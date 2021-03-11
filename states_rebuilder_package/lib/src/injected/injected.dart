part of '../reactive_model.dart';

///A Wrapper class that encloses the state of the model we want to Inject. The
///state can be mutable or immutable.
///
///Injected model can be instantiated globally or as a member of classes. They
///can be instantiated inside the build method without losing the state after
///rebuilds.
///
///
///* **Injected instantiation:**
///To instantiate an Injected model, you use [RM.inject], [RM.injectFuture],
///[RM.injectStream] or [RM.injectFlavor].
///
///
///* **Injected lifecycle:**
///The state wrapped by the Injected model has a lifecycle. It is created when
///first used and destroyed when no longer used even if it is declared globally.
///Between the creation and the destruction of the state, it can be listened to
///and mutated to notify its registered listeners.
///
///
///* **Injected state and null safety:**
///The state of an injected model is null safe, that is it can not be null. For
///this reason the initial state will be inferred by the library, and in case
///it is not, it must be defined explicitly. The initial state of primitives is
///inferred as follows: (int: 0, double, 0.0, String:'', and bool: false). For
///other non-primitive objects the initial state will be the first created
///instance.
///
///
///* **Listening to an Injected:**
///To listen to an Injected model you can use one of the following options:
///[ReactiveModelBuilder.listen], [ReactiveModelBuilder.futureBuilder],
///[ReactiveModelBuilder.streamBuilder], [ReactiveModelBuilder.rebuilder],
///[ReactiveModelBuilder.whenRebuilder], and
///[ReactiveModelBuilder.whenRebuilderOr].
///
///
///* **Injected state mutation:**
///To mutate the state and notify listeners, you use [ReactiveModel.state]
///setter, [ReactiveModel.setState], or[ ReactiveModel.toggle] if the state is
///bool.
///You can also notify listeners without changing the state using
///[ReactiveModel.notify]. You can also refresh the state to its initial state
///and reinvoke the creation function then notify listeners using
///[ReactiveModel.refresh].
///
///
///* **Injected state cleaning:**
///When the state is disposed of, its list of listeners is cleared, and if the
///state is waiting for a Future or subscribed to a Stream, it will cancel them
///to free resources.
///
///
///* **State persistence:**
///Injected state can be persisted using [PersistState]. By default the state
///is persisted each time the state is mutated. You can set it to persist
///manually or when the state is disposed. You can also throttle state
///persistence for the time you want.
///
///
///* **Undo redo state mutation:**
///You can undo or redo state mutation by defining the `undoStackLength`
///parameter of [RM.inject] [RM.injectFuture], [RM.injectStream] or
///[RM.injectFlavor]. After state mutation you can redo it using
///[ReactiveModelUndoRedoState.undoState] and redo it using
///[ReactiveModelUndoRedoState.redoState].
///
///
///* **Injected model dependence**
///Injected models can depend on other Injected models and recalculate its
///state and notify its listeners whenever any of its of the Inject model that
///it depends on emits a notification.
///
///
///* **Injected mock for testing:**
///Injected model can be easily mocked to fake implementation in tests using :
///[Injected.injectMock], [Injected.injectFutureMock],
///or [Injected.injectStreamMock].
///
///
abstract class Injected<T> implements ReactiveModel<T> {
  DependsOn<T>? _dependsOn;
  bool _dependenciesAreSet = false;
  Timer? _dependentDebounceTimer;
  void Function(T s)? _onDisposed;

  void _setDependence() {
    if (_dependsOn == null || _dependenciesAreSet) {
      return;
    }
    _dependenciesAreSet = true;

    for (var inj in _dependsOn!.injected) {
      inj._resolveDependencies<T>(this);
    }
    _resolveMergedState<T>(this, false);
  }

