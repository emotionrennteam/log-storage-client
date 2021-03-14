import 'dart:io';

/// Selects a directory and returns its absolute path.
///
/// [dialogTitle] is a string that is displayed above the tree view control in the
/// dialog box. This string can be used to specify instructions to the user.
/// Returns [null] if folder path couldn't be resolved or the user closed the dialog
/// without selecting a directory.
Future<String> pickDirectory(String dialogTitle) async {
  try {
    final executable = await _cmdPath();
    return await _openFileSelectionDialog(
      executable,
      dialogTitle,
      pickDirectory: true,
    );
  } catch (e) {
    return null;
  }
}

Future<String> _openFileSelectionDialog(String executable, String dialogTitle,
    {String fileFilter = '', bool pickDirectory = false}) async {
  final arguments = ['--file-selection', '--title', dialogTitle];

  if (fileFilter.isNotEmpty) {
    arguments.add('--file-filter==$fileFilter');
  }

  if (pickDirectory) {
    arguments.add('--directory');
  }

  final processResult = await Process.run(
    executable,
    arguments,
  );

  final path = processResult.stdout?.toString()?.trim();
  if (processResult.exitCode != 0 || path == null || path.isEmpty) {
    return Future.error(
      'The selected path couldn\'t be resolved or the user closed the dialog ' +
          'without selecting a directory.',
    );
  }
  return path;
}

/// Returns the path to `qarma` or `zenity` executable as a [String]. The future
/// returns an error, if neither of both executables was found on the path.
Future<String> _cmdPath() async {
  try {
    return await _isExecutableOnPath('qarma');
  } catch (e) {
    return await _isExecutableOnPath('zenity');
  }
}

Future<String> _isExecutableOnPath(String executable) async {
  final processResult = await Process.run('which', [executable]);
  final path = processResult.stdout?.toString()?.trim();
  if (processResult.exitCode != 0 || path == null || path.isEmpty) {
    return Future.error(
      'Couldn\'t find the executable $executable in the path.',
    );
  }
  return path;
}
