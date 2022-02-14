import 'dart:async';

import 'package:flutter/material.dart';

import '../../state_management/common/consts.dart';
import '../../state_management/rm.dart';

part 'i_auth.dart';
part 'on_auth_builder.dart';

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
class InjectedAuthImp<T, P> extends InjectedImpRedoPersistState<T>
    with InjectedAuth<T, P> {
  /// Injected state that is responsible for authenticating and
  ///authorization of a user.
  InjectedAuthImp({
    required this.repoCreator,
    this.unsignedUser,
    required this.param,
    required this.onSigned,
    required this.onUnsigned,
    required this.autoSignOut,
    required this.onAuthStream,
    //
    required StateInterceptor<T>? stateInterceptor,
    required this.sideEffects,
    required PersistState<T> Function()? persist,
    required String? debugPrintWhenNotifiedPreMessage,
    required Object? Function(T?)? toDebugString,
  }) : super(
          creator: () => unsignedUser as T,
          initialState: unsignedUser,
          sideEffects: sideEffects,
          stateInterceptor: stateInterceptor,
          persist: persist,
          undoStackLength: 0,
          dependsOn: null,
          autoDisposeWhenNotUsed: false,
          debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
          toDebugString: toDebugString,
          watch: null,
        );
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

  @override
  void resetDefaultState([VoidCallback? fn]) {
    super.resetDefaultState(fn);
    _repo = null;
    _auth = null;
    _isInitialized = true;
    onAuthStreamSubscription?.cancel();
    onAuthStreamSubscription = null;
  }

  @override
  bool get isSigned => state != unsignedUser && _isInitialized;

  @override
  Object? Function() get mockableCreator {
    if (cachedCreatorMocks.last != null) {
      isWaitingToInitialize = true;
      return super.mockableCreator;
    }
    return () async {
      _isInitialized = false;
      // snapValue = snapValue.copyWith(infoMessage: 'REPO $kInitMessage');
      auth._param = param?.call();
      await _init();
      snapValue = snapValue.copyWith(infoMessage: kInitMessage);
      if (onAuthStream != null) {
        final Stream<T> stream = await onAuthStream!(getRepoAs<IAuth<T, P>>());
        final future = Completer<T>();
        _isInitialized = true;
        onAuthStreamSubscription = stream.listen(
          (data) {
            if (!future.isCompleted) {
              future.complete(data);
            } else {
              setToHasData(data);
              // reactiveModelState.setToHasData(
              //   middleSnap: middleSnap,
              //   data: data,
              // );
            }
          },
          onError: (err, s) {
            if (!future.isCompleted) {
              future.completeError(err, s);
            } else {
              setToHasError(
                err,
                stackTrace: s,
              );
              // reactiveModelState.setToHasError(
              //   middleSnap: middleSnap,
              //   error: err,
              //   stackTrace: s,
              //   refresher: () {},
              // );
            }
          },
        );
        return future.future;
        // return super.middleCreator(() => future.future, creatorMock);
      }

      final result = super.mockableCreator();
      if (result is T && result != unsignedUser) {
        snapValue = snapValue.copyWith(data: result);
        return auth._autoSignOut().then(
          (data) {
            _isInitialized = true;
            return data;
          },
        );
      } else {
        _isInitialized = true;
        return result;
      }
    };
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
    super.dispose();
  }
}

class _AuthService<T, P> {
  final IAuth<T, P> _repository;

  ///The injected model associated with this service
  ///class
  final InjectedAuthImp<T, P> injected;
  _AuthService(this._repository, this.injected) {
    _disposer = injected.addObserver(
      isSideEffects: true,
      listener: (rm) {
        if (rm.hasData) {
          _onData(_onSignInOut);
        } else if (rm.hasError) {
          _onError(_onSignInOut);
        }

        // injected.sideEffects
        //   ?..onSetState?.call(rm.snapValue as SnapState<T>)
        //   ..onAfterBuild?.call();
      },
      shouldAutoClean: true,
    );
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
    return injected.snapValue.data as T;
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
    return injected.snapValue.data as T;
  }

  void _onError(void Function()? onAuthenticated) {
    final snap = injected.snapState;
    final isSigned = injected.isSigned;
    injected.snapValue = snap.copyWith(
      status: StateStatus.hasError,
      error: snap.snapError!,
      data: injected.unsignedUser,
      isImmutable: null is T,
    );
    if (isSigned) {
      injected.onUnsigned?.call();
    }
  }

  void _onData(void Function()? onAuthenticated) {
    onAuthenticated?.call();
    if (injected.snapValue.data == injected.unsignedUser) {
      _cancelTimer();
      if (onAuthenticated == null) {
        injected.onUnsigned?.call();
      }
    } else {
      // _persist();
      _autoSignOut();
      if (onAuthenticated == null) {
        injected.onSigned?.call(injected.snapValue.data as T);
      }
    }
    _onSignInOut = null;
  }

  Future<T> _autoSignOut() async {
    if (injected.autoSignOut != null) {
      _cancelTimer();
      final duration = injected.autoSignOut!(injected.snapValue.data as T);
      if (duration.inSeconds <= 0) {
        await refreshToken();
      } else {
        _authTimer = Timer(
          duration,
          () => refreshToken(),
        );
      }
    }
    return injected.snapValue.data as T;
  }

  /// Refresh the token
  ///
  /// If `shouldAutoSignOut` is true (the default), the user is signed out if
  /// the refresh token expires.
  Future<T> refreshToken({bool shouldAutoSignOut = true}) async {
    if (injected.snapValue.data == injected.unsignedUser) {
      return injected.snapValue.data as T;
    }
    final refreshedUser =
        await _repository.refreshToken(injected.snapValue.data as T);

    if (refreshedUser == null || refreshedUser == injected.unsignedUser) {
      if (shouldAutoSignOut) {
        signOut();
      }
      return injected.unsignedUser as T;
    }
    injected
      ..snapValue = injected.snapValue.copyWith(data: refreshedUser)
      ..persistState();
    _autoSignOut();
    return injected.snapValue.data as T;
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
