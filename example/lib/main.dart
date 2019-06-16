import 'package:flutter/material.dart';

import './tutorial_1/main.dart' as tutorial1;
import './tutorial_2/main.dart' as tutorial2;
import './state_with_mixin_builder.dart/main.dart' as stateWithMixin;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'States Rebuilder ',
      home: Scaffold(
        appBar: AppBar(
          title: Text("States Rebuilder demo"),
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  goto(Widget page, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Text("Tutorial 1: Basic use of StateBuilder and Injector"),
            onPressed: () => goto(tutorial1.App(), context),
          ),
          RaisedButton(
            child: Text("Tutorial 2: Basic Use of Streaming"),
            onPressed: () => goto(tutorial2.App(), context),
          ),
          RaisedButton(
            child: Text("StateWithMixinBuilder examples"),
            onPressed: () => goto(stateWithMixin.MyApp(), context),
          ),
        ],
      ),
    );
  }
}
