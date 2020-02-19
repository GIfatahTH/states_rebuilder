import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'counter_service.dart';

class CounterGridPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject(() => CounterService())],
      builder: (BuildContext context) {
        final counterServiceRM =
            Injector.getAsReactive<CounterService>(context: context);
        return Scaffold(
          appBar: AppBar(title: Text('Future counter with error')),
          body: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            children: <Widget>[
              CounterApp(
                counterService: counterServiceRM,
                name: 'Counter 1',
              ),
              CounterApp(
                counterService: counterServiceRM,
                name: 'Counter 2',
              ),
              CounterApp(
                counterService: counterServiceRM,
                name: 'Counter 3',
              ),
              CounterApp(
                counterService: counterServiceRM,
                name: 'Counter 4',
              ),
            ],
          ),
        );
      },
    );
  }
}

class CounterApp extends StatelessWidget {
  const CounterApp({Key key, this.counterService, this.name}) : super(key: key);
  final ReactiveModel<CounterService> counterService;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Theme(
        data: ThemeData(
            primarySwatch:
                counterService.hasError ? Colors.red : Colors.lightBlue),
        child: Scaffold(
          appBar: AppBar(
            title: Text(name),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CounterBox(
                counterService: counterService,
                seconds: 1,
                tag: 'blueCounter',
                color: Colors.blue,
              ),
              CounterBox(
                counterService: counterService,
                seconds: 3,
                tag: 'greenCounter',
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.lightBlue,
        ),
      ),
    );
  }
}

class CounterBox extends StatelessWidget {
  CounterBox({
    this.seconds,
    this.counterService,
    this.tag,
    this.color,
  });
  final int seconds;
  final ReactiveModel<CounterService> counterService;
  final String tag;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          WhenRebuilder(
            models: [counterService],
            tag: tag,
            onIdle: () => Text('Top on the btn to increment the counter'),
            onWaiting: () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$seconds second(s) wait  '),
                CircularProgressIndicator(),
              ],
            ),
            onError: (error) => Text(
              counterService.error.message,
              style: TextStyle(color: Colors.red),
            ),
            onData: (data) => Text(
              ' ${counterService.state.counter.count}',
              style: TextStyle(fontSize: 30),
            ),
          ),
          IconButton(
            onPressed: () {
              counterService.setState(
                (state) => state.increment(seconds),
                filterTags: [tag],
                onError: (BuildContext context, dynamic error) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(counterService.error.message),
                    ),
                  );
                },
              );
            },
            icon: Icon(
              Icons.add_circle,
              color: color,
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
          color: color,
        ),
      ),
      margin: EdgeInsets.all(5),
    );
  }
}
