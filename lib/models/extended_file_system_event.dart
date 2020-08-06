import 'dart:io';

import 'package:flutter/cupertino.dart';

class ExtendedFileSystemEvent {
  final FileSystemEvent fileSystemEvent;
  final DateTime timestamp;

  ExtendedFileSystemEvent({
    @required this.fileSystemEvent,
    @required this.timestamp,
  });
}
