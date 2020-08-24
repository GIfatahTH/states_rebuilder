part of '../injected.dart';

///implementation of [Injected] for Flavor injection
class InjectedInterface<T> extends Injected<T> {
  final Map<dynamic, FutureOr<T> Function()> _impl;
  final T _initialValue;

  ///implementation of [Injected] for Flavor injection
  InjectedInterface(
    Map<dynamic, FutureOr<T> Function()> impl, {
    bool autoDisposeWhenNotUsed = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    T initialValue,
    int undoStackLength,
    bool isLazy = true,
  })  : _impl = impl,
        _initialValue = initialValue,
        super(
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          onData: onData,
          onError: onError,
          onWaiting: onWaiting,
          onInitialized: onInitialized,
          onDisposed: onDisposed,
          undoStackLength: undoStackLength,
        ) {
    if (!isLazy) {
      _stateRM;
    }
  }
  @override
  String get _name => '___Injected${hashCode}Interface___';
  @override
  Inject<T> _getInject() {
    return Inject.interface(
      _impl,
      name: _name,
      initialValue: _initialValue,
    );
  }
}
