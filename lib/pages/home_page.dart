import 'package:emotion/widgets/app_drawer.dart';
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
      body: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDrawer(0),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: GridView.count(
                      physics: BouncingScrollPhysics(),
                      crossAxisCount: 2,
                      padding: EdgeInsets.all(4.0),
                      childAspectRatio: 2.0,
                      children: List.generate(
                        10,
                        (index) => Card(
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            'https://via.placeholder.com/600x300',
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 3,
                          margin: EdgeInsets.all(10),
                        ),
                      ),
                    ),
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
