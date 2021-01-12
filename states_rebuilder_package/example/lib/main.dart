import 'dart:math';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  runApp(App());
}

class Model {
  int counter;

  Model(this.counter);
  //1- Synchronous

  void incrementMutable() {
    counter++;
  }

  Model incrementImmutable() {
    //immutable returns a new instance
    return Model(counter + 1);
  }

  //2- Async Future
  Future<void> futureIncrementMutable() async {
    //Pessimistic 😢: wait until future completes without error to increment
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('ERROR 😠');
    }
    counter++;
  }

  Future<Model> futureIncrementImmutable() async {
    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      throw Exception('ERROR 😠');
    }
    return Model(counter + 1);
  }

  //3- Async Stream
  Stream<void> streamIncrementMutable() async* {
    //Optimistic 😄: start incrementing and if the future completes with error
    //go back the the initial state
    final oldCounter = counter;
    print(oldCounter);
    yield counter++;

    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      yield counter = oldCounter;
      throw Exception('ERROR 😠');
    }
  }

  Stream<Model> streamIncrementImmutable() async* {
    yield Model(counter + 1);

    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      yield this;
      throw Exception('ERROR 😠');
    }
  }
}

final model = RM.inject(() => Model(0));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHome(),
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('states_rebuilder'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SetStateCanDoAll(),
              Divider(),
              PessimisticAsync(),
              Divider(),
              PessimisticAsyncOnInitState1(),
              Divider(),
              PessimisticAsyncOnInitState2(),
              Divider(),
              OptimisticAsync(),
              Divider(),
              OptimisticAsyncOnInitState(),
            ],
          ),
        ));
  }
}

class SetStateCanDoAll extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //StateBuilder is one of four observer widgets
    return model.listen(
      child: On.any(
        () => Column(
          children: [
            //get the state of the model
            Text('${model.state.counter}'),
            RaisedButton(
              child: Text('Increment (SetStateCanDoAll)'),
              onPressed: () async {
                //setState treats mutable and immutable objects equally
                model.setState(
                  //mutable state mutation
                  (currentState) => currentState.incrementMutable(),
                );
                model.setState(
                  //immutable state mutation
                  (currentState) => currentState.incrementImmutable(),
                );

                //await until the future completes
                await model.setState(
                  //await for the future to complete and notify observer with
                  //the corresponding connectionState and data
                  //future will be canceled if all observer widgets are removed from
                  //the widget tree.
                  (currentState) => currentState.futureIncrementMutable(),
                );
                //
                await model.setState(
                  (currentState) => currentState.futureIncrementImmutable(),
                );

                //await until the stream is done
                await model.setState(
                  //subscribe to the stream and notify observers.
                  //stream subscription are canceled if all observer widget are removed
                  //from the widget tree.
                  (currentState) => currentState.streamIncrementMutable(),
                );
                //
                await model.setState(
                  (currentState) => currentState.streamIncrementImmutable(),
                );
                //setState can do all; mutable, immutable, sync, async, futures or streams.
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}

class PessimisticAsync extends StatelessWidget {
  //pessimistic means we will execute an async method and wait it result.
  //While waiting, we will display a waiting screen.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        model.listen(
          onSetState: On.all(
            onIdle: () => print('Idle'),
            onWaiting: () => print('onWaiting'),
            onError: (error) => print('onError'),
            onData: () => print('onData'),
          ),
          child: On.all(
            onIdle: () => Text('The state is idle'),
            onWaiting: () => Text('Future is executing, we are waiting ....'),
            onError: (error) => Text('Future completes with error $error'),
            onData: () => Text('${model.state.counter}'),
          ),
        ),
        RaisedButton(
          child: Text('Increment (PessimisticAsync - shouldAwait)'),
          onPressed: () {
            //All other widget subscribe to the global ReactiveModel will be notified to rebuild
            model.setState(
              (currentState) => currentState.futureIncrementImmutable(),
              //will await the current future if its pending
              //before calling futureIncrementImmutable
              shouldAwait: true,
            );
          },
        )
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}

class PessimisticAsyncOnInitState1 extends StatelessWidget {
  //The async method will be call when this widget is inserted in the widget tree
  final switcher = RM.inject(() => false);
  @override
  Widget build(BuildContext context) {
    return switcher.listen(
      child: On.data(
        () => Column(
          children: [
            if (switcher.state)
              model.futureBuilder(
                future: (s, asyncS) => s.futureIncrementImmutable(),
                onSetState: On.error((err) {
                  //show a SnackBar on error
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('${model.error}')),
                  );
                }),
                onWaiting: () =>
                    Text('Future is executing, we are waiting ....'),
                onError: (error) => Text('Future completes with error $error'),
                onData: (Model data) => Text('${data.counter}'),
              )
            else
              Container(),
            RaisedButton(
              child: Text(
                  '${switcher.state ? "Dispose" : "Insert"} (PessimisticAsyncOnInitState1)'),
              onPressed: () {
                //mutate the state of the local ReactiveModel directly
                //without using setState although we can.
                //setState gives us more features that we do not need here
                switcher.toggle();
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}

class PessimisticAsyncOnInitState2 extends StatelessWidget {
  //The same as in PessimisticAsyncOnInitState but here the rebuild is locally.
  //only this widget will rebuild.
  final switcher = RM.inject(() => false);

  @override
  Widget build(BuildContext context) {
    return switcher.listen(
      child: On.data(
        () => Column(
          children: [
            if (switcher.state)
              model.futureBuilder(
                //future method exposed the current state and teh Async representation of the state
                future: (s, asyncS) => s?.futureIncrementImmutable(),
                onWaiting: () =>
                    Text('Future is executing, we are waiting ....'),
                onError: (error) => Text('Future completes with error $error'),
                onData: (Model data) => Text('${data.counter}'),
              )
            else
              Text('This widget will not affect other widgets'),
            RaisedButton(
              child: Text(
                  '${switcher.state ? "Dispose" : "Insert"} (PessimisticAsyncOnInitState2)'),
              onPressed: () {
                switcher.toggle();
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}

class OptimisticAsync extends StatelessWidget {
  //Optimistic means, we will execute an async method and instantly display its expected result.
  //When the async method fails we will  undo the change and display an error message.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        model.listen(
          child: On.or(
            onWaiting: () => Text('Future is executing, we are waiting ....'),
            or: () => Text('${model.state.counter}'),
          ),
        ),
        RaisedButton(
          child: Text('Increment (OptimisticAsync - debounceDelay)'),
          onPressed: () {
            model.setState(
              (currentState) => currentState.streamIncrementMutable(),
              //debounce setState for 1 second
              debounceDelay: 1000,
              onError: (error) {
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$error'),
                  ),
                );
              },
            );
          },
        )
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}

class OptimisticAsyncOnInitState extends StatelessWidget {
  final switcher = RM.inject(() => false);

  @override
  Widget build(BuildContext context) {
    return switcher.listen(
      child: On.data(
        () => Column(
          children: [
            if (switcher.state)
              model.streamBuilder(
                //It exposes the current state and the current StreamSubscription.
                stream: (s, subscription) => s.streamIncrementImmutable(),
                onSetState: On.error(
                  (err) {
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('${model.error}')),
                    );
                  },
                ),
                onWaiting: () => CircularProgressIndicator(),
                onError: (e) => Text('Error'),
                onData: (data) => Text('${data.counter}'),
              )
            else
              Text('This widget will not affect other widgets'),
            RaisedButton(
              child: Text(
                  '${switcher.state ? "Dispose" : "Insert"} (OptimisticAsyncOnInitState)'),
              onPressed: () {
                switcher.toggle();
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
