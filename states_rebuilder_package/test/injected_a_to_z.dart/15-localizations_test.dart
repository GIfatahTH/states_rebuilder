import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//language file model
class I18n {
  final firstString;
  final secondString;

  I18n({this.firstString, this.secondString});

  static I18n fromMap(Map<String, String> map) {
    return I18n(
      firstString: map['first_string'],
      secondString: map['second_string'],
    );
  }
}

//Injection

//Stored locale:
//The user defined locale cached using a local storage library (SharedPreferences
// for example)
//
//Here we simulate that we get the stored locale.
//When the stored locale is null, the default system locale will be used
Locale? _storedLocale;
Locale? _localeFromTheApp;

final currentLocale = RM.inject<Locale>(
  //return the stored locale or if null return the system locale
  () => _storedLocale ?? WidgetsBinding.instance!.window.locales.first,
  //Each time the currentLocale is changed, we refresh the i18n so it load the
  //right json file.
  // onData: (_) => i18n.refresh(),
);

final Injected<I18n> i18n = RM.injectFuture<I18n>(
  () async {
    //Loading language file from the assets
    // assets:
    // - lang/ar.json
    // - lang/en.json

    String jsonString = await rootBundle
        .loadString('lang/${currentLocale.state.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    //returning an instance of I18n
    return I18n.fromMap(
      jsonMap.map(
        (key, value) {
          return MapEntry(key, value.toString());
        },
      ),
    );
  },
  dependsOn: DependsOn({currentLocale}),
  debugPrintWhenNotifiedPreMessage: '',
);

//The UI

class LocalizationsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateWithMixinBuilder.widgetsBindingObserver(
      observe: () => i18n,
      didChangeLocales: (_, __) {
        //when didChangeLocales is invoked,
        //we refresh the currentLocale and the i18n
        //It is only when they change that the widget will rebuild
        currentLocale.refresh();
        i18n.refresh();
      },
      builder: (_, __) {
        if (i18n.isWaiting) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text('Getting the json String ...'),
          );
        }
        return MaterialApp(
          key: Key('${currentLocale.state}'),
          locale: currentLocale.state,
          // List all of the app's supported locales here
          supportedLocales: [
            Locale('en', 'US'),
            Locale('ar', 'DZ'),
          ],
          //In real app we use localizationsDelegates for Material and widget
          //Localizations
          //
          // localizationsDelegates: [
          //   GlobalMaterialLocalizations.delegate,
          //   GlobalWidgetsLocalizations.delegate,
          // ],
          home: Builder(
            builder: (context) {
              _localeFromTheApp = Localizations.localeOf(context);
              return Column(
                children: [
                  Text(i18n.state.firstString),
                  Text(i18n.state.secondString),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

//Testing

void main() {
  setUp(() {
    //Faking the i18n injected model
    i18n.injectFutureMock(() async {
      await Future.delayed(Duration(seconds: 1));
      if (currentLocale.state.languageCode == 'en') {
        return I18n(
          firstString: 'This is the first String',
          secondString: 'This is the second String',
        );
      } else {
        return I18n(
          firstString: 'هذه هي الجملة الأولى',
          secondString: 'هذه هي الجملة الثانية',
        );
      }
    });
    _localeFromTheApp = null;
    _storedLocale = null;
  });
  testWidgets('No stored locale, use the system locale (en_US)',
      (tester) async {
    await tester.pumpWidget(LocalizationsApp());
    expect(find.text('Getting the json String ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(_localeFromTheApp, Locale('en', 'US'));
    expect(find.text('This is the first String'), findsOneWidget);
    expect(find.text('This is the second String'), findsOneWidget);
  });

  testWidgets('stored locale is arabic', (tester) async {
    _storedLocale = Locale('ar', 'DZ');
    await tester.pumpWidget(LocalizationsApp());
    expect(find.text('Getting the json String ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(_localeFromTheApp, Locale('ar', 'DZ'));
    expect(find.text('هذه هي الجملة الأولى'), findsOneWidget);
    expect(find.text('هذه هي الجملة الثانية'), findsOneWidget);
  });

  testWidgets('Manually change the locale form (en_US) ot (ar_DZ)',
      (tester) async {
    await tester.pumpWidget(LocalizationsApp());
    expect(find.text('Getting the json String ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(_localeFromTheApp, Locale('en', 'US'));
    expect(find.text('This is the first String'), findsOneWidget);
    expect(find.text('This is the second String'), findsOneWidget);
    //

    currentLocale.state = Locale('ar', 'DZ');
    await tester.pump();
    expect(find.text('Getting the json String ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(_localeFromTheApp, Locale('ar', 'DZ'));
    expect(find.text('هذه هي الجملة الأولى'), findsOneWidget);
    expect(find.text('هذه هي الجملة الثانية'), findsOneWidget);
  });

  testWidgets('automatically change the locale form (en_US) ot (ar_DZ)',
      (tester) async {
    //To simulate that the system locale is changed, we set :

    //Holds the system locale
    Locale? _systemLocale;
    //Called by flutter when the system locale is changed
    void _didChangeLocale() {
      currentLocale.refresh();
      i18n.refresh();
    }

    //Fake the currentLocale model
    currentLocale.injectMock(
      () =>
          _storedLocale ??
          (_systemLocale ?? WidgetsBinding.instance!.window.locales.first),
    );
    await tester.pumpWidget(LocalizationsApp());
    expect(find.text('Getting the json String ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(_localeFromTheApp, Locale('en', 'US'));
    expect(find.text('This is the first String'), findsOneWidget);
    expect(find.text('This is the second String'), findsOneWidget);

    //The user has changed the system locale to ar_DZ
    _systemLocale = Locale('ar', 'DZ');
    //Flutter invokes didChangeLocales of StateWithMixinBuilder
    _didChangeLocale();
    //
    await tester.pump();
    expect(find.text('Getting the json String ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(_localeFromTheApp, Locale('ar', 'DZ'));
    expect(find.text('هذه هي الجملة الأولى'), findsOneWidget);
    expect(find.text('هذه هي الجملة الثانية'), findsOneWidget);
  });
}
