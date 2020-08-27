import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FileSystemEntityTable extends StatelessWidget {
  final Directory _monitoredDirectory;
  final List<FileSystemEntity> _fileSystemEntities;

  FileSystemEntityTable(this._monitoredDirectory, this._fileSystemEntities);

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
      itemBuilder: (context, position) {
        return this._buildRow(this._fileSystemEntities[position]);
      },
    );
  }
}
