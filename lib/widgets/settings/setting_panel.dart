import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:log_storage_client/utils/constants.dart';

class SettingPanel extends StatefulWidget {
  /// The title / name of the setting.
  final String title;

  /// The message shown by the [Tooltip].
  final String tooltipMessage;

  /// Whether the icon for the tooltip is currently visible. If the user
  /// hovers this icon, then the [Tooltip] will be shown.
  final bool isIconForTooltipVisible;

  SettingPanel(this.title, this.tooltipMessage, this.isIconForTooltipVisible);

  @override
  State<StatefulWidget> createState() => _SettingPanelState();
}

class _SettingPanelState extends State<SettingPanel> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.title,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            heightFactor: 0.6,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 400),
              child: Tooltip(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.help_outline_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: null,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(BORDER_RADIUS_SMALL),
                ),
                message: widget.tooltipMessage,
                padding: EdgeInsets.all(12),
                preferBelow: true,
                verticalOffset: 15,
                textStyle: Theme.of(context).textTheme.subtitle1,
              ),
              opacity: widget.isIconForTooltipVisible ? 1.0 : 0.0,
              curve: Curves.easeInBack,
            ),
          ),
        ),
      ],
    );
  }
}
