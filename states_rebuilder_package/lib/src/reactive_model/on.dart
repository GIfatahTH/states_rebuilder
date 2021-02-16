part of '../reactive_model.dart';

///{@template on}
///Callbacks to be invoked depending on the state status of an [Injected] model
///
///For more control on when to invoke the callbacks use:
///* **[On.data]**: The callback is invoked only when the [Injected] model emits a
///notification with onData status.
///* **[On.waiting]**: The callback is invoked only when the [Injected] model emits
///a notification with waiting status.
///* **[On.error]**: The callback is invoked only when the [Injected] model emits a
///notification with error status.
///
///See also:  **[On.all]**, **[On.or]**.
///{@endtemplate}
class On<T> {
  ///Callback to be called when first the model is initialized.
  final T Function()? _onIdle;

  ///Callback to be called when the model is waiting for and async task.
  final T Function()? _onWaiting;

  ///Callback to be called when the model has an error.
  final T Function(dynamic err, void Function() refresh)? _onError;

  ///Callback to be called when the model has data.
  final T Function()? _onData;
  // final _OnType _onType;

  bool get _hasOnWaiting => _onWaiting != null;
  bool get _hasOnError => _onError != null;
  bool get _hasOnIdle => _onIdle != null;
  bool get _hasOnData => _onData != null;
  On._({
    required T Function()? onIdle,
    required T Function()? onWaiting,
    required T Function(dynamic err, void Function() refresh)? onError,
    required T Function()? onData,
    // required _OnType onType,
  })   : _onIdle = onIdle,
        _onWaiting = onWaiting,
        _onError = onError,
        _onData = onData;

  ///The callback is always invoked when the [Injected] model emits a
  // ///notification.
  // factory On.any(
  //   T Function() builder,
  // ) {
  //   return On._(
  //     onIdle: builder,
  //     onWaiting: builder,
  //     onError: (dynamic _) => builder(),
  //     onData: builder,
  //     // onType: _OnType.when,
  //   );
  // }

  ///The callback is always invoked when the [Injected] model emits a
  // notification.
  factory On(
    T Function() builder,
  ) {
    return On._(
      onIdle: builder,
      onWaiting: builder,
      onError: (dynamic _, void Function() __) => builder(),
      onData: builder,
      // onType: _OnType.when,
    );
  }

  ///The callback is invoked only when the [Injected] model emits a
  ///notification with onData status.
  factory On.data(T Function() fn) {
    return On._(
      onIdle: null,
      onWaiting: null,
      onError: null,
      onData: fn,
      // onType: _OnType.onData,
    );
  }

  ///The callback is invoked only when the [Injected] model emits a
  ///notification with waiting status.
  factory On.waiting(T Function() fn) {
    return On._(
      onIdle: null,
      onWaiting: fn,
      onError: null,
      onData: null,
      // onType: _OnType.onWaiting,
    );
  }

  ///The callback is invoked only when the [Injected] model emits a
  ///notification with error status.
  factory On.error(T Function(dynamic errn, void Function() refresh) fn) {
    return On._(
      onIdle: null,
      onWaiting: null,
      onError: fn,
      onData: null,
      // onType: _OnType.onError,
    );
  }

  ///Set of callbacks to be invoked  when the [Injected] model emits a
  ///notification with the corresponding state status.
  ///
  ///[onIdle], [onWaiting], [onError] and [onData] are optional. Non defined ones
  /// default to the [or] callback.
  ///
  ///To be forced to define all state status use [On.all].
  factory On.or({
    T Function()? onIdle,
    T Function()? onWaiting,
    T Function(dynamic err, void Function() refreh)? onError,
    T Function()? onData,
    required T Function() or,
  }) {
    return On._(
      onIdle: onIdle ?? or,
      onWaiting: onWaiting ?? or,
      onError: onError ?? (dynamic _, void Function() __) => or(),
      onData: onData ?? or,
      // onType: _OnType.when,
    );
  }

  ///Set of callbacks to be invoked  when the [Injected] model emits a
  ///notification with the corresponding state status.
  ///
  ///[onIdle], [onWaiting], [onError] and [onData] are required.
  ///
  ///For optional callbacks use [On.or].
  factory On.all({
    required T Function() onIdle,
    required T Function() onWaiting,
    required T Function(dynamic err, void Function() refresh) onError,
    required T Function() onData,
  }) {
    return On._(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
      // onType: _OnType.when,
    );
  }

  ///Set of callbacks to be invoked  when a future or an [Injected] model that
  ///is associated with the future, emits a notification with the corresponding
  ///state status.
  ///
  ///See: [_OnFuture.future] and [_OnFuture.listenTo]
  static _OnFuture<F> future<F>({
    required Widget Function()? onWaiting,
    required Widget Function(dynamic err, void Function() refresh)? onError,
    required Widget Function(F data, void Function() refresh) onData,
  }) {
    return _OnFuture<F>(
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
    );
  }

