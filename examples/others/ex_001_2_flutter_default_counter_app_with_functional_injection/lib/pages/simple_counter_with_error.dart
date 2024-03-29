import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//counter is a global variable but the state of the counter is not.
//It can be easily mocked and tested.
//With functional injection we do not need to use RMKey.
final Injected<int> counter = RM.inject<int>(
  () => 0,
  stateInterceptor: (currentSnap, nextSnap) {
    //Multiply the state by 10
    return nextSnap.copyToHasData(nextSnap.data! * 10);
  },
  debugPrintWhenNotifiedPreMessage: 'counter',
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
            OnReactive(
              () => Text(
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
            (int counter) {
              if (Random().nextBool()) {
                throw Exception('A Counter Error');
              }
              return counter + 1;
            },
            sideEffects: SideEffects.onAll(
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
              onData: (data) {
                //show snackBar
                //any current snackBar is hidden.
                RM.scaffold.showSnackBar(
                  SnackBar(
                    content: Text('$data'),
                  ),
                );
              },
              onWaiting: null,
            ),
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
