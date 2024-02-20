import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  runApp(const MyApp());
}

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

class EnUs {
  final String helloWorld = 'Hello world';
  final message = 'This is a message for you';
}

class Ar implements EnUs {
  @override
  final String helloWorld = 'مرحبا بكم';
  @override
  final message = 'هذه رسالة لكم';
}

final i18nRM = RM.injectI18N<EnUs>(
  {
    const Locale('en'): () => EnUs(),
    const Locale('ar'): () => Ar(),
  },
  persistKey: '__lan__',
  sideEffects: SideEffects.onData(
    (data) => RM.scaffold.showSnackBar(
      SnackBar(
        content: Text(data.helloWorld),
      ),
    ),
  ),
);

class MyApp extends TopStatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  List<FutureOr<void>>? ensureInitialization() {
    return [RM.storageInitializer(HiveStorage())];
  }

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
        title: Text(_i18n.helloWorld),
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
              _i18n.message,
              style: textStyle,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
