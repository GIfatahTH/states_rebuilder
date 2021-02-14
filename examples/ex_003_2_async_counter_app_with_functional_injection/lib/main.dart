import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'home_page.dart';

void main() {
  //To change the route transition you can simply use:
  //RM.navigate.transitionsBuilder = Transitions.bottomToUP();
  //
  //There are four predefined and customizable transitions:
  //leftToRight, rightToLeft, upToBottom and bottomToUP.

  //For each predefined transition, you can set the Tween and
  //the curve of the position and opacity animations

  //Here we will build our transitionsBuilder
  //Similar to that in flutter docs
  RM.navigate.transitionsBuilder =
      (context, animation, secondaryAnimation, child) {
    var begin = Offset(0.0, 1.0);
    var end = Offset.zero;
    var curve = Curves.ease;

    var tween = Tween(begin: begin, end: end);
    var curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    return SlideTransition(
      position: tween.animate(curvedAnimation),
      child: child,
    );
  };
  runApp(MyApp());
}

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
  late int count;
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
