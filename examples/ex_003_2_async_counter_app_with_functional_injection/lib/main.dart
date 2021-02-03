import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'home_page.dart';

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

//Injection

//Use injectFlavor which takes a map of our flavours.
final config = RM.injectFlavor(
  {
    Flavor.IncrByOne: () => IncrByOneConfig(),
    Flavor.IncrByTwo: () => IncrByTwoConfig(),
  },
  // debugPrintWhenNotifiedPreMessage: '',
);

final counterStore = RM.injectFlavor(
  {
    Flavor.IncrByOne: () => CounterStoreByOne(0),
    Flavor.IncrByTwo: () => CounterStoreByTwo(0),
  },
  //As config model have any observer, it can not be disposed automatically,
  //we have to Dispose it Manually.
  //For this example here is the appropriate place
  onDisposed: (_) => config.dispose(),
  // debugPrintWhenNotifiedPreMessage: '',
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      //set navigatorKey
      navigatorKey: RM.navigate.navigatorKey,
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
                    RM.env = Flavor.IncrByOne;
                    //Navigating to the same MyHomePage()
                    RM.navigate.to(MyHomePage());
                  },
                ),
                RaisedButton(
                  child: Text('Increment by Two flavor'),
                  onPressed: () {
                    //set the env static variable to be Flavor.IncrByOne
                    RM.env = Flavor.IncrByTwo;
                    RM.navigate.to(MyHomePage());
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
