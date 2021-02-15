part of '../reactive_model.dart';

abstract class ReactiveModelState<T> with StatesRebuilder<T> {
  late ReactiveModelCore<T> _coreRM;

  //
  T? get _nullState => _coreRM._nullState;
  set _nullState(T? s) => _coreRM._nullState = s;
  T? _initialState;
  T? get _state => _coreRM._state;
  set _state(T? s) => _coreRM._state = s;
  SnapState<T> get _snapState => _coreRM._snapState;
  set _snapState(SnapState<T> snap) => _coreRM._snapState = snap;
  SnapState<T>? get _previousSnapState => _coreRM._previousSnapState;
  set _previousSnapState(SnapState<T>? snap) =>
      _coreRM._previousSnapState = snap;

  ConnectionState _initialConnectionState = ConnectionState.none;
  //
  bool get _isInitialized => _coreRM._isInitialized;
  set _isInitialized(bool isInit) => _coreRM._isInitialized = isInit;
  bool _isFirstInitialized = false;
  bool _stateIsPersisted = false;
  // bool _isDisposed = false;
  //
  final Queue<SnapState<T>> _undoQueue = ListQueue();
  final Queue<SnapState<T>> _redoQueue = ListQueue();

  StreamSubscription? _subscription;
  Timer? _debounceTimer;
  //
  final _listeners = <void Function(ReactiveModel<T> rm)>[];
  final _inheritedInjects = <Injected>{};
  //
  late dynamic Function(ReactiveModel<T> rm) _creator;
  bool _shouldPersistStateOnInit = false;

  void cloneToAndClean(ReactiveModel<T> to) {
    to._coreRM = _coreRM;
    to._nullState = _nullState;
    to._initialState = _initialState;
    to._state = _state;
    to._snapState = _snapState;
    to._previousSnapState = _previousSnapState;
    to._initialConnectionState = _initialConnectionState;
    to._isInitialized = _isInitialized;
    to._isFirstInitialized = _isFirstInitialized;
    to._undoQueue.addAll(_undoQueue);
    to._redoQueue.addAll(_redoQueue);
    to._debounceTimer = _debounceTimer;
    to._coreRM._completer = _coreRM._completer;
    to._listeners.addAll(_listeners);
    to._cleaner.addAll(_cleaner);
    to._inheritedInjects.addAll(_inheritedInjects);
    to._listenersOfStateFulWidget.addAll(_listenersOfStateFulWidget);
    to._cachedHash = (this as ReactiveModel<T>)._cachedHash;

    // _undoQueue.clear();
    // _redoQueue.clear();
    // _listeners.clear();
    // _inheritedInjects.clear();
    // _listenersOfStateFulWidget.clear();
  }

  void _cleanUpState([dynamic Function(ReactiveModel<T> rm)? creator]) {
    if (_nullState != null) {
      _state = _nullState!;
    }
    _coreRM._middleState?.call(_snapState, SnapState<T>._nothing('CLEANING'));
    _snapState = SnapState<T>._nothing('CLEANING');

    _previousSnapState = null;
    _initialConnectionState = ConnectionState.none;

    _isInitialized = false;
    _isFirstInitialized = false;

    _undoQueue.clear();
    _redoQueue.clear();
    _coreRM._completeCompleter(_state);
    _subscription?.cancel();
    _subscription = null;

    _debounceTimer?.cancel();
    _debounceTimer = null;
    //
    _listeners.clear();
    _inheritedInjects.clear();
    //
    if (creator != null) {
      if (!_stateIsPersisted) {
        _creator = creator;
      } else {
        (this as InjectedImp<T>).creator = creator;
      }
    }
    if (this is Injected) {
      (this as Injected)._dependenciesAreSet = false;
    }
  }
}