  static _OnCRUD<T> crud<T>({
    required T Function()? onWaiting,
    required T Function(dynamic err, void Function() refresher)? onError,
    required T Function(dynamic data) onResult,
  }) {
    return _OnCRUD<T>(
      onWaiting: onWaiting,
      onError: onError,
      onResult: onResult,
    );
  }

  //
  static _OnAuth<T> auth<T>({
    T Function()? onInitialWaiting,
    T Function()? onWaiting,
    required T Function() onUnsigned,
    required T Function() onSigned,
  }) {
    return _OnAuth<T>(
      onInitialWaiting: onInitialWaiting,
      onWaiting: onWaiting,
      onUnsigned: onUnsigned,
      onSigned: onSigned,
    );
  }

  bool _canRebuild(ReactiveModel rm) {
    if (rm.isWaiting) {
      return _hasOnWaiting;
    }
    if (rm.hasError) {
      return _hasOnError;
    }
    return true;
  }

  T? _callForSideEffects(SnapState snapState) {
    if (snapState.isWaiting && _hasOnWaiting) {
      _onWaiting!.call();
    } else if (snapState.hasError && _hasOnError) {
      _onError!.call(snapState.error, snapState.onErrorRefresher!);
    } else if (snapState.hasData && _hasOnData) {
      _onData?.call();
    }
  }

  T? _call(SnapState snapState, [bool isSideEffect = true]) {
    if (snapState.isWaiting) {
      if (_hasOnWaiting) {
        return _onWaiting!.call();
      }
      return _onData?.call();
    }
    if (snapState.hasError) {
      if (_hasOnError) {
        return _onError!.call(snapState.error, snapState.onErrorRefresher!);
      }
      return _onData?.call();
    }

    if (snapState.isIdle) {
      if (_hasOnIdle) {
        return _onIdle?.call();
      }

      if (isSideEffect) {
        return null;
      }
      if (_hasOnData) {
        return _onData?.call();
      }
      if (_hasOnWaiting) {
        return _onWaiting?.call();
      }
      if (_hasOnError) {
        return _onError?.call(snapState.error, () {});
      }
    }

    if (_hasOnData) {
      return _onData?.call();
    }
    if (isSideEffect) {
      return null;
    }
    if (_hasOnWaiting) {
      return _onWaiting!.call();
    }

    if (_hasOnError) {
      return _onError!.call(snapState.error, () {});
    }
  }
}

// enum _OnType { onData, onWaiting, onError, when }

extension OnX on On<Widget> {
  ///Listen to this [Injected] model and register:
  ///
  ///{@template listen}
  ///* builder to be called to rebuild some part of the widget tree (**child**
  ///parameter).
  ///* Side effects to be invoked before rebuilding the widget (**onSetState**
  ///parameter).
  ///* Side effects to be invoked after rebuilding (**onAfterBuild** parameter).
  ///
  ///
  /// * **Required parameters**:
  ///     * **child**: of type `On<Widget>`. defines the widget to render when
  /// this injected model emits a notification.
  /// * **Optional parameters:**
  ///     * **onSetState** :  of type `On<void>`. Defines callbacks to be
  /// executed when this injected model emits a notification before rebuilding
  /// the widget.
  ///     * **onAfterBuild** :  of type `On<void>`. Defines callbacks
  /// to be executed when this injected model emits a notification after
  /// rebuilding the widget.
  ///     * **initState** : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * **dispose** : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * **shouldRebuild** : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * **watch** : callback to be executed before notifying listeners.
  ///     * **didUpdateWidget** : callback to be executed whenever the widget
  /// configuration changes.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  /// {@endtemplate}
  ///
  ///onSetState, child and onAfterBuild parameters receives a [On] object.
  Widget listenTo<T>(
    Injected<T> injected, {
    On<void>? onSetState,
    On<void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    void Function(_StateBuilder<T>)? didUpdateWidget,
    bool Function(SnapState<T>? previousState)? shouldRebuild,
    Object? Function()? watch,
    Key? key,
  }) {
    return _StateBuilder<T>(
      key: key,
      rm: [injected],
      initState: (_, setState, exposedRM) {
        injected._initialize();

        initState?.call();
        // state;
        if (onAfterBuild != null) {
          WidgetsBinding.instance?.addPostFrameCallback(
            (_) => onAfterBuild._call(injected._snapState),
          );
        }
        return injected._listenToRMForStateFulWidget((rm, tags, isOnCrud) {
          if (isOnCrud) {
            return;
          }
          rm!;
          if (shouldRebuild?.call(rm._coreRM._previousSnapState) == false) {
            return;
          }

          onSetState?._call(rm._snapState);
          rm._onHasErrorCallback = _hasOnError;

          if (!_canRebuild(rm)) {
            return;
          }
          if (onAfterBuild != null) {
            WidgetsBinding.instance?.addPostFrameCallback(
              (_) => onAfterBuild._call(rm._snapState),
            );
          }
          setState(rm);
        });
      },
      dispose: (context) {
        dispose?.call();
      },
      watch: watch,
      didUpdateWidget: (_, oldWidget) => didUpdateWidget?.call(oldWidget),
      builder: (_, __) {
        injected._onHasErrorCallback = _hasOnError;
        return _call(injected._snapState, false)!;
      },
    );
  }
}

