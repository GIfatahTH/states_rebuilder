part of '../injected.dart';

///implementation of [Injected]
class InjectedImp<T> extends Injected<T> {
  ///implementation of [Injected]
  InjectedImp(
    T Function() creationFunction, {
    bool autoDisposeWhenNotUsed = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    PersistState<T> persist,
    int undoStackLength,
    String debugPrintWhenNotifiedPreMessage,
  }) : super(
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
    _creationFunction = creationFunction;
    _name = '___Injected${hashCode}Imp___';
  }

  @override
  void injectMock(T Function() creationFunction) {
    super.injectMock(creationFunction);
    _creationFunction = creationFunction;
    _cashedMockCreationFunction ??= _creationFunction;
  }

  @override
  Inject<T> _getInject() {
    _initialStoredState = _persist?.read();
    return Inject<T>(
      () => _creationFunction() as T,
      name: _name,
      isLazy: false,
      joinSingleton: JoinSingleton.withCombinedReactiveInstances,
    );
  }
}
