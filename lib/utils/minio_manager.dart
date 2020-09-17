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
/// Returns a [Tuple2<bool, String>] where the first item contains a [bool]. The [bool]
/// is [true] upon successful connection and otherwise false. If no successful connection
/// could be established, then the second item contains an additional error message as a [String].
Future<Tuple2<bool, String>> validateConnection(
    StorageConnectionCredentials credentials) async {
  try {
    final minio = _initializeClient(credentials);
    var bucketExists = await minio.bucketExists(credentials.bucket);
    if (!bucketExists) {
      return Tuple2(false,
          'Connection error: the bucket "${credentials.bucket}" doesn\'t exist.');
    }
    return Tuple2(true, null);
  } catch (e) {
    return Tuple2(false, 'Connection error: ${e.toString()}');
  }
}

/// Asynchronically lists all objects in the given Minio bucket.
///
/// Returns a list of [StorageObject]s which represent directories
/// and files in Minio.
Future<List<StorageObject>> listObjectsInRemoteStorage(
    StorageConnectionCredentials credentials) async {
  final minio = _initializeClient(credentials);
  bool bucketExists = await minio.bucketExists(credentials.bucket);
  if (!bucketExists) {
    throw Exception('The given bucket "${credentials.bucket}" doesn\'t exist.');
  }

  List<ListObjectsChunk> objectsChunks =
      await minio.listObjects(credentials.bucket).toList();
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

/// Downloads all objects in the given list of [StorageObject]s to the given [downloadDirectory].
/// 
/// [StorageObject]s which are actually directories cannot be downloaded and will simply be created
/// as a directory on the local hard drive.
Future<void> downloadObjectsFromRemoteStorage(
  StorageConnectionCredentials credentials,
  Directory downloadDirectory,
  List<StorageObject> storageObjectsToDownload,
) async {
  final minio = _initializeClient(credentials);
  bool bucketExists = await minio.bucketExists(credentials.bucket);
  if (!bucketExists) {
    throw Exception('The given bucket "${credentials.bucket}" doesn\'t exist.');
  }

  // TODO: improve by adding a stream for the download progress
  for (StorageObject storageObject in storageObjectsToDownload) {
    // Create directories and only download files
    if (storageObject.isDirectory) {
      Directory(p.join(downloadDirectory.path, storageObject.name)).createSync();
      continue;
    }
    var objectByteStream =
        await minio.getObject(credentials.bucket, storageObject.name);
    var bytes = await objectByteStream.toBytes();
    File(p.join(downloadDirectory.path, storageObject.name))
        .writeAsBytes(bytes);
  }
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
