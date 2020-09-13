# `states_rebuilder`

[![pub package](https://img.shields.io/pub/v/states_rebuilder.svg)](https://pub.dev/packages/states_rebuilder)
[![CircleCI](https://circleci.com/gh/GIfatahTH/states_rebuilder.svg?style=svg)](https://circleci.com/gh/GIfatahTH/states_rebuilder)
[![codecov](https://codecov.io/gh/GIfatahTH/states_rebuilder/branch/master/graph/badge.svg)](https://codecov.io/gh/GIfatahTH/states_rebuilder)

<p align="center">
    <image src="../assets/Logo-Black.png" width="500" alt=''/>
</p>

A Flutter state management combined with a dependency injection solution to get the best experience with state management. 

- Performance
  - Strictly rebuild control
  - Auto clean state when not used
  - Immutable / Mutable states support

- Code Clean
  - Zero Boilerplate
  - No annotation & code-generation
  - Separation of UI & business logic
  - Achieve business logic in pure Dart.

- User Friendly
  - Built-in dependency injection system
  - `SetState` in StatelessWidget.
  - Hot-pluggable Stream / Futures
  - Easily Undo / Redo
  - Navigate, show dialogs without `BuildContext`
  - Easily persist the state and retrieve it back

- Maintainable
  - Easy to test, mock the dependencies
  - Built-in debugging print function
  - Capable for complex apps

## A Quick Tour of global functional injection (Newer Approach)

Start by your business logic. Use plain old vanilla dart class only.

```dart
class MyModel(){
  //Can return any type, futures and streams included
  someMethod(){ ... }
}
```

* To inject it following functional injection approach:
  ```dart
  //Can be defined globally, as a class field or even inside the build method.
  final model = RM.inject<MyModel>(
      ()=>MyModel(),
      //After initialized, it preserves the state it refers to until it is disposed
      onInitialized : (MyModel state) => print('Initialized'),
      //Default callbacks for side effects.
      onWaiting : () => print('Is waiting'),
      hasData : (MyModel data) => print('Has data'),
      hasError : (error, stack) => print('Has error'),
      //It is disposed when no longer needed
      onDisposed: (MyModel state) => print('Disposed'),
  );
  ```

* To mock it in test:
  ```dart
  model.injectMock(()=> MyMockModel());
  //You can even mock the mocked implementation
  ```
  Similar to `RM.inject` there are:
  ```dart
  RM.injectFuture//For Future, 
  RM.injectStream,//For Stream,
  RM.injectComputed//depends on other injected Models and watches them.
  RM.injectFlavor// For flavor and development environment
  ```

* To listen to an injected model from the User Interface:
  - Rebuild when model has data only:
    ```dart
    model.rebuilder(()=> Text('${model.state}')); 
    ```
  -Handle all possible async status:
    ```dart
    model.whenRebuilder(
        isIdle: ()=> Text('Idle'),
        isWaiting: ()=> Text('Waiting'),
        hasError: ()=> Text('Error'),
        hasData: ()=> Text('Data'),
    )
    ```

* To listen to many injected models and exposes and merged state:
  ```dart
    [model1, model1 ..., modelN].whenRebuilder(
        isWaiting: ()=> Text('Waiting'),//If any is waiting
        hasError: ()=> Text('Error'),//If any has error
        isIdle: ()=> Text('Idle'),//If any is Idle
        hasData: ()=> Text('Data'),//All have Data
    )
  ```

* To mutate the state and notify listener:
  ```dart
  //Direct mutation
  model.state= newState;
  //or for more options
  model.setState(
    (s)=>s.someMethod()
    debounceDelay=500,
  );
  ```
* To undo and redo immutable state:
  ```dart
  model.undoState();
  model.redoState();
  ```

* To navigate, show dialogs and snackBars without `BuildContext`:
  ```dart
  RM.navigate.to(HomePage());

  RM.navigate.toDialog(AlertDialog( ... ));

  RM.scaffoldShow.snackbar(SnackBar( ... ));
  ```

* To Persist the state and retrieve it when the app restarts,
  ```dart
  final model = RM.inject<MyModel>(
      ()=>MyModel(),
    persist: PersistState(
      key: 'modelKey',
      toJson: (MyModel s) => s.toJson(),
      fromJson: (String json) => MyModel.fromJson(json),
      //Optionally, throttle the state persistance
      throttleDelay: 1000,
    ),
  );
  ```
And many more features.


> 🚀 To see global functional injection in action and feel how easy and efficient it is, please refer to this tutorial [Global function injection from A to Z](https://github.com/GIfatahTH/states_rebuilder/wiki/functional_injection_form_a_to_z/00-functional_injection)
> 🚀 To see how to navigate and show dialogs, menus, bottom sheets, and snackBars without BuildContext, please refer to this document [**Navigate and show dialogs, menus, bottom sheets, and snackBars without `BuildContext`**](https://github.com/GIfatahTH/states_rebuilder/wiki/side_effects_without_buildContext)
> 🚀 To see how to how to persist the state and retrieve it on app restart, please refer to this document [**Navigate and show dialogs, menus, bottom sheets and snackBars without `BuildContext`**](https://github.com/GIfatahTH/states_rebuilder/wiki/17-persisting_the_state)

## An Example of widget-wise injection using Injector.

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

[Get the full working example](https://github.com/GIfatahTH/states_rebuilder/blob/master/states_rebuilder_package/example/README.md)

For more information about how to use states_rebuilder see in the [wiki](https://github.com/GIfatahTH/states_rebuilder/wiki) :
* [**states_rebuilder from A to Z using global functional injection**](https://github.com/GIfatahTH/states_rebuilder/wiki/functional_injection_form_a_to_z/00-functional_injection)
* [**Navigate and show dialogs, menus, bottom sheets and snackBars without `BuildContext`**](https://github.com/GIfatahTH/states_rebuilder/wiki/side_effects_without_buildContext)
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