part of '../injected.dart';

///Basic class for injected models
abstract class Injected<T> extends InjectedBaseCommon<T> {
  Function() _creationFunction;
  final bool _autoDisposeWhenNotUsed;
  final void Function(T s) _onData;
  final void Function(dynamic e, StackTrace s) _onError;
  final void Function() _onWaiting;

  final void Function(T s) _onInitialized;
  final void Function(T s) _onDisposed;

  final int _undoStackLength;
  final String _debugPrintWhenNotifiedPreMessage;

  final bool _hasSideEffect;
  final PersistState<T> Function() _persistCallback;

  ///Basic class for injected models
  Injected({
    bool autoDisposeWhenNotUsed = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    int undoStackLength,
    PersistState<T> Function() persist,
    String debugPrintWhenNotifiedPreMessage,
  })  : _autoDisposeWhenNotUsed = autoDisposeWhenNotUsed,
        _onData = onData,
        _onError = onError,
        _onWaiting = onWaiting,
        _hasSideEffect = onData != null || onError != null || onWaiting != null,
        _onInitialized = onInitialized,
        _onDisposed = onDisposed,
        _undoStackLength = undoStackLength,
        _persistCallback = persist,
        _debugPrintWhenNotifiedPreMessage = debugPrintWhenNotifiedPreMessage;

  ///Get the [ReactiveModel] associated with the injected model
  ReactiveModel<T> get getRM => _stateRM;

  ///Get the [ReactiveModel] associated with this model.
  ReactiveModel<T> get _stateRM {
    if (_isRegistered) {
      return _rm;
    }

    _resolveInject();
    _functionalInjectedModels[_name] = this;

    _isRegistered = _rm != null;

    if (_undoStackLength != null) {
      _rm.undoStackLength = _undoStackLength;
    }

    if (_autoDisposeWhenNotUsed ?? true) {
      _rm.cleaner(dispose);
    }

    assert(() {
      if (_debugPrintWhenNotifiedPreMessage?.isNotEmpty != null) {
        final disposer = (_rm as ReactiveModelInternal).listenToRMInternal(
          (rm) {
            // final Injected<T> injected =
            //     _functionalInjectedModels[rm.inject.getName()] as Injected<T>;
            StatesRebuilerLogger.log(
              '$_debugPrintWhenNotifiedPreMessage'
              '${_debugPrintWhenNotifiedPreMessage.isEmpty ? "" : ": "}'
              '$this',
            );
          },
          listenToOnDataOnly: false,
          debugListener: 'DEBUG_PRINT_STATE',
        );
        _rm.cleaner(disposer);
      }
      return true;
    }());

    //
    return _rm;
  }

  ///The state of the model.
  T get state {
    _resolveInject();
    _setAndGetModelState();
    return _state;
  }

  set state(T s) {
    _oldState = state;
    _rm.state = s;
  }

  ///Get the async state of the model.
  Future<T> get stateAsync {
    state;
    return _rm.stateAsync;
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
    final cashedInjected = Injected._activeInjected;
    if (cashedInjected != null) {
      _addToDependsOn(cashedInjected);
    }

    if (_inject != null) {
      return;
    }

    Injected._activeInjected = this;
    try {
      final inj = _getInject();
      Injected._activeInjected = cashedInjected;
      _setClearDependence();
      _setAndGetInject(inj);
      _registerSideEffects();
      _onInitialized?.call(_setAndGetModelState());
      assert(() {
        if (_debugPrintWhenNotifiedPreMessage?.isNotEmpty != null) {
          StatesRebuilerLogger.log(
            '$_debugPrintWhenNotifiedPreMessage'
            '${_debugPrintWhenNotifiedPreMessage.isEmpty ? "" : ": "}'
            '(initialized) $this',
          );
        }
        return true;
      }());
    } catch (e) {
      Injected._activeInjected = cashedInjected;
      rethrow;
    }
  }

  void _registerSideEffects() {
    if (_hasSideEffect) {
      final disposer = (_rm as ReactiveModelInternal).listenToRMInternal(
        (rm) {
          rm.whenConnectionState<void>(
            onIdle: () => null,
            onWaiting: () => _onWaiting?.call(),
            onData: (dynamic s) {
              if (!(rm as ReactiveModelInternal)
                  .setStateHasOnErrorCallback[0]) {
                _onData?.call(s as T);
              }
            },
            onError: (dynamic e) {
              //if setState has error override this _onError
              if (!(rm as ReactiveModelInternal)
                  .setStateHasOnErrorCallback[1]) {
                _onError?.call(e, (rm as ReactiveModelInternal).stackTrace);
              }
            },
            catchError: _onError != null,
          );
        },
        listenToOnDataOnly: false,
        debugListener: 'SIDE_EFFECT',
      );
      _rm.cleaner(disposer);
    }

    if (_persistCallback != null) {
      _persist ??= _persistCallback();
      if (_initialStoredState != null) {
        _rm.resetToHasData(_initialStoredState);
      }
      if (_persist.persistOn == null) {
        final disposer = (_rm as ReactiveModelInternal<T>).listenToRMInternal(
          (rm) async {
            if (_initialStoredState != rm.state) {
              await persistState(rm);
            }
            _initialStoredState = null;
          },
          debugListener: 'PERSISTANCE',
        );
        _rm.cleaner(disposer);
      }
    }
  }

