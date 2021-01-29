part of '../../reactive_model.dart';

class InjectedAuth<T, P> extends InjectedImp<T> {
  InjectedAuth({
    required dynamic Function() creator,
    P Function()? param,
    T? initialState,
    Duration Function(T s)? autoSignOut,
    void Function(T s)? onInitialized,
    void Function(T s)? onDisposed,
    void Function(T s)? onAuthenticated,
    void Function()? onSignOut,
    On<void>? onSetState,
    void Function(dynamic e, StackTrace? s)? onError,
    //
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    //
  })  : _param = param,
        _autoSignOut = autoSignOut,
        _onAuthenticated = onAuthenticated,
        _onSignOut = onSignOut,
        super(
          creator: (_) => creator(),
          initialValue: initialState,
          nullState: initialState,
          onInitialized: onInitialized?.call,
          onDisposed: onDisposed,

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
  P Function()? _param;
  Duration Function(T s)? _autoSignOut;
  _AuthService<T, P> get auth {
    _initialize();
    return _auth!;
  }

  _AuthService<T, P>? _auth;
  Future<R> getRepoAs<R>() async {
    assert(R != dynamic && R != Object);
    return (await auth._repository) as R;
  }

  void Function(T s)? _onAuthenticated;
  void Function()? _onSignOut;

  ///Inject a fake implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake creation function
  void injectAuthMock(IAuth<T, P> Function() fakeRepository) {
    final creator = () async {
      final repo = fakeRepository().init();
      _auth = _AuthService(repo, this);
      if (!_isFirstInitialized && !_isStateInitiallyPersisted) {
        return _initialState;
      } else {
        final _repo = await repo;
        return await _repo.signIn(_param?.call());
      }
    };
    _cachedMockCreator ??= (_) => creator();
    _cleanUpState((_) => creator());
    addToCleaner(() => _cleanUpState(_cachedMockCreator));
  }
}
