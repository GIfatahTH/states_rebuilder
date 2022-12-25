import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Example of undo redo of immutable state
*/

void main() {
  runApp(const MyApp());
}

@immutable
class CounterViewModel {
  CounterViewModel();
  final _counter = RM.inject(
    () => 0,
    debugPrintWhenNotifiedPreMessage: '_counter',
    // Set the stack length to a value greater than 0
    undoStackLength: 5,
  );

  // Undo and redo the state mutation (state must be immutable)
  bool get canRedo => _counter.canRedoState;
  bool get canUndo => _counter.canUndoState;
  void redo() => _counter.redoState();
  void undo() => _counter.undoState();
  void clearUndoQueue() => _counter.clearUndoStack();

  int get counter => _counter.state;
  void increment() {
    _counter.state++;
  }
}

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed:
                      counterViewModel.canUndo ? counterViewModel.undo : null,
                  child: const Text('Undo'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed:
                      counterViewModel.canRedo ? counterViewModel.redo : null,
                  child: const Text('Redo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: counterViewModel.clearUndoQueue,
              child: const Text('Clear undo queue'),
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
