import 'package:emotion/widgets/settings/settings_panel.dart';
import 'package:emotion/widgets/settings/textfield_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogFileSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LogFileSettingsState();
}

class _LogFileSettingsState extends State<LogFileSettings> {
  bool _autoUploadEnabled = false;

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
                  'C:\\Users\\JohnDoe\\logs',
                  null,
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
                  onPressed: () {},
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
        SettingPanel('Auto Upload'),
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
    );
  }
}
