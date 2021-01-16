import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:log_storage_client/models/storage_object.dart';
import 'package:log_storage_client/models/upload_profile.dart';
import 'package:log_storage_client/utils/app_settings.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/utils/storage_manager.dart'
    as StorageManager;
import 'package:log_storage_client/services/progress_service.dart';
import 'package:log_storage_client/utils/utils.dart';
import 'package:log_storage_client/utils/storage_object_sorting.dart' as StorageObjectSorting;
import 'package:log_storage_client/widgets/dialogs/select_upload_profile_dialog.dart';
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
  List<StorageObject> _storageObjects = [];
  List<StorageObject> _selectedStorageObjects;
  Function _onUploadFabPressed;
  bool _allStorageObjectsSelected = false;
  bool _fileTransferIsInProgress = false;
  bool _failedToListStorageObjects = false;

  Directory _currentDirectory;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    getLogFileDirectoryPath().then((logFileDirectory) {
      if (logFileDirectory != null && logFileDirectory.isNotEmpty) {
        this._monitoredDirectory = new Directory(logFileDirectory);
        this._currentDirectory = this._monitoredDirectory;
        _loadStorageObjects();
      } else {
        if (mounted) {
          setState(() {
            this._failedToListStorageObjects = true;
          });
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          getSnackBar(
            'Failed to list files. Error: path to local log file directory must not be null or empty.',
            true,
          ),
        );
      }
    });

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

  /// Changes the current directory to the given [absolutePath].
  ///
  /// If [absolutePath] is null, the current directory will be set
  /// to the parent directory of the current directory.
  void _navigateToDirectory(String absolutePath) {
    // Navigate to parent in the directory tree
    if (absolutePath == null) {
      setState(() {
        this._currentDirectory = Directory(
          getParentPath(
            this._currentDirectory.path,
            path.separator,
            artificialRootDirectory: this._monitoredDirectory.path,
          ),
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

  void _loadStorageObjects() {
    if (mounted) {
      setState(() {
        this._storageObjects = null;
        this._allStorageObjectsSelected = false;
        this._failedToListStorageObjects = false;
      });
    }
    StorageManager.listObjectsOnLocalFileSystem(
      this._currentDirectory,
      StorageObjectSorting.sortByDirectoriesFirstThenFiles,
    ).then((storageObjects) {
      if (mounted) {
        setState(() {
          this._storageObjects = storageObjects;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          this._failedToListStorageObjects = true;
        });
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        getSnackBar('Failed to list files. Error: $error', true),
      );
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
        final selectedUploadProfile = await showCupertinoModalPopup(
          context: context,
          filter: ImageFilter.blur(
            sigmaX: 2,
            sigmaY: 2,
          ),
          builder: (context) => SelectUploadProfileDialog(),
        ) as UploadProfile;

        if (selectedUploadProfile == null) {
          return;
        }

        final credentials = await getStorageConnectionCredentials();
        await StorageManager.uploadObjectsToRemoteStorage(
          credentials,
          this._selectedStorageObjects,
          this._currentDirectory,
          selectedUploadProfile,
          DateTime.now().toLocal(),
        );

        // TODO: is this still used?
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
          padding: EdgeInsets.fromLTRB(64, 0, 64, 100),
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
                      ? path.relative(
                          this._currentDirectory.path,
                          from: this._monitoredDirectory.path,
                        )
                      : '',
                  this._monitoredDirectory == null
                      ? ''
                      : path.basename(this._monitoredDirectory.path),
                  this._navigateToDirectory,
                  this._onSelectDeselectAllStorageObjects,
                  this._allStorageObjectsSelected,
                ),
              ),
              Expanded(
                child: Center(
                  child: this._failedToListStorageObjects
                      ? Icon(
                          Icons.warning_amber_rounded,
                          size: 50,
                          color: Theme.of(context).accentColor,
                        )
                      : this._storageObjects == null
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
