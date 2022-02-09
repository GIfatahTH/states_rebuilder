part of '../../rm.dart';

abstract class Injected<T> extends ReactiveModel<T> {
  factory Injected.generic({
    required Object? Function() creator,
    required T? initialState,
    required SideEffects<T>? sideEffects,
    required StateInterceptor<T>? stateInterceptor,
    required bool autoDisposeWhenNotUsed,
    required String? debugPrintWhenNotifiedPreMessage,
    required Object? Function(T?)? toDebugString,
    required int undoStackLength,
    required PersistState<T> Function()? persist,
    required DependsOn<T>? dependsOn,
    Object? Function(T? s)? watch,
  }) =>
      undoStackLength > 0 || persist != null
          ? InjectedImpRedoPersistState<T>(
              creator: creator,
              initialState: initialState,
              sideEffects: sideEffects,
              stateInterceptor: stateInterceptor,
              autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
              debugPrintWhenNotifiedPreMessage:
                  debugPrintWhenNotifiedPreMessage,
              toDebugString: toDebugString,
              undoStackLength: undoStackLength,
              persist: persist,
              dependsOn: dependsOn,
              watch: watch,
            )
          : InjectedImp<T>(
              creator: creator,
              initialState: initialState,
              sideEffectsGlobal: sideEffects,
              stateInterceptor: stateInterceptor,
              autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
              debugPrintWhenNotifiedPreMessageGlobal:
                  debugPrintWhenNotifiedPreMessage,
              toDebugString: toDebugString,
              dependsOn: dependsOn,
              watch: watch,
            );

  factory Injected({
    required T Function() creator,
    T? initialState,
    SideEffects<T>? sideEffects,
    StateInterceptor<T>? stateInterceptor,
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    DependsOn<T>? dependsOn,
  }) =>
      Injected<T>.generic(
        creator: creator,
        initialState: initialState,
        sideEffects: sideEffects,
        stateInterceptor: stateInterceptor,
        autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
        debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
        toDebugString: toDebugString,
        undoStackLength: undoStackLength,
        persist: persist,
        dependsOn: dependsOn,
      );

  factory Injected.future({
    required Future<T> Function() creator,
    T? initialState,
    SideEffects<T>? sideEffects,
    StateInterceptor<T>? stateInterceptor,
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    DependsOn<T>? dependsOn,
    bool isLazy = false,
  }) {
    final inj = Injected<T>.generic(
      creator: creator,
      initialState: initialState,
      sideEffects: sideEffects,
      stateInterceptor: stateInterceptor,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
      undoStackLength: undoStackLength,
      persist: persist,
      dependsOn: dependsOn,
    );

    return inj;
  }

  factory Injected.stream({
    required Stream<T> Function() creator,
    T? initialState,
    SideEffects<T>? sideEffects,
    StateInterceptor<T>? stateInterceptor,
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    DependsOn<T>? dependsOn,
    Object? Function(T? s)? watch,
  }) =>
      Injected<T>.generic(
        creator: creator,
        initialState: initialState,
        sideEffects: sideEffects,
        stateInterceptor: stateInterceptor,
        autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
        debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
        toDebugString: toDebugString,
        undoStackLength: undoStackLength,
        persist: persist,
        dependsOn: dependsOn,
        watch: watch,
      );

