import 'package:emotion/widgets/settings/settings_panel.dart';
import 'package:flutter/material.dart';

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
          cursorColor: Colors.white,
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
