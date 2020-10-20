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
    try {
      final s = (inject as InjectImp)?.creationFunction();
      if (_deepEquality.equals(state, s)) {
        resetToIdle(s);
      } else {
        resetToIdle(s);
        if (hasObservers) {
          rebuildStates();
        }
      }
    } catch (e) {
      if (e is Error) {
        rethrow;
      }
      resetToHasError(e);
      notify();
    }
    onInitRefresh?.call();
    return stateAsync.catchError((_) {});
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
