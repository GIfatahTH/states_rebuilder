part of '../inject.dart';

class InjectStream<T> extends Inject<T> {
  final T initialValue;
  final List<dynamic> filterTags;
  Object Function(T) watch;
  Stream<T> Function() creationStreamFunction;
  InjectStream(
    this.creationStreamFunction, {
    this.initialValue,
    this.filterTags,
    dynamic name,
    bool isLazy = true,
    this.watch,
  }) : super._() {
    _name = name?.toString();
    if (isLazy == false) {
      getReactive();
    }
  }

  @override
  ReactiveModel<T> _getRM([bool asNew = false]) {
    final rs = ReactiveModelStream<T>(this);
    addToReactiveNewInstanceList(asNew ? rs : null);
    return rs;
  }

  @override
  T _getSingleton() {
    return singleton = getReactive().state;
  }
}
