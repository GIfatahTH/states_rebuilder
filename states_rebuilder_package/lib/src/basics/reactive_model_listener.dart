part of '../rm.dart';

///Subscribe to state and notify listeners
class ReactiveModelListener<T> {
  final _listeners = <void Function(SnapState<T>? snap)>[];
  final _cleaners = <VoidCallback>[];
  final _sideEffectListeners = <void Function(SnapState<T>? snap)>[];
  void Function()? onFirstListerAdded;
  bool get hasListeners => _listeners.isNotEmpty;
  int get observerLength => _listeners.length;

  ///Add listener
  VoidCallback addListener(
    void Function(SnapState<T>? snap) setState, {
    VoidCallback? clean,
  }) {
    if (_listeners.isEmpty) {
      onFirstListerAdded?.call();
    }
    _listeners.add(setState);
    final cleanDisposer = addCleaner(() => _listeners.remove(setState));
    return () {
      if (_listeners.isEmpty) {
        return;
      }
      _listeners.remove(setState);
      cleanDisposer();
      if (_listeners.isEmpty) {
        clean?.call();
        // cleanState();
      }
    };
  }

  ///Notify all listeners
  void rebuildState(SnapState<T>? snap) {
    _listeners.forEach((setState) => setState(snap));
    _sideEffectListeners.forEach((fn) => fn(snap));
  }

  ///Add a callback to the cleaner list
  VoidCallback addCleaner(VoidCallback cleaner) {
    _cleaners.add(cleaner);
    return () => _cleaners.remove(cleaner);
  }

  ///Invoke all the registered cleaning callbacks
  void cleanState() {
    _cleaners.forEach((cleaner) => cleaner());
    _cleaners.clear();
    _sideEffectListeners.clear();
    onFirstListerAdded = null;
  }
}
