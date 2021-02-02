import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// final isDarkMode = RM.inject<bool>(
//   () => true,
//   persist: () => PersistState(
//     key: '__themeData__',
//     fromJson: (json) => json == '1',
//     toJson: (themeData) => themeData ? '1' : '0',
//   ),
//   onError: (e, s) {
//     // print(s);
//   },
// );

final isDark = RM.injectTheme(
  lightThemes: {
    'default': ThemeData.light(),
    'super': ThemeData.light().copyWith(
      backgroundColor: Colors.white,
      buttonColor: Colors.red,
      accentColor: Colors.red,
      appBarTheme: AppBarTheme(color: Colors.yellow),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.red,
      ),
    )
  },
  darkThemes: {
    'default': ThemeData.dark(),
    'super': ThemeData.dark().copyWith(
      appBarTheme: AppBarTheme(color: Colors.yellow),
      backgroundColor: Colors.white,
      buttonColor: Colors.white,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: Colors.red,
      ),
    )
  },
  themeMode: ThemeMode.dark,
  persistKey: '__themeData__',
  debugPrintWhenNotifiedPreMessage: '',
);
