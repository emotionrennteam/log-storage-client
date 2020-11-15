import 'package:dynamic_color_theme/dynamic_color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:log_storage_client/widgets/settings/setting_panel.dart';

/// A widget to select the [MaterialAccentColor] of this app's theme.
class ColorSettings extends StatefulWidget {
  /// A map containg all colors from which the user can choose.
  final Map<String, Color> availableColors = {
    'amberAccent': Colors.amberAccent,
    'blueAccent': Colors.blueAccent,
    'defaultAccent': Color.fromRGBO(1, 176, 117, 1),
    'deepOrangeAccent': Colors.deepOrangeAccent,
    'deepPurpleAccent': Colors.deepPurpleAccent,
    'indigoAccent': Colors.indigoAccent,
    'lightBlueAccent': Colors.lightBlueAccent,
    'orangeAccent': Colors.orangeAccent,
    'pinkAccent': Colors.pinkAccent,
    'purpleAccent': Colors.purpleAccent,
    'redAccent': Colors.redAccent,
  };

  final _state = _ColorSettingsState();

  Color getSelectedColor() {
    return this._state._selectedColor;
  }

  @override
  State<StatefulWidget> createState() => this._state;
}

class _ColorSettingsState extends State<ColorSettings> {
  Color _selectedColor;
  bool _isTooltipVisible = false;

  @override
  void initState() {
    super.initState();
    this._selectedColor = DynamicColorTheme.of(context).color;
  }

  Widget _colorWidget(String colorName, Color color) {
    return Container(
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            DynamicColorTheme.of(context).setColor(
              color: color,
              shouldSave: false,
            );
          });
        },
        opaque: false,
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() {
              this._selectedColor = color;
            });
          },
          child: Column(
            children: [
              Container(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        100,
                      ),
                      border: color.value == _selectedColor.value
                          ? Border.all(
                              color: Colors.white,
                              width: 3,
                            )
                          : null,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                padding: EdgeInsets.all(10),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                '${colorName[0].toUpperCase()}${colorName.substring(1, colorName.length - 6)}',
                style: Theme.of(context).textTheme.subtitle1,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      opaque: true,
      onEnter: (_) {
        setState(() {
          this._isTooltipVisible = true;
        });
      },
      onExit: (_) {
        setState(() {
          this._isTooltipVisible = false;
          DynamicColorTheme.of(context).resetToSharedPrefsValues();
        });
      },
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 16,
                top: 32,
              ),
              child: Text(
                'Color',
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.w600,
                  fontSize: 23,
                ),
              ),
            ),
          ),
          SettingPanel(
            'Accent Color',
            'The accent color is used as background\ncolor for buttons and labels.',
            this._isTooltipVisible,
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            height: 250,
            child: GridView.count(
              primary: false,
              crossAxisCount: 6,
              children: widget.availableColors.entries
                  .map((entry) => this._colorWidget(entry.key, entry.value))
                  .toList(),
              padding: EdgeInsets.only(
                top: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
