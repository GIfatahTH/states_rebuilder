part of '../rm.dart';

///A lightweight version of InjectedImp
class ReactiveModel<T> extends Injected<T> {
  final Function() creator;
  factory ReactiveModel.create(T state) {
    return ReactiveModel(creator: () => state, initialState: state);
  }

  factory ReactiveModel.future(
    Future<T> Function() creator, {
    T? initialState,
  }) {
    return ReactiveModel(creator: creator, initialState: initialState);
  }
  factory ReactiveModel.stream(
    Stream<T> Function() creator, {
    T? initialState,
  }) {
    return ReactiveModel(creator: creator, initialState: initialState);
  }
  ReactiveModel({
    required this.creator,
    T? initialState,
  }) {
    _reactiveModelState = ReactiveModelBase<T>(
      creator: creator,
      initialState: initialState,
      initializer: () {
        if (_reactiveModelState._isInitialized) {
          return;
        }
        _reactiveModelState
          .._isInitialized = true
          .._isDisposed = false
          .._snapState = SnapState._nothing(
            _reactiveModelState._initialState,
            kInitMessage,
            _reactiveModelState.debugPrintWhenNotifiedPreMessage,
          );

        _reactiveModelState._setInitialStateCreator(
          middleCreator: (crt) {
            return crt();
          },
          middleState: (snap) {
            if (snap.isWaiting) {
              if (snapState._infoMessage == kRefreshMessage) {
                return snap._copyWith(data: _reactiveModelState._initialState);
              } else {
                _reactiveModelState._snapState = snap;
                return null;
              }
            }

            // _reactiveModelState._initialState ??= snap.data;

            if (snapState._infoMessage == kInitMessage) {
              snap = snap._copyToIsIdle();
              _reactiveModelState._snapState = snap;
              return null; //Return null so do not rebuild
            }
            return snapState._infoMessage == kRefreshMessage
                ? snap._copyToIsIdle(
                    /*data: _reactiveModelState._initialState*/)
                : snap;
          },
          onDone: (snap) {
            return snap;
          },
        );
        _reactiveModelState._initialStateCreator!();
      },
    );
    _reactiveModelState.initializer();
  }

  T? get initialState => _reactiveModelState._initialState;
  ReactiveModelBase<T> get reactiveModelState => _reactiveModelState;
  SnapState<T>? middleSnap(SnapState<T> snap) {}

  @override
  SnapState<T>? _middleSnap(
    SnapState<T> snap, {
    On<void>? onSetState,
    void Function(T data)? onData,
    void Function(dynamic? error)? onError,
  }) {
    snap = middleSnap(snap) ?? snap;
    if (snap.isWaiting) {
      if (snapState.isWaiting) {
        return null;
      }
      onSetState?.call(snap);
      return snap;
    }
    if (snap.hasError) {
      if (snap.error == snapState.error) {
        return null;
      }
      onSetState?.call(snap);
      onError?.call(snap.error);
      return snap;
    }

    if (snap.hasData) {
      if (snap._isImmutable == true && snap == snapState) {
        return null;
      }
      onSetState?.call(snap);
      onData?.call(snap.data!);
    }
    return snap;
  }

  ConnectionState get connectionState =>
      _reactiveModelState._snapState._connectionState;

  VoidCallback observeForRebuild(void Function(ReactiveModel<T>? rm) fn) {
    return _reactiveModelState.listeners.addListener((_) => fn(this));
  }

  void addCleaner(VoidCallback fn) {
    _reactiveModelState.listeners.addCleaner(fn);
  }

  ///Exhaustively switch over all the possible statuses of [connectionState].
  ///Used mostly to return [Widget]s.
  R whenConnectionState<R>({
    required R Function() onIdle,
    required R Function() onWaiting,
    required R Function(T snapState) onData,
    required R Function(dynamic? error) onError,
    bool catchError = true,
  }) {
    if (isIdle) {
      return onIdle.call();
    }
    if (hasError) {
      return onError.call(error);
    }
    if (isWaiting) {
      return onWaiting.call();
    }
    return onData.call(state);
  }

  @override
  bool get canRedoState => false;

  @override
  bool get canUndoState => false;

  @override
  void clearUndoStack() {}

  @override
  void deletePersistState() {}

  @override
  void injectFutureMock(Future<T> Function() fakeCreator) {}

  @override
  void injectMock(T Function() fakeCreator) {}

  @override
  void injectStreamMock(Stream<T> Function() fakeCreator) {}

  @override
  void persistState() {}

  @override
  void redoState() {}

  @override
  void undoState() {}

  @override
  Widget inherited({
    required Widget Function(BuildContext) builder,
    Key? key,
    FutureOr<T> Function()? stateOverride,
    bool connectWithGlobal = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) {
    throw UnimplementedError();
  }

  @override
  reInherited({
    Key? key,
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) {
    throw UnimplementedError();
  }

  int get observerLength => _reactiveModelState.listeners.observerLength;
}

extension ReactiveModelX<T> on ReactiveModel<T> {
  void setReactiveModelState(ReactiveModelBase<T> rm) {
    _reactiveModelState = rm;
  }
}
