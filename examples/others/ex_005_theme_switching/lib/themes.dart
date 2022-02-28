import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final InjectedTheme theme = RM.injectTheme<AppTheme>(
  //The first theme in lightThemes is the default one,
  lightThemes: {
    AppTheme.Green: ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.green,
    ),
    AppTheme.Blue: ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
    ),
  },
  darkThemes: {
    AppTheme.Green: ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.green[700],
    ),
    AppTheme.Blue: ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blue[700],
    ),
  },
  persistKey: '__theme__',
);
enum AppTheme {
  Green,
  Blue,
}
