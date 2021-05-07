import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final theme = RM.injectTheme(
  lightThemes: {
    'simple': ThemeData.light(),
  },
);
void main() async {
  final store = await RM.storageInitializerMock();
  setUp(() => store.clear());
  testWidgets('Define only light theme and toggle', (tester) async {
    final lightTheme = ThemeData.light();
    final theme = RM.injectTheme(
      lightThemes: {
        'simple': lightTheme,
      },
    );
    late BuildContext context;
    final widget = TopAppWidget(
      injectedTheme: theme,
      builder: (ctx) {
        return MaterialApp(
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.themeMode,
          home: Builder(
            builder: (ctx) {
              context = ctx;
              return Container();
            },
          ),
        );
      },
    );

    await tester.pumpWidget(widget);

    final brightness = Theme.of(context).brightness;

    expect(brightness, Brightness.light);
    expect(theme.lightTheme, lightTheme);
    expect(theme.darkTheme, lightTheme);
    theme.toggle();
    await tester.pump();
    expect(brightness, Brightness.light);
    expect(theme.supportedDarkThemes.length, 0);
    expect(theme.supportedLightThemes.length, 1);
  });

  testWidgets('Define dark theme without light and toggle', (tester) async {
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();
    final theme = RM.injectTheme(
      lightThemes: {
        'theme1': lightTheme,
      },
      darkThemes: {
        'theme2': darkTheme,
      },
    );
    late BuildContext context;
    final widget = TopAppWidget(
      injectedTheme: theme,
      builder: (ctx) {
        return MaterialApp(
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.themeMode,
          home: Builder(
            builder: (ctx) {
              context = ctx;
              return Container();
            },
          ),
        );
      },
    );

    await tester.pumpWidget(widget);

    theme.state = 'theme2';
    await tester.pumpAndSettle();
    expect(theme.lightTheme, darkTheme);
    expect(theme.darkTheme, darkTheme);
    final brightness = Theme.of(context).brightness;
    expect(brightness, Brightness.dark);
    theme.toggle();
    await tester.pump();
    expect(brightness, Brightness.dark);
    expect(theme.supportedDarkThemes.length, 1);
    expect(theme.supportedLightThemes.length, 1);
  });

  testWidgets('toggle between light and dark theme', (tester) async {
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();
    final theme = RM.injectTheme(
      lightThemes: {
        'theme1': lightTheme,
      },
      darkThemes: {
        'theme1': darkTheme,
      },
    );
    expect(theme.isDarkTheme, false);
    late Brightness brightness;
    final widget = TopAppWidget(
      injectedTheme: theme,
      builder: (ctx) {
        return MaterialApp(
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.themeMode,
          home: Builder(
            builder: (ctx) {
              brightness = Theme.of(ctx).brightness;
              return Container();
            },
          ),
        );
      },
    );

    await tester.pumpWidget(widget);

    expect(brightness, Brightness.light);
    theme.toggle();
    await tester.pumpAndSettle();
    expect(brightness, Brightness.dark);
    expect(theme.isDarkTheme, true);
    //
    theme.themeMode = ThemeMode.system;
    await tester.pumpAndSettle();
    expect(brightness, Brightness.light);
    expect(theme.isDarkTheme, false);

    //
    theme.themeMode = ThemeMode.dark;
    await tester.pumpAndSettle();
    expect(brightness, Brightness.dark);
    expect(theme.isDarkTheme, true);
    //
    theme.themeMode = ThemeMode.light;
    await tester.pumpAndSettle();
    expect(brightness, Brightness.light);
    expect(theme.isDarkTheme, false);
  });

  testWidgets('Persisting theme, case not theme persisted', (tester) async {
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();
    final theme = RM.injectTheme(
      lightThemes: {
        'theme1': lightTheme,
        'theme2': lightTheme,
      },
      darkThemes: {
        'theme1': lightTheme,
        'theme2': darkTheme,
      },
      persistKey: '_theme_',
    );

    final widget = TopAppWidget(
      injectedTheme: theme,
      builder: (ctx) {
        return MaterialApp(
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.themeMode,
          home: Container(),
        );
      },
    );
    expect(store.store.isEmpty, true);
    await tester.pumpWidget(widget);
    expect(theme.themeMode, ThemeMode.system);
    expect(store.store['_theme_'], 'theme1#|#');
    theme.toggle();
    await tester.pump();
    expect(theme.themeMode, ThemeMode.dark);
    expect(store.store['_theme_'], 'theme1#|#1');
    //
    theme.toggle();
    await tester.pump();
    expect(theme.themeMode, ThemeMode.light);
    expect(store.store['_theme_'], 'theme1#|#0');
    //
    theme.state = 'theme2';
    await tester.pump();
    expect(theme.themeMode, ThemeMode.light);
    expect(store.store['_theme_'], 'theme2#|#0');
    //
    theme.toggle();
    await tester.pump();
    expect(theme.themeMode, ThemeMode.dark);
    expect(store.store['_theme_'], 'theme2#|#1');
    //
    theme.state = 'theme1';
    await tester.pump();
    expect(theme.themeMode, ThemeMode.dark);
    expect(store.store['_theme_'], 'theme1#|#1');
  });

  testWidgets('Persisting theme, case dark theme persisted', (tester) async {
    store.store.addAll({'_theme_': 'theme1#|#1'});
    //
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();
    final theme = RM.injectTheme(
      lightThemes: {
        'theme1': lightTheme,
        'theme2': lightTheme,
      },
      darkThemes: {
        'theme1': lightTheme,
        'theme2': darkTheme,
      },
      persistKey: '_theme_',
    );

    final widget = TopAppWidget(
      injectedTheme: theme,
      builder: (ctx) {
        return MaterialApp(
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.themeMode,
          home: Container(),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(theme.themeMode, ThemeMode.dark);
    expect(store.store['_theme_'], 'theme1#|#1');
    theme.toggle();
    await tester.pump();
    expect(theme.themeMode, ThemeMode.light);
    expect(store.store['_theme_'], 'theme1#|#0');
    //
    theme.state = 'theme2';
    await tester.pump();
    expect(theme.themeMode, ThemeMode.light);
    expect(store.store['_theme_'], 'theme2#|#0');
    //
  });

  testWidgets('Persisting theme, case system theme persisted', (tester) async {
    store.store.addAll({'_theme_': 'theme3#|#'});
    //
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();
    final theme = RM.injectTheme(
      lightThemes: {
        'theme1': lightTheme,
        'theme2': lightTheme,
      },
      darkThemes: {
        'theme1': lightTheme,
        'theme2': darkTheme,
      },
      persistKey: '_theme_',
    );

    final widget = TopAppWidget(
      injectedTheme: theme,
      builder: (ctx) {
        return MaterialApp(
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.themeMode,
          home: Container(),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(theme.themeMode, ThemeMode.system);
    expect(store.store['_theme_'], 'theme1#|#');
    theme.toggle();
    await tester.pump();
    expect(theme.themeMode, ThemeMode.dark);
    expect(store.store['_theme_'], 'theme1#|#1');
    //
    theme.state = 'theme2';
    await tester.pump();
    expect(theme.themeMode, ThemeMode.dark);
    expect(store.store['_theme_'], 'theme2#|#1');
  });

  testWidgets('Persisting theme, case light theme persisted', (tester) async {
    store.store.addAll({'_theme_': 'theme2#|#0'});
    //
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();
    final theme = RM.injectTheme(
      lightThemes: {
        'theme1': lightTheme,
        'theme2': lightTheme,
      },
      darkThemes: {
        'theme1': lightTheme,
        'theme2': darkTheme,
      },
      persistKey: '_theme_',
    );

    final widget = TopAppWidget(
      injectedTheme: theme,
      builder: (ctx) {
        return MaterialApp(
          theme: theme.lightTheme,
          darkTheme: theme.darkTheme,
          themeMode: theme.themeMode,
          home: Container(),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(theme.themeMode, ThemeMode.light);
    expect(store.store['_theme_'], 'theme2#|#0');
    theme.toggle();
    await tester.pump();
    expect(theme.themeMode, ThemeMode.dark);
    expect(store.store['_theme_'], 'theme2#|#1');
    //
    theme.state = 'theme1';
    await tester.pump();
    expect(theme.themeMode, ThemeMode.dark);
    expect(store.store['_theme_'], 'theme1#|#1');
  });

  testWidgets(
    'WHEN '
    'THEN ',
    (tester) async {
      SnapState<String>? _snapState;
      late SnapState<String> _nextSnapState;

      final lightTheme = ThemeData.light();
      final darkTheme = ThemeData.dark();
      final theme = RM.injectTheme<String>(
        lightThemes: {
          'theme1': lightTheme,
          'theme2': lightTheme,
        },
        darkThemes: {
          'theme1': lightTheme,
          'theme2': darkTheme,
        },
        middleSnapState: (middleSnap) {
          _snapState = middleSnap.currentSnap;
          _nextSnapState = middleSnap.nextSnap;
        },
      );
      theme.state = 'theme2';

      expect(_snapState?.isIdle, true);
      expect(_snapState?.data, 'theme1');
      //
      expect(_nextSnapState.hasData, true);
      expect(_nextSnapState.data, 'theme2');
    },
  );
}
