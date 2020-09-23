import 'dart:io';

import 'package:emotion/models/storage_connection_credentials.dart';
import 'package:emotion/models/storage_object.dart';
import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/utils/constants.dart';
import 'package:emotion/utils/minio_manager.dart';
import 'package:emotion/widgets/app_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class RemoteLogFilesPage extends StatefulWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  State<StatefulWidget> createState() => _RemoteLogFilesPageState();
}

class _RemoteLogFilesPageState extends State<RemoteLogFilesPage> {
  List<bool> _selectedStorageObjects = List<bool>.generate(0, (index) => false);
  List<StorageObject> _storageObjects = new List();
  bool _allStorageObjectsSelected = false;
  TextStyle _textStyle = const TextStyle(color: Colors.white);
  Function _uploadFloatingActionButtonOnPressed;
  StorageConnectionCredentials _credentials;

  @override
  void initState() {
    super.initState();
    getStorageConnectionCredentials().then((cred) {
      this._credentials = cred;
      if (mounted) {
        listObjectsInRemoteStorage(cred).then((storageObjects) {
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
    });
  }

  /// Enables or disables the FloatingActionButton for downloading objects
  /// when at least one object has been selected.
  void _setFloatingActionButtonState() {
    final selectCount =
        this._selectedStorageObjects.where((selected) => selected).length;
    // Disable the FAB when no files are selected
    if (selectCount == 0) {
      this._uploadFloatingActionButtonOnPressed = null;
      return;
    }

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
      await downloadObjectsFromRemoteStorage(
          this._credentials, downloadDirectory, remoteStorageObjectsToDownload);

      widget._scaffoldKey.currentState.hideCurrentSnackBar();
      widget._scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Download completed.'),
        ),
      );
      setState(() {
        this._selectedStorageObjects =
            List<bool>.generate(this._storageObjects.length, (_) => false);
      });
    };
  }

  Widget _buildHeader() {
    return Container(
      child: Row(
        children: [
          Container(
            width: 40,
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Checkbox(
              value: this._allStorageObjectsSelected,
              onChanged: (bool newValue) {
                setState(() {
                  this._allStorageObjectsSelected = newValue;
                  this._selectedStorageObjects = this._selectedStorageObjects.map((e) => newValue).toList();
                  _setFloatingActionButtonState();
                });
              },
            ),
          ),
          Container(
            width: 100,
            child: Text(
              'Type',
              style: _textStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 500,
            child: Text(
              'Name',
              style: _textStyle,
            ),
          ),
          Container(
            width: 120,
            margin: EdgeInsets.only(right: 20),
            child: Text(
              'Last Modified',
              style: _textStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 100,
            child: Text(
              'Size',
              style: _textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        color: Theme.of(context).accentColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).accentColor.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, -3),
          ),
        ],
      ),
    );
  }

  /// Builds the widget for displaying the list of remote [StorageObject]s using
  /// a [DataTable] widget.
  Widget _buildDataTable() {
    return ListView.separated(
      itemBuilder: (context, index) {
        return Container(
          color: this._selectedStorageObjects[index] ? DARK_GREY : Theme.of(context).primaryColor,
          height: 50,
          child: Row(
            children: [
              Container(
                width: 40,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Checkbox(
                  activeColor: DARK_GREY,
                  value: this._selectedStorageObjects[index],
                  onChanged: (bool newValue) {
                    setState(() {
                      this._selectedStorageObjects[index] = newValue;
                      _setFloatingActionButtonState();
                    });
                  },
                ),
              ),
              Container(
                width: 100,
                child: Icon(
                  this._storageObjects[index].isDirectory
                      ? Icons.folder
                      : Icons.insert_drive_file,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              Container(
                width: 500,
                child: Text(
                  this._storageObjects[index].name,
                  style: _textStyle,
                ),
              ),
              Container(
                width: 120,
                margin: EdgeInsets.only(right: 20),
                child: Text(
                  this._storageObjects[index].getHumanReadableLastModified(),
                  style: _textStyle,
                ),
              ),
              Container(
                width: 100,
                child: Text(
                  this._storageObjects[index].getHumanReadableSize(),
                  style: _textStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
      itemCount: this._storageObjects.length,
      padding: EdgeInsets.only(bottom: 100),
      physics: BouncingScrollPhysics(),
      separatorBuilder: (context, index) =>
          Container(height: 0, color: DARK_GREY),
    );
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
              child: this._buildHeader(),
            ),
            Expanded(
              child: Center(
                child: this._buildDataTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
