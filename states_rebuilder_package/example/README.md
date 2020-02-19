# 1- Simple Counter App 
Simple counter with showing the Snackbar when the value of the counter reaches 10.
This example shows the use of:
- the getter `state`
- The method `setState`
- The parameter `onSetState`
```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//Pure dart class. No inheritance, no notification, no streams, and no code generation
class Counter {
  int count = 0;
  increment() => count++;
}
void main() => runApp(MaterialApp(home: App()));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (context) {
        final counter = Injector.getAsReactive<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: Text(" Counter App"),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counter.setState((state) => state.increment(),
            //with osSetState you can define a callback to be executed after mutating the state.
              onSetState: (context) {
                if (counter.state.count >= 10) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text("You have reached 10 taps"),
                    ),
                  );
                }
              },
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
    final counter = Injector.getAsReactive<Counter>(context: context);
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
asynchronous counter with showing `CircularProgressIndicator` while waiting for the Future to resolve.
This example shows the use of:
- the getter `connectionState`. It take the following values:   
 `ConnectionState.none`    : before executing async task.   
 `ConnectionState.waiting` : while executing async task.    
 `ConnectionState.done`    : when async task resolves.     
  Listener are notified to rebuild after each change of `connectionState`.    
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
void main() => runApp(MaterialApp(home: App()));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (context) {
        final counter = Injector.getAsReactive<Counter>();
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
    final counter = Injector.getAsReactive<Counter>(context: context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("You have pushed this many times"),
          //counter has connectionState getter.
          //`counter.connectionState` equals:
          // ConnectionState.none    : before executing async task.
          // ConnectionState.waiting : while executing async task.
          // ConnectionState.done    : when async task resolves.
          counter.connectionState == ConnectionState.waiting
              ? CircularProgressIndicator()
              : Text(counter.state.count.toString()),
        ],
      ),
    );
  }
}
```

# 3- Counter app : catching errors (show AlertDialog)
asynchronous counter with possibility of throwing an error. An alert dialog is shown with the error message.
This example shows the use of:   
- The parameter `onSetState`       
- The getter `hasError`   
- The getter `error`   
```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  int _count = 0;
  int get count => _count;
  increment() async {
    //Simulating async task
    await Future.delayed(Duration(seconds: 1));
    //Simulating error (50% chance of error);
    bool isError = Random().nextBool();

    if (isError) {
      throw Exception("A fake network Error");
    }
    _count++;
  }
}
void main() => runApp(MaterialApp(home: App()));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (context) {
        final counterModel = Injector.getAsReactive<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: Text(" Counter App"),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counterModel.setState(
              (state) => state.increment(),
              catchError: true, //catch the error
              onSetState: (context) {
                // onSetState will be executed after mutating the state.
                if (counterModel.hasError) {
                  showDialog(
                    context: context,
                    child: AlertDialog(
                      title: Text("Error!"),
                      content: Text("${counterModel.error}"),
                    ),
                  );
                }
              },
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
          Builder(
            builder: (context) {
              if (counterModel.isWaiting) {
                return CircularProgressIndicator();
              }

              return Text(
                "${counterModel.state.count}",
                style: TextStyle(fontSize: 50),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

# 4- Counter app : watching variable
Simple counter with watching the change of the count variable.
This example shows the use of:   
- The parameter `watch` 
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
void main() => runApp(MaterialApp(home: App()));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (context) {
        final counter = Injector.getAsReactive<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: Text(" Counter App"),
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
    final counter = Injector.getAsReactive<Counter>(context: context);
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
                //watch variable `count1`, if it changes update the UI, else do not update the UI.
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
# 5- Injecting Futures and Streams 
This example shows the use of:   
- The parameter `Inject.stream`  and `Inject.future` 
```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
void main() => runApp(MaterialApp(home: App()));

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
      builder: (context) {
        final futureSnap = Injector.getAsReactive<bool>(context: context).snapshot;
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
    final streamSnap = Injector.getAsReactive<int>(context: context).snapshot;
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

# 6- Creating new reactive instances and commination with reactive singleton
This example shows the use of:   
- The parameters `joinSingleton`, `JoinSingleton.withCombinedReactiveInstances`, `joinSingletonToNewData` and `notifyAllReactiveInstances`.
- Creating new reactive instances.
```dart
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterModel {
  int counter = 0;
  void increment() => counter++;
  Future<void> incrementAsync() async {
    await Future.delayed(Duration(seconds: 1));
    counter++;
  }
}

void main() => runApp(MaterialApp(home: App()));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Injector(
        inject: [
          Inject<CounterModel>(
            () => CounterModel(),
            joinSingleton: JoinSingleton.withCombinedReactiveInstances,
          )
        ],
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Center(
              child: StateBuilder<CounterModel>(
                models: [Injector.getAsReactive<CounterModel>()],
                builder: (_, model) {
                  if (model.isWaiting) {
                    return CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(
                      '${model.joinSingletonToNewData ?? "Tap on A Counter"}',
                      style: TextStyle(fontSize: 30),
                    ),
                  );
                },
              ),
            ),
          ),
          body: CounterGrid(),
        ),
      ),
    );
  }
}

class CounterGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: <Widget>[
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: <Widget>[
                for (var i = 0; i < 12; i++)
                  StateBuilder<CounterModel>(
                    builder: (context, model) {
                      return GridItem(
                        count: model.isWaiting
                            ? null
                            : model.state.counter,
                        onTap: () {
                          if (i % 2 == 0)
                            model.setState(
                              (state) => state.increment(),
                              notifyAllReactiveInstances: true,
                              joinSingletonToNewData : 'I am Counter ${i + 1} I hold ${model.state.counter}';
                            );
                          else
                            model.setState(
                              (state) => state.incrementAsync(),
                              onSetState: (context) {
                                model.joinSingletonToNewData =
                                    'I am Counter ${i + 1} I hold ${model.state.counter}';
                              },
                            );
                        },
                      );
                    },
                  ),
              ],
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
          child: count != null
              ? Text(
                  "$count",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                  ),
                )
              : CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
        ),
      ),
      onTap: onTap,
    );
  }
}
```