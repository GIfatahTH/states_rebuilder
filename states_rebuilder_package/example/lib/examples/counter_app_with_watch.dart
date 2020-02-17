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
      builder: (context) {
        final counterRM = Injector.getAsReactive<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: Text(" Counter App with watch"),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counterRM.setState((state) => state.increment()),
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterRM = Injector.getAsReactive<Counter>(context: context);
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
            "${counterRM.state.count1}",
            style: TextStyle(fontSize: 50),
          ),
          if (counterRM.state.count1 > 4)
            Column(
              children: <Widget>[
                Text("your have reached the maximum"),
                Divider(),
                Text(
                    "If you tap on the left button, nothing changes, and the rebuild process is not triggered because the counter value is watched for change.\nIf you tap on the right button, the random color changes because the counter value is not watched."),
              ],
            ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text("increment and watch"),
                onPressed: () => counterRM.setState(
                    (state) => state.increment(),
                    watch: (state) => state.count1),
                // you can watch many variables : ` watch : (state) => [state.count1, state.count2]`
              ),
              RaisedButton(
                child: Text("increment without watch"),
                onPressed: () =>
                    counterRM.setState((state) => state.increment()),
              )
            ],
          )
        ],
      ),
    );
  }
}
