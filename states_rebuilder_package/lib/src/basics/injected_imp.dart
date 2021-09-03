part of '../rm.dart';

class InjectedImp<T> extends Injected<T> {
  InjectedImp({
    required dynamic Function()? creator,
    T? initialState,
    this.onInitialized,
    this.onDisposed,
    this.onSetState,
    this.onWaiting,
    this.onDataForSideEffect,
    this.onError,
    bool isAsyncInjected = false,
    this.dependsOn,
    this.undoStackLength = 0,
    PersistState<T> Function()? persist,
    this.middleSnapState,
    bool isLazy = true,
    this.debugPrintWhenNotifiedPreMessage,
    this.toDebugString,
    bool autoDisposeWhenNotUsed = true,
  }) : _isAsyncInjected = isAsyncInjected {
    if (undoStackLength > 0 || persist != null) {
      undoRedoPersistState = UndoRedoPersistState(
        undoStackLength: undoStackLength,
        persistanceProvider: persist?.call(),
      );
    }

    if (creator != null) {
      //if creator is null, it must be defined latter before initializing
      _reactiveModelState = ReactiveModelBase<T>(
        creator: creator,
        initialState: initialState,
        initializer: initialize,
        autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
        debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      );
      if (!isLazy) {
        initialize();
      }
    }
  }
  ReactiveModelBase<T> get reactiveModelState => _reactiveModelState;
  set reactiveModelState(ReactiveModelBase<T> rm) => _reactiveModelState = rm;
  UndoRedoPersistState<T>? undoRedoPersistState;

  final SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState;
  final On<void>? onSetState;
  final String? debugPrintWhenNotifiedPreMessage;
  final String Function(T?)? toDebugString;

  void Function(T? s)? onInitialized;
  final void Function(T s)? onDisposed;
  final void Function()? onWaiting;
  final void Function(T s)? onDataForSideEffect;
  // final On<void>? onSetState;
  final void Function(dynamic e, StackTrace? s)? onError;

  @override
  bool get isIdle {
    OnReactiveState.addToObs?.call(this);
    return _reactiveModelState.snapState.isIdle;
  }

  @override
  bool get isWaiting {
    OnReactiveState.addToObs?.call(this);
    return _reactiveModelState.snapState.isWaiting;
  }

  @override
  bool get hasData {
    OnReactiveState.addToObs?.call(this);
    return _reactiveModelState.snapState.hasData;
  }

  @override
  bool get isDone {
    OnReactiveState.addToObs?.call(this);
    return _reactiveModelState.snapState.isDone;
  }

  @override
  bool get hasError {
    OnReactiveState.addToObs?.call(this);
    return _reactiveModelState.snapState.hasError;
  }

  @override
  dynamic get error {
    OnReactiveState.addToObs?.call(this);
    return _reactiveModelState.snapState.error;
  }

  SnapState<T>? oldSnap;

  bool _isAsyncInjected;

  int undoStackLength = 0;

  DependsOn<T>? dependsOn;
  Timer? _dependentDebounceTimer;

  ///Create the state
  dynamic middleCreator(
    dynamic Function() crt,
    dynamic Function()? creatorMock,
  ) {
    final creator = creatorMock == null ? crt : creatorMock;
    if (undoRedoPersistState?.persistanceProvider != null) {
      final val = snapState._infoMessage == kInitMessage
          ? undoRedoPersistState!.persistedCreator()
          : null;

      dynamic recreate(T? val) {
        final shouldRecreate =
            undoRedoPersistState!.persistanceProvider!.shouldRecreateTheState;
        if (shouldRecreate == true ||
            (shouldRecreate == null && creator is Stream Function())) {
          if (val != null) {
            _reactiveModelState._initialState = val;
            //See issue 192
            final old = onInitialized;
            onInitialized = (_) {
              //Force hasData flag to be true.
              _reactiveModelState._snapState =
                  _reactiveModelState._snapState._copyToHasData(val);
              old?.call(_);
            };
          }
          return creator();
        }

        return val ?? creator();
      }

      if (val is Future) {
        final Function() fn = () async {
          final r = await val;
          return recreate(r);
        };
        return fn();
      }
      return recreate(val);
    }

    return creator();
  }

