import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// Our state is type ReactiveModel<int>
final counter = 0.inj();

// Rebuild optimization
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

// In this example, we can use ordinary StatelessWidget
class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  void _incrementCounter() {
    // increment the state of the counter and emit nonfiction to listeners
    counter.state++;
  }

  @override
  Widget build(BuildContext context) {
    // App print statement to track rebuild
    // In this example and even if the MyHomePage is ReactiveStatelessWidget,
    // the scaffold will not rebuild
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
            // By wrapping the Text widget with OnReactive, the _counter state
            // will register the OnReactive to rebuild and not the MyHomePage.
            OnReactive(
              () {
                return Text(
                  '${counter.state}',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
            // You can extract the Text widget to its own widget that
            // extends the ReactiveStatelessWidget
            // TODO comment the OnReactive widget and uncomment the next line
            // const CounterWidget(),
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

// Here we use ReactiveStatelessWidget
// Even if the CounterWidget is used with const modifier, it will rebuild
class CounterWidget extends ReactiveStatelessWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '${counter.state}',
      style: Theme.of(context).textTheme.headline4,
    );
  }
}


// state when the widget is building, will look up the widget tree for the nearest 
// ReactiveStateless widget to resister it.