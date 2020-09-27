library utils;

import 'package:emotion/utils/constants.dart';
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
SnackBar getSnackBar(String message, bool isErrorMessage) {
  final color = isErrorMessage ? LIGHT_RED : Color.fromRGBO(1, 176, 117, 1);
  return SnackBar(
    content: Row(
      children: <Widget>[
        // Icon(
        //   errorMessage ? Icons.highlight_off : Icons.check_circle_outline,
        //   color: color,
        // ),
        // SizedBox(
        //   width: 8,
        // ),
        Text(
          isErrorMessage ? 'ERROR' : 'SUCCESS',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 3,
                color: color,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 26,
        ),
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
