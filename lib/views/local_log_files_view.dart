import 'dart:io';

import 'package:log_storage_client/models/storage_object.dart';
import 'package:log_storage_client/utils/app_settings.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/utils/storage_manager.dart'
    as StorageManager;
import 'package:log_storage_client/utils/progress_service.dart';
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
  Directory _monitoredDirectory;
  List<StorageObject> _storageObjects = List();
  List<StorageObject> _selectedStorageObjects;
  Function _onUploadFabPressed;
  bool _allStorageObjectsSelected = false;
  bool _fileTransferIsInProgress = false;

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
    this._loadStorageObjects();
  }

  void _init() async {
    var logFileDirectory = await getLogFileDirectoryPath();
    this._monitoredDirectory = new Directory(logFileDirectory);
    this._currentDirectory = this._monitoredDirectory;
    _loadStorageObjects();

    ProgressService progressService = locator<ProgressService>();
    setState(() {
      this._fileTransferIsInProgress = progressService.isInProgress();
    });
    progressService.getIsInProgressStream().listen((isInProgress) {
      if (mounted && isInProgress != this._fileTransferIsInProgress) {
        setState(() {
          this._fileTransferIsInProgress = isInProgress;
        });
      }
    });
  }

  void _loadStorageObjects() {
    setState(() {
      this._storageObjects = null;
      this._allStorageObjectsSelected = false;
    });
    
    StorageManager.listObjectsOnLocalFileSystem(
      this._currentDirectory,
      StorageManager.sortByDirectoriesFirstThenFiles,
    ).then((storageObjects) {
      if (mounted) {
        setState(() {
          this._storageObjects = storageObjects;
        });
      }
    });
  }

  /// A [FloatingActionButton] for triggering the upload of log files.
  /// This button is automatically disabled when an upload is in progress or no
  /// files for upload have been selected.
  FloatingActionButton _uploadFAB() {
    _enableDisableFloatingActionButton();

    return FloatingActionButton.extended(
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
      mouseCursor: this._onUploadFabPressed == null
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onPressed: this._onUploadFabPressed,
    );
  }

  /// Enables or disables the [FloatingActionButton] depending on
  /// the count of currently selected [StorageObject]s and whether
  /// another file transfer is already in progress.
  void _enableDisableFloatingActionButton() {
    if (this._fileTransferIsInProgress ||
        this._selectedStorageObjects == null ||
        this._selectedStorageObjects.isEmpty) {
      setState(() {
        this._onUploadFabPressed = null;
      });
      return;
    }

    setState(() {
      this._onUploadFabPressed = () async {
        final credentials = await getStorageConnectionCredentials();
        await StorageManager.uploadObjectsToRemoteStorage(
          credentials,
          this._selectedStorageObjects,
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

  void _onSelectionOfStorageObjectsChanged(
      List<StorageObject> selectedStorageObjects) {
    setState(() {
      this._selectedStorageObjects = selectedStorageObjects;
    });
  }

  void _onSelectDeselectAllStorageObjects(bool allSelected) {
    setState(() {
      this._allStorageObjectsSelected = allSelected;
      this._selectedStorageObjects =
          allSelected ? this._storageObjects : List.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(32, 0, 32, 100),
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
                  this._onSelectDeselectAllStorageObjects,
                  this._allStorageObjectsSelected,
                ),
              ),
              Expanded(
                child: Center(
                  child: this._storageObjects == null
                      ? Container(
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                          ),
                          width: 200,
                        )
                      : StorageObjectTable(
                          this._navigateToDirectory,
                          this._onSelectionOfStorageObjectsChanged,
                          this._storageObjects,
                          this._allStorageObjectsSelected,
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
