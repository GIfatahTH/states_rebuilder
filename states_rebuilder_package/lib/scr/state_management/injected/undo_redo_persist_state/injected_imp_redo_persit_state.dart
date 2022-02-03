part of '../../rm.dart';

class InjectedImpRedoPersistState<T> extends InjectedImp<T> {
  InjectedImpRedoPersistState({
    required Object? Function() creator,
    required T? initialState,
    required SideEffects<T>? sideEffects,
    required StateInterceptor<T>? stateInterceptor,
    required bool autoDisposeWhenNotUsed,
    required String? debugPrintWhenNotifiedPreMessage,
    required Object? Function(T?)? toDebugString,
    required int undoStackLength,
    required PersistState<T> Function()? persist,
    required DependsOn<T>? dependsOn,
    required Object? Function(T? s)? watch,
  }) : super(
          creator: creator,
          initialState: initialState,
          sideEffectsGlobal: sideEffects,
          stateInterceptor: stateInterceptor,
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          debugPrintWhenNotifiedPreMessageGlobal:
              debugPrintWhenNotifiedPreMessage,
          toDebugString: toDebugString,
          dependsOn: dependsOn,
          watch: watch,
        ) {
    if (persist != null || undoStackLength > 0) {
      undoRedoPersistState = UndoRedoPersistState(
        undoStackLength: undoStackLength,
        persistanceProvider: persist?.call(),
      );
    }
  }
  UndoRedoPersistState<T>? undoRedoPersistState;
  T? shouldRecreateTheValue;
  @override
  Object? Function() get mockableCreator {
    final creator = super.mockableCreator;

    if (undoRedoPersistState?.persistanceProvider != null) {
      final val = _snapState._infoMessage == kInitMessage
          ? undoRedoPersistState!.persistedCreator()
          : null;

      Object? Function() recreate(T? val) {
        final shouldRecreate =
            undoRedoPersistState!.persistanceProvider!.shouldRecreateTheState;
        if (shouldRecreate == true ||
            (shouldRecreate == null && creator is Stream Function())) {
          if (val != null) {
            // See issue 192
            initialState = val;
            shouldRecreateTheValue = val;
          }
          return creator;
        }
        return val != null ? () => val : creator;
      }

      if (val is Future) {
        return () async {
          final r = await val;
          return recreate(r)();
        };
      }
      return recreate(val);
    }
    return creator;
  }

  @override
  void onStateInitialized() {
    super.onStateInitialized();
    if (shouldRecreateTheValue != null) {
      _snapState = _snapState.copyToHasData(shouldRecreateTheValue);
    }
  }

  @override
  void middleSetCreator(StateStatus status, Object? result) {
    super.middleSetCreator(status, result);
    if (_snapState.hasData || _snapState.isIdle) {
      undoRedoPersistState?.call(_snapState, this);
    }
  }

  @override
  void setToHasData(
    dynamic data, {
    SideEffects<T>? sideEffects,
    bool Function(SnapState<T>)? shouldOverrideDefaultSideEffects,
    StateInterceptor<T>? stateInterceptor,
  }) {
    super.setToHasData(
      data,
      sideEffects: sideEffects,
      shouldOverrideDefaultSideEffects: shouldOverrideDefaultSideEffects,
      stateInterceptor: stateInterceptor,
    );
    if (_snapState.hasData || _snapState.isIdle) {
      undoRedoPersistState?.call(_snapState, this);
    }
  }

  @override
  void undoState() {
    final snap = undoRedoPersistState?.undoState();
    if (snap == null) {
      return;
    }
    _snapState = snap.copyWith(oldSnapState: _snapState);
    notify();
  }

  @override
  void redoState() {
    final snap = undoRedoPersistState?.redoState();
    if (snap == null) {
      return;
    }
    _snapState = snap.copyWith(
      oldSnapState: _snapState,
    );
    notify();
  }

  @override
  void clearUndoStack() {
    undoRedoPersistState?.clearUndoStack();
    notify();
  }

  @override
  bool get canRedoState {
    ReactiveStatelessWidget.addToObs?.call(this);
    return undoRedoPersistState?.canRedoState ?? false;
  }

  @override
  bool get canUndoState {
    ReactiveStatelessWidget.addToObs?.call(this);
    return undoRedoPersistState?.canUndoState ?? false;
  }

  @override
  void persistState() {
    undoRedoPersistState?.persistanceProvider?.write(_snapState.state);
  }

  @override
  void deletePersistState() {
    undoRedoPersistState?.deleteState(this);
  }

  // ///If the state is persisted using [PersistState], the state is deleted from
  // ///the store and the new recalculated state is stored instead.
  // @override
  // Future<T?> refresh({}) {
  //   return super.refresh();
  // }

  @override
  void dispose() {
    if (_snapState.oldSnapState == null) {
      return;
    }
    undoRedoPersistState?.persistOnDispose(_snapState.state);
    shouldRecreateTheValue = null;
    super.dispose();
  }
}
