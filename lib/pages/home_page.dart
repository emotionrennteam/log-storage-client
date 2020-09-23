import 'package:emotion/widgets/app_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final globalKey = GlobalKey<ScaffoldState>();
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: AppLayout(
        appDrawerCurrentIndex: 0,
        view: GridView.count(
          physics: BouncingScrollPhysics(),
          crossAxisCount: 2,
          padding: EdgeInsets.symmetric(
            vertical: 32,
            horizontal: 0,
          ),
          childAspectRatio: 2.0,
          children: List.generate(
            10,
            (index) => Card(
              clipBehavior: Clip.antiAlias,
              color: index == 0
                  ? Theme.of(context).accentColor
                  : Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 3,
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Lorem ipsum',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
