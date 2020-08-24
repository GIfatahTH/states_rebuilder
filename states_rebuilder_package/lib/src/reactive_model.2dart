import 'dart:async';

import 'package:flutter/material.dart';

import 'inject.dart';
import 'injected.dart';
import 'injector.dart';
import 'reactive_model_imp.dart';
import 'states_rebuilder.dart';

///Remove custom added listener using [ReactiveModel.listenToRM]
typedef Disposer = void Function();

///An abstract class that defines the reactive environment.
///
///`states_rebuilder` is based on the concept of [ReactiveModel].
/// ReactiveModels are either local or global.
///
/// In local `ReactiveModel`, the creation of the `ReactiveModel` and subscription
/// and notification are all limited in one place (widget).
///
/// In Global `ReactiveModel`, the `ReactiveModel` is created once, and it is
/// available for subscription and notification throughout all the widget tree.
///
///   * [Local ReactiveModels](Local-ReactiveModels)
///   * [Global ReactiveModel  (Injector)](Global-ReactiveModel-Injector)
///
/// ### Local ReactiveModels
///
///Let's start by creating the simplest counter app ever created.
///
///```dart
///class MyApp extends StatelessWidget {
///  @override
///  Widget build(BuildContext context) {
///    return MaterialApp(
///      //StateBuilder is used to subscribe to ReactiveModel
///      home: StateBuilder<int>(
///        //Creating a local ReactiveModel that decorates an integer value
///        //with initial value of 0
///        observe: () => RM.create<int>(0),
///        //The builder exposes the BuildContext and the instance of the created ReactiveModel
///        builder: (context, counterRM) {
///          return Scaffold(
///            appBar: AppBar(),
///            body: Center(
///              //use the state getter to get the latest state stored in the ReactiveModel
///              child: Text('${counterRM.state}'),
///            ),
///            floatingActionButton: FloatingActionButton(
///              child: Icon(Icons.add),
///              //get and increment the value of the counterRM.
///              //on mutating the state using the state setter the observers are automatically notified
///              onPressed: () => counterRM.state++,
///            ),
///          );
///        },
///      ),
///    );
///  }
///}
///```
///    * `StateBuilder` widget is one of four observer widgets offered by `states_rebuilder` to subscribe to a `ReactiveModel`.
///    *  in `observer` parameter we created and subscribed to a local `ReactiveModel` the decorated an integer value with an initial value of 0.
///        With states_rebuilder we can create ReactiveModels form primitives, pure dart classes, futures or streams:
///        ```dart
///        //create for objects
///        final fooRM = RM.create<Foo>(Foo());
///        //create from Future
///        final futureRM = RM.future<T>(myFuture);
///        //create from stream
///        final streamRM = RM.stream<T>(myStream);
///        //the above statement are shortcuts of the following
///        final fooRM = ReactiveModel<Foo>.create(Foo());
///        final futureRM = ReactiveModel<T>.future(futureRM);
///        final streamRM = ReactiveModel<T>.stream(streamRM);
///        ```
///    * The `builder` parameter exposes the `BuildContext` and the the created instance of the `ReactiveModel`.
///    * To notify the subscribed widgets (we have one `StateBuilder` here), we just incremented the value of the `counterRM`
///        ```dart
///        onPressed: () => counterRM.state++,
///        ```
///    * `ReactiveModel` decorates a primitive integer of 0 initial value and adds the following functionality:
///        * The 0 is an observable `ReactiveModel` and widget can subscribe to it.
///        * The `state` getter and setter to increment the 0 and notify observers
///
///
///### Global ReactiveModel (Injector)
///There is no difference between local and global ReactiveModel, except that global ReactiveModels are available in the widget tree and local models are used for a limited part of the widget tree.
///
///Regardless of the effectiveness of the state management solution, it must rely on a reliable dependency injection system.
///
///`states_rebuilder` uses the service locator pattern for injecting dependencies using the` injector` with is a StatefulWidget.
///
///
///`states_rebuilder` uses the service locator pattern, in a way that makes it aware of the widget's lifecycle. This means that models are registered when needed in the `initState` method of a` StatefulWidget` and are unregistered when they are no longer needed in the `dispose` method.
///Models once registered are available throughout the widget tree as long as the StatefulWidget that registered them is not disposed. The StatefulWidget used to register and unregister models is the `Injector` widget.
///
///
///```dart
///@immutable
///class Counter {
///  final int count;
///
///  Counter(this.count);
///
///  Future<Counter> increment() async {
///    await fetchSomeThing();
///    return Counter(count + 1);
///  }
///}
///
///class MyApp extends StatelessWidget {
///  @override
///  Widget build(BuildContext context) {
///    //We use Injector widget to provide a model to the widget tree
///    return Injector(
///      //inject a list of injectable
///      inject: [Inject(() => Counter(0))],
///      builder: (context) {
///        return MaterialApp(
///          home: Scaffold(
///            appBar: AppBar(),
///            body: Center(
///              child: WhenRebuilder<Counter>(
///                //Consume the ReactiveModel of the injected Counter model
///                observe: () => RM.get<Counter>(),
///                onIdle: () => Text('Tap to increment the counter'),
///                onWaiting: () => Center(
///                  child: CircularProgressIndicator(),
///                ),
///                onError: (error) => Center(child: Text('$error')),
///                onData: (counter) {
///                  return Text('${counter.count}');
///                },
///              ),
///            ),
///            floatingActionButton: FloatingActionButton(
///              child: Icon(Icons.add),
///              //The ReactiveModel of Counter is available any where is the widget tree.
///              onPressed: () async => RM.get<Counter>().setSate(
///                    (Counter currentState) => currentState.increment(),
///                    catchError: true,
///                  ),
///            ),
///          ),
///        );
///      },
///    );
///  }
///}
///```
///
///To understand the principle of DI, it is important to consider the following principles:
///
///1. `Injector` adds classes to the container of the service locator in` initState` and deletes them in the `dispose` state. This means that if `Injector` is removed and re-inserted in the widget tree, a new singleton is registered for the injected models. If you injected streams or futures using `Inject.stream` or `Inject.future` and when the `Injector` is disposed and re-inserted, the streams and futures are disposed and reinitialized by `states_rebuilder` and do not fear of any memory leakage.
///
///2. You can use nested injectors. As the `Injector` is a simple StatefulWidget, it can be added anywhere in the widget tree. Typical use is to insert the `Injector` deeper in the widget tree just before using the injected classes.
///
///3. Injected classes are registered lazily. This means that they are not instantiated after injection until they are consumed for the first time.
///
///4. For each injected class, you can consume the registered instance using :
///    * `Injector.get` to get the registered raw vanilla dart instance.
///      ```dart
///      final T model = Injector.get<T>()
///      //If the model is registered with custom name :
///      final T model = Injector.get<T>(name:'customName');
///      ```
///      > As a shortcut you can use:
///      ```dart
///      final T model = IN.get<T>() // IN stands for Injector
///      ```
///    * or the ReactiveModel wrapper of the injected instance using:
///      ```dart
///      ReactiveModel<T> modelRM = Injector.getAsReactive<T>()
///      ```
///      As a shortcut you can use:
///      ```dart
///      ReactiveModel<T> modelRM = ReactiveModel<T>();
///      ReactiveModel<T> modelRM = RM.get<T>();
///      ```
///
///5. Both the raw instance and the reactive instance are registered lazily, if you consume a class using only `Injector.get` and not` Injector.getAsReactive`, the reactive instance will never be instantiated.
///
///6. You can register classes with concrete types or abstract classes.
///
///7. You can register under different devolvement environments. This can be done by the help of `Inject.interface` named constructor and by setting the environment flavor `Injector.env` before calling the runApp method. see example below.
///
///That said:
///> It is possible to register a class as a singleton, as a lazy singleton or as a factory simply by choosing where to insert it in the widget tree.
///
///* To save a singleton that will be available for all applications, insert the `Injector` widget in the top widget tree. It is possible to set the `isLazy` parameter to false to instantiate the injected class the time of injection.
///
///* To save a singleton that will be used by a branch of the widget tree, insert the `Injector` widget just above the branch. Each time you get into the branch, a singleton is registered and when you get out of it, the singleton will be destroyed. Making a profit of the behavior, you can clean injected models by defining a `dispose()` method inside them and set the parameter `disposeModels` of the `Injector`to true.
///
///It is important to understand that `states_rebuilder` caches two singletons.
///* The raw singleton of the registered model, obtained using `Injector.get` (or IN.get) method.
///* The reactive singleton of the registered model (the raw model decorated with reactive environment), obtained using `Injector.getAsReactive` of (RM.get).
///
///See also [Injector], [RM.get], [ReactiveModel.setState]

