part of '../rm.dart';

///Undo-redo and persist state
class UndoRedoPersistState<T> {
  final int undoStackLength;
  final PersistState<T>? persistanceProvider;

  ///Undo-redo and persist state
  UndoRedoPersistState({
    required this.undoStackLength,
    required this.persistanceProvider,
  });
  final Queue<SnapState<T>> _undoQueue = ListQueue();
  final Queue<SnapState<T>> _redoQueue = ListQueue();
  static final Set<PersistState> storageProviders = {};

  ///Whether the state can be redone.
  bool get canRedoState => _redoQueue.isNotEmpty;

  ///Whether the state can be done
  bool get canUndoState => _undoQueue.length > 1;

  ///Clear undoStack;
  void clearUndoStack() {
    _undoQueue.clear();
    _redoQueue.clear();
  }

  ///redo to the next valid state (isWaiting and hasError are ignored)
  SnapState<T>? redoState() {
    if (!canRedoState) {
      return null;
    }
    _undoQueue.add(_redoQueue.removeLast());
    return _undoQueue.last;
  }

  ///undo to the last valid state (isWaiting and hasError are ignored)
  SnapState<T>? undoState() {
    if (!canUndoState) {
      return null;
    }
    _redoQueue.add(_undoQueue.removeLast());
    // final oldSnapShot = ;
    return _undoQueue.last;
  }

  void _addToUndoQueue(SnapState<T> snap) {
    if (undoStackLength < 2) {
      return;
    }
    _undoQueue.add(snap);
    _redoQueue.clear();
    if (_undoQueue.length > undoStackLength) {
      _undoQueue.removeFirst();
    }
  }

//
  ///
  FutureOr<T?> persistedCreator() {
    if (persistanceProvider == null) {
      return null;
    }

    storageProviders.add(persistanceProvider!);

    late FutureOr<T?> Function() c;

    // if (this is InjectedAuth) {
    //   _coreRM.persistanceProvider!.persistOn = PersistOn.manualPersist;
    // }
    var result = persistanceProvider!.read();
    if (result is Future) {
      c = () async {
        dynamic innerResult = await (result as Future);
        result = null;
        if (innerResult is Function) {
          innerResult = await innerResult();
          if (innerResult is Function) {
            innerResult = await innerResult();
          }
        }
        return innerResult as T?;
      };
    } else {
      c = () {
        final r = result as T?;
        result = null;

        return r;
      };
    }
    return c();
  }

  void call(SnapState<T> snap, InjectedImp<T> injected) async {
    _addToUndoQueue(snap);
    if (persistanceProvider == null) {
      return;
    }
    if (persistanceProvider!.persistOn == null) {
      final oldSnap = injected.oldSnap;
      try {
        if (snap.data == null) {
          return await persistanceProvider!.delete();
        }
        await persistanceProvider!.write(snap.data!);
      } catch (e, s) {
        if (persistanceProvider!.catchPersistError) {
          StatesRebuilerLogger.log('Write to localStorage error', e, s);
          return null;
        }
        injected._reactiveModelState._setSnapStateAndRebuild =
            injected.middleSnap(
          oldSnap!._copyToHasError(e, () {}, stackTrace: s),
        );
        injected.onError?.call(e, s);
      }
    }
  }

  void persistOnDispose(T state) async {
    if (persistanceProvider == null) {
      return;
    }
    persistanceProvider!.cachedJson = null;
    if (persistanceProvider != null) {
      storageProviders.remove(persistanceProvider!);
    }
    if (persistanceProvider!.persistOn != PersistOn.disposed) {
      return;
    }
    await persistanceProvider!.write(state);
  }

  static void cleanStorageProviders() {
    for (var store in storageProviders) {
      store.cachedJson = null;
    }
  }

  void deleteState(InjectedImp<T> injected) async {
    final oldSnap = injected.snapState;
    try {
      await persistanceProvider!.delete();
    } catch (e, s) {
      injected._reactiveModelState._setSnapStateAndRebuild =
          injected.middleSnap(
        oldSnap._copyToHasError(e, () {}, stackTrace: s),
      );
      injected.onError?.call(e, s);
    }
  }
}
