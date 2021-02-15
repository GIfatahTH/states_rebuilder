part of '../../reactive_model.dart';

/// Injected state that is responsible for authenticating and
///authorization of a user.
class InjectedAuth<T, P> extends InjectedImp<T> {
  /// Injected state that is responsible for authenticating and
  ///authorization of a user.
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
    // bool autoDisposeWhenNotUsed = false,
    // bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    SnapState<T>? Function(SnapState<T> state, SnapState<T> nextState)?
        middleSnapState,
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
          autoDisposeWhenNotUsed: false,
          isLazy: true,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,

          middleSnapState: middleSnapState,
        );
  final P Function()? _param;
  final Duration Function(T s)? _autoSignOut;
  _AuthService<T, P> get auth {
    _initialize();
    return _auth!;
  }

  ///Whether the a user is signed or not
  bool get isSigned => state != _initialState;

  _AuthService<T, P>? _auth;
  Future<R> getRepoAs<R>() async {
    assert(R != dynamic && R != Object);
    // We get the repo, so we are supposed we want to sign.
    //If the auth state is not initialized, and it will invoke
    //OnUnSigned. This may lead to a bug.
    //Set _initialConnectionState to done will prevent calling
    //OnUnSinged on app initialization. (See RM.injectedAuth onInitialized)
    // _initialConnectionState = ConnectionState.done;
    return (await auth._repository) as R;
  }

  final void Function(T s)? _onAuthenticated;
  final void Function()? _onSignOut;
  @override
  void _onDisposeState() {
    _auth?._dispose();
    super._onDisposeState();
  }

  ///Inject a fake implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake creation function
  void injectAuthMock(IAuth<T, P> Function() fakeRepository) {
    _isInjectMock = false;
    final creator = () {
      if (!_isFirstInitialized) {
        final fn = () async {
          final repo = fakeRepository();
          await repo.init();
          return repo;
        };
        _auth = _AuthService(fn(), this);
      }
      return _initialState;
    };
    _cachedMockCreator ??= (_) => creator();
    _cleanUpState((_) => creator());
    addToCleaner(() => _cleanUpState(_cachedMockCreator));
  }
}
