import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* This is the default flutter counter app rewritten using states_rebuilder.
*/
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// Notice we used ReactiveStatelessWidget instead of StatelessWidget.
//
// By using ReactiveStatelessWidget, the MyHomePage will automatically listen
// to any injected reactive state consumed inside MyHomePage or any of its child
// widget.

class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  // Our state is type ReactiveModel<int>
  static final _counter = 0.inj();
  // OR, for more options use:
  // static final _counter = RM.inject(() => 0);

  void _incrementCounter() {
    // increment the state of the counter and emit a notification to listeners
    _counter.state++;
    // For more options use setState
    // _counter.setState((s) => s + 1);
  }

  @override
  Widget build(BuildContext context) {
    // App print statement to track rebuild
    // In this example all the scaffold of MyHomePage is rebuilt
    print('MyHomePage is rebuilt');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              // Get the state.
              //
              // As state is consumed inside the ReactiveStatelessWidget, the
              // following will listen to _counter state to rebuild when
              // the _counter state emits a notification
              '${_counter.state}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
