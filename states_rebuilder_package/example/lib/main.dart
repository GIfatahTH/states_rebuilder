import 'package:flutter/material.dart';

import './examples/counter_app.dart' as counterApp;
import './examples/counter_app_with_whenConnectionState.dart'
    as counterAppWithWhenConnectionState;
import './examples/counter_app_with_watch.dart' as counterAppWithWatch;
import './examples/counter_app_with_error.dart' as counterAppWithError;
import './examples/counter_app_with_error_immutable.dart'
    as counterAppWithErrorImmutable;
import './examples/counter_app_with_refresh_indicator.dart'
    as counterAppWithRefreshIndicator;
import './examples/grid_Counter_app.dart' as gridCounterApp;
import './state_with_mixin_builder/main.dart' as stateWithMixin;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
            child: Text("Example 1: Counter app"),
            onPressed: () => goto(counterApp.App(), context),
          ),
          RaisedButton(
            child: Text("Example 2: Counter app with whenConnectionState"),
            onPressed: () =>
                goto(counterAppWithWhenConnectionState.App(), context),
          ),
          RaisedButton(
            child: Text("Example 3: Counter app with [error] (mutable state)"),
            onPressed: () => goto(counterAppWithError.App(), context),
          ),
          RaisedButton(
            child:
                Text("Example 4: Counter app with [error] (Immutable state)"),
            onPressed: () => goto(counterAppWithErrorImmutable.App(), context),
          ),
          RaisedButton(
            child: Text("Example 5: Counter app with [RefreshIndicator]"),
            onPressed: () =>
                goto(counterAppWithRefreshIndicator.App(), context),
          ),
          RaisedButton(
            child: Text("Example 6: Counter app with [watch]"),
            onPressed: () => goto(counterAppWithWatch.App(), context),
          ),
          RaisedButton(
            child: Text("Example 7: Grid Counter app"),
            onPressed: () => goto(gridCounterApp.App(), context),
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
