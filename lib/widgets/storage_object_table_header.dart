import 'package:flutter/material.dart';

class StorageObjectTableHeader extends StatefulWidget {
  /// Callback function to be called when the user want to navigate up
  /// in the hierarchy of directories.
  final Function(String path) onNavigateToParentDirectoryCallback;

  /// Callback function to be called when the checkbox for selecting
  /// respectively deselecting all elements of the table was tapped.
  final Function(bool) onSelectDeselectAllCallback;

  /// Whether to display the last column with options to delete or share files.
  final bool optionsColumnEnabled;

  /// A string representing the path of the current directory.
  final String currentDirectory;

  /// A string which represents the root, e.g. the storage bucket or the root directory.
  final String rootDirectory;

  /// An optional character used to denote the root directory from child directories,
  /// e.g. foward or backslash.
  final String rootDirectorySeparator;

  /// Determines whether the checkbox for selecting / deselecting all [StorageObject]s
  /// is checked.
  final bool allStorageObjectsSelected;

  StorageObjectTableHeader(
      this.currentDirectory,
      this.rootDirectory,
      this.onNavigateToParentDirectoryCallback,
      this.onSelectDeselectAllCallback,
      this.allStorageObjectsSelected,
      {this.optionsColumnEnabled = false,
      this.rootDirectorySeparator});

  @override
  State<StatefulWidget> createState() => _StorageObjectTableHeaderState();
}

class _StorageObjectTableHeaderState extends State<StorageObjectTableHeader> {
  bool _allStorageObjectsSelected = false;
  final TextStyle _textStyle = const TextStyle(color: Colors.white);

  @override
  void didUpdateWidget(covariant StorageObjectTableHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    /// Update checkbox for selecting / deselecting all storage objects
    /// whenever the parent widget has been updated (from externally).
    this._allStorageObjectsSelected = widget.allStorageObjectsSelected;
  }

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
                  height: 40,
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
                  height: 40,
                  padding: EdgeInsets.all(widget.rootDirectory == '' ? 0 : 10),
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.rootDirectory != null ? widget.rootDirectory : '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 500,
                    height: 40,
                    padding: EdgeInsets.all(10),
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${widget.rootDirectorySeparator != null ? widget.rootDirectorySeparator : ""}${widget.currentDirectory}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
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
              Expanded(
                child: Container(
                  child: Text(
                    'Name',
                    style: this._textStyle,
                  ),
                ),
              ),
              Container(
                width: 120,
                child: Text(
                  'Last Modified',
                  style: this._textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                width: 100,
                padding: EdgeInsets.only(
                  right: widget.optionsColumnEnabled ? 10 : 20,
                ),
                child: Text(
                  'Size',
                  style: this._textStyle,
                  textAlign: TextAlign.right,
                ),
              ),
              widget.optionsColumnEnabled
                  ? Container(
                      width: 80,
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        'Options',
                        style: this._textStyle,
                        textAlign: TextAlign.right,
                      ),
                    )
                  : SizedBox(),
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
