import 'dart:io';

import 'package:emotion/models/storage_connection_credentials.dart';
import 'package:emotion/models/storage_object.dart';
import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/utils/constants.dart';
import 'package:emotion/utils/minio_manager.dart';
import 'package:emotion/utils/utils.dart';
import 'package:emotion/widgets/app_layout.dart';
import 'package:emotion/widgets/storage_object_table.dart';
import 'package:emotion/widgets/storage_object_table_header.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RemoteLogFilesPage extends StatefulWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  State<StatefulWidget> createState() => _RemoteLogFilesPageState();
}

class _RemoteLogFilesPageState extends State<RemoteLogFilesPage> {
  List<bool> _selectedStorageObjects = List<bool>.generate(0, (index) => false);
  List<StorageObject> _storageObjects = new List();
  Function _uploadFloatingActionButtonOnPressed;
  StorageConnectionCredentials _credentials;
  String _currentDirectory = '';

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
    listObjectsInRemoteStorage(
      this._credentials,
      path: this._currentDirectory,
    ).then((storageObjects) {
      setState(() {
        this._storageObjects = storageObjects;
        this._selectedStorageObjects =
            List<bool>.generate(storageObjects.length, (index) => false);
      });
    }).catchError((error) {
      widget._scaffoldKey.currentState.hideCurrentSnackBar();
      widget._scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Failed to list objects. Error: $error'),
        ),
      );
    });
  }

  /// Enables or disables the [FloatingActionButton] for downloading objects
  /// when at least one object has been selected.
  void _setFloatingActionButtonState(List<bool> selectedStorageObjects) {
    final selectCount =
        selectedStorageObjects.where((selected) => selected).length;
    // Disable the FAB when no files are selected
    if (selectCount == 0) {
      setState(() {
        this._uploadFloatingActionButtonOnPressed = null;
      });
      return;
    }
    setState(() {
      this._uploadFloatingActionButtonOnPressed = () async {
        String downloadPath = await FilePicker.platform.getDirectoryPath();
        // Path is null when user didn't select a directory but closed the dialog
        if (downloadPath == null) {
          return;
        }

        Directory downloadDirectory = Directory(downloadPath);
        if (!downloadDirectory.existsSync()) {
          // TODO: visualize exception
          throw new Exception('Selected directory doesn\'t exist.');
        }
        List<StorageObject> remoteStorageObjectsToDownload = List();
        this._selectedStorageObjects.asMap().forEach((index, selected) {
          if (selected) {
            remoteStorageObjectsToDownload.add(this._storageObjects[index]);
          }
        });
        await downloadObjectsFromRemoteStorage(this._credentials,
            downloadDirectory, remoteStorageObjectsToDownload);

        widget._scaffoldKey.currentState.hideCurrentSnackBar();
        widget._scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('Download completed.'),
          ),
        );
        // setState(() {
        //   this._selectedStorageObjects =
        //       List<bool>.generate(this._storageObjects.length, (_) => false);
        // });
      };
    });
  }

  void _setAllCheckboxes(bool selected) {
    // TODO: implementation
  }

  void _navigateToDirectory(String absolutePath) {
    // Navigate to parent in the directory tree
    if (absolutePath == null) {
      setState(() {
        this._currentDirectory = getParentForPath(this._currentDirectory);
      });
    } else {
      // Navigate to child in the directory tree
      setState(() {
        this._currentDirectory = absolutePath;
      });
    }
    this._loadStorageObjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldKey,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: this._uploadFloatingActionButtonOnPressed == null
            ? DARK_GREY
            : Theme.of(context).accentColor,
        onPressed: this._uploadFloatingActionButtonOnPressed,
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
      ),
      body: AppLayout(
        appDrawerCurrentIndex: 3,
        view: Column(
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
                this._setAllCheckboxes,
              ),
            ),
            Expanded(
              child: Center(
                child: StorageObjectTable(
                  this._navigateToDirectory,
                  this._setFloatingActionButtonState,
                  this._storageObjects,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
