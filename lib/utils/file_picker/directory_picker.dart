import 'dart:io';
import 'windows_directory_picker.dart' as windows_directory_picker;

/// Selects a directory and returns its absolute path.
///
/// [title] is a string that is displayed above the tree view control in the
/// dialog box. This string can be used to specify instructions to the user.
/// Returns [null] if folder path couldn't be resolved.
Future<String> pickDirectory({String title = ''}) {
  if (Platform.isWindows) {
    return Future(() => windows_directory_picker.pickDirectory(title));
  }

  throw UnimplementedError(
    'The current platform is not supported by this plugin.',
  );
}
