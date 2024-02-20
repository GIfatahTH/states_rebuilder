import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  runApp(const MyApp());
}

class AppLocalizations {
  late final Map<String, String> _localizedStrings;

  AppLocalizations(Map<String, String> localizedStrings)
      : _localizedStrings = localizedStrings;

  String translate(String key) {
    assert(_localizedStrings.containsKey(key));
    return _localizedStrings[key]!;
  }

  static Future<AppLocalizations> load(String languageCode) async {
    // Add some artifact waiting time
    await Future.delayed(const Duration(milliseconds: 500));
    String jsonString = await rootBundle.loadString('lan/$languageCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    final localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return AppLocalizations(localizedStrings);
  }
}

final i18nRM = RM.injectI18N<AppLocalizations>(
  {
    const Locale('en'): () => AppLocalizations.load('en'),
    const Locale('ar'): () => AppLocalizations.load('ar'),
  },
  sideEffects: SideEffects.onData(
    (data) => RM.scaffold.showSnackBar(
      SnackBar(
        content: Text(data.translate('hello_world')),
      ),
    ),
  ),
);

class MyApp extends TopStatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget? splashScreen() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: i18nRM.locale,
      localeResolutionCallback: i18nRM.localeResolutionCallback,
      localizationsDelegates: i18nRM.localizationsDelegates,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(), // Notice const,
    );
  }
}

class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  static final unselectedStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.blue,
  );
  @override
  Widget build(BuildContext context) {
    final _i18n = i18nRM.of(context);
    final textStyle = Theme.of(context).textTheme.headline4;
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.translate('hello_world')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => i18nRM.locale = const Locale('en'),
                  child: const Text('English'),
                  style: i18nRM.locale is! SystemLocale &&
                          i18nRM.locale == const Locale('en')
                      ? null
                      : unselectedStyle,
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => i18nRM.locale = const Locale('ar'),
                  child: const Text('arabic'),
                  style: i18nRM.locale is! SystemLocale &&
                          i18nRM.locale == const Locale('ar')
                      ? null
                      : unselectedStyle,
                ),
                const SizedBox(width: 12),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => i18nRM.locale = SystemLocale(),
                  child: const Text('system'),
                  style: i18nRM.locale is SystemLocale ? null : unselectedStyle,
                ),
              ],
            ),
            const Spacer(),
            Text(
              _i18n.translate('message'),
              style: textStyle,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
