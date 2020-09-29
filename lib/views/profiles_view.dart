import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfilesView extends StatelessWidget {
  const ProfilesView({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profiles View',
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
        ),
      ),
    );
  }
}