abstract class ReactiveModel<T> implements StatesRebuilder<T> {
  ///Create a ReactiveModel for primitive values, enums and immutable objects
  ///
  ///You can use the shortcut [RM.create]:
  ///```dart
  ///RM.create<T>(T model);
  ///```
  factory ReactiveModel.create(T model) {
    var inject = Inject<T>(() => model);
    var rm = inject.getReactive();
    return rm;
  }

  ///Create a ReactiveModel form stream
  ///
  ///You can use the shortcut [RM.stream]:
  ///```dart
  ///RM.stream<T>(Stream<T> stream);
  ///```
  ///Use [unsubscribe] to dispose of the stream.
  factory ReactiveModel.stream(
    Stream<T> stream, {
    dynamic name,
    T initialValue,
    List<dynamic> filterTags,
    Object Function(T) watch,
  }) {
    final inject = Inject<T>.stream(
      () => stream,
      initialValue: initialValue,
      name: name,
      filterTags: filterTags,
      watch: watch,
    );
    return inject.getReactive();
  }

  ///Create a ReactiveModel form future
  ///
  ///You can use the shortcut [RM.future]:
  ///```dart
  ///RM.future<T>(future<T> future);
  ///```
  factory ReactiveModel.future(
    Future<T> future, {
    dynamic name,
    T initialValue,
    List<dynamic> filterTags,
  }) {
    final inject = Inject<T>.future(
      () => future,
      initialValue: initialValue,
      name: name,
      filterTags: filterTags,
    );
    return inject.getReactive();
  }

