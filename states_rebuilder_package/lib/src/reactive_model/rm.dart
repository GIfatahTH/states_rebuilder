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
    // assert(
    //   InjectorState.contextSet.isNotEmpty,
    //   'No `BuildContext` is found. To get a valid `BuildContext` you have to '
    //   'use at least one of the following widgets under the the `MaterialApp` widget:\n'
    //   '`UseInjected`, `StateBuilder`, `WhenRebuilder`, `WhenRebuilderOR` or `Injector`',
    // );
    if (InjectorState.contextSet.isEmpty) {
      return null;
    }
    if (InjectorState.contextSet.last?.findRenderObject()?.attached != true) {
      InjectorState.contextSet.removeLast();
      return context;
    }

    return context = InjectorState.contextSet.last;
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
  static NavigatorState get navigator {
    try {
      return Navigator.of(context);
    } catch (e) {
      rethrow;
    }
  }

  ///Get the [ScaffoldState]
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static ScaffoldState get scaffold {
    return Scaffold.of(context);
  }

  ///A callBack that exposes an active [BuildContext]
  ///
  ///  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets context;
  ///[Injector], [StateBuilder], ... .
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
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
