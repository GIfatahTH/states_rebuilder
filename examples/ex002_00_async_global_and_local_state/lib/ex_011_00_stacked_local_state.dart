import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Example on how to instantiate local async state using InheritedWidget concepts.
*
* In this example both global and local state are used together.
*
* We will create a global state and override it for a particular branches of 
* the widget tree
*/

@immutable
class CounterViewModel {
  CounterViewModel(this.counterName);

  // To be called from the UI to fetch for data at initialization.
  void init() async {
    _counter.stateAsync = Future.delayed(
      const Duration(milliseconds: 2000),
      () => 1,
    );
  }

  // Used in the UI to wait until all data is available
  //
  // This is a good practice to use, namely waiting until async data are obtained before
  // rendering the data.
  late final _isViewReadyRM = RM.injectFuture<void>(
    () => Future.wait(
      [
        // Await for all states to be ready
        _counter.stateAsync,
        // add any future to wait for before rendering the data
      ],
    ),
    debugPrintWhenNotifiedPreMessage: 'isViewReady',
  );

  bool get isViewReady => _isViewReadyRM.hasData;

  final String counterName;
  late final _counter = RM.inject(
    () => 0,
    // debugPrintWhenNotifiedPreMessage: '_counter $counterName',
  );

  int get counter => _counter.state;
  void increment() {
    _counter.state++;
  }
}

// You can define one global instance of CounterViewModel
// and override it with local instances in the UI
//
// The global instance is obtained using counterViewModel.state
//
// The local instance is obtained using counterViewModel.of(context) or,
// counterViewModel(context).state
final counterViewModel = RM.inject<CounterViewModel>(
  () => CounterViewModel('1'),
);

void main() {
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
      home: const CounterView(counterId: 1),
    );
  }
}

class CounterView extends ReactiveStatelessWidget {
  const CounterView({
    Key? key,
    this.counterId = 1,
  }) : super(key: key);
  final int counterId;

  @override
  void didMountWidget(BuildContext context) {
    final _counterViewModel = counterViewModel.of(
      context,
      // If no CounterViewModel is found using InheritedWidget, then just return
      // the global instance
      defaultToGlobal: true, // Default to false
    );
    _counterViewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    // Get the local instance
    final _counterViewModel = counterViewModel(
      context,
      // If no CounterViewModel is found using InheritedWidget, then just return
      // the global instance
      defaultToGlobal: true, // Default to false
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Counter $counterId view'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            if (!_counterViewModel.state.isViewReady)
              const CircularProgressIndicator()
            else
              Text(
                '${_counterViewModel.state.counter}',
                style: Theme.of(context).textTheme.headline4,
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return counterViewModel.inherited(
                      stateOverride: () => CounterViewModel('${counterId + 1}'),
                      builder: (context) {
                        return CounterView(counterId: counterId + 1);
                      },
                    );
                  },
                ),
              ),
              child: const Text('Go to next counter'),
            ),
            const SizedBox(height: 24),
            //
            // Get the global instance
            if (_counterViewModel.state != counterViewModel.state)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'The global counter is ${counterViewModel.state.counter}',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  TextButton(
                    onPressed: counterViewModel.state.increment,
                    child: const Icon(
                      Icons.add,
                      size: 32,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _counterViewModel.state.increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
