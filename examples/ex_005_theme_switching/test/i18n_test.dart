import 'package:ex_005_theme_switching/home_page.dart';
import 'package:ex_005_theme_switching/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  final store = await RM.storageInitializerMock();
  setUp(() {
    store.clear();
  });
  testWidgets('Start with the default locale', (tester) async {
    //
    await tester.pumpWidget(MyApp());
    expect(find.text('Home'), findsOneWidget);
    expect(Localizations.localeOf(RM.context).toString(), 'en_US');
    expect(find.text('Zero times'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('One time'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('2 times'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('3 times'), findsOneWidget);
  });

  testWidgets('Changue to spanish', (tester) async {
    //
    await tester.pumpWidget(MyApp());
    expect(find.text('Home'), findsOneWidget);
    expect(Localizations.localeOf(RM.context).toString(), 'en_US');
    //
    //Navigate to PreferencePage
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    //
    await tester.tap(find.byKey(Key('_ChangeLanguage_')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('es_ES'));
    await tester.pumpAndSettle();
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Página de inicio'), findsOneWidget);

    expect(find.text('Cero veces'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('Una vez'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('2 veces'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('3 veces'), findsOneWidget);
  });

  testWidgets('Changue to Arabic', (tester) async {
    //
    await tester.pumpWidget(MyApp());
    expect(find.text('Home'), findsOneWidget);
    expect(Localizations.localeOf(RM.context).toString(), 'en_US');
    expect(Directionality.of(RM.context), TextDirection.ltr);
    //
    //Navigate to PreferencePage
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    //
    await tester.tap(find.byKey(Key('_ChangeLanguage_')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ar_DZ'));
    await tester.pumpAndSettle();
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(Directionality.of(RM.context), TextDirection.rtl);

    expect(find.text('صفحة البداية'), findsOneWidget);

    expect(find.text('صفر مرة'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('مرة واحدة'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('مرتان'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('3 مرات'), findsOneWidget);
    //
    counter.state = 11;
    await tester.pump();
    expect(find.text('11 مرة'), findsOneWidget);
  });

  testWidgets('Changue to French (async)', (tester) async {
    //
    await tester.pumpWidget(MyApp());
    expect(find.text('Home'), findsOneWidget);
    expect(Localizations.localeOf(RM.context).toString(), 'en_US');
    //
    //Navigate to PreferencePage
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    //
    await tester.tap(find.byKey(Key('_ChangeLanguage_')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('fr_FR'));
    //Get language asynchroniously
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Page d\'accueil'), findsOneWidget);

    expect(find.text('Zero fois'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('Une fois'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('2 fois'), findsOneWidget);
    //
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(find.text('3 fois'), findsOneWidget);
  });

  testWidgets('Change system locale', (tester) async {
    //
    await tester.pumpWidget(MyApp());
    expect(find.text('Home'), findsOneWidget);
    expect(Localizations.localeOf(RM.context).toString(), 'en_US');
    expect(Directionality.of(RM.context), TextDirection.ltr);
    expect(find.text('Home'), findsOneWidget);
    //To spanish
    await tester.binding.setLocale('es', 'Es');
    await tester.pumpAndSettle();
    expect(Localizations.localeOf(RM.context).toString(), 'es_ES');
    expect(Directionality.of(RM.context), TextDirection.ltr);
    expect(find.text('Página de inicio'), findsOneWidget);

    //To arabic
    await tester.binding.setLocale('ar', 'DZ');
    await tester.pumpAndSettle();
    expect(Localizations.localeOf(RM.context).toString(), 'ar_DZ');
    expect(Directionality.of(RM.context), TextDirection.rtl);
    expect(find.text('صفحة البداية'), findsOneWidget);

    //To french
    await tester.binding.setLocale('fr', 'FR');
    await tester.pumpAndSettle();
    expect(Localizations.localeOf(RM.context).toString(), 'fr_FR');

    expect(find.text('Page d\'accueil'), findsOneWidget);

    expect(Directionality.of(RM.context), TextDirection.ltr);

    //To non supported locale, get the default.
    await tester.binding.setLocale('de', 'DE');
    await tester.pumpAndSettle();
    expect(Localizations.localeOf(RM.context).toString(), 'en_US');
    expect(Directionality.of(RM.context), TextDirection.ltr);
    expect(find.text('Home'), findsOneWidget);
  });
}
