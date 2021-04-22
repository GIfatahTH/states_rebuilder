import 'dart:async';

import 'package:flutter/material.dart';
import '../../rm.dart';
import '../../common/consts.dart';

part 'i_auth.dart';
part 'on_auth.dart';

abstract class InjectedAuth<T, P> implements Injected<T> {
  IAuth<T, P>? _repo;

  ///Get the auth repository
  R getRepoAs<R extends IAuth<T, P>>() {
    if (_repo != null) {
      return _repo as R;
    }
    final repoMock = _cachedRepoMocks.last;
    _repo = repoMock != null
        ? repoMock()
        : (this as InjectedAuthImp<T, P>).repoCreator();
    (this as InjectedAuthImp)._init();
    return _repo as R;
  }

  ///Whether the a user is signed or not
  bool get isSigned => state != (this as InjectedAuthImp<T, P>).unsignedUser;
  //
  _AuthService<T, P>? _auth;

  ///To sign up, in or out
  _AuthService<T, P> get auth => _auth ??= _AuthService<T, P>(
        getRepoAs<IAuth<T, P>>(),
        this as InjectedAuthImp<T, P>,
      );

  List<IAuth<T, P> Function()?> _cachedRepoMocks = [null];

  ///Inject a fake implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake creation function

  void injectAuthMock(IAuth<T, P> Function() fakeRepository) {
    RM.disposeAll();
    _cachedRepoMocks.add(fakeRepository);
  }
}

/// Injected state that is responsible for authenticating and
///authorization of a user.
class InjectedAuthImp<T, P> extends InjectedImp<T> with InjectedAuth<T, P> {
  /// Injected state that is responsible for authenticating and
  ///authorization of a user.
  InjectedAuthImp({
    required this.repoCreator,
    this.unsignedUser,
    this.param,
    this.onSigned,
    this.onUnsigned,
    this.autoSignOut,
    this.onAuthStream,
    this.on,
    //
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
    void Function(T? s)? onInitialized,
    void Function(T s)? onDisposed,

    //
    PersistState<T> Function()? persist,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) : super(
          creator: () => unsignedUser,
          initialState: unsignedUser,
          onInitialized: onInitialized,
          onDisposed: onDisposed,
          middleSnapState: middleSnapState,
          persist: persist,
          isLazy: true,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
          toDebugString: toDebugString,
          autoDisposeWhenNotUsed: false,
        );
  final IAuth<T, P> Function() repoCreator;

  final P Function()? param;
  final void Function(T s)? onSigned;
  final void Function()? onUnsigned;
  final On<void>? on;
  final Duration Function(T auth)? autoSignOut;
  final FutureOr<Stream<T>> Function(IAuth<T, P> repo)? onAuthStream;
  StreamSubscription<T>? onAuthStreamSubscription;
  T? unsignedUser;

  @override
  dynamic middleCreator(
    dynamic Function() crt,
    dynamic Function()? creatorMock,
  ) {
    if (creatorMock != null) {
      return super.middleCreator(crt, creatorMock);
    }
    return () async {
      snapState = snapState.copyWith(infoMessage: 'REPO $kInitMessage');
      auth._param = param?.call();
      await _init();
      snapState = snapState.copyWith(infoMessage: kInitMessage);
      if (onAuthStream != null) {
        final Stream<T> stream = await onAuthStream!(getRepoAs<IAuth<T, P>>());
        return super.middleCreator(() => stream, creatorMock);
      }
      final r = super.middleCreator(crt, creatorMock);

      return r;
    }();
  }

  Future<void> _init() async {
    if (_isInitialized) {
      return;
    }
    await getRepoAs<IAuth<T, P>>().init();
    _isInitialized = true;
  }

  bool _isInitialized = false;

  @override
  void dispose() {
    auth._dispose();
    onAuthStreamSubscription?.cancel();
    onAuthStreamSubscription = null;
    if (_cachedRepoMocks.length > 1) {
      _cachedRepoMocks.removeLast();
    }
    super.dispose();
    _repo = null;
    _auth = null;
    _isInitialized = false;
  }
}

class _AuthService<T, P> {
  final IAuth<T, P> _repository;

