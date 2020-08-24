part of '../reactive_model.dart';

class ReactiveModelImpNew<T> extends ReactiveModelImp<T> {
  ReactiveModelImpNew(Inject<T> inject) : super(inject);

  @override
  T get state {
    return inject.getSingleton();
  }

  @override
  ReactiveModel<T> asNew([dynamic seed = 'defaultReactiveSeed']) {
    return inject.getReactive().asNew(seed);
  }

  void _joinSingleton(
    bool joinSingleton,
    dynamic Function() joinSingletonToNewData,
  ) {
    final reactiveSingleton = inject.getReactive();
    if (joinSingletonToNewData != null) {
      reactiveSingleton._joinSingletonToNewData = joinSingletonToNewData();
    }

    if ((inject as InjectImp).joinSingleton ==
            JoinSingleton.withNewReactiveInstance ||
        joinSingleton == true) {
      reactiveSingleton.snapshot = snapshot;
      if (reactiveSingleton.hasObservers) {
        reactiveSingleton.rebuildStates();
      }
    } else if ((inject as InjectImp).joinSingleton ==
        JoinSingleton.withCombinedReactiveInstances) {
      reactiveSingleton.snapshot = _combinedSnapshotState;
      if (reactiveSingleton.hasObservers) {
        reactiveSingleton.rebuildStates();
      }
    }
  }

  String toString() {
    String rm = '${type()} RM (new seed: "$_seed")'
        ' (#Code $hashCode)';
    int num = 0;
    observers().forEach((key, value) {
      if (key != '_ReactiveModelSubscriber') {
        if (!'$value'.contains('$Injector')) {
          num++;
        }
      }
    });

    return '$rm | ${whenConnectionState<String>(
      onIdle: () => 'isIdle ($state)',
      onWaiting: () => 'isWaiting ($state)',
      onData: (data) => 'hasData : ($data)',
      onError: (dynamic e) => 'hasError : ($e)',
      catchError: false,
    )} | $num observing widgets';
  }
}