class _OnFuture<F> {
  final Widget Function()? _onWaiting;
  final Widget Function(dynamic err, void Function() refresh)? _onError;
  final Widget Function(F data, void Function() refresh) _onData;
  _OnFuture({
    required Widget Function()? onWaiting,
    required Widget Function(dynamic err, void Function() refresh)? onError,
    required Widget Function(F data, void Function() refresh) onData,
  })   : _onWaiting = onWaiting,
        _onError = onError,
        _onData = onData;

  ///Used to listen to any kind of future.
  ///
  /// * **Required parameters**:
  ///     * **future**: Callback that return the future to listen to.
  /// * **Optional parameters:**
  ///     * **onSetState** :  of type `On<void>`. used for side effects
  ///     * **dispose** :  called when the widget is removed from the
  /// widget tree.
  Widget future<T>(
    Future<T> Function() future, {
    void Function()? dispose,
    void Function()? initState,
    On<void>? onSetState,
    Key? key,
  }) {
    assert(F == dynamic || '$F' == 'Object?' || T == F);
    return _listenTo<T>(
      future: future,
      dispose: dispose,
      initState: initState,
      onSetState: onSetState,
      key: key,
    );
  }

  ///Used to listen to the `stateAsyc` of an injected state.
  ///
  ///This is a one-time subscription for `onWaiting` and `onError`. That is
  ///after the `stateAsyc` future ends, this widget will not rebuild if the
  ///injected state emits notification with `hasError` or `isWaiting` state status.
  ///
  ///Whereas, `onData` is an ongoing subscritpion. the widget keeps listening the
  ///injected state when emits a notification with `hasData` status.
  ///
  /// * **Required parameters**:
  ///     * **future**: Callback that return the future to listen to.
  /// * **Optional parameters:**
  ///     * **onSetState** :  of type `On<void>`. used for side effects
  ///     * **dispose** :  called when the widget is removed from the
  /// widget tree.
  Widget listenTo<T>(
    Injected<T> injected, {
    void Function()? dispose,
    void Function()? initState,
    On<void>? onSetState,
    Key? key,
  }) {
    assert(F == dynamic || '$F' == 'Object?' || T == F);

    return _listenTo<T>(
      injected: injected,
      dispose: dispose,
      initState: initState,
      onSetState: onSetState,
      key: key,
    );
  }

  Widget _listenTo<T>({
    Injected<T>? injected,
    Future<T> Function()? future,
    void Function()? dispose,
    void Function()? initState,
    On<void>? onSetState,
    Key? key,
  }) {
    return _StateFulWidget<Injected<F>>(
      iniState: () {
        initState?.call();
        if (future != null) {
          return InjectedImp<T>(
            creator: (_) => future(),
            isLazy: false,
          ) as Injected<F>;
        } else {
          // injected!._onFutureWaiter++;
          bool _isAlreadyNotified = false;
          return InjectedImp<T>(
            creator: (_) => injected!.stateAsync,
            //depends is add only to prevent injected from disposing while
            //this new Inject is alive
            dependsOn: DependsOn<T>(
              {injected!},
              shouldNotify: (_) {
                if (_isAlreadyNotified) {
                  return false;
                }
                _isAlreadyNotified = true;
                return true;
              },
            ),
            isLazy: false,

            initialValue: injected._state,
          ) as Injected<F>;
        }
      },
      dispose: () {
        if (injected != null) {
          if (!injected.hasObservers) {
            Future.microtask(() => injected._clean());
          }
        }
        dispose?.call();
      },
      builder: (inj) {
        final _inj = inj!;
        final _refresher = () {
          if (injected != null) {
            if (injected.hasError) {
              injected.onErrorRefresher!.call();
            } else {
              injected
                .._snapState = injected._snapState.copyToIsIdle()
                .._isInitialized = false
                .._coreRM._completer = null
                .._initialize();
            }
          }

          _inj
            .._snapState = _inj._snapState.copyToIsIdle()
            .._isInitialized = false
            .._coreRM._completer = null
            .._initialize();
        };
        return On(() {
          if (_inj._snapState.isWaiting) {
            return _onWaiting?.call() ?? _onData(_inj.state, _refresher);
          }
          if (_inj._snapState.hasError) {
            return _onError?.call(
                  _inj.error,
                  _refresher,
                ) ??
                _onData(_inj.state, _refresher);
          }
          return injected != null
              ? On.data(() => _onData(_inj.state, _refresher))
                  .listenTo(injected)
              : _onData(_inj.state, _refresher);
        }).listenTo<F>(
          _inj,
          onSetState: onSetState,
          dispose: dispose,
          key: key,
        );
      },
    );
  }
}

