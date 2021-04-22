import 'dart:async';
import 'dart:collection';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'legacy/injector.dart';

import 'injected/injected_animation/injected_animation.dart';
import 'injected/injected_auth/injected_auth.dart';
import 'injected/injected_crud/injected_crud.dart';
import 'injected/injected_i18n/injected_i18n.dart';
import 'injected/injected_theme/injected_theme.dart';
import 'common/deep_equality.dart';
import 'common/logger.dart';
import 'common/consts.dart';

part 'basics/depends_on.dart';
part 'basics/reactive_model.dart';
part 'extensions/injected_list_x.dart';
part 'extensions/injected_x.dart';
part 'extensions/on_combined_x.dart';
part 'extensions/on_x.dart';
part 'basics/injected.dart';
part 'basics/injected_imp.dart';
part 'basics/injected_persistance/i_persistStore.dart';
part 'basics/injected_persistance/injected_persistance.dart';
part 'basics/injected_persistance/persist_state_mock.dart';
part 'navigate/build_context_x.dart';
part 'navigate/page_route_builder.dart';
part 'navigate/rm_navigator.dart';
part 'navigate/route_data.dart';
part 'navigate/route_full_widget.dart';
part 'navigate/route_widget.dart';
part 'navigate/sub_route.dart';
part 'navigate/transitions.dart';
part 'on_listeners/on.dart';
part 'on_listeners/on_combined.dart';
part 'on_listeners/on_future.dart';
part 'basics/reactive_model_base.dart';
part 'basics/reactive_model_listener.dart';
part 'basics/snap_state.dart';
part 'basics/state_builder.dart';
part 'basics/undo_redo_persist_state.dart';
part 'navigate/rm_scaffold.dart';

abstract class RM {
  RM._();

