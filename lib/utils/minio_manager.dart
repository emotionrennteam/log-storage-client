library minio_manager;

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:minio/minio.dart';
import 'package:path/path.dart' as path;

final String _bucket = 'logs';

Minio _initializeClient() {
  return Minio(
    endPoint: '127.0.0.1',
    port: 9000,
    useSSL: false,
    accessKey: 'minioadmin',
    secretKey: 'minioadmin',
  );
}

/// Checks whether the given credentials allow to connect to the MinIO storage system.
/// 
/// Returns [true] if a successful connection was made. Otherwise, returns [false].
Future<bool> validateConnection(String endpoint, int port, bool useSSL,
    String accessKey, String secretKey) async {
  try {
    final minio = Minio(
      endPoint: endpoint,
      port: port,
      useSSL: useSSL,
      accessKey: accessKey,
      secretKey: secretKey,
    );
    await minio.listBuckets();
    return true;
  } catch (_) {
    return false;
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
    List<FileSystemEntity> fileSystemEntities,
    Directory localBaseDirectory,
    StreamController<double> progressController) async {
  try {
    progressController.add(0.0);

    final minio = _initializeClient();
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
            .putObject(_bucket, fileName, stream, fileSizeInBytes)
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
