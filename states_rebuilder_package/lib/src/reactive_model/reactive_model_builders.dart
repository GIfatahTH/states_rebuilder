part of '../reactive_model.dart';

abstract class ReactiveModelBuilder<T> extends ReactiveModelInitializer<T> {
  bool _onHasErrorCallback = false;

  @override
  void _notifyListeners([List? tags]) {
    super._notifyListeners(tags);
    _listeners.forEach((fn) => fn(this as ReactiveModel<T>));
  }

  ///Listen to this [Injected] model and register:
  ///* builder to be called to rebuild some part of the widget tree (**child**
  ///parameter).
  ///* Side effects to be invoked before rebuilding the widget (**onSetState**
  ///parameter).
  ///* Side effects to be invoked after rebuilding (**onAfterBuild** parameter).
  ///
  ///onSetState, child and onAfterBuild parameters receives a [On] object.
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
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  Widget listen({
    required On<Widget> child,
    On<void>? onSetState,
    On<void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    bool Function(SnapState<T>? previousState)? shouldRebuild,
    Object? Function()? watch,
    Key? key,
  }) {
    return _StateBuilder<T>(
      key: key,
      rm: [this as ReactiveModel<T>],
      initState: (_, setState) {
        _initialize();

        initState?.call();
        // state;
        if (onAfterBuild != null) {
          WidgetsBinding.instance?.addPostFrameCallback(
            (_) => onAfterBuild(
              isIdle: snapState.isIdle,
              isWaiting: snapState.isWaiting,
              error: snapState.error,
            ),
          );
        }
        return _listenToRMForStateFulWidget((rm, _) {
          rm!;
          if (shouldRebuild?.call(_coreRM._previousSnapState) == false) {
            return;
          }

          onSetState?.call(
            isIdle: rm._snapState.isIdle,
            isWaiting: rm._snapState.isWaiting,
            error: rm.error,
          );
          _onHasErrorCallback = child._onType == _OnType.when;

          if (child._onType == _OnType.onData &&
              (rm._snapState.hasError || rm._snapState.isWaiting)) {
            return;
          }
          if (onAfterBuild != null) {
            WidgetsBinding.instance?.addPostFrameCallback(
              (_) => onAfterBuild(
                isIdle: rm._snapState.isIdle,
                isWaiting: rm._snapState.isWaiting,
                error: rm.error,
              ),
            );
          }
          setState();
        });
      },
      dispose: (context) {
        dispose?.call();
      },
      watch: watch,
      builder: (_) {
        _onHasErrorCallback = child._onType == _OnType.when;
        return child.call(
          isIdle: snapState.isIdle,
          isWaiting: snapState.isWaiting,
          error: snapState.error,
        )!;
      },
    );
  }

