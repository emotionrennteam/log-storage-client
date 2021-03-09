import 'package:flutter/material.dart';
import 'package:log_storage_client/utils/constants.dart';

class EmotionDesignButton extends StatelessWidget {
  final Widget child;
  final Function onPressed;
  final double verticalPadding;

  /// Defaults to the theme's canvas color.
  final Color color;

  /// Encapsulates a [TextButton] which is styled according to this app's design.
  EmotionDesignButton({
    @required this.child,
    @required this.onPressed,
    this.color,
    this.verticalPadding = 14,
  });

  @override
  Widget build(BuildContext context) {
    Color color = this.color;
    if (this.color == null) {
      color = Theme.of(context).canvasColor;
    }

    return TextButton(
      onPressed: this.onPressed,
      child: Padding(
        child: this.child,
        padding: EdgeInsets.symmetric(
          vertical: this.verticalPadding,
          horizontal: 25,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BORDER_RADIUS_LARGE),
            side: BorderSide(
              color: Color.fromRGBO(40, 40, 40, 1),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
