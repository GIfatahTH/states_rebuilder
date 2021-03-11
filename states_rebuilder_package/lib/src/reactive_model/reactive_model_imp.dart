part of '../reactive_model.dart';

class ReactiveModelImp<T> extends ReactiveModel<T> {
  ReactiveModelImp({
    required dynamic Function(ReactiveModel<T> rm) creator,
    T? nullState,
    T? initialState,
  }) : super(nullState, initialState) {
    _creator = creator;
  }

  ReactiveModelImp._({
    T? nullState,
    T? initialState,
  }) : super(nullState, initialState);

  factory ReactiveModelImp.future(
    Future<T> Function() future, {
    T? nullState,
    T? initialState,
    bool isLazy = true,
  }) {
    final rm = ReactiveModelImp(
      creator: (_) => future().asStream(),
      nullState: nullState,
      initialState: initialState,
    );
    if (!isLazy) {
      rm._initialize();
    }
    return rm;
  }

  factory ReactiveModelImp.stream(
    Stream<T> Function(ReactiveModel<T> rm) stream, {
    T? nullState,
    T? initialState,
    bool isLazy = true,
  }) {
    final rm = ReactiveModelImp(
      creator: stream,
      nullState: nullState,
      initialState: initialState,
    );
    if (!isLazy) {
      rm._initialize();
    }
    return rm;
  }
}
