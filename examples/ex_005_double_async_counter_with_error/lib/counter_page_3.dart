import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'counter_service.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Future counter with error')),
      body: Injector(
        inject: [Inject(() => CounterService())],

        //Case1 of obtaining new reactive instance
        builder: (BuildContext context) {
          final counterService = RM.get<CounterService>();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CounterPage(
                counterService: counterService.asNew('counterService1'),
                seconds: 1,
              ),
              CounterPage(
                counterService: counterService.asNew('counterService2'),
                seconds: 3,
              ),
            ],
          );
        },

        // // Case2 of obtaining new reactive instance
        // builder: (BuildContext context) {
        //   return Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       StateBuilder<CounterService>(
        //         builder: (BuildContext context,
        //             ReactiveModel<CounterService> counterService) {
        //           return CounterPage(
        //             counterService: counterService,
        //             seconds: 1,
        //           );
        //         },
        //       ),
        //       StateBuilder<CounterService>(
        //         builder: (BuildContext context, counterService) {
        //           return CounterPage(
        //             counterService: counterService,
        //             seconds: 3,
        //           );
        //         },
        //       ),
        //     ],
        //   );
        // },
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  CounterPage({this.seconds, this.counterService});
  final int seconds;
  final ReactiveModel<CounterService> counterService;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          WhenRebuilder(
            observe: () => counterService,
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
              counterService.error.message,
              style: TextStyle(color: Colors.red),
            ),
            onData: (data) => Text(
              '${counterService.state.counter.count}',
              style: TextStyle(fontSize: 30),
            ),
          ),
          IconButton(
            onPressed: () {
              counterService.setState(
                (state) => state.increment(seconds),
                onError: (BuildContext context, dynamic error) {
                  RM.scaffoldShow.snackBar(
                    SnackBar(
                      content: Text(counterService.error.message),
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
