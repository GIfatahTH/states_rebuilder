import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';
import 'injector.dart';

///An abstract class that defines the reactive environment.
///
///With `states_rebuilder` you can use pure dart class for your business logic,
///and reactivity is implicitly add by `states_rebuilder` using [Injector.getAsReactive] method.
///
///[ReactiveModel] adds the following getters and methods:
///
///* To trigger an event : [setState]
///
///* To get the current state : [state]
///
///* For streams and futures: [subscription],  [snapshot].
///
///* Far asynchronous tasks :[connectionState], [hasError], [error], [hasData].
///
///* For defining custom state status other than [connectionState] : [customStateStatus].
///
///* To join reactive singleton with new singletons: [joinSingletonToNewData].
abstract class ReactiveModel<T> extends StatesRebuilder {
  ///An abstract class that defines the reactive environment.
  ReactiveModel([this._inject]);

  final Inject<T> _inject;

  /// A representation of the most recent state (instance) of the injected model.
  AsyncSnapshot<T> snapshot;

  T _state;

  ///The state of the injected model.
  T get state => snapshot?.data ?? _state;

  set state(T data) {
    _state = data;
    snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _state);
  }

  ///The stream subscription. It is not null for injected streams or futures.
  StreamSubscription<T> get subscription => null;

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
  ConnectionState get connectionState => snapshot.connectionState;

  ///Where the reactive state is in the initial state
  ///
  ///It is a shortcut of : this.connectionState == ConnectionState.none
  bool get isIdle => connectionState == ConnectionState.none;

  ///Where the reactive state is in the waiting for an asynchronous task to resolve
  ///
  ///It is a shortcut of : this.connectionState == ConnectionState.waiting
  bool get isWaiting => connectionState == ConnectionState.waiting;

  ///Returns whether this state contains a non-null [error] value.
  bool get hasError => snapshot?.hasError;

  ///Returns whether this snapshot contains a non-null [AsyncSnapshot.data] value.
  ///Unlike in [AsyncSnapshot], hasData has special meaning here.
  ///It means that the [connectionState] is [ConnectionState.done] with no error.
  bool get hasData => !hasError && connectionState == ConnectionState.done;

  ///The latest error object received by the asynchronous computation.
  dynamic get error => snapshot?.error;

  /// custom status of state (ex: "ready" , "paused"; "plying") other than those defined by [connectionState]
  ///
  /// The best place to change [customStateStatus] is inside the callback of the onSetState parameters of [setState] method.
  dynamic customStateStatus;

  ///Holds data to be sent between reactive singleton and reactive new instances.
  dynamic joinSingletonToNewData;

  JoinSingleton get _joinSingletonFromInject => _inject?.joinSingleton;

  List<ReactiveModel<T>> get _newReactiveInstanceList =>
      _inject?.newReactiveInstanceList;

  ReactiveModel<dynamic> get _reactiveSingleton => _inject?.reactiveSingleton;

  //holds the  context of  the last call of Injector.get(context:context) or Injector.getAsReactive(context: context)
  BuildContext _lastContext;

  ///Exhaustively switch over all the possible statuses of [connectionState].
  ///Used mostly to return [Widget]s.
  R whenConnectionState<R>({
    @required R Function() onIdle,
    @required R Function() onWaiting,
    @required R Function(T state) onData,
    @required R Function(dynamic error) onError,
  }) {
    if (this.isIdle) {
      return onIdle();
    }
    if (this.hasError) {
      return onError(this.error);
    }
    if (this.isWaiting) {
      return onWaiting();
    }
    return onData(this.state);
  }

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
  /// [watch] is a function that returns a single model instance variable or a list of
  /// them. The rebuild process will be triggered if at least one of
  /// the return variable changes. Returned variable must be either a primitive variable,
  /// a List, a Map or a Set.To use a custom type, you should override the `toString` method to reflect
  /// a unique identity of each instance.
  /// If it is not defined all listener will be notified when a new state is available.
  ///
  /// To notify all reactive instances created from the same [Inject] set [notifyAllReactiveInstances] true.
  ///
  /// [joinSingletonWith] used to define how new reactive instances will notify and modify the state of the reactive singleton
  Future<void> setState(
    Object Function(T model) fn, {
    List<dynamic> filterTags,
    bool catchError,
    dynamic Function(T state) watch,
    void Function(BuildContext context) onSetState,
    void Function(BuildContext context) onRebuildState,
    void Function(BuildContext context, dynamic error) onError,
    dynamic joinSingletonToNewData,
    JoinSingleton joinSingletonWith,
    bool notifyAllReactiveInstances = false,
  }) async {
    assert(() {
      if (_inject == null) {
        throw Exception('''

Most probably, you are calling setState on a reactive model injected using `Inject.stream` or `Inject.future`.
This is not allowed, because setState method of a reactive model injected using `Inject.stream` or `Inject.future` is called automatically whenever the stream emits a value.

            ''');
      }
      return true;
    }());

    if (catchError == null) {
      catchError = false || onError != null || whenConnectionState != null;
    }

    final String before = watch != null ? watch(state)?.toString() : null;

    final Function(BuildContext context) _onSetState = (BuildContext context) {
      //context is from the last subscribed StateBuilder
      //_lastContext is from the last call of Injector.get(context:context) or Injector.getAsReactive(context: context)
      assert(() {
        if (context == null && _lastContext == null) {
          final runtimeType = '${this.runtimeType}'
              .replaceAll('ReactiveStatesRebuilder<', '')
              .replaceAll('>', '');
          throw Exception(
            '''

***No observer is subscribed yet***
| There is no observer subscribed to this observable $runtimeType model.
| To subscribe a widget you use:
| 1- StateRebuilder for an already defined:
|   ex:
|   StatesRebuilder(
|     models: [${runtimeType}instance],
|     builder : ....
|   )
| 2- Injector.getAsReactive<$runtimeType>(context : context). for implicit reactivity.
| 3- StateRebuilder for new reactive environment:
|   ex:
|   StatesRebuilder<$runtimeType>(
|     builder : ....
|   )
| 4- StatesWithMixinBuilder. similar to StateBuilder.
''',
          );
        }
        return true;
      }());

      if (onSetState != null) {
        onSetState(context ?? _lastContext);
      }

      if (onRebuildState != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onRebuildState(context ?? _lastContext);
        });
      }

      if (onError != null && hasError) {
        onError(context ?? _lastContext, error);
      }
    };

    this.joinSingletonToNewData = joinSingletonToNewData;

    try {
      final dynamic result = fn != null ? fn(state) as dynamic : null;
      if (result is Future) {
        snapshot = AsyncSnapshot<T>.withData(ConnectionState.waiting, state);
        try {
          _rebuildStates(
            tags: filterTags,
            onSetState: _onSetState,
            notifyAllReactiveInstances: notifyAllReactiveInstances,
            joinSingleton: joinSingletonWith,
          );
        } catch (e) {}
        await result;
      }
    } catch (e) {
      snapshot = AsyncSnapshot<T>.withError(ConnectionState.done, e);
      _rebuildStates(
        tags: filterTags,
        onSetState: _onSetState,
        notifyAllReactiveInstances: notifyAllReactiveInstances,
        joinSingleton: joinSingletonWith,
      );

      if (!catchError) {
        rethrow;
      }
      return;
    }
    snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, state);
    final String after = watch != null ? watch(state)?.toString() : '';

    //String in dart are immutable objects, which means that two strings with the same characters in the same order
    //share the same object.
    if (!identical(after, before)) {
      _rebuildStates(
        tags: filterTags,
        onSetState: _onSetState,
        notifyAllReactiveInstances: notifyAllReactiveInstances,
        joinSingleton: joinSingletonWith,
      );
    }
  }

  void _rebuildStates({
    List<dynamic> tags,
    void Function(BuildContext context) onSetState,
    bool notifyAllReactiveInstances = false,
    JoinSingleton joinSingleton,
  }) {
    if (this == _inject.reactiveSingleton) {
      _inject.rebuildInheritedWidget(
        tags,
        hasObservers ? null : (_) => onSetState(null),
      );
    }
    if (hasObservers || hasCustomObservers) {
      rebuildStates(tags, onSetState);
    }

    if (notifyAllReactiveInstances) {
      _notifyAllReactiveInstances(tags);
    }

    if (_reactiveSingleton != null) {
      if (_joinSingletonFromInject ==
              JoinSingleton.withCombinedReactiveInstances ||
          joinSingleton == JoinSingleton.withCombinedReactiveInstances) {
        _reactiveSingleton?.snapshot = _getCombinedSnapshot();
        if (joinSingletonToNewData != null) {
          _reactiveSingleton?.joinSingletonToNewData = joinSingletonToNewData;
        }
        joinSingletonToNewData = null;
        _notifyReactiveSingleton(tags);
      }

      if (_joinSingletonFromInject == JoinSingleton.withNewReactiveInstance ||
          joinSingleton == JoinSingleton.withNewReactiveInstance) {
        _reactiveSingleton?.snapshot = snapshot;
        if (joinSingletonToNewData != null) {
          _reactiveSingleton?.joinSingletonToNewData = joinSingletonToNewData;
        }
        joinSingletonToNewData = null;
        _notifyReactiveSingleton(tags);
      }
    }
  }

  void _notifyAllReactiveInstances(List<dynamic> tags) {
    if (_reactiveSingleton != null) {
      _notifyReactiveSingleton(tags);
    }
    if (_newReactiveInstanceList != null) {
      for (final ReactiveModel<T> reactiveInstance
          in _newReactiveInstanceList) {
        reactiveInstance.rebuildStates(tags);
      }
    }
  }

  void _notifyReactiveSingleton(List<dynamic> tags) {
    if (_reactiveSingleton.hasObservers == true ||
        _reactiveSingleton.hasCustomObservers) {
      _reactiveSingleton?.rebuildStates(tags);
    }
    _inject.rebuildInheritedWidget(tags, null);
  }

  AsyncSnapshot<T> _getCombinedSnapshot() {
    //First priority : The combined [ReactiveModel.hasError] is true if at least one of the new instances has error
    if (hasError) {
      return snapshot;
    }

    ReactiveModel<T> _model =
        _newReactiveInstanceList?.firstWhere((ReactiveModel<dynamic> model) {
      return model.hasError;
    }, orElse: () => null);

    if (_model != null) {
      return _model.snapshot;
    }

    //Second priority The combined [ReactiveModel.connectionState] if awaiting if at least one of the new instances is awaiting.
    if (connectionState == ConnectionState.waiting) {
      return snapshot;
    }

    _model =
        _newReactiveInstanceList?.firstWhere((ReactiveModel<dynamic> model) {
      return model.connectionState == ConnectionState.waiting;
    }, orElse: () => null);

    if (_model != null) {
      return _model.snapshot;
    }

    final bool hasData =
        _newReactiveInstanceList?.every((ReactiveModel<dynamic> model) {
      return model.hasData;
    });

    //Third priority : The combined [ReactiveModel.connectionState] is 'none' if at least one of the new instances is 'none'.
    if (!hasData) {
      return AsyncSnapshot<T>.withData(ConnectionState.none, _state);
    }
    // Forth priority : The combined [ReactiveModel.hasDate] is true if it has no error, isn't awaiting  and is not in 'none' state.
    return AsyncSnapshot<T>.withData(ConnectionState.done, _state);
  }

  ///Add the reactive model in the inject new reactive models list.
  void addToReactiveNewInstanceList() {
    _newReactiveInstanceList?.add(this);
  }

  ///remove the reactive model in the inject new reactive models list.
  void removeFromReactiveNewInstanceList() {
    _newReactiveInstanceList?.remove(this);
  }

  ///Add context to [InheritedWidget] listeners
  ReactiveModel<T> of(BuildContext context) {
    final InheritedWidget model =
        context.dependOnInheritedWidgetOfExactType<InheritedInject<T>>();
    final InheritedInject<T> inheritedInject = model as InheritedInject<T>;
    _lastContext = context;
    return inheritedInject?.model;
  }

  ///Add context to [InheritedWidget] listeners. Static version
  static InheritedWidget staticOf<T>(BuildContext context) {
    final InheritedWidget model =
        context.dependOnInheritedWidgetOfExactType<InheritedInject<T>>();
    return model;
  }
}