  ///Listen to a future from the injected model and rebuild this widget when it
  ///resolves.
  ///
  ///After the future ends (with data or error), it will mutate the state of
  ///the injected model, but only   ///rebuilds this widget.
  ///
  /// * Required parameters:
  ///     * [onWaiting] : callback to be executed when the future is in the
  /// waiting state.
  ///     * [onError] : callback to be executed when the future ends with error.
  ///     * [onData] : callback to be executed when the future ends data.
  ///  * Optional parameters:
  ///     * [future] : Callback that takes the current state and async state of
  /// the injected model.
  /// If not defined and if the injected model is of type (InjectedFuture),
  /// the async state is used by default
  ///     * [dispose] : called when the widget is removed from the widget tree.
  ///
  ///If [onWaiting] or [onError] is set to null, the onData callback will be
  ///execute instead.
  ///
  ///ex:
  ///In the following code the onData will be invoked when the future is waiting,
  ///hasError, or hasData
  ///```dart
  ///injectedModel.futureBuilder(
  ///future : (s, asyncS) => someMethod(),
  ///onWaiting : null, //onData is called instead
  ///onError: null, // onData is called instead
  ///onData: (data)=>SomeWidget(),
  ///)
  ///```
  ///
  ///**Performance:** When this [futureBuilder] is removed from the widget tree, the
  ///future is canceled if not resolved yet.
  Widget futureBuilder<F>({
    Future<F>? Function(T? data, Future<T> asyncState)? future,
    required Widget Function()? onWaiting,
    required Widget Function(dynamic)? onError,
    required Widget Function(F data) onData,
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
  }) {
    return StateBuilder<F>(
      observe: () {
        _initialize();
        if (future != null) {
          final f = future(_state, (this as ReactiveModel<T>).stateAsync);
          assert(f != null);
          return ReactiveModelImp<F>.future(
            () => f!,
            isLazy: false,
          );
        }
        return ReactiveModelImp<T>.future(
          () => (this as ReactiveModel<T>).stateAsync,
          isLazy: false,
        ) as ReactiveModel<F>;
      },
      shouldRebuild: (_) => true,
      onSetState: (_, rm) {
        onSetState?.call(
          isIdle: rm!.isDone,
          isWaiting: rm._snapState.isWaiting,
          error: rm.error,
        );
        if (rm!._snapState.hasData) {
          if (rm.state is T) {
            snapState = SnapState<T>._withData(
              ConnectionState.done,
              rm.state as T,
              true,
            );
            if (onSetState?.onData == null) {
              _coreRM.onData?.call(state);
            }
          }
        } else if (rm._snapState.hasError &&
            rm.error != _coreRM.snapState.error) {
          if (onSetState?.onError == null) {
            _coreRM.onError?.call(rm.error, rm.stackTrace);
          }
        }
      },
      dispose: (_, __) {
        if (!hasObservers) {
          _clean();
        }
        dispose?.call();
      },
      builder: (_, rm) {
        final _rm = rm!;
        if (rm._snapState.isWaiting) {
          return onWaiting?.call() ?? onData(_rm.state);
        }

        if (rm._snapState.hasError) {
          return onError?.call(rm.error) ?? onData(_rm.state);
        }
        return onData(_rm.state);
      },
    );
  }

  ///Listen to a stream from the injected model and rebuild this widget
  ///when the stream emits data.
  ///
  ///when the stream emits data, it will mutate the state of the injected model,
  ///but only rebuilds this widget.
  ///
  /// * Required parameters:
  ///     * [stream] : Callback that takes the current state and
  /// StreamSubscription  of the injected model.
  ///     * [onWaiting] : callback to be executed when the stream is in the
  /// waiting state.
  ///     * [onError] : callback to be executed when the stream emits error.
  ///     * [onData] : callback to be executed when the stream emits data.
  /// * Optional parameters:
  ///     * [onDone] : callback to be executed when the stream isDone.
  ///     * [dispose] : called when the widget is removed from the widget tree.
  ///
  ///If [onWaiting], [onError] or [onDone] is set to null, the onData callback
  ///will be execute instead.
  ///
  ///ex:
  ///In the following code the onData will be invoked when the stream is waiting,
  ///has error, has data, or is done
  ///```dart
  ///injectedModel.streamBuilder(
  ///stream : (s, subscription) => someMethod(),
  ///onWaiting : null, //onData is called instead
  ///onError: null, // onData is called instead
  ///onData: (data)=>SomeWidget(),
  ///)
  ///```
  ///
  ///**Performance:** When this [streamBuilder] is removed from the widget tree, the
  ///stream is closed.
  Widget streamBuilder<S>({
    required Stream<S>? Function(T? s, StreamSubscription? subscription) stream,
    required Widget Function()? onWaiting,
    required Widget Function(dynamic)? onError,
    required Widget Function(S data) onData,
    Widget Function(S data)? onDone,
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
  }) {
    return StateBuilder<S>(
      observe: () {
        _initialize();
        final s = stream(state, (this as ReactiveModel<T>).subscription);
        assert(s != null);
        return ReactiveModelImp<S>.stream(
          (_) => s!,
          isLazy: false,
        );
      },
      shouldRebuild: (_) => true,
      dispose: (_, __) {
        if (!hasObservers) {
          _clean();
        }
        dispose?.call();
      },
      onSetState: (_, rm) {
        onSetState?.call(
          isIdle: rm!.isDone,
          isWaiting: rm._snapState.isWaiting,
          error: rm._snapState.error,
        );
        if (rm!._snapState.hasData) {
          if (rm.state is T) {
            snapState = SnapState<T>._withData(
              ConnectionState.done,
              rm.state as T,
              true,
            );
            if (onSetState?.onData == null) {
              _coreRM.onData?.call(state);
            }
          }
        } else if (rm._snapState.hasError &&
            rm.error != _coreRM.snapState.error) {
          if (onSetState?.onError == null) {
            _coreRM.onError?.call(rm.error, rm.stackTrace);
          }
        }
      },
      builder: (_, rm) {
        final _rm = rm!;
        if (rm._snapState.isWaiting) {
          return onWaiting?.call() ?? onData(_rm.state);
        }

        if (rm._snapState.hasError) {
          return onError?.call(rm.error) ?? onData(_rm.state);
        }
        if (rm.isDone) {
          return onDone?.call(_rm.state) ?? onData(_rm.state);
        }
        return onData(_rm.state);
      },
    );
  }

