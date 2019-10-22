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
      builder: (context, __) {
        final futureSnap = Injector.getAsModel<bool>(context: context).snapshot;
        final counter = Injector.getAsModel<Counter>();
        return Scaffold(
          appBar: futureSnap.data == false
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
            onPressed: () => counter.setState((state) => state.increment1()),
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final streamSnap = Injector.getAsModel<int>(context: context).snapshot;
    final counter = Injector.getAsModel<Counter>(context: context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Counter incremented by the Stream"),
          Text(streamSnap.hasData
              ? "${streamSnap.data}"
              : "waiting for data ..."),
          Text("You have pushed this many times"),
          Text(counter.state.count.toString()),
          counter.snapshot.connectionState == ConnectionState.waiting
              ? CircularProgressIndicator()
              : RaisedButton(
                  child: Text("increment"),
                  onPressed: () =>
                      counter.setState((state) => state.increment2()))
        ],
      ),
    );
  }
}
