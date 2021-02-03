part of '../reactive_model.dart';

abstract class RM {
  ///Functional injection of a primitive, enum or object.
  ///
  ///* **Required parameters:**
  ///  * **creator**:  (positional parameter) a callback that
  /// creates an instance of the injected object
  /// {@template injectOptionalParameter}
  /// * **Optional parameters:**
  ///   * **initialState**: Initial state. If not defined, it will be inferred.
  /// (int: 0, double: 0.0, String: '', bool: false, Other objects: The first
  /// created instance)
  ///   * **onInitialized**: Callback to be executed after the injected model
  /// is first created.
  ///   * **onDisposed**: Callback to be executed after the injected model is
  /// removed.
  ///   * **onWaiting**: Callback to be executed each time the [ReactiveModel]
  /// associated with the injected model is in the awaiting state.
  ///   * **onData**: Callback to be executed each time the [ReactiveModel]
  /// associated with the injected model emits a notification with data.
  ///   * **onError**: Callback to be executed each time the [ReactiveModel]
  /// associated with the injected model emits a notification with error.
  ///   * **dependsOn**: The other [Injected] models this Injected depends on.
  /// It takes an instance of [DependsOn] object.
  ///   * **undoStackLength**: the length of the undo/redo stack. If not
  /// defined, the undo/redo is disabled.
  ///   * **persist**: If defined the state of this Injected will be persisted.
  /// It takes A callback that returns an instance of [PersistState].
  ///   * **autoDisposeWhenNotUsed**: Whether to auto dispose the injected
  /// model when no longer used (listened to).
  /// The default value is true.
  ///   * **isLazy**: By default models are lazily injected; that is not
  /// instantiated until first used.
  ///   * **debugPrintWhenNotifiedPreMessage**: if not null, print an
  /// informative message when this model is notified in the debug mode. The
  /// entered message will pré-append the debug message. Useful if the type of
  /// the injected model is primitive to distinguish
  /// {@endtemplate}
  static Injected<T> inject<T>(
    T Function() creator, {
    T? initialState,
    void Function(T s)? onInitialized,
    void Function(T s)? onDisposed,
    void Function()? onWaiting,
    void Function(T s)? onData,
    On<void>? onSetState,
    void Function(dynamic e, StackTrace? s)? onError,
    //
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not be inferred, please declare it explicitly',
    );

    return InjectedImp<T>(
      creator: (_) => creator(),
      nullState: initialState,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      onWaiting: onWaiting,
      onData: onData,
      onError: onError,
      on: onSetState,
      //
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      //
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  ///Functional injection of a [Future].
  ///
  ///* **Required parameters:**
  ///  * [creator]:  (positional parameter) a callback that return a [Future].
  /// {@macro injectOptionalParameter}
  static Injected<T> injectFuture<T>(
    Future<T> Function() creator, {
    T? initialState,
    void Function(T s)? onInitialized,
    void Function(T s)? onDisposed,
    void Function()? onWaiting,
    void Function(T s)? onData,
    void Function(dynamic e, StackTrace? s)? onError,
    On<void>? onSetState,

    //
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not inferred, please declare it explicitly',
    );
    return InjectedImp<T>(
      creator: (_) => creator(),
      initialValue: initialState,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      onWaiting: onWaiting,
      onData: onData,
      onError: onError,
      on: onSetState,
      //
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      //
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  ///Functional injection of a [Stream].
  ///
  ///* **Required parameters:**
  ///  * [creator]:  (positional parameter) a callback that return a [Stream].
  /// {@macro injectOptionalParameter}
  ///   * **watch**: Object to watch its change, and do not notify listener if
  /// not changed after the stream emits data.
  static Injected<T> injectStream<T>(
    Stream<T> Function() creator, {
    T? initialState,
    void Function(T s, StreamSubscription subscription)? onInitialized,
    void Function(T s)? onDisposed,
    void Function()? onWaiting,
    void Function(T s)? onData,
    void Function(dynamic e, StackTrace? s)? onError,
    On<void>? onSetState,

    //
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    //
    Object? Function(T? s)? watch,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not inferred, please declare it explicitly',
    );
    InjectedImp<T>? inj;
    inj = InjectedImp<T>(
      creator: (_) => creator(),
      initialValue: initialState,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      on: onSetState,
      onInitialized: onInitialized != null
          ? (s) => onInitialized(s, inj!.subscription!)
          : null,
      onDisposed: onDisposed,
      watch: watch,
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      isLazy: isLazy,
    );
    return inj;
  }

  ///Functional injection of flavors (environments).
  ///
  ///* Required parameters:
  ///  * [impl]:  (positional parameter) Map of the implementations of the interface.
  /// * optional parameters:
  /// {@macro injectOptionalParameter}
  static Injected<T> injectFlavor<T>(
    Map<dynamic, FutureOr<T> Function()> impl, {
    T? initialState,
    void Function(T s)? onInitialized,
    void Function(T s)? onDisposed,
    void Function()? onWaiting,
    void Function(T s)? onData,
    void Function(dynamic e, StackTrace? s)? onError,
    On<void>? onSetState,

    //
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not inferred, please declare it explicitly',
    );
    return InjectedImp<T>(
      creator: (_) {
        assert(RM.env != null, '''
You are using [Inject.interface] constructor. You have to define the [Inject.env] before the [runApp] method
    ''');
        assert(impl[env] != null, '''
There is no implementation for $env of $T interface
    ''');
        _envMapLength ??= impl.length;
        assert(impl.length == _envMapLength, '''
You must be consistent about the number of flavor environment you have.
you had $_envMapLength flavors and you are defining ${impl.length} flavors.
    ''');
        return impl[env]!();
      },
      initialValue: initialState,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      on: onSetState,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      // watch: watch,
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      isLazy: isLazy,
    );
  }

  static InjectedCRUD<T, P> injectCRUD<T, P>(
    ICRUD<T, P> Function() repository, {
    required Object? Function(T item) id,
    P Function()? param,
    bool readOnInitialization = false,
    void Function(List<T> s)? onInitialized,
    void Function(List<T> s)? onDisposed,
    void Function()? onWaiting,
    void Function(List<T> s)? onData,
    On<void>? onSetState,
    void Function(dynamic e, StackTrace? s)? onError,
    //
    DependsOn<List<T>>? dependsOn,
    int undoStackLength = 0,
    PersistState<List<T>> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not be inferred, please declare it explicitly',
    );

    final p = param != null
        ? RM.inject(
            () => param.call(),
          )
        : null;
    late InjectedCRUD<T, P> inj;
    inj = InjectedCRUD<T, P>(
      creator: () {
        if (!inj._isFirstInitialized && !readOnInitialization) {
          return <T>[];
        } else {
          final repo = repository();
          inj._crud = _CRUDService(repo, id, inj);
          return () async {
            final l = await repo.read(p?.state);
            return [...l];
          }();
        }
      },
      initialState: <T>[],
      param: p,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      onWaiting: onWaiting,
      onData: onData,
      onError: onError,
      onSetState: onSetState,
      //
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      //
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      identifier: id,
    );
    inj._readOnInitialization = readOnInitialization;
    return inj;
  }

  ///Static variable the holds the chosen working environment or flavour.
  static dynamic env;
  static int? _envMapLength;
  //
  static bool _printAllInitDispose = false;

  static BuildContext? _context;
  static final List<BuildContext> _contextSet = [];
  static Disposer _addToContextSet(BuildContext context) {
    _contextSet.add(context);
    return () {
      _contextSet.remove(context);
      if (_contextSet.isEmpty) {
        disposeAll();
      }
    };
  }

  ///Get an active [BuildContext].
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets
  ///context;
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static BuildContext? get context {
    if (_context != null) {
      return _context;
    }

    if (_contextSet.isNotEmpty) {
      // if (_contextSet.last.findRenderObject()?.attached != true) {
      //   _contextSet.removeLast();
      //   return context;
      // }
      return _contextSet.last;
    }

    return RM.navigate._navigatorKey.currentState?.context;
  }

  static set context(BuildContext? context) {
    if (context == null) {
      return;
    }
    _context = context;
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) {
        return _context = null;
      },
    );
  }

  ///Boiler-plate-less helper for Navigation and routing.
  ///
  ///It does not requires the definition of a BuildContext, MaterialPageRoute or
  ///ModalRoute
  ///
  ///equivalence:
  ///* to => push,
  ///* toNamed => pushNamed,
  ///* toReplacement => pushReplacement,
  ///* toReplacementNamed => pushReplacementNamed,
  ///* toAndRemoveUntil => pushAndRemoveUntil,
  ///* toNamedAndRemoveUntil => pushNamedAndRemoveUntil,
  ///
  ///* back => pop,
  ///* backUntil => popUntil,
  ///* backAndToNamed => popAndPushNamed,
  ///
  ///Dialogs and sheets
  ///
  ///* toDialog => showDialog
  ///* toCupertinoDialog => showCupertinoDialog
  ///* toBottomSheet => showModalBottomSheet
  ///* toCupertinoModalPopup => showCupertinoModalPopup
  ///
  ///For any other operations you can use [_Navigate.navigatorState] getter.
  static _Navigate navigate = _navigate;

  ///Boiler-plate-less helper for side effects that need the [ScaffoldState].
  ///
  ///It does not requires the explicit availability of a [BuildContext].
  ///
  ///Before calling any method a decedent BuildContext of Scaffold must be set.
  ///This can be done either:
  ///
  ///* ```dart
  ///   onPressed: (){
  ///    RM.scaffoldShow.context= context;
  ///    RM.scaffoldShow.snackBar( ... );
  ///   }
  ///  ```
  ///* ```dart
  ///   onPressed: (){
  ///    modelRM.setState(
  ///     (s)=> doSomeThing(),
  ///     context:context,
  ///     onData: (_,__){
  ///        RM.scaffoldShow.snackBar( ... );
  ///      )
  ///    }
  ///   }
  ///  ```
  ///equivalence:
  ///
  ///* bottomSheet => Scaffold.of(context).showBottomSheet,
  ///* snackBar => ScaffoldMessenger.of(context).showSnackBar,
  ///* hideCurrentSnackBar => ScaffoldMessenger.of(context).showSnackBar,
  ///* removeCurrentSnackBarm => ScaffoldMessenger.of(context).showSnackBar,
  ///* openDrawer => Scaffold.of(context).openDrawer,
  ///* openEndDrawer => Scaffold.of(context).openEndDrawer,
  ///
  ///For any other operations you can use [_Scaffold.scaffoldState] or
  ///[_Scaffold.scaffoldMessengerState]  getter.
  static _Scaffold scaffold = _scaffold;

  ///Initialize the default persistance provider to be used.
  ///
  ///Called in the main method:
  ///```dart
  ///void main()async{
  /// WidgetsFlutterBinding.ensureInitialized();
  ///
  /// await RM.storageInitializer(IPersistStoreImp());
  /// runApp(MyApp());
  ///}
  ///
  ///```
  ///
  ///This is considered as the default storage provider. It can be overridden
  ///with [PersistState.persistStateProvider]
  ///
  ///For test use [RM.storageInitializerMock].
  static Future<void> storageInitializer(IPersistStore store) async {
    if (_persistStateGlobal != null) {
      return;
    }
    _persistStateGlobal = store;
    return _persistStateGlobal?.init();
  }

  ///Initialize a mock persistance provider.
  ///
  ///Used for tests.
  ///
  ///It is wise to clear the store in setUp method, to ensure a fresh store for each test
  ///```dart
  /// setUp(() {
  ///  storage.clear();
  /// });
  ///```
  static Future<_PersistStoreMock> storageInitializerMock() async {
    _persistStateGlobalTest = _PersistStoreMock();
    await _persistStateGlobalTest?.init();
    return (_persistStateGlobalTest as _PersistStoreMock);
  }

  ///Manually dispose all [Injected] models.
  ///
  ///
  static void disposeAll() {
    final inj = {..._injectedModels};
    print(inj.length);
    inj.forEach((e) => e.dispose());
    _injectedModels.clear();
  }

  static var debugPrintActiveRM;
  static void Function(SnapState)? printInjected;
}

IPersistStore? _persistStateGlobal;
IPersistStore? _persistStateGlobalTest;
