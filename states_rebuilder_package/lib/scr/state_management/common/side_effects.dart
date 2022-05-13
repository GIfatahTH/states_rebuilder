part of '../rm.dart';

///Side effect to be called when the state is initialized, mutated and disposed of
///
///See named constructor [SideEffects.onData], [SideEffects.onError], [SideEffects.onWaiting]
///[SideEffects.onAll], and [SideEffects.onOrElse]
class SideEffects<T> {
  ///Side effect to be called when the state is first initialized
  final void Function()? initState;

  ///Side effect to be called when the state is disposed of,
  final void Function()? dispose;

  ///Side effect to be called when the state is mutated
  final void Function(SnapState<T>)? onSetState;

  ///Side effect to be called when the state is mutated and after listening widgets
  ///have rebuilt.
  void Function([bool? isDisposed])? _onAfterBuild;
  void Function([bool? isDisposed])? get onAfterBuild => _onAfterBuild;

  ///Side effect to be called when the state is initialized, mutated and disposed of
  ///
  ///See named constructor [SideEffects.onData], [SideEffects.onError], [SideEffects.onWaiting]
  ///[SideEffects.onAll], and [SideEffects.onOrElse]
  SideEffects({
    this.initState,
    this.dispose,
    this.onSetState,
    VoidCallback? onAfterBuild,
  }) {
    if (onAfterBuild != null) {
      _onAfterBuild =
          ([bool? isDisposed]) => WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  if (isDisposed != true) {
                    onAfterBuild();
                  }
                },
              );
    }
  }

  ///Side effect to be called when he state is mutated successfully with data
  factory SideEffects.onData(
    void Function(T data) data, {
    void Function()? initState,
    void Function()? dispose,
  }) {
    return SideEffects(
      initState: initState,
      dispose: dispose,
      onSetState: (snap) {
        if (snap.hasData) {
          data(snap.data as T);
        }
      },
    );
  }

  ///Side effect to be called while waiting for the state to resolve
  factory SideEffects.onWaiting(
    void Function() onWaiting, {
    void Function()? initState,
    void Function()? dispose,
  }) {
    return SideEffects(
      initState: initState,
      dispose: dispose,
      onSetState: (snap) {
        if (snap.isWaiting) {
          onWaiting();
        }
      },
    );
  }

  ///Side effect to be called when the state has error.
  factory SideEffects.onError(
    void Function(dynamic err, VoidCallback refresh) onError, {
    void Function()? initState,
    void Function()? dispose,
  }) {
    return SideEffects(
      initState: initState,
      dispose: dispose,
      onSetState: (snap) {
        if (snap.hasError) {
          onError(snap.snapError!.error, snap.snapError!.refresher);
        }
      },
    );
  }

  ///Handle all possible for state status. Null argument will be ignored.
  factory SideEffects.onAll({
    required void Function()? onWaiting,
    required void Function(dynamic err, VoidCallback refresh)? onError,
    required void Function(T data)? onData,
    void Function()? initState,
    void Function()? dispose,
  }) {
    return SideEffects(
      initState: initState,
      dispose: dispose,
      onSetState: (snap) {
        if (snap.isWaiting) {
          onWaiting?.call();
          return;
        }
        if (snap.hasError) {
          onError?.call(snap.snapError!.error, snap.snapError!.refresher);
          return;
        }
        onData?.call(snap.data as T);
      },
    );
  }

  ///Handle the three state status with one required fallback callback.
  factory SideEffects.onOrElse({
    void Function()? onWaiting,
    void Function(dynamic err, VoidCallback refresh)? onError,
    void Function(T data)? onData,
    required void Function(T data) orElse,
    void Function()? initState,
    void Function()? dispose,
  }) {
    return SideEffects(
      initState: initState,
      dispose: dispose,
      onSetState: (snap) {
        if (snap.isWaiting && onWaiting != null) {
          onWaiting();
          return;
        }

        if (snap.hasError && onError != null) {
          onError(snap.snapError!.error, snap.snapError!.refresher);

          return;
        }

        if (snap.hasData && onData != null) {
          onData(snap.data as T);
          return;
        }
        orElse(snap.data as T);
      },
    );
  }
}
