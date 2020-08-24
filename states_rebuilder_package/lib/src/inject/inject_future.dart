part of '../inject.dart';

class InjectFuture<T> extends Inject<T> {
  final T initialValue;
  final List<dynamic> filterTags;
  Future<T> Function() creationFutureFunction;
  InjectFuture(
    this.creationFutureFunction, {
    this.initialValue,
    this.filterTags,
    dynamic name,
    bool isLazy = true,
  }) : super._() {
    _name = name?.toString();
    if (isLazy == false) {
      getReactive();
    }
  }

  @override
  ReactiveModel<T> _getRM([bool asNew = false]) {
    final rs = ReactiveModelFuture<T>(this);
    addToReactiveNewInstanceList(asNew ? rs : null);
    return rs;
  }

  @override
  T _getSingleton() {
    return singleton = getReactive().state;
  }
}