  ///Get the singleton [ReactiveModel] instance of a model registered with [Injector].
  ///
  /// ou can use the shortcut [RM.get]:
  ///```dart
  ///RM.get<T>(;
  ///```
  ///
  ///
  factory ReactiveModel({dynamic name, bool silent = false}) {
    return Injector.getAsReactive<T>(name: name, silent: silent);
  }

  ///A representation of the most recent state (instance) of the injected model.
  AsyncSnapshot<T> get snapshot;

  ///The state of the injected model.
  T state;

  ///Get the state as future
  ///
  ///You can await for it when the [ConnectionState] is awaiting
  Future<T> get stateAsync;

  // ///The value the ReactiveModel holds. It is the same as [state]
  // ///
  // ///value is more suitable fro immutable objects,
  // ///
  // ///value when set it automatically notify observers. You do not have to explicitly use [setValue]
  // T value;

  ///inject associated with this ReactiveModel
  Inject<T> get inject;

  ///The latest error object received by the asynchronous computation.
  dynamic get error;

  ///Current state of connection to the asynchronous computation.
  ///
  ///The initial state is [ConnectionState.none].
  ///
  ///If the an asynchronous event is mutating the state,
  ///the connection state is set to [ConnectionState.waiting] and listeners are notified.
  ///
  ///When the asynchronous task resolves
  ///the connection state is set to [ConnectionState.none] and listeners are notified.
  ///
  ///If the state is mutated by a non synchronous event, the connection state remains [ConnectionState.none].
  ConnectionState get connectionState;

  ///Where the reactive state is in the initial state
  ///
  ///It is a shortcut of : this.connectionState == ConnectionState.none
  bool get isIdle;

  ///Where the reactive state is in the waiting for an asynchronous task to resolve
  ///
  ///It is a shortcut of : this.connectionState == ConnectionState.waiting
  bool get isWaiting;

  ///Returns whether this state contains a non-null [error] value.
  bool get hasError;

  ///The global error event handler of this ReactiveModel.
  ///
  ///The  exposed BuildContext if of the last add observer widget.
  ///If not observer is registered yet, the BuildContext is null.
  ///
  ///You can override this error handling to use a specific handling in response to particular events
  ///using the onError callback of [setState] or [setValue].
  void onError(void Function(BuildContext context, dynamic error) errorHandler);

  ///The global data event handler of this ReactiveModel.
  ///
  void onData(void Function(T data) fn);

  ///Returns whether this snapshot contains a non-null [AsyncSnapshot.data] value.
  ///Unlike in [AsyncSnapshot], hasData has special meaning here.
  ///It means that the [connectionState] is [ConnectionState.done] with no error.
  bool get hasData;

  ///unsubscribe form the stream.
  ///It works for injected streams or futures.
  void unsubscribe();

