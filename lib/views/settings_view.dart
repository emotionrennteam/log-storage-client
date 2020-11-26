import 'package:dynamic_color_theme/dynamic_color_theme.dart';
import 'package:log_storage_client/utils/app_settings.dart';
import 'package:log_storage_client/utils/utils.dart';
import 'package:log_storage_client/widgets/floating_action_button_position.dart';
import 'package:log_storage_client/widgets/settings/color_settings.dart';
import 'package:log_storage_client/widgets/settings/log_file_settings.dart';
import 'package:log_storage_client/widgets/settings/storage_connection_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _logFileSettingsWidget = LogFileSettings();
  final _storageConnectionsWidget = StorageConnectionSettings();
  final _colorSettingsWidget = ColorSettings();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: 100,
                  left: 32,
                  right: 32,
                ),
                physics: BouncingScrollPhysics(),
                child: Container(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 700),
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
                          this._storageConnectionsWidget,
                          SizedBox(
                            height: 32,
                          ),
                          this._logFileSettingsWidget,
                          SizedBox(
                            height: 32,
                          ),
                          this._colorSettingsWidget,
                          SizedBox(
                            height: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        FloatingActionButtonPosition(
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
              // Validate port
              try {
                int.parse(_storageConnectionsWidget.portController.text);
              } on Exception {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  getSnackBar(
                    'Failed to save settings. The specified port must be a numerical value, e.g. 80 or 443.',
                    true,
                  ),
                );
                return;
              }

              final savingSucceeded = await saveAllSettings(
                _storageConnectionsWidget.endpointController.text,
                _storageConnectionsWidget.portController.text,
                _storageConnectionsWidget.regionController.text,
                _storageConnectionsWidget.bucketController.text,
                _storageConnectionsWidget.accessKeyController.text,
                _storageConnectionsWidget.secretKeyController.text,
                _storageConnectionsWidget.getTlsEnabled(),
                _logFileSettingsWidget.logFileDirectoryController.text,
                _logFileSettingsWidget.getAutoUploadEnabled(),
              );
              await DynamicColorTheme.of(context).setColor(
                color: this._colorSettingsWidget.getSelectedColor(),
                shouldSave: true,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                getSnackBar(
                  savingSucceeded
                      ? 'Successfully saved settings.'
                      : 'Failed to save settings.',
                  !savingSucceeded,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
