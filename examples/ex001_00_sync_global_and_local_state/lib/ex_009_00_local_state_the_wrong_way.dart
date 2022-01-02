import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Example of local states supposed to not interact with local states created in 
* other route stack.
*
* This is the wrong version. see next example for the right one.
*/
void main() {
  runApp(const MyApp());
}

@immutable
class CounterViewModel {
  CounterViewModel(this.counterName);
  final String counterName;
  late final _counter = RM.inject(
    () => 0,
    debugPrintWhenNotifiedPreMessage: '_counter $counterName',
  );

  int get counter => _counter.state;
  void increment() {
    _counter.state++;
  }
}

// Create a global instance of CounterViewModel
//
// As we need more the route to have its onw CounterView instance, this will not work
//
// See the next example of the correct injection of local state
final counterViewModel = CounterViewModel('1');

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
    this.counterId = 1,
  }) : super(key: key);
  final int counterId;

  @override
  Widget build(BuildContext context) {
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
            Text(
              '${counterViewModel.counter}',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 12),
            // Pushing the next route
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return CounterView(counterId: counterId + 1);
                  },
                ),
              ),
              child: const Text('Go to next counter'),
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
