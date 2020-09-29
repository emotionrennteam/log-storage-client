library utils;

import 'package:log_storage_client/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

/// Computes the path of the parent directory for the given path.
///
/// Returns an empty string when the root of the directory tree has
/// been reached. Otherwise, returns the path to the parent directory
/// using the current system's separator ('forward slash on Linux
/// and backslash on Windows).
String getParentForPath(String currentPath, String pathSeparator) {
  List<String> pathComponents = path.split(currentPath);
  if (pathComponents.isEmpty || pathComponents.length == 1) {
    return '';
  }
  pathComponents.removeLast();
  return path.joinAll(pathComponents) + pathSeparator;
}

/// Returns a styled instance of [SnackBar].
///
/// Depending on [isErrorMessage], the SnackBar includes an additional
/// label with the text 'SUCCESS' or 'ERROR' in green respectively red
/// color.
SnackBar getSnackBar(String message, bool isErrorMessage, {SnackBarAction snackBarAction}) {
  return SnackBar(
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
