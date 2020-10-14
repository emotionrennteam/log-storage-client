import 'package:flutter/material.dart';

class EmotionDesignButton extends StatelessWidget {
  final Widget child;
  final Function onPressed;
  final double verticalPadding;

  /// Defaults to the theme's canvas color.
  final Color color;

  /// Encapsulates a [FlatButton] which is styled according to this app's design.
  EmotionDesignButton({
    @required this.child,
    @required this.onPressed,
    this.color,
    this.verticalPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    Color color = this.color;
    if (this.color == null) {
      color = Theme.of(context).canvasColor;
    }

    return FlatButton(
      child: this.child,
      padding: EdgeInsets.symmetric(
        vertical: this.verticalPadding,
        horizontal: 30,
      ),
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
        side: BorderSide(
          color: Color.fromRGBO(40, 40, 40, 1),
          width: 2,
        ),
      ),
      onPressed: this.onPressed,
    );
  }
}
