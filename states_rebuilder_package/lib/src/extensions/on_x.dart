part of '../rm.dart';

extension OnX on On<Widget> {
  bool _canRebuild(Injected inj) {
    if (inj.isWaiting) {
      return _hasOnWaiting;
    }
    if (inj.hasError) {
      return _hasOnError;
    }
    return true;
  }

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
    Injected<T> injected, {
    On<void>? onSetState,
    On<void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    // void Function(_StateBuilder)? didUpdateWidget,
    bool Function(SnapState<T>? snapState)? shouldRebuild,
    Object? Function()? watch,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return StateBuilderBase<_OnWidget<Widget>>(
      (widget, setState) {
        late VoidCallback disposer;
        var previousWatch = watch?.call();
        if (injected is InjectedImp) {
          (injected as InjectedImp).initialize();
        }
        return LifeCycleHooks(
          mountedState: (_) {
            disposer = injected._reactiveModelState.listeners.addListener(
              (snap) {
                if (shouldRebuild != null &&
                    !shouldRebuild(injected.snapState)) {
                  return;
                }
                if (watch != null) {
                  final currentWatch = watch();
                  if (deepEquality.equals(currentWatch, previousWatch)) {
                    return;
                  }
                  previousWatch = currentWatch;
                }
                if (!_canRebuild(injected)) {
                  return;
                }
                onSetState?.call(injected.snapState);
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  onAfterBuild?.call(injected.snapState);
                });
                setState();
                assert(() {
                  if (debugPrintWhenRebuild != null) {
                    print('REBUILD <' + debugPrintWhenRebuild + '>: $snap');
                  }
                  return true;
                }());
              },
              clean: injected is InjectedImp &&
                      !(injected as InjectedImp).autoDisposeWhenNotUsed
                  ? null
                  : () => injected.dispose(),
            );
            assert(() {
              if (debugPrintWhenRebuild != null) {
                print('INITIAL BUILD <' +
                    debugPrintWhenRebuild +
                    '>: ${injected.snapState}');
              }
              return true;
            }());
            initState?.call();
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              onAfterBuild?.call(injected.snapState);
            });
          },
          dispose: (_) {
            dispose?.call();
            disposer();
          },
          didUpdateWidget: (context, oldWidget, newWidget) {
            final newInj = newWidget.inject;
            final oldInj = oldWidget.inject;
            if (newInj._reactiveModelState != oldInj._reactiveModelState) {
              newInj._reactiveModelState.dispose();
              newInj._reactiveModelState = oldInj._reactiveModelState;
              if (newInj is InjectedImp) {
                newInj.undoRedoPersistState =
                    (oldInj as InjectedImp).undoRedoPersistState;
              }
            }
          },
          builder: (ctx, widget) {
            return widget.on.call(
              injected.snapState,
              false,
            )!;
          },
        );
      },
      widget: _OnWidget<Widget>(inject: injected, on: this),
      key: key,
    );
  }
}

class _OnWidget<T> {
  final Injected inject;
  final On<T> on;
  _OnWidget({
    required this.inject,
    required this.on,
  });
}
