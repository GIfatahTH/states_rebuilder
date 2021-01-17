part of '../reactive_model.dart';

///{@template on}
///Callbacks to be invoked depending on the state status of an [Injected] model
///
///For more control on when to invoke the callbacks use:
///* **[OnCombined.data]**: The callback is invoked only when the [Injected] model emits a
///notification with onData status.
///* **[OnCombined.waiting]**: The callback is invoked only when the [Injected] model emits
///a notification with waiting status.
///* **[OnCombined.error]**: The callback is invoked only when the [Injected] model emits a
///notification with error status.
///
///See also:  **[OnCombined.all]**, **[OnCombined.or]**.
///{@endtemplate}
class OnCombined<T, R> {
  ///Callback to be called when first the model is initialized.
  final R Function()? onIdle;

  ///Callback to be called when first the model is waiting for and async task.
  final R Function()? onWaiting;

  ///Callback to be called when first the model has an error.
  final R Function(dynamic error)? onError;

  ///Callback to be called when first the model has data.
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

  ///The callback is always invoked when the [Injected] model emits a
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

  ///{@macro on}
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

  ///The callback is invoked only when the [Injected] model emits a
  ///notification with onData status.
  factory OnCombined.data(R Function(T state) fn) {
    return OnCombined._(
      onIdle: null,
      onWaiting: null,
      onError: null,
      onData: fn,
      // onType: _OnType.onData,
    ).._hasOnDataOnly = true;
  }

  ///The callback is invoked only when the [Injected] model emits a
  ///notification with waiting status.
  factory OnCombined.waiting(R Function() fn) {
    return OnCombined._(
      onIdle: null,
      onWaiting: fn,
      onError: null,
      onData: null,
      // onType: _OnType.onWaiting,
    );
  }

  ///The callback is invoked only when the [Injected] model emits a
  ///notification with error status.
  factory OnCombined.error(R Function(dynamic error) fn) {
    return OnCombined._(
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
  ///To be forced to define all state status use [OnCombined.all].
  factory OnCombined.or({
    R Function()? onIdle,
    R Function()? onWaiting,
    R Function(dynamic error)? onError,
    R Function(T state)? onData,
    required R Function(T state) or,
  }) {
    return OnCombined._(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData ?? or,
      // onType: _OnType.when,
    );
  }

  ///Set of callbacks to be invoked  when the [Injected] model emits a
  ///notification with the corresponding state status.
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
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
      // onType: _OnType.when,
    );
  }

  R? call(SnapState snapState, T state) {
    if (snapState.isWaiting) {
      if (_hasOnWaiting) {
        return onWaiting?.call();
      }
      return onData?.call(state);
    }
    if (snapState.hasError) {
      if (_hasOnError) {
        return onError?.call(snapState.error);
      }
      return onData?.call(state);
    }

    if (snapState.isIdle) {
      if (_hasOnIdle) {
        return onIdle?.call();
      }
      if (_hasOnData) {
        return onData?.call(state);
      }
      if (_hasOnWaiting) {
        return onWaiting?.call();
      }
      if (_hasOnError) {
        return onError?.call(snapState.error);
      }
    }

    return onData?.call(state);
  }
}

// enum _OnType { onData, onWaiting, onError, when }
