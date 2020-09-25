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
    String debugPrintWhenNotifiedPreMessage,
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
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
        ) {
    _name = '___Injected${hashCode}Interface___';
    if (!isLazy) {
      _stateRM;
    }
  }

  @override
  Inject<T> _getInject() {
    if (_creationFunction is T Function()) {
      return Inject<T>(
        _creationFunction as T Function(),
        name: _name,
        isLazy: false,
      );
    }

    if (_creationFunction is Future<T> Function()) {
      return Inject<T>.future(
        _creationFunction as Future<T> Function(),
        name: _name,
        isLazy: false,
      );
    }

    return Inject.interface(
      _impl,
      name: _name,
      initialValue: _initialValue,
    );
  }

  @override
  void injectMock(T Function() creationFunction) {
    dispose();
    _creationFunction = creationFunction;
    _cashedMockCreationFunction ??= _creationFunction;
  }

  @override
  void injectFutureMock(Future<T> Function() creationFunction) {
    dispose();
    _creationFunction = creationFunction;
    _cashedMockCreationFunction ??= _creationFunction;
  }
}
