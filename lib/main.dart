import 'package:emotion/pages/dashboard_view.dart';
import 'package:emotion/utils/constants.dart' as constants;
import 'package:emotion/utils/constants.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Motion Rennteam',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(32, 33, 37, 1),
        canvasColor: Color.fromRGBO(22, 23, 27, 1),
        accentColor: Color.fromRGBO(1, 176, 117, 1),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        accentTextTheme: TextTheme(
          headline5: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontWeight: FontWeight.w300,
            color: constants.TEXT_COLOR,
          ),
          headline2: TextStyle(
            fontWeight: FontWeight.w300,
            color: constants.TEXT_COLOR,
          ),
          headline3: TextStyle(
            fontWeight: FontWeight.w300,
            color: constants.TEXT_COLOR,
          ),
          headline4: TextStyle(
            fontWeight: FontWeight.w300,
            color: constants.TEXT_COLOR,
          ),
          headline5: TextStyle(
            fontWeight: FontWeight.w300,
            color: constants.TEXT_COLOR,
          ),
          headline6: TextStyle(
            fontWeight: FontWeight.w400,
            color: constants.TEXT_COLOR,
          ),
          button: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: constants.TEXT_COLOR,
          ),
          subtitle1: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w300,
            color: constants.TEXT_COLOR,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        iconTheme: IconThemeData(
          color: TEXT_COLOR,
        ),
        unselectedWidgetColor: Colors.white,
      ),
      home: DashboardView(),
    );
  }
}
