import 'dart:io';

import 'package:emotion/models/storage_connection_credentials.dart';
import 'package:emotion/models/storage_object.dart';
import 'package:emotion/utils/app_settings.dart';
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

  /// Builds the widget for displaying the list of remote [StorageObject]s using
  /// a [DataTable] widget.
  Widget _buildDataTable() {
    return DataTable(
      columns: <DataColumn>[
        DataColumn(
          label: Text(
            'Type',
            style: Theme.of(context).textTheme.headline6,
          ),
          numeric: false,
        ),
        DataColumn(
          label: Text(
            'Name',
            style: Theme.of(context).textTheme.headline6,
          ),
          numeric: false,
        ),
        DataColumn(
          label: Text(
            'Last Modified',
            style: Theme.of(context).textTheme.headline6,
          ),
          numeric: false,
        ),
        DataColumn(
          label: Text(
            'Size',
            style: Theme.of(context).textTheme.headline6,
          ),
          numeric: true,
        ),
      ],
      rows: List<DataRow>.generate(
        this._storageObjects.length,
        (index) => DataRow(
          color: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            // All rows will have the same selected color.
            if (states.contains(MaterialState.selected))
              return Theme.of(context).colorScheme.primary.withOpacity(0.08);
            // Even rows will have a grey color.
            if (index % 2 == 0) return Color.fromRGBO(40, 40, 40, 1);
            return Color.fromRGBO(50, 50, 50, 1);
          }),
          cells: [
            DataCell(Icon(
              this._storageObjects[index].isDirectory
                  ? Icons.folder
                  : Icons.insert_drive_file,
              color: Theme.of(context).iconTheme.color,
            )),
            DataCell(Text(
              this._storageObjects[index].name,
              style: _textStyle,
            )),
            DataCell(Text(
              this._storageObjects[index].getHumanReadableLastModified(),
              style: _textStyle,
            )),
            DataCell(Text(
              this._storageObjects[index].getHumanReadableSize(),
              style: _textStyle,
            )),
          ],
          selected: this._selectedStorageObjects[index],
          onSelectChanged: (bool value) {
            setState(() {
              this._selectedStorageObjects[index] = value;
              _setFloatingActionButtonState();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._scaffoldKey,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: this._uploadFloatingActionButtonOnPressed == null
            ? Theme.of(context).primaryColor
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
        view: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 100),
          physics: BouncingScrollPhysics(),
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
                child: this._buildDataTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
