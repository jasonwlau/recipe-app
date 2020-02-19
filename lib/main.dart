import 'package:app/home.dart';
import 'package:app/login.dart';
import 'package:app/state_widget.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';

void main() => runApp(new StateWidget(
  child: new MyApp(),
  )
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App',
      theme: buildTheme(),
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
      }
    );
  }
}
