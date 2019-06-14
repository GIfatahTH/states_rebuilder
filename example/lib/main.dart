import 'package:flutter/material.dart';

import './states_rebuilder_basic_example/main.dart' as basicExample;
import './tutorial_1/main.dart' as tutorial1;
import './state_with_mixin_builder.dart/main.dart' as stateWithMixin;
import './rebuild_from_streams/main.dart' as streaming;

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
            child: Text("Basic examples"),
            onPressed: () => goto(basicExample.CounterTabApp(), context),
          ),
          RaisedButton(
            child: Text("StateWithMixinBuilder examples"),
            onPressed: () => goto(stateWithMixin.MyApp(), context),
          ),
          RaisedButton(
            child: Text("streaming example"),
            onPressed: () => goto(streaming.App(), context),
          ),
          RaisedButton(
            child: Text("Tutorial 1"),
            onPressed: () => goto(tutorial1.App(), context),
          ),
        ],
      ),
    );
  }
}
