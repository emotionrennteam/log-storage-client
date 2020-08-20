import 'package:emotion/pages/home_page.dart';
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
        primarySwatch: Colors.grey,
        primaryColor: Color.fromRGBO(26, 26, 26, 1),
        canvasColor: Color.fromRGBO(19, 19, 19, 1),
        accentColor: Color.fromRGBO(35, 201, 95, 1),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headline1: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
          headline2: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
          headline3: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
          headline4: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
          headline5: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
          headline6: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
          button: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          subtitle1: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
      home: HomePage(title: 'E-Motion Rennteam Aalen - Log Client'),
    );
  }
}
