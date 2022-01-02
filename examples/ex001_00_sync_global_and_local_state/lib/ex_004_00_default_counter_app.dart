import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
/*
* The use of ObBuilder widget
*/

final counter = RM.inject(() => 0);

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

// You can use simple StatelessWidget
class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  void _incrementCounter() {
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
            // Use of ObBuilder listener widget.
            // OnBuilder prevent child state from subscribing to parent
            // ReactiveStatelessWidget
            OnBuilder(
              listenTo: counter,
              builder: () {
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