///A package private class used to add reactive environment to models
class ReactiveStatesRebuilder<T> extends ReactiveModel<T> {
  ///A package private class used to add reactive environment to models
  ReactiveStatesRebuilder([Inject<T> inject]) : super(inject) {
    state = inject.getSingleton();
  }
}

///A package private class used to add reactive environment to Stream and future
class StreamStatesRebuilder<T> extends ReactiveModel<T> {
  ///A package private class used to add reactive environment to Stream and future

  StreamStatesRebuilder(this._singleton, this._inject$) {
    snapshot = AsyncSnapshot<T>.withData(ConnectionState.none, _initialData);
    _subscribe();
    cleaner(_unsubscribe);
  }

  final Stream<T> _singleton;
  T get _initialData => _inject$.initialValue;
  final Inject<T> _inject$;
  StreamSubscription<T> _subscription;
  bool _isDifferent = true;
  dynamic Function(T oldValue) get _watch => _inject$.watch;
  String _before;
  List<dynamic> get _tags => _inject$.tags;

  @override
  bool get hasData => snapshot.hasData;

  @override
  StreamSubscription<T> get subscription => _subscription;

  void _subscribe() {
    _subscription = _singleton.listen((T data) {
      if (_watch != null) {
        final String _after = _watch(data).toString();
        _isDifferent = !identical(_before, _after);
        _before = _after;
      }
      snapshot = AsyncSnapshot<T>.withData(ConnectionState.active, data);
      if (_isDifferent) {
        _inject$.rebuildInheritedWidget(_tags, null);
        if (hasObservers || hasCustomObservers) {
          rebuildStates(_tags);
        }
      }
    }, onError: (Object error) {
      snapshot = AsyncSnapshot<T>.withError(ConnectionState.active, error);
      _inject$.rebuildInheritedWidget(_tags, null);
      if (hasObservers || hasCustomObservers) {
        rebuildStates(_tags);
      }
    }, onDone: () {
      snapshot = snapshot.inState(ConnectionState.done);
      _inject$.rebuildInheritedWidget(_tags, null);
      if (hasObservers || hasCustomObservers) {
        rebuildStates(_tags);
      }
    }, cancelOnError: false);
    snapshot = snapshot.inState(ConnectionState.waiting);
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}