  ///Listen to a ReactiveModel
  ///
  ///By default,
  ///
  ///It returns a callback for unsubscription
  Disposer listenToRM(
    void Function(ReactiveModel<T> rm) fn, {
    bool listenToOnDataOnly = true,
  });

  ///The stream (or Future) subscription of the state
  StreamSubscription<dynamic> get subscription;

  ///Exhaustively switch over all the possible statuses of [connectionState].
  ///Used mostly to return [Widget]s.
  R whenConnectionState<R>({
    @required R Function() onIdle,
    @required R Function() onWaiting,
    @required R Function(T state) onData,
    @required R Function(dynamic error) onError,
    bool catchError = true,
  });

  ///Return a new reactive instance.
  ///
  ///The [seed] parameter is used to unsure to always obtain the same new reactive
  ///instance after widget tree reconstruction.
  ///
  ///[seed] is optional and if not provided a default seed is used.
  ReactiveModel<T> asNew([dynamic seed = 'defaultReactiveSeed']);

  ///Rest the async connection state to [isIdle]
  void resetToIdle([T state]);

  ///Rest the async connection state to [hasData]
  void resetToHasData([T state]);

  ///Rest the async connection state to [isWaiting]
  void resetToIsWaiting([T state]);

  ///Rest the async connection state to [hasError]
  void resetToHasError(dynamic e);

  ///Holds data to be sent between reactive singleton and reactive new instances.
  dynamic get joinSingletonToNewData;

  ///Mutate the state of the model and notify observers.
  ///
  ///* Required parameters:
  ///  * The mutation function. It takes the current state fo the model.
  /// The function can have any type of return including Future and Stream.
  ///* Optional parameters:
  ///  * [onData]: The callback to execute when the state is successfully mutated
  /// with data. If defined this [onData] will override any other onData for this particular call.
  ///  * [onError]: The callback to execute when the state has error. If defined
  /// this [onError] will override any other onData for this particular call.
  ///  * [onSetState] and [onRebuildState]: for more general side effects to
  /// execute before and after rebuilding observers.
  ///  * [catchError]: automatically catch errors. It defaults to false, but if
  /// [onError] is defined then it will be true.
  ///  * [skipWaiting]: Wether to notify observers on the waiting state.
  ///  * [debounceDelay]: time in seconds to debounce the execution of [setState].
  ///  * [throttleDelay]: time in seconds to throttle the execution of [setState].
  ///  * [shouldAwait]: Wether to await of any existing async call.
  ///  * [silent]: Whether to silent the error of no observers is found.
  ///  * [watch]: parameters to watch, and only emits notification if they changes.
  ///  * [filterTags]: List of tags to notify.
  ///  * [seeds]: List of seeds to notify.
  ///  * [context]: The [BuildContext] to be used for side effects (Navigation, SnackBar).
  /// If not defined a default [BuildContext] obtained from the last added [StateBuilder] will be used.
  ///  * [joinSingleton]:  used to define how new reactive instances will notify and modify the state of the reactive singleton.
  ///  * [notifyAllReactiveInstances]: Whether to notify all reactive instances created from the same [Inject]
  Future<void> setState(
    Function(T s) fn, {
    void Function(BuildContext context, T model) onData,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    bool catchError,
    bool skipWaiting = false,
    int debounceDelay,
    int throttleDelay,
    bool shouldAwait = false,
    bool silent = false,
    Object Function(T state) watch,
    List<dynamic> filterTags,
    List<dynamic> seeds,
    BuildContext context,
    bool joinSingleton = false,
    dynamic Function() joinSingletonToNewData,
    bool notifyAllReactiveInstances = false,
  });

  ///Get a stream from the state and subscribe to it and
  ///notify observing widget of this [ReactiveModel]
  ///whenever the stream emits data
  ///
  ///The callback exposes the current state and stream subscription.
  ///
  ///If all observer widget are removed from the widget tree,
  ///the stream of local ReactiveModel will be canceled.
  ///
  ///For global ReactiveModel the stream is not canceled unless
  ///the [Injector] widget that creates the stream is disposed.
  ///
  /// See
  ///* [Inject.stream]: Stream injected using [Inject.stream] can be consumed with [RM.get].
  ReactiveModel<S> stream<S>(
    Stream<S> Function(
      T s,
      StreamSubscription<dynamic> subscription,
    )
        stream, {
    S initialValue,
    Object Function(S s) watch,
  });

