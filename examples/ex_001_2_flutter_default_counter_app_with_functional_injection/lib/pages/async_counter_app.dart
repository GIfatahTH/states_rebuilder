import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//counter is a global variable but the state of the counter is not.
//It can be easily mocked and tested.
final Injected<int> counter = RM.inject<int>(
  () => 0,
  //Here we defined a global Side effect handling
  //Notice that setState has sideEffects parameter.
  //
  //You can override this global side effect when calling setState
  sideEffects: SideEffects.onOrElse(
      onData: (_) {
        //show snackBar
        //any current snackBar is hidden.
        RM.scaffold.showSnackBar(
          SnackBar(
            content: Text('${counter.state}'),
          ),
        );
      },
      onWaiting: () {
        //show snackBar
        //any current snackBar is hidden.
        RM.scaffold.showSnackBar(
          SnackBar(
            content: Text('Waiting ...'),
          ),
        );
      },
      orElse: (_) {}),

  middleSnapState: (middleSnap) {
    middleSnap.print();
  },
);

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
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
            //Subscribing to the counterRM using On.all
            OnReactive(
              () => counter.onAll(
                onIdle: () => Text('Tap on the FAB to increment the counter'),
                onWaiting: () => CircularProgressIndicator(),
                onError: (error, refresh) => Text(counter.error.message),
                onData: (data) => Text(
                  '$data',
                  style: Theme.of(context).textTheme.headline5,
                ),
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
            sideEffects: SideEffects.onAll(
              onData: (_) {
                RM.scaffold.hideCurrentSnackBar();
                print('OnData from setState');
              },
              onError: (error, refresh) {
                RM.scaffold.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Text('${error.message}'),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            refresh();
                            RM.scaffold.hideCurrentSnackBar();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              onWaiting: null,
            ),
            //You can override the global side effects
            //Default to false
            shouldOverrideDefaultSideEffects: (snap) => true,
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
