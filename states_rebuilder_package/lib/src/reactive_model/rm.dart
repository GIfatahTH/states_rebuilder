part of '../reactive_model.dart';

///
abstract class RM {
  ///Create a [ReactiveModel] from primitives or any object
  static ReactiveModel<T> create<T>(T model) {
    final T _model = model;
    return ReactiveModel<T>.create(_model);
  }

  ///Create a [ReactiveModel] from callback. It's like [create] with the difference
  ///that when [ReactiveModel.refresh] is called, an updated value is obtained.
  ///
  ///Useful with [ReactiveModel.refresh] method.
  static ReactiveModel<T> createFromCallback<T>(T Function() creationFunction) {
    return Inject<T>(creationFunction).getReactive();
  }

  ///Functional injection of a primitive, enum or object.
  ///
  ///* Required parameters:
  ///  * [creationFunction]:  (positional parameter) a callback that
  /// creates an instance of the injected object
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [onError]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [debugPrintWhenNotifiedPreMessage]: if not null, print an informative message when this model is notified in the debug mode.
  /// The entered message will pré-append the debug message. Useful if the type of the injected model is primitive to distinguish
  /// the model message.//TODO
  static Injected<T> inject<T>(
    T Function() creationFunction, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
    String debugPrintWhenNotifiedPreMessage,
  }) {
    return InjectedImp<T>(
      creationFunction,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      undoStackLength: undoStackLength,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  ///Functional injection of a [Future].
  ///
  ///* Required parameters:
  ///  * [creationFunction]:  (positional parameter) a callback that return a [Future].
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily invoke the Future. Default value is true.
  static Injected<T> injectFuture<T>(
    Future<T> Function() creationFunction, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
    T initialValue,
    bool isLazy = true,
    String debugPrintWhenNotifiedPreMessage,
  }) {
    return InjectedFuture<T>(
      creationFunction,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      isLazy: isLazy,
      initialValue: initialValue,
      undoStackLength: undoStackLength,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  ///Functional injection of a [Stream].
  ///
  ///* Required parameters:
  ///  * [creationFunction]:  (positional parameter) a callback that return a [Stream].
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily invoke the Future. Default value is true.
  ///   * [watch]: callback to determine the parameter to watch and do not emit a notification
  /// unless they changed.
  static Injected<T> injectStream<T>(
    Stream<T> Function() creationFunction, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
    T initialValue,
    bool isLazy = true,
    Function(T s) watch,
    String debugPrintWhenNotifiedPreMessage,
  }) {
    return InjectedStream<T>(
      creationFunction,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      isLazy: isLazy,
      watch: watch,
      initialValue: initialValue,
      undoStackLength: undoStackLength,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  ///Functional injection of flavors (environments).
  ///
  ///* Required parameters:
  ///  * [impl]:  (positional parameter) Map of the implementations of the interface.
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily execute the impl callback. Default value is true.
  static Injected<T> injectFlavor<T>(
    Map<dynamic, FutureOr<T> Function()> impl, {
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    void Function() onWaiting,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    bool autoDisposeWhenNotUsed = true,
    int undoStackLength,
    T initialValue,
    bool isLazy = true,
    String debugPrintWhenNotifiedPreMessage,
  }) {
    return InjectedInterface<T>(
      impl,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      initialValue: initialValue,
      undoStackLength: undoStackLength,
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  ///Functional injection of a computed model.
  ///
  ///The model
  ///
  ///* Required parameters:
  ///  * [impl]:  (positional parameter) Map of the implementations of the interface.
  /// * optional parameters:
  ///   * [onInitialized]: Callback to be executed after the
  /// injected model is first created.
  ///   * [onDisposed]: Callback to be executed after the injected model is removed.
  ///   * [onWaiting]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model is in the awaiting state.
  ///   * [onData]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with data.
  ///   * [error]: Callback to be executed each time the [ReactiveModel] associated with the injected
  /// model emits a notification with error.
  ///   * [autoDisposeWhenNotUsed]: Whether to auto dispose the injected model when no longer used (listened to).
  /// The default value is true.
  ///   * [undoStackLength]: the length of the undo/redo stack. If not defined, the undo/redo is disabled.
  ///   * [initialValue]: Initial value of the Future.
  ///   * [isLazy]: Whether to lazily execute the compute method. Default value is true.
  static Injected<T> injectComputed<T>({
    T Function(T s) compute,
    List<Injected<dynamic>> asyncDependsOn,
    Stream<T> Function(T s) computeAsync,
    bool autoDisposeWhenNotUsed = true,
    void Function(T s) onData,
    void Function(dynamic e, StackTrace s) onError,
    void Function() onWaiting,
    void Function(T s) onInitialized,
    void Function(T s) onDisposed,
    T initialState,
    bool Function(T s) shouldCompute,
    int undoStackLength,
    bool isLazy = true,
    String debugPrintWhenNotifiedPreMessage,
  }) {
    return InjectedComputed<T>(
      compute: compute,
      computeAsync: computeAsync,
      asyncDependsOn: asyncDependsOn,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      onData: onData,
      onError: onError,
      onWaiting: onWaiting,
      initialState: initialState,
      shouldCompute: shouldCompute,
      onInitialized: onInitialized,
      onDisposed: onDisposed,
      undoStackLength: undoStackLength,
      isLazy: isLazy,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    );
  }

  ///Clean and dispose all Injected model;
  ///
  ///Although Injected models are auto cleaned, sometimes, we need to
  ///manually clean the Injected models especially in tests.
  static void disposeAll() {
    cleanInjector();
  }

  ///Create a [ReactiveModel] from future.
  static ReactiveModel<T> future<T>(
    Future<T> future, {
    dynamic name,
    T initialValue,
    List<dynamic> filterTags,
  }) {
    return ReactiveModel<T>.future(
      future,
      name: name,
      initialValue: initialValue,
      filterTags: filterTags,
    );
  }

  ///Create a [Stream] from future.
  static ReactiveModel<T> stream<T>(
    Stream<T> stream, {
    dynamic name,
    T initialValue,
    List<dynamic> filterTags,
    Object Function(T) watch,
  }) {
    return ReactiveModel<T>.stream(
      stream,
      name: name,
      initialValue: initialValue,
      filterTags: filterTags,
      watch: watch,
    );
  }

  ///Get the [ReactiveModel] singleton of an injected model.
  static ReactiveModel<T> get<T>({
    dynamic name,
    bool silent,
    BuildContext context,
  }) {
    final rm = Injector.getAsReactive<T>(
      name: name,
      silent: silent,
    );
    if (rm != null && context != null) {
      rm.contextSubscription(context);
    }
    return rm;
  }

  ///get the model that is sending the notification
  static ReactiveModel get notified =>
      StatesRebuilderInternal.getNotifiedModel();

  static BuildContext _context;

  ///Get an active [BuildContext].
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static BuildContext get context {
    if (_context != null) {
      return _context;
    }

    if (InjectorState.contextSet.isNotEmpty) {
      if (InjectorState.contextSet.last?.findRenderObject()?.attached != true) {
        InjectorState.contextSet.removeLast();
        return context;
      }
      return InjectorState.contextSet.last;
    }

    return RM.navigate._navigatorKey?.currentState?.context;
  }

  static set context(BuildContext context) {
    _context = context;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        return _context = null;
      },
    );
  }

  ///get The state for a [Navigator] widget.
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  @Deprecated('use RM.navigate instead')
  static NavigatorState get navigator {
    return Navigator.of(context);
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
  ///For any other operations you can use navigatorState getter.
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
  ///* snackBar => Scaffold.of(context).showSnackBar,
  ///* openDrawer => Scaffold.of(context).openDrawer,
  ///* openEndDrawer => Scaffold.of(context).openEndDrawer,
  ///
  ///For any other operations you can use scaffoldState getter.
  static _Scaffold scaffoldShow = _scaffold;

  ///Get the [ScaffoldState]
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  @Deprecated('use RM.scaffoldShow instead')
  static ScaffoldState get scaffold {
    return Scaffold.of(context);
  }

  ///A callBack that exposes an active [BuildContext]
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  @deprecated
  static dynamic show(void Function(BuildContext context) fn) {
    return fn(context);
  }

  ///if true, An informative message is printed in the consol,
  ///showing the model being sending the Notification,
  ///
  ///See : [debugWidgetsRebuild], [debugError] and [debugErrorWithStackTrace]

  static bool debugPrintActiveRM = false;

  ///Consol log information about the widgets that have just rebuild
  ///
  ///See : [debugPrintActiveRM], [debugError] and [debugErrorWithStackTrace]
  static bool debugWidgetsRebuild = false;

  ///If true , print error message
  ///
  ///As states_rebuilder can catches errors, bu using [debugError]
  ///you can console log them.
  ///
  ///Default value is false
  ///
  ///See : [debugPrintActiveRM], [debugWidgetsRebuild] and [debugErrorWithStackTrace]
  static bool debugError = false;

  ///If true (default), print error message and stack trace
  ///
  ///Default value is false
  ///
  ///See : [debugPrintActiveRM], [debugWidgetsRebuild] and [debugError]
  static bool debugErrorWithStackTrace = false;

  static void Function(dynamic e, StackTrace s) errorLog;
}

final _navigate = _Navigate();
final _scaffold = _Scaffold();

class _Navigate {
  ///get the NavigatorState
  NavigatorState get navigatorState {
    final navigatorState = _navigatorKey.currentState;
    assert(navigatorState != null, '''
The MaterialApp has no defined navigatorKey.

To fix:
MaterialApp(
   navigatorKey: RM.navigate.navigatorKey,
   //
   //
)
''');
    return navigatorState;
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey {
    return _navigatorKey;
  }

  ///navigate to the given page.
  ///
  ///Equivalent to: [NavigatorState.push]
  Future<T> to<T extends Object>(Widget page) {
    return navigatorState.push<T>(
      MaterialPageRoute<T>(
        builder: (_) => page,
      ),
    );
  }

  ///Navigate to the page with the given named route.
  ///
  ///Equivalent to: [NavigatorState.pushNamed]
  Future<T> toNamed<T extends Object>(String routeName, {Object arguments}) {
    return navigatorState.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  ///Navigate to the given page, and remove the current route and replace it
  ///with the new one.
  ///
  ///Equivalent to: [NavigatorState.pushReplacement]
  Future<T> toReplacement<T extends Object, TO extends Object>(
    Widget page, {
    TO result,
  }) {
    return navigatorState.pushReplacement<T, TO>(
      MaterialPageRoute<T>(
        builder: (_) => page,
      ),
      result: result,
    );
  }

  ///Navigate to the page with the given named route, and remove the current
  ///route and replace it with the new one.
  ///
  ///Equivalent to: [NavigatorState.pushReplacementNamed]
  Future<T> toReplacementNamed<T extends Object, TO extends Object>(
      String routeName,
      {TO result,
      Object arguments}) {
    return navigatorState.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  ///Navigate to the given page, and then remove all the previous routes until
  ///meeting the route with defined route name [untilRouteName].
  ///
  ///If no route name is given ([untilRouteName] is null) , all routes will be
  ///removed except the new page route.
  ///
  ///Equivalent to: [NavigatorState.pushAndRemoveUntil]
  Future<T> toAndRemoveUntil<T extends Object>(
    Widget page, {
    String untilRouteName,
  }) {
    return navigatorState.pushAndRemoveUntil<T>(
      MaterialPageRoute<T>(
        builder: (_) => page,
      ),
      untilRouteName != null
          ? ModalRoute.withName(untilRouteName)
          : (r) => false,
    );
  }

  ///Navigate to the page with the given named route (first argument), and then
  ///remove all the previous routes until meeting the route with defined route
  ///name [untilRouteName].
  ///
  ///If no route name is given ([untilRouteName] is null) , all routes will be
  ///removed except the new page route.
  ///
  ///Equivalent to: [NavigatorState.pushNamedAndRemoveUntil]
  Future<T> toNamedAndRemoveUntil<T extends Object>(String newRouteName,
      {String untilRouteName, Object arguments}) {
    return navigatorState.pushNamedAndRemoveUntil<T>(
      newRouteName,
      untilRouteName != null
          ? ModalRoute.withName(untilRouteName)
          : (r) => false,
      arguments: arguments,
    );
  }

  ///Navigate back to the last page, ie
  ///Pop the top-most route off the navigator.
  ///
  ///Equivalent to: [NavigatorState.pop]
  void back<T extends Object>([T result]) {
    navigatorState.pop<T>(result);
  }

  ///Navigate back and remove all the previous routes until meeting the route
  ///with defined name
  ///
  ///Equivalent to: [NavigatorState.popUntil]
  void backUntil(String untilRouteName) {
    return navigatorState.popUntil(
      ModalRoute.withName(untilRouteName),
    );
  }

  ///Navigate back than to the page with the given named route
  ///
  ///Equivalent to: [NavigatorState.popAndPushNamed]
  Future<T> backAndToNamed<T extends Object, TO extends Object>(
    String routeName, {
    TO result,
    Object arguments,
  }) {
    return navigatorState.popAndPushNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  ///Displays a Material dialog above the current contents of the app, with
  ///Material entrance and exit animations, modal barrier color, and modal
  ///barrier behavior (dialog is dismissible with a tap on the barrier).
  ///
  ///* Required parameters:
  ///  * [dialog]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [barrierDismissible]: Whether dialog is dismissible when tapping
  /// outside it. Default value is true.
  ///  * [barrierColor]: the color of the modal barrier that darkens everything
  /// the dialog. If null the default color Colors.black54 is used.
  ///  * [useSafeArea]: Whether the dialog should only display in 'safe' areas
  /// of the screen. Default value is true.
  ///
  ///Equivalent to: [showDialog].
  Future<T> toDialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
    Color barrierColor,
    bool useSafeArea = true,
  }) {
    return showDialog<T>(
      context: navigatorState.context,
      builder: (_) => dialog,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
    );
  }

  ///Displays an iOS-style dialog above the current contents of the app, with
  ///iOS-style entrance and exit animations, modal barrier color, and modal
  ///barrier behavior
  ///
  ///* Required parameters:
  ///  * [dialog]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [barrierDismissible]: Whether dialog is dismissible when tapping
  /// outside it. Default value is false.
  ///
  ///Equivalent to: [showCupertinoDialog].
  Future<T> toCupertinoDialog<T>(
    Widget dialog, {
    bool barrierDismissible = false,
  }) {
    return showCupertinoDialog<T>(
      context: navigatorState.context,
      builder: (_) => dialog,
      barrierDismissible: barrierDismissible,
    );
  }

  ///Shows a modal material design bottom sheet that prevents the user from
  ///interacting with the rest of the app.
  ///
  ///A closely related widget is the persistent bottom sheet, which allows
  ///the user to interact with the rest of the app. Persistent bottom sheets
  ///can be created and displayed with the (RM.scaffoldShow.bottomSheet) or
  ///[showBottomSheet] Methods.
  ///
  ///
  ///* Required parameters:
  ///  * [bottomSheet]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [isDismissible]: whether the bottom sheet will be dismissed when user
  /// taps on the scrim. Default value is true.
  ///  * [enableDrag]: whether the bottom sheet can be dragged up and down and
  /// dismissed by swiping downwards. Default value is true.
  ///  * [isScrollControlled]: whether this is a route for a bottom sheet that
  /// will utilize [DraggableScrollableSheet]. If you wish to have a bottom
  /// sheet that has a scrollable child such as a [ListView] or a [GridView]
  /// and have the bottom sheet be draggable, you should set this parameter
  /// to true.Default value is false.
  ///  * [backgroundColor], [elevation], [shape], [clipBehavior] and
  /// [barrierColor]: used to customize the appearance and behavior of modal
  /// bottom sheets
  ///
  ///Equivalent to: [showModalBottomSheet].
  Future<T> toBottomSheet<T>(
    Widget bottomSheet, {
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
    Color backgroundColor,
    double elevation,
    ShapeBorder shape,
    Clip clipBehavior,
    Color barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: navigatorState.context,
      builder: (_) => bottomSheet,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  ///Shows a modal iOS-style popup that slides up from the bottom of the screen.
  ///* Required parameters:
  ///  * [cupertinoModalPopup]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [filter]:
  ///  * [semanticsDismissible]: whether the semantics of the modal barrier are
  /// included in the semantics tree
  Future<T> toCupertinoModalPopup<T>(
    Widget cupertinoModalPopup, {
    ImageFilter filter,
    bool semanticsDismissible,
  }) {
    return showCupertinoModalPopup<T>(
      context: navigatorState.context,
      builder: (_) => cupertinoModalPopup,
      semanticsDismissible: semanticsDismissible,
      filter: filter,
    );
  }
}

class _Scaffold {
  BuildContext _context;

  ScaffoldState get scaffoldState {
    final ctx = _context ?? RM.context;
    try {
      return Scaffold.of(ctx);
    } catch (e) {
      throw Exception(
        '''
No valid BuildContext is defined yet

  Before calling any method a decedent BuildContext of Scaffold must be set.
  This can be done either:
  
  * ```dart
     onPressed: (){
      RM.scaffoldShow.context= context;
      RM.scaffoldShow.bottomSheet(...);
     }
    ```
  * ```dart
     onPressed: (){
      modelRM.setState(
       (s)=> doSomeThing(),
       context:context,
       onData: (_,__){
          RM.scaffoldShow.bottomSheet(...);
        )
      }
     }
    ```
''',
      );
    }
  }

  set context(BuildContext context) => _context = context;

  ///Shows a material design persistent bottom sheet in the nearest [Scaffold].
  ///
  ///The new bottom sheet becomes a [LocalHistoryEntry] for the enclosing
  ///[ModalRoute] and a back button is added to the app bar of the [Scaffold]
  ///that closes the bottom sheet.
  ///
  ///To create a persistent bottom sheet that is not a [LocalHistoryEntry] and
  ///does not add a back button to the enclosing Scaffold's app bar, use the
  ///[Scaffold.bottomSheet] constructor parameter.
  ///
  ///A closely related widget is a modal bottom sheet, which is an alternative
  ///to a menu or a dialog and prevents the user from interacting with the
  ///rest of the app. Modal bottom sheets can be created and displayed with
  ///the [_Navigate.toBottomSheet] or [showModalBottomSheet] Methods.
  ///
  ///Returns a controller that can be used to close and otherwise manipulate
  ///the bottom sheet.
  ///
  ///
  ///* Required parameters:
  ///  * [bottomSheet]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [backgroundColor], [elevation], [shape], and [clipBehavior] : used to
  /// customize the appearance and behavior of bottom sheet
  ///
  ///Equivalent to: [ScaffoldState.showBottomSheet].
  ///
  ///Before calling any method a decedent BuildContext of Scaffold must be set.
  ///This can be done either:
  ///
  ///* ```dart
  ///   onPressed: (){
  ///    RM.scaffoldShow.context= context;
  ///    RM.scaffoldShow.bottomSheet(...);
  ///   }
  ///  ```
  ///* ```dart
  ///   onPressed: (){
  ///    modelRM.setState(
  ///     (s)=> doSomeThing(),
  ///     context:context,
  ///     onData: (_,__){
  ///        RM.scaffoldShow.bottomSheet(...);
  ///      )
  ///    }
  ///   }
  ///  ```
  PersistentBottomSheetController<T> bottomSheet<T>(
    Widget bottomSheet, {
    Color backgroundColor,
    double elevation,
    ShapeBorder shape,
    Clip clipBehavior,
  }) {
    final r = scaffoldState.showBottomSheet<T>(
      (_) => bottomSheet,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
    );
    _context = null;
    return r;
  }

  ///Shows a [SnackBar] at the bottom of the scaffold.
  ///
  ///* Required parameters:
  ///  * [snackBar]:  (positional parameter) The SnackBar to display.
  /// * optional parameters:
  ///  * [hideCurrentSnackBar]: Whether to hide the current SnackBar (if any).
  /// Default value is true.
  ///
  ///Equivalent to: [ScaffoldState.showSnackBar].
  ///
  ///Before calling any method a decedent BuildContext of Scaffold must be set.
  ///This can be done either:
  ///
  ///* ```dart
  ///   onPressed: (){
  ///    RM.scaffoldShow.context= context;
  ///    RM.scaffoldShow.snackBar(...);
  ///   }
  ///  ```
  ///* ```dart
  ///   onPressed: (){
  ///    modelRM.setState(
  ///     (s)=> doSomeThing(),
  ///     context:context,
  ///     onData: (_,__){
  ///        RM.scaffoldShow.snackBar(...);
  ///      )
  ///    }
  ///   }
  ///  ```
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar<T>(
    SnackBar snackBar, {
    bool hideCurrentSnackBar = true,
  }) {
    if (hideCurrentSnackBar) {
      scaffoldState.hideCurrentSnackBar();
    }
    final r = scaffoldState.showSnackBar(snackBar);
    _context = null;
    return r;
  }

  ///Opens the [Drawer] (if any).
  ///
  ///Before calling any method a decedent BuildContext of Scaffold must be set.
  ///This can be done either:
  ///
  ///Equivalent to: [ScaffoldState.openDrawer].
  ///
  ///* ```dart
  ///   onPressed: (){
  ///    RM.scaffoldShow.context= context;
  ///    RM.scaffoldShow.openDrawer();
  ///   }
  ///  ```
  ///* ```dart
  ///   onPressed: (){
  ///    modelRM.setState(
  ///     (s)=> doSomeThing(),
  ///     context:context,
  ///     onData: (_,__){
  ///        RM.scaffoldShow.openDrawer();
  ///      )
  ///    }
  ///   }
  ///  ```
  void openDrawer<T>() {
    scaffoldState.openDrawer();
    _context = null;
  }

  ///Opens the end side [Drawer] (if any).
  ///
  ///Before calling any method a decedent BuildContext of Scaffold must be set.
  ///This can be done either:
  ///
  //Equivalent to: [ScaffoldState.openEndDrawer].
  ///
  ///* ```dart
  ///   onPressed: (){
  ///    RM.scaffoldShow.context= context;
  ///    RM.scaffoldShow.openEndDrawer();
  ///   }
  ///  ```
  ///* ```dart
  ///   onPressed: (){
  ///    modelRM.setState(
  ///     (s)=> doSomeThing(),
  ///     context:context,
  ///     onData: (_,__){
  ///        RM.scaffoldShow.openEndDrawer();
  ///      )
  ///    }
  ///   }
  ///  ```
  void openEndDrawer<T>() {
    scaffoldState.openEndDrawer();
    _context = null;
  }
}
