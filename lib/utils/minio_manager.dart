library minio_manager;

import 'dart:async';
import 'dart:io';

import 'package:emotion/models/storage_connection_credentials.dart';
import 'package:emotion/models/storage_object.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:path/path.dart' as path;
import 'package:tuple/tuple.dart';

Minio _initializeClient(StorageConnectionCredentials credentials) {
  return Minio(
    endPoint: credentials.endpoint,
    port: credentials.port,
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
    StorageConnectionCredentials credentials,
    {String path = ''}) async {
  final minio = _initializeClient(credentials);
  bool bucketExists = await minio.bucketExists(credentials.bucket);
  if (!bucketExists) {
    throw Exception('The given bucket "${credentials.bucket}" doesn\'t exist.');
  }

  List<ListObjectsChunk> objectsChunks = await minio
      .listObjects(credentials.bucket, prefix: path, recursive: false)
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
    storageObject.name,
  );
}

/// Irreversibly deletes the specified [StorageObject].
Future<void> deleteObjectFromRemoteStorage(
  StorageObject storageObject,
  StorageConnectionCredentials credentials,
) async {
  final minio = _initializeClient(credentials);
  // TODO: delete directories by removing objects recursively
  if (storageObject.isDirectory) {
    throw new UnimplementedError();
  }
  await minio.removeObject(credentials.bucket, storageObject.name);
}

/// Downloads all objects in the given list of [StorageObject]s to the given [downloadDirectory].
///
/// [StorageObject]s which are actually directories cannot be downloaded and will simply be created
/// as a directory on the local hard drive.
Future<void> downloadObjectsFromRemoteStorage(
  StorageConnectionCredentials credentials,
  Directory downloadDirectory,
  String currentDirectory,
  List<StorageObject> storageObjectsToDownload,
) async {
  final minio = _initializeClient(credentials);
  bool bucketExists = await minio.bucketExists(credentials.bucket);
  if (!bucketExists) {
    throw Exception('The given bucket "${credentials.bucket}" doesn\'t exist.');
  }

  // TODO: improve by adding a stream for the download progress
  _downloadStorageObjects(storageObjectsToDownload, downloadDirectory,
      currentDirectory, minio, credentials);
}

/// Uploads all files listed in [List<FileSystemEntity>] to Minio.
///
/// Directories are not directly uploaded as Minio automatically creates folders
/// whenever a file path contains forward slashes.
/// The parameter [localBaseDirectory] is required to extract relative file paths.
/// Emits upload progress events through the [StreamController]. The values to
/// depict the upload progress are within the range of 0 and 1.
Future<void> uploadFileSystemEntities(
    StorageConnectionCredentials credentials,
    List<FileSystemEntity> fileSystemEntities,
    Directory localBaseDirectory,
    StreamController<double> progressController) async {
  try {
    progressController.add(0.0);

    final minio = _initializeClient(credentials);
    int iteration = 0;

    for (final fsEntity in fileSystemEntities) {
      progressController.add(iteration / fileSystemEntities.length);
      iteration++;
      // Only files must be synced to Minio. Minio does automatically create folders
      // when a file path contains forward slashes.
      if (fsEntity is File) {
        if (!fsEntity.existsSync()) {
          // TODO: error handling
          debugPrint('File doesn\'t exist');
          continue;
        }
        Stream<List<int>> stream = fsEntity.openRead();
        final fileSizeInBytes = fsEntity.lengthSync();
        final fileName = _getCompatibleMinioPath(fsEntity, localBaseDirectory);
        await minio
            .putObject(credentials.bucket, fileName, stream, fileSizeInBytes)
            .then((value) {})
            // TODO: error handling
            .catchError((error) {});
      }
    }
    progressController.add(1.0);
  } on Exception catch (e) {
    // TODO: error handling
    debugPrint('Exception: ${e.toString()}');
  }
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

/// Entry point for triggering the recursive download of all [StorageObject] in
/// the given list (files + directories).
void _downloadStorageObjects(
  List<StorageObject> storageObjects,
  Directory downloadDirectory,
  String currentDirectory,
  Minio minio,
  StorageConnectionCredentials credentials,
) {
  for (StorageObject storageObject in storageObjects) {
    // Create directories (don't download because MinIO comes without the abstraction of directories).
    if (storageObject.isDirectory) {
      _downloadDirectoryStorageObject(storageObject, downloadDirectory,
          currentDirectory, credentials, minio);
    } else {
      // Download files
      _downloadFileStorageObject(storageObject, downloadDirectory,
          currentDirectory, credentials, minio);
    }
  }
}

/// Recursively mirrors a directory and all its child files and directories
/// from MinIO and stores it on the local file system.
///
/// Directories itself are created directly and not downloaded from
/// MinIO because MinIO doesn't come with the concept of directories.
/// Triggers the download of all child [StorageObject]s (files
/// and directories).
void _downloadDirectoryStorageObject(
  StorageObject directoryStorageObject,
  Directory downloadDirectory,
  String currentDirectory,
  StorageConnectionCredentials credentials,
  Minio minio,
) async {
  var directoryName = _removeCurrentDirectoryPrefixFromStorageObject(
      directoryStorageObject, currentDirectory);
  Directory(
    p.join(
      downloadDirectory.path,
      directoryName,
    ),
  ).createSync();

  final childStorageObjects = await listObjectsInRemoteStorage(credentials,
      path: directoryStorageObject.name);
  _downloadStorageObjects(
    childStorageObjects,
    downloadDirectory,
    currentDirectory,
    minio,
    credentials,
  );
}

/// Downloads a single [StorageObject] (file) from MinIO and stores it in the given
/// [downloadDirectory] as file on the local file system.
void _downloadFileStorageObject(
  StorageObject fileStorageObject,
  Directory downloadDirectory,
  String currentDirectory,
  StorageConnectionCredentials credentials,
  Minio minio,
) async {
  var objectByteStream =
      await minio.getObject(credentials.bucket, fileStorageObject.name);
  var bytes = await objectByteStream.toBytes();

  var objectName = _removeCurrentDirectoryPrefixFromStorageObject(
      fileStorageObject, currentDirectory);

  try {
    // TODO: async or sync file creation?
    File(p.join(downloadDirectory.path, objectName)).writeAsBytesSync(bytes);
  } on FileSystemException catch (e) {
    throw new Exception(
        'Failed to download file to "${e.path}". Reason: ${e.osError}');
  } on Exception catch (e) {
    // TODO: handle error
    debugPrint('Failed to download file. Reason: $e');
  }
}

/// Removes the current directory (e.g. '/file') from the StorageObject's name.
///
/// This step is necessary in situation such as: we are not in the root directory
/// of the remote storage (e.g. '/file/') and we now want to download a file. The
/// downloaded file should not be downloaded to $DOWNLOAD_DIR/file/my-file.txt but
/// instead to $DOWNLOAD_DIR/my-file.txt
String _removeCurrentDirectoryPrefixFromStorageObject(
  StorageObject storageObject,
  String currentDirectory,
) {
  if (currentDirectory.isNotEmpty && currentDirectory != path.separator) {
    return storageObject.name.substring(currentDirectory.length);
  }
  return storageObject.name;
}
