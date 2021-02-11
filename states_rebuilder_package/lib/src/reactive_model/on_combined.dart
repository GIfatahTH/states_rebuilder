part of '../reactive_model.dart';

///{@template OnCombined}
///Callbacks to be invoked depending on the combined state status of a
///list of [Injected] models
///
///For more control on when to invoke the callbacks use:
///* **[OnCombined.data]**: The callback is invoked only  if all the [Injected] models
///have data.
///* **[OnCombined.waiting]**: The callback is invoked if any of the injected models
///is waiting.
///* **[OnCombined.error]**: The callback is invoked if all the injected models are not
///waiting and at least one of them has error.
///
///See also:  **[OnCombined.all]**, **[OnCombined.or]**.
///{@endtemplate}
class OnCombined<T, R> {
  ///Callback to be called if all injected models are neither waiting nor have error
  ///and at least one of them is on idle state status.
  final R Function(T data)? _onIdle;

  ///Callback to be called when any of the the model is waiting for and async task.
  final R Function(T data)? _onWaiting;

  ///Callback to be called when all models are not waiting and at least one of
  ///them has an error.
  final R Function(T data, dynamic error)? _onError;

  ///Callback to be called if all injected models have data
  final R Function(T data)? _onData;
  // final _OnType _onType;

  bool get _hasOnWaiting => _onWaiting != null;
  bool get _hasOnError => _onError != null;
  bool get _hasOnIdle => _onIdle != null;
  bool get _hasOnData => _onData != null;

  OnCombined._({
    required R Function(T data)? onIdle,
    required R Function(T data)? onWaiting,
    required R Function(T data, dynamic error)? onError,
    required R Function(T data)? onData,
    // required _OnType onType,
  })   : _onIdle = onIdle,
        _onWaiting = onWaiting,
        _onError = onError,
        _onData = onData;

  ///The callback is always invoked when any of the [Injected] models emits a
  ///notification.
  // factory OnCombined.any(
  //   R Function(T state) builder,
  // ) {
  //   return OnCombined._(
  //     onIdle: null,
  //     onWaiting: null,
  //     onError: null,
  //     onData: builder,
  //     // onType: _OnType.when,
  //   );
  // }

  ///{@macro OnCombined}
  factory OnCombined(
    R Function(T state) builder,
  ) {
    return OnCombined._(
      onIdle: builder,
      onWaiting: builder,
      onError: (T state, dynamic _) => builder(state),
      onData: builder,
      // onType: _OnType.when,
    );
  }

  ///The callback is invoked only when all the [Injected] models are in the
  ///onData status.
  factory OnCombined.data(R Function(T state) fn) {
    return OnCombined._(
      onIdle: null,
      onWaiting: null,
      onError: null,
      onData: fn,
      // onType: _OnType.onData,
    );
  }

  ///The callback is invoked only when one of the [Injected] models emits a
  ///notification with waiting status.
  factory OnCombined.waiting(R Function() fn) {
    return OnCombined._(
      onIdle: null,
      onWaiting: (_) => fn(),
      onError: null,
      onData: null,
    );
  }

  ///The callback is invoked only when any of the [Injected] models emits a
  ///notification with error status and with no other model is waiting.
  factory OnCombined.error(R Function(dynamic error) fn) {
    return OnCombined._(
      onIdle: null,
      onWaiting: null,
      onError: (_, dynamic err) => fn(err),
      onData: null,
    );
  }

  ///Set of callbacks to be invoked  when the [Injected] models emit
  ///notifications with the corresponding state status.
  ///
  ///[onIdle], [onWaiting], [onError] and [onData] are optional. Non defined ones
  /// default to the [or] callback.
  ///
  ///To be forced to define all state status use [OnCombined.all].
  factory OnCombined.or({
    R Function()? onIdle,
    R Function()? onWaiting,
    R Function(dynamic error)? onError,
    R Function(T state)? onData,
    required R Function(T state) or,
  }) {
    return OnCombined._(
      onIdle: onIdle != null ? (_) => onIdle() : or,
      onWaiting: onWaiting != null ? (_) => onWaiting() : or,
      onError: onError != null
          ? (_, dynamic err) => onError(err)
          : (s, dynamic err) => or(s),
      onData: onData ?? or,
    );
  }

