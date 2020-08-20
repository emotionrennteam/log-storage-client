import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/utils/minio_manager.dart';
import 'package:emotion/widgets/settings/settings_panel.dart';
import 'package:emotion/widgets/settings/textfield_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StorageConnectionSettings extends StatefulWidget {
  final endpointController = TextEditingController();
  final portController = TextEditingController();
  final accessKeyController = TextEditingController();
  final secretKeyController = TextEditingController();

  final _StorageConnectionSettingsState _state =
      new _StorageConnectionSettingsState();

  @override
  State<StatefulWidget> createState() => this._state;

  bool getTlsEnabled() {
    return this._state.tlsEnabled;
  }
}

class _StorageConnectionSettingsState extends State<StorageConnectionSettings> {
  bool tlsEnabled = false;

  @override
  void initState() {
    super.initState();
    this._readSettings();
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
          this.tlsEnabled = value;
        }
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
        ),
        Divider(color: Colors.transparent),
        // TODO: validate user input and ensure that it's a string
        TextFieldSetting(
          'Port',
          '9000',
          widget.portController,
        ),
        Divider(color: Colors.transparent),
        TextFieldSetting(
          'Access Key',
          'eyW/+8ZtsgT81Cb0e8OVxzJAQP5lY7Dcamnze+JnWEDT ...',
          widget.accessKeyController,
        ),
        Divider(color: Colors.transparent),
        TextFieldSetting(
          'Secret Key',
          '0tZn+7QQCxphpHwTm6/dC3LpP5JGIbYl6PK8Sy79R+P2 ...',
          widget.secretKeyController,
        ),
        Divider(color: Colors.transparent),
        SettingPanel('TLS'),
        SwitchListTile(
          value: this.tlsEnabled,
          title: Text(this.tlsEnabled ? 'TLS Enabled' : 'TLS Disabled'),
          onChanged: (value) async {
            setState(() {
              this.tlsEnabled = value;
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
              final connectionSucceeded = await validateConnection(
                  widget.endpointController.text,
                  port,
                  this.tlsEnabled,
                  widget.accessKeyController.text,
                  widget.secretKeyController.text);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Row(
                  children: <Widget>[
                    Icon(
                      connectionSucceeded ? Icons.check : Icons.close,
                      color: connectionSucceeded
                          ? Theme.of(context).accentColor
                          : Colors.redAccent,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      connectionSucceeded
                          ? 'Successfully connected.'
                          : 'Failed to connect.',
                    ),
                  ],
                ),
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
