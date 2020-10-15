import 'package:log_storage_client/widgets/settings/setting_panel.dart';
import 'package:flutter/material.dart';

class TextFieldSetting extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final FocusNode nextFocusNode;
  final String tooltipMessage;
  final bool isValueNumerical;
  final bool isObscured;

  TextFieldSetting(
    this.title,
    this.hintText,
    this.controller,
    this.nextFocusNode,
    this.tooltipMessage, {
    this.isValueNumerical = false,
    this.isObscured = false,
  });

  @override
  State<StatefulWidget> createState() => _TextFieldSettingState();
}

class _TextFieldSettingState extends State<TextFieldSetting> {
  bool _isTooltipVisible = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isTooltipVisible = true;
      }),
      onExit: (_) => setState(() {
        _isTooltipVisible = false;
      }),
      child: Column(
        children: [
          SettingPanel(
              widget.title, widget.tooltipMessage, this._isTooltipVisible),
          SizedBox(
            height: 13,
          ),
          TextFormField(
            autofocus: true,
            controller: widget.controller,
            cursorColor: Colors.white,
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
              hintText: widget.hintText,
            ),
            focusNode: widget.nextFocusNode,
            textInputAction: widget.nextFocusNode == null
                ? TextInputAction.done
                : TextInputAction.next,
            onEditingComplete: () => widget.nextFocusNode?.nextFocus(),
            keyboardType: widget.isValueNumerical
                ? TextInputType.number
                : TextInputType.text,
            obscureText: widget.isObscured,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
