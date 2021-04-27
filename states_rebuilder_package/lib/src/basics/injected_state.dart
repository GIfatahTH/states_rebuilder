part of '../rm.dart';

abstract class InjectedState<T> implements Injected<T> {
  dynamic stateCreator();
  final T? _initialState;
  final DependsOn<T>? _dependsOn;
  final int _undoStackLength;
  final bool _isLazy;

  final String? _debugPrintWhenNotifiedPreMessage;
  final String Function(T?)? _toDebugString;
  final bool _autoDisposeWhenNotUsed;
  InjectedState({
    T? initialState,
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
    bool autoDisposeWhenNotUsed = true,
  })  : _initialState = initialState,
        _dependsOn = dependsOn,
        _undoStackLength = undoStackLength,
        _isLazy = isLazy,
        _debugPrintWhenNotifiedPreMessage = debugPrintWhenNotifiedPreMessage,
        _toDebugString = toDebugString,
        _autoDisposeWhenNotUsed = autoDisposeWhenNotUsed;
  // InjectedController.future(
  //   Future<T> Function() creator, {
  //   T? initialState,
  //   DependsOn<T>? dependsOn,
  //   int undoStackLength = 0,
  //   bool isLazy = true,
  //   String? debugPrintWhenNotifiedPreMessage,
  //   String Function(T?)? toDebugString,
  //   bool autoDisposeWhenNotUsed = true,
  // })  : _creator = creator,
  //       _initialState = initialState,
  //       _dependsOn = dependsOn,
  //       _undoStackLength = undoStackLength,
  //       _isLazy = isLazy,
  //       _debugPrintWhenNotifiedPreMessage = debugPrintWhenNotifiedPreMessage,
  //       _toDebugString = toDebugString,
  //       _autoDisposeWhenNotUsed = autoDisposeWhenNotUsed;
  // InjectedController.stream(
  //   Stream<T> Function() creator, {
  //   T? initialState,
  //   DependsOn<T>? dependsOn,
  //   int undoStackLength = 0,
  //   bool isLazy = true,
  //   String? debugPrintWhenNotifiedPreMessage,
  //   String Function(T?)? toDebugString,
  //   bool autoDisposeWhenNotUsed = true,
  // })  : _creator = creator,
  //       _initialState = initialState,
  //       _dependsOn = dependsOn,
  //       _undoStackLength = undoStackLength,
  //       _isLazy = isLazy,
  //       _debugPrintWhenNotifiedPreMessage = debugPrintWhenNotifiedPreMessage,
  //       _toDebugString = toDebugString,
  //       _autoDisposeWhenNotUsed = autoDisposeWhenNotUsed;

  late Injected<T> _injected = InjectedImp(
    creator: stateCreator,
    initialState: _initialState,
    onInitialized: onInitialized,
    onSetState: onSetState,
    onWaiting: onWaiting,
    onData: onData,
    onError: onError,
    onDisposed: onDisposed,
    dependsOn: _dependsOn,
    undoStackLength: _undoStackLength,
    persist: persist,
    middleSnapState: middleSnapState,
    isLazy: _isLazy,
    debugPrintWhenNotifiedPreMessage: _debugPrintWhenNotifiedPreMessage,
    toDebugString: _toDebugString,
    autoDisposeWhenNotUsed: _autoDisposeWhenNotUsed,
  );

  @override
  InjectedImp<T> get _imp => _injected as InjectedImp<T>;
  void onInitialized(T? s) {}
  void onDisposed(T s) {}

  On<void>? get onSetState => null;
  PersistState<T> Function()? get persist => null;
  SnapState<T>? middleSnapState(MiddleSnapState<T> middleSap) {}
  void onWaiting() {}
  void onData(T s) {}
  void onError(dynamic error, StackTrace? stackTrace) {}

  @override
  SnapState<T>? _middleSnap(
    SnapState<T> s, {
    On<void>? onSetState,
    void Function(T)? onData,
    void Function(dynamic)? onError,
  }) {
    return _injected._middleSnap(
      s,
      onData: onData,
      onError: onError,
      onSetState: onSetState,
    );
  }

  @override
  bool get canRedoState => _injected.canRedoState;

  @override
  bool get canUndoState => _injected.canUndoState;

  @override
  void clearUndoStack() => _injected.clearUndoStack();