  ///Initialize the state
  void initialize() {
    if (_reactiveModelState._isInitialized) {
      return;
    }
    final cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = null;
    _reactiveModelState._isInitialized = true;
    final creatorMock = cachedCreatorMocks.last;
    bool isInitializing = true;

    _reactiveModelState._setInitialStateCreator(
      middleCreator: (crt) {
        isInitializing = true;
        return middleCreator(crt, creatorMock);
      },
      middleState: (snap) {
        if (isInitializing) {
          isInitializing = false;
          if (snapState._infoMessage == kRecomputing) {
            return middleSnap(snap);
          }

          if (snapState._infoMessage == kRefreshMessage) {
            return middleSnap(
              snap.hasData
                  ? snap._copyToIsIdle()
                  : snap.copyWith(data: _reactiveModelState._initialState),
            );
          } else if (snapState._infoMessage != kInitMessage) {
            return middleSnap(snap);
          }
          if (snap.hasData) {
            snap =
                _isAsyncInjected ? snap : snap._copyToIsIdle(isActive: false);
          }
          _reactiveModelState._snapState = middleSnap(snap) ?? snap;
          return null;
        }
        return middleSnap(snap);
      },
      onDone: (snap) {
        return snap;
      },
    );

    if (dependsOn != null) {
      _setCombinedSnap(
        dependsOn!.injected,
        shouldRebuild: false,
      );

      _subscribeForCombinedSnap(dependsOn!.injected);
      // if (hasObservers) {
      // } else {
      //   _reactiveModelState.listeners.onFirstListerAdded = () {
      //     _subscribeForCombinedSnap(dependsOn!.injected);
      //   };
      // }
    } else {
      _reactiveModelState._initialStateCreator!();
    }
    if (_reactiveModelState._isDisposed) {
      _reactiveModelState._isDisposed = false;
      onInitialized?.call(_reactiveModelState._snapState.data);
    }
    OnReactiveState.addToObs = cachedAddToObs;
  }

  @override
  Future<T?> refresh() async {
    if (inheritedInjects.isNotEmpty) {
      snapState = snapState._copyWith(infoMessage: kRefreshMessage);
      inheritedInjects.forEach(
        (e) => e._reactiveModelState._refresh(
          infoMessage: kRecomputing,
        ),
      );
      snapState = snapState._copyWith(infoMessage: '');
      return snapState.data;
    }

    return super.refresh();
  }

  @override
  toggle() {
    super.toggle();
    undoRedoPersistState?.call(snapState, this);
  }

  @override
  SnapState<T>? _middleSnap(
    SnapState<T> s, {
    On<void>? onSetState,
    void Function(T data)? onData,
    void Function(dynamic error)? onError,
  }) =>
      middleSnap(
        s,
        onSetState: onSetState,
        onData: onData,
        onError: onError,
      );
  SnapState<T>? middleSnap(
    SnapState<T> s, {
    On<void>? onSetState,
    void Function(T data)? onData,
    void Function(dynamic error)? onError,
  }) {
    final middleSnap = MiddleSnapState(snapState, s);
    final snap = middleSnapState?.call(middleSnap) ?? s;
    if (snap is SkipSnapState) {
      return null;
    }
    oldSnap = snapState;
    if (snap.isWaiting) {
      if (snapState.isWaiting) {
        return null;
      }
      _reactiveModelState._snapState = snap;
      if (onSetState != null && onSetState._hasOnWaiting) {
        onSetState.call(snap);
      } else {
        this.onSetState?.call(snap);
      }
      onWaiting?.call();
    } else if (snap.hasError) {
      if (snap.error == snapState.error) {
        return null;
      }
      _reactiveModelState._snapState = snap;
      if (onSetState != null && onSetState._hasOnError) {
        onSetState.call(snap);
      } else {
        this.onSetState?.call(snap);
      }

      if (onError != null) {
        onError.call(snap.error);
      } else {
        this.onError?.call(snap.error, snap.stackTrace);
      }
    } else if (snap.hasData) {
      if (snap._isImmutable == true && snap == snapState) {
        return null;
      }
      _reactiveModelState._snapState = snap;
      if (onSetState != null && onSetState._hasOnData) {
        onSetState.call(snap);
      } else {
        this.onSetState?.call(snap);
      }

      if (onData != null) {
        onData.call(snap.data as T);
      } else {
        this.onDataForSideEffect?.call(snap.data as T);
      }
      undoRedoPersistState?.call(snap, this);
    } else if (snap.isIdle) {
      undoRedoPersistState?.call(snap, this);
    }

    assert(() {
      if (toDebugString != null) {
        MiddleSnapState(oldSnap!, snap).print(
          stateToString: toDebugString,
          preMessage: debugPrintWhenNotifiedPreMessage!,
        );
      } else if (debugPrintWhenNotifiedPreMessage != null) {
        MiddleSnapState(oldSnap!, snap)
            .print(preMessage: debugPrintWhenNotifiedPreMessage!);
      }

      return true;
    }());
    if (_reactiveModelState._removeFromInjectedList == null && !snap.isIdle) {
      _reactiveModelState._removeFromInjectedList = addToInjectedModels(this);
    }

    return snap;
  }

