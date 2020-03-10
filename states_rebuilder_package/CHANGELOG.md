## 1.14.3 (2020-03-10)
* Add `reinjectOn` parameters to `Injector` widgets. It takes a list of `ReactiveModel`, and it re-injects the registered models whenever any of the ReactiveModels in the `reinjectOn` parameters emits a notification. [issue #47](../issues/47).

example of injected stream:
```dart
final multiplierRM = ReactiveModel.create(1);
Widget builder(BuildContext context){

  return Injector(
    inject: [Inject.stream(() => Stream.periodic(Duration(seconds: 1), (num) => multiplierRM * num))],
    //Listen to multiplierRM and reinject the stream whenever multiplierRM emits a notification
    reinjectOn: [multiplierRM],
    builder: (context) {
      ///
      ///
    },
  );
}
```

The stream emits: 1, 2, 3, 4, ... because multiplierRM = 1. 

when the value `multiplierRM` is set to 2:

```dart
multiplierRM.setValue(()=>2);
```

The stream subscription is cancelled and an new subscription is established that emits the values : 2, 4, 6, 8 ..... (multiplierRM = 2). Now decedent widgets can subscribe to the stream and rebuild whenever the stream emits a value.

This works for injected streams, futures and vanilla dart classes. 

* Add watch parameter to ReactiveModel.stream constructor. [issue 61](../issues/61)

* refactor code to improve performance.

## 1.14.2 (2020-02-28)
* Add `ReactiveModel<T>.stream(T stream)` and `ReactiveModel<T>.future(T future)` to create a `ReactiveModel` from a stream or future.
* Override the `toString` method of the `ReactiveModel` to give an informative debug print.
* Refactor the code.

## 1.14.1 (2020-02-25)
* Add `ReactiveModel<T>()` factory constructor. it is equivalent to `Injector.getAsReactive(<T>)`. You will save nine key stroke and it looks more readable.
```dart
//You can use the long form
final fooRM = Injector.getAsReactive<Foo>();
//Or the new way:
final fooRM = ReactiveModel<Foo>();
```
for example instead of :
```dart
StateBuilder<Foo>(
  models:[Injector.getAsReactive<Foo>()],
  builder:(context, fooRM){

  }
)
```
you write:
```dart
StateBuilder<Foo>(
  models:[ReactiveModel<Foo>()],
  builder:(context, fooRM){

  }
)
```

* Add `shouldOnInitState` to `OnSEtStateListener`: Usually `onSetState` and its equivalent `onData`, `onError` are invoked only if the observable reactive model emits a notification. This means they are not invoked in the `initState` method. `shouldOnInitState` is an optional bool parameter and when se to true the `onSetState` method will be called from the `initState` method.
* Add `onData` to `WhenRebuilderOr`
* Fix issue #52 and #55.
* Add tests to examples (Easiness of test, is a sign of good code).

## 1.14.0 (2020-02-18)
* Add `resetToIdle` and `resetToHasData` methods to the `ReactiveModel`.
use case examples:
1. Use it with `getAsReactive` so that each time the reactive model is obtained, it will be obtained with the desired asynchronous state, whatever its value before.
```dart
final fooRM = Injector.getAsReactive<Foo>()..resetToIdle();
//you can combine it with asNew
final fooRM = Injector.getAsReactive<Foo>().asNew('mySeed')..resetToIdle();
```
2. Use it if the reactive model throws an error, and you want something like clearing the error.
```dart
fooRM.setState(
  (s) => s.someMethod(),
  onError: (context, error) async {
    //awaiting the alert dialog
    await showDialog(
      context: context,
      builder: (context){
        ///
      }
    );
    //clearing the error.
    fooRM.resetToHasData();
  },
)
```

* Add `Injector.enableTestMode` static bool field. Set it to true in tests to inject fake dependency.
ex:
Let's suppose we have the widget.
```dart
Import 'my_real_model.dart';
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject(() => MyRealModel())],
      builder: (context) {
        final myRealModelRM = Injector.getAsReactive<MyRealModel>();

        // your widget
      },
    );
  }
}
```
MyApp widget depends on `MyRealModel`.

To mock `MyRealModel` and test MyApp we set ``Injector.enableTestMode`` to true :

```dart
testWidgets('Test MyApp class', (tester) async {
  //set enableTestMode to true
  Injector.enableTestMode = true;
  await tester.pumpWidget(
    Injector(
      //Inject the fake model and register it with the real model type
      inject: [Inject<MyRealModel>(() => MyFakeModel())],
      builder: (context) {
        //In my MyApp, Injector.get or Inject.getAsReactive will return the fake model instance
        return MyApp();
      },
    ),
  );

  //My test
});

//fake model implement real model
class MyFakeModel extends MyRealModel {
  // fake implementation
}
```
See real test of the [counter_app_with_error]((states_rebuilder_package/example/test)) and [counter_app_with_refresh_indicator]((states_rebuilder_package/example/test)).

* Add `tag` and `onWaiting` parameters to `OnSetStateListener` widget.
* Add `tag` parameter to `WhenRebuild`  and `WhenRebuildOr` widgets
* Improve the logic of `setValue` and `setState`. Now `setValue` has all the functionalities of `setState`.

## 1.13.0 (2020-02-12)
* Add static variable `Injector.env` and `Inject.interface` named constructor so that you can register under different environments.

ex:
```dart
//abstract class
abstract class ConfigInterface {}

// first prod implementation
class ProdConfig extends ConfigInterface {}

//second dev implementation
class DevConfig extends ConfigInterface {}

//enum for defined flavor
enum Flavor { Prod, Dev }


void main() {
  //Choose yor environment flavor
  Injector.env = Flavor.Dev;

  runApp(
    Injector(
      inject: [
        //Register against an interface with different flavor
        Inject<ConfigInterface>.interface({
          Flavor.Prod: ()=>ProdConfig(),
          Flavor.Dev:()=>DevConfig(),
        }),
      ],
      builder: (_){
        return MyApp(
          appTitle: Injector.get<ConfigInterface>().appDisplayName;
        );
      },
    )
  );
}
```

* `StateBuilder<T>`, `WhenRebuilder<T>` and `OnSetStateListener<T>` observer widgets can be set to observer many observable reactive models. The exposed model instance depends on the generic parameter `T`.
ex:
```dart
//first case : generic model is ModelA
StateBuilder<ModelA>(
  models:[modelA, modelB],
  builder:(context, exposedModel){
    //exposedModel is an instance of ReactiveModel<ModelA>.
  }
)
//second case : generic model is ModelB
StateBuilder<ModelB>(
  models:[modelA, modelB],
  builder:(context, exposedModel){
    //exposedModel is an instance of ReactiveModel<ModelB>.
  }
)
//third case : generic model is dynamic
StateBuilder(
  models:[modelA, modelB],
  builder:(context, exposedModel){
    //exposedModel is dynamic and it will change over time to hold the instance of model that emits a notification.
    
    //If modelA emits a notification the exposedModel == ReactiveModel<ModelA>.
    //Wheres if modelB emits a notification the exposedModel == ReactiveModel<ModelB>.
  }
)
```
* Add `WhenRebuilderOr`. It is equivalent to `WhenRebuilder` but with optional `onIdle`, `onWaiting` and `onError` parameters and with required default `builder`.



## 1.12.1 (2020-02-.3)
* Add Continuous Integration and code coverage support.
* Improve test coverage.

## 1.12.0 (2020-01-30)
* Add `ReactiveModel<T>.create(T value)` to create a `ReactiveModel` from a primitive value. The created `ReactiveModel` has the full power the other reactive models created using `Injector` have.
ex: This is a simple counter app:

```dart
class App extends StatelessWidget {
  //Create a reactiveModel<int> with initial value and assign it to counterRM  filed.
  final counterRM = ReactiveModel.create(0);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          // Subscribe StateBuilder widget ot counterRM
          child: StateBuilder(
            models: [counterRM],
            builder: (context, _) {
              return Text('${counterRM.value}');
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          //set the value of the counterRM and notify observers.
          onPressed: () => counterRM.setValue(() => counterRM.value + 1),
        ),
      ),
    );
  }
}
```

*  Add `WhenRebuilder` widget. It is a shortcut of using `SateBuilder` to subscribe to an observable model and use `ReactiveModel.whenConnectionState` method to exhaustively switch over all the possible statuses of `connectionState`.

instead of:
```dart
Widget build(BuildContext context) {
    return StateBuilder<PlugIn1>(
      models: [Injector.getAsReactive<PlugIn1>()],
      builder: (_, plugin1RM) {
        return plugin1RM.whenConnectionState(
          onIdle: () => Text('onIDle'),
          onWaiting: () => CircularProgressIndicator(),
          onError: (error) => Text('plugin one has an error $error'),
          onData: (plugin1) => Text('plugin one is ready'),
        );
      },
    );
}
```

You use :

```dart
@override
Widget build(BuildContext context) {
  return WhenRebuilder<PlugIn1>(
    models: [Injector.getAsReactive<PlugIn1>()],
    onIdle: () => Text('onIdle'),
    onWaiting: () => CircularProgressIndicator(),
    onError: (error) => Text('plugin one has an error $error'),
    onData: (plugin1) => Text('plugin one is ready'),
  );
}
```
As a good side effect of using `WhenRebuilder`, you can subscribe to many observable models and a combination status is exposed so that `onData` will not be invoked only after all observable models have data.

ex:

```dart
  final plugin1RM = Injector.getAsReactive<PlugIn1>();
  final plugin2RM = Injector.getAsReactive<PlugIn2>();
  @override
  Widget build(BuildContext context) {
    return WhenRebuilder<PlugIn1>(
      models: [plugin1RM, plugin2RM],
      onIdle: () => Text('onIDle'),
      //onWaiting is called if any models is in the waiting state
      onWaiting: () => CircularProgressIndicator(),
      // onError will be called with the thrown error, if any of the observed models throws.
      onError: (error) => Text('plugin1 or plugin2  has an error $error'),
      //onData is called when all observable models have data
      onData: (plugin1) => Text('plugin1 and plugin2  are both ready'),
    );
  }
```
* Add `OnSetStateListener` widget to handle side effects. It subscribes to a list of observable models and listen to them and execute the corresponding  onData or onError side effects.

* Add `value` getter and `ReactiveModel.setValue` method. They are the counterpart of the `state` getter and `ReactiveModel.setState` method respectively. They are more convenient to use with primitive values and immutable objects.

* Add `ReactiveModel.asNew([dynamic seed])` to create new reactive instance.

* Replace `setState.joinSingletonWith` in  with the bool parameter `setState.joinSingleton`.

* A huge Refactor of the code. I have written the code from the ground using Test Driven Design principles. Now the cod is cleaner, shorter, and more effective.


## 1.11.2 (2020-01-10)
* Add the static method `StatesRebuilderDebug.printInjectedModel()` to debugPrint all registered model in the service locator.
* Add the static method `StatesRebuilderDebug.printObservers(observable)` to )debugPrint all subscribed observers to the provided observable.
* Refactor watch logic to work with asynchronous tasks as well as with List, Map, Set types.

