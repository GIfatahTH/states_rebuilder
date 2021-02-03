import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//counter is a global variable but the state of the counter is not.
//It can be easily mocked and tested.
final Injected<int> counter = RM.inject<int>(
  () => 0,
  //Here we defined a global onData handling
  //Notice that setState has anData callback.
  //As for this simple example there is no difference between the two.
  //For more complicated scenarios, onData here is global and will be executed any
  //time the model has data, whereas is onData in setState is local to that call
  //of setState.
  //
  //If both are defined, the onData of setState override this global onData here
  onData: (int data) {
    //show snackBar
    //any current snackBar is hidden.
    RM.scaffoldShow.snackBar(
      SnackBar(
        content: Text('$data'),
      ),
    );
  },
  onWaiting: () {
    //show snackBar
    //any current snackBar is hidden.
    RM.scaffoldShow.snackBar(
      SnackBar(
        content: Text('Waiting ...'),
      ),
    );
  },
);

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            //Subscribing to the counterRM using StateBuilder
            counter.whenRebuilder(
              onIdle: () => Text('Tap on the FAB to increment the counter'),
              onWaiting: () => CircularProgressIndicator(),
              onError: (error) => Text(counter.error.message),
              onData: () => Text(
                '${counter.state}',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //set the value of the counter and notify observer widgets to rebuild.
          counter.setState(
            (int counter) async {
              await Future.delayed(Duration(seconds: 1));
              if (Random().nextBool()) {
                throw Exception('A Counter Error');
              }
              return counter + 1;
            },
            //This onData if defined will override the global onData
            onData: (_) {
              RM.scaffoldShow.hideCurrentSnackBar();
              print('OnData from setState');
            },
            onError: (_) {
              RM.scaffoldShow.hideCurrentSnackBar();
            },
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