  void _dispose() {
    assert(() {
      if (_debugPrintWhenNotifiedPreMessage?.isNotEmpty != null) {
        StatesRebuilerLogger.log(
          '$_debugPrintWhenNotifiedPreMessage'
          '${_debugPrintWhenNotifiedPreMessage.isEmpty ? "" : ": "}(disposed) '
          '$this',
        );
      }
      return true;
    }());
    if (_persist != null && _persist.persistOn == PersistOn.disposed) {
      _persist.write(_rm.state);
    }
    _onDisposed?.call(_state);
    _clearDependence?.call();
    _resetInjected();
    if (_cashedMockCreationFunction != null) {
      _creationFunction = _cashedMockCreationFunction;
    }
  }

  //used in didUpdateWidget of rebuilder
  void _cloneTo(Injected<T> to) {
    to._rm = _rm;
    to._setAndGetInject(_inject);
    to._creationFunction = _creationFunction;
    to._setClearDependence(_clearDependence);
    to._setAndGetDependsOn(_dependsOn);
    to._numberODependence = _numberODependence;
    to._cashedMockCreationFunction = _cashedMockCreationFunction;
    to._name = _name;
    _functionalInjectedModels[_name] = to;
    _resetInjected();
  }

  ///Manually dispose the model(unregister it).
  void dispose() {
    _unregisterFunctionalInjectedModel(this);
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
    _oldState = state;
    assert(silent || _rm != null);
    return _rm?.setState(
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
    _initialStoredState = null;
    if ((_rm as ReactiveModelInternal)?.inheritedInjected?.isNotEmpty == true) {
      for (var inj in (_rm as ReactiveModelInternal).inheritedInjected) {
        print((_rm as ReactiveModelInternal).inheritedInjected.length);

        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            inj.refresh();
          },
        );
      }
      return null;
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

  ///Save the current state to localStorage.
  Future<void> persistState([ReactiveModel reactiveModel]) async {
    final rm = reactiveModel ?? _rm;
    if (_rm == null) {
      return;
    }
    Injected<T> injected =
        _functionalInjectedModels[rm.inject.getName()] as Injected<T>;
    injected ??= this; //TODO
    final oldState = _oldState;
    try {
      if (!injected._persistHasError) {
        await injected._persist.write(rm.state);
      }
    } catch (e) {
      injected._persistHasError = true;
      // rm.state = oldState;
      // rm.resetToHasError(e);
      // // rm.notify();
      rm.setState(
        (s) => oldState,
        onData: (_, __) => rm.hasError
            ? rm.setState(
                (s) => throw e,
                catchError: true,
              )
            : null,
      );
      injected._persistHasError = false;
      // rethrow;
      if (e is! _PersistenceException) {
        rethrow;
      }
    }
  }

  ///Delete the saved instance of this state form localStorage.
  void deletePersistState() => _persist?.delete();

  ///Clear localStorage
  void deleteAllPersistState() => _persist?.deleteAll();

  /// {@template injected.rebuilder}
  ///Listen to the injected Model and ***rebuild only when the model emits a
  ///notification with new data***.
  ///
  ///If you want to rebuild when model emits notification with waiting or error state
  ///use [Injected.whenRebuilder] or [Injected.whenRebuilderOr].
  ///
  /// * Required parameters:
  ///     * [builder] (positional parameter) is si called each time the
  /// injected model has new data.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * [watch] : callback to be executed before notifying listeners.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
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
  /// {@endtemplate}Widget
  Widget rebuilder(
    Widget Function() builder, {
    void Function() initState,
    void Function() dispose,
    Object Function() watch,
    bool Function() shouldRebuild,
    Key key,
  }) {
    return StateBuilder<T>(
      key: key,
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild: shouldRebuild == null ? null : (_) => shouldRebuild(),
      watch: watch == null ? null : (_) => watch(),
      observe: () => _stateRM,
      didUpdateWidget: (_, rm, __) {
        if (_rm?.hasObservers != true) {
          final injected = _functionalInjectedModels[rm.inject.getName()];
          injected?._cloneTo(this);
        }
      },
      builder: (context, rm) => builder(),
    );
  }

  /// {@template injected.whenRebuilder}
  ///Listen to the injected Model and rebuild when it emits a notification.
  ///
  /// * Required parameters:
  ///     * [onIdle] : callback to be executed when injected model is in its
  /// initial state.
  ///     * [onWaiting] : callback to be executed when injected model is in
  /// waiting state.
  ///     * [onError] : callback to be executed when injected model has error.
  ///     * [onData] : callback to be executed when injected model has data.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed
  /// from the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
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
  // {@endtemplate}
  Widget whenRebuilder({
    @required Widget Function() onIdle,
    @required Widget Function() onWaiting,
    @required Widget Function() onData,
    @required Widget Function(dynamic) onError,
    void Function() initState,
    void Function() dispose,
    bool Function() shouldRebuild,
    Key key,
  }) {
    return StateBuilder<T>(
      key: key,
      observe: () => _stateRM,
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild:
          shouldRebuild == null ? (_) => true : (_) => shouldRebuild(),
      didUpdateWidget: (_, rm, old) {
        if (_rm?.hasObservers != true) {
          final injected = _functionalInjectedModels[rm.inject.getName()];
          injected?._cloneTo(this);
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

  /// {@template injected.whenRebuilderOr}
  ///Listen to the injected Model and rebuild when it emits a notification.
  ///
  /// * Required parameters:
  ///     * [builder] Default callback (called in replacement of any non
  /// defined optional parameters [onIdle], [onWaiting], [onError] and
  /// [onData]).
  /// * Optional parameters:
  ///     * [onIdle] : callback to be executed when injected model is in its
  /// initial state.
  ///     * [onWaiting] : callback to be executed when injected model is in
  /// waiting state.
  ///     * [onError] : callback to be executed when injected model has error.
  ///     * [onData] : callback to be executed when injected model has data.
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed
  /// from the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * [watch] : callback to be executed before notifying listeners.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
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
  /// {@endtemplate}
  Widget whenRebuilderOr({
    Widget Function() onIdle,
    Widget Function() onWaiting,
    Widget Function(dynamic) onError,
    Widget Function() onData,
    @required Widget Function() builder,
    void Function() initState,
    void Function() dispose,
    Object Function() watch,
    bool Function() shouldRebuild,
    Key key,
  }) {
    return StateBuilder<T>(
      key: key,
      observe: () => _stateRM,
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      watch: watch == null ? null : (_) => watch(),
      shouldRebuild: (_) {
        return shouldRebuild == null
            ? _stateRM.whenConnectionState<bool>(
                onIdle: () => true,
                onWaiting: () => true,
                onError: (dynamic _) => true,
                onData: (T _) => true,
                catchError: onError != null,
              )
            : shouldRebuild();
      },
      didUpdateWidget: (_, rm, old) {
        if (_rm?.hasObservers != true) {
          final injected = _functionalInjectedModels[rm.inject.getName()];
          injected?._cloneTo(this);
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
      },
      onSetState: (_, rm) {
        if (rm.hasData) {
          if (rm.state is T) {
            _onData?.call(state);
          }
        } else if (rm.hasError) {
          _onError?.call(rm.error, (rm as ReactiveModelInternal).stackTrace);
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
        if (rm.hasData) {
          //if setState has data override this _onData
          if (!(rm as ReactiveModelInternal).setStateHasOnErrorCallback[0]) {
            _onData?.call(state);
          }
        } else if (rm.hasError) {
          //if setState has error override this _onError
          // if (!(rm as ReactiveModelInternal).setStateHasOnErrorCallback[1]) {
          _onError?.call(rm.error, (rm as ReactiveModelInternal).stackTrace);
          // }
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

  Widget reInherited({
    Key key,
    BuildContext context,
    Widget Function(BuildContext) builder,
    bool connectWithGlobal = false,
    String debugPrintWhenNotifiedPreMessage,
  }) {
    return _InheritedState(
      key: key,
      builder: (context) => builder(context),
      globalInjected: this,
      reInheritedInjected: () => call(context),
      connectWithGlobal: connectWithGlobal,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  Widget inherited({
    Key key,
    T Function() state,
    Widget Function(BuildContext) builder,
    bool connectWithGlobal = false,
    String debugPrintWhenNotifiedPreMessage,
  }) {
    return _InheritedState(
      key: key,
      builder: (context) => builder(context),
      globalInjected: this,
      state: state,
      connectWithGlobal: connectWithGlobal,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  Injected<T> call(BuildContext context, {bool defaultToGlobal = false}) {
    final _InheritedInjected<T> _inheritedInjected = context
        .getElementForInheritedWidgetOfExactType<_InheritedInjected<T>>()
        ?.widget;
    if (_inheritedInjected != null) {
      if (_inheritedInjected.globalInjected == this) {
        return _inheritedInjected.injected;
      } else {
        return call(_inheritedInjected.context);
      }
    }
    if (defaultToGlobal) {
      return this;
    }
    return null;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _cachedHash;
  final int _cachedHash = _nextHashCode = (_nextHashCode + 1) % 0xffffff;
  static int _nextHashCode = 1;

  @override
  bool operator ==(o) => o.hashCode == hashCode;

  @override
  String toString() {
    return _rm == null
        ? '<$T> = $_state (RM<$T> not initialized yet)'
        : _rm?.toString();
  }
}
