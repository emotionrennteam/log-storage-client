import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

