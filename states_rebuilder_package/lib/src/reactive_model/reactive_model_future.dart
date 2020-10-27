part of '../reactive_model.dart';

class ReactiveModelFuture<T> extends ReactiveModelInternal<T> {
  ReactiveModelFuture(InjectFuture<T> inject)
      : assert(inject != null),
        super._(inject) {
    _state = inject.initialValue;
    setState(
      (s) => inject.creationFutureFunction(),
      catchError: true,
      silent: true,
      filterTags: inject.filterTags,
    );
  }

  @override
  Future<T> refresh({void Function() onInitRefresh}) {
    cleaner(unsubscribe, true);
    unsubscribe();
    setState(
      (dynamic s) {
        final result = (inject as InjectFuture).creationFutureFunction();
        onInitRefresh?.call();
        return result;
      },
      catchError: true,
      silent: true,
      filterTags: (inject as InjectFuture).filterTags,
    );
    return stateAsync.catchError((_) {});
  }

  @override
  String type([bool detailed = true]) {
    if (detailed) {
      return '<Future<$T>>';
    }
    return '$T';
  }

  @override
  bool isA<T>() {
    return (inject as InjectFuture).creationFutureFunction is T Function();
  }
}
