library utils;

import 'dart:io';

import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/services/auto_upload_service.dart';
import 'package:log_storage_client/services/upload_profile_service.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:log_storage_client/utils/i_app_settings.dart';
import 'package:log_storage_client/utils/locator.dart';
import 'package:path/path.dart' as path;

/// Computes the path of the parent directory for the given path.
///
/// Returns the parent directory for the given [currentPath].
/// If [artificialRootDirectory] is set, this method prevents from
/// navigating further-up in the file system hierarchy than the path
/// given in [artificialRootDirectory]. That is, [artificialRootDirectory]
/// becomes the artificial "root" directory.
String getParentPath(
  String currentPath,
  String pathSeparator, {
  String artificialRootDirectory,
}) {
  final parentDirectory = path.dirname(currentPath);
  if (artificialRootDirectory == null) {
    return parentDirectory;
  }
  // Limits the returned path from being further-up in the directory
  // structure than the artifical root directory.
  return path.isWithin(artificialRootDirectory, parentDirectory)
      ? parentDirectory
      : artificialRootDirectory;
}

/// Returns a styled instance of [SnackBar].
///
/// Depending on [isErrorMessage], the SnackBar includes an additional
/// label with the text 'SUCCESS' or 'ERROR' in green respectively red
/// color.
SnackBar getSnackBar(String message, bool isErrorMessage,
    {SnackBarAction snackBarAction}) {
  return SnackBar(
    duration: Duration(
      seconds: isErrorMessage ? 10 : 4,
    ),
    action: snackBarAction,
    content: Row(
      children: <Widget>[
        isErrorMessage
            ? Container(
                margin: EdgeInsets.only(
                  right: 24,
                ),
                child: Text(
                  'ERROR',
                  style: TextStyle(
                    color: LIGHT_RED,
                    fontWeight: FontWeight.w800,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 10,
                        color: LIGHT_RED,
                      ),
                    ],
                  ),
                  maxLines: 2,
                ),
              )
            : SizedBox(),
        Expanded(
          child: Text(
            message,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

/// Initializes the app.
///
/// Initializes the service locator which registers service implementations
/// as singletons.
/// Checks whether at least one [UploadProfile] exists and if not creates
/// a default [UploadProfile].
/// Enables the file watcher if auto upload is enabled.
initializeApp() {
  setupLocator();

  IAppSettings appSettings = locator<IAppSettings>();

  appSettings.getUploadProfiles().then((List<UploadProfile> uploadProfiles) {
    if (uploadProfiles == null || uploadProfiles.isEmpty) {
      appSettings.setUploadProfiles([
        UploadProfile(
          'Default',
          'Unknown',
          ['-'],
          ['Unknown'],
          List.empty(),
          enabled: true,
        ),
      ]).then((_) {
        locator<UploadProfileService>().getUploadProfileChangeSink().add(null);
      });
    }
  });

  appSettings.getAutoUploadEnabled().then((autoUploadEnabled) {
    if (autoUploadEnabled != null && autoUploadEnabled) {
      appSettings.getLogFileDirectoryPath().then((logFileDirectoryPath) {
        if (logFileDirectoryPath != null && logFileDirectoryPath.isNotEmpty) {
          locator<AutoUploadService>().enableAutoUpload(
            Directory(logFileDirectoryPath),
          );
        }
      });
    }
  });
}
