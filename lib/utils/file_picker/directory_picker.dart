import 'dart:io';
import 'windows_directory_picker.dart' as windows_directory_picker;
import 'linux_directory_picker.dart' as linux_directory_picker;

/// Selects a directory and returns its absolute path.
///
/// [dialogTitle] is a string that is displayed above the tree view control in the
/// dialog box. This string can be used to specify instructions to the user.
/// Returns [null] if folder path couldn't be resolved.
Future<String> pickDirectory({String dialogTitle = ''}) {
  if (Platform.isWindows) {
    return Future(() => windows_directory_picker.pickDirectory(dialogTitle));
  }
  if (Platform.isLinux) {
    return Future(() => linux_directory_picker.pickDirectory(dialogTitle));
  }

  throw UnimplementedError(
    'The current platform is not supported by this plugin.',
  );
}
