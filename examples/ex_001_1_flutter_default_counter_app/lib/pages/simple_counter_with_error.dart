import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  //creating a ReactiveModel key from the integer value of 0.
  final RMKey<int> counterRMKey = RMKey<int>(0);

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
            StateBuilder(
                //Create a local ReactiveModel and subscribing to it using StateBuilder
                observe: () => RM.create(0),
                //link this StateBuilder with key
                rmKey: counterRMKey,
                builder: (context, counterRM) {
                  //The builder exposes the BuildContext and the created instance of ReactiveModel
                  return Text(
                    //get the current state of the counter
                    '${counterRM.state}',
                    style: Theme.of(context).textTheme.headline5,
                  );
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //set the value of the counter and notify observer widgets to rebuild.
          counterRMKey.setState(
            (int counter) {
              if (Random().nextBool()) {
                throw Exception('A Counter Error');
              }
              return counter + 1;
            },
            onError: (context, dynamic error) {
              RM.navigate.toDialog(
                AlertDialog(
                  content: Text('${error.message}'),
                ),
              );
            },
            onData: (context, int data) {
              //show snackBar
              //any current snackBar is hidden.
              RM.scaffoldShow.snackBar(
                SnackBar(
                  content: Text('$data'),
                ),
              );
            },
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