  void _resolveDependencies<T>(Injected<T>? dependent) {
    if (dependent != null && dependent != this) {
      assert(
        _dependsOn?.injected.contains(dependent) != true,
        // '$runtimeType depends on ${_dependsOn.runtimeType} and '
        // '${_dependsOn.runtimeType} depends on $runtimeType',
      );
      _initialize();

      final refreshDisposer = addToRefresh(() {
        dependent._state = dependent._nullState;
      });
      final disposer = _listenToRMForStateFulWidget(
        (rm, tags, isOnCrud) {
          if (isOnCrud) {
            return;
          }
          if (dependent._dependsOn!.shouldNotify?.call(dependent._state) ==
              false) {
            return;
          }

          if (dependent._dependsOn!.debounceDelay > 0) {
            _subscription?.cancel();
            _dependentDebounceTimer?.cancel();
            _dependentDebounceTimer = Timer(
              Duration(milliseconds: dependent._dependsOn!.debounceDelay),
              () {
                // dependent._dependsOn!.debounceDelay = 0;
                _resolveMergedState<T>(dependent);
                _dependentDebounceTimer = null;
              },
            );
            return null;
          } else if (dependent._dependsOn!.throttleDelay > 0) {
            if (_dependentDebounceTimer != null) {
              return null;
            }
            _dependentDebounceTimer = Timer(
              Duration(milliseconds: dependent._dependsOn!.throttleDelay),
              () {
                _dependentDebounceTimer = null;
              },
            );
          }

          _resolveMergedState<T>(dependent);
        },
      );

      dependent.addToCleaner(() {
        disposer();
        refreshDisposer();
      });
    }
  }

  void dispose() {
    if (_cleaner.isNotEmpty) {
      _clean(true);
    }
  }

  @override
  void _onInitState() {
    _isDisposed = false;
    if (_debugPrintWhenNotifiedPreMessage != null) {
      subscribeToRM((rm) {
        final post = rm._snapState.isIdle ? '- Refreshed' : '';
        print('states_rebuilder:: $rm $post');
      });
    }
    assert(() {
      if (_debugPrintWhenNotifiedPreMessage != null ||
          RM._printAllInitDispose) {
        final pre = _debugPrintWhenNotifiedPreMessage ?? '';
        print('states_rebuilder:: $pre Injected<$T>(__INITIALIZED__)');
      }
      return true;
    }());
    RM.printInjected?.call(_snapState);
    final remove = _addToInjectedModels(this);
    addToCleaner(
      () {
        remove();
        _onDisposeState();
      },
      true,
    );
  }

  bool _isDisposed = false;
  void _onDisposeState() {
    assert(() {
      if (_debugPrintWhenNotifiedPreMessage != null ||
          RM._printAllInitDispose) {
        final pre = _debugPrintWhenNotifiedPreMessage ?? '';
        print('states_rebuilder:: $pre Injected<$T>(__DISPOSED__)');
      }
      return true;
    }());
    assert(!_isDisposed);

    _isDisposed = true;
    RM.printInjected?.call(_snapState);
    if (!_isInitialized) {
      return;
    }
    _onDisposed?.call(_state!);
    if (_coreRM.persistanceProvider?.persistOn == PersistOn.disposed) {
      persistState();
    }
    _cleanUpState();
  }

  Disposer _addToInheritedInjects(Injected<T> inj) {
    _state = inj.state;
    _nullState = inj._nullState;
    _inheritedInjects.add(inj);

    inj.subscribeToRM((rm) {
      if (_inheritedInjects.any((e) => e._snapState.isWaiting)) {
        if (_isRefreshing) {
          //while refreshing from global do change  the state
          //and do not rebuild
          //TODO to check if can be removed
          _coreRM._snapState = _coreRM._snapState._copyToIsWaiting();
          return;
        }
        return _coreRM._setToIsWaiting(
          infoMessage: 'Inherited Child',
        );
      }
      final errorRM =
          _inheritedInjects.firstWhereOrNull((e) => e._snapState.hasError);
      if (errorRM != null) {
        if (_isRefreshing) {
          _coreRM._snapState = _coreRM._snapState._copyToHasError(
            errorRM.error,
            errorRM.onErrorRefresher,
            stackTrace: errorRM.stackTrace,
          );
          return;
        }
        return _coreRM._setToHasError(
          errorRM.error,
          errorRM.stackTrace!,
          onErrorRefresher: errorRM.onErrorRefresher!,
        );
      }
      if (!_isFirstInitialized) {
        _onInitState();
        _onInitialized?.call(state);
        _isFirstInitialized = true;
        _isInitialized = true;
      }
      if (_isRefreshing) {
        _coreRM._snapState = _coreRM._snapState._copyWith(
          connectionState: rm.connectionState,
          data: rm.state,
        );
        return;
      }
      // if (!rm._snapState.isIdle) {
      return _coreRM._setToHasData(rm.state);
      // }
    });
    return () {
      _inheritedInjects.remove(inj);
      if (_inheritedInjects.isEmpty && !hasObservers) {
        _clean();
      }
    };
  }

