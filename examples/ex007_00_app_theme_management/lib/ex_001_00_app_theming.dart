import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(const MyApp());

final kGreenishThemeLight = ThemeData(
  colorSchemeSeed: Colors.green,
  brightness: Brightness.light,
  textTheme: GoogleFonts.latoTextTheme(),
);
final kGreenishThemeDark = ThemeData(
  colorSchemeSeed: Colors.green,
  brightness: Brightness.dark,
  textTheme: GoogleFonts.latoTextTheme(),
);
final kPurplishThemeLight = ThemeData(
  colorSchemeSeed: Colors.purple,
  brightness: Brightness.light,
  textTheme: GoogleFonts.k2dTextTheme(),
);
final kPurplishThemeDark = ThemeData(
  colorSchemeSeed: Colors.purple,
  brightness: Brightness.dark,
  textTheme: GoogleFonts.k2dTextTheme(),
);

final kBluishThemeLight = kGreenishThemeLight.copyWith(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  textTheme: GoogleFonts.theGirlNextDoorTextTheme(),
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
      backgroundColor: MaterialStateProperty.all<Color>(
        Colors.blue.shade900,
      ),
    ),
  ),
);

final kBluishThemeDark = kGreenishThemeDark.copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  textTheme: GoogleFonts.theGirlNextDoorTextTheme(),
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
      backgroundColor: MaterialStateProperty.all<Color>(
        Colors.blue.shade100,
      ),
    ),
  ),
);

enum ThemeName { purplish, greenish, bluish }
final themeRM = RM.injectTheme(
  themeMode: ThemeMode.system,
  lightThemes: {
    ThemeName.greenish: kGreenishThemeLight,
    ThemeName.purplish: kPurplishThemeLight,
    ThemeName.bluish: kBluishThemeLight,
  },
  darkThemes: {
    ThemeName.greenish: kGreenishThemeDark,
    ThemeName.purplish: kPurplishThemeDark,
    ThemeName.bluish: kBluishThemeDark,
  },
);

class MyApp extends TopStatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeRM.activeTheme(),
      // theme: themeRM.lightTheme,
      // darkTheme: themeRM.darkTheme,
      // // kGreenishTheme.copyWith(brightness: Brightness.dark).,
      // themeMode: themeRM.themeMode,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ThemeCard(
                  label: 'on Primary',
                  color: colorScheme.primary,
                  textColor: colorScheme.onPrimary,
                ),
              ),
              Expanded(
                child: ThemeCard(
                  label: 'on primaryContainer',
                  color: colorScheme.primaryContainer,
                  textColor: colorScheme.onPrimaryContainer,
                ),
              ),
              Expanded(
                child: ThemeCard(
                  label: 'inversePrimary',
                  color: colorScheme.inversePrimary,
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ThemeCard(
                  label: 'on Secondary',
                  color: colorScheme.secondary,
                  textColor: colorScheme.onSecondary,
                ),
              ),
              Expanded(
                child: ThemeCard(
                  label: 'on SecondaryContainer',
                  color: colorScheme.secondaryContainer,
                  textColor: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ThemeCard(
                  label: 'on Tertiary',
                  color: colorScheme.tertiary,
                  textColor: colorScheme.onTertiary,
                ),
              ),
              Expanded(
                child: ThemeCard(
                  label: 'on TertiaryContainer',
                  color: colorScheme.tertiaryContainer,
                  textColor: colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ThemeCard(
                  label: 'on Surface',
                  color: colorScheme.surface,
                  textColor: colorScheme.onSurface,
                ),
              ),
              Expanded(
                child: ThemeCard(
                  label: 'on SurfaceVariant',
                  color: colorScheme.surfaceVariant,
                  textColor: colorScheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: ThemeCard(
                  label: 'on inverseSurface',
                  color: colorScheme.inverseSurface,
                  textColor: colorScheme.onInverseSurface,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ThemeCard(
                  label: 'on Error',
                  color: colorScheme.error,
                  textColor: colorScheme.onError,
                ),
              ),
              Expanded(
                child: ThemeCard(
                  label: 'on ErrorContainer',
                  color: colorScheme.errorContainer,
                  textColor: colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ThemeCard(
                  label: 'on Background',
                  color: colorScheme.background,
                  textColor: colorScheme.onBackground,
                ),
              ),
              Expanded(
                child: ThemeCard(
                  label: 'shadow',
                  color: colorScheme.shadow,
                  textColor: Colors.white,
                ),
              ),
              Expanded(
                child: ThemeCard(
                  label: 'outline',
                  color: colorScheme.outline,
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Theme(
            data: themeRM.activeTheme(ThemeName.bluish),
            child: Card(
              elevation: 8,
              shadowColor: themeRM.isDarkTheme ? Colors.white : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Theme override',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(
                      height: 90,
                      child: ThemeCard(
                        label: 'Theme override to use bluish',
                        color: Theme.of(context).colorScheme.primary,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Elevated Button (Theme override)'),
                      style: Theme.of(context).elevatedButtonTheme.style,
                      // style:
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          themeRM.toggle();
        },
        child: Icon(themeRM.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
      ),
    );
  }
}

class ThemeCard extends StatelessWidget {
  const ThemeCard({
    Key? key,
    required this.label,
    required this.color,
    required this.textColor,
  }) : super(key: key);

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Card(
        margin: const EdgeInsets.all(8),
        elevation: 8,
        color: color,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
