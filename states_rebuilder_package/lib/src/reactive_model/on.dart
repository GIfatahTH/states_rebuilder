part of '../reactive_model.dart';

///{@template on}
///Callbacks to be invoked depending on the state status of an [Injected] model
///
///For more control on when to invoke the callbacks use:
///* **[On.data]**: The callback is invoked only when the [Injected] model emits a
///notification with onData status.
///* **[On.waiting]**: The callback is invoked only when the [Injected] model emits
///a notification with waiting status.
///* **[On.error]**: The callback is invoked only when the [Injected] model emits a
///notification with error status.
///
///See also:  **[On.all]**, **[On.or]**.
///{@endtemplate}
class On<T> {
  ///Callback to be called when first the model is initialized.
  final T Function()? onIdle;

  ///Callback to be called when the model is waiting for and async task.
  final T Function()? onWaiting;

  ///Callback to be called when the model has an error.
  final T Function(dynamic err)? onError;

  ///Callback to be called when the model has data.
  final T Function()? onData;
  // final _OnType _onType;

  bool get _hasOnWaiting => onWaiting != null;
  bool get _hasOnError => onError != null;
  bool get _hasOnIdle => onIdle != null;
  bool get _hasOnData => onData != null;
  bool _hasOnDataOnly = false;
  On._({
    required this.onIdle,
    required this.onWaiting,
    required this.onError,
    required this.onData,
    // required _OnType onType,
  });

  ///The callback is always invoked when the [Injected] model emits a
  ///notification.
  factory On.any(
    T Function() builder,
  ) {
    return On._(
      onIdle: builder,
      onWaiting: builder,
      onError: (dynamic _) => builder(),
      onData: builder,
      // onType: _OnType.when,
    );
  }

  ///{@macro on}
  factory On(
    T Function() builder,
  ) {
    return On._(
      onIdle: builder,
      onWaiting: builder,
      onError: (dynamic _) => builder(),
      onData: builder,
      // onType: _OnType.when,
    );
  }

  ///The callback is invoked only when the [Injected] model emits a
  ///notification with onData status.
  factory On.data(T Function() fn) {
    return On._(
      onIdle: null,
      onWaiting: null,
      onError: null,
      onData: fn,
      // onType: _OnType.onData,
    ).._hasOnDataOnly = true;
  }

  ///The callback is invoked only when the [Injected] model emits a
  ///notification with waiting status.
  factory On.waiting(T Function() fn) {
    return On._(
      onIdle: null,
      onWaiting: fn,
      onError: null,
      onData: null,
      // onType: _OnType.onWaiting,
    );
  }

  ///The callback is invoked only when the [Injected] model emits a
  ///notification with error status.
  factory On.error(T Function(dynamic err) fn) {
    return On._(
      onIdle: null,
      onWaiting: null,
      onError: fn,
      onData: null,
      // onType: _OnType.onError,
    );
  }

  ///Set of callbacks to be invoked  when the [Injected] model emits a
  ///notification with the corresponding state status.
  ///
  ///[onIdle], [onWaiting], [onError] and [onData] are optional. Non defined ones
  /// default to the [or] callback.
  ///
  ///To be forced to define all state status use [On.all].
  factory On.or({
    T Function()? onIdle,
    T Function()? onWaiting,
    T Function(dynamic err)? onError,
    T Function()? onData,
    required T Function() or,
  }) {
    return On._(
      onIdle: onIdle ?? or,
      onWaiting: onWaiting ?? or,
      onError: onError ?? (dynamic _) => or(),
      onData: onData ?? or,
      // onType: _OnType.when,
    );
  }

  ///Set of callbacks to be invoked  when the [Injected] model emits a
  ///notification with the corresponding state status.
  ///
  ///[onIdle], [onWaiting], [onError] and [onData] are required.
  ///
  ///For optional callbacks use [On.or].
  factory On.all({
    required T Function() onIdle,
    required T Function() onWaiting,
    required T Function(dynamic err) onError,
    required T Function() onData,
  }) {
    return On._(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
      // onType: _OnType.when,
    );
  }

  static _OnFuture<T> future<T>({
    required Widget Function()? onWaiting,
    required Widget Function(dynamic err)? onError,
    required Widget Function(T data) onData,
  }) {
    return _OnFuture<T>(
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
    );
  }

