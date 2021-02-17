import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//counter is a global variable but the state of the counter is not.
//It can be easily mocked and tested.
final Injected<int> counter = RM.inject<int>(
  () => 0,
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
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            counter.setState(
              (counter) => counter + 1,
              //onSetState callback is invoked after counterRM emits a notification and before rebuild
              //context to be used to shw snackBar

              onSetState: On(() {
                //show snackBar
                //any current snackBar is hidden.

                //This call of snackBar is independent of BuildContext
                //Can be called any where
                RM.scaffold.showSnackBar(
                  SnackBar(
                    content: Text('${counter.state}'),
                  ),
                );
              }),
              //onRebuildState is called after rebuilding the observer widget
              onRebuildState: () {
                //
              },
            );
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
