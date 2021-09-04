part of 'injected_crud.dart';

class OnCRUD<T> {
  final T Function()? onWaiting;
  final T Function(dynamic err, void Function() refresh)? onError;
  final T Function(dynamic data) onResult;
  OnCRUD({
    required T Function()? onWaiting,
    required T Function(dynamic err, void Function() refresh)? onError,
    required T Function(dynamic data) onResult,
  })  : this.onWaiting = onWaiting,
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
                    StatesRebuilerLogger.log(
                        'REBUILD <' + debugPrintWhenRebuild + '>: $snap');
                  }
                  return true;
                }());
              },
              clean: null,
            );

            assert(() {
              if (debugPrintWhenRebuild != null) {
                StatesRebuilerLogger.log('INITIAL BUILD<' +
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
              Widget? w;
              if (injected.hasError) {
                w = widget.onError?.call(
                  injected.error,
                  injected.onErrorRefresher,
                ) as Widget?;
              } else {
                w = widget.onError?.call(
                  injected.onCrudSnap.error,
                  injected.onCrudSnap.onErrorRefresher!,
                ) as Widget?;
              }
              return w ?? widget.onResult(injected.onCrudSnap.data) as Widget;
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

class OnCRUDBuilder extends StatelessWidget {
  const OnCRUDBuilder({
    Key? key,
    required this.listenTo,
    this.onWaiting,
    this.onError,
    required this.onResult,
    this.dispose,
    this.onSetState,
    this.debugPrintWhenRebuild,
  }) : super(key: key);
  final InjectedCRUD listenTo;

  ///Widget to display while waiting for any CRUD operation
  final Widget Function()? onWaiting;

  ///Widget to display if a CRUD operation fails
  final Widget Function(dynamic, void Function())? onError;

  ///Widget to display if a CRUD operation ends successfully. It exposes the
  ///result of the CRUD operation
  final Widget Function(dynamic) onResult;

  ///Side effects to call when this widget is disposed.
  final void Function()? dispose;

  ///Side effects to call InjectedAuth emits notification.
  final On<void>? onSetState;

  ///Debug print informative message when this widget is rebuilt
  final String? debugPrintWhenRebuild;
  @override
  Widget build(BuildContext context) {
    return On.crud(
      onWaiting: onWaiting,
      onError: onError,
      onResult: onResult,
    ).listenTo(
      listenTo,
      onSetState: onSetState,
      dispose: dispose,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }
}
