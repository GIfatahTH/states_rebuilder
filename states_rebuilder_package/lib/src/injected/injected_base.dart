part of '../injected.dart';

///Basic class for injected models
abstract class Injected<T> {
  Function() _creationFunction;
  final bool _autoDisposeWhenNotUsed;
  final void Function(T s) _onData;
  final void Function(dynamic e, StackTrace s) _onError;
  final void Function() _onWaiting;
  final void Function(T s) _onInitialized;
  final void Function(T s) _onDisposed;
  final int _undoStackLength;
  final String _debugPrintWhenNotifiedPreMessage;
  String _name;
  Inject<T> _inject;
  dynamic Function() _cashedMockCreationFunction;

  ///Basic class for injected models
  Injected({
    bool autoDisposeWhenNotUsed = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    int undoStackLength,
    String debugPrintWhenNotifiedPreMessage,
  })  : _autoDisposeWhenNotUsed = autoDisposeWhenNotUsed,
        _onData = onData,
        _onError = onError,
        _onWaiting = onWaiting,
        _onInitialized = onInitialized,
        _onDisposed = onDisposed,
        _undoStackLength = undoStackLength,
        _debugPrintWhenNotifiedPreMessage = debugPrintWhenNotifiedPreMessage;
  final Set<Injected> _dependsOn = {};

  ReactiveModel<T> _rm;

  ///Get the [ReactiveModel] associated with the injected model
  ReactiveModel<T> get getRM => _stateRM;

  ///Get the [ReactiveModel] associated with this model.
  ReactiveModel<T> get _stateRM {
    if (_rm != null) {
      return _rm;
    }

    _resolveInject();
    _inject.isGlobal = true;

    _rm = _inject.getReactive();
    if (_undoStackLength != null) {
      _rm.undoStackLength = _undoStackLength;
    }
    _onInitialized?.call(_inject.getSingleton());
    if (_autoDisposeWhenNotUsed ?? true) {
      _rm.cleaner(dispose);
    }

    assert(() {
      if (_debugPrintWhenNotifiedPreMessage?.isNotEmpty != null) {
        (_rm as ReactiveModelInternal).listenToRMInternal((rm) {
          final Injected<T> injected =
              _functionalInjectedModels[rm.inject.getName()];
          print('[states_rebuilder] : $_debugPrintWhenNotifiedPreMessage'
              '${_debugPrintWhenNotifiedPreMessage.isEmpty ? "" : ": "}'
              '$injected');
        });
      }
      return true;
    }());

    if (_onWaiting != null || _onData != null || _onError != null) {
      (_rm as ReactiveModelInternal).listenToRMInternal(
        (rm) {
          final Injected<T> injected =
              _functionalInjectedModels[rm.inject.getName()];
          assert(injected != null);
          rm.whenConnectionState<void>(
            onIdle: () => null,
            onWaiting: () => injected._onWaiting?.call(),
            onData: (dynamic s) => injected._onData?.call(s as T),
            onError: (dynamic e) {
              //if setState has error override this _onError
              if (!(rm as ReactiveModelInternal).setStateHasOnErrorCallback) {
                injected._onError
                    ?.call(e, (rm as ReactiveModelInternal).stackTrace);
              }
            },
            catchError: injected._onError != null,
          );
        },
        listenToOnDataOnly: false,
      );
    }

    //
    assert(() {
      if (_debugPrintWhenNotifiedPreMessage?.isNotEmpty != null) {
        print(
            '[states_rebuilder] : $_debugPrintWhenNotifiedPreMessage${_debugPrintWhenNotifiedPreMessage.isEmpty ? "" : ": "}(initialized) $this');
      }
      return true;
    }());

    return _rm;
  }

  //used internally so not to call state and _resolveInject (as in toString)
  T _state;

  ///The state of the model.
  T get state {
    if (Injected._activeInjected?._dependsOn?.add(this) == true) {
      assert(
        !_dependsOn.contains(Injected._activeInjected),
        '$runtimeType depends on ${Injected._activeInjected.runtimeType} and '
        '${Injected._activeInjected.runtimeType} depends on $runtimeType',
      );
      _numberODependence++;
    }
    return null;
  }

  set state(T s) {
    _stateRM.state = s;
  }

  ///Get the async state of the model.
  Future<T> get stateAsync {
    state;
    return _stateRM.stateAsync;
  }

  ///The latest error object received by the asynchronous computation.
  dynamic get error => _rm?.error;

