library minio_manager;

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

/// Uploads all files listed in [List<FileSystemEntity>] to Minio.
/// 
/// Directories are not directly uploaded as Minio automatically creates folders
/// whenever a file path contains forward slashes.
/// The parameter [localBaseDirectory] is required to extract relative file paths.
void uploadFileSystemEntities(
    List<FileSystemEntity> fileSystemEntities, Directory localBaseDirectory) {
  try {
    final minio = _initializeClient();
    for (final fsEntity in fileSystemEntities) {
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
        minio
            .putObject(_bucket, fileName, stream, fileSizeInBytes)
            .then((value) {})
            // TODO: error handling
            .catchError(() {});
      }
    }
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
/// become forward slashes), and removes the leading slash (required for Minio).
///
/// Returns the relative path as a [String].
String _getCompatibleMinioPath(
    FileSystemEntity fileSystemEntity, Directory localBaseDirectory) {
  final relativePath = path
      .relative(fileSystemEntity.path, from: localBaseDirectory.path)
      .replaceAll('\\', '/');

  if (relativePath.startsWith('/')) {
    return relativePath.substring(1);
  }
  return relativePath;
}
