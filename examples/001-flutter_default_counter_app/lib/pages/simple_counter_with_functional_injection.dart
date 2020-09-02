import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//counter is a global variable but the state of the counter is not.
//It can be easily mocked and tested.
//With functional injection we do not need to use RMKey.
final Injected<int> counter = RM.inject<int>(() => 0);

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
            counter.rebuilder(
              () => Text(
                '${counter.state}',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            //We can use StateBuilder instead
            // StateBuilder(
            //   observe: () => counter.getRM,
            //   builder: (context, counterRM) => Text(
            //     '${counter.state}',
            //     style: Theme.of(context).textTheme.headline5,
            //   ),
            // )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counter.setState(
            (counter) => counter + 1,
            //onSetState callback is invoked after counterRM emits a notification and before rebuild
            onSetState: (context) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('${counter.state}'),
                  ),
                );
            },
            //onRebuildState is called after rebuilding the observer widget
            onRebuildState: (context) {
              //
            },
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
