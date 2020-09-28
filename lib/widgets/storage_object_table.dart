import 'dart:ui';

import 'package:emotion/models/storage_object.dart';
import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/utils/constants.dart';
import 'package:emotion/utils/minio_manager.dart';
import 'package:emotion/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds the widget for displaying the list of [StorageObject]s as a table.
class StorageObjectTable extends StatefulWidget {
  /// Whether to display the last column with options to delete or share files.
  final bool optionsColumnEnabled;

  /// A list of [StorageObject]s which are visualized as rows.
  final List<StorageObject> storageObjects;

  /// Callback function to be called when the selection (checkboxes) has changed.
  final Function(List<bool>) onSelectionChangedCallback;

  /// Callback function to be called when the user want to navigate up or down
  /// in the hierarchy of directories.
  final Function(String path) onNavigateToDirectoryCallback;

  final _state = _StorageObjectTableState();

  StorageObjectTable(this.onNavigateToDirectoryCallback,
      this.onSelectionChangedCallback, this.storageObjects,
      {this.optionsColumnEnabled = false});

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
  List<String> _storageObjectOptions = ['Delete', 'Share'];
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

  /// Builds a [PopupMenuButton] with the options to delete or share the
  /// associated [StorageObject].
  ///
  /// The request to delete a [StorageObject] will open an [AlertDialog]
  /// which asks for confirmation. Shareable links are valid for 7 days
  /// and give download access to the specified file without having to
  /// authenticate (no credentials required).
  PopupMenuButton _popupMenuButtonForOptions(StorageObject storageObject) {
    return PopupMenuButton<String>(
      onSelected: (option) {
        getStorageConnectionCredentials().then((credentials) {
          if (option == 'Share') {
            shareObjectFromRemoteStorage(
              storageObject,
              credentials,
            ).then((String shareableLink) {
              Clipboard.setData(
                ClipboardData(
                  text: shareableLink,
                ),
              ).then((_) {
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(getSnackBar(
                  'Successfully copied shareable link to your clipboard (valid for 7 days).',
                  false,
                  snackBarAction: SnackBarAction(
                      label: 'OPEN IN BROWSER',
                      onPressed: () async {
                        if (await canLaunch(shareableLink)) {
                          launch(shareableLink);
                        }
                      }),
                ));
              });
            });
          } else if (option == 'Delete') {
            showCupertinoModalPopup(
              context: context,
              filter: ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ),
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 20,
                  title: Text('Delete File'),
                  content: Text(
                    'Do you really want to delete ${storageObject.name}?\nThis action can\'t be undone.',
                  ),
                  contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 10),
                  buttonPadding: EdgeInsets.only(
                    right: 24,
                  ),
                  actions: <Widget>[
                    FlatButton(
                      color: Theme.of(context).canvasColor,
                      child: Text(
                        'No',
                        style: Theme.of(context).textTheme.button,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                        side: BorderSide(
                          color: Color.fromRGBO(40, 40, 40, 1),
                          width: 2,
                        ),
                      ),
                    ),
                    FlatButton(
                      color: Theme.of(context).canvasColor,
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: LIGHT_RED,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        deleteObjectFromRemoteStorage(
                          storageObject,
                          credentials,
                        ).then((_) {
                          Scaffold.of(this.context).hideCurrentSnackBar();
                          Scaffold.of(this.context).showSnackBar(getSnackBar(
                            'Successfully deleted ${storageObject.name}.',
                            false,
                          ));
                        });
                        Navigator.of(context).pop();
                      },
                      padding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.0),
                        side: BorderSide(
                          color: Color.fromRGBO(40, 40, 40, 1),
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        });
      },
      color: DARK_GREY,
      elevation: 20,
      itemBuilder: (BuildContext context) {
        return _storageObjectOptions.map((String option) {
          return PopupMenuItem(
            value: option,
            enabled: !storageObject.isDirectory,
            child: Text(
              option,
              style: TextStyle(
                color: !storageObject.isDirectory ? TEXT_COLOR : LIGHT_GREY,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList();
      },
    );
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
                        widget.optionsColumnEnabled
                            ? Container(
                                width: 40,
                                margin: EdgeInsets.only(
                                  left: 10,
                                  right: 20,
                                ),
                                child: this._popupMenuButtonForOptions(
                                  widget.storageObjects[index],
                                ),
                              )
                            : SizedBox(),
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
