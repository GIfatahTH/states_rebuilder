import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Example of state persistance SharedPreferences.
*
* In this example a future state is persisted. Once the state is persisted, the 
* future will not called again when the app starts.
*
* To recall the future and update the state, we use the refresh method.
*/

class SharedPreferencesImp implements IPersistStore {
  late SharedPreferences _sharedPreferences;

  @override
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Object? read(String key) {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<void> write<T>(String key, T value) async {
    await _sharedPreferences.setString(key, value as String);
  }

  @override
  Future<void> delete(String key) async {
    await _sharedPreferences.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    await _sharedPreferences.clear();
  }
}

// when the state is first initialized the future is called. Once the state is
// persisted the future won't be called again until the state is refreshed
final counterRM = RM.injectFuture<int>(
  () => Future.delayed(
    const Duration(seconds: 1),
    () => Random().nextInt(1000),
  ),
  persist: () => PersistState(
    key: 'counter',
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RM.storageInitializer(SharedPreferencesImp());
  // RM.deleteAllPersistState();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHome(),
    );
  }
}

class MyHome extends ReactiveStatelessWidget {
  const MyHome({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter view'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            if (counterRM.isWaiting)
              const CircularProgressIndicator()
            else
              Text(
                '${counterRM.state}',
                style: Theme.of(context).textTheme.headline4,
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Refresh the state and recall the future
        onPressed: counterRM.refresh,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
