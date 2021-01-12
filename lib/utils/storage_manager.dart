library storage_manager;

import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:log_storage_client/models/file_transfer_exception.dart';
import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/models/storage_object.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/services/progress_service.dart';
import 'package:path/path.dart' as p;
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart' as path;
import 'package:tuple/tuple.dart';

final _uploadDirectoryDateFormat = new DateFormat('yyyy-MM-dd_HH-mm-ss');

Minio _initializeClient(StorageConnectionCredentials credentials) {
  return Minio(
    endPoint: credentials.endpoint,
    port: credentials.port,
    region: credentials.region,
    useSSL: credentials.tlsEnabled,
    accessKey: credentials.accessKey,
    secretKey: credentials.secretKey,
  );
}

/// Checks whether the given credentials allow to connect to the storage system.
///
/// Returns a [Tuple4]. The first item contains a [bool] which is [true] upon
/// successful connection to the storage system and otherwise false. If no successful
/// connection could be established, then the second item contains an additional error
/// message as a [String]. The third item contains the (server) region of the bucket.
/// The fourth item contains a [List] of all available buckets on the storage system
/// server.
Future<Tuple4<bool, String, String, List<Bucket>>> validateConnection(
    StorageConnectionCredentials credentials) async {
  Minio minio;
  List<Bucket> buckets;
  String region;
  try {
    if (credentials.endpoint == null || credentials.port == null) {
      return Tuple4(false, 'Endpoint or port not configured.', null, null);
    }

    minio = _initializeClient(credentials);

    buckets = await minio.listBuckets();

    final bucketExists = await minio.bucketExists(credentials.bucket);

    // Warning of a common misconception: the "region" is not attached
    // to the server but to each bucket separately. This is why we
    // can't use `minio.region` to fill the `region` variable.
    region = await minio.getBucketRegion(credentials.bucket);

    if (!bucketExists) {
      return Tuple4(
        false,
        'The specified bucket \'${credentials.bucket}\' does not exist.',
        region,
        buckets,
      );
    }

    return Tuple4(true, null, region, buckets);
  } catch (e) {
    debugPrint(e.toString());
    return Tuple4(
      false,
      e.toString(),
      region,
      buckets,
    );
  }
}

/// Asynchronically lists all objects in the given bucket.
///
/// Returns a list of [StorageObject]s which represent directories and
/// files in the storage system. The [storagePath] is the directory or
/// path on S3, so to speak, for which all "children" objects shall be
/// listed.
Future<List<StorageObject>> listObjectsInRemoteStorage(
  StorageConnectionCredentials credentials,
  void Function(List<StorageObject>) sortFunction, {
  String storagePath = '',
  bool recursive = false,
}) async {
  final minio = _initializeClient(credentials);
  bool bucketExists = await minio.bucketExists(credentials.bucket);
  if (!bucketExists) {
    throw Exception('The given bucket "${credentials.bucket}" doesn\'t exist.');
  }

  // For listing objects in a S3 bucket the prefix must not start with a leading
  // slash but it must always end with a slash.
  var prefix = storagePath;
  if (storagePath.startsWith('/')) {
    prefix = storagePath.substring(1);
  }
  if (!storagePath.endsWith('/')) {
    prefix += '/';
  }

  List<ListObjectsChunk> objectsChunks = await minio
      .listObjects(credentials.bucket, prefix: prefix, recursive: recursive)
      .toList();
  List<StorageObject> storageObjects = [];

  for (var objectsChunk in objectsChunks) {
    for (var object in objectsChunk.objects) {
      storageObjects.add(StorageObject(
        object.key,
        lastModified: object.lastModified,
        sizeInBytes: object.size,
      ));
    }
    for (var prefix in objectsChunk.prefixes) {
      storageObjects.add(StorageObject(prefix, isDirectory: true));
    }
  }

  sortFunction(storageObjects);

  return storageObjects;
}

