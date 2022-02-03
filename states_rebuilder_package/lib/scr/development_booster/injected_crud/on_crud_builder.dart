part of 'injected_crud.dart';

extension InjectedCRUDX<T, P> on InjectedCRUD<T, P> {
  _Rebuild<T, P> get rebuild => _Rebuild<T, P>(this);
}

class _Rebuild<T, P> {
  final InjectedCRUD<T, P> inj;
  _Rebuild(this.inj);
  Widget onCRUD({
    Key? key,
    Widget Function()? onWaiting,
    Widget Function(dynamic, void Function())? onError,
    required Widget Function(dynamic) onResult,
    void Function()? dispose,
    String? debugPrintWhenRebuild,
  }) {
    return OnCRUDBuilder(
      listenTo: inj,
      onResult: onResult,
      key: key,
      onWaiting: onWaiting,
      onError: onError,
      dispose: dispose,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }
}

class OnCRUDSideEffects {
  final void Function()? onWaiting;
  final void Function(dynamic err, void Function() refresh)? onError;
  final void Function(dynamic data) onResult;
  OnCRUDSideEffects({
    required this.onWaiting,
    required this.onError,
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
class OnCRUDBuilder extends MyStatefulWidget {
  OnCRUDBuilder({
    Key? key,
    required this.listenTo,
    this.onWaiting,
    this.onError,
    required this.onResult,
    void Function()? dispose,
    this.debugPrintWhenRebuild,
  }) : super(
          key: key,
          observers: (context) {
            return [(listenTo as InjectedCRUDImp).onCrudRM];
          },
          dispose: (_, __) {
            dispose?.call();
            listenTo.disposeIfNotUsed();
          },
          debugPrintWhenRebuild: debugPrintWhenRebuild,
          builder: (context, snap, rm) {
            final inj = rm as ReactiveModelImp;
            if (inj.isWaiting) {
              return onWaiting?.call() ?? onResult(inj.snapValue.data);
            }
            if (inj.hasError) {
              Widget? w;
              if (inj.hasError) {
                w = onError?.call(
                  inj.error,
                  inj.snapValue.snapError!.refresher,
                );
              } else {
                w = onError?.call(
                  inj.error,
                  inj.snapValue.snapError!.refresher,
                );
              }
              return w ?? onResult(inj.snapValue.data);
            }
            return (onResult(inj.snapValue.data));
          },
        );

  final InjectedCRUD listenTo;

  ///Widget to display while waiting for any CRUD operation
  final Widget Function()? onWaiting;

  ///Widget to display if a CRUD operation fails
  final Widget Function(dynamic, void Function())? onError;

  ///Widget to display if a CRUD operation ends successfully. It exposes the
  ///result of the CRUD operation
  final Widget Function(dynamic) onResult;

  ///Debug print informative message when this widget is rebuilt
  final String? debugPrintWhenRebuild;
  // @override
  // Widget build(BuildContext context) {
  //   return OnCRUD(
  //     onWaiting: onWaiting,
  //     onError: onError,
  //     onResult: onResult,
  //   )._listenTo(
  //     listenTo,
  //     onSetState: onSetState,
  //     dispose: dispose,
  //     key: key,
  //     debugPrintWhenRebuild: debugPrintWhenRebuild,
  //   );
  // }
}
