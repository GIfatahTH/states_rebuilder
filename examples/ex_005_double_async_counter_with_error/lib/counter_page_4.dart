import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'counter.dart';
import 'counter_service_immutable.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Future counter with error')),
      body: Injector(
        inject: [Inject(() => CounterState(Counter(0)))],

        //Case1 of obtaining new reactive instance
        builder: (BuildContext context) {
          final counterState = RM.get<CounterState>();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CounterPage(
                counterState: counterState.asNew('counterState1'),
                seconds: 1,
              ),
              CounterPage(
                counterState: counterState.asNew('counterState2'),
                seconds: 3,
              ),
            ],
          );
        },
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  CounterPage({this.seconds, this.counterState});
  final int seconds;
  final ReactiveModel<CounterState> counterState;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          WhenRebuilder(
            observe: () => counterState,
            onIdle: () => Text(
                'Top on the plus button to start incrementing the counter'),
            onWaiting: () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Text('$seconds second(s) wait'),
              ],
            ),
            onError: (error) => Text(
              counterState.error.message,
              style: TextStyle(color: Colors.red),
            ),
            onData: (data) => Text(
              '${counterState.state.counter.count}',
              style: TextStyle(fontSize: 30),
            ),
          ),
          IconButton(
            onPressed: () {
              counterState.setState(
                (c) => c.increment(seconds),
                context: context,
                onError: (context, error) {
                  RM.scaffoldShow.snackBar(
                    SnackBar(
                      content: Text(counterState.error.message),
                    ),
                  );
                },
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: Theme.of(context).primaryColor,
            ),
            iconSize: 40,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
      // Decoration of the Container
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).primaryColor,
        ),
      ),
      margin: EdgeInsets.all(1),
    );
  }
}
