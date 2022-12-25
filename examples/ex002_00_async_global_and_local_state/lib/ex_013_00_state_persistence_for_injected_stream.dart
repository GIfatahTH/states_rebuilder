import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Example of stream state local persistence.
*
* The persisted state is updated each time the stream emits data.
*
* On app restart, the state is initialized from the local store. So the state 
* starts from the last persisted state and continues to update with stream data 
* emission.
*
* That is the default behavior. It can be changed using shouldRecreateTheState
* argument.
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

// CounterRM1 will persist the state. When the app restarts, this state will hold
// the last persisted state and continues to update on stream emission.
final counterRM1 = RM.injectStream<int>(
  () => Stream.periodic(
    const Duration(seconds: 5),
    (_) => Random().nextInt(1000),
  ),
  persist: () => PersistState(
    key: 'counter1',
  ),
);

// By setting shouldRecreateTheState to false, on app restart, the state will not
// trigger the stream again.
final counterRM2 = RM.injectStream<int>(
  () => Stream.periodic(
    const Duration(seconds: 5),
    (_) => Random().nextInt(1000),
  ),
  persist: () => PersistState(
    key: 'counter2',
    shouldRecreateTheState:
        false, // default to true for injectStream and false for injectFuture
  ),
  debugPrintWhenNotifiedPreMessage: '',
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
              'This is the value of Stream 1',
            ),
            if (counterRM1.isWaiting)
              const CircularProgressIndicator()
            else
              Text(
                '${counterRM1.state}',
                style: Theme.of(context).textTheme.headline4,
              ),
            const SizedBox(height: 12),
            const Text(
              'This is the value of Stream 2',
            ),
            if (counterRM2.isWaiting)
              const CircularProgressIndicator()
            else
              Text(
                '${counterRM2.state}',
                style: Theme.of(context).textTheme.headline4,
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // refresh the counterRM2 state and trigger the stream
        onPressed: counterRM2.refresh,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
