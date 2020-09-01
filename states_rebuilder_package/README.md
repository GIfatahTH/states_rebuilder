# `states_rebuilder`

[![pub package](https://github.com/GIfatahTH/states_rebuilder/wiki/https://img.shields.io/pub/v/states_rebuilder.svg)](https://github.com/GIfatahTH/states_rebuilder/wiki/https://pub.dev/packages/states_rebuilder)
[![CircleCI](https://github.com/GIfatahTH/states_rebuilder/wiki/https://circleci.com/gh/GIfatahTH/states_rebuilder.svg?style=svg)](https://github.com/GIfatahTH/states_rebuilder/wiki/https://circleci.com/gh/GIfatahTH/states_rebuilder)
[![codecov](https://github.com/GIfatahTH/states_rebuilder/wiki/https://codecov.io/gh/GIfatahTH/states_rebuilder/branch/master/graph/badge.svg)](https://github.com/GIfatahTH/states_rebuilder/wiki/https://codecov.io/gh/GIfatahTH/states_rebuilder)


A Flutter state management combined with dependency injection solution that allows : 
  * A 100% separation between business logic and UI logic. You wWrite your business logic with pure dart class without depending on any external library (Flutter and states_rebuilder included).
  * Immutable and immutable state. You are free to use immutable or mutable objects or to mix them. Even you can refactor form mutability to immutability (or from immutability to mutability) without affecting the user interface code.
  * Work with futures and streams. You can change the nature of any method from synchronous to asynchronous; from returning Future to returning Stream or vice versa without changing a single line in the user interface.
  * Very rich dependency injection system. Asynchronous dependency is injected with the same ease as synchronous dependency.
  * Global functional injection for dependency injection.
  * Side effects without the `BuildContext`. Navigate and get the `ScaffoldState`without requiring the `BuildContext`.

`states_rebuilder` is built on the observer pattern for state management.

> **Intent of observer pattern**    
>Define a one-to-many dependency between objects so that when one object changes state (observable object), all its dependents (observer objects) are notified and updated automatically.

`states_rebuilder` state management solution is based on what is called the `ReactiveModel`.


Note: version 2.0.0 is marked by some breaking changes, please be aware of them. [2.0.0 update](changelog/v-2.0.0.md)

> 🚀 To see global functional injection 🚀 in action and feel how easy and efficient it is, please refer to this tutorial [Global function injection from A to Z](https://github.com/GIfatahTH/states_rebuilder/wiki/functional_injection_form_a_to_z/00-functional_injection.md)

To start using `states_rebuilder`, just start writing your business logic in a separate class.


Here is a typical class, that encapsulated, all the type of method mutation one expects to find in real-life situations.

```dart
class Model {
  int counter;

  Model(this.counter);

  //1- Synchronous mutation
  void incrementMutable() {
    counter++;
  }

  Model incrementImmutable() {
    //fields should be final,
    //immutable returns a new instance based on the current state
    return Model(counter + 1);
  }

  //2- Async mutation Future
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
    final oldState = counter;
    yield counter++;

    await Future.delayed(Duration(seconds: 1));
    if (Random().nextBool()) {
      yield counter = oldState;
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
```

The Model class is a pure dart class without any reference to any external library (even Flutter).
In the Model class we have :
* Sync mutation of state (mutable and immutable);
* Async future mutation of the state (mutable and immutable);
* Async stream mutation of the state (mutable and immutable);

Async mutation is whether :
* Pessimistic so that we must await it to complete and display an awaiting screen.
* Optimistic so that we just display what we expect from it, and execute it in the background. It is until it fails that we go back to the old state and display an error message.

states_rebuilder manage all that with the same easiness.

The next step is to inject the Model class into the widget tree.

```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return Injector(
      //Inject Model instance into the widget tree.
      inject: [Inject(() => Model(0))],
      builder: (context) {
        return MaterialApp(
          home: MyHome(),
        );
      },
    );
  }
}
```
[Get more information on Injector](https://github.com/GIfatahTH/states_rebuilder/wiki/Injector).

To get the injected model at any level of the widget tree, we use:
```dart
//get the injected instance
final Model model = IN.get<Model>(); 
//get the injected instance decorated with a ReactiveModel
final ReactiveModel<Model> modelRM =  RM.get<Model>();
```

The next step is to subscribe to the injected ReactiveModel and mutate the state and notify observers.

* subscription is done using one of the four observer widgets : `StateBuilder`, `WhenRebuilder`, `WhenRebuilderOr`, `OnSetStateListener`.
* notification is done mainly with `setState` method.

## setState can do all:
```dart
  @override
  Widget build(BuildContext context) {
    //StateBuilder is one of four observer widgets
    return StateBuilder<Model>(
      //get the ReactiveModel of the injected Model instance,
      //and subscribe this StateBuilder to it.
      observe: () => RM.get<Model>(),
      builder: (context, modelRM) {
        //The builder exposes the BuildContext and the Model ReactiveModel
        return Row(
          children: [
            //get the state of the model
            Text('${modelRM.state.counter}'),
            RaisedButton(
              child: Text('Increment (SetStateCanDoAll)'),
              onPressed: () async {
                //setState treats mutable and immutable objects equally
                modelRM.setState(
                  //mutable state mutation
                  (currentState) => currentState.incrementMutable(),
                );
                modelRM.setState(
                  //immutable state mutation
                  (currentState) => currentState.incrementImmutable(),
                );

                //await until the future completes
                await modelRM.setState(
                  //await for the future to complete and notify observer with
                  //the corresponding connectionState and data
                  //future will be canceled if all observer widgets are removed from
                  //the widget tree.
                  (currentState) => currentState.futureIncrementMutable(),
                );
                //
                await modelRM.setState(
                  (currentState) => currentState.futureIncrementImmutable(),
                );

                //await until the stream is done
                await modelRM.setState(
                  //subscribe to the stream and notify observers.
                  //stream subscription are canceled if all observer widget are removed
                  //from the widget tree.
                  (currentState) => currentState.streamIncrementMutable(),
                );
                //
                await modelRM.setState(
                  (currentState) => currentState.streamIncrementImmutable(),
                );
                //setState can do all; mutable, immutable, sync, async, futures or streams.
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        );
      },
    );
  }
```

No matter you deal with mutable or immutable objects, your method is sync or async, you use future or stream, setState can handle each case to mutate the state and notify listeners.

[Get more information on `setState` method](https://github.com/GIfatahTH/states_rebuilder/wiki/setState)   
[Get more information on `StateBuilder` method](https://github.com/GIfatahTH/states_rebuilder/wiki/StateBuilder)


## Pessimistic future

One common use case is to fetch some data from a server. In this case we may want to display a CircularProgressIndicator while awaiting for the future to complete.

```dart
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //WhenRebuilder is the second of the four observer widgets
        WhenRebuilder<Model>(
          //subscribe to the global ReactiveModel
          observe: () => RM.get<Model>(),
          onSetState: (context, modelRM) {
            //side effects here
            modelRM.whenConnectionState(
              onIdle: () => print('Idle'),
              onWaiting: () => print('onWaiting'),
              onData: (data) => print('onData'),
              onError: (error) => print('onError'),
            );
          },
          onIdle: () => Text('The state is not mutated at all'),
          onWaiting: () => Text('Future is executing, we are waiting ....'),
          onError: (error) => Text('Future completes with error $error'),
          onData: (Model data) => Text('${data.counter}'),
        ),
        RaisedButton(
          child: Text('Increment'),
          onPressed: () {
            //All other widget subscribe to the global ReactiveModel will be notified to rebuild
            RM.get<Model>().setState(
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
```
The futureIncrementImmutable (or futureIncrementMutable) is trigger in response to a button click. We can trigger the async method automatically once the widget is inserted into the widget tree:

```dart
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
      //Create a local ReactiveModel model that decorate the false value
      observe: () => RM.create<bool>(false),
      builder: (context, switchRM) {
        //builder expose the BuildContext and the locally created ReactiveModel.
        return Row(
          children: [
            if (switchRM.state)
              WhenRebuilder<Model>(
                //get the global ReactiveModel and call setState
                //All other widget subscribed to this global ReactiveModel will be notified
                observe: () => RM.get<Model>()
                  ..setState(
                    (currentState) {
                      return currentState.futureIncrementImmutable();
                    },
                  ),
                onSetState: (context, modelRM) {
                  //side effects
                  if (modelRM.hasError) {
                    //show a SnackBar on error
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${modelRM.error}'),
                      ),
                    );
                  }
                },
                onIdle: () => Text('The state is not mutated at all'),
                onWaiting: () =>
                    Text('Future is executing, we are waiting ....'),
                onError: (error) => Text('Future completes with error $error'),
                onData: (Model data) => Text('${data.counter}'),
              )
            else
              Container(),
            RaisedButton(
              child: Text(
                  '${switchRM.state ? "Dispose" : "Insert"}'),
              onPressed: () {
                //mutate the state of the local ReactiveModel directly
                //without using setState although we can.
                //setState gives us more features that we do not need here
                switchRM.state = !switchRM.state;
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        );
      },
    );
  }
```
In the example above, we first created a local `ReactiveModel` of type bool and initialize it with false.

In states_rebuilder there are Global ReactiveModel (injected using Injector) and local ReactiveModel (created locally).

[Get more information on global and local `ReactiveModel` method](https://github.com/GIfatahTH/states_rebuilder/wiki/Local-and-Global-ReactiveModel)
[Get more information on `WhenRebuilder`](https://github.com/GIfatahTH/states_rebuilder/wiki/WhenRebuilder-and-WhenRebuilderOr)

Once a global model emits a notification, all widget subscribed to it will be notified.

To limit the notification to one widget we can use the `future` method.

```dart
  @override
  Widget build(BuildContext context) {
    return StateBuilder(
        observe: () => RM.create(false),
        builder: (context, switchRM) {
          return Row(
            children: [
              if (switchRM.state)
                WhenRebuilder<Model>(
                  //Here use the future method to create new reactive model
                  observe: () => RM.get<Model>().future(
                    (currentState, stateAsync) {
                      //future method exposed the current state and teh Async representation of the state
                      return currentState.futureIncrementImmutable();
                    },
                  ),
                  ////This is NOT equivalent to this :
                  //// observe: () => RM.future(
                  ////   IN.get<Model>().futureIncrementImmutable(),
                  //// ),

                  onIdle: () => Text('The state is not mutated at all'),
                  onWaiting: () =>
                      Text('Future is executing, we are waiting ....'),
                  onError: (error) =>
                      Text('Future completes with error $error'),
                  onData: (Model data) => Text('${data.counter}'),
                )
              else
                Text('This widget will not affect other widgets'),
              RaisedButton(
                child: Text(
                    '${switchRM.state ? "Dispose" : "Insert"}'),
                onPressed: () {
                  switchRM.state = !switchRM.state;
                },
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          );
        },
    );
  }
```
[Get more information on `future` method](https://github.com/GIfatahTH/states_rebuilder/wiki/future)

## Optimistic update
One might be able to predict the outcome of an async operation. If so, we can implement optimistic updates by displaying the expected data when starting the async action and execute the async task in the background and forget about it. It is only if the async task fails that we want to go back to the last state and notify the user of the error.

```dart
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //WhenRebuilderOr is the third observer widget
        WhenRebuilderOr<Model>(
          observe: () => RM.get<Model>(),
          onWaiting: () => Text('Future is executing, we are waiting ....'),
          builder: (context, modelRM) => Text('${modelRM.state.counter}'),
        ),
        RaisedButton(
          child: Text('Increment'),
          onPressed: () {
            RM.get<Model>().setState(
              //stream is the choice for optimistic update
              (currentState) => currentState.streamIncrementMutable(),
              //debounce setState for 1 second
              debounceDelay: 1000,
              onError: (context, error) {
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
```
[Get more information on `WhenRebuilderOr` method](https://github.com/GIfatahTH/states_rebuilder/wiki/WhenRebuilder-and-WhenRebuilderOr)

If we want to automatically call the streamIncrementMutable once the widget is inserted into the widget tree:

```dart
  Widget build(BuildContext context) {
    return StateBuilder(
      observe: () => RM.create(false),
      builder: (context, switchRM) {
        return Row(
          children: [
            if (switchRM.state)
              WhenRebuilderOr<Model>(
                //Create a new ReactiveModel with the stream method.

                observe: () => RM.get<Model>().stream((state, subscription) {
                  //It exposes the current state and the current StreamSubscription.
                  return state.streamIncrementImmutable();
                }),

                ////This is NOT equivalent to this : 
                //// observe: () => RM.stream(
                ////   IN.get<Model>().streamIncrementImmutable(),
                //// ),
                ///
                onSetState: (context, modelRM) {
                  if (modelRM.hasError) {
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${modelRM.error}'),
                      ),
                    );
                  }
                },
                builder: (context, modelRM) {
                  return Text('${modelRM.state.counter}');
                },
              )
            else
              Text('This widget will not affect other widgets'),
            RaisedButton(
              child: Text(
                  '${switchRM.state ? "Dispose" : "Insert"} (OptimisticAsyncOnInitState)'),
              onPressed: () {
                switchRM.state = !switchRM.state;
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        );
      },
    );
  }
```

[Get the full working example](example/README.md)

For more information about how to use states_rebuilder see in the [wiki](https://github.com/GIfatahTH/states_rebuilder/wiki) :
* [**states_rebuilder from A to Z using global functional injection**](https://github.com/GIfatahTH/states_rebuilder/wiki/functional_injection_form_a_to_z/00-functional_injection.md)
* [What is a `ReactiveModel`](https://github.com/GIfatahTH/states_rebuilder/wiki/what-is-a-ReactiveModel)
* [Local and Global `ReactiveModel`](https://github.com/GIfatahTH/states_rebuilder/wiki/Local-and-Global-ReactiveModel)
  * [Local ReactiveModels](https://github.com/GIfatahTH/states_rebuilder/wiki/Local-ReactiveModels)
  * [Global ReactiveModel  (Injector)](https://github.com/GIfatahTH/states_rebuilder/wiki/Global-ReactiveModel-Injector)
* [Mutable state management](https://github.com/GIfatahTH/states_rebuilder/wiki/mutable-state-management)
* [Immutable state management](https://github.com/GIfatahTH/states_rebuilder/wiki/immutable-state-management)
* [New ReactiveModel](https://github.com/GIfatahTH/states_rebuilder/wiki/new-reactivemodel)
* [ReactiveModel key](https://github.com/GIfatahTH/states_rebuilder/wiki/reactivemodel_key)
* [`states_rebuilder` API](https://github.com/GIfatahTH/states_rebuilder/wiki/states_rebuilder-API)
  * [StateBuilder](https://github.com/GIfatahTH/states_rebuilder/wiki/StateBuilder)
  * [WhenRebuilder and WhenRebuilderOr](https://github.com/GIfatahTH/states_rebuilder/wiki/WhenRebuilder-and-WhenRebuilderOr)
  * [OnSetStateListener](https://github.com/GIfatahTH/states_rebuilder/wiki/OnSetStateListener)
  * [Note on the exposedModel](https://github.com/GIfatahTH/states_rebuilder/wiki/Note-on-the-exposedModel)
  * [Injector](https://github.com/GIfatahTH/states_rebuilder/wiki/Injector)
  * [setState](https://github.com/GIfatahTH/states_rebuilder/wiki/setState)
  * [future](https://github.com/GIfatahTH/states_rebuilder/wiki/future)
  * [stream](https://github.com/GIfatahTH/states_rebuilder/wiki/stream)
  * [refresh](https://github.com/GIfatahTH/states_rebuilder/wiki/refresh)
  * [listenToRM](https://github.com/GIfatahTH/states_rebuilder/wiki/listenToRM)
  * [StateWithMixinBuilder](https://github.com/GIfatahTH/states_rebuilder/wiki/StateWithMixinBuilder)
* [Dependency Injection](https://github.com/GIfatahTH/states_rebuilder/wiki/Dependency-Injection)
  * [Asynchronous Dependency Injection](https://github.com/GIfatahTH/states_rebuilder/wiki/Asynchronous-Dependency-Injection)
  * [Development flavor](https://github.com/GIfatahTH/states_rebuilder/wiki/Development-flavor)
* [Side effects without context](https://github.com/GIfatahTH/states_rebuilder/wiki/side-effects-without-context)
* [Widget unit testing](https://github.com/GIfatahTH/states_rebuilder/wiki/Widget-unit-testing)
* [Debugging print](https://github.com/GIfatahTH/states_rebuilder/wiki/Debugging-print)
* [Update log](https://github.com/GIfatahTH/states_rebuilder/wiki/Update-log)