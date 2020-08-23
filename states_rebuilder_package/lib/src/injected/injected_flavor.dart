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
  static int _envMapLength;
  @override
  String get _name => '___Injected${hashCode}Interface___';
  @override
  Inject<T> _getInject() {
    assert(Injector.env != null, '''
You are using [Inject.interface] constructor. You have to define the [Inject.env] before the [runApp] method
    ''');
    assert(_impl[Injector.env] != null, '''
There is no implementation for ${Injector.env} of $T interface
    ''');
    _envMapLength ??= _impl.length;
    assert(_impl.length == _envMapLength, '''
You must be consistent about the number of flavor environment you have.
you had $_envMapLength flavors and you are defining ${_impl.length} flavors.
    ''');

    final creationFunction = _impl[Injector.env];
    if (creationFunction is Future<T> Function()) {
      return Inject.future(
        creationFunction,
        name: _name,
        initialValue: _initialValue,
        isLazy: false,
      );
    }
    return Inject(
      creationFunction as T Function(),
      name: _name,
    );
  }
}
