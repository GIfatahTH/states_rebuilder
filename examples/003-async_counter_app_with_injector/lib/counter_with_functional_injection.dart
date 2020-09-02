import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MyApp());

class CounterStore {
  CounterStore(this.count);
  int count;

  void increment() async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('A Counter Error');
    }
    count++;
  }
}

final counter = RM.inject(() => CounterStore(0));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _MyScaffold(),
    );
  }
}

class _MyScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyHomePage(title: 'Flutter Demo Home Page');
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            //Subscribing to the counter using WhenRebuilder
            counter.whenRebuilder(
              onIdle: () => Text('Tap on the FAB to increment the counter'),
              onWaiting: () => CircularProgressIndicator(),
              onError: (error) => Text(counter.error.message),
              onData: () => Text(
                '${counter.state.count}',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //set the state of the counter and notify observer widgets to rebuild.
          counter.setState((s) => s.increment());
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
