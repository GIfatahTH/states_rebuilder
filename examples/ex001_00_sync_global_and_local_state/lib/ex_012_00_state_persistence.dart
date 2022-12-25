import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Example of state persistence SharedPreferences
* 
* The state to persist is a simple integer
*/

// We have to implement the IPersistStore
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

@immutable
class CounterViewModel {
  CounterViewModel();
  final _counter = RM.inject<int>(
    () => 0,
    persist: () => PersistState(
      key: 'counter',
      // For primitives, (int, double, String, bool), fromJson and toJson can be skipped
      //
      // TODO: uncomment the next line
      // throttleDelay: 1000,
    ),
  );

  int get counter => _counter.state;
  void clearPersistedState() {
    // this will delete the persisted state without state mutation
    _counter.deletePersistState();
  }

  void refreshTheState() {
    // This will delete the persisted state and mutate the state
    _counter.refresh();
  }

  void increment() {
    _counter.state++;
  }
}

final counterViewModel = CounterViewModel();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the local store provider
  //
  // See the test folder to see how it is mocked
  await RM.storageInitializer(SharedPreferencesImp());
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
      home: const CounterView(),
    );
  }
}

class CounterView extends ReactiveStatelessWidget {
  const CounterView({
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
            Text(
              '${counterViewModel.counter}',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              // Press and restart the app
              onPressed: counterViewModel.clearPersistedState,
              // TODO uncomment the next line
              // onPressed: counterViewModel.refreshTheState,
              child: const Text('Clear persisted State'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counterViewModel.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