  final _dependentDisposers = <VoidCallback>[];

  void _subscribeForCombinedSnap(Set<Injected> depends) {
    for (var depend in dependsOn!.injected) {
      final fn = (_) {
        if (dependsOn!.shouldNotify?.call(_nullableState) == false) {
          return;
        }

        if (dependsOn!.debounceDelay > 0) {
          subscription?.cancel();
          _dependentDebounceTimer?.cancel();
          _dependentDebounceTimer = Timer(
            Duration(milliseconds: dependsOn!.debounceDelay),
            () {
              _setCombinedSnap(dependsOn!.injected);
              // _reactiveModelState._refresh(infoMessage: kRecomputing);
              _dependentDebounceTimer = null;
            },
          );
          return null;
        } else if (dependsOn!.throttleDelay > 0) {
          if (_dependentDebounceTimer != null) {
            return null;
          }
          _dependentDebounceTimer = Timer(
            Duration(milliseconds: dependsOn!.throttleDelay),
            () {
              _dependentDebounceTimer = null;
            },
          );
        }

        _setCombinedSnap(dependsOn!.injected);
        // _reactiveModelState._refresh(infoMessage: kRecomputing);
      };

      void addListenerForRebuild() {
        final disposer =
            depend._reactiveModelState.listeners.addListenerForRebuild(
          fn,
          clean: () {
            depend.dispose();
          },
        );
        _dependentDisposers.add(disposer);
      }

      // if (!hasObservers) {

      final disposer =
          depend._reactiveModelState.listeners.addListenerForSideEffect(
        fn,
        clean: () {
          depend.dispose();
        },
      );
      _reactiveModelState.listeners.onFirstListerAdded = () {
        _reactiveModelState.listeners._sideEffectListeners.remove(fn);
        _dependentDisposers.remove(disposer);
        addListenerForRebuild();
      };
      depend._reactiveModelState.listeners.addCleaner(() {
        if (!hasObservers && _imp.autoDisposeWhenNotUsed) {
          dispose();
        }
      });
      _dependentDisposers.add(disposer);
      // } else {
      //   addListenerForRebuild();
      // }
    }
  }

  void _setCombinedSnap(Set<Injected> depends, {bool shouldRebuild = true}) {
    bool isIdle = false;
    // bool isWaiting = false;

    dynamic error;
    late StackTrace stackTrace;
    late VoidCallback refresher;

    for (var depend in depends) {
      //Use _reactiveModelState.snapState.isWaiting instead of depend.isWaiting
      //to avoid dependent state to subscribe to OnReactive
      if (depend._reactiveModelState.snapState.isWaiting) {
        final snap = _reactiveModelState._snapState._copyToIsWaiting(
          data: depend._imp.oldSnap?._infoMessage == kRefreshMessage
              ? _reactiveModelState._initialState
              : null,
          infoMessage: kDependsOn,
        );
        if (shouldRebuild) {
          _reactiveModelState.setSnapStateAndRebuild = middleSnap(snap);
        } else {
          _reactiveModelState
            .._snapState = middleSnap(snap) ?? snap
            ..setSnapStateAndRebuild = null;
        }
        return;
      }
      if (depend._reactiveModelState.snapState.hasError) {
        error = depend._reactiveModelState.snapState.error;
        stackTrace = depend._reactiveModelState._snapState.stackTrace!;
        refresher = depend._reactiveModelState._snapState.onErrorRefresher!;
      }

      if (depend._reactiveModelState.snapState.isIdle) {
        isIdle = true;
      }
    }

    if (error != null) {
      final snap = _reactiveModelState._snapState._copyToHasError(
        error,
        refresher,
        stackTrace: stackTrace,
      );
      if (shouldRebuild) {
        _reactiveModelState.setSnapStateAndRebuild = middleSnap(snap);
      } else {
        _reactiveModelState
          .._snapState = middleSnap(snap) ?? snap
          ..setSnapStateAndRebuild = null;
      }

      return;
    }

    if (isIdle) {
      _reactiveModelState._refresh(
        infoMessage: shouldRebuild ? kRecomputing : kInitMessage,
      );
      return;
    }

    _reactiveModelState._refresh(infoMessage: kRecomputing);
  }

