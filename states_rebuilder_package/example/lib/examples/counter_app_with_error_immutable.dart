import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

Future<void> asyncMethod() async {
//Simulating async task to persist the new counter value
  await Future<void>.delayed(const Duration(seconds: 1), () {
    //Simulating error (50% chance of error);
    final bool isError = Random().nextBool();

    if (isError) {
      throw Exception('A fake network Error');
    }
  });
}

@immutable
class CounterState {
  final int count;

  CounterState(this.count);

  Future<CounterState> fetchCounter() async {
    await Future.delayed(Duration(seconds: 3));
    return CounterState(10);
  }

  Stream<CounterState> increment() async* {
    //yield the new CounterState
    yield CounterState(count + 1);
    try {
      await asyncMethod();
    } catch (e) {
      //on error yield the old CounterState
      yield this;
      //You have to rethrow the error.
      rethrow;
    }
  }

  void dispose() {
    print('dispose');
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RM.debugPrintActiveRM = true;
    return Injector(
      inject: [Inject<CounterState>(() => CounterState(0))],
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
              RM.get<CounterState>()
                ..stream(
                  (counterState) => counterState.increment(),
                ).onError((context, error) {
                  print(context);
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${error.message}'),
                    ),
                  );
                });
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
          WhenRebuilderOr<CounterState>(
            observe: () => RM.get<CounterState>().asNew('dd')
              ..future((s) => s.fetchCounter()),
            onWaiting: () => CircularProgressIndicator(),
            builder: (BuildContext context, counterModel) {
              return StateBuilder<CounterState>(
                observe: () => RM.get<CounterState>(),
                builder: (context, counterModel) {
                  return Text(
                    '${counterModel.value.count}',
                    style: const TextStyle(fontSize: 50),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
