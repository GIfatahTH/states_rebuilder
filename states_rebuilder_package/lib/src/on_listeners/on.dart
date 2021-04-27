part of '../rm.dart';

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
  factory On.error(T Function(dynamic err, void Function() refresh) fn) {
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
    T Function(dynamic err, void Function() refresh)? onError,
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

  T? call(SnapState snapState, [bool isSideEffect = true]) {
    if (snapState.isWaiting) {
      if (_hasOnWaiting) {
        return _onWaiting!.call();
      }
      if (isSideEffect) {
        return null;
      }
      return _onData?.call();
    }
    if (snapState.hasError) {
      if (_hasOnError) {
        return _onError!.call(snapState.error, snapState.onErrorRefresher!);
      }
      if (isSideEffect) {
        return null;
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

  static OnAuth<T> auth<T>({
    T Function()? onInitialWaiting,
    T Function()? onWaiting,
    required T Function() onUnsigned,
    required T Function() onSigned,
  }) {
    return OnAuth<T>(
      onInitialWaiting: onInitialWaiting,
      onWaiting: onWaiting,
      onUnsigned: onUnsigned,
      onSigned: onSigned,
    );
  }

  static OnCRUD<T> crud<T>({
    required T Function()? onWaiting,
    required T Function(dynamic err, void Function() refresher)? onError,
    required T Function(dynamic data) onResult,
  }) {
    return OnCRUD<T>(
      onWaiting: onWaiting,
      onError: onError,
      onResult: onResult,
    );
  }

  static OnFuture<F> future<F>({
    required Widget Function()? onWaiting,
    required Widget Function(dynamic err, void Function() refresh)? onError,
    required Widget Function(F data, void Function() refresh) onData,
  }) {
    return OnFuture<F>(
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
    );
  }

  ///Used to subscribe to an [InjectedAnimation].
  ///
  ///Example:
  ///
  ///First inject an animation:
  ///
  ///```dart
  /// final animation = RM.injectAnimation(
  ///   duration: const Duration(seconds: 1),
  ///   curve: Curves.fastOutSlowIn,
  /// );
  ///```
  ///
  ///## Implicit Animation
  ///In the widget tree :
  ///
  ///```dart
  ///  On.animation(
  ///   (animate) => Container(
  ///     width: animate(selected ? 200.0 : 100.0),
  ///     height: animate(selected ? 100.0 : 200.0, 'height'),
  ///     color: animate(selected ? Colors.red : Colors.blue),
  ///     alignment: animate(
  ///       selected ? Alignment.center : AlignmentDirectional.topCenter,
  ///     ),
  ///     child: const FlutterLogo(size: 75),
  ///   ),
  /// ).listenTo(animation),
  ///```
  ///Similar to Flutter AnimatedContainer, when the `selected` variable value is toggled
  ///and the the `On.animation` is rebuild, the animation is implicitly animated.
  ///
  ///## Explicit Animation
  ///
  ///Use `animate.fromTween` to explicitly parametrize your animation.
  ///```dart
  /// On.animation(
  ///   (animate) => Transform.rotate(
  ///     angle: animate.formTween(
  ///       (_) => Tween(begin: 0, end: 2 * 3.14),
  ///     )!,
  ///     child: const FlutterLogo(size: 75),
  ///   ),
  /// ).listenTo(animation),
  ///```
  ///
  ///You can also use pre-built widget of the Flutter library that ends with
  ///Transition (ex:SlideTransition,  RotationTransition)
  ///
  ///This is an example of SlideTransition.
  ///```dart
  ///On.animation(
  ///  (_) => SlideTransition(
  ///    position: Tween<Offset>(
  ///      begin: Offset.zero,
  ///      end: const Offset(1.5, 0.0),
  ///    ).animate(animation.curvedAnimation),
  ///    child: const Padding(
  ///      padding: EdgeInsets.all(8.0),
  ///      child: FlutterLogo(size: 150.0),
  ///    ),
  ///  ),
  ///).listenTo(
  ///  animation,
  ///  onInitialized: () {
  ///    animation.triggerAnimation();
  ///  },
  ///);
  ///```
  static OnAnimation animation<F>(Widget Function(Animate animate) anim) {
    return OnAnimation(anim);
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
  return on.call(
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
