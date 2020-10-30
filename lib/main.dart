import 'package:log_storage_client/utils/locator.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/widgets/app_layout.dart';
import 'package:flutter/material.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Motion Rennteam',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
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
      home: AppLayout(),
    );
  }
}
