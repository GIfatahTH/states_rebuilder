part of '../../rm.dart';

class InjectedImp<T> extends ReactiveModelImp<T> implements Injected<T> {
  InjectedImp({
    required Object? Function() creator,
    required T? initialState,
    required this.sideEffectsGlobal,
    required StateInterceptor<T>? stateInterceptor,
    required bool autoDisposeWhenNotUsed,
    required this.debugPrintWhenNotifiedPreMessageGlobal,
    required this.toDebugString,
    required this.dependsOn,
    required this.watch,
  }) : super(
          creator: creator,
          initialState: initialState,
          stateInterceptorGlobal: stateInterceptor,
          autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
        ) {
    resetDefaultState(() {
      creatorUpdatable = creator;
    });
  }
  final SideEffects<T>? sideEffectsGlobal;
  final String? debugPrintWhenNotifiedPreMessageGlobal;
  final Object? Function(T?)? toDebugString;
  final DependsOn<T>? dependsOn;
  final Object? Function(T? s)? watch;
  //
  late Object? Function() creatorUpdatable;
  late Object? _cachedWatch;
  final inheritedInjects = <InjectedImp<T>>{};
  late bool? _shouldConnectWithGlobal;
  late bool _isInheritedDirty;
  // var fields. they deed to reset to default value after state disposing off
  // _resetDefaultState is used to reset var fields to default initial values
  @override
  void resetDefaultState([VoidCallback? fn]) {
    super.resetDefaultState();
    inheritedInjects.clear();
    _cachedWatch = null;
    _shouldConnectWithGlobal = null;
    _isInheritedDirty = false;
    fn?.call();
  }

  List<dynamic Function()?> cachedCreatorMocks = [null];

  @override
  SnapState<T> get initialSnapState => SnapState<T>.none(
        debugName: debugPrintWhenNotifiedPreMessageGlobal ?? '',
        toDebugString: toDebugString,
        infoMessage: kInitMessage,
        data: initialState,
      );
  @override
  Object? Function() get mockableCreator {
    if (!isInitialized && dependsOn != null) {
      _subscribeForCombinedSnap();
      _setCombinedSnap(kDebugMode ? StackTrace.current : null);
    }
    if (cachedCreatorMocks.last != null) {
      if (creator is Future<T> Function() || creator is Stream<T> Function()) {
        isWaitingToInitialize = true;
      }
      return cachedCreatorMocks.last!;
    }
    return creatorUpdatable;
  }

  @override
  void onStateInitialized() {
    assert(() {
      if (debugPrintWhenNotifiedPreMessageGlobal != null) {
        _snapState.debugPrint();
      }
      return true;
    }());
    sideEffectsGlobal?.initState?.call();
  }

  @override
  Future<T?> refresh({String? infoMessage}) async {
    if (inheritedInjects.isNotEmpty) {
      _snapState = snapState.copyWith(infoMessage: kRefreshMessage);
      await WidgetsBinding.instance.endOfFrame;
      if (_isInheritedDirty) {
        _isInheritedDirty = false;
      } else {
        for (final inj in inheritedInjects) {
          inj.refresh(infoMessage: kRecomputing);
        }
      }
      if (inheritedInjects.isNotEmpty) {
        notify(
          nextSnap: inheritedInjects.last.snapValue,
        );
      }

      try {
        return await stateAsync;
      } catch (e) {
        return _snapState.data;
      }
    }
    return super.refresh();
  }

  void _injectMock(dynamic Function() fakeCreator) {
    dispose();
    // // if (bool.fromEnvironment('test')) {
    RM.disposeAll();
    // // }
    cachedCreatorMocks.add(fakeCreator);
  }

  @override
  void injectMock(T Function() fakeCreator) {
    _injectMock(fakeCreator);
  }

  @override
  void injectFutureMock(Future<T> Function() fakeCreator) {
    _injectMock(fakeCreator);
  }

  @override
  void injectStreamMock(Stream<T> Function() fakeCreator) {
    _injectMock(fakeCreator);
  }