/// Lists all files and directories in the given [Directory] on the
/// local file system (not recursively).
///
/// Returns a list of [StorageObject]s which represent directories
/// and files on the local file system. The list is sorted in two
/// steps: directories come first, then all files. Within the set
/// of directories and files, all elements are sorted in alphabetically
/// descending order.
Future<List<StorageObject>> listObjectsOnLocalFileSystem(Directory directory,
    void Function(List<StorageObject>) sortFunction) async {
  final fileSystemEntities = directory.listSync(recursive: false);
  final storageObjects = fileSystemEntities.map((e) {
    final stats = e.statSync();
    return new StorageObject(
      e.path,
      isDirectory: e is Directory,
      lastModified: stats.modified,
      sizeInBytes: stats.size,
    );
  }).toList();

  sortFunction(storageObjects);

  return Future.value(storageObjects);
}

/// Creates a "presigned" (=shareable) link for downloading a [StorageObject] without
/// needing to authenticate at the storage system (=> public link).
///
/// Attention: in MinIO / S3, it is not possible to share directories. Only single files
/// can be shared via a link. The created link / URL is valid for 7 days.
Future<String> shareObjectFromRemoteStorage(
  StorageObject storageObject,
  StorageConnectionCredentials credentials,
) async {
  final minio = _initializeClient(credentials);
  if (storageObject.isDirectory) {
    throw new UnimplementedError();
  }
  return await minio.presignedGetObject(
    credentials.bucket,
    storageObject.path,
  );
}

/// Irreversibly deletes the specified [StorageObject] from the remote storage system.
///
/// Can also delete directories by recursively deleting all child objects.
Future<void> deleteObjectFromRemoteStorage(
  StorageObject storageObject,
  StorageConnectionCredentials credentials,
) async {
  final minio = _initializeClient(credentials);
  if (storageObject.isDirectory) {
    final childObjects = await listObjectsInRemoteStorage(
      credentials,
      sortByDirectoriesFirstThenFiles,
      storagePath: storageObject.path,
      recursive: true,
    );
    final childObjectsPaths = childObjects.map((o) => o.path).toList();

    await minio.removeObjects(credentials.bucket, childObjectsPaths);
  } else {
    await minio.removeObject(credentials.bucket, storageObject.path);
  }
}

/// Recursively downloads all storage objects in the given [List<StorageObject>] and their
/// children (files in sub-directories) to the given [downloadDirectory].
///
/// [StorageObject]s which are actually directories cannot be downloaded and will simply be
/// created as a directory on the local hard drive.
Future<void> downloadObjectsFromRemoteStorage(
  StorageConnectionCredentials credentials,
  Directory downloadDirectory,
  String currentDirectory,
  List<StorageObject> storageObjectsToDownload,
) async {
  ProgressService progressService = locator<ProgressService>();
  final progressStreamSink = progressService.startProgressStream('Download');

  // Delay download for 1 second so that the download progress animation can pop-up.
  await Future.delayed(Duration(seconds: 1));

  try {
    final minio = _initializeClient(credentials);
    bool bucketExists = await minio.bucketExists(credentials.bucket);
    if (!bucketExists) {
      throw Exception(
          'The given bucket "${credentials.bucket}" doesn\'t exist.');
    }

    final recursiveStorageObjectsToDownload =
        await _recursivelyListOnRemoteStorage(
      storageObjectsToDownload,
      credentials,
    );

    int i = 0;
    for (StorageObject storageObject in recursiveStorageObjectsToDownload) {
      progressStreamSink.add(i++ / recursiveStorageObjectsToDownload.length);

      if (storageObject.isDirectory) {
        try {
          final directoryName = _removeCurrentDirectoryPrefixFromFilePath(
              storageObject.path, currentDirectory);
          Directory(p.join(downloadDirectory.path, directoryName)).createSync();
        } on Exception catch (e) {
          progressService.getErrorMessagesSink().add(
                DownloadException(e.toString(), storageObject.path),
              );
          debugPrint(
              'failed to create directory ${storageObject.path}. Error: $e');
        }
      } else {
        await _downloadFileStorageObject(
          storageObject,
          downloadDirectory,
          currentDirectory,
          credentials,
          minio,
        ).catchError((e) {
          if (e is DownloadException) {
            progressService.getErrorMessagesSink().add(e);
          } else {
            progressService.getErrorMessagesSink().add(
                  DownloadException(e.toString(), storageObject.path),
                );
          }
          debugPrint(
              'failed to download file ${storageObject.path}. Error: $e');
        });
      }
    }
  } on Exception catch (e) {
    // TODO: error handling
    debugPrint('Exception during download: ${e.toString()}');
  } finally {
    progressService.endProgressStream();
  }
}

