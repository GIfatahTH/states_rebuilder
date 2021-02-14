import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'main.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(primarySwatch: config.state.color),
      child: Scaffold(
        appBar: AppBar(
          title: Text(config.state.appName),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              //Subscribing to the counterRM using StateBuilder
              On.all(
                onIdle: () => Text('Tap on the FAB to increment the counter'),
                onWaiting: () => CircularProgressIndicator(),
                onError: (error, refresh) => Text(counterStore.error.message),
                onData: () => Text(
                  '${counterStore.state.count}',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ).listenTo(counterStore),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            //set the state of the counter and notify observer widgets to rebuild.
            counterStore.setState((s) => s.increment());
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
