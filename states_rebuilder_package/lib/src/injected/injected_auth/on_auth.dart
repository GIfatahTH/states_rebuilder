part of 'injected_auth.dart';

///[InjectedAuth] listener
class OnAuth<T> {
  final T Function()? _onInitialWaiting;
  final T Function()? _onWaiting;
  final T Function() _onUnsigned;
  final T Function() _onSigned;

  ///[InjectedAuth] listener
  OnAuth({
    required T Function()? onInitialWaiting,
    required T Function()? onWaiting,
    required T Function() onUnsigned,
    required T Function() onSigned,
  })  : _onInitialWaiting = onInitialWaiting,
        _onWaiting = onWaiting,
        _onUnsigned = onUnsigned,
        _onSigned = onSigned;

  ///Listen to an InjectedAuth state
  ///
  ///By default, the switch between the onSinged and the onUnsigned pages is
  ///a simple widget replacement. To use the navigation page transition
  ///animation, set [userRouteNavigation] to true. In this case, you
  ///need to set the [RM.navigate.navigatorKey].
  Widget listenTo<D>(
    InjectedAuth<D, dynamic> injected, {
    bool useRouteNavigation = false,
    SideEffects<D>? sideEffects,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    final inj = injected as InjectedAuthImp<D, dynamic>;
    inj.initialize();
    T getWidget() => inj.isSigned ? _onSigned() : _onUnsigned();
    bool isNavigated = false;
    bool isInitialBuild = true;
    return StateBuilderBase<_OnAuthWidget<T>>(
      (widget, setState) {
        var onInitialWaiting = widget.onInitialWaiting;
        return LifeCycleHooks(
          mountedState: (_) {
            //It is not disposed
            inj.reactiveModelState.listeners.addListenerForRebuild(
              (snap) {
                print(inj.snapState);
                print(inj.sideEffects);
                print(inj.sideEffects!.onAfterBuild);
                print(inj.sideEffects!.onSetState);
                // inj.sideEffects
                //   ?..onSetState?.call(inj.snapState)
                //   ..onAfterBuild?.call();

                if (useRouteNavigation && inj.hasData) {
                  if (injected.isSigned) {
                    RM.navigate.toAndRemoveUntil<T>(
                      _onSigned() as Widget,
                    );
                  } else {
                    RM.navigate.toAndRemoveUntil<T>(
                      _onUnsigned() as Widget,
                    );
                  }

                  isNavigated = true;
                } else if (!isNavigated) {
                  if (injected.isWaiting && widget.onInitialWaiting == null) {
                    return;
                  }
                  setState();
                  assert(() {
                    if (debugPrintWhenRebuild != null) {
                      StatesRebuilerLogger.log(
                          'REBUILD <' + debugPrintWhenRebuild + '>: $snap');
                    }
                    return true;
                  }());
                }
              },
              clean: null,
            );
            sideEffects?.initState?.call();
          },
          dispose: (_) {
            sideEffects?.dispose?.call();

            // disposer();
          },
          didUpdateWidget: (context, oldWidget, newWidget) {
            final newInj = newWidget.inject as InjectedImp;
            final oldInj = oldWidget.inject as InjectedImp;
            if (newInj.reactiveModelState != oldInj.reactiveModelState) {
              newInj.reactiveModelState.dispose();
              newInj.reactiveModelState = oldInj.reactiveModelState;
              newInj.undoRedoPersistState = oldInj.undoRedoPersistState;
            }
          },
          builder: (ctx, widget) {
            assert(() {
              if (isInitialBuild && debugPrintWhenRebuild != null) {
                isInitialBuild = false;
                StatesRebuilerLogger.log('INITIAL BUILD<' +
                    debugPrintWhenRebuild +
                    '>: ${injected.snapState}');
              }
              return true;
            }());
            if (injected.isWaiting) {
              if (onInitialWaiting != null) {
                return (widget.onInitialWaiting?.call() ?? getWidget())
                    as Widget;
              }
              return (widget.onWaiting?.call() ?? getWidget()) as Widget;
            }
            onInitialWaiting = null;
            return (isNavigated ? widget.onUnsigned() : getWidget()) as Widget;
          },
        );
      },
      widget: _OnAuthWidget<T>(
        inject: injected,
        onInitialWaiting: _onInitialWaiting,
        onWaiting: _onWaiting,
        onUnsigned: _onUnsigned,
        onSigned: _onSigned,
      ),
      key: key,
    );
  }
}

class _OnAuthWidget<T> {
  final Injected inject;

  ///Widget to display while waiting for the first signing when app starts
  final T Function()? onInitialWaiting;

  ///Widget to display while waiting for signing
  final T Function()? onWaiting;

  ///Widget to display if use is signed
  final T Function() onUnsigned;

  ///Widget to display if use is unsigned
  final T Function() onSigned;
  _OnAuthWidget({
    required this.inject,
    this.onInitialWaiting,
    this.onWaiting,
    required this.onUnsigned,
    required this.onSigned,
  });
}

class OnAuthBuilder<T, P> extends StatelessWidget {
  const OnAuthBuilder({
    Key? key,
    required this.listenTo,
    required this.onUnsigned,
    required this.onSigned,
    this.onInitialWaiting,
    this.useRouteNavigation = false,
    this.onWaiting,
    this.dispose,
    this.onSetState,
    this.sideEffects,
    this.debugPrintWhenRebuild,
  }) : super(key: key);
  final InjectedAuth<T, P> listenTo;

  ///Widget to display while waiting for the first signing when app starts
  final Widget Function()? onInitialWaiting;

  ///Widget to display while waiting for signing
  final Widget Function()? onWaiting;

  ///Widget to display if use is signed
  final Widget Function() onUnsigned;

  ///Widget to display if use is unsigned
  final Widget Function() onSigned;

  ///Whether to use navigation transition between onSigned and onUnsigned
  ///widgets or simply use widget replacement
  final bool useRouteNavigation;

  ///Side effects to call when this widget is disposed.
  @Deprecated('Use sideEffects instead')
  final void Function()? dispose;

  ///Side effects to call InjectedAuth emits notification.
  @Deprecated('Use sideEffects instead')
  final On<void>? onSetState;

  ///Handle side effects
  final SideEffects<T>? sideEffects;

  ///Debug print informative message when this widget is rebuilt
  final String? debugPrintWhenRebuild;
  @override
  Widget build(BuildContext context) {
    return On.auth(
      onInitialWaiting: onInitialWaiting,
      onWaiting: onWaiting,
      onUnsigned: onUnsigned,
      onSigned: onSigned,
    ).listenTo<T>(
      listenTo,
      useRouteNavigation: useRouteNavigation,
      sideEffects: sideEffects,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }
}