/// Recursively uploads all storage objects in the given [List<StorageObject>] and their
/// children (files in sub-directories) to the storage system.
///
/// This function does not act like a typical file sync client such as OneDrive, NextCloud,
/// or Dropbox. Instead, with each upload a new directory in the root level of the object
/// storage system is created. This directory's name contains a [DateTime] and the name
/// of the currently selected [UploadProfile]. All files are then uploaded into this
/// parent directory. This strategy ensures that existing log files are never overwritten
/// and each new upload creates a new parent directory no matter whether the same data
/// was already uploaded before.
/// In addition to the given list of [storageObjectsToUpload] an additional JSON file named
/// `_metadata.json` is created and uploaded. This file contains the given [uploadProfile]
/// serialized as JSON. Moreover, the properties of the [uploadProfile] are assigned as
/// user-deinfed object metadata (=S3 feature) to each object / file during upload.
/// Directories are not directly uploaded as Minio / S3 automatically creates folders
/// whenever a file path contains forward slashes.
/// The parameter [localBaseDirectory] is required to extract relative file paths and should
/// be equivalent to the parent directory (="local base / root dir") of all selected storage
/// objects.
/// This function emits upload progress events through the [StreamController]. The values
/// depicting the upload progress are within the range of 0.0 and 1.0.
/// The given [UploadProfile] and [DateTime] are used to assemble the name of the parent
/// upload directory.
Future<void> uploadObjectsToRemoteStorage(
  StorageConnectionCredentials credentials,
  List<StorageObject> storageObjectsToUpload,
  Directory localBaseDirectory,
  UploadProfile uploadProfile,
  DateTime uploadTimestamp,
) async {
  ProgressService progressService = locator<ProgressService>();
  final progressStreamSink = progressService.startProgressStream('Upload');

  // Delay download for 1 second so that the upload progress animation can pop-up.
  await Future.delayed(Duration(seconds: 1));

  try {
    final minio = _initializeClient(credentials);
    final fsEntitiesToUpload = _recursivelyListOnLocalFileSystem(
      storageObjectsToUpload,
    );
    final metadataFile = await _createMetadataJsonFileFromUploadProfile(
      uploadProfile,
      localBaseDirectory,
      fsEntitiesToUpload.where((e) => e is File).length,
    );
    fsEntitiesToUpload.add(metadataFile);

    final timestamp = _uploadDirectoryDateFormat.format(uploadTimestamp);
    final uploadProfileName = uploadProfile.name.length > 25
        ? uploadProfile.name.substring(0, 25)
        : uploadProfile.name;
    final metadata = <String, String>{
      'upload-profile': uploadProfile.name,
      'vehicle': uploadProfile.vehicle,
      'drivers': uploadProfile.drivers.join(';'),
      'event-or-location': uploadProfile.eventOrLocation.join(';'),
      'tags': uploadProfile.tags.join(';'),
    };

    int i = 0;
    for (final fsEntity in fsEntitiesToUpload) {
      progressStreamSink.add(i++ / fsEntitiesToUpload.length);

      // Only files must be synced to the storage system. Minio / S3 automatically
      // creates folders when a file path contains forward slashes.
      if (fsEntity is File) {
        Stream<List<int>> stream = fsEntity.openRead();
        final fileSizeInBytes = fsEntity.lengthSync();
        final fileName = _sanitizeFilePathForS3(
          "${timestamp}_$uploadProfileName/${_getRelativeFilePath(fsEntity, localBaseDirectory)}",
        );
        await minio
            .putObject(credentials.bucket, fileName, stream, fileSizeInBytes,
                metadata: metadata)
            .then((value) {
          debugPrint('successfully uploaded file ${fsEntity.path}');
        }).catchError((error) {
          progressService.getErrorMessagesSink().add(UploadException(
                error.toString(),
                _removeCurrentDirectoryPrefixFromFilePath(
                  fsEntity.path,
                  localBaseDirectory.path,
                ),
              ));
          debugPrint('failed to upload file ${fsEntity.path}. Error: $error');
        });
      }
    }
    await metadataFile.delete();
    progressStreamSink.add(1.0);
  } on Exception catch (e) {
    // TODO: error handling
    debugPrint('Exception during upload: ${e.toString()}');
  } finally {
    progressService.endProgressStream();
  }
}

