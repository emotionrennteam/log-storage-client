import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class StorageObject {
  final bool isDirectory;
  final DateTime lastModified;
  final String name;
  final int sizeInBytes;

  final DateFormat _format = DateFormat('dd.MM.yyyy HH:mm');

  StorageObject(this.name,
      {this.isDirectory = false, this.lastModified, this.sizeInBytes = 0});

  /// Transforms the object's size into a human readable format.
  /// Returns the size of the object + the unit concatenated as a [String],
  /// e.g. "100 MBytes".
  String getHumanReadableSize() {
    int divisor = 1;
    String unit = 'Bytes';

    if (this.sizeInBytes > 999999999) {
      divisor = 1000000000;
      unit = 'GBytes';
    } else if (this.sizeInBytes > 999999) {
      divisor = 1000000;
      unit = 'MBytes';
    } else if (this.sizeInBytes > 999) {
      divisor = 1000;
      unit = 'KBytes';
    }

    return '${(this.sizeInBytes / divisor).toStringAsFixed(0)} $unit';
  }

  /// Transforms the last modified timestamp into a human readable format.
  /// Returns an empty [String] if no timestamp is set (e.g. when object is
  /// a directory).
  String getHumanReadableLastModified() {
    if (this.lastModified != null) {
      return this._format.format(this.lastModified.toLocal());
    }
    return '';
  }

  /// Returns the basename, that is the name of the current directory or file
  /// without the full / absolute path.
  String getBasename() {
    return path.basename(this.name);
  }
}
