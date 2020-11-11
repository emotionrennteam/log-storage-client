import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/widgets/settings/setting_panel.dart';
import 'package:flutter/material.dart';

class TextFieldSetting extends StatefulWidget {
  /// A title displayed above this text field.
  final String title;

  /// A hint text displayed in grey inside the text field as long
  /// as there's no input.
  final String hintText;

  final TextEditingController controller;

  /// Reference to the [FocusNode] of the next form element / input
  /// which will be focused automatically after this text field when
  /// the user hits the TAB key.
  final FocusNode nextFocusNode;

  /// A message displayed as a tooltip when the user hovers this text field.
  final String tooltipMessage;

  /// Used to determine the type of keyboard on mobile devices.
  final bool isValueNumerical;

  /// Determines whether the text should be oscured (plaintext is replaced
  /// by character •).
  final bool isObscured;

  /// A function to validate the text input.
  /// 
  /// The function must return null, if the text is valid. Otherwise, the
  /// function must return an error message.
  final String Function(String) validator;

  TextFieldSetting(
    this.title,
    this.hintText,
    this.controller,
    this.nextFocusNode,
    this.tooltipMessage, {
    this.isValueNumerical = false,
    this.isObscured = false,
    this.validator,
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
                  const Radius.circular(BORDER_RADIUS_LARGE),
                ),
                borderSide: BorderSide(color: Colors.transparent, width: 0.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(BORDER_RADIUS_LARGE),
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
            validator:
                widget.validator == null ? (_) => null : widget.validator,
          ),
        ],
      ),
    );
  }
}
