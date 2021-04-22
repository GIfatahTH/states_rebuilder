part of '../rm.dart';

class InjectedImp<T> extends Injected<T> {
  InjectedImp({
    required dynamic Function()? creator,
    T? initialState,
    this.onInitialized,
    this.onDisposed,
    this.onSetState,
    this.onWaiting,
    this.onData,
    this.onError,
    bool isAsyncInjected = false,
    this.dependsOn,
    this.undoStackLength = 0,
    PersistState<T> Function()? persist,
    this.middleSnapState,
    bool isLazy = true,
    this.debugPrintWhenNotifiedPreMessage,
    this.toDebugString,
    this.autoDisposeWhenNotUsed = true,
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
  final bool autoDisposeWhenNotUsed;
  final void Function(T? s)? onInitialized;
  final void Function(T s)? onDisposed;
  final void Function()? onWaiting;
  final void Function(T s)? onData;
  // final On<void>? onSetState;
  final void Function(dynamic e, StackTrace? s)? onError;

  @override
  bool get isIdle => _reactiveModelState.snapState.isIdle;
  @override
  bool get isWaiting => _reactiveModelState.snapState.isWaiting;
  @override
  bool get hasData => _reactiveModelState.snapState.hasData;
  @override
  bool get isDone => _reactiveModelState.snapState.isDone;
  @override
  bool get hasError => _reactiveModelState.snapState.hasError;
  @override
  dynamic get error => _reactiveModelState.snapState.error;
  SnapState<T>? oldSnap;
  T? firstOnDataState;

  bool _isAsyncInjected;

  int undoStackLength = 0;

  DependsOn<T>? dependsOn;
  Timer? _dependentDebounceTimer;
  VoidCallback? _removeFromInjectedList;

  ///Create the state
  dynamic middleCreator(
    dynamic Function() crt,
    dynamic Function()? creatorMock,
  ) {
    final creator = creatorMock == null ? crt : creatorMock;
    final val = snapState._infoMessage == kInitMessage
        ? undoRedoPersistState?.persistedCreator()
        : null;

    if (val is Future) {
      final Function() fn = () async {
        final r = await val;
        return r ?? creator();
      };
      return fn();
    }
    return val ?? creator();
  }

  ///Initialize the state
  void initialize() {
    if (_reactiveModelState._isInitialized) {
      return;
    }
    _reactiveModelState
      .._isInitialized = true
      .._isDisposed = false;
    _removeFromInjectedList = _addToInjectedModels(this);
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
            firstOnDataState ??= snap.data;
            snap = _isAsyncInjected ? snap : snap._copyToIsIdle();
          }
          _reactiveModelState._snapState = middleSnap(snap) ?? snap;
          return null;
        }
        firstOnDataState ??= snap.data;
        return middleSnap(snap);
      },
      onDone: (snap) {
        return snap;
      },
    );

    if (dependsOn != null) {
      _setCombinedSnap(
        dependsOn!.injected.cast<InjectedImp>(),
        shouldRebuild: false,
      );
      _subscribeForCombinedSnap(dependsOn!.injected.cast<InjectedImp>());
    } else {
      _reactiveModelState._initialStateCreator!();
    }

    onInitialized?.call(_reactiveModelState._snapState.data);
  }

  @override
  Future<T?> refresh() async {
    if (_inheritedInjects.isNotEmpty) {
      snapState = snapState._copyWith(infoMessage: kRefreshMessage);
      _inheritedInjects.forEach(
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
    void Function(dynamic? error)? onError,
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
    void Function(dynamic? error)? onError,
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
        onData.call(snap.data!);
      } else {
        this.onData?.call(snap.data!);
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

    return snap;
  }

  void _subscribeForCombinedSnap(Set<InjectedImp> depends) {
    final disposers = <VoidCallback>[];
    for (var depend in dependsOn!.injected.cast<InjectedImp>()) {
      final disposer = depend._reactiveModelState.listeners.addListener(
        (_) {
          if (dependsOn!.shouldNotify?.call(_nullableState) == false) {
            return;
          }

          if (dependsOn!.debounceDelay > 0) {
            subscription?.cancel();
            _dependentDebounceTimer?.cancel();
            _dependentDebounceTimer = Timer(
              Duration(milliseconds: dependsOn!.debounceDelay),
              () {
                _setCombinedSnap(dependsOn!.injected.cast<InjectedImp>());
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

          _setCombinedSnap(dependsOn!.injected.cast<InjectedImp>());
          // _reactiveModelState._refresh(infoMessage: kRecomputing);
        },
        clean: () {
          if (depend.autoDisposeWhenNotUsed) {
            depend.dispose();
          }
        },
      );
      disposers.add(disposer);
    }
    _reactiveModelState.listeners.addCleaner(
      () => disposers.forEach((fn) => fn()),
    );
  }

  void _setCombinedSnap(Set<InjectedImp> depends, {bool shouldRebuild = true}) {
    bool isIdle = false;
    // bool isWaiting = false;

    dynamic error;
    late StackTrace stackTrace;
    late VoidCallback refresher;
    for (var depend in depends) {
      if (depend.isWaiting) {
        final snap = _reactiveModelState._snapState._copyToIsWaiting(
          data: depend.oldSnap?._infoMessage == kRefreshMessage
              ? _reactiveModelState._initialState
              : null,
          infoMessage: kDependsOn,
        );
        if (shouldRebuild) {
          _reactiveModelState._setSnapStateAndRebuild = middleSnap(snap);
        } else {
          _reactiveModelState
            .._snapState = middleSnap(snap) ?? snap
            .._setSnapStateAndRebuild = null;
        }
        return;
      }
      if (depend.hasError) {
        error = depend.error;
        stackTrace = depend._reactiveModelState._snapState.stackTrace!;
        refresher = depend._reactiveModelState._snapState.onErrorRefresher!;
      }

      if (depend.isIdle) {
        isIdle = true;
      }
    }

    if (error != null) {
      final snap = _reactiveModelState._snapState.copyToHasError(
        error,
        stackTrace: stackTrace,
        onErrorRefresher: refresher,
      );
      if (shouldRebuild) {
        _reactiveModelState._setSnapStateAndRebuild = middleSnap(snap);
      } else {
        _reactiveModelState
          .._snapState = middleSnap(snap) ?? snap
          .._setSnapStateAndRebuild = null;
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
  Future<F?> Function() future<F>(Future<F> Function(T s) future) {
    return () async {
      late F data;
      await future(state).then((d) {
        if (d is T) {
          snapState = snapState.copyToHasData(d);
          onSetState?.call(snapState);
          onData?.call(state);
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
      onDisposed?.call(state);
      if (cachedCreatorMocks.length > 1) {
        cachedCreatorMocks.removeLast();
      }
      undoRedoPersistState?.clearUndoStack();
      undoRedoPersistState?.persistOnDispose(state);
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
      _removeFromInjectedList?.call();
      super.dispose();
    }
  }

  List<dynamic Function()?> cachedCreatorMocks = [null];

  void _injectMock(dynamic Function() fakeCreator) {
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
    _reactiveModelState._setSnapStateAndRebuild =
        undoRedoPersistState?.undoState();
  }

  @override
  void redoState() {
    _reactiveModelState._setSnapStateAndRebuild =
        undoRedoPersistState?.redoState();
  }

  @override
  void clearUndoStack() {
    undoRedoPersistState?.clearUndoStack();
  }

  @override
  bool get canRedoState {
    return undoRedoPersistState?.canRedoState ?? false;
  }

  @override
  bool get canUndoState {
    return undoRedoPersistState?.canUndoState ?? false;
  }

  @override
  void persistState() {
    undoRedoPersistState?.persistanceProvider?.write(state);
  }

  @override
  void deletePersistState() {
    undoRedoPersistState?.deleteState(this);
  }

  @override
  String toString() {
    return 'Injected($snapState)';
  }

  final _inheritedInjects = <Injected<T>>{};

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
            ?.widget as _InheritedInjected<T>)
        .globalInjected;
    return _inherited(
      key: key ?? Key('$context'),
      builder: builder,
      globalInjected: globalInjected,
      reInheritedInject: globalInjected(context),
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
        globalInjected ??= this;
        late Injected<T> injected;
        late VoidCallback disposer;

        if (stateOverride == null) {
          injected = reInheritedInject ?? this;
        } else {
          injected = InjectedImp<T>(
            creator: () {
              final s = stateOverride();
              return s;
            },
            // initialState: state,
            onInitialized: (_) {
              if (connectWithGlobal) {
                _reactiveModelState._isInitialized = true;
                _inheritedInjects.add(injected);
                _setCombinedInheritedSnap(
                  _inheritedInjects.cast<InjectedImp<T>>(),
                  injected as InjectedImp<T>,
                );
              }
            },
            debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
            toDebugString: toDebugString,
          );
        }
        return LifeCycleHooks<NullWidget>(
          mountedState: (context) {
            disposer = injected._reactiveModelState.listeners.addListener(
              (snap) {
                if (snapState._infoMessage == kRefreshMessage) {
                  setState();
                  return;
                }
                print(snapState);
                if (_inheritedInjects.isNotEmpty) {
                  _setCombinedInheritedSnap(
                    _inheritedInjects.cast<InjectedImp<T>>(),
                    injected as InjectedImp<T>,
                  );
                }
                setState();
              },
              clean: () {
                if (!hasObservers) {
                  dispose();
                }
              },
            );
          },
          dispose: (context) {
            if (reInheritedInject == null) {
              disposer();
              _inheritedInjects.remove(injected);
            }
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
      Set<InjectedImp<T>> inheritStates, InjectedImp<T> inj) {
    bool isWaiting = false;

    dynamic error;
    late StackTrace stackTrace;
    late VoidCallback refresher;
    SnapState<T>? oldSnap;
    SnapState<T>? newSnap;
    for (var state in inheritStates) {
      if (state.isWaiting) {
        isWaiting = true;
        oldSnap = state.oldSnap;
        break;
      }
      if (state.hasError) {
        error = state.error;
        stackTrace = state._reactiveModelState._snapState.stackTrace!;
        refresher = state._reactiveModelState._snapState.onErrorRefresher!;
        oldSnap = state.oldSnap;
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

    snapState = oldSnap ?? inj.oldSnap!;
    _reactiveModelState._setSnapStateAndRebuild =
        middleSnap(newSnap ?? inj.snapState);
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