  ///Get a Future from the state and subscribe to it and
  ///notify observing widget of this [ReactiveModel]
  ///when the future completes
  ///
  ///The callback exposes the current state and async state as parameter.
  ///
  ///The future is automatically canceled when this [ReactiveModel] is disposed.
  ///
  ///
  ///See:
  ///* [Inject.future].
  ReactiveModel<F> future<F>(
    Future<F> Function(T s, Future<T> stateAsync) future, {
    F initialValue,
  });

  ///Check the type of the state of the [ReactiveModel]
  bool isA<T>();

  ///Return the type of the state of the [ReactiveModel]
  String type([bool detailed]);

  /// Notify registered observers to rebuild.
  void notify([List<dynamic> tags]);

  /// Refresh the [ReactiveModel] state.
  ///
  /// Reset the ReactiveModel to its initial state by reinvoking its creation function.
  Future<T> refresh({void Function() onInitRefresh});

  ///undo to the last valid state (isWaiting and hasError are ignored)
  ReactiveModel<T> undoState();

  ///redo to the next valid state (isWaiting and hasError are ignored)
  ReactiveModel<T> redoState();

  ///Clear undoStack;
  void clearUndoStack();

  ///Whether the state can be done
  bool get canUndoState;

  ///Whether the state can be redone.
  bool get canRedoState;
  set undoStackLength(int length);
}

///
abstract class RM {
  ///Create a [ReactiveModel] from primitives or any object
  static ReactiveModel<T> create<T>(T model) {
    final T _model = model;
    return ReactiveModel<T>.create(_model);
  }

  ///Create a [ReactiveModel] from callback. It's like [create] with the difference
  ///that when [ReactiveModel.refresh] is called, an updated value is obtained.
  ///
  ///Useful with [ReactiveModel.refresh] method.
  static ReactiveModel<T> createFromCallback<T>(T Function() creationFunction) {
    return Inject<T>(creationFunction).getReactive();
  }

