part of '../injected.dart';

abstract class InjectedBaseCommon<T> {
  Inject<T> _inject;
  ReactiveModel<T> _rm;
  T _state;

  ReactiveModel<T> _setReactiveModel([ReactiveModel<T> rm]) {
    return _rm = rm ?? _inject.getReactive();
  }

  T _setModelState() {
    return _state = _inject.getSingleton();
  }
}
