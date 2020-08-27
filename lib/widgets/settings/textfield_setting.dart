import 'package:emotion/widgets/settings/settings_panel.dart';
import 'package:flutter/material.dart';

class TextFieldSetting extends StatelessWidget {
  final String _title;
  final String _hintText;
  final TextEditingController _controller;
  final FocusNode _nextFocusNode;

  TextFieldSetting(
    this._title,
    this._hintText,
    this._controller,
    this._nextFocusNode,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingPanel(this._title),
        SizedBox(
          height: 13,
        ),
        TextFormField(
          autofocus: true,
          controller: this._controller,
          cursorColor: Colors.white,
          decoration: InputDecoration(
            // suffix: IconButton(
            //   padding: EdgeInsets.all(0),
            //   icon: Icon(Icons.visibility),
            //   onPressed: () {
            //   },
            // ),
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
            contentPadding: EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            fillColor: Color.fromRGBO(40, 40, 40, 1),
            filled: true,
            hintStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey.withOpacity(0.4),
            ),
            hintText: this._hintText,
          ),
          focusNode: this._nextFocusNode,
          textInputAction: this._nextFocusNode == null
              ? TextInputAction.done
              : TextInputAction.next,
          onEditingComplete: () => this._nextFocusNode?.nextFocus(),
          // TODO: make this configurable
          keyboardType: TextInputType.number,
          // TODO: make this configurable and add an icon as suffix
          obscureText: false,
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
