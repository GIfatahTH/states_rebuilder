import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* This is similar to the last example except that the counter Text widget is extracted
* to its own widget class.
*
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

class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  static final _counter = RM.inject<int>(() => 0);

  void _incrementCounter() {
    _counter.state++;
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
          // ignore: prefer_const_literals_to_create_immutables
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            //
            // Here we extracted the counter Text to it's own widget class
            //
            // Notice wh ignore const modifier.
            // In this example, adding const modifier will prevent
            // CounterWidget from rebuild.
            //
            // TODO: Try add const modifier and notice that it is not rebuilding.
            // ignore: prefer_const_constructors
            /*const*/ CounterWidget(),
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

// Notice here that we use ordinal StatelessWidget
class CounterWidget extends StatelessWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      // Get the state
      //
      // As we consume the state here, the _counter will look up the widget tree
      // for any ReactiveStatelessWidget. The first it finds will be registered.
      //
      // In this example, as MyHomePage is a ReactiveStatelessWidget, it will be
      // registered for rebuild.
      //
      // When _counter emits a notification, MyHomePage will rebuilt and as
      // CounterWidget is a child of MyHomePage it will rebuilt provided it is
      // not instantiated with const modifier.
      //
      // For this widget to rebuild even if it is used with const modifier, this
      // widget must be ReactiveStateless
      '${MyHomePage._counter.state}',
      style: Theme.of(context).textTheme.headline4,
    );
  }
}

/*
* ReactiveStatelessWidget can register any state consumed in its child widget
* provided that the child widget is not lazily loaded as is the case with
* ListView.builder items
*
* Child widget declared with const modifier can not register to parent 
* ReactiveStatelessWidget
*/
