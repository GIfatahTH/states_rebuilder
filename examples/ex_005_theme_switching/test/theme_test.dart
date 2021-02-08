import 'package:ex_005_theme_switching/main.dart';
import 'package:ex_005_theme_switching/preference_page.dart';
import 'package:ex_005_theme_switching/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  final store = await RM.storageInitializerMock();
  setUp(() {
    store.clear();
  });
  testWidgets('Start with default theme and system theme mode', (tester) async {
    await tester.pumpWidget(MyApp());
    //Defautl theme is the AppTheme.Green
    expect(Theme.of(RM.context).primaryColor, Colors.green);
    expect(Theme.of(RM.context).brightness, Brightness.light);
    //
    expect(theme.state, AppTheme.Green);
    expect(theme.themeMode, ThemeMode.system);
    //Navigate to PreferencePage
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.byType(PreferencePage), findsOneWidget);
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
  });

  testWidgets(
      'blue theme with dark mode is stored and the app use it when started',
      (tester) async {
    store.store.addAll({
      '__theme__': 'AppTheme.Blue#|#1',
    });
    await tester.pumpWidget(MyApp());
    //Stored theme is the AppTheme.Blue and dark model
    expect(Theme.of(RM.context).primaryColor, Colors.blue[700]);
    expect(Theme.of(RM.context).brightness, Brightness.dark);
    //
    expect(theme.state, AppTheme.Blue);
    expect(theme.themeMode, ThemeMode.dark);
    //Navigate to PreferencePage
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.nights_stay), findsOneWidget);
  });

  testWidgets('Switch default theme between dark and light mode',
      (tester) async {
    print(store);

    await tester.pumpWidget(MyApp());
    print(theme.themeMode);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    //toggle to dark
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(Theme.of(RM.context).primaryColor, Colors.green[700]);
    expect(Theme.of(RM.context).brightness, Brightness.dark);
    expect(find.byIcon(Icons.nights_stay), findsOneWidget);
    expect(theme.state, AppTheme.Green);
    expect(theme.themeMode, ThemeMode.dark);
    //toggle to light
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(Theme.of(RM.context).primaryColor, Colors.green);
    expect(Theme.of(RM.context).brightness, Brightness.light);
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    expect(theme.state, AppTheme.Green);
    expect(theme.themeMode, ThemeMode.light);
    //
    //toggle to dark
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(Theme.of(RM.context).primaryColor, Colors.green[700]);
    expect(Theme.of(RM.context).brightness, Brightness.dark);
    expect(find.byIcon(Icons.nights_stay), findsOneWidget);
    expect(theme.state, AppTheme.Green);
    expect(theme.themeMode, ThemeMode.dark);
    //use system theme
    await tester.tap(find.byType(OutlineButton));
    await tester.pumpAndSettle();
    expect(Theme.of(RM.context).primaryColor, Colors.green);
    expect(Theme.of(RM.context).brightness, Brightness.light);
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    expect(theme.state, AppTheme.Green);
    expect(theme.themeMode, ThemeMode.system);
  });

  testWidgets('use the blue theme and switch between dark and light mode',
      (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    //
    await tester.tap(find.byKey(Key('BlueThemeListTile')));
    await tester.pumpAndSettle();
    expect(Theme.of(RM.context).primaryColor, Colors.blue);

    //toggle to dark
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(Theme.of(RM.context).primaryColor, Colors.blue[700]);
    expect(Theme.of(RM.context).brightness, Brightness.dark);
    expect(find.byIcon(Icons.nights_stay), findsOneWidget);
    expect(theme.state, AppTheme.Blue);
    expect(theme.themeMode, ThemeMode.dark);
    //toggle to light
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(Theme.of(RM.context).primaryColor, Colors.blue);
    expect(Theme.of(RM.context).brightness, Brightness.light);
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    expect(theme.state, AppTheme.Blue);
    expect(theme.themeMode, ThemeMode.light);
    //
    //toggle to dark
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(Theme.of(RM.context).primaryColor, Colors.blue[700]);
    expect(Theme.of(RM.context).brightness, Brightness.dark);
    expect(find.byIcon(Icons.nights_stay), findsOneWidget);
    expect(theme.state, AppTheme.Blue);
    expect(theme.themeMode, ThemeMode.dark);
    //use system theme
    await tester.tap(find.byType(OutlineButton));
    await tester.pumpAndSettle();
    expect(Theme.of(RM.context).primaryColor, Colors.blue);
    expect(Theme.of(RM.context).brightness, Brightness.light);
    expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
    expect(theme.state, AppTheme.Blue);
    expect(theme.themeMode, ThemeMode.system);
  });
}
