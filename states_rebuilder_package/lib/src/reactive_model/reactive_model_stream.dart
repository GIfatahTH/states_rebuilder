part of '../reactive_model.dart';

class ReactiveModelStream<T> extends ReactiveModelInt<T> {
  ReactiveModelStream(InjectStream<T> inject)
      : assert(inject != null),
        super._(inject) {
    _state = inject.initialValue;
    setState(
      (s) => inject.creationStreamFunction(),
      catchError: true,
      silent: true,
      filterTags: inject.filterTags,
      watch: inject.watch,
    );
  }

  @override
  Future<T> refresh({void Function() onInitRefresh}) {
    cleaner(unsubscribe, true);
    unsubscribe();
    setState(
      (dynamic s) => (inject as InjectStream).creationStreamFunction(),
      onSetState: (_) {
        if (onInitRefresh != null && isWaiting) {
          onInitRefresh.call();
        }
      },
      catchError: true,
      silent: true,
      filterTags: (inject as InjectStream).filterTags,
    );
    return stateAsync;
  }

  @override
  String type([bool detailed = true]) {
    if (detailed) {
      return '<Stream<$T>>';
    }
    return '$T';
  }

  @override
  bool isA<T>() {
    return (inject as InjectStream).creationStreamFunction is T Function();
  }
}
