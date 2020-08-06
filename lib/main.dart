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
        primaryColor: Colors.grey.shade800,
        accentColor: Colors.indigoAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'E-Motion Rennteam Aalen - Log Client'),
    );
  }
}
