part of '../rm.dart';

extension InjectedX<T> on Injected<T> {
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
  ///     On.data(
  ///       () => builder()
  ///     ).listenTo(
  ///       injectedState,
  ///       initState: initState != null ? () => initState() : null,
  ///       dispose: dispose != null ? () => dispose() : null,
  ///       shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
  ///       watch: watch,
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
    return On.data(builder).listenTo<T>(
      this,
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
      watch: watch,
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
  ///  return On.all(
  ///      onIdle: onIdle,
  ///      onWaiting: onWaiting,
  ///      onError: onError,
  ///      onData: onData,
  ///  ).listenTo(
  ///       injectedState,
  ///       initState: initState != null ? () => initState() : null,
  ///       dispose: dispose != null ? () => dispose() : null,
  ///       shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
  ///       watch: watch,
  ///   );
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
  }) =>
      On.all(
        onIdle: onIdle,
        onWaiting: onWaiting,
        onError: (err, _) => onError(err),
        onData: onData,
      ).listenTo<T>(
        this,
        initState: initState != null ? () => initState() : null,
        dispose: dispose != null ? () => dispose() : null,
        shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
      );

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
  ///  return On.or(
  ///      onIdle: onIdle,
  ///      onWaiting: onWaiting,
  ///      onError: onError,
  ///      onData: onData,
  ///      or: builder,
  ///  ).listenTo(
  ///       injectedState,
  ///       initState: initState != null ? () => initState() : null,
  ///       dispose: dispose != null ? () => dispose() : null,
  ///       shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
  ///       watch: watch,
  ///   );
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
  }) =>
      On.or(
        onIdle: onIdle,
        onWaiting: onWaiting,
        onError: onError != null ? (err, _) => onError(err) : null,
        onData: onData,
        or: builder,
      ).listenTo<T>(
        this,
        initState: initState != null ? () => initState() : null,
        dispose: dispose != null ? () => dispose() : null,
        shouldRebuild: shouldRebuild != null ? (_) => shouldRebuild() : null,
        watch: watch,
      );

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
    required Widget Function(F? data) onData,
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
  }) {
    return StateBuilderBase<_OnAsyncWidget<F>>(
      (widget, setState) {
        final inj = this as InjectedImp<T>;
        inj.initialize();

        StreamSubscription? subscription;
        bool isWaiting = true;
        F? data = _getPrimitiveNullState<F>();
        dynamic error;
        Future<F?>? f;
        SnapState<F?> snap = SnapState._nothing(null, '', '');
        VoidCallback? disposer;
        if (future != null) {
          f = future(inj._nullableState, inj.stateAsync);
        } else {
          f = stateAsync as Future<F?>;
        }
        disposer = inj._reactiveModelState.listeners.addListener(
          (_) {},
          clean: inj.autoDisposeWhenNotUsed
              ? () {
                  inj.dispose();
                }
              : null,
        );

        return LifeCycleHooks(
          mountedState: (_) {
            subscription = f?.asStream().listen.call((d) {
              isWaiting = false;
              setState();
              onSetState?.call(snap._copyToHasData(d));
              if (d is T) {
                inj._reactiveModelState._snapState = SnapState<T>._withData(
                  ConnectionState.done,
                  d as T,
                );
                if (onSetState?._onData == null) {
                  inj.onData?.call(inj.state);
                }
                disposer?.call();
                disposer = null;
              }
              data = d;
            }, onError: (e, s) {
              isWaiting = false;
              setState();
              onSetState?.call(snap._copyToHasError(e, () {}, stackTrace: s));
              if (e != inj.error) {
                if (onSetState?._onError == null) {
                  inj.onError?.call(e, s);
                }
              }
              error = e;
            });
            onSetState?.call(snap._copyToIsWaiting());
          },
          dispose: (_) {
            disposer?.call();
            dispose?.call();
            subscription?.cancel();
            // if (!inj._reactiveModelState._listeners.hasListeners) {
            //   inj.dispose();
            // }
          },
          builder: (ctx, widget) {
            if (isWaiting) {
              return widget.onWaiting?.call() ?? widget.onData(data);
            }
            if (error != null) {
              return widget.onError?.call(error) ?? widget.onData(data);
            }
            return widget.onData(data);
          },
        );
      },
      widget: _OnAsyncWidget<F>(
        onWaiting: onWaiting,
        onError: onError,
        onData: onData,
      ),
      key: key,
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
    required Widget Function(S? data) onData,
    Widget Function(S data)? onDone,
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
  }) {
    return StateBuilderBase<_OnAsyncWidget<S>>(
      (widget, setState) {
        final inj = this as InjectedImp<T>;
        inj.initialize();

        StreamSubscription? subscription;
        bool isWaiting = true;
        bool isDone = false;
        S? data = _getPrimitiveNullState<S>();
        dynamic error;
        SnapState<S?> snap = SnapState._nothing(null, '', '');

        return LifeCycleHooks(
          mountedState: (_) {
            subscription =
                stream(inj._nullableState, inj.subscription)?.listen.call(
              (d) {
                isWaiting = false;
                setState();
                onSetState?.call(snap._copyToHasData(data));
                if (data is T) {
                  inj._reactiveModelState._snapState = SnapState<T>._withData(
                    ConnectionState.done,
                    data as T,
                  );
                  if (onSetState?._onData == null) {
                    inj.onData?.call(inj.state);
                  }
                }
                data = d;
              },
              onError: (e, s) {
                isWaiting = false;
                setState();
                onSetState?.call(snap._copyToHasError(e, () {}, stackTrace: s));
                if (e != inj.error) {
                  if (onSetState?._onError == null) {
                    inj.onError?.call(e, s);
                  }
                }
                error = e;
              },
              onDone: () {
                isDone = true;
              },
            );
            onSetState?.call(snap._copyToIsWaiting());
          },
          dispose: (_) {
            dispose?.call();
            subscription?.cancel();
            if (inj.autoDisposeWhenNotUsed &&
                !inj._reactiveModelState.listeners.hasListeners) {
              inj.dispose();
            }
          },
          builder: (ctx, widget) {
            if (isWaiting) {
              return widget.onWaiting?.call() ?? widget.onData(data);
            }
            if (error != null) {
              return widget.onError?.call(error) ?? widget.onData(data);
            }
            if (isDone) {
              return widget.onDone?.call(data!) ?? widget.onData(data);
            }
            return widget.onData(data);
          },
        );
      },
      widget: _OnAsyncWidget<S>(
        onWaiting: onWaiting,
        onError: onError,
        onData: onData,
        onDone: onDone,
      ),
      key: key,
    );
  }
}

class _OnAsyncWidget<T> {
  final Widget Function()? onWaiting;
  final Widget Function(dynamic)? onError;
  final Widget Function(T? data) onData;
  final Widget Function(T data)? onDone;
  _OnAsyncWidget({
    this.onWaiting,
    this.onError,
    required this.onData,
    this.onDone,
  });
}