  ///Set of callbacks to be invoked  when the [Injected] models emit
  ///notifications with the corresponding state status.
  ///
  ///[onIdle], [onWaiting], [onError] and [onData] are required.
  ///
  ///For optional callbacks use [OnCombined.or].
  factory OnCombined.all({
    required R Function() onIdle,
    required R Function() onWaiting,
    required R Function(dynamic error) onError,
    required R Function(T state) onData,
  }) {
    return OnCombined._(
      onIdle: (_) => onIdle(),
      onWaiting: (_) => onWaiting(),
      onError: (_, dynamic err) => onError(err),
      onData: onData,
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

  R? _call(SnapState snapState, T state) {
    if (snapState.isWaiting) {
      if (_hasOnWaiting) {
        return _onWaiting?.call(state);
      }
      return _onData?.call(state);
    }
    if (snapState.hasError) {
      if (_hasOnError) {
        return _onError?.call(state, snapState.error);
      }
      return _onData?.call(state);
    }

    if (snapState.isIdle) {
      if (_hasOnIdle) {
        return _onIdle?.call(state);
      }
      if (_hasOnData) {
        return _onData?.call(state);
      }
      if (_hasOnWaiting) {
        return _onWaiting?.call(state);
      }
      if (_hasOnError) {
        return _onError?.call(state, snapState.error);
      }
    }

    if (_hasOnData) {
      return _onData?.call(state);
    }
    if (_hasOnWaiting) {
      return _onWaiting!.call(state);
    }

    if (_hasOnError) {
      return _onError!.call(state, snapState.error);
    }
  }
}

extension OnCombinedX on OnCombined<dynamic, Widget> {
  ///Listen to a list [Injected] states and register:
  ///{@macro listen}
  ///
  ///onSetState, child and onAfterBuild parameters receives a
  ///[OnCombined] object.
  Widget listenTo<T>(
    List<ReactiveModel<dynamic>> rms, {
    OnCombined<T, void>? onSetState,
    OnCombined<T, void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    void Function(_StateBuilder<T> oldWidget)? didUpdateWidget,
    bool Function()? shouldRebuild,
    Object? Function()? watch,
    Key? key,
  }) {
    return _StateBuilder<T>(
      rm: rms,
      initState: (_, setState, exposedRM) {
        initState?.call();
        final disposer = <Disposer>[];

        for (var rm in rms) {
          rm._initialize();
          disposer.add(
            rm._listenToRMForStateFulWidget((_, tag, __) {
              if (shouldRebuild?.call() == false) {
                return;
              }
              onSetState?._call(
                  _getCombinedSnap(rms), (exposedRM ?? rm)._state as T);

              if (!_canRebuild(rm)) {
                return;
              }

              if (onAfterBuild != null) {
                WidgetsBinding.instance?.addPostFrameCallback(
                  (_) {
                    onAfterBuild._call(
                        _getCombinedSnap(rms), (exposedRM ?? rm)._state as T);
                  },
                );
              }
              setState(rm);
            }),
          );
        }
        if (onAfterBuild != null) {
          WidgetsBinding.instance?.addPostFrameCallback(
            (_) {
              onAfterBuild._call(
                _getCombinedSnap(rms),
                (exposedRM ?? rms.first)._state as T,
              );
            },
          );
        }
        return () => disposer.forEach((e) => e());
      },
      dispose: (context) {
        dispose?.call();
        Future.microtask(
          () => rms.forEach(
            (e) {
              if (!e.hasObservers) {
                e._clean();
              }
            },
          ),
        );
      },
      watch: watch,
      didUpdateWidget: (_, oldWidget) => didUpdateWidget?.call(oldWidget),
      builder: (_, rm) {
        return _call(_getCombinedSnap(rms), rm!._state as T)!;
      },
    );
  }

  SnapState _getCombinedSnap(List<ReactiveModel> rms) {
    SnapState? snapWaiting;
    SnapState? snapError;
    SnapState? snapIdle;
    for (var e in rms) {
      if (e._snapState.isWaiting) {
        snapWaiting = e._snapState;
        break;
      }
      if (e._snapState.hasError) {
        snapError = e._snapState;
      }
      if (e._snapState.isIdle) {
        snapIdle = e._snapState;
      }
    }
    return snapWaiting ??
        snapError ??
        snapIdle ??
        SnapState<dynamic>._withData(ConnectionState.done, 'data', true);
  }
}

///Used in tests
R? onCombinedCall<T, R>(
  OnCombined<T, R> on,
  T state, {
  bool isWaiting = false,
  dynamic error,
  T? data,
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
    ),
    state,
  );
}
