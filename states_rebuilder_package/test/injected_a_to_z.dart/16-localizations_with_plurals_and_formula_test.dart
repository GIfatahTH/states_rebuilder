import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

abstract class I18n {
  final counter_app = 'Counter app';

  //use a function to return the desired string
  String you_have_pushed_the_button_$num_times(int num) =>
      'You have pushed the button $num time${_plural(num)}';

  //helper method that returns "s" when the number is greater than 1.
  //The english rule is simple.
  String _plural(int num) => num < 2 ? '' : 's';
}

class En_US extends I18n {}

class Ar_DZ extends I18n {
  final counter_app = 'تطبيق العداد';

  //Arabic plural rule is more complex
  String you_have_pushed_the_button_$num_times(int num) {
    if (num < 2) {
      return 'لقد قمت بالضغط على الزر $num مرة';
    }
    if (num < 3) {
      return 'لقد قمت بالضغط على الزر $num مرتان';
    }
    if (num < 11) {
      return 'لقد قمت بالضغط على الزر $num مرات';
    }
    // > 11
    return 'لقد قمت بالضغط على الزر $num مرة';
  }
}

final Map<Locale, I18n> supportedLocalesMap = {
  Locale('en', 'US'): En_US(),
  Locale('ar', 'DZ'): Ar_DZ(),
};

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

final Injected<I18n> i18n = RM.inject<I18n>(
  () {
    //returning an instance of I18n
    for (final localeEntry in supportedLocalesMap.entries) {
      if (localeEntry.key == currentLocale.state) {
        return localeEntry.value;
      }
    }

    for (final localeEntry in supportedLocalesMap.entries) {
      if (localeEntry.key.languageCode == currentLocale.state.languageCode) {
        return localeEntry.value;
      }
    }
    return En_US();
  },
  dependsOn: DependsOn({currentLocale}),
);

final counter = RM.inject(() => 0);

// The ui
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
        // if (i18n.isWaiting) {
        //   return Directionality(
        //     textDirection: TextDirection.ltr,
        //     child: Text('Getting the json String ...'),
        //   );
        // }
        return MaterialApp(
          locale: currentLocale.state,
          // List all of the app's supported locales here
          supportedLocales: supportedLocalesMap.keys.toList(),
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
                  Text(i18n.state.counter_app),
                  On.data(
                    () => Text(
                      i18n.state.you_have_pushed_the_button_$num_times(
                        counter.state,
                      ),
                    ),
                  ).listenTo(counter),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

void main() {
  setUp(() {
    _localeFromTheApp = null;
    _storedLocale = null;
  });

  testWidgets('No stored locale, use the system locale (en_US)',
      (tester) async {
    await tester.pumpWidget(LocalizationsApp());
    expect(_localeFromTheApp, Locale('en', 'US'));
    expect(find.text('Counter app'), findsOneWidget);
    expect(find.text('You have pushed the button 0 time'), findsOneWidget);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('You have pushed the button 1 time'), findsOneWidget);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('You have pushed the button 2 times'), findsOneWidget);
  });

  testWidgets('stored locale is arabic', (tester) async {
    _storedLocale = Locale('ar', 'DZ');
    await tester.pumpWidget(LocalizationsApp());
    expect(_localeFromTheApp, Locale('ar', 'DZ'));
    expect(find.text('تطبيق العداد'), findsOneWidget);
    expect(find.text('لقد قمت بالضغط على الزر 0 مرة'), findsOneWidget);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('لقد قمت بالضغط على الزر 1 مرة'), findsOneWidget);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('لقد قمت بالضغط على الزر 2 مرتان'), findsOneWidget);
    counter.state++;
    await tester.pump();
    expect(find.text('لقد قمت بالضغط على الزر 3 مرات'), findsOneWidget);

    counter.state = 11;
    await tester.pump();
    expect(find.text('لقد قمت بالضغط على الزر 11 مرة'), findsOneWidget);
  });
}
