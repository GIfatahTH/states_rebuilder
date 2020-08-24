part of '../injected.dart';

///implementation of [Injected] for Stream injection
class InjectedStream<T> extends Injected<T> {
  final T _initialValue;
  final Function(T) _watch;

  ///implementation of [Injected] for Stream injection
  InjectedStream(
    Stream<T> Function() creationFunction, {
    bool autoDisposeWhenNotUsed = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    Function(T) watch,
    bool isLazy = true,
    T initialValue,
    int undoStackLength,
  })  : _initialValue = initialValue,
        _watch = watch,
        super(
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          onData: onData,
          onError: onError,
          onWaiting: onWaiting,
          onInitialized: onInitialized,
          onDisposed: onDisposed,
          undoStackLength: undoStackLength,
        ) {
    _creationFunction = creationFunction;
    if (!isLazy) {
      _stateRM;
    }
  }
  @override
  String get _name => '___Injected${hashCode}Stream___';
  @override
  void injectStreamMock(Stream<T> Function() creationFunction) {
    super.injectStreamMock(creationFunction);
    _creationFunction = creationFunction;
    _cashedMockCreationFunction ??= _creationFunction;
  }

  @override
  Inject<T> _getInject() => Inject<T>.stream(
        _creationFunction as Stream<T> Function(),
        name: _name,
        initialValue: _initialValue,
        watch: _watch,
        isLazy: false,
      );

  @override
  Future<T> refresh() async {
    state = _initialValue;
    return super.refresh();
  }
}
