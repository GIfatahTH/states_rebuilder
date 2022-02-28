import 'dart:async';

/*
* Example of class that depends on other plugins which in turn depends on others.
*
* The first class should wait for plugging to initialize before been able to 
* instantiate objects.
*/
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Plugin1Repository {
  // Typically for plugin that need to be initialized asynchronously, we use and
  // init method that initialize the plugin and return the same object after
  // initialization.
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
  // The second plugin depends on the first plugin and should not be instantiated
  // until the first plugin is ready.
  final Plugin1Repository repository1;
  Plugin2Repository({
    required this.repository1,
  });

  // Similar to the first plugin, we use the init method
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
  // the CounterViewModel depends on plugin 2 which depends on plugin 1
  late final Plugin2Repository repository2;

  // As this class will be instantiated in the UI,
  // the init method sets the state of a helper injected state
  void init() {
    // setting the state of _isViewReady state
    _isViewReady.setState((s) async {
      // Wait for all futures that need to be resolved.
      // In the UI we will display a waiting widget while waiting for future to
      // resolved
      await Future.wait([
        () async {
          repository2 = await repository2RM.stateAsync;
        }(),
      ]);

      return true;
    });
  }

  // helper injected state used in the UI to display CircularProgressIndicator
  // while waiting for data to be ready.
  final _isViewReady = false.inj();
  late final isViewStatus = _isViewReady.onAll;

  final _counter = 0.inj();
  int get counter => _counter.state;
  late final counterStatus = _counter.onAll;
  void increment() {
    _counter.stateAsync = repository2.incrementValueBy(_counter.state);
  }
}

// Inject plugin 1
final repository1RM = RM.injectFuture<Plugin1Repository>(
  () => Plugin1Repository()
      .init(), // call init state the returns Plugin1Repository
);

// Inject plugin 2
final repository2RM = RM.injectFuture<Plugin2Repository>(
  () async {
    // await for plugin 1 to be ready
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
  void didMountWidget(context) {
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
