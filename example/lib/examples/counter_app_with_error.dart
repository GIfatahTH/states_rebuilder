import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  int _count = 0;
  int get count => _count;
  increment() async {
    //Simulating async task
    await Future.delayed(Duration(seconds: 1));
    //Simulating error (50% chance of error);
    bool isError = Random().nextBool();

    if (isError) {
      throw Exception("A fake network Error");
    }
    _count++;
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
            title: Text(" Counter App With error"),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => counterModel.setState(
              (state) => state.increment(),
              catchError: true, //catch the error
              onSetState: (context) {
                // osSetState will be executed after mutating the state.
                if (counterModel.hasError) {
                  showDialog(
                    context: context,
                    child: AlertDialog(
                      title: Text("Error!"),
                      content: Text("${counterModel.error}"),
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
    final counterModel = Injector.getAsModel<Counter>(context: context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("You have 50% chance of error"),
          Builder(
            builder: (context) {
              if (counterModel.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              return Text(
                "${counterModel.state.count}",
                style: TextStyle(fontSize: 50),
              );
            },
          ),
        ],
      ),
    );
  }
}