  ///Returns whether this state is in the hasDate state.
  bool get hasData => _rm?.hasData == true;

  ///Returns whether this state is in the error state.
  bool get hasError => _rm?.hasError == true;

  ///Returns whether this state is in the waiting state.
  bool get isWaiting => _rm?.isWaiting == true;

  Inject<T> _getInject();
  static Injected _activeInjected;
  void _resolveInject() {
    if (_inject != null) {
      return;
    }
    _functionalInjectedModels[_name] = this;
    _dependsOn.clear();

    final cashedInjected = Injected._activeInjected;
    Injected._activeInjected = this;
    final inj = _getInject();
    Injected._activeInjected = cashedInjected;
    _clearDependence = _dependsOn.isEmpty
        ? null
        : () {
            for (var depend in _dependsOn) {
              depend._numberODependence--;
              if (depend._rm?.hasObservers != true &&
                  depend._numberODependence < 1) {
                depend.dispose();
              }
            }
          };
    _inject = inj;
  }

  int _numberODependence = 0;
  //clean models that depend on this
  void Function() _clearDependence;
  void _dispose() {
    assert(() {
      if (_debugPrintWhenNotifiedPreMessage?.isNotEmpty != null) {
        print(
            '[states_rebuilder] : $_debugPrintWhenNotifiedPreMessage${_debugPrintWhenNotifiedPreMessage.isEmpty ? "" : ": "}(disposed) $this');
      }
      return true;
    }());
    _onDisposed?.call(_state);
    _clearDependence?.call();
    _rm = null;
    _inject = null;
    if (_cashedMockCreationFunction != null) {
      _creationFunction = _cashedMockCreationFunction;
    }
  }

  //used in didUpdateWidget of rebuilder
  void _cloneTo(Injected<T> to) {
    to._rm = _rm;
    to._inject = _inject;
    to._creationFunction = _creationFunction;
    to._clearDependence = _clearDependence;
    to._dependsOn.addAll(_dependsOn ?? {});
    to._numberODependence = _numberODependence;
    to._cashedMockCreationFunction = _cashedMockCreationFunction;
    to._name = _name;
    _functionalInjectedModels[_name] = to;
    _rm = null;
    _inject = null;
    _dependsOn.clear();
  }

  ///Manually dispose the model(unregister it).
  void dispose() {
    _unregisterFunctionalInjectedModel(_name);
  }

  ///Inject a fake implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake creation function
  void injectMock(T Function() creationFunction) {
    assert(this is InjectedImp<T>);
    dispose();
  }

  ///Inject a fake future implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake future
  void injectFutureMock(Future<T> Function() creationFunction) {
    assert(this is InjectedFuture<T>);
    dispose();
  }

  ///Inject a fake stream implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake stream
  void injectStreamMock(Stream<T> Function() creationFunction) {
    assert(this is InjectedStream<T>);
    dispose();
  }

