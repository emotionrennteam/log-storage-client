import 'dart:io' show Platform, File;
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:log_storage_client/utils/i_app_settings.dart';
import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/widgets/emotion_design_button.dart';
import 'package:log_storage_client/widgets/settings/setting_panel.dart';
import 'package:log_storage_client/widgets/settings/textfield_setting.dart';

class LogFileSettings extends StatefulWidget {
  final logFileDirectoryController = TextEditingController();

  final _LogFileSettingsState _state = new _LogFileSettingsState();

  @override
  State<StatefulWidget> createState() => this._state;

  bool getAutoUploadEnabled() {
    return this._state._autoUploadEnabled;
  }
}

class _LogFileSettingsState extends State<LogFileSettings> {
  IAppSettings _appSettings = locator<IAppSettings>();
  bool _autoUploadEnabled = false;
  bool _isAutoUploadTooltipVisible = false;

  @override
  void initState() {
    super.initState();
    this._readSettings();
  }

  void _readSettings() async {
    this._appSettings.getLogFileDirectoryPath().then(
          (value) => setState(() {
            widget.logFileDirectoryController.text = value;
          }),
        );
    this._appSettings.getAutoUploadEnabled().then(
          (value) => setState(() {
            if (value != null) {
              this._autoUploadEnabled = value;
            }
          }),
        );
  }

  void _showAutoUploadWarningForLinux() {
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
          title: Text('Warning'),
          content: Text(
            """"Auto Upload" on Linux isn\'t fully supported. "Auto Upload" watches the\nfile-system for changes. The implementation for file-system watching in\nDart (=the programming language used for the implementation of this\napplication) supports watching both files and directories, but recursive\nwatching is not supported.\n\nTherefore, "Auto Upload" only works, if the trigger file "_UPLOAD" is\ncreated directly in the configured log file directory (sub-directories\naren't supported). In other words, if the trigger file is created in a sub-\ndirectory of the configured log file directory, then this application won't\nbe notified about the creation of the trigger file and therefore cannot\nstart the "Auto Upload".""",
            softWrap: true,
          ),
          contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 10),
          buttonPadding: EdgeInsets.only(
            right: 24,
          ),
          actions: <Widget>[
            EmotionDesignButton(
              child: Text(
                'Ok',
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
      },
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
              'Log Files',
              style: TextStyle(
                color: Colors.grey.shade300,
                fontWeight: FontWeight.w600,
                fontSize: 23,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                child: TextFieldSetting(
                  'Log File Directory',
                  '/home/johndoe/logs/',
                  widget.logFileDirectoryController,
                  'The directory on your local hard drive which\ncontains log files. Only files in this directory\ncan be uploaded.',
                ),
                width: 500,
              ),
            ),
            SizedBox(
              width: 16,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(top: 41),
                child: EmotionDesignButton(
                  onPressed: () async {
                    var directoryPath =
                        await FilePicker.platform.getDirectoryPath();
                    if (directoryPath != null && directoryPath.length > 1) {
                      widget.logFileDirectoryController.text =
                          File(directoryPath).path;
                    }
                  },
                  child: Text(
                    'Browse',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(color: Colors.transparent),
        MouseRegion(
          onEnter: (_) => setState(() {
            this._isAutoUploadTooltipVisible = true;
          }),
          onExit: (_) => setState(() {
            this._isAutoUploadTooltipVisible = false;
          }),
          child: Column(
            children: [
              SettingPanel(
                'Auto Upload',
                'Determines whether new log files shall be\nuploaded automatically. If enabled, then\nthe specified log directory will be monitored\nfor file changes. An upload is automatically\nstarted when the user creates a new file\nnamed "_UPLOAD".',
                this._isAutoUploadTooltipVisible,
              ),
              SwitchListTile(
                value: this._autoUploadEnabled,
                title: Text(this._autoUploadEnabled
                    ? 'Auto Upload Enabled'
                    : 'Auto Upload Disabled'),
                onChanged: (value) async {
                  setState(() {
                    this._autoUploadEnabled = value;
                    if (Platform.isLinux && value) {
                      this._showAutoUploadWarningForLinux();
                    }
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
      ],
    );
  }
}
