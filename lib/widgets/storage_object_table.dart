import 'dart:ui';

import 'package:log_storage_client/models/storage_object.dart';
import 'package:log_storage_client/utils/app_settings.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/minio_manager.dart';
import 'package:log_storage_client/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:log_storage_client/widgets/emotion_design_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds the widget for displaying the list of [StorageObject]s as a table.
class StorageObjectTable extends StatefulWidget {
  /// Whether to display the last column with options to delete or share files.
  final bool optionsColumnEnabled;

  /// A list of [StorageObject]s which are visualized as rows.
  final List<StorageObject> storageObjects;

  /// Callback function to be called when the selection (checkboxes) has changed.
  /// The given list contains all [StorageObject]s which the user selected.
  final Function(List<StorageObject>) onSelectionChangedCallback;

  /// Callback function to be called when the user want to navigate up or down
  /// in the hierarchy of directories.
  final Function(String path) onNavigateToDirectoryCallback;

  /// Determines whether the checkbox for all [StorageObject]s is checked / unchecked.
  final bool allStorageObjectsSelected;

  final _state = _StorageObjectTableState();

  StorageObjectTable(
      this.onNavigateToDirectoryCallback,
      this.onSelectionChangedCallback,
      this.storageObjects,
      this.allStorageObjectsSelected,
      {this.optionsColumnEnabled = false});

  // /// Sets the checkboxes for all [StorageObject]s to the given value
  // /// so that they're all checked respectively unchecked.
  // void setSelectionForAllStorageObjects(bool selected) =>
  //     this._state._setSelectionForAllStorageObjects(selected);

  @override
  State<StatefulWidget> createState() => _state;
}

class _StorageObjectTableState extends State<StorageObjectTable> {
  List<bool> _selectedStorageObjects;
  List<String> _storageObjectOptions = ['Delete', 'Share'];
  TextStyle _textStyle = const TextStyle(color: Colors.white);

  @override
  void initState() {
    super.initState();
    this._initializeCheckboxes(widget.allStorageObjectsSelected);
  }

  @override
  void didUpdateWidget(covariant StorageObjectTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    /// Update checkboxes for selecting / deselecting storage objects
    /// whenever the parent widget has been updated (from externally).
    if (oldWidget.allStorageObjectsSelected !=
            widget.allStorageObjectsSelected ||
        oldWidget.storageObjects?.length != widget.storageObjects?.length) {
      this._initializeCheckboxes(widget.allStorageObjectsSelected);
    }
  }

  /// Initializes the checkboxes for all [StorageObject]s with [allSelected]
  /// so that they're unchecked respectively checked.
  void _initializeCheckboxes(bool allSelected) {
    this._selectedStorageObjects = List<bool>.generate(
      widget.storageObjects.length,
      (index) => allSelected,
    );
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
                    'Do you really want to delete ${storageObject.path}?\nThis action can\'t be undone.',
                  ),
                  contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 10),
                  buttonPadding: EdgeInsets.only(
                    right: 24,
                  ),
                  actions: <Widget>[
                    EmotionDesignButton(
                      child: Text(
                        'No',
                        style: Theme.of(context).textTheme.button,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    EmotionDesignButton(
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
                            'Successfully deleted ${storageObject.path}.',
                            false,
                          ));
                        });
                        Navigator.of(context).pop();
                      },
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
                      final selectedStorageObjects = List<StorageObject>();
                      for (var i = 0; i < widget.storageObjects.length; i++) {
                        if (this._selectedStorageObjects[i]) {
                          selectedStorageObjects.add(widget.storageObjects[i]);
                        }
                      }
                      widget.onSelectionChangedCallback(selectedStorageObjects);
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
                              widget.storageObjects[index].path,
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
