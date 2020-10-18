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
    PersistState<T> Function() persist,
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

            return _creationFunction() as T;
          },
          name: _name,
        );
      }
      _initialStoredState = value;
    }
    return Inject<T>(
      () => _creationFunction() as T,
      name: _name,
    );
  }
}