  ///Inject a fake computed implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [compute] (positional parameter): the fake compute callback
  /// * Optional parameters:
  ///   * [initialState] : the desired initial state of the injected model. If not defined, the original initial state is used.
  void injectComputedMock({
    T Function(T s) compute,
    Stream<T> Function(T s) computeAsync,
    T initialState,
  }) {
    assert(this is InjectedComputed<T>);
    dispose();
  }

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
  /// If not defined a default [BuildContext] obtained from the last added [StateBuilder] will be used
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
  }) {
    return _stateRM.setState(
      fn,
      onData: onData,
      onError: onError,
      onSetState: onSetState,
      onRebuildState: onRebuildState,
      catchError: catchError,
      skipWaiting: skipWaiting,
      debounceDelay: debounceDelay,
      throttleDelay: throttleDelay,
      shouldAwait: shouldAwait,
      silent: silent,
      watch: watch,
      filterTags: filterTags,
      seeds: seeds,
      context: context,
    );
  }

  ///Refresh the [ReactiveModel] state.
  ///
  ///Reset the ReactiveModel to its initial state by reinvoking its creation function.
  ///
  ///If first invoke 'onDisposed' if defined that reset the injected model to its initial state
  ///and call 'onInitialized' if defined.
  ///
  Future<T> refresh() async {
    _onDisposed?.call(_state);
    if (_rm == null && _inject != null) {
      _inject
        ..singleton = null
        ..getSingleton();
      _onInitialized?.call(state);
    }
    return _rm?.refresh(
      onInitRefresh: () => _onInitialized?.call(state),
    );
  }

  ///The stream (or Future) subscription of the state
  StreamSubscription get subscription => _rm?.subscription;

  ///Notify registered observers to rebuild.
  ///
  ///* Optional parameters:
  ///  * [tags] : List of tags to limit the notification on.
  void notify([List<dynamic> tags]) => _rm?.notify(tags);

  ///Whether the state can be redone.
  bool get canRedoState => _rm?.canRedoState == true;

  ///Whether the state can be done
  bool get canUndoState => _rm?.canUndoState == true;

  ///redo to the next valid state (isWaiting and hasError are ignored)
  ReactiveModel<T> redoState() => _rm?.redoState();

  ///undo to the last valid state (isWaiting and hasError are ignored)
  ReactiveModel<T> undoState() => _rm?.undoState();

  ///Clear undoStack;
  void clearUndoStack() => _rm?.clearUndoStack();

  ///Listen to the injected Model and ***rebuild only when the model emits a
  ///notification with new data***.
  ///
  ///If you want to rebuild when model emits notification with waiting or error state
  ///use [Injected.whenRebuilder] or [Injected.whenRebuilderOr].
  ///
  /// * Required parameters:
  ///     * [builder] (positional parameter) is si called each time the injected model has new data.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from the widget tree.
  ///
  /// Note that this is exactly equivalent to :
  ///```dart
  ///  StateBuilder(
  ///    observe: () => rm,
  ///    initState: (_, rm) => initState(),
  ///    dispose:  (_, rm) => dispose(),
  ///    shouldRebuild: (rm) => rm.hasData,
  ///    builder: (context, rm) => builder(),
  ///  )
  ///```
  ///
  ///Use [StateBuilder] if you want to have more options
  Widget rebuilder(
    Widget Function() builder, {
    void Function() initState,
    void Function() dispose,
    Key key,
  }) {
    return StateBuilder<T>(
      key: key,
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild: (rm) => rm.hasData || rm.isIdle,
      observe: () => _stateRM,
      didUpdateWidget: (_, rm, __) {
        if (_rm?.hasObservers != true) {
          final injected = _functionalInjectedModels[rm.inject.getName()];
          injected._cloneTo(this);
        }
      },
      builder: (context, rm) => builder(),
    );
  }

  ///Listen to the injected Model and rebuild when it emits a notification.
  ///
  /// * Required parameters:
  ///     * [onIdle] : callback to be executed when injected model is in its initial state.
  ///     * [onWaiting] : callback to be executed when injected model is in waiting state.
  ///     * [onError] : callback to be executed when injected model has error.
  ///     * [onData] : callback to be executed when injected model has data.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from the widget tree.
  ///
  /// Note that this is exactly equivalent to :
  ///```dart
  ///    WhenRebuilder(
  ///    observe: () => injectedModel.rm,
  ///    initState: (context, rm) => initState(),
  ///    dispose: (context, rm) => dispose(),
  ///    onIdle: onIdle,
  ///    onWaiting: onWaiting,
  ///    onError: onError,
  ///    onData: (s) => onData(),
  ///  );
  ///```
  ///
  ///Use [WhenRebuilder] if you want to have more options
  Widget whenRebuilder({
    @required Widget Function() onIdle,
    @required Widget Function() onWaiting,
    @required Widget Function() onData,
    @required Widget Function(dynamic) onError,
    void Function() initState,
    void Function() dispose,
    Key key,
  }) {
    return StateBuilder<T>(
      key: key,
      observe: () => _stateRM,
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild: (_) => true,
      didUpdateWidget: (_, rm, old) {
        if (_rm?.hasObservers != true) {
          final injected = _functionalInjectedModels[rm.inject.getName()];
          injected._cloneTo(this);
        }
      },
      builder: (context, __) {
        return _stateRM.whenConnectionState(
          onIdle: onIdle,
          onWaiting: onWaiting,
          onError: onError,
          onData: (_) => onData(),
          catchError: onError != null,
        );
      },
    );
  }

  ///Listen to the injected Model and rebuild when it emits a notification.
  ///
  /// * Required parameters:
  ///     * [builder] Default callback (called in replacement of any non defined optional parameters [onIdle], [onWaiting], [onError] and [onData]).
  /// * Optional parameters:
  ///     * [onIdle] : callback to be executed when injected model is in its initial state.
  ///     * [onWaiting] : callback to be executed when injected model is in waiting state.
  ///     * [onError] : callback to be executed when injected model has error.
  ///     * [onData] : callback to be executed when injected model has data.
  ///     * [initState] : callback to be executed when the widget is first inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from the widget tree.
  ///
  /// Note that this is exactly equivalent to :
  ///```dart
  ///    WhenRebuilderOr(
  ///    observe: () => injectedModel.rm,
  ///    initState: (context, rm) => initState(),
  ///    dispose: (context, rm) => dispose(),
  ///    onIdle: onIdle,
  ///    onWaiting: onWaiting,
  ///    onError: onError,
  ///    onData: (s) => onData(),
  ///    builder: (context, rm) {
  ///      return builder();
  ///    },
  ///  );
  ///```
  ///
  ///Use [WhenRebuilderOr] if you want to have more options
  Widget whenRebuilderOr({
    Widget Function() onIdle,
    Widget Function() onWaiting,
    Widget Function(dynamic) onError,
    Widget Function() onData,
    @required Widget Function() builder,
    void Function() initState,
    void Function() dispose,
    Key key,
  }) {
    return StateBuilder<T>(
      key: key,
      observe: () => _stateRM,
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild: (_) {
        return _stateRM.whenConnectionState<bool>(
          onIdle: () => true,
          onWaiting: () => true,
          onError: (dynamic _) => true,
          onData: (T _) => true,
          catchError: onError != null,
        );
      },
      didUpdateWidget: (_, rm, old) {
        if (_rm?.hasObservers != true) {
          final injected = _functionalInjectedModels[rm.inject.getName()];
          injected._cloneTo(this);
        }
      },
      builder: (context, __) {
        if (_stateRM.isIdle && onIdle != null) {
          return onIdle();
        }
        if (isWaiting && onWaiting != null) {
          return onWaiting();
        }
        if (hasError && onError != null) {
          return onError(error);
        }
        if (hasData && onData != null) {
          return onData();
        }
        return builder();
      },
    );
  }

  ///Listen to a future from the injected model and rebuild this widget when it resolves.
  ///
  ///After the future ends (with data or error), it will mutate the state of the injected model, but only
  ///rebuilds this widget.
  ///
  /// * Required parameters:
  ///     * [future] : Callback that takes the current state and async state of the injected model.
  ///     * [onWaiting] : callback to be executed when the future is in the waiting state.
  ///     * [onError] : callback to be executed when the future ends with error.
  ///     * [onData] : callback to be executed when the future ends data.
  ///  * Optional parameters:
  ///     * [dispose] : called when the widget is removed from the widget tree.
  ///
  ///If [onWaiting] or [onError] is set to null, the onData callback will be execute instead.
  ///
  ///ex:
  ///In the following code the onData will be invoked when the future is waiting,
  ///hasError, or hasData
  ///```dart
  ///injectedModel.futureBuilder(
  ///future : (s, asyncS) => someMethod(),
  ///onWaiting : null, //onData is called instead
  ///onError: null, // onData is called instead
  ///onData: (data)=>SomeWidget(),
  ///)
  ///```
  ///
  ///**Performance:** When this [futureBuilder] is removed from the widget tree, the
  ///future is canceled if not resolved yet.
  Widget futureBuilder<F>({
    @required Future<F> Function(T data, Future<T> asyncState) future,
    @required Widget Function() onWaiting,
    @required Widget Function(dynamic) onError,
    @required Widget Function(F data) onData,
    void Function() dispose,
    Key key,
  }) {
    return StateBuilder<F>(
      key: key,
      observe: () {
        return _stateRM.future((s, stateAsync) {
          return future(s, stateAsync);
        });
      },
      initState: (_, __) =>
          (_stateRM as ReactiveModelInternal).numberOfFutureAndStreamBuilder++,
      dispose: (_, futureRM) {
        (_stateRM as ReactiveModelInternal).numberOfFutureAndStreamBuilder--;
        if (!_stateRM.hasObservers) {
          statesRebuilderCleaner(_stateRM);
        }
        dispose?.call();
        // futureRM.unsubscribe();
      },
      onSetState: (_, rm) {
        if (rm.hasError) {
          //if setState has error override this _onError
          if (!(rm as ReactiveModelInternal).setStateHasOnErrorCallback) {
            _onError?.call(rm.error, (rm as ReactiveModelInternal).stackTrace);
          }
        }
      },
      shouldRebuild: (_) => true,
      builder: (_, rm) {
        if (rm.isWaiting) {
          return onWaiting == null ? onData(rm.state) : onWaiting();
        }

        if (rm.hasError) {
          return onError == null ? onData(rm.state) : onError(rm.error);
        }

        return onData(rm.state);
      },
    );
  }

  ///Listen to a stream from the injected model and rebuild this widget
  ///when the stream emits data.
  ///
  ///when the stream emits data, it will mutate the state of the injected model, but only
  ///rebuilds this widget.
  ///
  /// * Required parameters:
  ///     * [stream] : Callback that takes the current state and StreamSubscription  of the injected model.
  ///     * [onWaiting] : callback to be executed when the stream is in the waiting state.
  ///     * [onError] : callback to be executed when the stream emits error.
  ///     * [onData] : callback to be executed when the stream emits data.
  /// * Optional parameters:
  ///     * [onDone] : callback to be executed when the stream isDone.
  ///     * [dispose] : called when the widget is removed from the widget tree.
  ///
  ///If [onWaiting], [onError] or [onDone] is set to null, the onData callback will be execute instead.
  ///
  ///ex:
  ///In the following code the onData will be invoked when the stream is waiting,
  ///has error, has data, or is done
  ///```dart
  ///injectedModel.streamBuilder(
  ///stream : (s, subscription) => someMethod(),
  ///onWaiting : null, //onData is called instead
  ///onError: null, // onData is called instead
  ///onData: (data)=>SomeWidget(),
  ///)
  ///```
  ///
  ///**Performance:** When this [streamBuilder] is removed from the widget tree, the
  ///stream is closed.
  Widget streamBuilder<S>({
    @required Stream<S> Function(T s, StreamSubscription subscription) stream,
    @required Widget Function() onWaiting,
    @required Widget Function(dynamic) onError,
    @required Widget Function(S data) onData,
    Widget Function(S data) onDone,
    void Function() dispose,
    Key key,
  }) {
    return StateBuilder<S>(
      key: key,
      observe: () {
        return _stateRM.stream((s, subscription) {
          return stream(s, subscription);
        });
      },
      initState: (_, __) =>
          (_stateRM as ReactiveModelInternal).numberOfFutureAndStreamBuilder++,
      dispose: (_, __) {
        (_stateRM as ReactiveModelInternal).numberOfFutureAndStreamBuilder--;
        if (!_stateRM.hasObservers) {
          statesRebuilderCleaner(_stateRM);
        }
        dispose?.call();
      },
      onSetState: (_, rm) {
        if (rm.hasError) {
          //if setState has error override this _onError
          if (!(rm as ReactiveModelInternal).setStateHasOnErrorCallback) {
            _onError?.call(rm.error, (rm as ReactiveModelInternal).stackTrace);
          }
        }
      },
      shouldRebuild: (_) => true,
      builder: (_, rm) {
        if (rm.isWaiting) {
          return onWaiting == null ? onData(rm.state) : onWaiting();
        }

        if (rm.hasError) {
          return onError == null ? onData(rm.state) : onError(rm.error);
        }

        if (rm.isStreamDone == true) {
          return onDone == null ? onData(rm.state) : onDone(rm.state);
        }
        return onData(rm.state);
      },
    );
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _cachedHash;
  final int _cachedHash = _nextHashCode = (_nextHashCode + 1) % 0xffffff;
  static int _nextHashCode = 1;

  @override
  String toString() {
    return _rm == null
        ? '<$T> = $_state (RM<$T> not initialized yet)'
        : _rm?.toString();
  }
}

final Map<String, Injected<dynamic>> _functionalInjectedModels =
    <String, Injected<dynamic>>{};

///
Map<String, Injected<dynamic>> get functionalInjectedModels =>
    _functionalInjectedModels;

///Dispose and clean all injected model
void cleanInjector() {
  Map<String, Injected<dynamic>>.from(_functionalInjectedModels).forEach(
    (key, injected) {
      _unregisterFunctionalInjectedModel(injected._name);
    },
  );
  assert(_functionalInjectedModels.isEmpty);
}

void _unregisterFunctionalInjectedModel(String name) {
  if (name == null) {
    return;
  }

  Injected<dynamic> injected = _functionalInjectedModels.remove(name);
  if (injected?._inject == null) {
    return;
  }
  injected._rm?.unsubscribe();
  injected._inject
    ..removeAllReactiveNewInstance()
    ..cleanInject();
  injected._dispose();
}
