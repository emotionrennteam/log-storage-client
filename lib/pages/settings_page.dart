import 'package:emotion/utils/minio_manager.dart';
import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/widgets/app_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _tlsEnabled = false;
  final endpointController = TextEditingController();
  final portController = TextEditingController();
  final accessKeyController = TextEditingController();
  final secretKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this._readSettings();
  }

  void _readSettings() async {
    getMinioEndpoint().then(
      (value) => setState(() {
        this.endpointController.text = value;
      }),
    );
    getMinioPort().then(
      (value) => setState(() {
        this.portController.text = value.toString();
      }),
    );
    getMinioAccessKey().then(
      (value) => setState(() {
        this.accessKeyController.text = value;
      }),
    );
    getMinioSecretKey().then(
      (value) => setState(() {
        this.secretKeyController.text = value;
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
    return new Scaffold(
      key: this._scaffoldKey,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(
          Icons.check,
          color: Colors.white,
        ),
        label: Text(
          'Save',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        onPressed: () async {
          final savingSucceeded = await saveAllSettings(
            this.endpointController.text,
            this.portController.text,
            this.accessKeyController.text,
            this.secretKeyController.text,
            this._tlsEnabled,
          );
          this._scaffoldKey.currentState.hideCurrentSnackBar();
          this._scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text(savingSucceeded
                    ? 'Successfully saved settings.'
                    : 'Failed to save settings.'),
              ));
        },
      ),
      backgroundColor: Color.fromRGBO(19, 19, 19, 1),
      body: Builder(
        builder: (context) => Column(
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDrawer(4),
                  Expanded(
                    child: Container(
                      color: Color.fromRGBO(26, 26, 26, 1),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 100),
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 32,
                                top: 32,
                              ),
                              child: Text(
                                'Settings',
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                            TextFieldSetting(
                              'Endpoint',
                              '10.11.0.18',
                              this.endpointController,
                            ),
                            Divider(color: Colors.transparent),
                            TextFieldSetting(
                              'Port',
                              '9000',
                              this.portController,
                            ),
                            Divider(color: Colors.transparent),
                            TextFieldSetting(
                              'Access Key',
                              'eyW/+8ZtsgT81Cb0e8OVxzJAQP5lY7Dcamnze+JnWEDT ...',
                              this.accessKeyController,
                            ),
                            Divider(color: Colors.transparent),
                            TextFieldSetting(
                              'Secret Key',
                              '0tZn+7QQCxphpHwTm6/dC3LpP5JGIbYl6PK8Sy79R+P2 ...',
                              this.secretKeyController,
                            ),
                            Divider(color: Colors.transparent),
                            SettingPanel('TLS'),
                            SwitchListTile(
                              value: this._tlsEnabled,
                              title: Text(this._tlsEnabled
                                  ? 'TLS Enabled'
                                  : 'TLS Disabled'),
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
                                color: Theme.of(context).accentColor,
                                onPressed: () async {
                                  int port = 0;
                                  try {
                                    port = int.parse(this.portController.text);
                                  } on FormatException catch (_) {
                                    // TODO: validate input
                                    return;
                                  }
                                  final connectionSucceeded =
                                      await validateConnection(
                                          this.endpointController.text,
                                          port,
                                          this._tlsEnabled,
                                          this.accessKeyController.text,
                                          this.secretKeyController.text);
                                  Scaffold.of(context).hideCurrentSnackBar();
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(connectionSucceeded
                                        ? 'Successfully connected.'
                                        : 'Failed to connect.'),
                                  ));
                                },
                                padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 25,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingPanel extends StatelessWidget {
  final String title;

  SettingPanel(this.title);

  @override
  Widget build(BuildContext context) {
    // TODO: add tooltips
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        this.title,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class TextFieldSetting extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;

  TextFieldSetting(this.title, this.hintText, this.controller);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingPanel(this.title),
        SizedBox(
          height: 13,
        ),
        TextField(
          controller: this.controller,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(28.0),
              ),
              borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(28.0),
              ),
              borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            ),
            contentPadding: EdgeInsets.only(
              left: 20,
              top: 15,
              bottom: 15,
            ),
            fillColor: Color.fromRGBO(40, 40, 40, 1),
            filled: true,
            hintStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey.withOpacity(0.4),
            ),
            hintText: this.hintText,
          ),
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
