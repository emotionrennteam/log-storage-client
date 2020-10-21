import 'dart:io';

import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/models/storage_object.dart';
import 'package:log_storage_client/utils/app_settings.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/minio_manager.dart';
import 'package:log_storage_client/utils/utils.dart';
import 'package:log_storage_client/widgets/floating_action_button_position.dart';
import 'package:log_storage_client/widgets/storage_object_table.dart';
import 'package:log_storage_client/widgets/storage_object_table_header.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RemoteLogFilesView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RemoteLogFilesViewState();
}

class _RemoteLogFilesViewState extends State<RemoteLogFilesView> {
  List<StorageObject> _storageObjects = new List();
  Function _onDownloadFabPressed;
  StorageConnectionCredentials _credentials;
  String _currentDirectory = '';
  bool _allStorageObjectsSelected = false;

  @override
  void initState() {
    super.initState();
    getStorageConnectionCredentials().then((cred) {
      this._credentials = cred;
      if (mounted) {
        this._loadStorageObjects();
      }
    });
  }

  void _loadStorageObjects() {
    setState(() {
      this._storageObjects = null;
      this._allStorageObjectsSelected = false;
    });

    listObjectsInRemoteStorage(
      this._credentials,
      path: this._currentDirectory,
    ).then((storageObjects) {
      if (mounted) {
        setState(() {
          this._storageObjects = storageObjects;
        });
      }
    }).catchError((error) {
      if (mounted) {
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
          getSnackBar(
            'Failed to list objects. Error: $error',
            true,
          ),
        );
      }
    });
  }

  /// Enables or disables the [FloatingActionButton] for downloading objects
  /// when at least one object has been selected.
  void _onSelectionOfStorageObjectsChanged(
      List<StorageObject> selectedStorageObjects) {
    // Disable the FAB when no files are selected
    if (selectedStorageObjects.isEmpty) {
      setState(() {
        this._onDownloadFabPressed = null;
      });
      return;
    }

    setState(() {
      this._onDownloadFabPressed = () async {
        String downloadPath = await FilePicker.platform.getDirectoryPath();
        // Path is null or empty when user didn't select a directory but closed the dialog.
        if (downloadPath == null || downloadPath.isEmpty) {
          return;
        }

        Directory downloadDirectory = Directory(downloadPath);
        if (!downloadDirectory.existsSync()) {
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            getSnackBar(
              'The selected download directory "$downloadPath" could not be found.',
              true,
            ),
          );
          return;
        }

        // TODO: doesn't catch exceptions
        downloadObjectsFromRemoteStorage(
          this._credentials,
          downloadDirectory,
          this._currentDirectory,
          selectedStorageObjects,
        ).then((_) {
          // Scaffold.of(context).hideCurrentSnackBar();
          // Scaffold.of(context).showSnackBar(
          //   getSnackBar('Download completed.', false),
          // );
        }).catchError((error) {
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            getSnackBar(error.toString(), true),
          );
          return;
        });

        // TODO: de-select all objects after download
        // setState(() {
        //   this._selectedStorageObjects =
        //       List<bool>.generate(this._storageObjects.length, (_) => false);
        // });
      };
    });
  }

  /// Changes the currently displayed directory to the given parameter [absolutePath].
  ///
  /// If the parameter [absolutePath] is set to [null], then the current directory
  /// will be set to parent directory of the current directory (navigate up in the
  /// hierarchy of directories).
  void _navigateToDirectory(String absolutePath) {
    // Navigate to parent in the directory tree
    if (absolutePath == null) {
      setState(() {
        this._currentDirectory = getParentForPath(this._currentDirectory, '/');
      });
    } else {
      // Navigate to child in the directory tree
      setState(() {
        this._currentDirectory = absolutePath;
      });
    }
    this._loadStorageObjects();
    this._onSelectionOfStorageObjectsChanged(List.empty());
  }

  void _onSelectDeselectAllStorageObjects(bool allSelected) {
    setState(() {
      this._allStorageObjectsSelected = allSelected;
    });
    this._onSelectionOfStorageObjectsChanged(
      allSelected ? this._storageObjects : List.empty(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                    'Remote Log Files',
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Center(
                child: StorageObjectTableHeader(
                  this._currentDirectory,
                  this._credentials?.bucket,
                  this._navigateToDirectory,
                  this._onSelectDeselectAllStorageObjects,
                  this._allStorageObjectsSelected,
                  optionsColumnEnabled: true,
                  rootDirectorySeparator: '/',
                ),
              ),
              Expanded(
                child: Center(
                  child: StorageObjectTable(
                    this._navigateToDirectory,
                    this._onSelectionOfStorageObjectsChanged,
                    this._storageObjects,
                    this._allStorageObjectsSelected,
                    optionsColumnEnabled: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        FloatingActionButtonPosition(
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: this._onDownloadFabPressed == null
                ? DARK_GREY
                : Theme.of(context).accentColor,
            icon: Icon(
              Icons.cloud_download,
              color: Colors.white,
            ),
            label: Text(
              'Download',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            onPressed: this._onDownloadFabPressed,
          ),
        ),
      ],
    );
  }
}
