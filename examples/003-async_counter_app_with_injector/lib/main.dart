import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(MyApp());

enum Flavor { IncrByOne, IncrByTwo }

abstract class IConfig {
  String get appName;
  MaterialColor get color;
}

class IncrByOneConfig implements IConfig {
  @override
  String get appName => 'Increment By one Flavor';

  @override
  MaterialColor get color => Colors.blue;
}

class IncrByTwoConfig implements IConfig {
  @override
  String get appName => 'Increment By two Flavor';

  @override
  MaterialColor get color => Colors.orange;
}

abstract class ICounterStore {
  int count;
  void increment();
}

class CounterStoreByOne implements ICounterStore {
  CounterStoreByOne(this.count);

  @override
  int count;

  @override
  void increment() async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('A Counter Error');
    }
    count++;
  }
}

class CounterStoreByTwo implements ICounterStore {
  CounterStoreByTwo(this.count);

  @override
  int count;

  @override
  void increment() async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('A Counter Error');
    }
    count += 2;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: Builder(builder: (context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text('Increment by one flavor'),
                  onPressed: () {
                    //set the env static variable to be Flavor.IncrByOne
                    Injector.env = Flavor.IncrByOne;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          //Navigating to the same MyHomePage()
                          return MyHomePage();
                        },
                      ),
                    );
                  },
                ),
                RaisedButton(
                  child: Text('Increment by Two flavor'),
                  onPressed: () {
                    //set the env static variable to be Flavor.IncrByOne
                    Injector.env = Flavor.IncrByTwo;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          //Navigating to the same MyHomePage()
                          return MyHomePage();
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //Named constructor Inject.interface is used to resister with flavors
        Inject.interface(
          {
            Flavor.IncrByOne: () => IncrByOneConfig(),
            Flavor.IncrByTwo: () => IncrByTwoConfig(),
          },
        ),
        Inject.interface(
          {
            Flavor.IncrByOne: () => CounterStoreByOne(0),
            Flavor.IncrByTwo: () => CounterStoreByTwo(0),
          },
        ),
      ],
      //initState is called when the Injector is inserted in the widget tree
      initState: () => print('initState'),
      //dispose is called when the Injector is removed from the widget tree
      dispose: () => print('dispose'),
      builder: (context) {
        //getting the counterRM from the interface. The exact implementation is defined by Injector.env
        final counterRM = Injector.getAsReactive<ICounterStore>();

        //getting the config without reactivity
        final config = Injector.get<IConfig>();

        return Theme(
          data: ThemeData(primarySwatch: config.color),
          child: Scaffold(
            appBar: AppBar(
              title: Text(config.appName),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'You have pushed the button this many times:',
                  ),
                  //Subscribing to the counterRM using StateBuilder
                  WhenRebuilder<ICounterStore>(
                    models: [counterRM],
                    onIdle: () =>
                        Text('Tap on the FAB to increment the counter'),
                    onWaiting: () => CircularProgressIndicator(),
                    onError: (error) => Text(counterRM.error.message),
                    onData: (data) => Text(
                      '${data.count}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                //set the state of the counter and notify observer widgets to rebuild.
                counterRM.setState((s) => s.increment());
              },
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
