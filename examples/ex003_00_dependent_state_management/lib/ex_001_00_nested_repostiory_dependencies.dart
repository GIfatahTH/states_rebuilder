import 'dart:async';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Plugin1Repository {
  Future<Plugin1Repository> init() async {
    await Future.delayed(const Duration(seconds: 1));
    return this;
  }

  Future<int> getStoredValue() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 10;
  }
}

class Plugin2Repository {
  final Plugin1Repository repository1;
  Plugin2Repository({
    required this.repository1,
  });

  Future<Plugin2Repository> init() async {
    await Future.delayed(const Duration(seconds: 1));
    return this;
  }

  Future<int> incrementValueBy(int value) async {
    final by = await repository1.getStoredValue();
    await Future.delayed(const Duration(milliseconds: 200));
    return value + by;
  }
}

class CounterViewModel {
  late final Plugin2Repository repository2;

  void init() {
    _isViewReady.setState((s) async {
      await Future.wait([
        () async {
          repository2 = await repository2RM.stateAsync;
        }(),
      ]);

      return true;
    });
  }

  final _isViewReady = false.inj();
  late final isViewStatus = _isViewReady.onAll;

  final _counter = 0.inj();
  int get counter => _counter.state;
  late final counterStatus = _counter.onAll;
  void increment() {
    _counter.stateAsync = repository2.incrementValueBy(_counter.state);
  }
}

final repository1RM = RM.injectFuture(
  () => Plugin1Repository().init(),
);

final repository2RM = RM.injectFuture(
  () async {
    final repo1 = await repository1RM.stateAsync;
    return Plugin2Repository(repository1: repo1).init();
  },
);

final counterViewModel = CounterViewModel();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  void didMountWidget() {
    counterViewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nested dependencies'),
      ),
      body: Center(
        child: counterViewModel.isViewStatus(
          onWaiting: () => const CircularProgressIndicator(),
          onError: (err, refresh) => Text('$err'),
          onData: (_) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              counterViewModel.counterStatus(
                onWaiting: () => const CircularProgressIndicator(),
                onError: (err, refresh) => Text('$err'),
                onData: (_) => Text(
                  '${counterViewModel.counter}',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => counterViewModel.increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
