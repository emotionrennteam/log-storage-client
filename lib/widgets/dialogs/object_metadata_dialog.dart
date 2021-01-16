import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';

import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/models/storage_object.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:log_storage_client/utils/storage_manager.dart'
    as storageManager;
import 'package:log_storage_client/widgets/emotion_design_button.dart';

class ObjectMetadataDialog extends StatefulWidget {
  final StorageObject storageObject;
  final StorageConnectionCredentials credentials;

  /// An [AlertDialog] that displays the S3 object metadata of the given
  /// [StorageObject] in a scrollable [ListView].
  ObjectMetadataDialog(this.credentials, this.storageObject);

  @override
  State<StatefulWidget> createState() => _ObjectMetadataDialogState();
}

class _ObjectMetadataDialogState extends State<ObjectMetadataDialog> {
  final ScrollController _scrollController = ScrollController();
  List<String> _metadataKeys;
  List<String> _metadataValues;

  @override
  void initState() {
    super.initState();
    storageManager
        .getObjectMetadata(
          this.widget.credentials,
          this.widget.storageObject,
        )
        .then(
          (metadataMap) => setState(() {
            this._metadataKeys = metadataMap.keys.toList()..sort();
            this._metadataValues = this
                ._metadataKeys
                .map(
                  (key) => metadataMap[key],
                )
                .toList();
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 20,
      title: Text('Metadata'),
      content: Container(
        height: 350,
        width: 500,
        child: DraggableScrollbar.rrect(
          controller: _scrollController,
          backgroundColor: constants.DARK_GREY,
          heightScrollThumb: 70,
          padding: EdgeInsets.all(0),
          child: ListView(
            controller: this._scrollController,
            children: [
              DataTable(
                dividerThickness: 0,
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Metadata Key',
                      style: TextStyle(color: constants.TEXT_COLOR),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Metadata Value',
                      style: TextStyle(color: constants.TEXT_COLOR),
                    ),
                  ),
                ],
                rows: this._metadataKeys != null
                    ? this._metadataKeys.asMap().entries.map((entry) {
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Text(
                                entry.value,
                                style: TextStyle(
                                  color: constants.TEXT_COLOR,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                this
                                    ._metadataValues[entry.key]
                                    .split(';')
                                    .join(', '),
                                style: TextStyle(
                                  color: constants.TEXT_COLOR,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList()
                    : [],
              ),
            ],
          ),
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 10),
      buttonPadding: EdgeInsets.only(
        right: 24,
      ),
      actions: <Widget>[
        EmotionDesignButton(
          child: Text(
            'Close',
            style: TextStyle(
              color: constants.LIGHT_RED,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
