import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  int _count = 0;
  List<int> count = [];

  increment() async {
    //Simulating async task
    await Future.delayed(Duration(seconds: 1));
    _count++;
    count.add(_count);
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject<Counter>(() => Counter())],
      builder: (context, __) {
        final counterModel = Injector.getAsModel<Counter>();
        return Scaffold(
          appBar: AppBar(
            title: Text(" Counter App with refresh indicator"),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counterModel.setState(
              (state) => state.increment(),
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
    final counterModel = Injector.getAsModel<Counter>(context: context);
    return Center(
      child: RefreshIndicator(
        onRefresh: () async {
          await counterModel.setState((state) => state.increment());
        },
        child: ListView(
          children: <Widget>[
            Text("pull down to refresh the list"),
            for (final count in counterModel.state.count)
              Text(
                "$count",
                style: TextStyle(fontSize: 50),
              ),
          ],
        ),
      ),
    );
  }
}
