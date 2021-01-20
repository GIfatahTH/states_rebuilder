part of '../../reactive_model.dart';

class InjectedCRUD<T, P> extends InjectedImp<List<T>> {
  InjectedCRUD({
    required dynamic Function() creator,
    List<T>? initialState,
    void Function(List<T> s)? onInitialized,
    void Function(List<T> s)? onDisposed,
    void Function()? onWaiting,
    void Function(List<T> s)? onData,
    On<void>? onSetState,
    void Function(dynamic e, StackTrace? s)? onError,
    //
    DependsOn<List<T>>? dependsOn,
    int undoStackLength = 0,
    PersistState<List<T>> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    //
    ICRUD<T, P>? repo,
    Object Function(T item)? identifier,
  }) : super(
          creator: (_) => creator(),
          nullState: initialState,
          onInitialized: onInitialized,
          onDisposed: onDisposed,
          onWaiting: onWaiting,
          onData: onData,
          onError: onError,
          on: onSetState,
          //
          dependsOn: dependsOn,
          undoStackLength: undoStackLength,
          persist: persist,
          //
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
          isLazy: isLazy,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
        );

  _CRUDService<T, P> get crud => _crud;
  late _CRUDService<T, P> _crud;
}
