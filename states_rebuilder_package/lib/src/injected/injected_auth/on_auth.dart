part of 'injected_auth.dart';

///[InjectedAuth] listener
class OnAuth<T> {
  T Function()? _onInitialWaiting;
  final T Function()? _onWaiting;
  final T Function() _onUnsigned;
  final T Function() _onSigned;

  ///[InjectedAuth] listener
  OnAuth({
    required T Function()? onInitialWaiting,
    required T Function()? onWaiting,
    required T Function() onUnsigned,
    required T Function() onSigned,
  })   : _onInitialWaiting = onInitialWaiting,
        _onWaiting = onWaiting,
        _onUnsigned = onUnsigned,
        _onSigned = onSigned;

  ///Listen to an InjectedAuth state
  ///
  ///By default, the switch between the onSinged and the onUnsigned pages is
  ///a simple widget replacement. To use the navigation page transition
  ///animation, set [userRouteNavigation] to true. In this case, you
  ///need to set the [RM.navigate.navigatorKey].
  Widget listenTo(
    InjectedAuth injected, {
    bool useRouteNavigation = false,
    void Function()? dispose,
    On<void>? onSetState,
    Key? key,
  }) {
    T getWidget() => injected.isSigned ? _onSigned() : _onUnsigned();

    bool isNavigated = false;
    return StateBuilderBase<_OnAuthWidget<T>>(
      (_, setState) {
        return LifeCycleHooks(
          mountedState: (_) {
            //It is not disposed
            (injected as InjectedAuthImp)
                .reactiveModelState
                .listeners
                .addListener(
              (_) {
                onSetState?.call(injected.snapState);

                if (useRouteNavigation && injected.hasData) {
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
                  setState();
                }
              },
              clean: null,
            );
          },
          dispose: (_) {
            dispose?.call();
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
            if (injected.isWaiting) {
              if (widget.onInitialWaiting != null) {
                return (widget.onInitialWaiting?.call() ?? getWidget())
                    as Widget;
              }
              return (widget.onWaiting?.call() ?? getWidget()) as Widget;
            }
            widget.onInitialWaiting = null;
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
  T Function()? onInitialWaiting;
  final T Function()? onWaiting;
  final T Function() onUnsigned;
  final T Function() onSigned;
  _OnAuthWidget({
    required this.inject,
    this.onInitialWaiting,
    this.onWaiting,
    required this.onUnsigned,
    required this.onSigned,
  });
}
