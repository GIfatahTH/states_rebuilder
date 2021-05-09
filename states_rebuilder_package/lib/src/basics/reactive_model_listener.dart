part of '../rm.dart';

///Subscribe to state and notify listeners
class ReactiveModelListener<T> {
  final _listeners = <void Function(SnapState<T>? snap)>[];
  final _cleaners = <VoidCallback>[];
  final _sideEffectListeners = <void Function(SnapState<T>? snap)>[];
  void Function(int length)? onAddListener;
  void Function(int length)? onRemoveListener;
  void Function()? onFirstListerAdded;
  bool get hasListeners => _listeners.isNotEmpty;
  int get observerLength => _listeners.length;

  ///Add listener
  VoidCallback addListenerForRebuild(
    void Function(SnapState<T>? snap) setState, {
    VoidCallback? clean,
  }) {
    if (_listeners.isEmpty) {
      //Used in dependent injected
      // _listeners.addAll(_sideEffectListeners);
      // _sideEffectListeners.clear();
      onFirstListerAdded?.call();
    }
    _listeners.add(setState);
    assert(() {
      onAddListener?.call(_listeners.length);
      return true;
    }());
    final cleanDisposer = addCleaner(() => _listeners.remove(setState));
    return () {
      cleanDisposer();
      if (_listeners.isEmpty) {
        return;
      }
      _listeners.remove(setState);
      assert(() {
        onRemoveListener?.call(_listeners.length);
        return true;
      }());
      if (_listeners.isEmpty) {
        clean?.call();
      }
    };
  }

  VoidCallback addListenerForSideEffect(
    void Function(SnapState<T>? snap) setState, {
    VoidCallback? clean,
  }) {
    _sideEffectListeners.add(setState);
    final cleanDisposer = addCleaner(
      () => _sideEffectListeners.remove(setState),
    );
    return () {
      cleanDisposer();
      if (_sideEffectListeners.isEmpty) {
        return;
      }
      _sideEffectListeners.remove(setState);
      if (_listeners.isEmpty && _sideEffectListeners.isEmpty) {
        clean?.call();
      }
    };
  }

  ///Notify all listeners
  void rebuildState(SnapState<T>? snap) {
    _listeners.forEach((setState) => setState(snap));
    [..._sideEffectListeners].forEach((fn) => fn(snap));
  }

  ///Add a callback to the cleaner list
  VoidCallback addCleaner(VoidCallback cleaner) {
    _cleaners.add(cleaner);
    return () => _cleaners.remove(cleaner);
  }

  ///Invoke all the registered cleaning callbacks
  void cleanState() {
    [..._cleaners].forEach((cleaner) => cleaner());
    _cleaners.clear();
    _sideEffectListeners.clear();
    // onFirstListerAdded = null;
  }
}