  ///{@template inherited}
  ///Provide the injected model using an [InheritedWidget] that wraps its state.
  ///
  ///By default the [InheritedWidget] holds the state of the injected model,
  ///but this can be overridden using the [stateOverride] parameter.
  ///
  ///Child widgets can obtain the wrapped state using `.of(context)` or
  ///`.call(context)` methods.
  ///
  ///* `myModel.of(context)` looks up in the widget tree to find the state of
  ///`myModel` and register  the `BuildContext` to rebuild when `myModel` is
  ///notified.
  ///
  ///* `myModel.call(context) or myModel(context)` looks up in the widget tree
  ///to find the injected model `myModel` without registering the `BuildContext`.
  ///
  ///ex:
  ///
  ///```dart
  ///final counter1 = RM.inject<int>(()=> 0);
  ///final counter2 = RM.inject<int>(()=> 0);
  ///
  ///class MyApp extends StatelessWidget{
  ///
  /// Widget build(context){
  ///  counter1.inherited(
  ///   builder: (context):{
  ///     return counter2.inherited(
  ///       builder: (context){
  ///         //Getting the counters state using `of` will
  ///         //resister this BuildContext
  ///         final int counter1State = counter1.of(context);
  ///         //Although both counters are of the same type we get
  ///         //the right state
  ///         final int counter2State = counter2.of(context);
  ///
  ///
  ///         //Getting the counters using the `call` method will
  ///         //not register this BuildContext
  ///          final Injected<int> counter1 = counter1(context);
  ///          final Injected<int> counter2 = counter2(context);
  ///       }
  ///     )
  ///   }
  ///  )
  /// }
  ///}
  ///```
  ///
  /// * **Required parameters**:
  ///     * **builder**: Callback to be rendered. It exposed the [BuildContext].
  /// * Optional parameters:
  ///     * **stateOverride**: CallBack to override the exposed state.
  ///     * **connectWithGlobal**: If state is overridden, whether to mutate the
  /// global
  ///     * **debugPrintWhenNotifiedPreMessage**: if not null, print an
  /// informative message when this model is notified in the debug mode.The
  /// entered message will pré-append the debug message. Useful if the type
  /// of the injected
  /// model is primitive to distinguish
  /// {@endtemplate}
  Widget inherited({
    required Widget Function(BuildContext) builder,
    Key? key,
    FutureOr<T> Function()? stateOverride,
    bool? connectWithGlobal,
    String? debugPrintWhenNotifiedPreMessage,
  }) {
    return _InheritedState<T>(
      key: key,
      builder: (context) => builder(context),
      globalInjected: this,
      reInheritedInjected: stateOverride == null ? this : null,
      state: stateOverride,
      connectWithGlobal:
          stateOverride == null ? false : connectWithGlobal ?? true,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  ///Provide the Injected model to another widget tree branch.
  Widget reInherited({
    Key? key,
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool connectWithGlobal = true,
    String? debugPrintWhenNotifiedPreMessage,
  }) {
    final globalInject = (context
            .getElementForInheritedWidgetOfExactType<_InheritedInjected<T>>()
            ?.widget as _InheritedInjected<T>)
        .globalInjected;
    return _InheritedState<T>(
      key: key ?? Key('$context'),
      builder: (context) => builder(context),
      globalInjected: globalInject,
      reInheritedInjected: globalInject(context),
      connectWithGlobal: connectWithGlobal,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  ///Obtain the state from the nearest [InheritedWidget] inserted using [inherited].
  ///
  ///The [BuildContext] used, will be registered so that when this Injected model emits
  ///a notification, the [Element] related the the [BuildContext] will rebuild.
  ///
  ///If you want to obtain the state without registering use the [call] method.
  ///
  ///```dart
  ///myModel.of(context); // Will return the state and register the BuildContext.
  ///myModel(context); // Will return the Injected model and do not register the BuildContext.
  ///```
  ///
  T? of(BuildContext context, {bool defaultToGlobal = false}) {
    final _inheritedInjected =
        context.dependOnInheritedWidgetOfExactType<_InheritedInjected<T>>();

    if (_inheritedInjected != null) {
      if (_inheritedInjected.globalInjected == this) {
        return _inheritedInjected.injected.state;
      } else {
        return of(
          _inheritedInjected.context,
          defaultToGlobal: defaultToGlobal,
        );
      }
    }
    if (defaultToGlobal) {
      return state;
    }
    return null;
  }

  ///Obtain the Injected model from the nearest [InheritedWidget] inserted using [inherited].
  ///
  ///The [BuildContext] used, will not be registered.
  ///
  ///If you want to obtain the state and  register it use the [of] method.
  ///
  ///```dart
  ///myModel.of(context); // Will return the state and register the BuildContext.
  ///myModel(context); // Will return the Injected model and do not register the BuildContext.
  ///```
  ///
  Injected<T>? call(BuildContext context, {bool defaultToGlobal = false}) {
    final _inheritedInjected = context
        .getElementForInheritedWidgetOfExactType<_InheritedInjected<T>>()
        ?.widget as _InheritedInjected<T>?;

    if (_inheritedInjected != null) {
      if (_inheritedInjected.globalInjected == this) {
        return _inheritedInjected.injected;
      } else {
        return call(
          _inheritedInjected.context,
          defaultToGlobal: defaultToGlobal,
        );
      }
    }
    if (defaultToGlobal) {
      return this;
    }
    return null;
  }

  //
  dynamic Function(ReactiveModel<T> rm)? _cachedMockCreator;

  ///Use to prevent invoking onSigned and onUnSigned when
  ///injectAuth is mocked using injectMock
  bool _isInjectMock = false;

  ///Inject a fake implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake creation function
  void injectMock(T Function() creationFunction) {
    _isInjectMock = true;
    _cachedMockCreator ??= (_) => creationFunction();
    _cleanUpState((_) => creationFunction());

    addToCleaner(() {
      _cleanUpState(_cachedMockCreator);
    });
  }

  ///Inject a fake stream implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake stream
  void injectStreamMock(Stream<T> Function() creationFunction) {
    _cachedMockCreator ??= (_) => creationFunction();
    _cleanUpState((_) => creationFunction());
    addToCleaner(() => _cleanUpState(_cachedMockCreator));
  }

  ///Inject a fake future implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake future
  void injectFutureMock(Future<T> Function() creationFunction) {
    _cachedMockCreator ??= (_) => creationFunction().asStream();
    // assert(this is AsyncInjected<T>);
    _cleanUpState((_) => creationFunction().asStream());
    addToCleaner(() => _cleanUpState(_cachedMockCreator));
  }
}

Set<Injected> get injectedModels => _injectedModels;

final _injectedModels = <Injected>{};
Disposer _addToInjectedModels(Injected inj) {
  _injectedModels.add(inj);
  return () {
    _injectedModels.remove(inj);
  };
}

void _resolveMergedState<T>(Injected<T> dependent, [bool shouldNotify = true]) {
  if (dependent._dependsOn!.injected.any((e) => e._snapState.isWaiting)) {
    return dependent._coreRM._setToIsWaiting(
      shouldNotify: shouldNotify,
      infoMessage: 'Dependent State',
    );
  }
  final errorRM = dependent._dependsOn!.injected
      .firstWhereOrNull((e) => e._snapState.hasError);
  if (errorRM != null) {
    if (shouldNotify) {
      dependent._coreRM._setToHasError(
        errorRM.error,
        errorRM.stackTrace!,
        onErrorRefresher: errorRM.onErrorRefresher!,
      );
    } else {
      dependent._snapState = dependent._snapState._copyToHasError(
        errorRM.error,
        errorRM.onErrorRefresher!,
        stackTrace: errorRM.stackTrace!,
      );
    }
  } else if (dependent._dependsOn!.injected.any((e) => e._snapState.hasData)) {
    if (shouldNotify) {
      dependent._snapState = dependent._snapState._copyWith(
        infoMessage: 'Dependent',
      );
      dependent.refresh(true);
    }
  } else {
    dependent._snapState = dependent.snapState.copyToIsIdle();
  }
}