  ///{@template inherited}
  ///Provide the injected model using an [InheritedWidget] that wraps its state.
  ///
  ///By default the [InheritedWidget] holds the state of the injected model,
  ///but this can be overridden using the [stateOverride] parameter.
  ///
  ///Child widgets can obtain the wrapped state using `.of(context)` or
  ///`.call(context)` methods.
  ///
  ///* `myModel.of(context)` looks up in the widget tree to find the state of
  ///`myModel` and register  the `BuildContext` to rebuild when `myModel` is
  ///notified.
  ///
  ///* `myModel.call(context) or myModel(context)` looks up in the widget tree
  ///to find the injected model `myModel` without registering the `BuildContext`.
  ///
  ///ex:
  ///
  ///```dart
  ///final counter1 = RM.inject<int>(()=> 0);
  ///final counter2 = RM.inject<int>(()=> 0);
  ///
  ///class MyApp extends StatelessWidget{
  ///
  /// Widget build(context){
  ///  counter1.inherited(
  ///   builder: (context):{
  ///     return counter2.inherited(
  ///       builder: (context){
  ///         //Getting the counters state using `of` will
  ///         //resister this BuildContext
  ///         final int counter1State = counter1.of(context);
  ///         //Although both counters are of the same type we get
  ///         //the right state
  ///         final int counter2State = counter2.of(context);
  ///
  ///
  ///         //Getting the counters using the `call` method will
  ///         //not register this BuildContext
  ///          final Injected<int> counter1 = counter1(context);
  ///          final Injected<int> counter2 = counter2(context);
  ///       }
  ///     )
  ///   }
  ///  )
  /// }
  ///}
  ///```
  ///
  /// * **Required parameters**:
  ///     * **builder**: Callback to be rendered. It exposed the [BuildContext].
  /// * Optional parameters:
  ///     * **stateOverride**: CallBack to override the exposed state.
  ///     * **connectWithGlobal**: If state is overridden, whether to mutate the
  /// global
  ///     * **debugPrintWhenNotifiedPreMessage**: if not null, print an
  /// informative message when this model is notified in the debug mode.The
  /// entered message will pré-append the debug message. Useful if the type
  /// of the injected
  /// model is primitive to distinguish
  /// {@endtemplate}
  Widget inherited({
    Key? key,
    required Widget Function(BuildContext) builder,
    required FutureOr<T> Function()? stateOverride,
    bool connectWithGlobal = true,
    SideEffects<T>? sideEffects,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(T?)? toDebugStringGlobal,
    // bool keepAlive = false,
  });

  ///Provide the Injected model to another widget tree branch.
  Widget reInherited({
    Key? key,
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    // bool keepAlive = false,
    // String? debugPrintWhenNotifiedPreMessage,
    // String Function(T?)? toDebugString,
  });

  ///Obtain the state from the nearest [InheritedWidget] inserted using [inherited].
  ///
  ///The [BuildContext] used, will be registered so that when this Injected model emits
  ///a notification, the [Element] related the the [BuildContext] will rebuild.
  ///
  ///If you want to obtain the state without registering use the [call] method.
  ///
  ///```dart
  ///myModel.of(context); // Will return the state and register the BuildContext.
  ///myModel(context); // Will return the Injected model and do not register the BuildContext.
  ///```
  ///
  T of(BuildContext context, {bool defaultToGlobal = false});

  ///Obtain the Injected model from the nearest [InheritedWidget] inserted using [inherited].
  ///
  ///The [BuildContext] used, will not be registered.
  ///
  ///If you want to obtain the state and  register it use the [of] method.
  ///
  ///```dart
  ///myModel.of(context); // Will return the state and register the BuildContext.
  ///myModel(context); // Will return the Injected model and do not register the BuildContext.
  ///```
  ///
  Injected<T> call(BuildContext context, {bool defaultToGlobal = false});

  ///Inject a fake implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake creation function
  void injectMock(T Function() fakeCreator);

  ///Inject a fake future implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake future
  void injectFutureMock(Future<T> Function() fakeCreator);

  ///Inject a fake stream implementation of this injected model.
  ///
  ///* Required parameters:
  ///   * [creationFunction] (positional parameter): the fake stream
  void injectStreamMock(Stream<T> Function() fakeCreator);

  ///Undo to the last valid state (isWaiting and hasError are ignored)
  void undoState();

  ///Redo to the next valid state (isWaiting and hasError are ignored)
  void redoState();

  ///Clear undoStack;
  void clearUndoStack();

  ///Whether the state can be redone.
  bool get canRedoState;

  ///Whether the state can be done
  bool get canUndoState;

  ///Persist the state
  void persistState();

  ///Delete the state form the persistence store
  void deletePersistState();
}
