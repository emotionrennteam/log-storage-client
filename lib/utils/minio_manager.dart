library minio_manager;

import 'dart:async';
import 'dart:io';

import 'package:log_storage_client/models/file_transfer_exception.dart';
import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/models/storage_object.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/utils/progress_service.dart';
import 'package:path/path.dart' as p;
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart' as path;
import 'package:tuple/tuple.dart';

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

/// Checks whether the given credentials allow to connect to the MinIO storage system.
///
/// Returns a [Tuple4]. The first item contains a [bool] which [bool] is [true] upon
/// successful connection to MinIO and otherwise false. If no successful connection
/// could be established, then the second item contains an additional error message as
/// a [String]. The third item contains the region of the MinIO server. The fourth item
/// contains the [List] of buckets available at the MinIO server.
Future<Tuple4<bool, String, String, List<Bucket>>> validateConnection(
    StorageConnectionCredentials credentials) async {
  Minio minio;
  List<Bucket> buckets;
  String region;
  try {
    minio = _initializeClient(credentials);
    if (credentials.bucket != null) {
      // Warning before misconception: the "region" is not attached
      // to the server but to each bucket separately. This is why we
      // can't use `minio.region`.
      region = await minio.getBucketRegion(credentials.bucket);
    }

    final bucketExists = await minio.bucketExists(credentials.bucket);
    buckets = await minio.listBuckets();

    if (!bucketExists) {
      return Tuple4(
        false,
        'The specified bucket ${credentials.bucket} doesn\'t exist.',
        region,
        buckets,
      );
    }

    return Tuple4(true, null, region, buckets);
  } catch (e) {
    return Tuple4(
      false,
      e.toString(),
      region,
      buckets,
    );
  }
}

/// Asynchronically lists all objects in the given Minio bucket.
///
/// Returns a list of [StorageObject]s which represent directories
/// and files in Minio.
Future<List<StorageObject>> listObjectsInRemoteStorage(
  StorageConnectionCredentials credentials, {
  String path = '',
  bool recursive = false,
}) async {
  final minio = _initializeClient(credentials);
  bool bucketExists = await minio.bucketExists(credentials.bucket);
  if (!bucketExists) {
    throw Exception('The given bucket "${credentials.bucket}" doesn\'t exist.');
  }

  List<ListObjectsChunk> objectsChunks = await minio
      .listObjects(credentials.bucket, prefix: path, recursive: recursive)
      .toList();
  List<StorageObject> storageObjects = List();

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
  return storageObjects;
}

/// Creates a "presigned" (=shareable) link for downloading a [StorageObject] without
/// needing to authenticate at MinIO (=> public link).
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
Future<void> deleteObjectFromRemoteStorage(
  StorageObject storageObject,
  StorageConnectionCredentials credentials,
) async {
  final minio = _initializeClient(credentials);
  // TODO: delete directories by removing objects recursively
  if (storageObject.isDirectory) {
    throw new UnimplementedError();
  }
  await minio.removeObject(credentials.bucket, storageObject.path);
}

