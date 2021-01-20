import 'package:log_storage_client/widgets/settings/chips_form_field.dart';
import 'package:log_storage_client/widgets/settings/setting_panel.dart';
import 'package:flutter/material.dart';

class ChipsTextFieldSetting extends StatefulWidget {
  /// A list of elements which represent the initial value of this textfield.
  final List<String> initialValues;

  /// A title displayed above this text field.
  final String title;

  /// A hint text displayed in grey inside the text field as long
  /// as there's no input.
  final String hintText;

  /// A message displayed as a tooltip when the user hovers this text field.
  final String tooltipMessage;

  /// A callback function which is called when the user is typing in this
  /// textfield. The function should return a list of auto complete values
  /// corresponding to the user's input query.
  final List<String> Function(String) onAutoComplete;

  /// A callback function which is called when the user adds a new chip.
  final void Function(String) onAddChip;

  /// A callback function which is called when the user removes a new chip.
  final void Function(String) onRemoveChip;

  /// The maximum number of allowed chips / values.
  final int maxValues;
  
  /// The minimum number of required chips / values. Defaults to 0.
  final int minValues;

  /// A wrapper for [ChipsFormField] which applies a custom [InputDecoration]
  /// so that the style of the [ChipsFormField] matches the design of this
  /// application.
  ChipsTextFieldSetting({
    @required this.initialValues,
    @required this.title,
    @required this.hintText,
    @required this.onAutoComplete,
    @required this.onAddChip,
    @required this.onRemoveChip,
    @required this.tooltipMessage,
    this.maxValues,
    this.minValues = 0,
  });

  @override
  State<StatefulWidget> createState() => _ChipsTextFieldSettingState();
}

class _ChipsTextFieldSettingState extends State<ChipsTextFieldSetting> {
  final _focusNode = FocusNode();
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
          ChipsFormField(
            initialValue: widget.initialValues,
            onAutoComplete: widget.onAutoComplete,
            onAddChip: widget.onAddChip,
            onRemoveChip: widget.onRemoveChip,
            autoCompleteColor: Theme.of(context).primaryColor,
            chipBackgroundColor: Theme.of(context).primaryColor,
            focusNode: this._focusNode,
            maxChips: widget.maxValues,
            minChips: widget.minValues,
            inputDecoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(32),
                ),
                borderSide: BorderSide(color: Colors.transparent, width: 0.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(32),
                ),
                borderSide: BorderSide(color: Colors.transparent, width: 0.0),
              ),
              contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              fillColor: Color.fromRGBO(40, 40, 40, 1),
              filled: true,
              hintStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey.withOpacity(0.4),
              ),
            ),
            hintText: widget.hintText,
            hintTextStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey.withOpacity(0.4),
            ),
            textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
