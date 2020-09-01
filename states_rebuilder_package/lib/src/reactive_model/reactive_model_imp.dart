part of '../reactive_model.dart';

class ReactiveModelImp<T> extends ReactiveModelInternal<T> {
  ReactiveModelImp(Inject<T> inject)
      : assert(inject != null),
        super._(inject) {
    snapshot = AsyncSnapshot<T>.withData(
      ConnectionState.none,
      inject?.getSingleton(),
    );
  }

  @override
  Future<T> refresh({void Function() onInitRefresh}) {
    cleaner(unsubscribe, true);
    unsubscribe();
    setState(
      (s) => (inject as InjectImp).creationFunction(),
      silent: true,
    );
    onInitRefresh?.call();
    resetToIdle();
    return stateAsync;
  }

  @override
  String type([bool detailed = true]) {
    if (detailed) {
      return '<$T>';
    }
    return '$T';
  }

  @override
  bool isA<T>() {
    return (inject as InjectImp).creationFunction is T Function();
  }
}
