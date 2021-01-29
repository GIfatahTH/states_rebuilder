part of '../../reactive_model.dart';

abstract class IAuth<T, P> {
  Future<IAuth<T, P>> init();
  Future<T> signIn(P? param);
  Future<T> signUp(P? param);
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
  _AuthService(this._repository, this.injected);

  Future<T> signIn(
    P Function()? param, {
    void Function()? onAuthenticated,
    void Function(dynamic error)? onError,
  }) async {
    await injected.setState(
      (s) async {
        final _repo = await _repository;
        return _repo.signIn(param?.call() ?? injected._param?.call());
      },
      onSetState: onError != null ? On.error(onError) : null,
    );
    if (injected.hasData) {
      _onData(onAuthenticated);
    }
    return injected.state;
  }

  Future<T> signUp(
    P Function()? param, {
    void Function()? onAuthenticated,
    void Function(dynamic error)? onError,
  }) async {
    await injected.setState(
      (s) async {
        final _repo = await _repository;
        return _repo.signUp(param?.call() ?? injected._param?.call());
      },
      onSetState: onError != null ? On.error(onError) : null,
    );
    if (injected.hasData) {
      _onData(onAuthenticated);
    }
    return injected.state;
  }

  void _onData(void Function()? onAuthenticated) {
    if (injected.state == injected._initialState) {
      _cancelTimer();
      injected._onSignOut?.call();
    } else {
      _persist();
      _autoSignOut();
      if (onAuthenticated != null) {
        onAuthenticated.call();
      } else {
        injected._onAuthenticated?.call(injected.state);
      }
    }
  }

  // On<void> _on(
  //   void Function()? onAuthenticated,
  //   void Function(dynamic error)? onError,
  // ) {
  //   final
  //   return On.or(
  //     onError: onError,
  //     onData: onData,
  //     or: () {},
  //   );
  // }

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
    P Function()? param,
    void Function()? onSignOut,
    void Function(dynamic error)? onError,
  }) async {
    _cancelTimer();

    await injected.setState(
      (s) async* {
        yield injected._initialState;
        final _repo = await _repository;
        await _repo.signOut(param?.call() ?? injected._param?.call());
      },
      onSetState: On.or(
        onError: onError,
        onData: onSignOut ?? injected._onSignOut,
        or: () {},
      ),
    );
    if (injected.hasData) {
      if (injected._stateIsPersisted) {
        injected._coreRM.persistanceProvider!.delete();
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

  Future<void> autoSignOut(Duration time, {P Function()? param}) async {
    _cancelTimer();
    _authTimer = Timer(
      time,
      () => signOut(param: param),
    );
  }
}
