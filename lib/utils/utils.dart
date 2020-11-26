library utils;

import 'package:log_storage_client/utils/constants.dart';
import 'package:flutter/material.dart';
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
  return path.isWithin(artificialRootDirectory, parentDirectory) ? parentDirectory : artificialRootDirectory;
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
