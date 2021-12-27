import 'dart:async';

import 'package:flutter/material.dart';
import '../../common/logger.dart';
import '../../rm.dart';
import '../../common/consts.dart';

part 'i_auth.dart';
part 'on_auth.dart';

/// Injection of a state that can authenticate and authorize
/// a user.
///
/// This injected state abstracts the best practices of the clean
/// architecture to come out with a simple, clean, and testable approach
/// to manage user authentication and authorization.
///
/// The approach consists of the following steps:
/// * Define uer User Model. (The name is up to you).
/// * You may define a class (or enum) to parametrize the query.
/// * Your repository must implements [IAuth]<T, P> where T is the User type
///  and P is the parameter
/// type. with `IAuth<T, P>` you define sign-(in, up , out) methods.
/// * Instantiate an [InjectedAuth] object using [RM.injectAuth] method.
/// * Later on use [InjectedAuth.auth].signUp, [InjectedAuth.auth].signIn, and
/// [InjectedAuth.auth].signOut for sign up, sign in, sign out.
/// * In the UI you can use [OnAuthBuilder] to listen the this injected state
/// and define the appropriate view for each state.
///
/// See: [InjectedAuth.auth], [_AuthService.signUp], [_AuthService.singIn],
/// [_AuthService.signOut], [_AuthService.refreshToken],and
/// [OnAuthBuilder]
abstract class InjectedAuth<T, P> implements Injected<T> {
  // InjectedAuthImp<T, P> _getImp() => this as InjectedAuthImp<T, P>;
  IAuth<T, P>? _repo;

  T get _state => getInjectedState(this);

  ///Get the auth repository of type R
  R getRepoAs<R extends IAuth<T, P>>() {
    if (_repo != null) {
      return _repo as R;
    }
    final repoMock = _cachedRepoMocks.last;
    _repo = repoMock != null
        ? repoMock()
        : (this as InjectedAuthImp<T, P>).repoCreator();
    return _repo as R;
  }

  ///Whether the a user is signed or not
  bool get isSigned;
  _AuthService<T, P>? _auth;

  ///Object that encapsulates the signIn, signUp, signOut methods
  _AuthService<T, P> get auth => _auth ??= _AuthService<T, P>(
        getRepoAs<IAuth<T, P>>(),
        this as InjectedAuthImp<T, P>,
      );

  final List<IAuth<T, P> Function()?> _cachedRepoMocks = [null];

  /// Inject a fake implementation of this injected model.
  ///
  /// Use [Injected.injectMock] to directly mack a signed user.
  void injectAuthMock(IAuth<T, P> Function()? fakeRepository) {
    dispose();
    RM.disposeAll();
    if (fakeRepository == null) {
      _cachedRepoMocks
        ..clear()
        ..add(null);
    }
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
    //
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
    this.sideEffects,
    // this.onSetAuthState,
    // void Function(T? s)? onInitialized,
    // void Function(T s)? onDisposed,

    //
    PersistState<T> Function()? persist,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) : super(
          creator: () => unsignedUser,
          initialState: unsignedUser,
          onInitialized: sideEffects?.initState != null
              ? (_) => sideEffects!.initState!()
              : null,
          onDisposed: sideEffects?.dispose != null
              ? (_) => sideEffects!.dispose!()
              : null,
          middleSnapState: middleSnapState,
          persist: persist,
          isLazy: true,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
          toDebugString: toDebugString,
          autoDisposeWhenNotUsed: false,
        ) {
    _resetDefaultState = () {
      _repo = null;
      _auth = null;
      _isInitialized = true;
      onAuthStreamSubscription?.cancel();
      onAuthStreamSubscription = null;
    };
    _resetDefaultState();
  }
  final IAuth<T, P> Function() repoCreator;

  final P Function()? param;
  final void Function(T s)? onSigned;
  final void Function()? onUnsigned;
  final SideEffects<T>? sideEffects;
  final Duration Function(T auth)? autoSignOut;
  final FutureOr<Stream<T>> Function(IAuth<T, P> repo)? onAuthStream;
  final T? unsignedUser;
  //
  late bool _isInitialized;
  StreamSubscription<T>? onAuthStreamSubscription;

  late final VoidCallback _resetDefaultState;
  @override
  bool get isSigned => state != unsignedUser && _isInitialized;

