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
  final T Function()? onIdle;

  ///Callback to be called when first the model is waiting for and async task.
  final T Function()? onWaiting;

  ///Callback to be called when first the model has an error.
  final T Function(dynamic err)? onError;

  ///Callback to be called when first the model has data.
  final T Function()? onData;
  // final _OnType _onType;

  bool get _hasOnWaiting => onWaiting != null;
  bool get _hasOnError => onError != null;
  bool get _hasOnIdle => onIdle != null;
  bool get _hasOnData => onData != null;
  bool _hasOnDataOnly = false;
  On._({
    required this.onIdle,
    required this.onWaiting,
    required this.onError,
    required this.onData,
    // required _OnType onType,
  });

  ///The callback is always invoked when the [Injected] model emits a
  ///notification.
  factory On.any(
    T Function() builder,
  ) {
    return On._(
      onIdle: null,
      onWaiting: null,
      onError: null,
      onData: builder,
      // onType: _OnType.when,
    );
  }

  ///{@macro on}
  factory On(
    T Function() builder,
  ) {
    return On._(
      onIdle: null,
      onWaiting: null,
      onError: null,
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
    ).._hasOnDataOnly = true;
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
  factory On.error(T Function(dynamic err) fn) {
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
    T Function(dynamic err)? onError,
    T Function()? onData,
    required T Function() or,
  }) {
    return On._(
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
  ///For optional callbacks use [On.or].
  factory On.all({
    required T Function() onIdle,
    required T Function() onWaiting,
    required T Function(dynamic err) onError,
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

  T? call<M>(SnapState snapState) {
    if (snapState.isWaiting) {
      if (_hasOnWaiting) {
        return onWaiting?.call();
      }
      return onData?.call();
    }
    if (snapState.hasError) {
      if (_hasOnError) {
        return onError?.call(snapState.error);
      }
      return onData?.call();
    }

    if (snapState.isIdle) {
      if (_hasOnIdle) {
        return onIdle?.call();
      }
      if (_hasOnData) {
        return onData?.call();
      }
      if (_hasOnWaiting) {
        return onWaiting?.call();
      }
      if (_hasOnError) {
        return onError?.call(snapState.error);
      }
    }

    return onData?.call();
  }
}

// enum _OnType { onData, onWaiting, onError, when }