  ///Functional injection of a primitive, enum or object.
  ///
  ///* Required parameters:
  ///  * [creationFunction]:  (positional parameter) a callback that
  /// creates an instance of the injected object
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [onError]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  static Injected<T> inject<T>(
    T Function() creationFunction, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
  }) {
    return InjectedImp<T>(
      creationFunction,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      undoStackLength: undoStackLength,
    );
  }

  ///Functional injection of a [Future].
  ///
  ///* Required parameters:
  ///  * [creationFunction]:  (positional parameter) a callback that return a [Future].
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily invoke the Future. Default value is true.
  static Injected<T> injectFuture<T>(
    Future<T> Function() creationFunction, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
    T initialValue,
    bool isLazy = true,
  }) {
    return InjectedFuture<T>(
      creationFunction,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      isLazy: isLazy,
      initialValue: initialValue,
      undoStackLength: undoStackLength,
    );
  }

  ///Functional injection of a [Stream].
  ///
  ///* Required parameters:
  ///  * [creationFunction]:  (positional parameter) a callback that return a [Stream].
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily invoke the Future. Default value is true.
  ///   * [watch]: callback to determine the parameter to watch and do not emit a notification
  /// unless they changed.
  static Injected<T> injectStream<T>(
    Stream<T> Function() creationFunction, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
    T initialValue,
    bool isLazy = true,
    Function(T s) watch,
  }) {
    return InjectedStream<T>(
      creationFunction,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      isLazy: isLazy,
      watch: watch,
      initialValue: initialValue,
      undoStackLength: undoStackLength,
    );
  }

  ///Functional injection of flavors (environments).
  ///
  ///* Required parameters:
  ///  * [impl]:  (positional parameter) Map of the implementations of the interface.
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily execute the impl callback. Default value is true.
  static Injected<T> injectFlavor<T>(
    Map<dynamic, FutureOr<T> Function()> impl, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
    T initialValue,
    bool isLazy = true,
  }) {
    return InjectedInterface<T>(
      impl,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      initialValue: initialValue,
      undoStackLength: undoStackLength,
      isLazy: isLazy,
    );
  }

  ///Functional injection of a computed model.
  ///
  ///The model
  ///
  ///* Required parameters:
  ///  * [impl]:  (positional parameter) Map of the implementations of the interface.
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily execute the compute method. Default value is true.
  static Injected<T> injectComputed<T>({
    T Function(T s) compute,
    List<Injected<dynamic>> asyncDependsOn,
    Stream<T> Function(T s) computeAsync,
    bool autoDisposeWhenNotUsed = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    T initialState,
    bool Function(T s) shouldCompute,
    int undoStackLength,
    bool isLazy = true,
  }) {
    return InjectedComputed<T>(
      compute: compute,
      computeAsync: computeAsync,
      asyncDependsOn: asyncDependsOn,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      initialState: initialState,
      shouldCompute: shouldCompute,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      undoStackLength: undoStackLength,
      isLazy: isLazy,
    );
  }

  ///Clean and dispose all Injected model;
  ///
  ///Although Injected models are auto cleaned, sometimes, we need to
  ///manually clean the Injected models especially in tests.
  static void disposeAll() {
    cleanInjector();
  }

  ///Create a [ReactiveModel] from future.
  static ReactiveModel<T> future<T>(
    Future<T> future, {
    dynamic name,
    T initialValue,
    List<dynamic> filterTags,
  }) {
    return ReactiveModel<T>.future(
      future,
      name: name,
      initialValue: initialValue,
      filterTags: filterTags,
    );
  }

  ///Create a [Stream] from future.
  static ReactiveModel<T> stream<T>(
    Stream<T> stream, {
    dynamic name,
    T initialValue,
    List<dynamic> filterTags,
    Object Function(T) watch,
  }) {
    return ReactiveModel<T>.stream(
      stream,
      name: name,
      initialValue: initialValue,
      filterTags: filterTags,
      watch: watch,
    );
  }

  ///Get the [ReactiveModel] singleton of an injected model.
  static ReactiveModel<T> get<T>({
    dynamic name,
    bool silent,
    BuildContext context,
  }) {
    final rm = Injector.getAsReactive<T>(
      name: name,
      silent: silent,
    );
    if (rm != null && context != null) {
      (rm as ReactiveModelImp).contextSubscription(context);
    }
    return rm;
  }

  ///get the model that is sending the notification
  static ReactiveModel get notified =>
      StatesRebuilderInternal.getNotifiedModel();

  static BuildContext _context;

  ///Get an active [BuildContext].
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static BuildContext get context {
    if (_context != null) {
      return _context;
    }
    // assert(
    //   InjectorState.contextSet.isNotEmpty,
    //   'No `BuildContext` is found. To get a valid `BuildContext` you have to '
    //   'use at least one of the following widgets under the the `MaterialApp` widget:\n'
    //   '`UseInjected`, `StateBuilder`, `WhenRebuilder`, `WhenRebuilderOR` or `Injector`',
    // );
    if (InjectorState.contextSet.isEmpty) {
      return null;
    }
    if (InjectorState.contextSet.last?.findRenderObject()?.attached != true) {
      InjectorState.contextSet.removeLast();
      return context;
    }

    return context = InjectorState.contextSet.last;
  }

  static set context(BuildContext context) {
    _context = context;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        return _context = null;
      },
    );
  }

  ///get The state for a [Navigator] widget.
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static NavigatorState get navigator {
    try {
      return Navigator.of(context);
    } catch (e) {
      rethrow;
    }
  }

  static MediaQueryData _mediaQuery;

  ///Get the [ScaffoldState]
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static ScaffoldState get scaffold {
    return Scaffold.of(context);
  }

  ///A callBack that exposes an active [BuildContext]
  ///
  ///  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static dynamic show(void Function(BuildContext context) fn) {
    return fn(context);
  }

  ///if true, An informative message is printed in the consol,
  ///showing the model being sending the Notification,
  ///
  ///See : [debugWidgetsRebuild], [debugError] and [debugErrorWithStackTrace]

  static bool debugPrintActiveRM = false;

  ///Consol log information about the widgets that have just rebuild
  ///
  ///See : [debugPrintActiveRM], [debugError] and [debugErrorWithStackTrace]
  static bool debugWidgetsRebuild = false;

  ///If true , print error message
  ///
  ///As states_rebuilder can catches errors, bu using [debugError]
  ///you can console log them.
  ///
  ///Default value is false
  ///
  ///See : [debugPrintActiveRM], [debugWidgetsRebuild] and [debugErrorWithStackTrace]
  static bool debugError = false;

  ///If true (default), print error message and stack trace
  ///
  ///Default value is false
  ///
  ///See : [debugPrintActiveRM], [debugWidgetsRebuild] and [debugError]
  static bool debugErrorWithStackTrace = false;

  static void Function(dynamic e, StackTrace s) errorLog;
}
