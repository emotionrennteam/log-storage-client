import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class StorageObjectTableHeader extends StatefulWidget {
  /// Callback function to be called when the user want to navigate up
  /// in the hierarchy of directories.
  final Function(String path) onNavigateToParentDirectoryCallback;

  /// Callback function to be called when the checkbox for selecting
  /// respectively deselecting all elements of the table was tapped.
  final Function(bool) onSelectDeselectAllCallback;

  /// A string which represents the root, e.g. the storage bucket or the root directory.
  final String rootDirectory;

  /// A string representing the path of the current directory.
  final String currentDirectory;

  StorageObjectTableHeader(
    this.currentDirectory,
    this.rootDirectory,
    this.onNavigateToParentDirectoryCallback,
    this.onSelectDeselectAllCallback,
  );

  @override
  State<StatefulWidget> createState() => _StorageObjectTableHeaderState();
}

class _StorageObjectTableHeaderState extends State<StorageObjectTableHeader> {
  bool _allStorageObjectsSelected = false;
  final TextStyle _textStyle = const TextStyle(color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Row(
              children: [
                Container(
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () {
                        widget.onNavigateToParentDirectoryCallback(null);
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.arrow_back_ios_rounded),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  child: Text(
                    widget.rootDirectory != null ? widget.rootDirectory : '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 500,
                    padding: EdgeInsets.all(10),
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    child: Text(
                      path.separator + widget.currentDirectory,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 40,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Checkbox(
                  value: this._allStorageObjectsSelected,
                  onChanged: (bool newValue) {
                    setState(() {
                      this._allStorageObjectsSelected = newValue;
                    });
                    widget.onSelectDeselectAllCallback(newValue);
                  },
                ),
              ),
              Container(
                width: 100,
                child: Text(
                  'Type',
                  style: this._textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 500,
                child: Text(
                  'Name',
                  style: this._textStyle,
                ),
              ),
              Container(
                width: 120,
                margin: EdgeInsets.only(right: 20),
                child: Text(
                  'Last Modified',
                  style: this._textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 100,
                child: Text(
                  'Size',
                  style: this._textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
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
      padding: EdgeInsets.only(top: 20),
    );
  }
}
