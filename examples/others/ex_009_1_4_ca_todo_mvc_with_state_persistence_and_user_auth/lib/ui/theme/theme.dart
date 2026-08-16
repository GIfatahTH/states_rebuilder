import 'package:material_ui/material_ui.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final isDark = RM.injectTheme(
  lightThemes: {
    'default': ThemeData.light(),
  },
  darkThemes: {
    'default': ThemeData.dark(),
  },
  themeMode: ThemeMode.dark,
  persistKey: '__themeData__',
  // debugPrintWhenNotifiedPreMessage: '',
);
