part of '../rm.dart';

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
  final R Function(T data, dynamic error, void Function() refresh)? _onError;

  ///Callback to be called if all injected models have data
  final R Function(T data)? _onData;
  // final _OnType _onType;

  bool get _hasOnWaiting => _onWaiting != null;
  bool get _hasOnError => _onError != null;
  bool get _hasOnIdle => _onIdle != null;
  bool get _hasOnData => _onData != null;
  InjectedBaseState<dynamic>? _notifiedInject;
  SnapState<dynamic>? _combinedSnap;
  OnCombined._({
    required R Function(T data)? onIdle,
    required R Function(T data)? onWaiting,
    required R Function(T data, dynamic error, void Function() refresh)?
        onError,
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
      onError: (T state, dynamic _, void Function() __) => builder(state),
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
  factory OnCombined.error(
      R Function(dynamic error, void Function() refresh) fn) {
    return OnCombined._(
      onIdle: null,
      onWaiting: null,
      onError: (_, dynamic err, void Function() refresh) => fn(err, refresh),
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
    R Function(dynamic error, void Function() refresh)? onError,
    R Function(T state)? onData,
    required R Function(T state) or,
  }) {
    return OnCombined._(
      onIdle: onIdle != null ? (_) => onIdle() : or,
      onWaiting: onWaiting != null ? (_) => onWaiting() : or,
      onError: onError != null
          ? (_, dynamic err, void Function() refresh) => onError(err, refresh)
          : (s, dynamic err, __) => or(s),
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
    required R Function(dynamic error, void Function() refresh) onError,
    required R Function(T state) onData,
  }) {
    return OnCombined._(
      onIdle: (_) => onIdle(),
      onWaiting: (_) => onWaiting(),
      onError: (_, dynamic err, void Function() refresh) =>
          onError(err, refresh),
      onData: onData,
    );
  }

  // bool _canRebuild(ReactiveModel rm) {
  //   if (rm.isWaiting) {
  //     return _hasOnWaiting;
  //   }
  //   if (rm.hasError) {
  //     return _hasOnError;
  //   }
  //   return true;
  // }

  R? _call(SnapState snapState, T state, [bool isSideEffect = true]) {
    if (snapState.isWaiting) {
      if (_hasOnWaiting) {
        return _onWaiting?.call(state);
      }
      return _onData?.call(state);
    }
    if (snapState.hasError) {
      if (_hasOnError) {
        return _onError?.call(
            state, snapState.error, snapState.onErrorRefresher!);
      }
      return _onData?.call(state);
    }

    if (snapState.isIdle) {
      if (_hasOnIdle) {
        return _onIdle?.call(state);
      }
      if (isSideEffect) {
        return null;
      }
      if (_hasOnData) {
        return _onData?.call(state);
      }
      if (_hasOnWaiting) {
        return _onWaiting?.call(state);
      }
      if (_hasOnError) {
        return _onError?.call(state, snapState.error, () {});
      }
    }

    if (_hasOnData) {
      return _onData?.call(state);
    }
    if (isSideEffect) {
      return null;
    }
    if (_hasOnWaiting) {
      return _onWaiting!.call(state);
    }

    if (_hasOnError) {
      return _onError!.call(state, snapState.error, () {});
    }
  }
}

///Used in tests
R? onCombinedCall<T, R>(
  OnCombined<T, R> on,
  T state, {
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
    state,
    isSideEffect,
  );
}
