part of '../rm.dart';

extension OnFutureX<F> on OnFuture<F> {
  ///Used to listen to any kind of future.
  ///
  /// * **Required parameters**:
  ///     * **future**: Callback that return the future to listen to.
  /// * **Optional parameters:**
  ///     * **onSetState** :  of type `On<void>`. used for side effects
  ///     * **dispose** :  called when the widget is removed from the
  /// widget tree.
  Widget future<T>(
    Future<T> Function() future, {
    void Function()? dispose,
    void Function()? initState,
    On<void>? onSetState,
    Key? key,
  }) {
    assert(F == dynamic || '$F' == 'Object?' || T == F);
    return _listenTo<T>(
      future: future,
      dispose: dispose,
      initState: initState,
      onSetState: onSetState,
      key: key,
    );
  }

  ///Used to listen to the `stateAsync` of an injected state.
  ///
  ///This is a one-time subscription for `onWaiting` and `onError`. That is
  ///after the `stateAsync` future ends, this widget will not rebuild if the
  ///injected state emits notification with `hasError` or `isWaiting` state status.
  ///
  ///Whereas, `onData` is an ongoing subscription. the widget keeps listening the
  ///injected state when emits a notification with `hasData` status.
  ///
  /// * **Required parameters**:
  ///     * **future**: Callback that return the future to listen to.
  /// * **Optional parameters:**
  ///     * **onSetState** :  of type `On<void>`. used for side effects
  ///     * **dispose** :  called when the widget is removed from the
  /// widget tree.
  Widget listenTo<T>(
    Injected<T> injected, {
    void Function()? dispose,
    void Function()? initState,
    On<void>? onSetState,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    assert(F == dynamic || '$F' == 'Object?' || T == F);

    return _listenTo<T>(
      injected: injected,
      dispose: dispose,
      initState: initState,
      onSetState: onSetState,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }

  Widget _listenTo<T>({
    Injected<T>? injected,
    Future<T> Function()? future,
    void Function()? dispose,
    void Function()? initState,
    On<void>? onSetState,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return StateBuilderBase<OnFutureWidget>(
      (widget, setState) {
        assert(injected != null || future != null);
        late InjectedBase<F> inj;
        VoidCallback? disposer1;
        VoidCallback? disposer2;
        if (future != null) {
          inj = ReactiveModelImp(creator: () => future());
        } else {
          // bool _isAlreadyNotified = false;
          inj = InjectedImp<T>(
            creator: () => injected!.stateAsync,
            // //depends is add only to prevent injected from disposing while
            // //this new Inject is alive
            // dependsOn: DependsOn<T>(
            //   {injected!},
            //   shouldNotify: (_) {
            //     if (_isAlreadyNotified) {
            //       return false;
            //     }
            //     _isAlreadyNotified = true;
            //     return true;
            //   },
            // ),
            isLazy: false,
            initialState: injected!._nullableState,
            debugPrintWhenNotifiedPreMessage: '',
          ) as Injected<F>;

          disposer1 =
              injected._reactiveModelState.listeners.addListenerForRebuild(
            (_) {},
            clean: injected is InjectedImp &&
                    !(injected as InjectedImp).autoDisposeWhenNotUsed
                ? null
                : () {
                    injected.dispose();
                  },
          );
        }
        return LifeCycleHooks(
          mountedState: (_) {
            assert(() {
              if (debugPrintWhenRebuild != null) {
                StatesRebuilerLogger.log('INITIAL BUILD<' +
                    debugPrintWhenRebuild +
                    '>: ${inj.snapState}');
              }
              return true;
            }());

            initState?.call();
            disposer2 = inj.subscribeToRM(
              (snap) {
                setState();
                onSetState?.call(snap!);
                assert(() {
                  if (debugPrintWhenRebuild != null) {
                    final inj = injected as InjectedImp;

                    StatesRebuilerLogger.log('REBUILD <' +
                        debugPrintWhenRebuild +
                        '>: ${inj.snapState}');
                  }
                  return true;
                }());
              },
            );
          },
          dispose: (_) {
            dispose?.call();
            inj.dispose();
            disposer1?.call();
            disposer2?.call();
          },
          builder: (ctx, widget) {
            final _refresher = () {
              if (injected != null) {
                if (injected.hasError) {
                  injected.onErrorRefresher.call();
                } else {
                  injected._reactiveModelState._refresh();
                }
              }
              inj._reactiveModelState._refresh();
            };

            return On(() {
              if (inj.snapState.isWaiting) {
                return _onWaiting?.call() ?? _onData(inj._state, _refresher);
              }
              if (inj.snapState.hasError) {
                return _onError?.call(
                      inj.error,
                      _refresher,
                    ) ??
                    _onData(inj._state, _refresher);
              }
              return injected != null
                  ? On.data(() => _onData(inj._state, _refresher))
                      .listenTo(injected)
                  : _onData(inj._state, _refresher);
            }).listenTo<F>(
              inj,
              onSetState: onSetState,
              dispose: dispose,
              key: key,
            );
          },
        );
      },
      widget: OnFutureWidget(injects: []),
      key: key,
    );
  }
}

class OnFutureWidget extends Widget {
  final List<Injected> injects;
  OnFutureWidget({
    required this.injects,
  });
  @override
  Element createElement() {
    throw UnimplementedError();
  }
}