  @override
  Future<F> Function() future<F>(Future<F> Function(T s) future) {
    return () async {
      late F data;
      await future(_state).then((d) {
        if (d is T) {
          snapState = snapState.copyToHasData(d);
          onSetState?.call(snapState);
          onDataForSideEffect?.call(_state);
        }
        data = d;
      }).catchError((e, StackTrace s) {
        snapState = snapState._copyToHasError(
          e,
          () => this.future(future),
          stackTrace: s,
        );
        onSetState?.call(snapState);
        onError?.call(e, s);
        throw e;
      });
      return data;
    };
  }

  @override
  void dispose() {
    if (!_reactiveModelState._isDisposed) {
      onDisposed?.call(_state);
      if (cachedCreatorMocks.length > 1) {
        cachedCreatorMocks.removeLast();
      }
      undoRedoPersistState?.clearUndoStack();
      undoRedoPersistState?.persistOnDispose(_state);
      final middleSnap = MiddleSnapState(
        snapState,
        SnapState._nothing(
          snapState.data,
          kDisposeMessage,
          debugPrintWhenNotifiedPreMessage,
        ),
      );
      middleSnapState?.call(middleSnap);

      assert(
        () {
          if (toDebugString != null) {
            middleSnap.print(
              stateToString: toDebugString,
              preMessage: debugPrintWhenNotifiedPreMessage!,
            );
          } else if (debugPrintWhenNotifiedPreMessage != null) {
            middleSnap.print(preMessage: debugPrintWhenNotifiedPreMessage!);
          }
          return true;
        }(),
      );
      if (dependsOn != null) {
        _dependentDisposers.forEach((e) => e());
      }
      _reactiveModelState._removeFromInjectedList?.call();
      _reactiveModelState._removeFromInjectedList = null;

      super.dispose();
    }
  }

  List<dynamic Function()?> cachedCreatorMocks = [null];

