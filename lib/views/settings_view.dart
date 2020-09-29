import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/utils/utils.dart';
import 'package:emotion/widgets/app_layout.dart';
import 'package:emotion/widgets/settings/log_file_settings.dart';
import 'package:emotion/widgets/settings/storage_connection_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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
          this._scaffoldKey.currentState.showSnackBar(
                getSnackBar(
                  savingSucceeded
                      ? 'Successfully saved settings.'
                      : 'Failed to save settings.',
                  !savingSucceeded,
                ),
              );
        },
      ),
      body: AppLayout(
        appDrawerCurrentIndex: 4,
        view: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 700),
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
            ],
          ),
        ),
      ),
    );
  }
}