  T? _call(SnapState snapState) {
    if (snapState.isWaiting) {
      if (_hasOnWaiting) {
        return onWaiting?.call();
      }
      return onData?.call();
    }
    if (snapState.hasError) {
      if (_hasOnError) {
        return onError?.call(snapState.error);
      }
      return onData?.call();
    }

    if (snapState.isIdle) {
      if (_hasOnIdle) {
        return onIdle?.call();
      }
      if (_hasOnData) {
        return onData?.call();
      }
      if (_hasOnWaiting) {
        return onWaiting?.call();
      }
      if (_hasOnError) {
        return onError?.call(snapState.error);
      }
    }

    return onData?.call();
  }
}

// enum _OnType { onData, onWaiting, onError, when }

extension OnX on On<Widget> {
  ///Listen to this [Injected] model and register:
  ///
  ///{@template listen}
  ///* builder to be called to rebuild some part of the widget tree (**child**
  ///parameter).
  ///* Side effects to be invoked before rebuilding the widget (**onSetState**
  ///parameter).
  ///* Side effects to be invoked after rebuilding (**onAfterBuild** parameter).
  ///
  ///
  /// * **Required parameters**:
  ///     * **child**: of type `On<Widget>`. defines the widget to render when
  /// this injected model emits a notification.
  /// * **Optional parameters:**
  ///     * **onSetState** :  of type `On<void>`. Defines callbacks to be
  /// executed when this injected model emits a notification before rebuilding
  /// the widget.
  ///     * **onAfterBuild** :  of type `On<void>`. Defines callbacks
  /// to be executed when this injected model emits a notification after
  /// rebuilding the widget.
  ///     * **initState** : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * **dispose** : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * **shouldRebuild** : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * **watch** : callback to be executed before notifying listeners.
  ///     * **didUpdateWidget** : callback to be executed whenever the widget
  /// configuration changes.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  /// {@endtemplate}
  ///
  ///onSetState, child and onAfterBuild parameters receives a [On] object.
  Widget listenTo<T>(
    Injected<T> rm, {
    On<void>? onSetState,
    On<void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    void Function(_StateBuilder<T>)? didUpdateWidget,
    bool Function(SnapState<T>? previousState)? shouldRebuild,
    Object? Function()? watch,
    Key? key,
  }) {
    return _StateBuilder<T>(
      key: key,
      rm: [rm],
      initState: (_, setState, exposedRM) {
        rm._initialize();

        initState?.call();
        // state;
        if (onAfterBuild != null) {
          WidgetsBinding.instance?.addPostFrameCallback(
            (_) => onAfterBuild._call(rm._snapState),
          );
        }
        return rm._listenToRMForStateFulWidget((rm, _) {
          rm!;
          if (shouldRebuild?.call(rm._coreRM._previousSnapState) == false) {
            return;
          }

          onSetState?._call(rm._snapState);
          rm._onHasErrorCallback = _hasOnError;
          if (_hasOnDataOnly &&
              (rm._snapState.hasError || rm._snapState.isWaiting)) {
            return;
          }
          if (onAfterBuild != null) {
            WidgetsBinding.instance?.addPostFrameCallback(
              (_) => onAfterBuild._call(rm._snapState),
            );
          }
          setState(rm);
        });
      },
      dispose: (context) {
        dispose?.call();
      },
      watch: watch,
      didUpdateWidget: (_, oldWidget) => didUpdateWidget?.call(oldWidget),
      builder: (_, __) {
        rm._onHasErrorCallback = _hasOnError;
        return _call(rm._snapState)!;
      },
    );
  }
}

class _OnFuture<F> {
  final Widget Function()? onWaiting;
  final Widget Function(dynamic err)? onError;
  final Widget Function(F data) onData;
  _OnFuture({
    required this.onWaiting,
    required this.onError,
    required this.onData,
  });

  Injected? _injected;
  Widget future(
    Future<F> Function() future, {
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
  }) {
    return _listenTo(
      InjectedImp(
        creator: (_) => future(),
        isLazy: false,
      ),
      dispose: dispose,
      onSetState: onSetState,
      key: key,
    );
  }

  Widget listenTo(
    Injected<F> injected, {
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
  }) {
    _injected = injected;
    return _listenTo(
      InjectedImp(
        creator: (_) => injected.stateAsync,
        isLazy: false,
      ),
      dispose: dispose,
      onSetState: onSetState,
      key: key,
    );
  }

  Widget _listenTo(
    Injected<F> injected, {
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
  }) {
    return On.or(
      onWaiting: onWaiting,
      onError: onError,
      or: () => _injected == null
          ? onData(injected.state)
          : On.data(
              () => onData(injected.state),
            ).listenTo(_injected!),
    ).listenTo(
      injected,
      dispose: dispose,
      onSetState: onSetState,
      key: key,
    );
  }
}
