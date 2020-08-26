import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/widgets/app_drawer.dart';
import 'package:emotion/widgets/settings/log_file_settings.dart';
import 'package:emotion/widgets/settings/storage_connection_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _logFileSettingsWidget = new LogFileSettings();
  final _storageConnectionsWidget = new StorageConnectionSettings();

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
            _storageConnectionsWidget.endpointController.text,
            _storageConnectionsWidget.portController.text,
            _storageConnectionsWidget.accessKeyController.text,
            _storageConnectionsWidget.secretKeyController.text,
            _storageConnectionsWidget.bucketController.text,
            _storageConnectionsWidget.getTlsEnabled(),
            _logFileSettingsWidget.logFileDirectoryController.text,
            _logFileSettingsWidget.getAutoUploadEnabled(),
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
                            _storageConnectionsWidget,
                            SizedBox(
                              height: 32,
                            ),
                            _logFileSettingsWidget,
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