/// Custom sorting which sorts a [List] of [StorageObject]s by directories first
/// followed by all files. Within the set of directories and files, all elements
/// are sorted in alphabetically descending order with the exception of the special
/// file `_metadata.json`. This file is sorted so that it is always shown as the
/// very first file.
void sortByDirectoriesFirstThenFiles(List<StorageObject> listToSort) {
  listToSort.sort((StorageObject o1, StorageObject o2) {
    if (o1.isDirectory && o2.isDirectory) {
      return o1
          .getBasename()
          .toLowerCase()
          .compareTo(o2.getBasename().toLowerCase());
    }
    if (o1.isDirectory) {
      return -1;
    }
    if (o2.isDirectory) {
      return 1;
    }
    if (o1.getBasename() == '_metadata.json') {
      return -1;
    }
    if (o2.getBasename() == '_metadata.json') {
      return 1;
    }
    return o1
        .getBasename()
        .toLowerCase()
        .compareTo(o2.getBasename().toLowerCase());
  });
}

/// Gets the object metadata for the given [storageObject].
///
/// For each object stored in a bucket, Amazon S3 maintains a set of
/// system metadata. When uploading an object to S3, one can assign
/// user-defined metadata to the object. This function returns a
/// [Map<String, String>] which contains all object metadata as key-
/// value pairs.
Future<Map<String, String>> getObjectMetadata(
    StorageConnectionCredentials credentials,
    StorageObject storageObject) async {
  final minio = _initializeClient(credentials);
  return minio
      .statObject(credentials.bucket, storageObject.path)
      .then((metadataMap) => metadataMap.metaData)
      .catchError((error) {
    debugPrint(
      'Failed to retrieve metadata for storage object "${storageObject.path}". Error: $error.',
    );
    return null;
  });
}

/// Traverses the given [List<StorageObject>] and recursively lists
/// all corresponding files, directories, and symlinks in all (sub-)
/// directories on the local file system.
///
/// Returns a [List<FileSystemEntity>] which contains all files,
/// directories, and symlinks.
List<FileSystemEntity> _recursivelyListOnLocalFileSystem(
    List<StorageObject> storageObjects) {
  final List<FileSystemEntity> recursiveFileSystemEntities = [];

  storageObjects.forEach((StorageObject storageObject) {
    if (storageObject.isDirectory) {
      final fsEntity = Directory(storageObject.path);
      recursiveFileSystemEntities.add(fsEntity);
      recursiveFileSystemEntities.addAll(
        fsEntity.listSync(recursive: true, followLinks: true),
      );
    } else {
      final fsEntity = File(storageObject.path);
      recursiveFileSystemEntities.add(fsEntity);
    }
  });

  return recursiveFileSystemEntities;
}

/// Traverses the given [List<StorageObject>] and recursively lists
/// all corresponding files in all (sub-)directories on the remote
/// storage system.
///
/// Returns a [List<StorageObject>] which contains all files.
Future<List<StorageObject>> _recursivelyListOnRemoteStorage(
    List<StorageObject> storageObjects,
    StorageConnectionCredentials credentials) async {
  final List<StorageObject> recursiveStorageObjects = [];

  for (StorageObject storageObject in storageObjects) {
    recursiveStorageObjects.add(storageObject);

    if (storageObject.isDirectory) {
      final childs = await listObjectsInRemoteStorage(
        credentials,
        sortByDirectoriesFirstThenFiles,
        storagePath: storageObject.path,
        recursive: true,
      );
      recursiveStorageObjects.addAll(childs);
    }
  }

  return recursiveStorageObjects;
}

