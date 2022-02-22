import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class HiveStorage implements IPersistStore {
  late Box box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox('myBox');
  }

  @override
  Object? read(String key) {
    return box.get(key);
  }

  @override
  Future<void> write<T>(String key, T value) async {
    return box.put(key, value);
  }

  @override
  Future<void> delete(String key) async {
    return box.delete(key);
  }

  @override
  Future<void> deleteAll() async {
    await box.clear();
  }
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await RM.storageInitializer(HiveStorage());
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
  persistKey: '__theme__',
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
    return MaterialApp(
      theme: themeRM.activeTheme().copyWith(
            textTheme: TextTheme(
              bodyText2: TextStyle(
                fontSize: 22,
                fontFamily: GoogleFonts.pacifico().fontFamily,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                ),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
          ),
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
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
              ElevatedButton(
                child: const Text('Toggle darkness'),
                onPressed: () {
                  themeRM.toggle();
                },
              ),
              const Spacer(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {}),
      ),
    );
  }
}
