import 'package:log_storage_client/models/storage_connection_credentials.dart';
import 'package:log_storage_client/utils/app_settings.dart';
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/minio_manager.dart';
import 'package:log_storage_client/utils/utils.dart';
import 'package:log_storage_client/widgets/emotion_design_button.dart';
import 'package:log_storage_client/widgets/settings/setting_panel.dart';
import 'package:log_storage_client/widgets/settings/textfield_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StorageConnectionSettings extends StatefulWidget {
  final accessKeyController = TextEditingController();
  final bucketController = TextEditingController();
  final endpointController = TextEditingController();
  final portController = TextEditingController();
  final regionController = TextEditingController();
  final secretKeyController = TextEditingController();

  final _StorageConnectionSettingsState _state =
      new _StorageConnectionSettingsState();

  @override
  State<StatefulWidget> createState() => this._state;

  bool getTlsEnabled() {
    return this._state._tlsEnabled;
  }
}

class _StorageConnectionSettingsState extends State<StorageConnectionSettings> {
  final _accessKeyFocusNode = FocusNode();
  final _bucketFocusNode = FocusNode();
  final _portFocusNode = FocusNode();
  final _regionFocusNode = FocusNode();
  final _secretKeyFocusNode = FocusNode();
  bool _tlsEnabled = false;
  bool _isTlsTooltipVisible = false;
  bool _connectionTestInProgress = false;

  @override
  void initState() {
    super.initState();
    this._readSettings();
  }

  @override
  void dispose() {
    this._accessKeyFocusNode.dispose();
    this._bucketFocusNode.dispose();
    this._portFocusNode.dispose();
    this._regionFocusNode.dispose();
    this._secretKeyFocusNode.dispose();
    super.dispose();
  }

  void _readSettings() async {
    getMinioAccessKey().then(
      (value) => setState(() {
        widget.accessKeyController.text = value;
      }),
    );
    getMinioBucket().then(
      (value) => setState(() {
        widget.bucketController.text = value;
      }),
    );
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
    getMinioRegion().then(
      (value) => setState(() {
        widget.regionController.text = value;
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
          'The hostname or IP address of the MinIO\nserver (without port and scheme). For\nconnecting to S3 from Amazon Web\nServices please use "s3.amazonaws.com".',
        ),
        Divider(color: Colors.transparent),
        // TODO: validate user input and ensure that it's a string
        TextFieldSetting(
          'Port',
          '9000',
          widget.portController,
          this._accessKeyFocusNode,
          'The TCP/IP port number for the MinIO server.\nTypically port 80 for HTTP and 443 for HTTPS.',
          isValueNumerical: true,
        ),
        Divider(color: Colors.transparent),
        TextFieldSetting(
          'Region',
          'eu-central-1',
          widget.regionController,
          this._regionFocusNode,
          'The name of the location of the MinIO server\ne.g. "us-east-1".',
        ),
        Divider(color: Colors.transparent),
                TextFieldSetting(
          'Bucket',
          'logs',
          widget.bucketController,
          null,
          'The name of the bucket in MinIO. A bucket is\nthe uppermost storage unit in MinIO (root).\nBuckets can store files and directories.',
        ),
        Divider(color: Colors.transparent),
        TextFieldSetting(
          'Access Key',
          'eyW/+8ZtsgT81Cb0e8OVxzJAQP5lY7Dcamnze+JnWEDT ...',
          widget.accessKeyController,
          this._secretKeyFocusNode,
          'The access key is like  a user-id that\nuniquely identifies your account.',
        ),
        Divider(color: Colors.transparent),
        TextFieldSetting(
            'Secret Key',
            '0tZn+7QQCxphpHwTm6/dC3LpP5JGIbYl6PK8Sy79R+P2 ...',
            widget.secretKeyController,
            this._bucketFocusNode,
            'The secret key is the password to your\naccount.'),
        Divider(color: Colors.transparent),
        MouseRegion(
          onEnter: (_) => setState(() {
            this._isTlsTooltipVisible = true;
          }),
          onExit: (_) => setState(() {
            this._isTlsTooltipVisible = false;
          }),
          child: Column(
            children: [
              SettingPanel(
                'TLS',
                'If set to true, a TLS secured connection (HTTPS)\nis used instead of a plain-text connection (HTTP).',
                this._isTlsTooltipVisible,
              ),
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
            ],
          ),
        ),
        Divider(color: Colors.transparent),
        Align(
          alignment: Alignment.centerLeft,
          child: EmotionDesignButton(
            verticalPadding: 17,
            child: Wrap(
              spacing: 10,
              verticalDirection: VerticalDirection.down,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  height: 24,
                  width: this._connectionTestInProgress ? 24 : 0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(DARK_GREY),
                    value: this._connectionTestInProgress ? null : 0,
                  ),
                ),
                Text(
                  'Test Connection',
                  style: Theme.of(context).textTheme.button,
                ),
              ],
            ),
            onPressed: () async {
              setState(() {
                this._connectionTestInProgress = true;
              });

              // Delay connection test by 0.5s so that the animated progress indicator can pop-up in the meantime
              await Future.delayed(Duration(milliseconds: 500));

              int port = 0;
              try {
                port = int.parse(widget.portController.text);
              } on FormatException catch (_) {
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(getSnackBar(
                  'The specified port must be a numerical value, e.g. 80 or 443.',
                  true,
                ));
                setState(() {
                  this._connectionTestInProgress = false;
                });
                return;
              }
              var credentials = new StorageConnectionCredentials(
                widget.endpointController.text,
                port,
                widget.regionController.text,
                widget.bucketController.text,
                widget.accessKeyController.text,
                widget.secretKeyController.text,
                this._tlsEnabled,
              );
              final connectionSucceeded = await validateConnection(credentials);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(getSnackBar(
                connectionSucceeded.item1
                    ? 'Successfully connected.'
                    : 'Connection error: ${connectionSucceeded.item2}',
                !connectionSucceeded.item1,
              ));
              setState(() {
                this._connectionTestInProgress = false;
              });
            },
          ),
        ),
      ],
    );
  }
}
