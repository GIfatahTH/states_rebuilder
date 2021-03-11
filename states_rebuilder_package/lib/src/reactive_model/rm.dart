part of '../reactive_model.dart';

abstract class RM {
  RM._();

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
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    void Function(SnapState snapState)? debugNotification,
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
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

      middleSnapState: middleSnapState,
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
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    void Function(SnapState snapState)? debugNotification,
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
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

      middleSnapState: middleSnapState,
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
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    void Function(SnapState snapState)? debugNotification,
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,

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
      middleSnapState: middleSnapState,
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
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    void Function(SnapState snapState)? debugNotification,
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not inferred, please declare it explicitly',
    );
    return InjectedImp<T>(
      creator: (_) {
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

      middleSnapState: middleSnapState,
      isLazy: isLazy,
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
    void Function(List<T> s)? onInitialized,
    void Function(List<T> s)? onDisposed,
    _OnCRUD<void>? onCRUD,
    On<void>? onSetState,
    //
    DependsOn<List<T>>? dependsOn,
    int undoStackLength = 0,
    PersistState<List<T>> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    SnapState<List<T>>? Function(MiddleSnapState<List<T>> middleSnap)?
        middleSnapState,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not be inferred, please declare it explicitly',
    );

    late InjectedCRUD<T, P> inj;
    inj = InjectedCRUD<T, P>(
      creator: () {
        if (!inj._isFirstInitialized) {
          final fn = () async {
            final repo = repository();
            await repo.init();
            return repo;
          };
          inj._crud = _CRUDService(fn(), inj);
        }
        if (!inj._isFirstInitialized && !(readOnInitialization)) {
          return <T>[];
        } else {
          return () async {
            final _repo = await inj._crud!._repository;
            final l = await _repo.read(param?.call());
            return [...l];
          }();
        }
      },
      initialState: <T>[],
      param: param,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      onCRUD: onCRUD,
      onSetState: onSetState,
      //
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      //
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      debugError: debugError,
      middleSnapState: middleSnapState,
    );
    inj.._readOnInitialization = readOnInitialization;
    return inj;
  }

  ///Functional injection of a state that can authenticate and authorize
  ///a user.
  ///
  ///* Required parameters:
  ///  * **repository**:  (positional parameter) Repository that implements
  /// the IAuth<T, P> interface, where T is the Type of the user, and P is
  /// the type of the param to be used when querying the backend service.
  ///  * **unsignedUser**:  (named parameter) An object that represents an
  /// unsigned user. It must be of type T.
  ///
  /// * **Optional parameters:**
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
    required T unsignedUser,
    P Function()? param,
    void Function(T s)? onSigned,
    void Function()? onUnsigned,
    Duration Function(T auth)? autoSignOut,
    FutureOr<Stream<T>> Function(IAuth<T, P> repo)? onAuthStream,
    //
    void Function(T s)? onInitialized,
    void Function(T s)? onDisposed,
    On<void>? onSetState,
    //
    //DependsOn<T>? dependsOn,
    //int undoStackLength = 0,
    PersistState<T> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = false,
    String? debugPrintWhenNotifiedPreMessage,
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    SnapState<T>? Function(MiddleSnapState<T> middleSnap)? middleSnapState,
  }) {
    assert(
      T != dynamic && T != Object,
      'Type can not be inferred, please declare it explicitly',
    );

    late InjectedAuth<T, P> inj;
    inj = InjectedAuth<T, P>(
      creator: () {
        if (!inj._isFirstInitialized) {
          final fn = () async {
            final repo = repository();
            await repo.init();
            return repo;
          };

          inj._auth = _AuthService(fn(), inj);
        }
        return unsignedUser;
      },
      initialState: unsignedUser,
      autoSignOut: autoSignOut,
      param: param,
      onInitialized: (s) async {
        inj._auth ??= _AuthService(
          () async {
            final repo = repository();
            await repo.init();
            return repo;
          }(),
          inj,
        );

        if (onAuthStream != null) {
          inj._coreRM._setToIsWaiting(
            infoMessage: 'AuthStateChange',
          );
          final repo = await inj._auth!._repository;
          final Stream<T> stream = await onAuthStream(repo);
          StreamSubscription<T>? subscription = stream.listen(
            (data) {
              inj.state = data;
            },
            onError: (e, s) {
              inj.state = inj._initialState!;
              inj._coreRM._setToHasError(e, s, onErrorRefresher: () {});
            },
          );
          inj.addToCleaner(
            () {
              subscription?.cancel();
              subscription = null;
            },
          );
        }

        //If it is mocked using injectMock,
        //Do not invoke onSigned and onUnSigned
        if (inj.isIdle && !inj._isInjectMock) {
          if (inj.state != inj._initialState) {
            if (autoSignOut != null) {
              inj._auth!._autoSignOut();
              // inj._auth!.autoSignOut(autoSignOut(inj._state!));
            }
            WidgetsBinding.instance?.addPostFrameCallback(
              (_) => onSigned?.call(inj._state!),
            );
          } else {
            WidgetsBinding.instance?.addPostFrameCallback(
              (_) => onUnsigned?.call(),
            );
          }
        }
        onInitialized?.call(s);
      },
      onDisposed: (s) {
        inj._auth!._cancelTimer();
        onDisposed?.call(s);
      },
      onSetState: onSetState,
      onAuthenticated: onSigned,
      onSignOut: onUnsigned,
      //
      //dependsOn: dependsOn,
      //undoStackLength: undoStackLength,
      persist: persist,
      //
      // autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      debugError: debugError,
      middleSnapState: middleSnapState,
    );

    return inj;
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
  static InjectedTheme<Key> injectTheme<Key>({
    required Map<Key, ThemeData> lightThemes,
    Map<Key, ThemeData>? darkThemes,
    ThemeMode themeMode = ThemeMode.system,
    String? persistKey,
    //
    void Function(Key s)? onInitialized,
    void Function(Key s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<Key>? dependsOn,
    int undoStackLength = 0,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    SnapState<Key>? Function(MiddleSnapState<Key> middleSnap)? middleSnapState,
  }) {
    PersistState<Key> Function()? persist;
    late InjectedTheme<Key> inj;
    if (persistKey != null) {
      persist = () => PersistState(
            key: persistKey,
            fromJson: (json) {
              ///json is of the form key#|#1
              final s = json.split('#|#');
              assert(s.length <= 2);
              final Key key = lightThemes.keys.firstWhere(
                (k) => s.first == '$k',
                orElse: () => lightThemes.keys.first,
              );
              //

              if (s.last == '0') {
                inj._themeMode = ThemeMode.light;
              } else if (s.last == '1') {
                inj._themeMode = ThemeMode.dark;
              } else {
                inj._themeMode = ThemeMode.system;
              }
              return key;
            },
            toJson: (key) {
              String th = '';
              if (inj._themeMode == ThemeMode.light) {
                th = '0';
              } else if (inj._themeMode == ThemeMode.dark) {
                th = '1';
              }

              ///json is of the form key#|#1
              return '$key#|#$th';
            },
            // debugPrintOperations: true,
          );
    }
    inj = InjectedTheme<Key>(
      themes: lightThemes,
      darkThemes: darkThemes,
      themeMode: themeMode,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      onSetState: onSetState,
      //
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      //
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      debugError: debugError,
      middleSnapState: middleSnapState,
    );
    return inj;
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
    Map<Locale, FutureOr<I18N> Function()> selectionMap, {
    String? persistKey,
    //
    void Function(I18N s)? onInitialized,
    void Function(I18N s)? onDisposed,
    On<void>? onSetState,
    //
    DependsOn<I18N>? dependsOn,
    int undoStackLength = 0,
    //
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    void Function(dynamic error, StackTrace stackTrace)? debugError,
    SnapState<I18N>? Function(MiddleSnapState<I18N> middleSnap)?
        middleSnapState,
  }) {
    PersistState<I18N> Function()? persist;
    late InjectedI18N<I18N> inj;
    if (persistKey != null) {
      persist = () => PersistState(
            key: persistKey,
            fromJson: (json) {
              final s = json.split('#|#');
              assert(s.length <= 3);
              if (s.first.isEmpty) {
                return inj._getLanguage(SystemLocale());
              }
              final l = Locale.fromSubtags(
                languageCode: s.first,
                scriptCode: s.length > 2 ? s[1] : null,
                countryCode: s.last,
              );

              return inj._getLanguage(l);
            },
            toJson: (_) {
              String l = '';
              if (inj._locale is SystemLocale) {
                l = '#|#';
              } else {
                l = '${inj._resolvedLocale!.languageCode}#|#' +
                    (inj._locale?.scriptCode != null
                        ? '${inj._resolvedLocale!.scriptCode}#|#'
                        : '') +
                    '${inj._resolvedLocale!.countryCode}';
              }
              return l;
            },
            // debugPrintOperations: true,
          );
    }
    inj = InjectedI18N<I18N>(
      i18n: selectionMap,
      //
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      onSetState: onSetState,
      //
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      persist: persist,
      //
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      debugError: debugError,
      middleSnapState: middleSnapState,
    );
    return inj;
  }

  ///Static variable the holds the chosen working environment or flavour.
  static dynamic env;
  static int? _envMapLength;
  //
  // ignore: prefer_final_fields
  static bool _printAllInitDispose = false;

  static BuildContext? _context;
  static final List<BuildContext> _contextSet = [];
  static Disposer _addToContextSet(BuildContext context) {
    _contextSet.add(context);
    return () {
      _contextSet.remove(context);
      if (_contextSet.isEmpty) {
        Future.microtask(
          () => disposeAll(false),
        );
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
  static _Transitions transitions = _transitions;

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

  ///Manually dispose all [Injected] models.
  ///
  ///
  static void disposeAll([bool forceDispose = true]) async {
    _scaffold._context = null;
    _context = null;

    await Future.microtask(
      () => {..._injectedModels}.forEach(
        (e) {
          if (forceDispose || e._autoDisposeWhenNotUsed) {
            e.dispose();
            _injectedModels.remove(e);
          }
        },
      ),
    );
  }

  static bool? debugPrintActiveRM;
  static void Function(SnapState)? printInjected;
  //
  //
  static ReactiveModel<T> get<T>([String? name]) {
    return Injector.getAsReactive<T>(name: name);
  }

  static ReactiveModel<T> create<T>(T m) {
    return ReactiveModelImp(creator: (_) => m, nullState: m);
  }
}

IPersistStore? _persistStateGlobal;
IPersistStore? _persistStateGlobalTest;
