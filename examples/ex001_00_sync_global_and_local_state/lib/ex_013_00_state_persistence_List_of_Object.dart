import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Example of state persistence using Hive
* The state to persist is a list of Objects
*/

// Implement IPersistStore interface
class HiveImp implements IPersistStore {
  late Box box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox('myBox');
  }

  @override
  String? read(String key) {
    return box.get(key);
  }

  @override
  Future<void> write<T>(String key, T value) async {
    await box.put(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await box.delete(key);
  }

  @override
  Future<void> deleteAll() async {
    await box.clear();
  }
}

class CounterModel {
  final int value;
  CounterModel(this.value);

  Map<String, dynamic> toMap() {
    return {
      'value': value,
    };
  }

  factory CounterModel.fromMap(Map<String, dynamic> map) {
    return CounterModel(
      map['value']?.toInt() ?? 0,
    );
  }

  factory CounterModel.fromJson(String source) =>
      CounterModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  // Two static methods to parse a list of CounterModel
  static List<CounterModel> fromListJson(String source) {
    final List result = json.decode(source) as List;
    return result.map((e) => CounterModel.fromJson(e)).toList();
  }

  static String toListJson(List<CounterModel> counters) {
    final List result = counters.map((e) => e.toJson()).toList();
    return json.encode(result);
  }
}

@immutable
class CounterViewModel {
  CounterViewModel();
  final _counter = RM.inject<List<CounterModel>>(
    () => [],
    persist: () => PersistState(
      // Do not persist until state is disposed,
      persistOn: PersistOn.disposed,
      //
      // You can set to persist state manually by calling _counter.persistState();
      // persistOn: PersistOn.manualPersist,
      key: 'counter',
      fromJson: (source) => CounterModel.fromListJson(source),
      toJson: (state) => CounterModel.toListJson(state),
      // See console log (reading state when app starts, and writing when navigation back)
      debugPrintOperations: true,
    ),
  );
  List<CounterModel> get counters => _counter.state;
  void emptyList() => _counter.state = [];
  void persistState() {
    // Manually persist the state
    _counter.persistState();
  }

  void addCounter() {
    // set the state immutably
    _counter.state = [..._counter.state, CounterModel(0)];
  }

  void increment(int index) {
    // set the state mutably
    _counter.setState((s) {
      s[index] = CounterModel(s[index].value + 1);
    });
  }
}

final counterViewModel = CounterViewModel();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RM.storageInitializer(HiveImp());
  // RM.deleteAllPersistState();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const MyApp(),
  ));
}

class MyApp extends ReactiveStatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persisted Counters'),
      ),
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Go to counter view'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const MyHomePage();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                child: const Text('Clear all persisted states'),
                // RM.deleteAllPersistState() clear all persisted state
                onPressed: () => RM.deleteAllPersistState(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persisted Counters'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: counterViewModel.counters.asMap().keys.map(
          (index) {
            return CounterView(index: index);
          },
        ).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counterViewModel.addCounter,
        tooltip: 'Add counter',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({
    Key? key,
    required this.index,
  }) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Counter $index: ',
            style: Theme.of(context).textTheme.headline4,
          ),
          Text(
            '${counterViewModel.counters[index].value}',
            style: Theme.of(context).textTheme.headline4,
          ),
          TextButton(
            onPressed: () => counterViewModel.increment(index),
            child: const Icon(Icons.add, size: 32),
          ),
        ],
      ),
    );
  }
}
