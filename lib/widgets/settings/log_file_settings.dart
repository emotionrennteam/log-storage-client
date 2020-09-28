import 'dart:io';

import 'package:emotion/utils/app_settings.dart';
import 'package:emotion/widgets/settings/setting_panel.dart';
import 'package:emotion/widgets/settings/textfield_setting.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  bool _autoUploadEnabled = false;
  bool _isAutoUploadTooltipVisible = false;

  @override
  void initState() {
    super.initState();
    this._readSettings();
  }

  void _readSettings() async {
    getLogFileDirectoryPath().then(
      (value) => setState(() {
        widget.logFileDirectoryController.text = value;
      }),
    );
    getAutoUploadEnabled().then(
      (value) => setState(() {
        if (value != null) {
          this._autoUploadEnabled = value;
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
                  null,
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
                child: FlatButton(
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
                'Determines whether new log files shall be\nuploaded automatically. If enabled, then\nthe specified log directory will be monitored\nfor file changes. An upload is automatically\nstarted when the user creates a new file\nnamed "_SUCCESS".',
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
