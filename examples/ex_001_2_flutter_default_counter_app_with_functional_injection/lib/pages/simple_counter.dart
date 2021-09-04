import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//counter is a global variable but the state of the counter is not.
//It can be easily mocked and tested.
final Injected<int> counter = RM.inject<int>(
  () => 0,
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
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            counter.state++;
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