/// Transforms the path of the given [FileSystemEntity] into a relative path
/// that is compatible with S3 by removing the base path from the given
/// [FileSystemEntity].
///
/// Returns the relative path as a [String].
String _getRelativeFilePath(
    FileSystemEntity fileSystemEntity, Directory localBaseDirectory) {
  return path.relative(fileSystemEntity.path, from: localBaseDirectory.path);
}

/// Downloads a single [StorageObject] (file) from the storage system and stores it
/// in the given [downloadDirectory] as file on the local file system.
Future<void> _downloadFileStorageObject(
  StorageObject fileStorageObject,
  Directory downloadDirectory,
  String currentDirectory,
  StorageConnectionCredentials credentials,
  Minio minio,
) async {
  try {
    final objectByteStream =
        await minio.getObject(credentials.bucket, fileStorageObject.path);
    final bytes = await objectByteStream.toBytes();
    final objectName = _removeCurrentDirectoryPrefixFromFilePath(
        fileStorageObject.path, currentDirectory);
    final filePath = p.join(downloadDirectory.path, objectName);

    // Ensure that the file's parent directory exists
    final parentDirectory = p.dirname(filePath);
    if (!Directory(parentDirectory).existsSync()) {
      Directory(parentDirectory).createSync();
    }

    File(filePath).writeAsBytesSync(bytes);
  } on Exception catch (e) {
    throw new DownloadException(e.toString(), fileStorageObject.path);
  }
}

/// Removes the current directory (e.g. '/file') from the StorageObject's name.
///
/// This step is necessary in situation such as: we are not in the root directory
/// of the remote storage (e.g. '/file/') and we now want to download a file. The
/// downloaded file should not be downloaded to $DOWNLOAD_DIR/file/my-file.txt but
/// instead to $DOWNLOAD_DIR/my-file.txt
String _removeCurrentDirectoryPrefixFromFilePath(
  String filePath,
  String currentDirectory,
) {
  if (currentDirectory.isNotEmpty && currentDirectory != path.separator) {
    return filePath.substring(currentDirectory.length);
  }
  return filePath;
}

/// Sanitizes the given file path so that it is safe to be used as
/// an object key name on Amazon S3 / MinIO.
///
/// Replaces backslash with forward slash (Windows -> Linux path) and
/// special characters with underscores `_` in the given file path to
/// make it compatible with Amazon S3. If the file path contains a
/// leading slash, then it will be removed (generally a bad idea in S3).
/// These steps are necessary because not all characters are safe to be
/// used in object key names. Amazon provides a list of safe characters.
/// Altough special characters such as `/`, `!`, `-`, `_`, `.`, `*`, `'`,
/// `(`, and `)` are mentioned as safe characters, the MinIO library used
/// in this Flutter app fails to handle file paths which contain an
/// exclamation character `!`.
/// See here for the official documentation:
/// https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingMetadata.html
String _sanitizeFilePathForS3(String filePath) {
  filePath = filePath
      .replaceAll('\\', '/')
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('Ä', 'ae')
      .replaceAll('Ö', 'oe')
      .replaceAll('Ü', 'ue')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[^a-zA-Z0-9-\._\/]'), '_');
  return filePath.startsWith('/') ? filePath.substring(1) : filePath;
}

/// Creates a file `_metadata.json` in the given [UploadDirectory].
///
/// The idea is that during each upload one additional file named
/// `_metadata.json` is generated which contains the information
/// from the currently selected/enabled [UploadProfile] encoded
/// as JSON. This information could later on be used by people
/// who want to analyze the uploaded log data (e.g. for filtering
/// for specific log data).
///
/// The value of [numberOfFiles] should contain the number of files
/// which are about to be uploaded. This number is included in the
/// JSON file `_metadata.json` as additional metadata.
Future<FileSystemEntity> _createMetadataJsonFileFromUploadProfile(
  UploadProfile uploadProfile,
  Directory uploadDirectory,
  int numberOfFiles,
) async {
  final jsonFile = File(
    path.join(uploadDirectory.path, '_metadata.json'),
  );
  await jsonFile.writeAsString(
    uploadProfile.toJsonString(numberOfFiles),
  );
  return jsonFile;
}
