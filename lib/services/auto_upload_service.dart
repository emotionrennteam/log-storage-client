import 'dart:async';
import 'dart:io';

import 'package:log_storage_client/models/storage_object.dart';
import 'package:log_storage_client/utils/app_settings.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:log_storage_client/utils/storage_manager.dart'
    as storageManager;
import 'package:path/path.dart' as path;

/// A service which handles the auto upoad of log files.
/// 
/// Auto upload can be enabled and disabled. Auto upload works by watching
/// the log file directory for file-system notifications. If the predefined
/// trigger file `_UPLOAD` is modified (= created or changed), then the
/// directory which contains the trigger file will be automatically uploaded.
/// Unfortunately, Dart's API doesn't support recursive watching on Linux.
/// That means, auto upload will only work on OS X and Windows.
class AutoUploadService {

  StreamSubscription _fileEventStreamSubscription;

  /// Enables auto upload for the given directory [logFileDirectory].
  /// 
  /// Monitors the specified [logFileDirectory] for file-system notifications.
  /// If the predefined trigger file `_UPLOAD` is modified (= created or changed),
  /// then the directory which contains the trigger file will be automatically
  /// uploaded. Unfortunately, Dart's API doesn't support recursive watching on
  /// Linux. That means, auto upload will only work on OS X and Windows.
  void enableAutoUpload(Directory logFileDirectory) {
    if (logFileDirectory == null || logFileDirectory.path.isEmpty || !logFileDirectory.existsSync()) {
      throw FileSystemException(
        'The specified log file directory does not exist.',
      );
    }

    try {
      Stream<FileSystemEvent> eventStream = logFileDirectory.watch(
        recursive: false,
      );
      _fileEventStreamSubscription = eventStream.listen(
        (event) {
          /// Start upload on [FileSystemEvent.modify] of the trigger file.
          if ((path.basename(event.path) == AUTO_UPLOAD_TRIGGER_FILE) &&
              (!event.isDirectory) &&
              (event.type == FileSystemEvent.modify)) {
            this._triggerFileUpload(path.dirname(event.path));
          }
        },
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  // Disables auto upload which effectively turns of the file-system watcher.
  void disableAutoUpload() {
    this._fileEventStreamSubscription?.cancel();
  }

  void _triggerFileUpload(String directoryName) async {
    final uploadProfile = await getEnabledUploadProfile();
    final credentials = await getStorageConnectionCredentials();
    final storageObjects = [
      StorageObject(
        directoryName,
        isDirectory: true,
      ),
    ];

    storageManager.uploadObjectsToRemoteStorage(
      credentials,
      storageObjects,
      Directory(directoryName),
      uploadProfile,
      DateTime.now().toLocal(),
    );
  }
}