/// Recursively downloads all storage objects in the given [List<StorageObject>] and their
/// children (files in sub-directories) to the given [downloadDirectory].
///
/// [StorageObject]s which are actually directories cannot be downloaded and will simply be created
/// as a directory on the local hard drive.
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
/// children (files in sub-directories) to Minio.
///
/// Directories are not directly uploaded as Minio automatically creates folders
/// whenever a file path contains forward slashes.
/// The parameter [localBaseDirectory] is required to extract relative file paths.
/// Emits upload progress events through the [StreamController]. The values to
/// depict the upload progress are within the range of 0 and 1.
Future<void> uploadObjectsToRemoteStorage(
  StorageConnectionCredentials credentials,
  List<StorageObject> storageObjectsToUpload,
  Directory localBaseDirectory,
) async {
  ProgressService progressService = locator<ProgressService>();
  final progressStreamSink = progressService.startProgressStream('Upload');

  // Delay download for 1 second so that the upload progress animation can pop-up.
  await Future.delayed(Duration(seconds: 1));

  try {
    final minio = _initializeClient(credentials);
    final fsEntitiesToUpload =
        _recursivelyListOnLocalFileSystem(storageObjectsToUpload);

    int i = 0;
    for (final fsEntity in fsEntitiesToUpload) {
      progressStreamSink.add(i++ / fsEntitiesToUpload.length);

      // Only files must be synced to Minio. Minio does automatically create folders
      // when a file path contains forward slashes.
      if (fsEntity is File) {
        Stream<List<int>> stream = fsEntity.openRead();
        final fileSizeInBytes = fsEntity.lengthSync();
        final fileName = _getCompatibleMinioPath(fsEntity, localBaseDirectory);
        await minio
            .putObject(credentials.bucket, fileName, stream, fileSizeInBytes)
            .then((value) {
          debugPrint('successfully uploaded. File: ${fsEntity.path}');
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
    progressStreamSink.add(1.0);
  } on Exception catch (e) {
    // TODO: error handling
    debugPrint('Exception during upload: ${e.toString()}');
  } finally {
    progressService.endProgressStream();
  }
}

/// Traverses the given [List<StorageObject>] and recursively lists
/// all corresponding files, directories, and symlinks in all (sub-)
/// directories on the local file system.
///
/// Returns a [List<FileSystemEntity>] which contains all files,
/// directories, and symlinks.
List<FileSystemEntity> _recursivelyListOnLocalFileSystem(
    List<StorageObject> storageObjects) {
  final recursiveFileSystemEntities = List<FileSystemEntity>();

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
  final recursiveStorageObjects = List<StorageObject>();

  for (StorageObject storageObject in storageObjects) {
    recursiveStorageObjects.add(storageObject);

    if (storageObject.isDirectory) {
      final childs = await listObjectsInRemoteStorage(
        credentials,
        path: storageObject.path,
        recursive: true,
      );
      recursiveStorageObjects.addAll(childs);
    }
  }

  return recursiveStorageObjects;
}

/// Transforms the path of the given [FileSystemEntity] into a relative path
/// that is compatible with Minio.
///
/// Removes the base path from the given [FileSystemEntity] so that it becomes a
/// relative path, makes the path name POSIX conform (Windows backslashes
/// become forward slashes), replaces characters except [a-zA-Z0-9-\._\/]
/// by underscores, and removes the leading slash (required for Minio).
///
/// Returns the relative path as a [String].
String _getCompatibleMinioPath(
    FileSystemEntity fileSystemEntity, Directory localBaseDirectory) {
  final relativePath = path
      .relative(fileSystemEntity.path, from: localBaseDirectory.path)
      .replaceAll('\\', '/')
      // Prevent special characters in file names, e.g. Minio cannot handle the character '!'.
      .replaceAll(new RegExp(r'[^a-zA-Z0-9-\._\/]'), '_');

  if (relativePath.startsWith('/')) {
    return relativePath.substring(1);
  }
  return relativePath;
}

/// Downloads a single [StorageObject] (file) from MinIO and stores it in the given
/// [downloadDirectory] as file on the local file system.
Future<void> _downloadFileStorageObject(
  StorageObject fileStorageObject,
  Directory downloadDirectory,
  String currentDirectory,
  StorageConnectionCredentials credentials,
  Minio minio,
) async {
  try {
    var objectByteStream =
        await minio.getObject(credentials.bucket, fileStorageObject.path);
    var bytes = await objectByteStream.toBytes();
    var objectName = _removeCurrentDirectoryPrefixFromFilePath(
        fileStorageObject.path, currentDirectory);
    // TODO: ensure that parent directory exists
    File(p.join(downloadDirectory.path, objectName)).writeAsBytesSync(bytes);
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