  void _injectMock(dynamic Function() fakeCreator) {
    dispose();
    RM.disposeAll();
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
  void undoState() {
    _reactiveModelState.setSnapStateAndRebuild =
        undoRedoPersistState?.undoState();
  }

  @override
  void redoState() {
    _reactiveModelState.setSnapStateAndRebuild =
        undoRedoPersistState?.redoState();
  }

  @override
  void clearUndoStack() {
    undoRedoPersistState?.clearUndoStack();
  }

  @override
  bool get canRedoState {
    OnReactiveState.addToObs?.call(this);
    return undoRedoPersistState?.canRedoState ?? false;
  }

  @override
  bool get canUndoState {
    OnReactiveState.addToObs?.call(this);
    return undoRedoPersistState?.canUndoState ?? false;
  }

  @override
  void persistState() {
    undoRedoPersistState?.persistanceProvider?.write(_state);
  }

  @override
  void deletePersistState() {
    undoRedoPersistState?.deleteState(this);
  }

  @override
  String toString() {
    return 'Injected#$hashCode($snapState)';
  }

  final inheritedInjects = <Injected<T>>{};

  @override
  Widget inherited({
    required Widget Function(BuildContext) builder,
    Key? key,
    FutureOr<T> Function()? stateOverride,
    bool connectWithGlobal = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) =>
      _inherited(
        builder: builder,
        key: key,
        stateOverride: stateOverride,
        connectWithGlobal: connectWithGlobal,
        debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
        toDebugString: toDebugString,
      );

  @override
  Widget reInherited({
    Key? key,
    required BuildContext context,
    required Widget Function(BuildContext) builder,
  }) {
    final globalInjected = (context
            .getElementForInheritedWidgetOfExactType<_InheritedInjected<T>>()
            ?.widget as _InheritedInjected<T>?)
        ?.globalInjected;
    assert(globalInjected != null,
        'The provided BuildContext has no Inherited state ancestor');
    return _inherited(
      key: key ?? Key('$context'),
      builder: builder,
      globalInjected: globalInjected,
      reInheritedInject: globalInjected!(context),
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );
  }

  Widget _inherited({
    required Widget Function(BuildContext) builder,
    Key? key,
    FutureOr<T> Function()? stateOverride,
    Injected<T>? reInheritedInject,
    Injected<T>? globalInjected,
    bool connectWithGlobal = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) {
    return StateBuilderBase(
      (widget, setState) {
        //Not always globalInjected == this
        globalInjected ??= this;
        late Injected<T> injected;
        late VoidCallback disposer;

        if (stateOverride == null) {
          injected = reInheritedInject ?? this;
        } else {
          injected = InjectedImp<T>(
            creator: stateOverride,
            // initialState: state,
            onInitialized: (_) {
              if (connectWithGlobal) {
                _reactiveModelState
                  .._isInitialized = true
                  .._isDisposed = false;
                inheritedInjects.add(injected);
                _setCombinedInheritedSnap(inheritedInjects, injected);
              }
            },
            debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
            toDebugString: toDebugString,
          );
        }
        return LifeCycleHooks<NullWidget>(
          mountedState: (context) {
            disposer =
                injected._reactiveModelState.listeners.addListenerForRebuild(
              (snap) {
                if (snapState._infoMessage == kRefreshMessage) {
                  setState();
                  return;
                }
                if (inheritedInjects.isNotEmpty) {
                  _setCombinedInheritedSnap(inheritedInjects, injected);
                }
                setState();
              },
              clean: () {
                if (injected != this) {
                  if (autoDisposeWhenNotUsed && !hasObservers) {
                    dispose();
                  }
                  inheritedInjects.remove(injected);
                }
                if (injected.autoDisposeWhenNotUsed) {
                  injected.dispose();
                }
              },
            );
          },
          dispose: (context) {
            // if (injected != this) {
            //   print(inheritedInjects);
            //   inheritedInjects.remove(injected);
            //   print(inheritedInjects);
            // }
            disposer();
          },
          builder: (context, widget) {
            return _InheritedInjected(
              injected: injected,
              globalInjected: globalInjected!,
              context: context,
              child: Builder(builder: (context) => builder(context)),
            );
          },
        );
      },
      key: key,
      widget: NullWidget(
        injects: [],
      ),
    );
  }

  void _setCombinedInheritedSnap(
      Set<Injected<T>> inheritStates, Injected<T> inj) {
    bool isWaiting = false;

    dynamic error;
    late StackTrace stackTrace;
    late VoidCallback refresher;
    SnapState<T>? oldSnap;
    SnapState<T>? newSnap;
    final cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = null;
    for (var state in inheritStates) {
      if (state.isWaiting) {
        isWaiting = true;
        oldSnap = state._imp.oldSnap;
        break;
      }
      if (state.hasError) {
        error = state.error;
        stackTrace = state._reactiveModelState._snapState.stackTrace!;
        refresher = state._reactiveModelState._snapState.onErrorRefresher!;
        oldSnap = state._imp.oldSnap;
      }
    }

    if (isWaiting) {
      newSnap = _reactiveModelState._snapState
          ._copyToIsWaiting(infoMessage: kInherited);
    }
    if (error != null) {
      newSnap = _reactiveModelState._snapState.copyToHasError(
        error,
        stackTrace: stackTrace,
        onErrorRefresher: refresher,
      );
    }

    snapState = oldSnap?._copyWith(
          debugPrintWhenNotifiedPreMessage:
              snapState._debugPrintWhenNotifiedPreMessage,
        ) ??
        inj._imp.oldSnap!._copyWith(
          debugPrintWhenNotifiedPreMessage:
              snapState._debugPrintWhenNotifiedPreMessage,
        );
    _reactiveModelState.setSnapStateAndRebuild = middleSnap(
      newSnap?._copyWith(
            debugPrintWhenNotifiedPreMessage:
                snapState._debugPrintWhenNotifiedPreMessage,
          ) ??
          inj.snapState._copyWith(
            debugPrintWhenNotifiedPreMessage:
                snapState._debugPrintWhenNotifiedPreMessage,
          ),
    );
    OnReactiveState.addToObs = cachedAddToObs;
  }
}

class _InheritedInjected<T> extends InheritedWidget {
  const _InheritedInjected({
    Key? key,
    required Widget child,
    required this.injected,
    required this.globalInjected,
    required this.context,
  }) : super(key: key, child: child);
  final Injected<T> injected;
  final Injected<T> globalInjected;
  final BuildContext context;

  @override
  bool updateShouldNotify(_InheritedInjected _) {
    return true;
  }
}
