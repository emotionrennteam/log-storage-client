import 'dart:io';

import 'package:emotion/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FileSystemEntityTable extends StatelessWidget {
  final bool _autoUploadEnabled;
  final List<FileSystemEntity> _fileSystemEntities;
  final Directory _monitoredDirectory;

  FileSystemEntityTable(
    this._autoUploadEnabled,
    this._fileSystemEntities,
    this._monitoredDirectory,
  );

  Widget _buildRow(FileSystemEntity fileSystemEntity) {
    // TODO: make file tree navigatable
    // final relativePath = path.relative(
    //   fileSystemEntity.path,
    //   from: this._monitoredDirectory.path,
    // );
    // // Hide nested directories & files.
    // if (relativePath.contains('\\') || relativePath.contains('/')) {
    //   return SizedBox();
    // }
    
    // Don't show the trigger file if auto upload is enabled
    if (this._autoUploadEnabled &&
        (fileSystemEntity is File) &&
        (path.basename(fileSystemEntity.path) == AUTO_UPLOAD_TRIGGER_FILE)) {
      return SizedBox();
    }

    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(40, 40, 40, 1),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: ListTile(
        leading: Icon(
          fileSystemEntity is Directory
              ? Icons.folder
              : Icons.insert_drive_file,
          color: Colors.grey.withOpacity(0.4),
        ),
        title: Text(
          path.basename(fileSystemEntity.path),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        trailing: Text(
          'Upload Pending',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      margin: EdgeInsets.symmetric(vertical: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: this._fileSystemEntities.length,
      itemBuilder: (context, position) {
        return this._buildRow(this._fileSystemEntities[position]);
      },
    );
  }
}
