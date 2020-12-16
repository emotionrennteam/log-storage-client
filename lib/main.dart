import 'package:dynamic_color_theme/dynamic_color_theme.dart';
import 'package:log_storage_client/utils/constants.dart' as constants;
import 'package:log_storage_client/utils/constants.dart';
import 'package:log_storage_client/utils/utils.dart' as utils;
import 'package:log_storage_client/widgets/app_layout.dart';
import 'package:flutter/material.dart';

void main() {
  utils.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  ThemeData _buildTheme(Color accentColor, bool isDark) {
    return ThemeData(
      primarySwatch: Colors.blueGrey,
      primaryColor: Color.fromRGBO(32, 33, 37, 1),
      canvasColor: Color.fromRGBO(22, 23, 27, 1),
      accentColor: accentColor,
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorTheme(
      data: this._buildTheme,
      defaultIsDark: true,
      // Default AccentColor
      defaultColor: Color.fromRGBO(1, 176, 117, 1),
      themedWidgetBuilder: (BuildContext context, ThemeData theme) {
        return MaterialApp(
          title: 'E-Motion Rennteam',
          theme: theme,
          home: AppLayout(),
        );
      },
    );
  }
}