  @override
  bool notify({
    SnapState<T>? nextSnap,
    SideEffects<T>? sideEffects,
    bool Function(SnapState<T>)? shouldOverrideDefaultSideEffects,
    StateInterceptor<T>? stateInterceptor,
  }) {
    final isNotified = super.notify(
      nextSnap: nextSnap,
      sideEffects: sideEffects,
      stateInterceptor: stateInterceptor,
    );
    if (!isNotified) {
      return false;
    }
    if (nextSnap == null) {
      return true;
    }
    if (shouldOverrideDefaultSideEffects?.call(_snapState) != true) {
      sideEffectsGlobal
        ?..onSetState?.call(_snapState)
        .._onAfterBuild?.call();
    }

    assert(() {
      if (debugPrintWhenNotifiedPreMessageGlobal != null &&
          _snapState._infoMessage != kInitMessage) {
        // if (_snapState == _snapState.oldSnapState) {
        //   return true;
        // }
        _snapState.debugPrint();
      }
      return true;
    }());
    return true;
  }

  @override
  void rebuildState() {
    if (watch != null && (_snapState.hasData | _snapState.isIdle)) {
      final w = watch!(_snapState.data);
      if (deepEquality.equals(w, _cachedWatch)) {
        return;
      }
      _cachedWatch = w;
    }
    super.rebuildState();
  }

  @override
  Widget inherited({
    required Widget Function(BuildContext) builder,
    Key? key,
    required FutureOr<T> Function()? stateOverride,
    bool? connectWithGlobal,
    SideEffects<T>? sideEffects,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
    // bool keepAlive = false,
  }) {
    if (connectWithGlobal == null && _shouldConnectWithGlobal == null) {
      if (!isInitialized) {
        try {
          final s = mockableCreator();
          isInitialized = true;
          if (s is T) {
            _snapState = _snapState.copyWith(data: s);
          } else if (s != null) {
            setStateNullable(
              (s) => mockableCreator(),
              middleSetState: middleSetState,
              stackTrace: kDebugMode ? StackTrace.current : null,
            );
          }
          // _reactiveModelState.setStateFn(
          //   (_) => s,
          //   middleState: _middleSnap,
          //   onDone: (_) {},
          // )();
        } catch (e) {
          if (e is! UnimplementedError) {
            rethrow;
          }
        }
      }

      _shouldConnectWithGlobal = _snapState.data == null;
    }

    return _inherited(
      builder: builder,
      key: key,
      stateOverride: stateOverride,
      connectWithGlobal: connectWithGlobal ?? _shouldConnectWithGlobal!,
      sideEffects: sideEffects,
      toDebugString: toDebugString,
      // keepAlive: keepAlive,
    );
  }

  @override
  Widget reInherited({
    Key? key,
    required BuildContext context,
    required Widget Function(BuildContext context) builder,
  }) {
    final inj =
        context.dependOnInheritedWidgetOfExactType<_InheritedInjected<T>>()!;
    return _inherited(
      key: key,
      reInheritedInject: inj.injected,
      globalInjected: inj.globalInjected,
      builder: builder,
    );
  }

  Widget _inherited({
    required Widget Function(BuildContext) builder,
    Key? key,
    FutureOr<T> Function()? stateOverride,
    Injected<T>? reInheritedInject,
    Injected<T>? globalInjected,
    bool connectWithGlobal = true,
    SideEffects<T>? sideEffects,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
    // bool keepAlive = false,
  }) {
    return MyStatefulWidget(
      key: key,
      observers: (context) {
        late InjectedImp<T> injected;
        if (stateOverride == null) {
          injected = (reInheritedInject as InjectedImp<T>?) ?? this;
        } else {
          injected = InjectedImp<T>(
            creator: () {
              try {
                return stateOverride();
              } catch (e) {
                if (e is RangeError) {
                  return injected._snapState.data;
                }
                rethrow;
              }
            },
            sideEffectsGlobal: SideEffects<T>(
              initState: () {
                sideEffects?.initState?.call();
                if (connectWithGlobal) {
                  isInitialized = true;
                  inheritedInjects.add(injected);
                  _setCombinedInheritedSnap(inheritedInjects, injected);
                }
              },
              dispose: () {
                sideEffects?.dispose?.call();
                if (injected != this) {
                  inheritedInjects.remove(injected);
                  if (autoDisposeWhenNotUsed && inheritedInjects.isEmpty) {
                    disposeIfNotUsed();
                  }
                }
                if (injected.autoDisposeWhenNotUsed) {
                  // injected.dispose();
                }
              },
              onAfterBuild: sideEffects?.onAfterBuild != null
                  ? () => sideEffects!.onAfterBuild?.call()
                  : null,
              onSetState: (snap) {
                if (_snapState._infoMessage != kRefreshMessage) {
                  if (inheritedInjects.isNotEmpty) {
                    _setCombinedInheritedSnap(inheritedInjects, injected);
                  }
                }
                sideEffects?.onSetState?.call(snap);
              },
            ),
            autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
            stateInterceptor: null,
            dependsOn: null,
            watch: null,
            initialState: _snapState.data,
            debugPrintWhenNotifiedPreMessageGlobal:
                debugPrintWhenNotifiedPreMessage,
            toDebugString: toDebugString,
          );
        }
        injected.initialize();
        return [injected];
      },
      didUpdateWidget: (context, rm, old) {
        if (stateOverride != null) {
          (rm as InjectedImp).creatorUpdatable = () {
            try {
              return stateOverride();
            } catch (e) {
              if (e is RangeError) {
                return rm._snapState.data;
              }
              rethrow;
            }
          };
          if (snapValue._infoMessage == kRefreshMessage) {
            _isInheritedDirty = true;
            rm.refresh(infoMessage: kRecomputing).onError((_, __) {});
          }
        }
      },
      builder: (context, __, rm) {
        return _InheritedInjected(
          key: key,
          injected: rm as InjectedImp<T>,
          globalInjected: globalInjected ?? this,
          context: context,
          child: Builder(builder: builder),
        );
      },
    );
  }