  @override
  void deletePersistState() => _injected.deletePersistState();

  @override
  void injectFutureMock(Future<T> Function() fakeCreator) =>
      _injected.injectFutureMock(fakeCreator);
  @override
  void injectMock(T Function() fakeCreator) =>
      _injected.injectMock(fakeCreator);

  @override
  void injectStreamMock(Stream<T> Function() fakeCreator) =>
      _injected.injectStreamMock(fakeCreator);

  @override
  void persistState() => _injected.persistState();

  @override
  void redoState() => _injected.redoState();

  @override
  void undoState() => _injected.undoState();

  @override
  Widget inherited({
    required Widget Function(BuildContext p1) builder,
    Key? key,
    FutureOr<T> Function()? stateOverride,
    bool connectWithGlobal = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) {
    throw UnimplementedError();
  }

  @override
  Widget reInherited({
    Key? key,
    required BuildContext context,
    required Widget Function(BuildContext p1) builder,
  }) {
    throw UnimplementedError();
  }

  @override
  Timer? get _debounceTimer => _injected._debounceTimer;
  set _debounceTimer(Timer? t) => _injected._debounceTimer = t;

  @override
  ReactiveModelBase<T> get _reactiveModelState => _injected._reactiveModelState;
  set _reactiveModelState(ReactiveModelBase<T> r) =>
      _injected._reactiveModelState = r;

  @override
  Object? get customStatus => _injected.customStatus;
  set customStatus(Object? arg) => _injected.customStatus = arg;

  @override
  String? get debugMessage => _injected.debugMessage;
  set debugMessage(String? arg) => _injected.debugMessage = arg;

  @override
  SnapState<T> get snapState => _injected.snapState;
  set snapState(SnapState<T> snap) => _injected.snapState = snap;

  @override
  T get state => _injected.state;
  set state(T s) => _injected.state = s;

  @override
  T? get _nullableState => _injected._nullableState;

  @override
  Injected<T>? call(BuildContext context, {bool defaultToGlobal = false}) {
    return _injected.call(context, defaultToGlobal: defaultToGlobal);
  }

  @override
  Future<Injected<T>> catchError(
      void Function(dynamic error, StackTrace s) onError) {
    return _injected.catchError(onError);
  }

  @override
  void dispose() {
    _injected.dispose();
  }

  @override
  dynamic get error => _injected.error;

  @override
  Future<F?> Function() future<F>(Future<F> Function(T s) future) {
    return _injected.future(future);
  }

  @override
  bool get hasData => _injected.hasData;

  @override
  bool get hasError => _injected.hasError;

  @override
  bool get hasObservers => _injected.hasObservers;

  @override
  bool get isActive => _injected.isActive;

  @override
  bool get isDone => _injected.isDone;

  @override
  bool get isIdle => _injected.isIdle;

  @override
  bool get isWaiting => _injected.isWaiting;

  @override
  void notify() {
    _injected.notify();
  }

  @override
  T? of(BuildContext context, {bool defaultToGlobal = false}) {
    return _injected.of(context, defaultToGlobal: defaultToGlobal);
  }

  @override
  void onErrorRefresher() {
    _injected.onErrorRefresher();
  }

  @override
  Future<T?> refresh() {
    return _injected.refresh();
  }

  @override
  Future<T> setState(
    Function(T s) fn, {
    void Function(T data)? onData,
    void Function(dynamic error)? onError,
    On<void>? onSetState,
    void Function()? onRebuildState,
    int debounceDelay = 0,
    int throttleDelay = 0,
    bool shouldAwait = false,
    bool skipWaiting = false,
    BuildContext? context,
  }) {
    return _injected.setState(
      fn,
      onData: onData,
      onError: onError,
      onSetState: onSetState,
      onRebuildState: onRebuildState,
      debounceDelay: debounceDelay,
      throttleDelay: throttleDelay,
      shouldAwait: shouldAwait,
      skipWaiting: skipWaiting,
      context: context,
    );
  }

  @override
  Future<T> get stateAsync => _injected.stateAsync;

  @override
  subscribeToRM(void Function(SnapState<T>? snap) fn) {
    return _injected.subscribeToRM(fn);
  }

  @override
  StreamSubscription? get subscription => _injected.subscription;

  @override
  void toggle() {
    _injected.toggle();
  }
}
