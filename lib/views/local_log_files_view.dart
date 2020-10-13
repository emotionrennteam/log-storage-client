import 'dart:io';

import 'package:log_storage_client/models/storage_object.dart';
import 'package:log_storage_client/utils/app_settings.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/minio_manager.dart';
import 'package:log_storage_client/utils/utils.dart';
import 'package:log_storage_client/widgets/floating_action_button_position.dart';
import 'package:log_storage_client/widgets/storage_object_table.dart';
import 'package:log_storage_client/widgets/storage_object_table_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:path/path.dart' as path;

class LocalLogFilesView extends StatefulWidget {
  LocalLogFilesView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _LocalLogFilesViewState();
}

class _LocalLogFilesViewState extends State<LocalLogFilesView> {
  bool _uploadInProgress = false;

  List<FileSystemEntity> _fileSystemEntities = [];
  Directory _monitoredDirectory;
  List<StorageObject> _storageObjects = List();
  Function _onUploadFabPressed;

  Directory _currentDirectory;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToDirectory(String absolutePath) {
    // Navigate to parent in the directory tree
    if (absolutePath == null) {
      setState(() {
        this._currentDirectory = Directory(
          getParentForPath(this._currentDirectory.path, path.separator),
        );
      });
    } else {
      // Navigate to child in the directory tree
      setState(() {
        this._currentDirectory = Directory(absolutePath);
      });
    }
    _loadStorageObjects();
  }

  void _init() async {
    var logFileDirectory = await getLogFileDirectoryPath();
    this._monitoredDirectory = new Directory(logFileDirectory);
    this._currentDirectory = this._monitoredDirectory;
    _loadStorageObjects();
  }

  void _loadStorageObjects() {
    _fileSystemEntities = this._currentDirectory.listSync(recursive: false);

    setState(() {
      this._storageObjects = this._fileSystemEntities.map((e) {
        final stats = e.statSync();
        return new StorageObject(
          e.path,
          isDirectory: e is Directory,
          lastModified: stats.modified,
          sizeInBytes: stats.size,
        );
      }).toList();
    });
  }

  /// A [FloatingActionButton] for triggering the upload of log files.
  /// This button is automatically disabled when an upload is in progress.
  FloatingActionButton _uploadFAB() {
    return FloatingActionButton.extended(
      /// During upload, the FAB is disabled
      onPressed: this._onUploadFabPressed,
      backgroundColor: this._onUploadFabPressed == null
          ? DARK_GREY
          : Theme.of(context).accentColor,
      disabledElevation: 2,
      icon: Icon(
        Icons.cloud_upload,
        color: Colors.white,
      ),
      label: Text(
        'Upload',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  void _onSelectionOfStorageObjectsChanged(
      List<StorageObject> selectedStorageObjects) async {
    // Disable FAB when no StorageObjects selected
    if (selectedStorageObjects.isEmpty) {
      setState(() {
        this._onUploadFabPressed = null;
      });
      return;
    }
    setState(() {
      this._onUploadFabPressed = () async {
        // TODO: adapt and use ProgressService to check whether an upload is already in progress
        if (this._uploadInProgress) return;

        var credentials = await getStorageConnectionCredentials();
        await uploadObjectsToRemoteStorage(
          credentials,
          selectedStorageObjects,
          this._monitoredDirectory,
        );

        final uploadTriggerFile = File(
          path.join(
            this._monitoredDirectory.path,
            AUTO_UPLOAD_TRIGGER_FILE,
          ),
        );
        if (uploadTriggerFile.existsSync()) {
          uploadTriggerFile.deleteSync();
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  bottom: 32,
                  top: 32,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Local Log Files',
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Center(
                child: StorageObjectTableHeader(
                  this._currentDirectory != null
                      ? path.relative(this._currentDirectory.path,
                          from: this._monitoredDirectory.path)
                      : '',
                  '',
                  this._navigateToDirectory,
                  (_) {},
                ),
              ),
              Expanded(
                child: Container(
                  child: StorageObjectTable(
                    this._navigateToDirectory,
                    this._onSelectionOfStorageObjectsChanged,
                    this._storageObjects,
                  ),
                ),
              ),
            ],
          ),
        ),
        FloatingActionButtonPosition(
          floatingActionButton: this._uploadFAB(),
        ),
      ],
    );
  }
}
