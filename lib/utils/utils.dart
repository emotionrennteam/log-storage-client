library utils;

import 'package:path/path.dart' as path;

/// Computes the path of the parent directory for the given path.
/// 
/// Returns an empty string when the root of the directory tree has
/// been reached. Otherwise, returns the path to the parent directory
/// using the current system's separator ('forward slash on Linux
/// and backward slash on Windows).
String getParentForPath(String currentPath) {
  List<String> pathComponents = path.split(currentPath);
  if (pathComponents.isEmpty || pathComponents.length == 1) {
    return '';
  }
  pathComponents.removeLast();
  return path.joinAll(pathComponents) + path.separator;
}
