part of '../inject.dart';

///Base class for [Inject]
class InjectImp<T> extends Inject<T> {
  /// The Creation Function.
  T Function() creationFunction;

  ///new reactive instances can transmit their state and notification to reactive singleton.
  JoinSingleton joinSingleton;

  InjectImp(
    this.creationFunction, {
    dynamic name,
    bool isLazy = true,
    JoinSingleton joinSingleton,
  }) : super._() {
    this.joinSingleton = joinSingleton;
    _name = name?.toString();
    if (isLazy == false) {
      getReactive();
    }
  }

  @override
  T _getSingleton() {
    return creationFunction();
  }

  @override
  ReactiveModel<T> _getRM([bool asNew = false]) {
    final rs = asNew ? ReactiveModelImpNew<T>(this) : ReactiveModelImp<T>(this);
    addToReactiveNewInstanceList(asNew ? rs : null);
    return rs;
  }
}
