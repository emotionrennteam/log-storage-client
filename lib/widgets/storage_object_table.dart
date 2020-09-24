import 'package:emotion/models/storage_object.dart';
import 'package:emotion/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Builds the widget for displaying the list of [StorageObject]s as a table.
class StorageObjectTable extends StatefulWidget {
  /// A list of [StorageObject]s which are visualized as rows.
  final List<StorageObject> storageObjects;

  /// Callback function to be called when the selection (checkboxes) has changed.
  final Function(List<bool>) onSelectionChangedCallback;

  /// Callback function to be called when the user want to navigate up or down
  /// in the hierarchy of directories.
  final Function(String path) onNavigateToDirectoryCallback;

  final _state = _StorageObjectTableState();

  StorageObjectTable(
    this.onNavigateToDirectoryCallback,
    this.onSelectionChangedCallback,
    this.storageObjects,
  );

  // /// Sets the checkboxes for all [StorageObject]s to the given value
  // /// so that they're all checked respectively unchecked.
  // void setSelectionForAllStorageObjects(bool selected) =>
  //     this._state._setSelectionForAllStorageObjects(selected);

  @override
  State<StatefulWidget> createState() => _state;
}

class _StorageObjectTableState extends State<StorageObjectTable> {
  int _lastCountOfStorageObjects = 0;
  List<bool> _selectedStorageObjects;
  TextStyle _textStyle = const TextStyle(color: Colors.white);

  @override
  void initState() {
    super.initState();
    this._selectedStorageObjects = List<bool>.generate(
      widget.storageObjects.length,
      (index) => false,
    );
  }

  /// Initializes the checkboxes for all [StorageObject]s with [false]
  /// so that they're unchecked.
  ///
  /// The if-statement ensures that the initialization is repeated
  /// when the count of [StorageObject]s has changed, e.g. files have
  /// been loaded lazily or the current directory has changed.
  void _initializeCheckboxes() {
    if (widget.storageObjects.length != this._lastCountOfStorageObjects) {
      this._lastCountOfStorageObjects = widget.storageObjects.length;
      this._selectedStorageObjects = List<bool>.generate(
        widget.storageObjects.length,
        (index) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    this._initializeCheckboxes();

    return ListView.separated(
      itemCount: widget.storageObjects.length,
      padding: EdgeInsets.only(bottom: 100),
      physics: BouncingScrollPhysics(),
      separatorBuilder: (context, index) => Container(
        height: 0,
        color: DARK_GREY,
      ),
      itemBuilder: (context, index) {
        return Container(
          color: this._selectedStorageObjects[index]
              ? DARK_GREY
              : Theme.of(context).primaryColor,
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
                      widget.onSelectionChangedCallback(
                          this._selectedStorageObjects);
                    });
                  },
                ),
              ),
              Expanded(
                child: MouseRegion(
                  cursor: widget.storageObjects[index].isDirectory
                      ? SystemMouseCursors.click
                      : MouseCursor.defer,
                  child: GestureDetector(
                    onTap: widget.storageObjects[index].isDirectory
                        ? () => widget.onNavigateToDirectoryCallback(
                              widget.storageObjects[index].name,
                            )
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          child: Icon(
                            widget.storageObjects[index].isDirectory
                                ? Icons.folder
                                : Icons.insert_drive_file,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.storageObjects[index].getBasename(),
                              style: _textStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Container(
                          width: 110,
                          margin: EdgeInsets.only(right: 20),
                          child: Text(
                            widget.storageObjects[index]
                                .getHumanReadableLastModified(),
                            style: _textStyle,
                          ),
                        ),
                        Container(
                          width: 100,
                          padding: EdgeInsets.only(right: 20),
                          child: Text(
                            widget.storageObjects[index].getHumanReadableSize(),
                            style: _textStyle,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
