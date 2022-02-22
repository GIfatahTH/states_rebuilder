import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main(List<String> args) {
  runApp(const CupertinoStoreApp());
}

final kGreenishThemeLight = ThemeData(
  colorSchemeSeed: Colors.green,
  brightness: Brightness.light,
);
final kGreenishThemeDark = ThemeData(
  colorSchemeSeed: Colors.green,
  brightness: Brightness.dark,
);

final kPurplishThemeLight = ThemeData(
  colorSchemeSeed: Colors.purple,
  brightness: Brightness.light,
);
final kPurplishThemeDark = ThemeData(
  colorSchemeSeed: Colors.purple,
  brightness: Brightness.dark,
);

enum ThemeName { purplish, greenish }
final themeRM = RM.injectTheme(
  themeMode: ThemeMode.system,
  lightThemes: {
    ThemeName.greenish: kGreenishThemeLight,
    ThemeName.purplish: kPurplishThemeLight,
  },
  darkThemes: {
    ThemeName.greenish: kGreenishThemeDark,
    ThemeName.purplish: kPurplishThemeDark,
  },
);

class CupertinoStoreApp extends TopStatelessWidget {
  const CupertinoStoreApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: MaterialBasedCupertinoThemeData(
        materialTheme: themeRM.activeTheme(),
      ),
      home: CupertinoPageScaffold(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              CupertinoSegmentedControl<ThemeName>(
                children: const {
                  ThemeName.purplish: Text('Purplish'),
                  ThemeName.greenish: Text('Greenish'),
                },
                groupValue: themeRM.state,
                onValueChanged: (value) {
                  themeRM.state = value;
                },
              ),
              const SizedBox(height: 4),
              OnReactive(
                () {
                  return CupertinoSegmentedControl<ThemeMode>(
                    children: const {
                      ThemeMode.light: Text('Light'),
                      ThemeMode.dark: Text('Dark'),
                      ThemeMode.system: Text('System'),
                    },
                    groupValue: themeRM.themeMode,
                    onValueChanged: (value) {
                      themeRM.themeMode = value;
                    },
                  );
                },
              ),
              const Spacer(),
              CupertinoButton.filled(
                child: const Text('Toggle darkness'),
                onPressed: () {
                  themeRM.toggle();
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
