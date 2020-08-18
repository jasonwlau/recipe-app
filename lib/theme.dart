import 'package:flutter/material.dart';

ThemeData buildTheme() {
  // We're going to define all of our font styles
  // in this method:
  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      headline: base.headline.copyWith(
        fontFamily: 'Manjari',
        fontSize: 40.0,
        color: const Color(0xAACCE5D5),
      ),
    );
  }

  // We want to override a default light blue theme.
  final ThemeData base = ThemeData.light();
  
  // And apply changes on it:
  return base.copyWith(
    textTheme: _buildTextTheme(base.textTheme),
  );
}