  ///The injected model associated with this service
  ///class
  final InjectedAuthImp<T, P> injected;
  _AuthService(this._repository, this.injected) {
    _disposer = injected.subscribeToRM((snap) {
      if (snap!.hasData) {
        _onData(_onSignInOut);
      } else if (snap.hasError) {
        _onError(_onSignInOut);
      }
      injected.on?.call(snap);
    });
  }

  P? _param;
  void Function()? _onSignInOut;
  late VoidCallback _disposer;
  Timer? _authTimer;

  ///Sign in
  ///[param] is used to parametrize the query (ex: user
  ///id, token).
  ///
  ///[onAuthenticated] called after user authentication.
  ///
  ///[onError] called when authentication fails
  Future<T> signIn(
    P Function(P? param)? param, {
    void Function()? onAuthenticated,
    void Function(dynamic error, void Function() refresh)? onError,
  }) async {
    _onSignInOut = onAuthenticated;
    await injected.setState(
      (s) async {
        _param = param?.call(
          injected.param?.call(),
        );
        await injected._init();
        return _repository.signIn(_param ?? injected.param?.call());
      },
      onSetState: onError != null ? On.error(onError) : null,
    );
    _onSignInOut = null;
    return injected.state;
  }

  ///Sign up
  ///[param] is used to parametrize the query (ex: user
  ///id, token).
  ///
  ///[onAuthenticated] called after user authentication.
  ///
  ///[onError] called when authentication fails
  Future<T> signUp(
    P Function(P? param)? param, {
    void Function()? onAuthenticated,
    void Function(dynamic error, void Function() refresh)? onError,
  }) async {
    _onSignInOut = onAuthenticated;

    await injected.setState(
      (s) async {
        _param = param?.call(
          injected.param?.call(),
        );
        await injected._init();

        return _repository.signUp(_param ?? injected.param?.call());
      },
      onSetState: onError != null ? On.error(onError) : null,
    );
    _onSignInOut = null;
    return injected.state;
  }

  void _onError(void Function()? onAuthenticated) {
    final snap = injected.snapState;
    injected.snapState = snap.copyToHasError(
      snap.error,
      onErrorRefresher: snap.onErrorRefresher,
      stackTrace: snap.stackTrace,
      data: injected.unsignedUser,
      enableNull: true,
    );
    injected.onUnsigned?.call();
  }

  void _onData(void Function()? onAuthenticated) {
    onAuthenticated?.call();
    if (injected.state == injected.unsignedUser) {
      _cancelTimer();
      if (onAuthenticated == null) {
        injected.onUnsigned?.call();
      }
    } else {
      _persist();
      _autoSignOut();
      if (onAuthenticated == null) {
        injected.onSigned?.call(injected.state);
      }
    }
    _onSignInOut = null;
  }

  void _persist() {
    injected.persistState();
  }

  void _autoSignOut() {
    if (injected.autoSignOut != null) {
      _cancelTimer();
      _authTimer = Timer(
        injected.autoSignOut!(injected.state),
        () => signOut(),
      );
    }
  }

  ///Sign out
  ///[param] is used to parametrize the query (ex: user
  ///id, token).
  ///
  ///[onSignOut] called after user has signed out.
  ///
  ///[onError] called when authentication fails
  Future<void> signOut({
    P Function(P? param)? param,
    void Function()? onSignOut,
    void Function(dynamic error, void Function() refresh)? onError,
  }) async {
    _cancelTimer();
    _onSignInOut = onSignOut;
    await injected.setState(
      (s) async* {
        yield injected.unsignedUser;
        await injected._init();

        await _repository.signOut(
          param?.call(injected.param?.call()) ??
              injected.param?.call() ??
              _param,
        );
      },
      onSetState: onError != null ? On.error(onError) : null,
    );
    _onSignInOut = null;

    if (injected.hasData) {
      injected.deletePersistState();
    }
  }

  void _cancelTimer() {
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
  }

  // void autoSignOut(Duration time, {P Function(P? param)? param}) {
  //   _cancelTimer();
  //   _authTimer = Timer(
  //     time,
  //     () => signOut(param: param),
  //   );
  // }

  Future<void> _dispose() async {
    _disposer();
    _authTimer?.cancel();
    _repository.dispose();
  }
}
