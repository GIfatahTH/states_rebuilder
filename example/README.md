# 1- Simple Counter App 
```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//Pure dart class. No inheritance, no notification, no streams, and no code generation
class Counter {
  int count = 0;
  increment() => count++;
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (context, __) {
        final counter = Injector.getAsModel<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: Text(" Counter App"),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counter.setState((state) => state.increment()),
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = Injector.getAsModel<Counter>(context: context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("You have pushed this many times"),
          Text("${counter.state.count}"),
        ],
      ),
    );
  }
}
```
# 2- Counter App with Future
```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  int count = 0;
  increment() async {
    await Future.delayed(Duration(seconds: 1));
    count++;
  }
}

//The same UI as for simple Counter app
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (context, __) {
        final counter = Injector.getAsModel<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: Text(" Counter App"),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counter.setState((state) => state.increment()),
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = Injector.getAsModel<Counter>(context: context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("You have pushed this many times"),
          //counter has an internal AsyncSnapshot<Counter>.
          //it allow for checking the business of the state (while awaiting for the future).
          counter.snapshot.connectionState == ConnectionState.waiting
              ? CircularProgressIndicator()
              : Text(counter.state.count.toString()),
        ],
      ),
    );
  }
}
```
# 3- Counter app watching variable
```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

Color _color() {
  return Color.fromRGBO(
      Random().nextInt(256), Random().nextInt(256), Random().nextInt(256), 1);
}

class Counter {
  int _count1 = 0;
  int get count1 => _count1 <= 5 ? _count1 : 5;
  increment() {
    _count1++;
  }
}

//The same UI as for simple Counter app
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (context, __) {
        final counter = Injector.getAsModel<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: Text(" Counter App"),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counter.setState((state) => state.increment()),
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = Injector.getAsModel<Counter>(context: context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 50,
            color: _color(),
            child: Center(
                child: Text("Random Color. It changes with each rebuild")),
          ),
          Text(
            "${counter.state.count1}",
            style: TextStyle(fontSize: 50),
          ),
          if (counter.state.count1 > 4)
            Column(
              children: <Widget>[
                Text("your have reached the maximum"),
                Divider(),
                Text(
                    "If you tap on the left button, nothing changes, and the rebuild process is stopped because the counter value is not changed.\nIf you tap on the right button, the random color changes because the counter value is not watched."),
              ],
            ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text("increment and watch"),
                onPressed: () => counter.setState((state) => state.increment(),
                    watch: (state) => state.count1),
                // you can watch many variables : ` watch : (state) => [state.count1, state.count2]`
              ),
              RaisedButton(
                child: Text("increment without watch"),
                onPressed: () => counter.setState((state) => state.increment()),
              )
            ],
          )
        ],
      ),
    );
  }
}
```
# 4- Injecting Futures and Streams 
```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        Inject.stream(
          () => Stream<int>.periodic(Duration(seconds: 1), (num) => num)
              .take(10),
        ),
        Inject<bool>.future(
            () => Future.delayed(Duration(seconds: 5), () => true),
            initialValue: false),
      ],
      builder: (_, __) {
        final futureSnap = Injector.getAsModel<bool>(context: context).snapshot;
        return Scaffold(
          appBar: futureSnap.data == false
              ? AppBar(
                  title: Text(" awaiting a Future"),
                  backgroundColor: Colors.red,
                )
              : AppBar(
                  title: Text("Future is completed"),
                  backgroundColor: Colors.blue,
                ),
          body: MyHome(),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final streamSnap = Injector.getAsModel<int>(context: context).snapshot;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Counter From stream"),
          streamSnap.hasData
              ? Text("${streamSnap.data}")
              : Text("Waiting for data ..."),
        ],
      ),
    );
  }
}
```

# 5- Animation with StateWithMixinBuilder.
```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterModel extends StatesRebuilder {
  int counter = 0;

  AnimationController controller;
  Animation animation;

  initAnimation(TickerProvider ticker) {
    controller =
        AnimationController(duration: Duration(seconds: 2), vsync: ticker);
    animation = Tween<double>(begin: 0, end: 2 * 3.14).animate(controller);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reset();
      }
    });
  }

  VoidCallback listener;
  triggerAnimation(tagID) {
    animation.removeListener(listener);
    listener = () {
      rebuildStates([tagID]);
    };
    animation.addListener(listener);
    controller.forward();
    counter++;
  }

  dispose() {
    controller.dispose();
  }
}

class AnimateSetExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector<CounterModel>(
      models:[()=> CounterModel()],
      builder:(context,model) => CounterGrid(),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Injector.get<CounterModel>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text("Animate a set of boxes"),
          Expanded(
            child: StateWithMixinBuilder(
              mixinWith: MixinWith.singleTickerProviderStateMixin,
              initState: (_, __, ticker) => model.initAnimation(ticker),
              dispose: (_, __, ___) => model.dispose(),
              builder: (_, __) => GridView.count(
                    crossAxisCount: 3,
                    children: <Widget>[
                      for (var i = 0; i < 12; i++)
                        StateBuilder(
                          tag: i % 2,
                          viewModels: [model],
                          builder: (_, tagID) => Transform.rotate(
                                angle: model.animation.value,
                                child: GridItem(
                                  count: model.counter,
                                  onTap: () => model.triggerAnimation(i % 2),
                                ),
                              ),
                        ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final int count;
  final Function onTap;
  GridItem({this.count, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          border:
              Border.all(color: Theme.of(context).primaryColorDark, width: 4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            "$count",
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
```