## 1.11.1 (2020-01-05)
* Add `onData(BuildContext, T)` parameter to `setState` method.
  It is a shortcut to:
  ```dart
  onSetState(context){
    if(reactiveModel.hasData){
      .....
    }
  }
  ```

## 1.11.0 (2020-01-05)
* `Inject.get` for injected streams and future will no longer throw, it will return the the current value.
* If `whenConnectionState` is defined, `catchError` is set true automatically.
* Add `watch` parameter to `StateBuilder` widget and. `watch` allows to link the rebuild process to the variation of a set of variables.(Experimental feature).
* Remove deprecated `getAsModel` and `hasState`.
* Update docs and add Dependency Injection section in the readme file.

## 1.10.0 (2019-12-30)
* Add `whenConnectionState` method to the `ReactiveModel`. IT exhaustively switch over all the possible statuses of `connectionState`. Used mostly to return a Widget. (Pul request of [ResoCoder](https://resocoder.com/2019/12/30/states-rebuilder-zero-boilerplate-flutter-state-management/)).

## 1.9.0 (2019-12-28)
* Add assertion error helpful messages.
* Add `isIdle` getter to the `ReactiveModel` as a shortcut to :
 `connectionState == ConnectionState.none`
* Add `isWaiting` getter to the `ReactiveModel` as a shortcut to :
 `connectionState == ConnectionState.waiting`
* Add `onError(BuildContext, dynamic)` parameter to `setState` method.
* Add `joinSingletonToNewData` parameter to `setState` method.
* Refactor codes to remove bugs and to use Flutter 1.12 version.

## 1.8.0 (2019-12-06)
1- Add the following features: (See readme fille).
*  `onSetState` and  `onRebuildState` parameters to the `StateBuilder`.
* The BuildContext is the default tag of `StateBuilder`.
* `JoinSingleton`, `inheritedInject`, `initialCustomStateStatus` parameters to `Inject`
* `reinject` and `getAsReactive` to `Injector`.
2- Remove the following parameters:(Breaking changes)
*  `tagID` parameter from `StateBuilder`.
before
```dart
StateBuilder(
  builder: (BuildContext context, String tagID){
    // code
  }
)
```
after
```dart
StateBuilder<T>(
  models: [firstModel, secondModel],
  builder: (BuildContext context, ReactiveModel<T> model){
    /// No more need for the `tagID` because the `context` is used as `tagID`.
    /// the model is the first instance (firstModel) in the list of the [models] parameter.
    /// If the parameter [models] is not provided then the model will be a new reactive instance
    /// See readme file for more information
  }
)
```
* The model parameter of the `Injector.builder` method.
before
```dart
Injector(
  builder: (BuildContext context, T model){
    // code
  }
)
```

after
```dart
Injector(
  builder: (BuildContext context){
    // no need for model parameter. It has less boilerplate.
  }
)
```
* `Injector.getAsModel`, `StateBuilder.viewModel` and `StatesRebuilder.hasState` are deprecated, and replaced by `Injector.getAsReactive`, `StateBuilder.models` and `StatesRebuilder.hasObservers` respectively.

## 1.7.0 (2019-11-14)
1- Add `onSetState` parameter to the `setState` method to define a callback to be executed after state mutation.
  The callBack takes the context so you can push/pop routes, show dialogs or snackBar. (see example folder).  

2- Add `catchError` parameter to the `setState` method to define whether to catch error while mutining the state or not.(see example folder). If an error is thrown, `hasError` getter is true and the error can be obtained via the `error` getter (see point 5 below).   

3- Add the getter `connectionState` to the `ModelStatesRebuilder<T>`to get the asynchronous status of the state. it can be `ConnectionState.none` before executing the Future, `ConnectionState.waiting` while waiting for the Future and `ConnectionState.done` after resolving the Future.    

4- Add the field `stateStatus` to the `ModelStatesRebuilder<T>` class. It allows defining a custom status of the state other than those defined by the `connectionState`  getter.    

5- add the getter `hasError`, `hasData` and `error` to the `ModelStatesRebuilder<T>` class.     

6- Change the name `blocs` to `models`.   

7- Refactor the code and fix bugs.

8- Update docs and examples.


## 1.6.1 (2019-10-22)
* Add `watch` parameter to `setState` method and `Inject.stream` constructor. `watch` allows to link the rebuild process to the variation of a set of variables.
* Update docs

## 1.6.0+1 (2019-10-18)
* Add `Injector.getAsModel` method. When called with the context parameter, the calling widget is automatically registered as a listener.
* Add `setState(Function(state))` to mutate the state and update the dependent the views from the UI.
* Model class have not to extend `StatesRebuilder` to get reactivity.
* Add the named constructor`Inject.future` which take a future and update dependents when future completes.
* Add the named constructor`Inject.stream` which take a steam and update dependents when stream emits a value.
* `Injector.get` or `Injector.getAsModel` now throws if no registered model is found. This can be silent by setting the parameter `silent` to true
* Injected model ara lazily instantiated. To do otherwise set the parameter `isLazy` of the `Inject` widget to false.


## 1.5.1 (2019-09-14)
* add `afterInitialBuild` and `afterRebuild` parameters to the `StateBuilder`, `StateWithMixinBuilder` and `Injector` widgets.`
  `afterInitialBuild` and `afterRebuild` are callBack to be executed after the widget is mounted and after each rebuild. 

## 1.5.0+1 (2019-09-12)
* Use `ObservableService` and `hasState` instead of `Observable` and `hasObserver`, because the latters are widely used and can lead to conflict


## 1.5.0 (2019-09-06)
* Add `hasStates` getter to check if the StatesRebuilder object has listener.
* Add `inject` parameter to the `Injector` widget as an alternative to the `models` parameter. With `inject` you can register models using interface Type. 
* Add `observable` interface. Any service class can implement it to notify any ViewModel to rebuild its corresponding view.
* Refactor the library to make it design patterns wise and hence make it testable.
* Test the library

## 1.3.2 (2019-06-24)
* Add `appLifeCycle` argument to Injector to track the life cycle of the app.
* Refactor the code.


## 1.3.1 (2019-06-13)
* remove `rebuildFromStreams`.
* Initial release of `Streaming` class
* The builder closure of the `Injector` takes (BuildContext context, T model) where T is the generic type.
* Fix typos

## 1.3.0 (2019-06-04)
* Initial release of `rebuildFromStreams` method.
* Initial release of `Injector` for Dependency Injection.
* deprecate blocs parameter and use viewModels instead
* StateBuilder can have many tags.

## 1.2.0 (2019-05-23)
 *  Remove `stateID` and replace it by `tag` parameter. `tag` is optional and many widgets can have the same tag.
 *  `rebuildStates()` when called without parameters, it rebuilds all widgets that are wrapped with `StateBuilder` and `StateWithMixinBuilder`.
 *  Each `StateBuilder` has an automatically generated cached address. It is stored in the second parameter of the `builder`, `initState`, `dispose`,  and other closures. You can call it inside the closures to rebuild that particular widget.
 *  add `StateWithMixinBuilder` widget to account for some of the most used mixins.
 *  Optimize the code and improve performance

## 1.1.0 (2019-05-13)
 * Add `withTickerProvider` parameter to `StateBuilder` widget.


## 1.0.0 (2019-05-12)
 * Add `BlocProvider`to provide your BloCs.
 * You can use enums to name your `StateBuilder` widgets.
 * `rebuildStates` now has only one positioned parameter of List<dynamic>.
 * If `rebuildStates` is given without parameter, it will rebuild all widgets that have `stateID`.
 * improve performance.


## 0.1.4

  * improve performance


## 0.1.3

  * Add getter and setter for the stateMap.

## 0.1.2

  * Remove print statements

## 0.1.1

  * Change readme.md of the example

## 0.1.0

  * Initial version
