import 'package:emotion/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {

  final int appDrawerCurrentIndex;
  final Widget view;

  AppLayout({this.appDrawerCurrentIndex = 0, this.view});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Column(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDrawer(this.appDrawerCurrentIndex),
                Expanded(
                  child: Container(
                    color: Color.fromRGBO(26, 26, 26, 1),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                    ),
                    child: this.view,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
