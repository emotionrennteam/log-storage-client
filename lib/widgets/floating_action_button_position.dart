import 'package:flutter/material.dart';

/// Simple widget which is meant to position a [FloatingActionButton].
///
/// Due to the layout of this application (drawer on left side + content on the right)
/// and due to the need that the drawer must not be initialized more than once, view
/// widgets cannot contain a Scaffold. Without access to a Scaffold, the view widgets
/// cannot position a [FloatingActionButton] at its default position via the Scaffold.
/// This widget acts as a replacement. It simply defines the location of a given child
/// widget.
class FloatingActionButtonPosition extends StatelessWidget {
  /// Child widget which shall be positioned.
  final FloatingActionButton floatingActionButton;

  FloatingActionButtonPosition({this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 0,
      child: this.floatingActionButton,
    );
  }
}
