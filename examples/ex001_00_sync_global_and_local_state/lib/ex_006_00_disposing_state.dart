import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
/*
* states even if instantiated globally, have life cycle. This is an example of
* state cleaning (disposing off)
*/

void main() {
  runApp(const MyApp());
}

@immutable
class CounterViewModel {
  // By default injected state is disposed of when no longer listened to.
  //
  // A state never listen to, never auto dispose.
  final _counter = RM.inject(
    () => 0,
    // See the console log
    debugPrintWhenNotifiedPreMessage: '_counter',
    // TODO uncomment the next line to prevent _counter from disposing of
    // autoDisposeWhenNotUsed: false,
  );
  int get counter => _counter.state;
  void increment() {
    _counter.state++;
  }

  void dispose() {
    // IF a state is set to not disposed of automatically (autoDisposeWhenNotUsed: false)
    // it is a good practice to dispose of it manually
    _counter.dispose();
    //
    // RM.disposeAll will dispose all injected state. It may be used in test
    // RM.disposeAll();
  }
}

// Although _counter is used only in a part of the app (in CounterView), it is
// considered as global state. because only one instance of it is active at any
// instant.
final counterViewModel = CounterViewModel();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to counter view'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const CounterView();
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // manually dispose a state
        onPressed: counterViewModel.dispose,
        tooltip: 'Dispose state',
        child: const Icon(Icons.clear),
      ),
    );
  }
}

class CounterView extends ReactiveStatelessWidget {
  const CounterView({Key? key}) : super(key: key);

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
