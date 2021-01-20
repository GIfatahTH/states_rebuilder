part of '../../reactive_model.dart';

class InjectedCRUD<T, P> extends InjectedImp<List<T>> {
  InjectedCRUD({
    required dynamic Function() creator,
    Injected<P>? param,
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
    Object Function(T item)? identifier,
  })  : _param = param,
        super(
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
        ) {
    if (_param != null) {
      if (_dependsOn != null) {
        _dependsOn!.injected.add(_param!);
      } else {
        _dependsOn = DependsOn({_param!});
      }
    }
  }
  Injected<P>? _param;
  Injected<P>? get param => _param;
  bool _readOnInitialization = false;
  _CRUDService<T, P> get crud => _crud;
  late _CRUDService<T, P> _crud;

  ///Inject a fake implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake creation function
  void injectCRUDMock(
    ICRUD<T, P> Function() fakeRepository, {
    List<T>? initialState,
  }) {
    if (initialState != null) {
      _initialState = initialState;
      _nullState = initialState;
    }
    final creator = () {
      if (!_isFirstInitialized && !_readOnInitialization) {
        return initialState ?? <T>[];
      } else {
        final repo = fakeRepository();
        return () async {
          final l = await repo.read(param?.state);
          return [...l];
        }();
      }
    };
    _cachedMockCreator ??= (_) => creator();
    _cleanUpState((_) => creator());
    addToCleaner(() => _cleanUpState(_cachedMockCreator));
  }
}
