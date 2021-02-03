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
  final R Function(T data)? onIdle;

  ///Callback to be called when any of the the model is waiting for and async task.
  final R Function(T data)? onWaiting;

  ///Callback to be called when all models are not waiting and at least one of
  ///them has an error.
  final R Function(T data, dynamic error)? onError;

  ///Callback to be called if all injected models have data
  final R Function(T data)? onData;
  // final _OnType _onType;

  bool get _hasOnWaiting => onWaiting != null;
  bool get _hasOnError => onError != null;
  bool get _hasOnIdle => onIdle != null;
  bool get _hasOnData => onData != null;
  bool _hasOnDataOnly = false;

  OnCombined._({
    required this.onIdle,
    required this.onWaiting,
    required this.onError,
    required this.onData,
    // required _OnType onType,
  });

  ///The callback is always invoked when any of the [Injected] models emits a
  ///notification.
  factory OnCombined.any(
    R Function(T state) builder,
  ) {
    return OnCombined._(
      onIdle: null,
      onWaiting: null,
      onError: null,
      onData: builder,
      // onType: _OnType.when,
    );
  }

  ///{@macro OnCombined}
  factory OnCombined(
    R Function(T state) builder,
  ) {
    return OnCombined._(
      onIdle: null,
      onWaiting: null,
      onError: null,
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
    ).._hasOnDataOnly = true;
  }

  ///The callback is invoked only when one of the [Injected] models emits a
  ///notification with waiting status.
  factory OnCombined.waiting(R Function() fn) {
    return OnCombined._(
      onIdle: null,
      onWaiting: (_) => fn(),
      onError: null,
      onData: null,
      // onType: _OnType.onWaiting,
    );
  }

  ///The callback is invoked only when any of the [Injected] models emits a
  ///notification with error status and with no other model is waiting.
  factory OnCombined.error(R Function(dynamic error) fn) {
    return OnCombined._(
      onIdle: null,
      onWaiting: null,
      onError: (_, err) => fn(err),
      onData: null,
      // onType: _OnType.onError,
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
      onError: onError != null ? (_, err) => onError(err) : (s, err) => or(s),
      onData: onData ?? or,
      // onType: _OnType.when,
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
      onError: (_, err) => onError(err),
      onData: onData,
      // onType: _OnType.when,
    );
  }

  R? call(SnapState snapState, T state) {
    if (snapState.isWaiting) {
      if (_hasOnWaiting) {
        return onWaiting?.call(state);
      }
      return onData?.call(state);
    }
    if (snapState.hasError) {
      if (_hasOnError) {
        return onError?.call(state, snapState.error);
      }
      return onData?.call(state);
    }

    if (snapState.isIdle) {
      if (_hasOnIdle) {
        return onIdle?.call(state);
      }
      if (_hasOnData) {
        return onData?.call(state);
      }
      if (_hasOnWaiting) {
        return onWaiting?.call(state);
      }
      if (_hasOnError) {
        return onError?.call(state, snapState.error);
      }
    }

    return onData?.call(state);
  }
}

// enum _OnType { onData, onWaiting, onError, when }
