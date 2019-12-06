import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  int count = 0;
  increment1() => count++;
  increment2() async {
    await Future.delayed(Duration(seconds: 1));
    count++;
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        Inject.stream(
          () =>
              Stream.periodic(Duration(seconds: 1), (num) => num + 1).take(10),
        ),
        Inject.future(() => Future.delayed(Duration(seconds: 5), () => true),
            initialValue: false),
        Inject(() => Counter()),
      ],
      builder: (context) {
        final futureSnap = Injector.getAsReactive<bool>(context: context);
        final counter = Injector.getAsReactive<Counter>();
        return Scaffold(
          appBar: futureSnap.state == false
              ? AppBar(
                  title: Text(" awaiting a Future"),
                  backgroundColor: Colors.red,
                )
              : AppBar(
                  title: Text("Future is completed"),
                  backgroundColor: Colors.blue,
                ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counter.setState(
              (state) => state.increment1(),
              //with osSetState you can define a callback to be executed after mutating the state.
              onSetState: (context) {
                if (counter.state.count >= 10) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text("You have reached 10 taps"),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stream = Injector.getAsReactive<int>();
    final counter = Injector.getAsReactive<Counter>(context: context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Spacer(),
          Text("Counter incremented by the Stream"),
          StateBuilder<int>(
            models: [stream],
            onSetState: (context, stream) {
              print('onSetState counter = ${stream.state}');
            },
            onRebuildState: (context, stream) {
              print('onRebuildState counter = ${stream.snapshot.data}');
            },
            builder: (_, __) {
              return Text(
                  stream.hasData ? "${stream.state}" : "waiting for data ...");
            },
          ),
          Text("You have pushed this many times"),
          Text(counter.state.count.toString()),
          counter.snapshot.connectionState == ConnectionState.waiting
              ? CircularProgressIndicator()
              : RaisedButton(
                  child: Text("increment"),
                  onPressed: () => counter.setState(
                      (state) => state.increment2(),
                      onSetState: (context) {}),
                ),
          Spacer(),
          Text("Tap on The ActionButton More the 10 time to see the SnackBar")
        ],
      ),
    );
  }
}
