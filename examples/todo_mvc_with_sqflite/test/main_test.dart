import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todo_mvc_with_sqflite/injected.dart';
import 'package:todo_mvc_with_sqflite/main.dart';
import 'package:todo_mvc_with_sqflite/ui/pages/home_screen/extra_actions_button.dart';
import 'package:todo_mvc_with_sqflite/ui/pages/home_screen/languages.dart';

import 'fake_Sqflite_Repository.dart';

void main() async {
  final storage = await RM.storageInitializerMock();
  todos.injectCRUDMock(() => FakeSqfliteRepository([]));
  testWidgets('Toggle theme should work', (tester) async {
    await tester.pumpWidget(App());
    //App start with dart model
    expect(Theme.of(RM.context).brightness == Brightness.dark, isTrue);

    //tap on the ExtraActionsButton
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    //And tap to toggle light mode
    await tester.tap(find.byKey(Key('__toggleDarkMode__')));
    await tester.pumpAndSettle();
    //
    //Expect the themeData is persisted
    expect(storage.store['__themeData__'], '0');
    //And theme is light
    expect(Theme.of(RM.context).brightness == Brightness.light, isTrue);
    //
    //Tap to toggle theme to dark mode
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__toggleDarkMode__')));
    await tester.pumpAndSettle();
    //
    //The storage.stored themeData is updated
    expect(storage.store['__themeData__'], '1');
    //And theme is dark
    expect(Theme.of(RM.context).brightness == Brightness.dark, isTrue);
  });

  testWidgets('Change language should work', (tester) async {
    await tester.pumpWidget(App());
    //App start with english
    expect(MaterialLocalizations.of(RM.context).alertDialogLabel, 'Alert');

    //Tap on the language action button
    await tester.tap(find.byType(Languages));
    await tester.pumpAndSettle();
    //choose 'AR' language
    await tester.tap(find.text('AR'));
    await tester.pumpAndSettle();
    //ar is persisted
    expect(storage.store['__localization__'], 'ar');
    //App is in arabic
    expect(MaterialLocalizations.of(RM.context).alertDialogLabel, 'تنبيه');
    //The app bar title is in arabic
    expect(find.text('States_rebuilder مثال'), findsOneWidget);
    //
    await tester.tap(find.byType(Languages));
    await tester.pumpAndSettle();
    //tap to use system language
    await tester.tap(find.byKey(Key('__System_language__')));
    await tester.pumpAndSettle();
    //and for systemLanguage is persisted
    expect(storage.store['__localization__'], 'und');
    //App is back to system language (english).
    expect(MaterialLocalizations.of(RM.context).alertDialogLabel, 'Alert');
    //The app bar title is in english
    expect(find.text('States_rebuilder Example'), findsOneWidget);
  });
}
