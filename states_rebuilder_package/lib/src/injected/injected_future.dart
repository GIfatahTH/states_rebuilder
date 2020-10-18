part of '../injected.dart';

///implementation of [Injected] for future injection
class InjectedFuture<T> extends Injected<T> {
  final T _initialValue;

  ///implementation of [Injected] for future injection
  InjectedFuture(
    Future<T> Function() creationFunction, {
    bool autoDisposeWhenNotUsed = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    bool isLazy = true,
    T initialValue,
    int undoStackLength,
    PersistState<T> Function() persist,
    String debugPrintWhenNotifiedPreMessage,
  })  : _initialValue = initialValue,
        super(
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          onData: onData,
          onError: onError,
          onWaiting: onWaiting,
          onInitialized: onInitialized,
          onDisposed: onDisposed,
          undoStackLength: undoStackLength,
          persist: persist,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
        ) {
    _name = '___Injected${hashCode}Future___';
    _creationFunction = creationFunction;
    if (!isLazy) {
      _stateRM;
    }
  }

  @override
  void injectFutureMock(Future<T> Function() creationFunction) {
    super.injectFutureMock(creationFunction);
    _creationFunction = creationFunction;
    _cashedMockCreationFunction ??= _creationFunction;
  }

  @override
  Inject<T> _getInject() {
    if (_persistCallback != null) {
      _persist ??= _persistCallback();
      final value = _persist.read();
      if (value is Future) {
        return Inject<T>.future(
          () async {
            var result = await value;

            if (result is Function) {
              result = await result();
            }
            if (result is Function) {
              result = await result();
            }

            if (result != null) {
              return _initialStoredState = result;
            }

            return _creationFunction() as Future<T>;
          },
          name: _name,
        );
      }
      _initialStoredState = value;
    }

    return Inject<T>.future(
      () {
        return _initialStoredState != null
            ? Future.value(_initialStoredState)
            : _creationFunction() as Future<T>;
      },
      name: _name,
      initialValue: _initialStoredState ?? _initialValue,
    );
  }
}