  @override
  T of(BuildContext context, {bool defaultToGlobal = false}) {
    final _inheritedInjected =
        context.dependOnInheritedWidgetOfExactType<_InheritedInjected<T>>();

    if (_inheritedInjected != null) {
      if (_inheritedInjected.globalInjected == this) {
        _inheritedInjected.injected.initialize();
        return _inheritedInjected.injected.snapValue.state;
      } else {
        return of(
          _inheritedInjected.context,
          defaultToGlobal: defaultToGlobal,
        );
      }
    }
    if (defaultToGlobal) {
      return snapState.state;
    }
    throw Exception(
      'No Parent InheritedWidget of type $T is found\n'
      'If you pushed to new route use reInherited method to provide the state '
      'to the new route',
    );
    // return null;
  }

  @override
  Injected<T> call(BuildContext context, {bool defaultToGlobal = false}) {
    final _inheritedInjected = context
        .getElementForInheritedWidgetOfExactType<_InheritedInjected<T>>()
        ?.widget as _InheritedInjected<T>?;

    if (_inheritedInjected != null) {
      if (_inheritedInjected.globalInjected == this) {
        return _inheritedInjected.injected;
      } else {
        return call(
          _inheritedInjected.context,
          defaultToGlobal: defaultToGlobal,
        );
      }
    }
    if (defaultToGlobal) {
      return this;
    }
    throw Exception('No InheritedWidget of type $T is found');

    // return null;
  }

  void _setCombinedInheritedSnap(
      Set<InjectedImp<T>> inheritStates, InjectedImp<T> inj) {
    bool isWaiting = false;
    SnapError? snapError;
    // SnapState<T>? oldSnap;
    SnapState<T>? newSnap;
    for (var state in inheritStates) {
      state.initialize();
      if (state.snapValue.isWaiting) {
        isWaiting = true;
        // oldSnap = state._snapState.oldSnapState;
        break;
      }
      if (state.snapValue.hasError) {
        snapError = state._snapState.snapError;
        // oldSnap = state._snapState.oldSnapState;
      }
    }

    if (isWaiting) {
      newSnap = _snapState.copyToIsWaiting(kInherited);
    }
    if (snapError != null) {
      newSnap = _snapState.copyWith(
        status: StateStatus.hasError,
        error: snapError,
        infoMessage: '',
      );
    }

    // _snapState = oldSnap?.copyWith(debugName: _snapState.debugName) ??
    //     inj._snapState.oldSnapState!.copyWith(debugName: _snapState.debugName);
    // _snapState = newSnap?.copyWith(
    //       debugName: _snapState.debugName,
    //     ) ??
    //     inj._snapState.copyWith(
    //       debugName: _snapState.debugName,
    //     );
    notify(
      nextSnap: newSnap?.copyWith(
            debugName: _snapState._debugName,
          ) ??
          inj._snapState.copyWith(
            debugName: _snapState._debugName,
          ),
    );
  }

