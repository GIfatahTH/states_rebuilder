import 'dart:async';

import 'package:flutter/material.dart';

import 'inject.dart';
import 'injector.dart';
import 'on_set_state_listener.dart';
import 'state_builder.dart';
import 'states_rebuilder.dart';
import 'when_connection_state.dart';
import 'when_rebuilder_or.dart';

///An abstract class that defines the reactive environment.
///
///`states_rebuilder` is based on the concept of [ReactiveModel].
///
///Pure dart models (or Blocs, or Stores) can be injected globally using the [Injector].
///To obtained the injected ReactiveModel singleton, you use :
///```dart
/// final modelRM = Injector.getAsReactive<T>();
/// //or more concisely:
/// final modelRM = ReactiveModel<T>();
/// // or even more concisely (since 1.15.0 release):
/// final modelRM = RM.get<T>();
///```
///
///In another hand, [ReactiveModel] can can be created locally.
///```dart
/////creating a reactive model form integer
///final counterRM = ReactiveModel<int>.create(0);
///// or more concisely (since 1.15.0 release)
///final counterRM = RM.create<int>(0);
///```
///
///with `states_rebuilder` we can locally create `ReactiveModel` from primitive values, objects, futures or streams.
///
///To consume the created `ReactiveModel`, we use one of the available widget observers : [StateBuilder], [WhenRebuilder], [WhenRebuilderOr] or [OnSetStateListener].
///
///
///[ReactiveModel] adds the following getters and methods:
///
///* To trigger an event : [setState], [setValue]
///
///* To get the current state : [state],[value]
///
///* For streams and futures: [subscription],  [snapshot].
///
///* Far asynchronous tasks :[connectionState], [hasError], [error], [hasData].
///
///and many more...
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
  factory ReactiveModel.stream(Stream<T> stream,
      {dynamic name,
      T initialValue,
      List<dynamic> filterTags,
      Object Function(T) watch}) {
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
  factory ReactiveModel.future(Future<T> future,
      {dynamic name, T initialValue, List<dynamic> filterTags}) {
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
  ///It returns a callback for unsubscription
  void Function() listenToRM(void Function(ReactiveModel<T> rm) fn);

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
  void resetToIdle();

  ///Rest the async connection state to [hasData]
  void resetToHasData();

  ///Holds data to be sent between reactive singleton and reactive new instances.
  dynamic get joinSingletonToNewData;

  /// Mutate the state of the model and notify observers.
  ///
  /// [fn] takes the current state as argument. You can optionally define
  /// a list of [StateBuilder] [filterTags] to be notified after state mutation.
  ///
  /// To limit the rebuild process to a particular set of model instance variables use [watch].
  ///
  /// If you want to catch error define [catchError] to be true
  ///
  /// With [onSetState] you can define callBacks to be executed after mutating the state such as Navigation,
  /// show dialog or SnackBar.
  ///
  /// [onRebuildState] is similar to [onSetState] except that it is executed after
  /// the rebuilding process is completed.
  ///
  ///[onData] callback to be executed when ReactiveModel has data.
  ///
  ///[onError] callback to be executed when ReactiveModel has data.
  ///
  /// [watch] is a function that returns a single model instance variable or a list of
  /// them. The rebuild process will be triggered if at least one of
  /// the return variable changes. Returned variable must be either a primitive variable,
  /// a List, a Map or a Set.To use a custom type, you should override the `toString` method to reflect
  /// a unique identity of each instance.
  /// If it is not defined all listener will be notified when a new state is available.
  ///
  /// To notify all reactive instances created from the same [Inject] set [notifyAllReactiveInstances] true.
  ///
  /// [joinSingleton] used to define how new reactive instances will notify and modify the state of the reactive singleton
  Future<void> setState(
    Function(T s) fn, {
    bool catchError,
    Object Function(T state) watch,
    List<dynamic> filterTags,
    List<dynamic> seeds,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    void Function(BuildContext context, T model) onData,
    dynamic Function() joinSingletonToNewData,
    bool joinSingleton = false,
    bool notifyAllReactiveInstances = false,
    bool setValue = false,
    bool silent = false,
    bool shouldAwait = false,
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
    Object Function(T s) watch,
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
  String type();
}

///
abstract class RM {
  ///Create a [ReactiveModel] from primitives or any object
  static ReactiveModel<T> create<T>(T model) {
    final T _model = model;
    // assert(T != dynamic);
    return ReactiveModel<T>.create(_model);
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
  }) {
    return Injector.getAsReactive<T>(
      name: name,
      silent: silent,
    );
  }

  ///if true, An informative message is printed in the consol, showing the model being sending the Notification,
  static bool debugPrintActiveRM = false;

  ///Consol log information about the widgets that have just rebuild
  static bool debugWidgetsRebuild = false;

  ///get the model that is sending the notification
  static ReactiveModel get notified =>
      StatesRebuilderInternal.getNotifiedModel();
}
