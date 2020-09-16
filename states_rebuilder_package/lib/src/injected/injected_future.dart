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
    PersistState<T> persist,
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
    _initialStoredState = _persist?.read();
    return Inject<T>.future(
      () => _initialStoredState != null
          ? Future.value(_initialStoredState)
          : _creationFunction() as Future<T>,
      name: _name,
      initialValue: _initialValue,
      isLazy: false,
    );
  }
}