  /// {@template injected.rebuilder}
  ///Listen to the injected Model and ***rebuild only when the model emits a
  ///notification with new data***.
  ///
  ///If you want to rebuild when model emits notification with waiting or error state
  ///use [Injected.whenRebuilder] or [Injected.whenRebuilderOr].
  ///
  /// * Required parameters:
  ///     * [builder] (positional parameter) is si called each time the
  /// injected model has new data.
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
  ///
  /// Note that this is exactly equivalent to :
  ///```dart
  ///   listen(
  ///    initState: initState != null ? () => initState() : null,
  ///    dispose: dispose != null ? () => dispose() : null,
  ///    shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
  ///    watch: watch,
  ///    child: On.data(() => builder()),
  ///  );
  ///```
  ///
  ///Use [ReactiveModelBuilder.listen] if you want to have more options
  /// {@endtemplate}
  Widget rebuilder(
    Widget Function() builder, {
    void Function()? initState,
    void Function()? dispose,
    Object Function()? watch,
    bool Function()? shouldRebuild,
    Key? key,
  }) {
    return listen(
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
      watch: watch,
      child: On.data(() => builder()),
    );
  }

  /// {@template injected.whenRebuilder}
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
  ///     * [dispose] : callback to be executed when the widget is removed
  /// from the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///
  /// Note that this is exactly equivalent to :
  ///```dart
  ///  return listen(
  ///    initState: initState != null ? () => initState() : null,
  ///    dispose: dispose != null ? () => dispose() : null,
  ///    shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
  ///    child: On.all(
  ///      onIdle: onIdle,
  ///      onWaiting: onWaiting,
  ///      onError: onError,
  ///      onData: onData,
  ///    ),
  ///  );
  ///```
  ///
  ///Use [ReactiveModelBuilder.listen] if you want to have more options
  /// {@endtemplate}
  Widget whenRebuilder({
    required Widget Function() onIdle,
    required Widget Function() onWaiting,
    required Widget Function() onData,
    required Widget Function(dynamic) onError,
    void Function()? initState,
    void Function()? dispose,
    bool Function()? shouldRebuild,
    Key? key,
  }) {
    return listen(
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
      child: On.all(
        onIdle: onIdle,
        onWaiting: onWaiting,
        onError: onError,
        onData: onData,
      ),
    );
  }

  /// {@template injected.whenRebuilderOr}
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
  ///     * [dispose] : callback to be executed when the widget is removed
  /// from the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * [watch] : callback to be executed before notifying listeners.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  ///
  /// Note that this is exactly equivalent to :
  ///```dart
  ///  return listen(
  ///    initState: initState != null ? () => initState() : null,
  ///    dispose: dispose != null ? () => dispose() : null,
  ///    shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
  ///    watch: watch,
  ///    child: On.or(
  ///      onIdle: onIdle,
  ///      onWaiting: onWaiting,
  ///      onError: onError,
  ///      onData: onData,
  ///      or: builder,
  ///    ),
  ///  );
  ///```
  ///
  ///Use [ReactiveModelBuilder.listen] if you want to have more options
  /// {@endtemplate}
  Widget whenRebuilderOr({
    Widget Function()? onIdle,
    Widget Function()? onWaiting,
    Widget Function(dynamic)? onError,
    Widget Function()? onData,
    required Widget Function() builder,
    void Function()? initState,
    void Function()? dispose,
    Object Function()? watch,
    bool Function()? shouldRebuild,
    Key? key,
  }) {
    return listen(
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
      watch: watch,
      child: On.or(
        onIdle: onIdle,
        onWaiting: onWaiting,
        onError: onError,
        onData: onData,
        or: builder,
      ),
    );
  }
}
