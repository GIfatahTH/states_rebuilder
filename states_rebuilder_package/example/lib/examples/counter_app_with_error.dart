import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class CounterStore {
  int _count = 0;
  int get count => _count;
  void increment() async {
    //
    _count++;
    //Simulating async task to persist the new counter value
    await Future<void>.delayed(const Duration(seconds: 1), () {
      //Simulating error (50% chance of error);
      final bool isError = Random().nextBool();

      if (isError) {
        throw Exception('A fake network Error');
      }
    }).catchError((error) {
      _count--;
      throw error;
    });
  }

  void dispose() {
    print('dispose');
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // RM.printActiveRM = true;
    return Injector(
      inject: [Inject<CounterStore>(() => CounterStore())],
      disposeModels: true,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(' Counter App With error'),
          ),
          body: MyHome(),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              //get CounterStor ReactiveModel and call setState method
              RM.get<CounterStore>().setState(
                (CounterStore state) => state.increment(),
                onError: (context, error) {
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${error.message}'),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('increment until you see an error'),
          const Text(
              'Notice that with error the counter return to the last state'),
          StateBuilder<CounterStore>(
            observe: () => RM.get<CounterStore>(),
            onRebuildState: (context, counterModel) {
              print("3- onRebuildState");
            },
            builder: (BuildContext context, counterModel) {
              print("2- build");

              if (counterModel.isWaiting) {
                return CircularProgressIndicator();
              }
              return Text(
                '${counterModel.state.count}',
                style: const TextStyle(fontSize: 50),
              );
            },
          ),
        ],
      ),
    );
  }
}