  @override
  dynamic middleCreator(
    dynamic Function() crt,
    dynamic Function()? creatorMock,
  ) {
    if (creatorMock != null) {
      return super.middleCreator(crt, creatorMock);
    }
    return () async {
      _isInitialized = false;
      snapState = snapState.copyWith(infoMessage: 'REPO $kInitMessage');
      auth._param = param?.call();
      await _init();
      snapState = snapState.copyWith(infoMessage: kInitMessage);
      if (onAuthStream != null) {
        final Stream<T> stream = await onAuthStream!(getRepoAs<IAuth<T, P>>());
        final future = Completer<T>();
        _isInitialized = true;
        onAuthStreamSubscription = stream.listen(
          (data) {
            if (!future.isCompleted) {
              future.complete(data);
            } else {
              reactiveModelState.setToHasData(
                middleSnap: middleSnap,
                data: data,
              );
            }
          },
          onError: (err, s) {
            if (!future.isCompleted) {
              future.completeError(err, s);
            } else {
              reactiveModelState.setToHasError(
                middleSnap: middleSnap,
                error: err,
                stackTrace: s,
                refresher: () {},
              );
            }
          },
        );
        return super.middleCreator(() => future.future, creatorMock);
      }
      final r = super.middleCreator(crt, creatorMock);
      if (r is T && r != unsignedUser) {
        snapState = snapState.copyWith(data: r);
        return auth._autoSignOut()?.then(
          (data) {
            _isInitialized = true;
            return data;
          },
        );
      }
      _isInitialized = true;
      return r;
    }();
  }

  Future<void> _init() async {
    if (_isInitialized) {
      return;
    }
    await getRepoAs<IAuth<T, P>>().init();
  }

  @override
  void dispose() {
    _auth?._dispose();

    if (_cachedRepoMocks.length > 1) {
      _cachedRepoMocks.removeLast();
    }
    _resetDefaultState();
    super.dispose();
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

      injected.sideEffects
        ?..onSetState?.call(snap)
        ..onAfterBuild?.call();
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
  //TODO make param named parameter
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
        return _repository.signIn(_param ?? injected.param?.call());
      },
      sideEffects: onError != null ? SideEffects.onError(onError) : null,
      shouldOverrideDefaultSideEffects: (_) => onError != null,
    );
    _onSignInOut = null;
    return injected._state;
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
        return _repository.signUp(_param ?? injected.param?.call());
      },
      sideEffects: onError != null ? SideEffects.onError(onError) : null,
      shouldOverrideDefaultSideEffects: (_) => onError != null,
    );
    _onSignInOut = null;
    return injected._state;
  }

  void _onError(void Function()? onAuthenticated) {
    final snap = injected.snapState;
    final isSigned = injected.isSigned;
    injected.snapState = snap.copyToHasError(
      snap.error,
      onErrorRefresher: snap.onErrorRefresher,
      stackTrace: snap.stackTrace,
      data: injected.unsignedUser,
      enableNull: true,
    );
    if (isSigned) {
      injected.onUnsigned?.call();
    }
  }

  void _onData(void Function()? onAuthenticated) {
    onAuthenticated?.call();
    if (injected._state == injected.unsignedUser) {
      _cancelTimer();
      if (onAuthenticated == null) {
        injected.onUnsigned?.call();
      }
    } else {
      // _persist();
      _autoSignOut();
      if (onAuthenticated == null) {
        injected.onSigned?.call(injected._state);
      }
    }
    _onSignInOut = null;
  }

  Future<T>? _autoSignOut() async {
    if (injected.autoSignOut != null) {
      _cancelTimer();
      final duration = injected.autoSignOut!(injected._state);
      if (duration.inSeconds <= 0) {
        return refreshToken();
      } else {
        _authTimer = Timer(
          duration,
          () => refreshToken(),
        );
      }
    }
    return injected._state;
  }

  /// Refresh the token
  ///
  /// If `shouldAutoSignOut` is true (the default), the user is signed out if
  /// the refresh token expires.
  Future<T> refreshToken({bool shouldAutoSignOut = true}) async {
    if (injected._state == injected.unsignedUser) {
      return injected._state;
    }
    final refreshedUser = await _repository.refreshToken(injected._state);

    if (refreshedUser == null || refreshedUser == injected.unsignedUser) {
      if (shouldAutoSignOut) {
        signOut();
      }
      return injected.unsignedUser as T;
    }
    injected
      ..snapState = injected.snapState.copyWith(data: refreshedUser)
      ..persistState();
    _autoSignOut();
    return injected._state;
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
        await _repository.signOut(
          param?.call(injected.param?.call()) ??
              injected.param?.call() ??
              _param,
        );
      },
      sideEffects: onError != null ? SideEffects.onError(onError) : null,
      shouldOverrideDefaultSideEffects: (_) => onError != null,
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
    _cancelTimer();
    _repository.dispose();
  }
}