  ///Functional injection of a primitive, enum or object.
  ///
  ///* **Required parameters:**
  ///  * **creator**:  (positional parameter) a callback that
  /// creates an instance of the injected object
  /// {@template injectOptionalParameter}
  /// * **Optional parameters:**
  ///   * **initialState**: Initial state.
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
  /// informative message when this model is notified in the debug mode. It
  /// prints (FROM ==> TO state). The entered message will pré-append the
  /// debug message. Useful if the type of the injected model is primitive to
  /// distinguish between them.
  ///   * **toDebugString**: String representation fo the state to be used in
  /// debugPrintWhenNotifiedPreMessage. Useful, for example, if the state is a
  /// collection and you want to print its length only.
  /// {@endtemplate}
  static Injected<T> inject<T>(
    T Function() creator, {
    T? initialState,
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
    void Function(T? s)? onInitialized,
    void Function(T s)? onDisposed,
    void Function()? onWaiting,
    void Function(T s)? onData,
    On<void>? onSetState,
    void Function(dynamic e, StackTrace? s)? onError,
    DependsOn<T>? dependsOn,
    //
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    //
    bool isLazy = true,
    //
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) {
    return InjectedImp<T>(
      creator: creator,
      initialState: initialState,
      onInitialized: onInitialized,
      onSetState: onSetState,
      onWaiting: onWaiting,
      onData: onData,
      onError: onError,
      onDisposed: onDisposed,
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      middleSnapState: middleSnapState,
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
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
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
    void Function(T? s)? onInitialized,
    void Function(T s)? onDisposed,
    void Function()? onWaiting,
    void Function(T s)? onData,
    // On<void>? onSetState,
    void Function(dynamic e, StackTrace? s)? onError,
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    //
    bool isLazy = true,
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) {
    return InjectedImp<T>(
      creator: creator,
      initialState: initialState,
      onInitialized: onInitialized,
      onWaiting: onWaiting,
      onData: onData,
      onError: onError,
      onDisposed: onDisposed,
      dependsOn: dependsOn,
      isAsyncInjected: true,
      undoStackLength: undoStackLength,
      persist: persist,
      middleSnapState: middleSnapState,
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
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
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
    void Function(T? s, StreamSubscription subscription)? onInitialized,
    void Function(T s)? onDisposed,
    void Function()? onWaiting,
    void Function(T s)? onData,
    // On<void>? onSetState,
    void Function(dynamic e, StackTrace? s)? onError,
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    //
    bool isLazy = true,
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
    //
    Object? Function(T? s)? watch,
  }) {
    late InjectedImp<T> inj;
    inj = InjectedImp<T>(
      creator: creator,
      initialState: initialState,
      onInitialized: onInitialized != null
          ? (s) => onInitialized(s, inj.subscription!)
          : null,
      onWaiting: onWaiting,
      onData: onData,
      onError: onError,
      onDisposed: onDisposed,
      dependsOn: dependsOn,
      isAsyncInjected: true,
      undoStackLength: undoStackLength,
      middleSnapState: (s) {
        final snap = middleSnapState?.call(s) ?? s.nextSnap;
        if (watch != null && s.currentSnap.hasData && snap.hasData) {
          final can = watch(s.currentSnap.data) == watch(snap.data);
          if (can) {
            return SkipSnapState<T>();
          }
        }
        return snap;
      },
      isLazy: true,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );
    if (!isLazy) {
      inj.initialize();
    }
    return inj;
  }

  ///Functional injection of a state that can authenticate and authorize
  ///a user.
  ///
  ///* Required parameters:
  ///  * **repository**:  (positional parameter) Repository that implements
  /// the IAuth<T, P> interface, where T is the Type of the user, and P is
  /// the type of the param to be used when querying the backend service.
  ///
  /// * **Optional parameters:**
  ///  * **unsignedUser**:  (named parameter) An object that represents an
  /// unsigned user. It must be of type T. It may be null.
  ///   * **param**: Default param to be used for authentication.
  /// It can be overridden when calling signUp, signIn and signOut
  /// methods
  ///   * **onSigned**: Callback to be called when a user is signed. This
  /// is the right place to navigate to a user related page.
  ///   * **onUnsigned**: Callback to be called when a user is unsigned or
  /// signed out. This is the right place to navigate to authentication page.
  ///   * **autoSignOut**: Callback that exposes the current signed user and
  /// returns a duration after which the user is automatically signed out.
  ///   * **authenticateOnInit**: Whether to authenticate the
  /// {@macro customInjectOptionalParameter}
  static InjectedAuth<T, P> injectAuth<T, P>(
    IAuth<T, P> Function() repository, {
    T? unsignedUser,
    P Function()? param,
    void Function(T s)? onSigned,
    void Function()? onUnsigned,
    Duration Function(T auth)? autoSignOut,
    FutureOr<Stream<T>> Function(IAuth<T, P> repo)? onAuthStream,
    //
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
    void Function(T? s)? onInitialized,
    void Function(T s)? onDisposed,
    On<void>? onSetState,
    //
    PersistState<T> Function()? persist,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugString,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not inferred, please declare it explicitly',
    );
    assert(
      null is T || unsignedUser != null,
      '$T is non nullable, you have to define unsignedUser parameter.\n'
      'If you want to the unsignedUSer to be null use nullable type ($T?)',
    );
    return InjectedAuthImp<T, P>(
      repoCreator: repository,
      unsignedUser: unsignedUser,
      param: param,
      onSigned: onSigned,
      onUnsigned: onUnsigned,
      autoSignOut: autoSignOut,
      onAuthStream: onAuthStream,
      //
      middleSnapState: middleSnapState,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      on: onSetState,
      //
      persist: persist,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );
  }

  ///Functional injection of a state that can create, read, update and
  ///delete from a backend or database service.
  ///
  ///* Required parameters:
  ///  * **repository**:  (positional parameter) Repository that implements
  /// the ICRUD<T,P> interface, where T is the Type of the state, and P is
  /// the type of the param to be used when querying the backend service.
  ///
  /// * **Optional parameters:**
  ///   * **param**: Default param to be used when querying the database.
  /// It can be overridden when calling create, read, update and delete
  /// methods
  ///   * **readOnInitialization**: If true a read query with the default
  /// param will se sent to the backend service once the state is initialized.
  /// You can set it to false and intentionally call read method the time you
  /// want.
  /// {@template customInjectOptionalParameter}
  ///   * **onInitialized**: Callback to be executed after the injected model
  /// is first created.
  ///   * **onDisposed**: Callback to be executed after the injected model is
  /// removed.
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
  static InjectedCRUD<T, P> injectCRUD<T, P>(
    ICRUD<T, P> Function() repository, {
    P Function()? param,
    bool readOnInitialization = false,
    OnCRUD<void>? onCRUD,
    //
    SnapState<List<T>>? Function(MiddleSnapState<List<T>> middleSnap)?
        middleSnapState,
    void Function(List<T>? s)? onInitialized,
    void Function(List<T> s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<List<T>>? dependsOn,
    int undoStackLength = 0,
    PersistState<List<T>> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(List<T>?)? toDebugString,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not inferred, please declare it explicitly',
    );
    return InjectedCRUDImp<T, P>(
      repoCreator: repository,
      param: param,
      readOnInitialization: readOnInitialization,
      onCRUD: onCRUD,
      //
      middleSnapState: middleSnapState,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      onSetState: onSetState,
      //
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );
  }

  ///{@template injectedTheme}
  ///Functional injection of a state that handle app theme switching.
  ///
  ///* Required parameters:
  ///  * **lightThemes**:  Map of light themes the app supports. The keys of
  /// the Map are the names of the themes. They can be String or enumeration
  ///
  /// * **Optional parameters:**
  ///  * **darkThemes**:  Map of dark themes the app supports. There should
  /// be a correspondence between light and dark themes. Nevertheless, you
  /// can have light themes with no corresponding dark one.
  ///  * **themeMode**: the theme Mode the app should start with.
  ///  * **persistKey**: If defined the app theme is persisted to a local
  /// storage. The persisted theme will be used on app restarting.
  /// {@endtemplate}
  /// {@macro customInjectOptionalParameter}
  static InjectedTheme<KEY> injectTheme<KEY>({
    required Map<KEY, ThemeData> lightThemes,
    Map<KEY, ThemeData>? darkThemes,
    ThemeMode themeMode = ThemeMode.system,
    String? persistKey,
    //
    SnapState<KEY>? Function(MiddleSnapState<KEY> middleSnap)? middleSnapState,
    void Function(KEY? s)? onInitialized,
    void Function(KEY s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<KEY>? dependsOn,
    int undoStackLength = 0,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(KEY?)? toDebugString,
  }) {
    return InjectedThemeImp<KEY>(
      lightThemes: lightThemes,
      darkThemes: darkThemes,
      themeModel: themeMode,
      persistKey: persistKey,
      //
      middleSnapState: middleSnapState,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      onSetState: onSetState,
      //
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      //
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );
  }

  ///Functional injection of a state that handle app internationalization
  ///and localization.
  ///
  ///* Required parameters:
  ///  * **i18n**:  Map of supported locales with their language translation.
  ///
  /// * **Optional parameters:**
  ///  * **persistKey**: If defined the app locale is persisted to a local
  /// storage. On app start, the stored locale will be used.
  /// {@macro customInjectOptionalParameter}
  static InjectedI18N<I18N> injectI18N<I18N>(
    Map<Locale, FutureOr<I18N> Function()> i18Ns, {
    String? persistKey,
    //
    SnapState<I18N>? Function(MiddleSnapState<I18N> middleSnap)?
        middleSnapState,
    void Function(I18N? s)? onInitialized,
    void Function(I18N s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<I18N>? dependsOn,
    int undoStackLength = 0,
    //
    // bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
  }) {
    return InjectedI18NImp<I18N>(
      i18Ns: i18Ns,
      persistKey: persistKey,
      //
      middleSnapState: middleSnapState,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      onSetState: onSetState,
      //
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      //
      // isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  static InjectedAnimation injectAnimation({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.linear,
    int? repeats,
    int? cycles,
    void Function()? endAnimationListener,
  }) {
    return InjectedAnimationImp(
      duration: duration,
      curve: curve,
      repeats: repeats,
      cycles: cycles,
      endAnimationListener: endAnimationListener,
    );
  }

  ///Static variable the holds the chosen working environment or flavour.
  static dynamic env;
  static int? _envMapLength;

  ///Functional injection of flavors (environments).
  ///
  ///* Required parameters:
  ///  * [impl]:  (positional parameter) Map of the implementations of the interface.
  /// * optional parameters:
  /// {@macro injectOptionalParameter}
  static Injected<T> injectFlavor<T>(
    Map<dynamic, FutureOr<T> Function()> impl, {
    T? initialState,
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
    void Function(T? s)? onInitialized,
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
    String Function(T?)? toDebugString,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not inferred, please declare it explicitly',
    );
    return InjectedImp<T>(
      creator: () {
        _envMapLength ??= impl.length;
        assert(RM.env != null, '''
You are using [RM.injectFlavor]. You have to define the [RM.env] before the [runApp] method
    ''');
        assert(impl[env] != null, '''
There is no implementation for $env of $T interface
    ''');
        assert(impl.length == _envMapLength, '''
You must be consistent about the number of flavor environment you have.
you had $_envMapLength flavors and you are defining ${impl.length} flavors.
    ''');
        return impl[env]!();
      },
      initialState: initialState,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onSetState: onSetState,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      // watch: watch,
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
      middleSnapState: middleSnapState,
      isLazy: isLazy,
    );
  }

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
    if (_persistStateGlobal != null || _persistStateGlobalTest != null) {
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

  static Future<void> deleteAllPersistState() async {
    await (_persistStateGlobalTest ?? _persistStateGlobal)?.deleteAll();
    UndoRedoPersistState.cleanStorageProviders();
  }

  static void disposeAll() {
    for (var inj in [...injectedModels]) {
      inj.dispose();
    }
    injectedModels.clear();
    _scaffold._context = null;
  }

  static _Scaffold scaffold = _scaffold;
  static _Navigate navigate = _navigate;
  static _Transitions transitions = _transitions;
  static BuildContext? _context;

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
      if (_contextSet.last.findRenderObject()?.attached != true) {
        _contextSet.removeLast();
        return context;
      }
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

  //
  static ReactiveModel<T> get<T>([String? name]) {
    return Injector.getAsReactive<T>(name: name);
  }
}

final injectedModels = <Injected>{};
VoidCallback _addToInjectedModels(Injected inj) {
  injectedModels.add(inj);
  return () {
    injectedModels.remove(inj);
  };
}

final List<BuildContext> _contextSet = [];

VoidCallback addToContextSet(BuildContext ctx) {
  _contextSet.add(ctx);
  print('contextSet length is ${_contextSet.length}');
  return () {
    _contextSet.remove(ctx);
    print('contextSet dispose length is ${_contextSet.length}');
  };
}
