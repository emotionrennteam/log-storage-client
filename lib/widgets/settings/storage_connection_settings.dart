import 'package:emotion/models/storage_connection_credentials.dart';
import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/utils/constants.dart';
import 'package:emotion/utils/minio_manager.dart';
import 'package:emotion/utils/utils.dart';
import 'package:emotion/widgets/settings/settings_panel.dart';
import 'package:emotion/widgets/settings/textfield_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StorageConnectionSettings extends StatefulWidget {
  final endpointController = TextEditingController();
  final portController = TextEditingController();
  final accessKeyController = TextEditingController();
  final secretKeyController = TextEditingController();
  final bucketController = TextEditingController();

  final _StorageConnectionSettingsState _state =
      new _StorageConnectionSettingsState();

  @override
  State<StatefulWidget> createState() => this._state;

  bool getTlsEnabled() {
    return this._state._tlsEnabled;
  }
}

class _StorageConnectionSettingsState extends State<StorageConnectionSettings> {
  final _portFocusNode = FocusNode();
  final _accessKeyFocusNode = FocusNode();
  final _secretKeyFocusNode = FocusNode();
  final _bucketFocusNode = FocusNode();
  bool _tlsEnabled = false;

  @override
  void initState() {
    super.initState();
    this._readSettings();
  }

  @override
  void dispose() {
    this._portFocusNode.dispose();
    this._accessKeyFocusNode.dispose();
    this._secretKeyFocusNode.dispose();
    this._bucketFocusNode.dispose();
    super.dispose();
  }

  void _readSettings() async {
    getMinioEndpoint().then(
      (value) => setState(() {
        widget.endpointController.text = value;
      }),
    );
    getMinioPort().then(
      (value) => setState(() {
        if (value != null) widget.portController.text = value.toString();
      }),
    );
    getMinioAccessKey().then(
      (value) => setState(() {
        widget.accessKeyController.text = value;
      }),
    );
    getMinioSecretKey().then(
      (value) => setState(() {
        widget.secretKeyController.text = value;
      }),
    );
    getMinioTlsEnabled().then(
      (value) => setState(() {
        if (value != null) {
          this._tlsEnabled = value;
        }
      }),
    );
    getMinioBucket().then(
      (value) => setState(() {
        widget.bucketController.text = value;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: 16,
              top: 32,
            ),
            child: Text(
              'Storage Connection',
              style: TextStyle(
                color: Colors.grey.shade300,
                fontWeight: FontWeight.w600,
                fontSize: 23,
              ),
            ),
          ),
        ),
        TextFieldSetting(
          'Endpoint',
          '10.11.0.18',
          widget.endpointController,
          this._portFocusNode,
        ),
        Divider(color: Colors.transparent),
        // TODO: validate user input and ensure that it's a string
        TextFieldSetting(
          'Port',
          '9000',
          widget.portController,
          this._accessKeyFocusNode,
        ),
        Divider(color: Colors.transparent),
        TextFieldSetting(
          'Access Key',
          'eyW/+8ZtsgT81Cb0e8OVxzJAQP5lY7Dcamnze+JnWEDT ...',
          widget.accessKeyController,
          this._secretKeyFocusNode,
        ),
        Divider(color: Colors.transparent),
        TextFieldSetting(
          'Secret Key',
          '0tZn+7QQCxphpHwTm6/dC3LpP5JGIbYl6PK8Sy79R+P2 ...',
          widget.secretKeyController,
          this._bucketFocusNode,
        ),
        Divider(color: Colors.transparent),
        TextFieldSetting(
          'Bucket',
          'logs',
          widget.bucketController,
          null,
        ),
        Divider(color: Colors.transparent),
        SettingPanel('TLS'),
        // TODO: add a FocusNode to the switch
        SwitchListTile(
          autofocus: false,
          value: this._tlsEnabled,
          title: Text(this._tlsEnabled ? 'TLS Enabled' : 'TLS Disabled'),
          onChanged: (value) async {
            setState(() {
              this._tlsEnabled = value;
            });
          },
          contentPadding: EdgeInsets.only(
            left: 20,
            right: 0,
          ),
        ),
        Divider(color: Colors.transparent),
        Align(
          alignment: Alignment.centerLeft,
          child: FlatButton(
            child: Text(
              'Test Connection',
              style: Theme.of(context).textTheme.button,
            ),
            // TODO: show progress spinner
            onPressed: () async {
              int port = 0;
              try {
                port = int.parse(widget.portController.text);
              } on FormatException catch (_) {
                // TODO: validate input
                return;
              }
              var credentials = new StorageConnectionCredentials(
                widget.endpointController.text,
                port,
                widget.accessKeyController.text,
                widget.secretKeyController.text,
                widget.bucketController.text,
                this._tlsEnabled,
              );
              final connectionSucceeded = await validateConnection(credentials);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(getSnackBar(
                connectionSucceeded.item1
                    ? 'Successfully connected.'
                    : connectionSucceeded.item2,
                !connectionSucceeded.item1,
              ));
            },
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.0),
              side: BorderSide(
                color: Color.fromRGBO(40, 40, 40, 1),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
