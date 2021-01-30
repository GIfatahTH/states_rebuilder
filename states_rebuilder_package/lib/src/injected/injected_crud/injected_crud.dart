part of '../../reactive_model.dart';

class InjectedCRUD<T, P> extends InjectedImp<List<T>> {
  InjectedCRUD({
    required dynamic Function() creator,
    P Function()? param,
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
  })  : _param = param,
        super(
          creator: (_) => creator(),
          initialValue: initialState,
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
  final P Function()? _param;
  bool _readOnInitialization = false;
  _CRUDService<T, P> get crud {
    _initialize();
    return _crud;
  }

  late _CRUDService<T, P> _crud;
  Future<R> getRepoAs<R>() async {
    assert(R != dynamic && R != Object);
    return (await crud._repository) as R;
  }

  @override
  void _onDisposeState() {
    _crud._dispose();
    super._onDisposeState();
  }

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
      final fn = () async {
        final repo = fakeRepository();
        await repo.init();
        return repo;
      };
      _crud = _CRUDService(fn(), this);
      if (!_isFirstInitialized && !_readOnInitialization) {
        return initialState ?? <T>[];
      } else {
        return () async {
          final _repo = await _crud._repository;
          final l = await _repo.read(_param?.call());
          return [...l];
        }();
      }
    };
    _cachedMockCreator ??= (_) => creator();
    _cleanUpState((_) => creator());
    addToCleaner(() => _cleanUpState(_cachedMockCreator));
  }
}