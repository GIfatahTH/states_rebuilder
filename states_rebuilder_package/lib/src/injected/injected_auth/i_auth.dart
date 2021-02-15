part of '../../reactive_model.dart';

///Interface to implement for authentication and authorization
///
///
///The first generic type is the user.
///
///the second generic type is for the query parameter
abstract class IAuth<T, P> {
  ///It is called and awaited to finish when
  ///the state is first created
  ///
  ///Here is the right place to initialize plugins
  Future<void> init();

  ///Sign in
  Future<T> signIn(P? param);

  ///Sign up
  Future<T> signUp(P? param);

  ///Sign out
  Future<void> signOut(P? param);

  ///It is called when the injected model is disposed
  ///
  ///This is the right place for cleaning resources.
  void dispose();
}

class _AuthService<T, P> {
  final FutureOr<IAuth<T, P>> _repository;

  ///The injected model associated with this service
  ///class
  final InjectedAuth<T, P> injected;
  _AuthService(this._repository, this.injected) {
    _disposer = injected.subscribeToRM((rm) {
      if (rm.hasData) {
        _onData(_onSignInOut);
      }
    });
  }

  P? _param;
  void Function()? _onSignInOut;
  late Disposer _disposer;

  ///Sign in
  ///[param] is used to parametrize the query (ex: user
  ///id, token).
  Future<T> signIn(
    P Function(P? param)? param, {
    void Function()? onAuthenticated,
    void Function(dynamic error, void Function() refresh)? onError,
  }) async {
    _onSignInOut = onAuthenticated;
    await injected.setState(
      (s) async {
        final _repo = await _repository;
        _param = param?.call(
          injected._param?.call(),
        );
        return _repo.signIn(_param ?? injected._param?.call());
      },
      onSetState: onError != null ? On.error(onError) : null,
    );
    _onSignInOut = null;
    return injected.state;
  }

  Future<T> signUp(
    P Function(P? param)? param, {
    void Function()? onAuthenticated,
    void Function(dynamic error, void Function() refreh)? onError,
  }) async {
    _onSignInOut = onAuthenticated;

    await injected.setState(
      (s) async {
        final _repo = await _repository;
        _param = param?.call(
          injected._param?.call(),
        );

        return _repo.signUp(_param ?? injected._param?.call());
      },
      onSetState: onError != null ? On.error(onError) : null,
    );
    _onSignInOut = null;
    return injected.state;
  }

  void _onData(void Function()? onAuthenticated) {
    onAuthenticated?.call();
    if (injected.state == injected._initialState) {
      _cancelTimer();
      if (onAuthenticated == null) {
        injected._onSignOut?.call();
      }
    } else {
      _persist();
      _autoSignOut();
      if (onAuthenticated == null) {
        injected._onAuthenticated?.call(injected.state);
      }
    }
    _onSignInOut = null;
  }

  void _persist() {
    if (injected._stateIsPersisted) {
      injected.persistState();
    }
  }

  void _autoSignOut() {
    if (injected._autoSignOut != null) {
      autoSignOut(injected._autoSignOut!(injected.state));
    }
  }

  Future<void> signOut({
    P Function(P? param)? param,
    void Function()? onSignOut,
    void Function(dynamic error, void Function() refreh)? onError,
  }) async {
    _cancelTimer();
    _onSignInOut = onSignOut;
    await injected.setState(
      (s) async* {
        yield injected._initialState;
        final _repo = await _repository;
        await _repo.signOut(
          param?.call(injected._param?.call()) ??
              injected._param?.call() ??
              _param,
        );
      },
      onSetState: onError != null ? On.error(onError) : null,
    );
    _onSignInOut = null;
    if (injected.hasData) {
      if (injected._stateIsPersisted) {
        await injected._coreRM.persistanceProvider!.delete();
      }
    }
  }

  Timer? _authTimer;
  void _cancelTimer() {
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
  }

  void autoSignOut(Duration time, {P Function(P? param)? param}) {
    _cancelTimer();
    _authTimer = Timer(
      time,
      () => signOut(param: param),
    );
  }

  Future<void> _dispose() async {
    final _repo = await _repository;
    _disposer();
    _repo.dispose();
  }
}
