part of 'injected_crud.dart';

class OnCRUD<T> extends OnCRUDSideEffects<T> {
  OnCRUD({
    required T Function()? onWaiting,
    required T Function(dynamic err, void Function() refresh)? onError,
    required T Function(dynamic data) onResult,
  }) : super(
          onWaiting: onWaiting,
          onError: onError,
          onResult: onResult,
        );
}

class OnCRUDSideEffects<T> {
  final T Function()? onWaiting;
  final T Function(dynamic err, void Function() refresh)? onError;
  final T Function(dynamic data) onResult;
  OnCRUDSideEffects({
    required this.onWaiting,
    required this.onError,
    required this.onResult,
  });
  @Deprecated('User OnCRUDBuilder instead')
  Widget listenTo(
    InjectedCRUD inj, {
    void Function()? dispose,
    On<void>? onSetState,
    String? debugPrintWhenRebuild,
    Key? key,
  }) =>
      _listenTo(
        inj,
        dispose: dispose,
        onSetState: onSetState,
        debugPrintWhenRebuild: debugPrintWhenRebuild,
        key: key,
      );

  ///Listen to an InjectedCRUD state
  Widget _listenTo(
    InjectedCRUD inj, {
    void Function()? dispose,
    On<void>? onSetState,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    final injected = inj as InjectedCRUDImp;
    late final VoidCallback disposer;
    return StateBuilderBase<_OnCRUDWidget<T>>(
      (_, setState) {
        injected.initialize();
        return LifeCycleHooks(
          mountedState: (_) {
            disposer = injected.onCRUDListeners.addListenerForRebuild(
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
              clean: injected.autoDisposeWhenNotUsed
                  ? () => injected.dispose()
                  : null,
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
            disposer();
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

/// To listen to an InjectedCRUD state just use [ReactiveStatelessWidget],
/// [OnReactive], or [OnBuilder] widgets.
///
/// Nevertheless, as the CREATE, UPDATE, DELETE functions can be performed
/// optimistically, the user will not notice anything. Looks like he's dealing
/// with a simple sync list of items.
///
/// If we want to show the user that something is happening in the background,
/// we can use the `OnCRUDBuilder` widget.
///
/// ```dart
/// OnCRUDBuilder<T>(
///   listenTo: products,
///   onWaiting: ()=> Text('onWaiting'),
///   onError: (err, refreshErr)=> Text('onError'),
///   onResult: (result)=> Text('onResult'),
/// )
/// ```
/// - onWaiting: while the database is querying.
/// - onError: if the query ends with an error. IT exposes a refresher to reinvoke the async call that caused the error.
/// - onResult; if the request ends successfully. It exposes the result fo the query (ex: number of rows updated).
///
/// #### [OnCRUDBuilder] vs [OnBuilder].all or [OnBuilder].orElse:
/// - Both used to listen to injected state.
/// - In pessimistic mode they are equivalent.
/// - In optimistic mode, the difference is in the onWaiting hook.
///   - In `OnBuilder.all` the onWaiting in never called.
///   - In `OnCRUDBuilder` the onWaiting is called while waiting for the
/// backend service result.
/// - `OnBuilder.all` has onData callback.
/// - `OnCRUDBuilder` has onResult callback that exposes the return result for
/// the backend service.
///
class OnCRUDBuilder extends StatelessWidget {
  const OnCRUDBuilder({
    Key? key,
    required this.listenTo,
    this.onWaiting,
    this.onError,
    required this.onResult,
    this.dispose,
    @Deprecated('') this.onSetState,
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
    return OnCRUD(
      onWaiting: onWaiting,
      onError: onError,
      onResult: onResult,
    )._listenTo(
      listenTo,
      onSetState: onSetState,
      dispose: dispose,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }
}