class _OnCRUD<T> {
  final T Function()? _onWaiting;
  final T Function(dynamic err, void Function() refresh)? _onError;
  final T Function(dynamic data) _onResult;
  _OnCRUD({
    required T Function()? onWaiting,
    required T Function(dynamic err, void Function() refresh)? onError,
    required T Function(dynamic data) onResult,
  })   : _onWaiting = onWaiting,
        _onError = onError,
        _onResult = onResult;

  ///Listen to an InjectedCRUD state
  Widget listenTo(
    InjectedCRUD injected, {
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
  }) {
    return _StateBuilder(
      initState: (context, setState, rm) {
        injected._initialize();
        final disposer = injected._listenToRMForStateFulWidget(
          (rm, tags, _) {
            onSetState?._call(rm!.snapState);
            setState(injected);
          },
        );
        return disposer;
      },
      dispose: (_) => dispose?.call(),
      builder: (context, rm) {
        if (injected.isOnCRUD) {
          return (_onWaiting?.call() ?? _onResult(injected._result)) as Widget;
        }
        if (injected.hasError) {
          return (_onError?.call(injected.error, injected.onErrorRefresher!) ??
              _onResult(injected._result)) as Widget;
        }
        return (_onResult(injected._result)) as Widget;
      },
    );
  }
}

class _OnAuth<T> {
  T Function()? _onInitialWaiting;
  final T Function()? _onWaiting;
  final T Function() _onUnsigned;
  final T Function() _onSigned;
  _OnAuth({
    required T Function()? onInitialWaiting,
    required T Function()? onWaiting,
    required T Function() onUnsigned,
    required T Function() onSigned,
  })   : _onInitialWaiting = onInitialWaiting,
        _onWaiting = onWaiting,
        _onUnsigned = onUnsigned,
        _onSigned = onSigned;

  ///Listen to an InjectedAuth state
  Widget listenTo(
    InjectedAuth injected, {
    bool useRouteNavigation = false,
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
  }) {
    T widget() => injected.isSigned ? _onSigned() : _onUnsigned();

    bool isNavigated = false;
    return _StateBuilder(
      initState: (context, setState, rm) {
        injected._initialize();
        final navigatorState =
            useRouteNavigation ? RM.navigate.navigatorState : null;

        final disposer = injected._listenToRMForStateFulWidget(
          (rm, tags, _) {
            onSetState?._call(rm!.snapState);
            if (useRouteNavigation && injected.hasData) {
              SchedulerBinding.instance?.scheduleFrameCallback(
                (_) {
                  if (injected.isSigned) {
                    RM.navigate.toAndRemoveUntil<T>(
                      _onSigned() as Widget,
                    );
                  } else {
                    RM.navigate.toAndRemoveUntil<T>(
                      _onUnsigned() as Widget,
                    );
                  }
                },
              );
              isNavigated = true;
            } else if (!isNavigated) {
              setState(injected);
            }
          },
        );
        injected.addToCleaner(disposer);
        return () {};
      },
      dispose: (_) {
        //injected.dispose();
        dispose?.call();
      },
      builder: (context, rm) {
        if (injected.isWaiting) {
          if (_onInitialWaiting != null) {
            return (_onInitialWaiting?.call() ?? widget()) as Widget;
          }
          return (_onWaiting?.call() ?? widget()) as Widget;
        }
        _onInitialWaiting = null;
        return (isNavigated ? _onUnsigned() : widget()) as Widget;
      },
    );
  }
}

////Used in tests
T? onCall<T>(
  On<T> on, {
  bool isWaiting = false,
  dynamic error,
  T? data,
  bool isSideEffect = false,
}) {
  final connectionState = isWaiting
      ? ConnectionState.waiting
      : (error != null || data != null)
          ? ConnectionState.done
          : ConnectionState.none;
  return on._call(
    SnapState._(
      connectionState,
      data,
      error,
      null,
      () {},
    ),
    isSideEffect,
  );
}
