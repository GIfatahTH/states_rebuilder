part of '../rm.dart';

class _Rebuild<T> {
  final InjectedBase<T> _injected;
  _Rebuild(this._injected);

  /// {@template injected.rebuild.call}
  ///Listen to the reactive (injected) model and invoke the [builder] whenever the
  ///injected model is notified with any kind of state status (isWaiting,
  ///hasData, hasError).
  ///
  /// * Required parameters:
  ///     * [builder] (positional parameter) is called each time the
  /// injected model emits a notification with any kind of status flag.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * [watch] : callback to be executed before notifying listeners.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  ///    * [onSetState] :For side effects before rebuilding the widget tree.
  ///    * [onAfterBuild] :For side effects after rebuilding the widget tree.
  ///    * [debugPrintWhenRebuild] : Print state transition log.
  /// {@endtemplate}
  Widget call(
    Widget Function() builder, {
    void Function(SnapState<T>)? onSetState,
    void Function()? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    Object? Function()? watch,
    bool Function(SnapState<T>, SnapState<T>)? shouldRebuild,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    return OnBuilder(
      listenTo: _injected,
      sideEffects: SideEffects<T>(
        onSetState: onSetState,
        onAfterBuild: onAfterBuild,
        initState: initState,
        dispose: dispose,
      ),
      shouldRebuild: shouldRebuild,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      watch: watch,
      builder: builder,
    );
  }

  /// {@template injected.rebuild.onData}
  ///Listen to the reactive (injected) model and invoke the [builder] whenever the
  ///injected model is notified with hasData flag.
  ///
  /// * Required parameters:
  ///     * [builder] (positional parameter) is called each time the
  /// injected model emits a notification with hasData status flag.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * [watch] : callback to be executed before notifying listeners.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  ///    * [onSetState] :For side effects before rebuilding the widget tree.
  ///    * [onAfterBuild] :For side effects after rebuilding the widget tree.
  ///    * [debugPrintWhenRebuild] : Print state transition log.
  /// {@endtemplate}
  Widget onData(
    Widget Function(T data) builder, {
    void Function(SnapState<T>)? onSetState,
    void Function()? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    Object? Function()? watch,
    bool Function(SnapState<T>, SnapState<T>)? shouldRebuild,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    return OnBuilder.data(
      listenTo: _injected,
      sideEffects: SideEffects<T>(
        onSetState: onSetState,
        onAfterBuild: onAfterBuild,
        initState: initState,
        dispose: dispose,
      ),
      shouldRebuild: shouldRebuild,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      watch: watch,
      builder: builder,
    );
  }

  /// {@template injected.rebuild.onAll}
  ///Listen to the injected Model and rebuild when it emits a notification.
  ///
  /// * Required parameters:
  ///     * [onIdle] : callback to be executed when injected model is in its
  /// initial state.
  ///     * [onWaiting] : callback to be executed when injected model is in
  /// waiting state.
  ///     * [onError] : callback to be executed when injected model has error.
  ///     * [onData] : callback to be executed when injected model has data.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///    * [onSetState] :For side effects before rebuilding the widget tree.
  ///    * [onAfterBuild] :For side effects after rebuilding the widget tree.
  ///    * [debugPrintWhenRebuild] : Print state transition log.
  /// {@endtemplate}
  Widget onAll({
    Widget Function()? onIdle,
    required Widget Function() onWaiting,
    required Widget Function(dynamic err, void Function() refreshError) onError,
    required Widget Function(T data) onData,
    void Function(SnapState<T>)? onSetState,
    void Function()? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    Object? Function()? watch,
    bool Function(SnapState<T>, SnapState<T>)? shouldRebuild,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    return OnBuilder.all(
      listenTo: _injected,
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
      sideEffects: SideEffects<T>(
        onSetState: onSetState,
        onAfterBuild: onAfterBuild,
        initState: initState,
        dispose: dispose,
      ),
      shouldRebuild: shouldRebuild,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      watch: watch,
    );
  }

  /// {@template injected.rebuild.onOr}
  ///Listen to the injected Model and rebuild when it emits a notification.
  ///
  /// * Required parameters:
  ///     * [builder] Default callback (called in replacement of any non
  /// defined optional parameters [onIdle], [onWaiting], [onError] and
  /// [onData]).
  /// * Optional parameters:
  ///     * [onIdle] : callback to be executed when injected model is in its
  /// initial state.
  ///     * [onWaiting] : callback to be executed when injected model is in
  /// waiting state.
  ///     * [onError] : callback to be executed when injected model has error.
  ///     * [onData] : callback to be executed when injected model has data.
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * [watch] : callback to be executed before notifying listeners.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  ///    * [onSetState] :For side effects before rebuilding the widget tree.
  ///    * [onAfterBuild] :For side effects after rebuilding the widget tree.
  ///    * [debugPrintWhenRebuild] : Print state transition log.
  /// {@endtemplate}
  Widget onOrElse({
    Widget Function()? onIdle,
    Widget Function()? onWaiting,
    Widget Function(dynamic err, void Function() refreshError)? onError,
    Widget Function(T data)? onData,
    required Widget Function(T data) orElse,
    void Function(SnapState<T>)? onSetState,
    void Function()? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    Object? Function()? watch,
    bool Function(SnapState<T>, SnapState<T>)? shouldRebuild,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    return OnBuilder.orElse(
      listenTo: _injected,
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
      orElse: orElse,
      sideEffects: SideEffects<T>(
        onSetState: onSetState,
        onAfterBuild: onAfterBuild,
        initState: initState,
        dispose: dispose,
      ),
      shouldRebuild: shouldRebuild,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      watch: watch,
    );
  }

  Widget onFuture<F>({
    required Future<F> Function() future,
    required Widget Function() onWaiting,
    required Widget Function(dynamic, void Function()) onError,
    required Widget Function(F, void Function()) onData,
    On<void>? onSetState,
    On<void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    bool Function(SnapState<T>? snapState)? shouldRebuild,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return On.future<F>(
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
    ).future(
      future,
      onSetState: onSetState,
      initState: initState,
      dispose: dispose,
      key: key,
    );
  }

  ///Listen to an [InjectedAuth] state
  ///
  ///[onInitialWaiting] defines the widget to display when the the state is first
  ///(and only the first) waiting for authentication.
  ///
  ///[onWaiting] defines the widget to display when the the state is
  ///waiting for authentication.
  ///
  ///[onUnsigned] and [onSigned] are widgets to be displayed if the state is unsigned
  ///and signed respectively
  ///
  ///By default, the switch between the onSinged and the onUnsigned pages is
  ///a simple widget replacement. To use the navigation page transition
  ///animation, set [userRouteNavigation] to true. In this case, you
  ///need to set the [RM.navigate.navigatorKey].
  Widget onAuth({
    Widget Function()? onInitialWaiting,
    Widget Function()? onWaiting,
    required Widget Function() onUnsigned,
    required Widget Function() onSigned,
    bool useRouteNavigation = false,
    void Function()? dispose,
    On<void>? onSetState,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    return On.auth(
      onInitialWaiting: onInitialWaiting,
      onWaiting: onWaiting,
      onUnsigned: onUnsigned,
      onSigned: onSigned,
    ).listenTo(
      _injected as InjectedAuth,
      useRouteNavigation: useRouteNavigation,
      onSetState: onSetState,
      dispose: dispose,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }

  ///Listen to an [InjectedCRUD] state
  ///
  ///[onWaiting] defines the widget to display when the state is waiting for a
  ///CRUD operation to end.
  ///
  ///[onError] defines the widget to display if the CRUD operation ends with error.
  ///It exposes the error and a refresh callback to recall the last CRUD operation.
  ///
  ///[onResult] defines the widget to display if the CRUD operation ends with succuss.
  ///It exposes the result of the CRUD operation (such as the number of raw add or
  ///the last id of the added item.
  Widget onCRUD({
    required Widget Function()? onWaiting,
    required Widget Function(dynamic err, void Function() refresh)? onError,
    required Widget Function(dynamic data) onResult,
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return On.crud(
      onWaiting: onWaiting,
      onError: onError,
      onResult: onResult,
    ).listenTo(
      _injected as InjectedCRUD,
      onSetState: onSetState,
      dispose: dispose,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }
}

///A lightweight version of InjectedImp
abstract class ReactiveModel<T> extends InjectedBase<T> {
  ///Callable class used to listen to a reactive (injected) model and rebuild widget
  ///
  ///* `foo.rebuild( ... )` or `rebuild.call( ... )`: Equivalent to `On( ... ).listenTo(foo)`;
  ///* `foo.rebuild.onData( ... )` : Equivalent to `On.data( ... ).listenTo(foo)`;
  ///* `foo.rebuild.onAll( ... )` : Equivalent to `On.all( ... ).listenTo(foo)`;
  ///* `foo.rebuild.onOr( ... )` : Equivalent to `On.or( ... ).listenTo(foo)`;
  ///* `foo.rebuild.onFuture( ... )` : Equivalent to `On.future( ... ).future(foo)`;
  ///* `foo.rebuild.onAuth( ... )` : Equivalent to `On.auth( ... ).listenTo(foo)`;
  ///* `foo.rebuild.onCRUD( ... )` : Equivalent to `On.curd( ... ).listenTo(foo)`;
  ///
  /// where foo is a reactive (injected) model.
  late final rebuild = _Rebuild(this);

  factory ReactiveModel.create(
    T state, {
    bool autoDisposeWhenNotUsed = true,
  }) {
    return ReactiveModelImp(
      creator: () => state,
      initialState: state,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }

  factory ReactiveModel.future(
    Future<T> Function() creator, {
    T? initialState,
    bool autoDisposeWhenNotUsed = true,
  }) {
    return ReactiveModelImp(
      creator: creator,
      initialState: initialState,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
  factory ReactiveModel.stream(
    Stream<T> Function() creator, {
    T? initialState,
    bool autoDisposeWhenNotUsed = true,
  }) {
    return ReactiveModelImp(
      creator: creator,
      initialState: initialState,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }

  ReactiveModel();

  ConnectionState get connectionState =>
      _reactiveModelState._snapState._connectionState;

  ///Exhaustively switch over all the possible statuses of [connectionState].
  ///Used mostly to return [Widget]s.
  R whenConnectionState<R>({
    required R Function() onIdle,
    required R Function() onWaiting,
    required R Function(T snapState) onData,
    required R Function(dynamic error) onError,
    bool catchError = true,
  }) {
    if (isIdle) {
      return onIdle.call();
    }
    if (hasError) {
      return onError.call(error);
    }
    if (isWaiting) {
      return onWaiting.call();
    }
    return onData.call(_state);
  }

  int get observerLength => _reactiveModelState.listeners.observerLength;
}

class ReactiveModelImp<T> extends ReactiveModel<T> {
  final Function() creator;

  ReactiveModelImp({
    required this.creator,
    T? initialState,
    bool autoDisposeWhenNotUsed = true,
  }) {
    _reactiveModelState = ReactiveModelBase<T>(
      creator: creator,
      initialState: initialState,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      initializer: () {
        if (_reactiveModelState._isInitialized) {
          return;
        }
        final cachedAddToObs = OnReactiveState.addToObs;
        OnReactiveState.addToObs = null;

        _reactiveModelState
          .._isInitialized = true
          .._isDisposed = false
          .._snapState = SnapState._nothing(
            _reactiveModelState._initialState,
            kInitMessage,
            _reactiveModelState.debugPrintWhenNotifiedPreMessage,
          );

        _reactiveModelState._setInitialStateCreator(
          middleCreator: (crt) {
            return crt();
          },
          middleState: (snap) {
            if (snap.isWaiting) {
              if (snapState._infoMessage == kRefreshMessage) {
                return snap._copyWith(data: _reactiveModelState._initialState);
              } else {
                _reactiveModelState._snapState = snap;
                return null;
              }
            }

            // _reactiveModelState._initialState ??= snap.data;

            if (snapState._infoMessage == kInitMessage) {
              snap = snap._copyToIsIdle(isActive: false);
              _reactiveModelState._snapState = snap;
              return null; //Return null so do not rebuild
            }
            return snapState._infoMessage == kRefreshMessage
                ? snap._copyToIsIdle(
                    /*data: _reactiveModelState._initialState*/)
                : snap;
          },
          onDone: (snap) {
            return snap;
          },
        );
        _reactiveModelState._initialStateCreator!();
        OnReactiveState.addToObs = cachedAddToObs;
      },
    );
    _reactiveModelState.initializer();
  }

  T? get initialState => _reactiveModelState._initialState;

  ReactiveModelBase<T> get reactiveModelState => _reactiveModelState;

  // SnapState<T>? middleSnap(SnapState<T> snap) {}

  @override
  SnapState<T>? _middleSnap(
    SnapState<T> snap, {
    On<void>? onSetState,
    void Function(T data)? onData,
    void Function(dynamic error)? onError,
  }) {
    // snap = middleSnap(snap) ?? snap;
    if (snap.isWaiting) {
      if (snapState.isWaiting) {
        return null;
      }
      onSetState?.call(snap);
      return snap;
    }
    if (snap.hasError) {
      if (snap.error == snapState.error) {
        return null;
      }
      onSetState?.call(snap);
      onError?.call(snap.error);
      return snap;
    }

    if (snap.hasData) {
      if (snap._isImmutable == true && snap == snapState) {
        return null;
      }
      onSetState?.call(snap);
      onData?.call(snap.data as T);
    }
    return snap;
  }

  // @override
  // Future<F> Function() future<F>(Future<F> Function(T s) future) {
  //   return () async {
  //     late F data;
  //     await future(state).then((d) {
  //       if (d is T) {
  //         snapState = snapState.copyToHasData(d);
  //       }
  //       data = d;
  //     }).catchError(
  //       (e, StackTrace s) {
  //         snapState = snapState._copyToHasError(
  //           e,
  //           () => this.future(future),
  //           stackTrace: s,
  //         );

  //         throw e;
  //       },
  //     );
  //     return data;
  //   };
  // }

  VoidCallback observeForRebuild(void Function(ReactiveModel<T>? rm) fn) {
    return _reactiveModelState.listeners.addListenerForRebuild((_) => fn(this));
  }

  void addCleaner(VoidCallback fn) {
    _reactiveModelState.listeners.addCleaner(fn);
  }
}
