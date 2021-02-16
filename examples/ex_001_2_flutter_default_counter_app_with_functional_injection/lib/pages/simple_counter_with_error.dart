import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//counter is a global variable but the state of the counter is not.
//It can be easily mocked and tested.
//With functional injection we do not need to use RMKey.
final Injected<int> counter = RM.inject<int>(
  () => 0,
  middleSnapState: (snapState, nextSnapState) {
    SnapState.log(
      snapState,
      nextSnapState,
      //you can see the print log and select an error to stop and debug.
      debugWhen: (err) => err.message == 'A Counter Error',
    ).print();
    if (nextSnapState.hasData) {
      //Multiply the state by 10
      return nextSnapState.copyToHasData(nextSnapState.data! * 10);
    }
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
            //subscribe to counter injected model
            On(
              () => Text(
                '${counter.state}',
                style: Theme.of(context).textTheme.headline5,
              ),
            ).listenTo(counter),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //set the value of the counter and notify observer widgets to rebuild.
          counter.setState(
            (int counter) {
              if (Random().nextBool()) {
                throw Exception('A Counter Error');
              }
              return counter + 1;
            },
            onSetState: On.or(
              onError: (dynamic error, void Function() refresh) {
                RM.navigate.toDialog(
                  AlertDialog(
                    content: Row(
                      children: [
                        Text('${error.message}'),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            refresh();
                            RM.navigate.back();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              onData: () {
                //show snackBar
                //any current snackBar is hidden.
                RM.scaffold.showSnackBar(
                  SnackBar(
                    content: Text('${counter.state}'),
                  ),
                );
              },
              or: () {},
            ),
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
