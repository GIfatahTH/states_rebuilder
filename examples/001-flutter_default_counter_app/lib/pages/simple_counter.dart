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
            StateBuilder<int>(
                //Create a local ReactiveModel and subscribing to it using StateBuilder
                observe: () => RM.create(0),
                //link this StateBuilder with key
                rmKey: counterRMKey,
                builder: (context, counterRM) {
                  //The builder exposes the BuildContext and the created instance of ReactiveModel
                  print('build : is building');
                  return Text(
                    //get the current value of the counter
                    '${counterRM.value}',
                    style: Theme.of(context).textTheme.headline,
                  );
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //counterRMKey is used to control the counter ReactiveModel from outside the widget where it is created
          //set the value of the counter and notify observer widgets to rebuild.
          counterRMKey.setValue(
            () => counterRMKey.value + 1,
            //onSetState callback is invoked after counterRM emits a notification and before rebuild
            onSetState: (context) {
              print('onSetState : before rebuild');
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('${counterRMKey.value}'),
                  ),
                );
            },
            //onRebuildState is called after rebuilding the observer widget
            onRebuildState: (context) {
              print('onRebuildState : after rebuild');
            },
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