  void _subscribeForCombinedSnap() {
    List<VoidCallback> disposers = [];
    for (var rm in dependsOn!.injected) {
      if (rm.autoDisposeWhenNotUsed) {
        // ignore: unused_result
        rm.addCleaner(rm.dispose);
      }
      final disposer = rm._addDependentObserver(
        listener: (rm) {
          if (dependsOn!.shouldNotify?.call(_snapState.data) == false) {
            return;
          }
          if (dependsOn!.debounceDelay > 0) {
            subscription?.cancel();
            _dependentDebounceTimer?.cancel();
            _dependentDebounceTimer = Timer(
              Duration(milliseconds: dependsOn!.debounceDelay),
              () {
                _setCombinedSnap();
                _dependentDebounceTimer = null;
              },
            );
            return;
          } else if (dependsOn!.throttleDelay > 0) {
            if (_dependentDebounceTimer != null) {
              return;
            }
            _dependentDebounceTimer = Timer(
              Duration(milliseconds: dependsOn!.throttleDelay),
              () {
                _dependentDebounceTimer = null;
              },
            );
          }
          _setCombinedSnap();
        },
        shouldAutoClean: rm.autoDisposeWhenNotUsed,
      );
      disposers.add(disposer);
    }
    // ignore: unused_result
    addCleaner(() {
      for (var disposer in disposers) {
        disposer();
      }
    });
  }

  void _setCombinedSnap([StackTrace? stackTrace]) {
    bool isWaiting = false;
    SnapError? snapError;
    // final cachedAddToObs = ReactiveStatelessWidget.addToObs;
    // ReactiveStatelessWidget.addToObs = null;
    for (var rm in dependsOn!.injected) {
      rm.initialize();
      if (rm.snapValue.isWaiting) {
        isWaiting = true;
        completer = Completer();
        // isInitialized = true;
        // _setState(
        //   (s) => rm.stateAsync,
        //   middleSetState: middleSetSate,
        // );
        break;
      }
      if (rm.snapValue.hasError) {
        snapError = rm._snapState.snapError;
      }
    }
    // ReactiveStatelessWidget.addToObs = cachedAddToObs;

    if (isWaiting) {
      if (_snapState.isWaiting) {
        return;
      }
      completer = Completer();
      isInitialized = true;
      notify(nextSnap: _snapState.copyToIsWaiting(kDependsOn));
    } else if (snapError != null) {
      if (completer?.isCompleted == false) {
        completer!.complete();
      }

      if (!isInitialized) {
        _snapState = _snapState.copyWith(
          status: StateStatus.hasError,
          error: snapError,
          infoMessage: '',
        );
        isInitialized = true;
        return;
      }

      setStateNullable(
        (s) {
          try {
            return mockableCreator();
          } catch (_) {
            return snapValue.data;
          }
        },
        middleSetState: (status, result) {
          subscription?.cancel();
          notify(
            nextSnap: _snapState.copyWith(
              status: StateStatus.hasError,
              error: snapError,
              infoMessage: '',
              data: status == StateStatus.hasData ? result : null,
            ),
          );
        },
        stackTrace: stackTrace,
      );
    } else {
      if (isInitialized) {
        if (completer?.isCompleted == false) {
          completer!.complete();
        }
        setStateNullable(
          (s) => mockableCreator(),
          middleSetState: middleSetState,
          stackTrace: stackTrace,
        );
      }
    }
  }

  @override
  void dispose() {
    if (!isInitialized) {
      return;
    }
    if (cachedCreatorMocks.length > 1) {
      cachedCreatorMocks.removeLast();
    }
    sideEffectsGlobal?.dispose?.call();

    assert(() {
      if (debugPrintWhenNotifiedPreMessageGlobal != null) {
        _snapState = _snapState.copyWith(
          status: StateStatus.isIdle,
          infoMessage: kDisposeMessage,
        );
        _snapState.debugPrint();
      }
      return true;
    }());
    // resetDefaultState();
    super.dispose();
  }

  @override
  bool get canRedoState => false;

  @override
  bool get canUndoState => false;

  @override
  void clearUndoStack() {}

  @override
  void redoState() {}

  @override
  void undoState() {}

  @override
  void deletePersistState() {}

  @override
  void persistState() {}
}
