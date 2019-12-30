import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  int _count = 0;
  int get count => _count;
  Future<void> increment() async {
    //Simulating async task
    await Future<void>.delayed(const Duration(seconds: 2));
    //Simulating error (50% chance of error);
    final bool isError = Random().nextBool();

    if (isError) {
      throw Exception('A fake network Error');
    }
    _count++;
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (BuildContext context) {
        final ReactiveModel<Counter> counterModel =
            Injector.getAsReactive<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: const Text(' Counter App With error'),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counterModel.setState(
              (Counter state) => state.increment(),
              catchError: true, //catch the error
            ),
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterModel = Injector.getAsReactive<Counter>(context: context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          counterModel.whenConnectionState(
            onIdle: () => Text(
              'onIdle : Tap on the FAB',
              style: const TextStyle(fontSize: 30),
            ),
            onWaiting: () => Text(
              'onWaiting : be patient',
              style: const TextStyle(fontSize: 30),
            ),
            onData: (state) => Text(
              'onData : Wahoo! The counter is ${state.count}',
              style: const TextStyle(fontSize: 25),
            ),
            onError: (error) => Container(
              color: Colors.red,
              child: Text(
                'onError : HOOPS! Something wrong happens',
                style: const TextStyle(fontSize: 30),
              ),
            ),
          )
        ],
      ),
    );
  }
}
