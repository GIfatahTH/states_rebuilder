part of 'injected_crud.dart';

class OnCRUD<T> {
  final T Function()? onWaiting;
  final T Function(dynamic err, void Function() refresh)? onError;
  final T Function(dynamic data) onResult;
  OnCRUD({
    required T Function()? onWaiting,
    required T Function(dynamic err, void Function() refresh)? onError,
    required T Function(dynamic data) onResult,
  })   : this.onWaiting = onWaiting,
        this.onError = onError,
        this.onResult = onResult;

  ///Listen to an InjectedCRUD state
  Widget listenTo(
    InjectedCRUD inj, {
    void Function()? dispose,
    On<void>? onSetState,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    final injected = inj as InjectedCRUDImp;
    return StateBuilderBase<_OnCRUDWidget<T>>(
      (_, setState) {
        injected.initialize();
        return LifeCycleHooks(
          mountedState: (_) {
            injected.onCRUDListeners.addListenerForRebuild(
              (snap) {
                onSetState?.call(injected.onCrudSnap);
                setState();
                assert(() {
                  if (debugPrintWhenRebuild != null) {
                    print('REBUILD <' + debugPrintWhenRebuild + '>: $snap');
                  }
                  return true;
                }());
              },
              clean: null,
            );

            assert(() {
              if (debugPrintWhenRebuild != null) {
                print('INITIAL BUILD <' +
                    debugPrintWhenRebuild +
                    '>: ${injected.snapState}');
              }
              return true;
            }());
          },
          dispose: (_) {
            dispose?.call();
            // disposer();
          },
          didUpdateWidget: (context, oldWidget, newWidget) {
            final newInj = newWidget.inject as InjectedImp;
            final oldInj = oldWidget.inject as InjectedImp;
            if (newInj.reactiveModelState != oldInj.reactiveModelState) {
              newInj.reactiveModelState.dispose();
              newInj.reactiveModelState = oldInj.reactiveModelState;
              (newInj as InjectedCRUDImp).onCRUDListeners =
                  (oldInj as InjectedCRUDImp).onCRUDListeners;
              newInj.undoRedoPersistState = oldInj.undoRedoPersistState;
            }
          },
          builder: (ctx, widget) {
            if (injected.onCrudSnap.isWaiting) {
              return (widget.onWaiting?.call() ??
                  widget.onResult(injected.onCrudSnap.data)) as Widget;
            }
            if (injected.onCrudSnap.hasError) {
              return (widget.onError
                      ?.call(injected.error, injected.onErrorRefresher) ??
                  widget.onResult(injected.onCrudSnap.data)) as Widget;
            }
            return (widget.onResult(injected.onCrudSnap.data)) as Widget;
          },
        );
      },
      widget: _OnCRUDWidget<T>(
        inject: injected,
        onWaiting: onWaiting,
        onError: onError,
        onResult: onResult,
      ),
      key: key,
    );
  }
}

class _OnCRUDWidget<T> {
  final Injected inject;

  final T Function()? onWaiting;
  final T Function(dynamic err, void Function() refresh)? onError;
  final T Function(dynamic data) onResult;
  _OnCRUDWidget({
    required this.inject,
    this.onWaiting,
    this.onError,
    required this.onResult,
  });
}
