import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
/*
* Illustrates the use of OnReactive to limit the part of the widget to rebuild
*/

final counter = 0.inj();

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

// In this example, we can use an ordinary StatelessWidget
class MyHomePage extends StatelessWidget {
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
            // will register the OnReactive to be rebuilt, and not
            // the entire MyHomePage.
            OnReactive(
              () {
                return Text(
                  '${counter.state}',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
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

/*
* state when the widget is building, will look up the widget tree for the nearest 
* ReactiveStateless widget to resister it.
*/ 
