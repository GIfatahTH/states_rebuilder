part of '../rm.dart';

extension OnCombinedX on OnCombined<dynamic, Widget> {
  bool _canRebuild(SnapState snap) {
    if (snap.isWaiting) {
      return _hasOnWaiting;
    }
    if (snap.hasError) {
      return _hasOnError;
    }
    return true;
  }

  ///Listen to a list [Injected] states and register:
  ///{@macro listen}
  ///
  ///onSetState, child and onAfterBuild parameters receives a
  ///[OnCombined] object.
  Widget listenTo<T>(
    List<InjectedBaseState<dynamic>> injects, {
    OnCombined<T, void>? onSetState,
    OnCombined<T, void>? onAfterBuild,
    void Function()? initState,
    void Function()? dispose,
    // void Function(_StateBuilder<T> oldWidget)? didUpdateWidget,
    bool Function()? shouldRebuild,
    Object? Function()? watch,
    Key? key,
    String? debugPrintWhenRebuild,
  }) {
    return StateBuilderBase<_OnCombinedWidget<Widget>>(
      (widget, setState) {
        List<VoidCallback> disposers = [];
        var previousWatch = watch?.call();
        return LifeCycleHooks(
          mountedState: (_) {
            for (var inj in injects) {
              late ReactiveModelBase rm;
              if (inj is InjectedImp) {
                inj.initialize();
                rm = inj._reactiveModelState;
              } else if (inj is ReactiveModel) {
                rm = (inj as ReactiveModelImp).reactiveModelState;
              }
              final disposer = rm.listeners.addListenerForRebuild(
                (s) {
                  var snapFormType = injects.firstWhereOrNull(
                    (e) {
                      if (e.snapState.type() == T) {
                        _notifiedInject = e;
                        return true;
                      }
                      return false;
                    },
                  )?.snapState;
                  if (snapFormType == null) {
                    snapFormType = s;
                    _notifiedInject = injects.firstWhereOrNull(
                      (e) => e.snapState == s,
                    );
                  }
                  if (shouldRebuild != null && !shouldRebuild()) {
                    return;
                  }
                  if (watch != null) {
                    final currentWatch = watch();
                    if (currentWatch == previousWatch) {
                      return;
                    }
                    previousWatch = currentWatch;
                  }

                  _combinedSnap =
                      _getCombinedSnap(widget.injects, snapFormType!);

                  if (!_canRebuild(_combinedSnap!)) {
                    return;
                  }

                  onSetState?._call(_combinedSnap!, _combinedSnap!.data);

                  if (onAfterBuild != null) {
                    WidgetsBinding.instance?.addPostFrameCallback(
                      (_) => onAfterBuild._call(
                          _combinedSnap!, _combinedSnap!.data),
                    );
                  }
                  setState();
                  assert(() {
                    if (debugPrintWhenRebuild != null) {
                      StatesRebuilerLogger.log('REBUILD <' +
                          debugPrintWhenRebuild +
                          '>: $_combinedSnap');
                    }
                    return true;
                  }());
                },
                clean: inj is InjectedImp && inj.autoDisposeWhenNotUsed
                    ? () => inj.dispose()
                    : null,
              );
              disposers.add(disposer);
            }

            var snapFormType = injects.firstWhereOrNull((e) {
              if (e.snapState.type() == T) {
                _notifiedInject = e;
                return true;
              }
              return false;
            })?.snapState;
            if (snapFormType == null) {
              snapFormType = injects.first.snapState;
              _notifiedInject = injects.first;
            }
            _combinedSnap = _getCombinedSnap(widget.injects, snapFormType);

            if (onAfterBuild != null) {
              WidgetsBinding.instance?.addPostFrameCallback(
                (_) => onAfterBuild._call(_combinedSnap!, _combinedSnap!.data),
              );
            }
            assert(() {
              if (debugPrintWhenRebuild != null) {
                StatesRebuilerLogger.log('INITIAL BUILD <' +
                    debugPrintWhenRebuild +
                    '>: $_combinedSnap');
              }
              return true;
            }());

            initState?.call();
          },
          dispose: (_) {
            dispose?.call();

            disposers.forEach((e) => e());
          },
          didUpdateWidget: (context, oldWidget, newWidget) {
            for (var i = 0; i < newWidget.injects.length; i++) {
              final newInj = newWidget.injects[i];
              final oldInj = oldWidget.injects[i];
              if (newInj._reactiveModelState != oldInj._reactiveModelState) {
                newInj._reactiveModelState.dispose();
                newInj._reactiveModelState = oldInj._reactiveModelState;
                if (newInj is InjectedImp) {
                  newInj.undoRedoPersistState =
                      (oldInj as InjectedImp).undoRedoPersistState;
                }
              }
            }
          },
          builder: (ctx, widget) {
            return widget.on._call(
              _combinedSnap!,
              _combinedSnap!.data,
              false,
            )!;
          },
        );
      },
      widget: _OnCombinedWidget(injects: injects, on: this),
      key: key,
    );
  }

  SnapState<T> _getCombinedSnap<T>(
      List<InjectedBaseState<dynamic>> injects, SnapState<T> snapFromType) {
    SnapState? snapError;
    SnapState? snapIdle;
    for (var e in injects) {
      if (e.isWaiting) {
        return snapFromType.copyToIsWaiting();
      }
      if (e.hasError) {
        snapError ??= e.snapState;
      }
      if (e.isIdle) {
        snapIdle ??= e.snapState;
      }
    }
    if (snapError != null) {
      return snapFromType.copyToHasError(
        snapError.error,
        stackTrace: snapError.stackTrace,
        onErrorRefresher: snapError.onErrorRefresher,
      );
    }
    if (snapIdle != null) {
      return snapFromType.copyToIsIdle();
    }
    return snapFromType;
  }
}

class _OnCombinedWidget<T> {
  final List<InjectedBaseState<dynamic>> injects;
  final OnCombined<dynamic, T> on;
  _OnCombinedWidget({
    required this.injects,
    required this.on,
  });
}
