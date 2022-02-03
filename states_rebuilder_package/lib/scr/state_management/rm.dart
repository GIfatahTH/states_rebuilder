import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../development_booster/injected_animation/injected_animation.dart';
import '../development_booster/injected_auth/injected_auth.dart';
import '../development_booster/injected_crud/injected_crud.dart';
import '../development_booster/injected_form_field/injected_text_editing.dart';
import '../development_booster/injected_i18n/injected_i18n.dart';
import '../development_booster/injected_scrolling/injected_scrolling.dart';
import '../development_booster/injected_tab/injected_page_tab.dart';
import '../development_booster/injected_theme/injected_theme.dart';
import '../navigation/injected_navigator.dart';
import 'common/consts.dart';
import 'common/logger.dart';
import 'legacy/injector.dart';

part './common/depends_on.dart';
part './common/global.dart';
part './common/side_effects.dart';
part './common/type_def.dart';
part './injected/inherited_injected.dart';
part './injected/injected.dart';
part './injected/injected_imp.dart';
part './injected/undo_redo_persist_state/i_persist_state_mock.dart';
part './injected/undo_redo_persist_state/i_persist_store.dart';
part './injected/undo_redo_persist_state/injected_imp_redo_persit_state.dart';
part './injected/undo_redo_persist_state/persist_state.dart';
part './injected/undo_redo_persist_state/undo_redo_persist_state.dart';
part './listeners/on_builder.dart';
part './listeners/reactive_stateless_widget.dart';
part './listeners/stateful_widget_imp.dart';
part './listeners/top_stateless_widget.dart';
part './listeners/top_widget.dart';
part './reactive_model/reactive_model.dart';
part './reactive_model/reactive_model_imp.dart';
part './reactive_model/snap_state.dart';

abstract class RM {
  /// Injection of a primitive, enum, or object.
  ///
  /// State can be injected globally or scoped locally:
  ///
  /// Scoped locally means that the state's flow is encapsulated within the widget
  /// and its children. If more than one widget is created, each has its own
  /// independent state.
  ///
  /// * Global state:
  ///
  ///   ```dart
  ///   //In the global scope
  ///   final myState = RM.inject(() => MyState())
  ///   ```
  ///   // Or Encapsulate it inside a business logic class (BLOC):
  ///   ```dart
  ///   //For the sake of best practice, one strives to make the class immutable
  ///   @immutable
  ///   class MyBloc {  // or MyViewModel, or MyController
  ///     final _myState1 = RM.inject(() => MyState1())
  ///     final _myState2 = RM.inject(() => MyState2())
  ///
  ///     //Other logic that mutate _myState1 and _myState2
  ///   }
  ///
  ///   //As MyBloc is immutable, it is safe to instantiate it globally
  ///   final myBloc = MyBloc();
  ///   ```
  ///
  /// * Scoped state (local state)
  ///
  ///   If the state or the Bloc are configurable (parametrized), Just declare
  ///   them globally and override the state in the widget tree.
  ///
  ///   BloC stands for Business Logic, and when it is attached to the widget
  ///   tree it becomes a Presentation logic or view model.
  ///   ```dart
  ///   // The state will be initialized in the widget tree.
  ///   final myState = RM.inject(() => throw UnimplementedError())
  ///
  ///   // In the widget tree
  ///   myState.inherited(
  ///     stateOverride: () {
  ///       return MyState(parm1,param2);
  ///     },
  ///     builder: (context) {
  ///       // Read the state through the context
  ///       final _myState = myState.of(context);
  ///     }
  ///   )
  ///   ```
  ///   Similar with Blocs
  ///   ```dart
  ///   final myBloC = RM.inject<myBloC>(() => throw UnimplementedError())
  ///
  ///   //In the widget tree
  ///   myState.inherited(
  ///     stateOverride: () {
  ///       return myBloC(parm1, param2);
  ///     },
  ///     builder: (context) {
  ///       final _myBloC = myBloC.of(context);
  ///     }
  ///   )
  ///   ```
  /// ## Parameters:
  /// ### `creator`: Required callback that returns `<T>`
  /// A callback that is used to create an instance of the injected object.
  /// It is called when:
  ///   * The state is first initialized
  ///   * The state is refreshed by calling [InjectedBase.refresh] method.
  ///   * Any of the states that it depends on emits a notification.
  ///
  /// {@template injectOptionalParameter}
  /// ### `initialState`: Optional `<T>`
  /// The initial state. It is useful when injecting Future or Stream. If you
  /// try to get the state of non-resolved Future or Stream of non-nullable state,
  /// it will throw if `initialState` is not defined.
  ///
  /// ### `autoDisposeWhenNotUsed`: Optional [bool] (Default true)
  /// Whether to auto dispose the injected model when no longer used
  /// (listened to).
  ///
  /// It is important to note that:
  /// * A state never listened to for rebuild, never auto dispose even after it
  /// is mutated.
  /// * By default, all states consumed in the widget tree will auto dispose.
  /// * It is recommended to manually dispose state that are not auto disposed
  /// using [InjectedBaseState.dispose]. You can dispose all states of the app
  /// using [RM.disposeAll].
  /// * A state will auto dispose if all states it depends on are disposed of.
  /// * Non disposed state may lead to unexpected behavior.
  /// * To debug when state is initialized and disposed of use
  /// `debugPrintWhenNotifiedPreMessage` parameter (See below)
  ///
  /// ### `sideEffects`: Optional [SideEffects]
  /// Used to handle sideEffects when the state is initialized, mutated and
  /// disposed of. Side effects defined here are called global (default) and
  /// can be overridden when calling [InjectedBase.setState] method.
  ///
  /// See also: [InjectedBase.setState], [OnBuilder.sideEffectsGlobal] and [OnReactive.sideEffectsGlobal]
  ///
  /// ### `onInitialized`: Optional callback That exposed the state
  /// Callback to be executed after the injected model is first created. It is
  /// similar to [SideEffects.initState] except that it exposes the state for
  /// some useful cases.
  ///
  /// If the injected state is stream, onInitialized additionally exposes the
  /// [StreamSubscription] object to be able to pause the stream.
  ///
  /// ### `dependsOn`: optional [DependsOn]
  /// Use to defined other injected states that this state depends on. When
  /// any of states it depends on is notified, this state is also notified and
  /// its creator is re-invoked. The state status will reflect a combination of
  /// the state status of dependencies:
  /// * If any of dependency state isWaiting, this state isWaiting.
  /// * If any of dependency state hasError, this state hasError.
  /// * If any of dependency state isIdle, this state isIdle.
  /// * If all dependency states have data, this state hasData.
  ///
  /// You can set when the state should be recreated, the time of debounce
  /// and the time of throttle.
  ///
  /// ### `undoStackLength`: Optional integer
  /// It defines the length of the undo/redo stack. If not defined, the
  /// undo/redo is disabled.
  ///
  /// For the undo/redo state to work properly, the state must be immutable.
  ///
  /// Further on to undo or redo the state just call [Injected.undoState] and
  /// [Injected.redoState]
  ///
  /// ### `persist`: Optional callback that return [PersistState]
  /// If defined, the state will be persisted.
  ///
  /// You have to provide a class that implements [IPersistStore] and initialize
  /// it in the main method.
  ///
  /// For example
  /// ```dart
  /// class IPersistStoreImp implements IPersistStore{
  ///  // ....
  /// }
  /// void main()async{
  ///  WidgetsFlutterBinding.ensureInitialized();
  ///
  ///  await RM.storageInitializer(IPersistStoreImp());
  ///  runApp(MyApp());
  /// }
  /// ```
  /// By default, the state is persisted whenever is mutated, but you can set it
  /// to be persisted manually, or once the state is disposed of.
  ///
  /// You can debounce and throttle state persistence.
  ///
  /// ### `stateInterceptor`: Optional callback that exposes the current and
  /// next [SnapState]
  /// This call back is fired after on state mutation and exposes both the
  /// current state just before mutation and the next state.
  ///
  /// The callback return the next [SnapState]. It may be the same as the next state
  /// or you can change it. Useful in many scenarios where we want to concatenate
  /// both current and next snap (fetch for list of items is an example);
  ///
  /// Example:
  /// ```dart
  /// final myState = RM.inject(
  ///  () => [],
  ///  stateInterceptor: (currentSnap, nextSnap) {
  ///    return nextSnap.copyTo(data: [
  ///      ...currentSnap.state,
  ///      ...nextSnap.state,
  ///    ]);
  ///  },
  /// );
  /// /// later on
  /// myState.state = ['one'];
  /// print(myState.state); // ['one']
  ///
  /// myState.state = ['two'];
  /// print(myState.state); // ['one', 'two']
  ///
  /// ```
  ///
  /// ### `debugPrintWhenNotifiedPreMessage`: Optional [String]
  /// if not null, print an informative message when this model is notified in
  /// the debug mode. It prints (FROM ==> TO state). The entered message will
  /// pré-append the debug message. Useful if the type of the injected model
  /// is primitive to distinguish between them.
  ///
  /// ### `toDebugString`: Optional callback that exposes the state
  /// String representation of the state to be used in
  ///  `debugPrintWhenNotifiedPreMessage`. Useful, for example, if the state is a
  ///  collection and you want to print its length only.
  ///  {@endtemplate}
  ///
  static Injected<T> inject<T>(
    T Function() creator, {
    T? initialState,
    StateInterceptor<T>? stateInterceptor,
    // void Function(T? s)? onInitialized,
    SideEffects<T>? sideEffects,
    DependsOn<T>? dependsOn,
    // //
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    // //
    // bool isLazy = true,
    // //
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
  }) {
    return Injected<T>(
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
    // late final InjectedImp<T> inj;

    // return inj = InjectedImp<T>(
    //   creator: creator,
    //   initialState: initialState,
    //   onInitialized: sideEffects?.initState != null
    //       ? (_) => sideEffects!.initState!()
    //       : onInitialized,
    //   onSetState: On(
    //     () {
    //       sideEffects
    //         ?..onSetState?.call(inj.snapState)
    //         ..onAfterBuild?.call();
    //       onSetState?.call(inj.snapState);
    //     },
    //   ),
    //   onWaiting: onWaiting,
    //   onDataForSideEffect: onData,
    //   onError: onError,
    //   onDisposed: sideEffects?.dispose != null
    //       ? (_) => sideEffects!.dispose!()
    //       : onDisposed,
    //   dependsOn: dependsOn,
    //   undoStackLength: undoStackLength,
    //   persist: persist,
    //   middleSnapState: stateInterceptor != null
    //       ? (middleSnap) => stateInterceptor(
    //             middleSnap.currentSnap,
    //             middleSnap.nextSnap,
    //           )
    //       : middleSnapState,
    //   isLazy: isLazy,
    //   debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    //   toDebugString: toDebugString,
    //   autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    // );
  }

  /// injection of a [Future].
  ///
  /// ## Parameters:
  /// ### `creator`: Required callback that returns [Future]
  /// A callback that is used to create an instance of the injected object.
  /// It is called when:
  ///   * The state is first initialized
  ///   * The state is refreshed by calling [InjectedBase.refresh] method.
  ///   * Any of the states that it depends on emits a notification.
  ///
  /// {@macro injectOptionalParameter}
  static Injected<T> injectFuture<T>(
    Future<T> Function() creator, {
    T? initialState,
    StateInterceptor<T>? stateInterceptor,
    // void Function(T? s)? onInitialized,
    SideEffects<T>? sideEffects,
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    //
    // bool isLazy = true,
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
  }) {
    return Injected.future(
      creator: creator,
      initialState: initialState,
      stateInterceptor: stateInterceptor,
      sideEffects: sideEffects,
      undoStackLength: undoStackLength,
      dependsOn: dependsOn,
      persist: persist,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
      // isLazy: isLazy,
    );
    // late final InjectedImp<T> inj;
    // return inj = InjectedImp<T>(
    //   creator: creator,
    //   initialState: initialState,
    //   // onInitialized: onInitialized,
    //   onWaiting: onWaiting,
    //   onDataForSideEffect: onData,
    //   onError: onError,
    //   onDisposed: sideEffects?.dispose != null
    //       ? (_) => sideEffects!.dispose!()
    //       : onDisposed,
    //   onInitialized: sideEffects?.initState != null
    //       ? (_) => sideEffects!.initState!()
    //       : onInitialized,
    //   onSetState: On(
    //     () {
    //       sideEffects
    //         ?..onSetState?.call(inj.snapState)
    //         ..onAfterBuild?.call();
    //     },
    //   ),
    //   dependsOn: dependsOn,
    //   isAsyncInjected: true,
    //   undoStackLength: undoStackLength,
    //   persist: persist,
    //   middleSnapState: stateInterceptor != null
    //       ? (middleSnap) => stateInterceptor(
    //             middleSnap.currentSnap,
    //             middleSnap.nextSnap,
    //           )
    //       : middleSnapState,
    //   isLazy: isLazy,
    //   debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    //   toDebugString: toDebugString,
    //   autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    // );
  }

  /// injection of a [Stream].
  ///
  /// ## Parameters:
  /// ### `creator`: Required callback that returns [Stream]
  /// A callback that is used to create an instance of the injected object.
  /// It is called when:
  ///   * The state is first initialized
  ///   * The state is refreshed by calling [InjectedBase.refresh] method.
  ///   * Any of the states that it depends on emits a notification.
  ///
  /// {@macro injectOptionalParameter}
  ///   * **watch**: Object to watch its change, and do not notify listener if
  /// not changed after the stream emits data.
  static Injected<T> injectStream<T>(
    Stream<T> Function() creator, {
    T? initialState,
    StateInterceptor<T>? stateInterceptor,
    void Function(T? s, StreamSubscription subscription)? onInitialized,
    SideEffects<T>? sideEffects,
    DependsOn<T>? dependsOn,
    PersistState<T> Function()? persist,
    int undoStackLength = 0,
    //
    // bool isLazy = true,
    bool autoDisposeWhenNotUsed = true,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
    //
    Object? Function(T? s)? watch,
  }) {
    late final Injected<T> inj;
    inj = Injected.stream(
      creator: creator,
      initialState: initialState,
      stateInterceptor: stateInterceptor,
      sideEffects: SideEffects<T>(
        initState: () {
          onInitialized?.call(
            inj.snapState.data,
            (inj as ReactiveModelImp<T>).subscription!,
          );
          sideEffects?.initState?.call();
        },
        dispose: () {
          sideEffects?.initState?.call();
        },
        onSetState: (snap) => sideEffects?.onSetState?.call(snap),
        onAfterBuild: () => sideEffects?.onAfterBuild?.call(),
      ),
      undoStackLength: undoStackLength,
      dependsOn: dependsOn,
      persist: persist,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
      watch: watch,
    );
    return inj;
    // late final InjectedImp<T> inj;
    // inj = InjectedImp<T>(
    //   creator: creator,
    //   initialState: initialState,
    //   // onInitialized: onInitialized != null
    //   //     ? (s) => onInitialized(s, inj.subscription!)
    //   //     : null,
    //   onWaiting: onWaiting,
    //   onDataForSideEffect: onData,
    //   onError: onError,
    //   onDisposed: sideEffects?.dispose != null
    //       ? (_) => sideEffects!.dispose!()
    //       : onDisposed,
    //   onInitialized: sideEffects?.initState != null
    //       ? (_) => sideEffects!.initState!()
    //       : onInitialized != null
    //           ? (s) => onInitialized(s, inj.subscription!)
    //           : null,
    //   onSetState: On(
    //     () {
    //       sideEffects
    //         ?..onSetState?.call(inj.snapState)
    //         ..onAfterBuild?.call();
    //       onSetState?.call(inj.snapState);
    //     },
    //   ),
    //   dependsOn: dependsOn,
    //   isAsyncInjected: true,
    //   undoStackLength: undoStackLength,
    //   middleSnapState: (s) {
    //     final SnapState<T> snap = (stateInterceptor != null
    //             ? stateInterceptor(
    //                 s.currentSnap,
    //                 s.nextSnap,
    //               )
    //             : middleSnapState != null
    //                 ? middleSnapState(s)
    //                 : null) ??
    //         s.nextSnap;
    //     if (watch != null && s.currentSnap.hasData && snap.hasData) {
    //       final can = watch(s.currentSnap.data) == watch(snap.data);
    //       if (can) {
    //         return SkipSnapState<T>();
    //       }
    //     }
    //     return snap;
    //   },
    //   persist: persist,
    //   autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    //   debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    //   toDebugString: toDebugString,
    // );
    // if (!isLazy) {
    //   inj.initialize();
    // }
    // return inj;
  }

  /// Injection of a state that can authenticate and authorize
  /// a user.
  ///
  /// This injected state abstracts the best practices of the clean
  /// architecture to come out with a simple, clean, and testable approach
  /// to manage user authentication and authorization.
  ///
  /// The approach consists of the following steps:
  /// * Define the User Model. (The name is up to you).
  /// * You may define a class (or enum) to parametrize the query.
  /// * Your repository must implements [IAuth]<T, P> where T is the User type
  ///  and P is the parameter
  /// type. with `IAuth<T, P>` you define sign-(in, up , out) methods.
  /// * Instantiate an [InjectedAuth] object using [RM.injectAuth] method.
  /// * Later on use [InjectedAuth.auth].signUp, [InjectedAuth.auth].signIn, and
  /// [InjectedAuth.auth].signOut for sign up, sign in, sign out.
  /// * In the UI you can use [OnAuthBuilder] to listen the this injected state
  /// and define the appropriate view for each state.
  ///
  /// ## Parameters:
  /// ### `repository`: Required callback that returns an object that implements [IAuth]<T, P>
  ///
  /// [IAuth]<T, P> forces you to implement the following methods:
  /// 1. `Future<void> init()` to initialize your authentication service (if it
  /// deeds to).
  /// 2. `Future<T> signIn(P? param)` To sign in using your authentication
  /// service. With param you can parametrize your query
  /// Example:
  ///
  ///     ```
  ///        @override
  ///        Future<User> signIn(UserParam param) {
  ///          switch (param.signIn) {
  ///            case SignIn.anonymously:
  ///              return _signInAnonymously();
  ///            case SignIn.withGoogle:
  ///              return _signInWithGoogle();
  ///            case SignIn.withEmailAndPassword:
  ///              return _signInWithEmailAndPassword(
  ///                param.email,
  ///                param.password,
  ///              );
  ///
  ///            default:
  ///              throw UnimplementedError();
  ///          }
  ///        }
  ///     ```
  /// 3. `Future<T> signUp(P? param)` To sign up
  /// 4. `Future<T> signOut(P? param)` To sign out
  /// 5. `Future<T> refreshToken(T currentUser)` To refresh user token
  ///     It exposes the currentUser model, where you get the refresh token.
  ///     If the token is successfully refreshed, a new copy of the current user
  ///     holding the new token is return.
  ///
  ///     Example:
  ///
  ///     ```dart
  ///      @override
  ///      Future<User?>? refreshToken(User? currentUser) async {
  ///
  ///       final response = await http.post( ... );
  ///
  ///       if (response.codeStatus == 200){
  ///        return currentUser!.copyWith(
  ///          token: response.body['id_token'],
  ///          refreshToken: response.body['refresh_token'],
  ///          tokenExpiration: DateTime.now().add(
  ///              Duration(seconds: response.body[expires_in] ),
  ///          ),
  ///        );
  ///       }
  ///
  ///       return null;
  ///
  ///      }
  ///     ```
  /// 6. `void dispose()` To dispose any resources.
  ///
  /// Apart from these six methods, you can define other custom methods and
  /// invoke them using [InjectedAuth.getRepoAs] method.
  ///
  /// ### `unsignedUser`: Optional `T`
  /// An object that represents an unsigned user. If T is nullable unsignedUser
  /// is null. unsignedUser value is used internally to decide to call signed
  /// hooks or unsigned hooks.
  ///
  /// ### `param`: Optional callback that returns `P`
  /// The default param object to be used in [IAuth.signIn], [IAuth.signUp], and
  /// [IAuth.signOut] methods.
  ///
  /// You can override the default value when calling InjectedAuth.auth.signIn
  /// , [InjectedAuth.auth].signUp, [InjectedAuth.auth].signOut
  ///
  /// ### `autoRefreshTokenOrSignOut`: Optional callback that exposes the signed user and returns a [Duration].
  /// After the return duration, the user will try to refresh the token as
  /// implemented in[IAuth.refreshToken].If the token is not refreshed then the
  /// user is sign out.
  ///
  /// See [IAuth.refreshToken]
  ///
  /// ### `onAuthStream`: Optional callback that exposes the repository and
  /// returns a stream.
  /// It is used to listen to a stream from the repository. The stream emits the
  /// value of the currentUser. Depending on the emitted user, sign in or sign
  /// out hooks will be invoked.
  ///
  /// ### `persist`: Optional callback that return [PersistState]
  /// If defined, the signed user will be persisted.
  ///
  /// You have to provide a class that implements [IPersistStore] and initialize
  /// it in the main method.
  ///
  /// For example
  /// ```dart
  /// class IPersistStoreImp implements IPersistStore{
  ///  // ....
  /// }
  /// void main()async{
  ///  WidgetsFlutterBinding.ensureInitialized();
  ///
  ///  await RM.storageInitializer(IPersistStoreImp());
  ///  runApp(MyApp());
  /// }
  /// ```
  ///
  /// If persist is defined the signed user information is persisted and when
  /// the app starts up, the user information is retrieved from the local
  /// storage and it is automatically signed in if it has no expired token.
  ///
  /// Example:
  ///
  /// ```dart
  /// final user = RM.injectAuth<User?, UserParam>(
  ///   () => FireBaseAuth(),
  ///   persist: () => PersistState<User?>(
  ///     key: '__User__',
  ///     toJson: (user) => user?.toJson(),
  ///     fromJson: (json) {
  ///       final user = User.fromJson(json);
  ///       return user.token.isNotExpired ? user : null;
  ///     },
  ///   ),
  /// );
  /// ```
  ///
  /// ### `onSigned`: Optional callback that exposes the signed user
  /// It is used to call side effects when the user is signed.
  ///
  /// ### `onUnSigned`: Optional callback
  /// It is used to call side effects when the user is unsigned.
  ///
  /// ### `stateInterceptor`: Optional callback that exposes the current and
  /// next [SnapState]
  /// This call back is fired after on state mutation (singed user change) and
  /// exposes both the current state just before mutation and the next state.
  ///
  /// The callback return the next [SnapState]. It may be the same as the next state
  /// or you can change it.
  ///
  /// ### `sideEffects`: Optional [SideEffects]
  /// Used to handle sideEffects when the state is initialized, mutated and
  /// disposed of.
  ///
  /// ### `debugPrintWhenNotifiedPreMessage`: Optional [String]
  /// if not null, print an informative message when this model is notified in
  /// the debug mode. It prints (FROM ==> TO state). The entered message will
  /// pré-append the debug message. Useful if the type of the injected model
  /// is primitive to distinguish between them.
  ///
  /// ### `toDebugString`: Optional callback that exposes the state
  /// String representation of the state to be used in
  ///  `debugPrintWhenNotifiedPreMessage`. Useful, for example, if the state is a
  ///  collection and you want to print its length only.
  ///
  static InjectedAuth<T, P> injectAuth<T, P>(
    IAuth<T, P> Function() repository, {
    T? unsignedUser,
    P Function()? param,
    Duration Function(T user)? autoRefreshTokenOrSignOut,
    FutureOr<Stream<T>> Function(IAuth<T, P> repo)? onAuthStream,
    PersistState<T> Function()? persist,
    //
    void Function(T s)? onSigned,
    void Function()? onUnsigned,
    SnapState<T>? Function(
      SnapState<T> currentSnap,
      SnapState<T> nextSnap,
    )?
        stateInterceptor,
    SideEffects<T>? sideEffects,
    //
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
  }) {
    assert(() {
      if (null is! T && unsignedUser == null) {
        StatesRebuilerLogger.log(
          '$T is non-nullable and the unsignedUser is null',
          'You have to define unsignedUser parameter.\n'
              'If you want the unsignedUser to be null use nullable type ($T?)',
        );
        return false;
      }

      return true;
    }());
    assert(() {
      if (null is T && unsignedUser != null) {
        StatesRebuilerLogger.log(
          '$T is nullable, null is considered as the unsigned user',
          'You can not set a non-null unsignedUser\n'
              'If you want the unsignedUSer to be non-null use non-nullable type ($T).',
        );
        return false;
      }

      return true;
    }());

    return InjectedAuthImp(
      repoCreator: repository,
      unsignedUser: unsignedUser,
      param: param,
      autoSignOut: autoRefreshTokenOrSignOut,
      onSigned: onSigned,
      onUnsigned: onUnsigned,
      onAuthStream: onAuthStream,
      stateInterceptor: stateInterceptor,
      sideEffects: sideEffects,
      persist: persist,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );

    // late final InjectedAuthImp<T, P> inj;
    // return inj = InjectedAuthImp<T, P>(
    //   repoCreator: repository,
    //   unsignedUser: unsignedUser,
    //   param: param,
    //   onSigned: onSigned,
    //   onUnsigned: onUnsigned,
    //   autoSignOut: autoRefreshTokenOrSignOut ?? autoSignOut,
    //   onAuthStream: onAuthStream,
    //   //
    //   middleSnapState: stateInterceptor != null
    //       ? (middleSnap) => stateInterceptor(
    //             middleSnap.currentSnap,
    //             middleSnap.nextSnap,
    //           )
    //       : middleSnapState,
    //   sideEffects: SideEffects<T>(
    //     initState: () {
    //       if (sideEffects?.initState != null) {
    //         sideEffects?.initState?.call();
    //       } else {
    //         onInitialized?.call(inj.state);
    //       }
    //     },
    //     onSetState: (snap) {
    //       if (sideEffects?.onSetState != null) {
    //         sideEffects?.onSetState?.call(snap);
    //       } else {
    //         onSetState?.call(snap);
    //       }
    //     },
    //     dispose: () {
    //       if (sideEffects?.dispose != null) {
    //         sideEffects?.dispose?.call();
    //       } else {
    //         onDisposed?.call(inj.state);
    //       }
    //     },
    //   ),
    //   //
    //   persist: persist,
    //   debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    //   toDebugString: toDebugString,
    // );
  }

  /// Injection of a state that can create, read, update and
  /// delete from a backend or database service.
  ///
  /// This injected state abstracts the best practices of the clean
  /// architecture to come out with a simple, clean, and testable approach
  /// to manage CRUD operations.
  ///
  /// The approach consists of the following steps:
  /// * Define an `Item` Model. (The name is up to you).
  /// * You may define a class (or enum) to parametrize the query.
  /// * Your repository must implements [ICRUD]<T, P> where T is the Item type
  ///  and P is the parameter type.
  /// * Instantiate an [InjectedCRUD] object using [RM.injectCRUD] method.
  /// * Later on use [InjectedCRUD.crud].create, [InjectedCRUD.crud].read,
  /// [InjectedCRUD.crud].update, and [InjectedCRUD.crud].delete item.
  /// * In the UI you can use [ReactiveStatelessWidget], [OnReactive],
  /// [ObBuilder], or [OnCRUDBuilder] to listen to this injected state.
  /// * You may use [InjectedCRUD.item].inherited for performant list of item
  /// rendering.
  /// * CRUD methods can be invoked optimistically or pessimistically.
  ///
  ///
  /// ## Parameters:
  /// ### `repository`: Required callback that returns an object that implements [ICRUD]<T, P>
  /// [ICRUD]<T, P> forces you to implement the following methods:
  /// 1. `Future<void> init()` to initialize your CRUD service (if it
  /// deeds to).
  /// 2. `Future<List<T>> read(P? param)` to read a list of Items. With `param` you can parametrize your query
  /// Example:
  ///
  ///     ```
  ///       @override
  ///        Future<List<Item>> read(Param? param) async {
  ///          final items = await http.get('uri/${param.user.id}');
  ///          //After parsing
  ///          return items;
  ///
  ///          //OR
  ///          if(param.queryType=='GetCompletedItems'){
  ///             final items = await http.get('uri/${param.user.id}/completed');
  ///             return items;
  ///          }else if(param.queryType == 'GetActiveItems'){
  ///            final items = await http.get('uri/${param.user.id}/active');
  ///             return items;
  ///          }
  ///        }
  ///     ```
  /// 3. `Future<T> create(T item, P? param)` to create on Item
  /// 4. `Future<dynamic> update(List<T> items, P? param)` to update an item
  /// 4. `Future<dynamic> delete(List<T> items, P? param)` to delete an item
  /// 5. `Future<void> dispose()` to dispose resources.
  ///
  /// Apart from these five methods, you can define other custom methods and
  /// invoke them using [InjectedCRUD.getRepoAs] method.
  ///
  /// ### `param`: Optional callback that returns `P`
  /// The default param object to be used in [ICRUD.create], [ICRUD.read],
  /// [ICRUD.update], and [ICRUD.delete] methods.
  ///
  /// ### `readOnInitialization`: Optional bool. Defaults to false
  /// If true, a read query with the default `param` will sent to the backend
  /// service once the state is initialized.
  ///
  /// ### `onCRUDSideEffects`: Optional [OnCRUDSideEffects] object
  /// Use to perform side effects when the app is waiting for a CRUD operation
  /// to resolve.
  ///
  /// ### `sideEffects`: Optional [SideEffects]
  /// Used to handle side effects when the state is initialized, mutated and
  /// disposed of.
  ///
  /// Both `onCRUDSideEffects` and `sideEffects`  used for side effects. These
  /// are the differences between them.
  /// - In pessimistic mode they are equivalent. The `onWaiting` is called while
  /// waiting for the backend service result.
  /// - In optimistic mode, the difference is in the `onWaiting` hook.
  ///   In `sideEffects` the `onWaiting` in never called.
  /// - `sideEffects` has `onData` callback.
  /// - `onCRUDSideEffects` has `onResult` callback that exposes the return result
  /// for the backend service.
  ///
  /// ### `persist`: Optional callback that return [PersistState]
  /// If defined, the state will be persisted.
  ///
  /// You have to provide a class that implements [IPersistStore] and initialize
  /// it in the main method.
  ///
  /// For example
  /// ```dart
  /// class IPersistStoreImp implements IPersistStore{
  ///  // ....
  /// }
  /// void main()async{
  ///  WidgetsFlutterBinding.ensureInitialized();
  ///
  ///  await RM.storageInitializer(IPersistStoreImp());
  ///  runApp(MyApp());
  /// }
  /// ```
  /// By default, the state is persisted whenever is mutated, but you can set it
  /// to be persisted manually, or once the state is disposed of.
  ///
  /// You can debounce and throttle state persistence.
  ///
  /// ### `stateInterceptor`: Optional callback that exposes the current and
  /// next [SnapState]
  /// This call back is fired after on state mutation and exposes both the
  /// current state just before mutation and the next state.
  ///
  /// The callback return the next [SnapState]. It may be the same as the next state
  /// or you can change it. Useful in many scenarios where we want to concatenate
  /// both current and next snap (fetch for list of items is an example);
  ///
  /// ### `undoStackLength`: Optional integer
  /// It defines the length of the undo/redo stack. If not defined, the
  /// undo/redo is disabled.
  ///
  /// For the undo/redo state to work properly, the state must be immutable.
  ///
  /// Further on, to undo or redo the state just call [Injected.undoState] and
  /// [Injected.redoState]
  ///
  /// ### `dependsOn`: optional [DependsOn]
  /// Use to defined other injected states that this state depends on. When
  /// any of states it depends on is notified, this state is also notified and
  /// its creator is re-invoked. The state status will reflect a combination of
  /// the state status of dependencies:
  /// * If any of dependency state isWaiting, this state isWaiting.
  /// * If any of dependency state hasError, this state hasError.
  /// * If any of dependency state isIdle, this state isIdle.
  /// * If all dependency states have data, this state hasData.
  ///
  /// ### `autoDisposeWhenNotUsed`: Optional [bool] (Default true)
  /// Whether to auto dispose the injected model when no longer used
  /// (listened to).
  ///
  /// It is important to note that:
  /// * A state never listened to for rebuild, never auto dispose even after it
  /// is mutated.
  /// * By default, all states consumed in the widget tree will auto dispose.
  /// * It is recommended to manually dispose state that are not auto disposed
  /// using [InjectedBaseState.dispose]. You can dispose all states of the app
  /// using [RM.disposeAll].
  /// * A state will auto dispose if all states it depends on are disposed of.
  /// * Non disposed state may lead to unexpected behavior.
  /// * To debug when state is initialized and disposed of use
  /// `debugPrintWhenNotifiedPreMessage` parameter (See below)
  ///
  /// ### `debugPrintWhenNotifiedPreMessage`: Optional [String]
  /// if not null, print an informative message when this model is notified in
  /// the debug mode. It prints (FROM ==> TO state). The entered message will
  /// pré-append the debug message. Useful if the type of the injected model
  /// is primitive to distinguish between them.
  ///
  /// ### `toDebugString`: Optional callback that exposes the state
  /// String representation of the state to be used in
  /// `debugPrintWhenNotifiedPreMessage`. Useful, for example, if the state is a
  ///  collection and you want to print its length only.
  static InjectedCRUD<T, P> injectCRUD<T, P>(
    ICRUD<T, P> Function() repository, {
    P Function()? param,
    bool readOnInitialization = false,
    OnCRUDSideEffects? onCRUDSideEffects,
    SideEffects<List<T>>? sideEffects,
    PersistState<List<T>> Function()? persist,
    //
    SnapState<List<T>>? Function(
      SnapState<List<T>> currentSnap,
      SnapState<List<T>> nextSnap,
    )?
        stateInterceptor,
    //
    int undoStackLength = 0,
    DependsOn<List<T>>? dependsOn,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    String Function(List<T>?)? toDebugString,
  }) {
    return InjectedCRUDImp<T, P>(
      repoCreator: repository,
      param: param,
      readOnInitialization: readOnInitialization,
      stateInterceptor: stateInterceptor,
      sideEffects: sideEffects,
      onCRUDSideEffects: onCRUDSideEffects,
      dependsOn: dependsOn,
      persist: persist,
      undoStackLength: undoStackLength,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );
    // late final InjectedCRUDImp<T, P> inj;
    // return inj = InjectedCRUDImp<T, P>(
    //   repoCreator: repository,
    //   param: param,
    //   readOnInitialization: readOnInitialization,
    //   onCRUD: onCRUDSideEffects ?? onCRUD,
    //   //
    //   middleSnapState: stateInterceptor != null
    //       ? (middleSnap) => stateInterceptor(
    //             middleSnap.currentSnap,
    //             middleSnap.nextSnap,
    //           )
    //       : middleSnapState,
    //   onInitialized: sideEffects?.initState != null
    //       ? (_) => sideEffects!.initState!()
    //       : onInitialized,
    //   onDisposed: sideEffects?.dispose != null
    //       ? (_) => sideEffects!.dispose!()
    //       : onDisposed,
    //   onSetState: On(
    //     () {
    //       if (sideEffects?.onSetState != null) {
    //         sideEffects!.onSetState!(inj.snapState);
    //       } else {
    //         onSetState?.call(inj.snapState);
    //       }
    //       sideEffects?.onAfterBuild?.call();
    //     },
    //   ),

    //   //
    //   dependsOn: dependsOn,
    //   undoStackLength: undoStackLength,
    //   persist: persist,
    //   autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    //   debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    //   toDebugString: toDebugString,
    // );
  }

  /// {@macro InjectedTheme}
  ///
  /// ## Parameters:
  ///
  /// ### `lightThemes`: Required `Map<T, ThemeData>`
  /// Map of light themes the app supports. The keys of the Map are the names
  /// of the themes. `T` can be String or enumeration.
  ///
  /// ### `darkThemes`: Optional `Map<T, ThemeData>`
  /// Map of dark themes the app supports. There should be a correspondence
  /// between light and dark themes. Nevertheless, you can have light themes
  /// with no corresponding dark one.
  ///
  /// ### `themeMode`: Optional `ThemeMode`
  /// the [ThemeMode] the app should start with.
  ///
  /// ### `persistKey`: Optional `String`
  /// If defined the app theme is persisted to a local storage. The persisted
  /// theme will be used on app restarting.
  ///
  /// You have to provide a class that implements [IPersistStore] and initialize
  /// it in the main method.
  ///
  /// For example
  /// ```dart
  /// class IPersistStoreImp implements IPersistStore{
  ///  // ....
  /// }
  /// void main()async{
  ///  WidgetsFlutterBinding.ensureInitialized();
  ///
  ///  await RM.storageInitializer(IPersistStoreImp());
  ///  runApp(MyApp());
  /// }
  /// ```
  ///
  /// ### `stateInterceptor`: Optional callback that exposes the current and
  /// next [SnapState]
  /// This call back is fired after on state mutation (singed user change) and
  /// exposes both the current state just before mutation and the next state.
  ///
  /// ### `undoStackLength`: Optional integer
  /// It defines the length of the undo/redo stack. If not defined, the
  /// undo/redo is disabled.
  ///
  /// For the undo/redo state to work properly, the state must be immutable.
  ///
  /// Further on, to undo or redo the state just call [Injected.undoState] and
  /// [Injected.redoState]
  ///
  /// ### `sideEffects`: Optional [SideEffects]
  /// Used to handle sideEffects when the state is initialized, mutated and
  /// disposed of.
  ///
  /// ### `dependsOn`: optional [DependsOn]
  /// Use to defined other injected states that this state depends on. When
  /// any of states it depends on is notified, this state is also notified and
  /// its creator is re-invoked. The state status will reflect a combination of
  /// the state status of dependencies:
  /// * If any of dependency state isWaiting, this state isWaiting.
  /// * If any of dependency state hasError, this state hasError.
  /// * If any of dependency state isIdle, this state isIdle.
  /// * If all dependency states have data, this state hasData.
  ///
  /// ### `autoDisposeWhenNotUsed`: Optional [bool] (Default true)
  /// Whether to auto dispose the injected model when no longer used
  /// (listened to).
  ///
  /// It is important to note that:
  /// * A state never listened to for rebuild, never auto dispose even after it
  /// is mutated.
  /// * By default, all states consumed in the widget tree will auto dispose.
  /// * It is recommended to manually dispose state that are not auto disposed
  /// using [InjectedBaseState.dispose]. You can dispose all states of the app
  /// using [RM.disposeAll].
  /// * A state will auto dispose if all states it depends on are disposed of.
  /// * Non disposed state may lead to unexpected behavior.
  /// * To debug when state is initialized and disposed of use
  /// `debugPrintWhenNotifiedPreMessage` parameter (See below)
  ///
  /// ### `debugPrintWhenNotifiedPreMessage`: Optional [String]
  /// if not null, print an informative message when this model is notified in
  /// the debug mode. It prints (FROM ==> TO state). The entered message will
  /// pré-append the debug message. Useful if the type of the injected model
  /// is primitive to distinguish between them.
  ///
  /// ### `toDebugString`: Optional callback that exposes the state
  /// String representation of the state to be used in
  /// `debugPrintWhenNotifiedPreMessage`. Useful, for example, if the state is a
  ///  collection and you want to print its length only.
  static InjectedTheme<T> injectTheme<T>({
    required Map<T, ThemeData> lightThemes,
    Map<T, ThemeData>? darkThemes,
    ThemeMode themeMode = ThemeMode.system,
    String? persistKey,
    //
    SnapState<T>? Function(
      SnapState<T> currentSnap,
      SnapState<T> nextSnap,
    )?
        stateInterceptor,
    SideEffects<T>? sideEffects,
    //
    int undoStackLength = 0,
    DependsOn<T>? dependsOn,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
  }) {
    return InjectedThemeImp(
      lightThemes: lightThemes,
      darkThemes: darkThemes,
      themeModel: themeMode,
      persistKey: persistKey,
      sideEffects: sideEffects,
      stateInterceptor: stateInterceptor,
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );

    // assert(
    //   T != dynamic && T != Object,
    //   'Type can not inferred, please declare it explicitly',
    // );

    // late final InjectedThemeImp<T> inj;
    // return inj = InjectedThemeImp<T>(
    //   lightThemes: lightThemes,
    //   darkThemes: darkThemes,
    //   themeModel: themeMode,
    //   persistKey: persistKey,
    //   //
    //   middleSnapState: stateInterceptor != null
    //       ? (middleSnap) => stateInterceptor(
    //             middleSnap.currentSnap,
    //             middleSnap.nextSnap,
    //           )
    //       : middleSnapState,
    //   onInitialized: sideEffects?.initState != null
    //       ? (_) => sideEffects!.initState!()
    //       : onInitialized,
    //   onDisposed: sideEffects?.dispose != null
    //       ? (_) => sideEffects!.dispose!()
    //       : onDisposed,
    //   onSetState: On(
    //     () {
    //       if (sideEffects?.onSetState != null) {
    //         sideEffects!.onSetState!(inj.snapState);
    //       } else {
    //         onSetState?.call(inj.snapState);
    //       }
    //       sideEffects?.onAfterBuild?.call();
    //     },
    //   ),
    //   //
    //   dependsOn: dependsOn,
    //   undoStackLength: undoStackLength,
    //   //
    //   autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    //   isLazy: isLazy,
    //   debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    //   toDebugString: toDebugString,
    // );
  }

  /// Injection of a state that handle app internationalization
  /// and localization.
  ///
  ///
  /// This injected state abstracts the best practices of the clean
  /// architecture to come out with a simple, clean, and testable approach
  /// to manage app localization and internationalization.
  ///
  /// The approach consists of the following steps:
  /// * //TODO
  /// ## Parameters:
  ///
  /// ### `i18Ns`: Required `Map<T, FutureOr<T> Function()>`
  /// Map of supported locales with their language translation
  ///
  /// ### `persistKey`: Optional `String`
  /// If defined the app language is persisted to a local storage. The persisted
  /// language will be used on app restarting.
  ///
  /// You have to provide a class that implements [IPersistStore] and initialize
  /// it in the main method.
  ///
  /// For example
  /// ```dart
  /// class IPersistStoreImp implements IPersistStore{
  ///  // ....
  /// }
  /// void main()async{
  ///  WidgetsFlutterBinding.ensureInitialized();
  ///
  ///  await RM.storageInitializer(IPersistStoreImp());
  ///  runApp(MyApp());
  /// }
  /// ```
  ///
  /// ### `stateInterceptor`: Optional callback that exposes the current and
  /// next [SnapState]
  /// This call back is fired after on state mutation (singed user change) and
  /// exposes both the current state just before mutation and the next state.
  ///
  /// ### `undoStackLength`: Optional integer
  /// It defines the length of the undo/redo stack. If not defined, the
  /// undo/redo is disabled.
  ///
  /// For the undo/redo state to work properly, the state must be immutable.
  ///
  /// Further on, to undo or redo the state just call [Injected.undoState] and
  /// [Injected.redoState]
  ///
  /// ### `sideEffects`: Optional [SideEffects]
  /// Used to handle sideEffects when the state is initialized, mutated and
  /// disposed of.
  ///
  /// ### `dependsOn`: optional [DependsOn]
  /// Use to defined other injected states that this state depends on. When
  /// any of states it depends on is notified, this state is also notified and
  /// its creator is re-invoked. The state status will reflect a combination of
  /// the state status of dependencies:
  /// * If any of dependency state isWaiting, this state isWaiting.
  /// * If any of dependency state hasError, this state hasError.
  /// * If any of dependency state isIdle, this state isIdle.
  /// * If all dependency states have data, this state hasData.
  ///
  /// ### `debugPrintWhenNotifiedPreMessage`: Optional [String]
  /// if not null, print an informative message when this model is notified in
  /// the debug mode. It prints (FROM ==> TO state). The entered message will
  /// pré-append the debug message. Useful if the type of the injected model
  /// is primitive to distinguish between them.
  static InjectedI18N<T> injectI18N<T>(
    Map<Locale, FutureOr<T> Function()> i18Ns, {
    String? persistKey,
    //
    SnapState<T>? Function(
      SnapState<T> currentSnap,
      SnapState<T> nextSnap,
    )?
        stateInterceptor,
    SideEffects<T>? sideEffects,
    //
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    //
    // bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
  }) {
    return InjectedI18NImp(
      i18Ns: i18Ns,
      persistKey: persistKey,
      sideEffects: sideEffects,
      stateInterceptor: stateInterceptor,
      dependsOn: dependsOn,
      undoStackLength: undoStackLength,
      autoDisposeWhenNotUsed: true,
      debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
      toDebugString: toDebugString,
    );

    // assert(
    //   T != dynamic && T != Object,
    //   'Type can not inferred, please declare it explicitly',
    // );
    // late final InjectedI18NImp<T> inj;
    // return inj = InjectedI18NImp<T>(
    //   i18Ns: i18Ns,
    //   persistKey: persistKey,
    //   //
    //   middleSnapState: stateInterceptor != null
    //       ? (middleSnap) => stateInterceptor(
    //             middleSnap.currentSnap,
    //             middleSnap.nextSnap,
    //           )
    //       : middleSnapState,
    //   onInitialized: sideEffects?.initState != null
    //       ? (_) => sideEffects!.initState!()
    //       : onInitialized,
    //   onDisposed: sideEffects?.dispose != null
    //       ? (_) => sideEffects!.dispose!()
    //       : onDisposed,
    //   onSetState: On(
    //     () {
    //       if (sideEffects?.onSetState != null) {
    //         sideEffects!.onSetState!(inj.snapState);
    //       } else {
    //         onSetState?.call(inj.snapState);
    //       }
    //       sideEffects?.onAfterBuild?.call();
    //     },
    //   ),
    //   //
    //   dependsOn: dependsOn,
    //   undoStackLength: undoStackLength,
    //   //
    //   // isLazy: isLazy,
    //   debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
    // );
  }

  /// {@macro InjectedTextEditing}
  ///
  /// ## Parameters:
  /// ### `text`: Optional [String]. Defaults to empty string.
  /// The initial text the linked [TextField] displays.
  ///
  /// ### `selection`: Optional [TextSelection]. Defaults to empty `TextSelection.collapsed(offset: -1)`.
  /// The initial text selection the linked [TextField] starts with.
  ///
  /// ### `composing`: Optional [TextRange]. Defaults to empty `TextRange.empty`
  /// The initial range of text the linked [TextField] starts with.
  ///
  /// ### `validators`: Optional List of callbacks.
  /// Set of validation rules the field should pass.
  ///
  /// Validators expose the text that the user entered.
  ///
  /// If any of the validation callbacks return a non-empty string, the filed
  /// is considered non valid. For the field to be valid all validators must
  /// return null.
  ///
  /// example:
  ///   ```dart
  ///      final _email = RM.injectTextEditing(
  ///       validators: [
  ///         (value) {
  ///            //Frontend validation
  ///            if (!Validators.isValidEmail(value)) {
  ///              return 'Enter a valid email';
  ///            }
  ///          },
  ///       ]
  ///     );
  ///   ```
  /// The validations performed here are frontend validation. To do backend
  /// validation you must use [InjectedForm].
  ///
  /// ### `validateOnTyping`: Optional [bool].
  /// Whether to validate the input while the user is typing.
  ///
  /// The default value depends on whether the linked [TextField] is inside or
  /// outside [OnFormBuilder]:
  /// * If outside: it default to true if `validateOnLoseFocus` is false.
  /// * If inside: it defaults to false if [InjectedForm.autovalidateMode] is
  /// [AutovalidateMode.disabled], otherwise it defaults to true.
  ///
  /// If `validateOnTyping` is set to false, the text is not validate on typing.
  /// The text can be validate manually by invoking [InjectedTextEditing.validate].
  ///
  /// ### `validateOnLoseFocus`: Optional [bool].
  /// Whether to validate the input just after the user finishes typing and the
  /// field loses focus.
  ///
  /// It defaults to true if the linked [TextField] is inside [OnFormBuilder]
  /// and defaults to false if it is outside.
  ///
  /// Once the [TextField] loses focus and if it fails to validate, the field will
  /// auto-validate on typing the next time the user starts typing.
  ///
  /// For `validateOnLoseFocus` to work you have to set the [TextField]'s [FocusNode]
  /// to use [InjectedTextEditing.focusNode]
  ///
  /// Example:
  ///   ```dart
  ///     final email =  RM.injectTextEditing():
  ///
  ///     // In the widget tree
  ///    TextField(
  ///       controller: email.controller,
  ///       focusNode: email.focusNode, //It is auto disposed of.
  ///     ),
  ///   ```
  ///
  /// ### `isReadOnly`: Optional [bool]. Defaults to false.
  /// If true the [TextField] is clickable and selectable but not editable.
  /// Later on, you can set it using [InjectedTextEditing.isReadOnly]
  ///
  /// All input fields are set to be read-only if they are inside a [OnFormBuilder]
  /// and the form is waiting for submission to resolve.
  ///
  /// ### `isEnabled`: Optional [bool]. Defaults to true.
  /// If false the [TextField] is disabled.
  /// Later on, you can set it using [InjectedTextEditing.isEnable].
  ///
  /// You can enable or disable all input fields inside [OnFormBuilder] using
  /// [InjectedForm.isEnabled] setter.
  ///
  /// For `isEnabled` to work you have to set the [TextField]'s enable property
  /// to use [InjectedTextEditing.isEnabled]
  ///
  /// Example:
  ///   ```dart
  ///     final email =  RM.injectTextEditing():
  ///
  ///     // In the widget tree
  ///    TextField(
  ///       controller: email.controller,
  ///       enabled: email.isEnabled,
  ///     ),
  ///   ```
  /// ### `onTextEditing`: Optional callback.
  /// Callback for side effects. It is fired whenever the input text or
  /// selection changes
  ///
  /// ### `isReadOnly`: Optional [bool]. Defaults to false.
  /// If true the input is clickable and selectable but not editable.
  /// Later on, you can set it using [InjectedTextEditing.isReadOnly].
  ///
  /// See [OnFormBuilder.isReadOnlyRM] to set a group of input fields to read
  /// only.
  ///
  /// ### `isEnabled`: Optional [bool]. Defaults to true.
  /// If false the [OnFormFieldBuilder] is disabled.
  /// Later on, you can set it using [InjectedTextEditing.isEnabled].
  ///
  /// See [OnFormBuilder.isReadOnlyRM] to disable a group of input fields.
  ///
  /// ### `autoDisposeWhenNotUsed`: Optional [bool] (Default true)
  /// Whether to auto dispose the injected model when no longer used
  /// (listened to).
  ///
  /// It is important to note that:
  /// * A state never listened to for rebuild, never auto dispose even after it
  /// is mutated.
  /// * By default, all states consumed in the widget tree will auto dispose.
  /// * It is recommended to manually dispose state that are not auto disposed
  /// using [InjectedBaseState.dispose]. You can dispose all states of the app
  /// using [RM.disposeAll].
  /// * A state will auto dispose if all states it depends on are disposed of.
  /// * Non disposed state may lead to unexpected behavior.
  /// * To debug when state is initialized and disposed of use
  /// `debugPrintWhenNotifiedPreMessage` parameter (See below)
  static InjectedTextEditing injectTextEditing({
    String text = '',
    TextSelection selection = const TextSelection.collapsed(offset: -1),
    TextRange composing = TextRange.empty,
    List<String? Function(String? text)>? validators,
    bool? validateOnTyping,
    bool? validateOnLoseFocus,
    void Function(InjectedTextEditing textEditing)? onTextEditing,
    bool isReadOnly = false,
    bool isEnabled = true,
    bool autoDispose = true,
  }) {
    return InjectedTextEditingImp(
      text: text,
      selection: selection,
      composing: composing,
      validator: validators,
      validateOnTyping: validateOnTyping,
      validateOnLoseFocus: validateOnLoseFocus,
      autoDispose: autoDispose,
      onTextEditing: onTextEditing,
      isReadOnly: isReadOnly,
      isEnabled: isEnabled,
    );
  }

  /// {@macro InjectedForm}
  ///
  /// ## Parameters:
  /// ### `autovalidateMode`: Optional [AutovalidateMode]. Defaults to [AutovalidateMode.disabled]
  /// The auto validation mode of the form. It can take one of three enumeration
  /// values:
  ///    - `AutovalidateMode.disable`: The form is validated manually by
  /// calling` form.validate()`
  ///    - `AutovalidateMode.always`: The form is always validated
  ///    - `AutovalidateMode.onUserInteraction`: The form is not validated
  /// until the user has started typing.
  ///
  /// If autovalidateMode is set to  `AutovalidateMode.always` or
  /// `AutovalidateMode.onUserInteraction`, It overrides the value of
  /// `autoValidateValueChange` of its child [InjectedTextEditing] or
  /// [InjectedFormField].
  ///
  /// ### `autoFocusOnFirstError`: Optional [bool]. Defaults to true
  /// After the form is validated, get focused on the first non valid TextField,
  /// if any.
  ///
  /// ### `submit`: Optional callback.
  /// Contains the user submission logic. Called when invoking
  ///[InjectedForm.submit] method.
  ///
  /// ### `submissionSideEffects`: Optional [SideEffects].
  /// Use to invoke side effects. See [OnFormBuilder.isEnabledRM] for an example
  /// of disabling a inputs while waiting for the form submission.
  ///
  /// ### `onSubmitting`: Optional callback.
  /// Callback for side effects called while waiting for form submission
  ///
  /// ### `onSubmitted`: Optional callback.
  /// Callback for side effects called if the form successfully submitted.
  static InjectedForm injectForm({
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    bool autoFocusOnFirstError = true,
    void Function()? onSubmitting,
    void Function()? onSubmitted,
    SideEffects? submissionSideEffects,
    Future<void> Function()? submit,
    // void Function(dynamic, void Function())? onSubmissionError,
  }) {
    return InjectedFormImp(
      autovalidateMode: autovalidateMode,
      autoFocusOnFirstError: autoFocusOnFirstError,
      onSubmitting: onSubmitting,
      onSubmitted: onSubmitted,
      sideEffects: submissionSideEffects,
      submit: submit,
    );
  }

  /// {@macro InjectedFormField}
  /// See bellow for more examples.
  /// ## Parameters:
  /// ### `text`: Required initial value of the generic type.
  /// The initial value the linked [OnFormFieldBuilder] should expose.
  ///
  /// ### `validators`: Optional List of callbacks.
  /// Set of validation rules the field should pass.
  ///
  /// Validators expose the value that the user entered.
  ///
  /// If any of the validation callbacks return a non-empty strings, the filed
  /// is considered non valid. For the field to be valid all validators must
  /// return null.
  ///
  /// example:
  ///   ```dart
  ///      final _email = RM.injectedFormField(
  ///       false,
  ///       validators: [
  ///         (value) {
  ///            //Frontend validation
  ///            if(!value){
  ///               return 'You must accept the license'.
  ///             }
  ///          },
  ///       ]
  ///     );
  ///   ```
  /// The validations performed here are frontend validation. To do backend
  /// validation you must use [InjectedForm].
  ///
  /// ### `validateOnValueChange`: Optional [bool].
  /// Whether to validate the input when the user change its value.
  ///
  /// The default value depends on whether the linked [OnFormFieldBuilder] is
  /// inside or  [OnFormBuilder]:
  /// * If outside: it default to true if `validateOnLoseFocus` is false.
  /// * If inside: it defaults to false if [InjectedForm.autovalidateMode] is
  /// [AutovalidateMode.disabled], otherwise it defaults to true.
  ///
  /// If `validateOnValueChange` is set to false, the text is not validated on
  /// input change.
  /// The text can be validate manually by invoking [InjectedFormField.validate].
  ///
  /// ### `validateOnLoseFocus`: Optional [bool].
  /// Whether to validate the input just after the field loses focus.
  ///
  /// It defaults to true if the linked [OnFormFieldBuilder] is inside [OnFormBuilder]
  /// and defaults to false if it is outside.
  ///
  /// Once the [OnFormFieldBuilder] loses focus and if it fails to validate,
  /// the field will auto validate on typing the next time the user starts typing.
  ///
  /// ### `isReadOnly`: Optional [bool]. Defaults to false.
  /// If true the input is clickable and selectable but not editable.
  /// Later on, you can set it using [InjectedFormField.isReadOnly]
  ///
  /// See [OnFormBuilder.isReadOnlyRM] to set a group of input fields to read
  /// only.
  ///
  /// ### `isEnabled`: Optional [bool]. Defaults to true.
  /// If false the [OnFormFieldBuilder] is disabled.
  /// Later on, you can set it using [InjectedFormField.isEnabled].
  ///
  /// See [OnFormBuilder.isEnabledRM] to set a group of input fields to read
  /// only.
  ///
  /// ### `onValueChange`: Optional callback.
  /// Callback for side effects. It is fired whenever the input is changed
  ///
  /// ### `autoDisposeWhenNotUsed`: Optional [bool] (Default true)
  /// Whether to auto dispose the injected model when no longer used
  /// (listened to).
  ///
  /// It is important to note that:
  /// * A state never listened to for rebuild, never auto dispose even after it
  /// is mutated.
  /// * By default, all states consumed in the widget tree will auto dispose.
  /// * It is recommended to manually dispose state that are not auto disposed
  /// using [InjectedBaseState.dispose]. You can dispose all states of the app
  /// using [RM.disposeAll].
  /// * A state will auto dispose if all states it depends on are disposed of.
  /// * Non disposed state may lead to unexpected behavior.
  /// * To debug when state is initialized and disposed of use
  /// `debugPrintWhenNotifiedPreMessage` parameter (See below)
  ///
  /// {@macro InjectedFormField.examples}
  static InjectedFormField<T> injectFormField<T>(
    T initialValue, {
    List<String? Function(T value)>? validators,
    bool? validateOnValueChange,
    bool? validateOnLoseFocus,
    void Function(InjectedFormField formField)? onValueChange,
    bool autoDispose = true,
    bool isReadOnly = false,
    bool isEnabled = true,
  }) {
    return InjectedFormFieldImp<T>(
      initialValue,
      validator: validators,
      validateOnValueChange: validateOnValueChange,
      validateOnLoseFocus: validateOnLoseFocus,
      autoDispose: autoDispose,
      onValueChange: onValueChange,
      isReadOnly: isReadOnly,
      isEnabled: isEnabled,
    );
  }

  /// {@macro InjectedAnimation}
  ///
  /// ## Parameters:
  ///
  /// ### `duration`: Required [Duration]
  /// The length of time the animation should last in the forward direction.
  ///
  /// ### `reverseDuration`: Optional [Duration]
  /// The length of time this animation should last when going in reverse. If
  /// not defined, the forward duration is used.
  ///
  /// ### `curve`: Optional [Curve]. Defaults to [Curves.linear]
  /// The curve the animation should take when going in forward direction.
  ///
  /// ### `reverseCurve`: Optional [Curve].
  /// The curve the animation should take when going in reverse direction. If
  /// not defined, the forward curve is used.
  ///
  /// ### `lowerBound`: Optional [double]. Defaults to 0.0
  /// The value at which this animation is deemed to be dismissed.
  ///
  ///
  /// ### `upperBound`: Optional [double]. Defaults to 1.0
  /// The value at which this animation is deemed to be completed.
  ///
  /// ### `initialValue`: Optional [double].
  /// The AnimationController's value the animation start with. If not defined
  /// the lowerBand is used.
  ///
  /// ### `animationBehavior`: Optional [AnimationBehavior]. Defaults to [AnimationBehavior.normal]
  /// The behavior of the controller when [AccessibilityFeatures.disableAnimations]
  /// is true.
  ///
  /// ### `repeats`: Optional [int]. Defaults to 1.
  /// The number of times the animation repeats (always from start to end).
  /// A value of zero means that the animation will repeats infinity.
  ///
  /// ### `shouldReverseRepeats`: Optional [bool]. Defaults to false.
  /// When it is set to true, animation will repeat by alternating between begin
  /// and end on each repeat.
  ///
  /// ### `shouldAutoStart`: Optional [bool]. Defaults to false.
  /// When it is set to true, animation will auto start after first initialized.
  ///
  /// ### `onInitialized`: Optional Callback.
  /// Callback fired once the animation is first set.
  ///
  /// ### `endAnimationListener`: Optional Callback.
  /// callback to be fired after animation ends (After purge of repeats and cycle)
  ///
  /// See [OnAnimationBuilder], [Animate]
  ///
  /// Example of Implicit Animated Container
  ///
  /// ```dart
  ///  final animation = RM.injectAnimation(
  ///    duration: Duration(seconds: 2),
  ///    curve: Curves.fastOutSlowIn,
  ///  );
  ///
  ///  class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  ///    bool selected = false;
  ///
  ///    @override
  ///    Widget build(BuildContext context) {
  ///      return GestureDetector(
  ///        onTap: () {
  ///          setState(() {
  ///            selected = !selected;
  ///          });
  ///        },
  ///        child: Center(
  ///          child: OnAnimationBuilder(
  ///            listenTo: animation,
  ///            builder: (animate) {
  ///              final width = animate(selected ? 200.0 : 100.0);
  ///              final height = animate(selected ? 100.0 : 200.0, 'height');
  ///              final alignment = animate(
  ///                selected ? Alignment.center : AlignmentDirectional.topCenter,
  ///              );
  ///              final Color? color = animate(
  ///                selected ? Colors.red : Colors.blue,
  ///              );
  ///              return Container(
  ///                width: width,
  ///                height: height,
  ///                color: color,
  ///                alignment: alignment,
  ///                child: const FlutterLogo(size: 75),
  ///              );
  ///            },
  ///          ),
  ///        ),
  ///      );
  ///    }
  ///  }
  /// ```
  static InjectedAnimation injectAnimation({
    required Duration duration,
    Duration? reverseDuration,
    Curve curve = Curves.linear,
    Curve? reverseCurve,
    double? initialValue,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    int? repeats,
    bool shouldReverseRepeats = false,
    bool shouldAutoStart = false,
    void Function(InjectedAnimation)? onInitialized,
    void Function()? endAnimationListener,
  }) {
    return InjectedAnimationImp(
      duration: duration,
      reverseDuration: reverseDuration,
      curve: curve,
      reverseCurve: reverseCurve,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: animationBehavior,
      repeats: repeats,
      shouldReverseRepeats: shouldReverseRepeats,
      shouldAutoStart: shouldAutoStart,
      onInitialized: onInitialized,
      endAnimationListener: endAnimationListener,
      initialValue: initialValue,
    );
  }

  /// Inject a [ScrollController]
  ///
  /// This injected state abstracts the best practices to come out with a
  /// simple, clean, and testable approach to control Scrollable view.
  ///
  /// If you don't use [OnScrollBuilder] to listen to the state, it is highly
  /// recommended to manually dispose the state using [Injected.dispose] method.
  ///
  /// ## Parameters:
  ///
  /// ### `initialScrollOffset`: Optional [double]. Defaults to 0.0.
  /// is the initial scroll offset
  ///
  /// ### `endScrollDelay`: Optional [int]. Defaults to 300.
  /// The delay in milliseconds to be awaited after the user stop scrolling to
  ///consider scrolling action ended.
  ///
  /// ### `onScrolling`: Optional callback.
  /// Callback invoked each time the [ScrollController] emits a notification. It
  /// exposes the [InjectedScrolling] instance. It is used to invoke side effects
  /// when:
  /// * Reaching the maximum scroll extent [InjectedScrolling.maxScrollExtent]
  /// * Reaching the minimum scroll extent [InjectedScrolling.minScrollExtent]
  /// * While is scrolling in the forward direction
  /// * While is scrolling [InjectedScrolling.isScrolling]
  /// [InjectedScrolling.isScrollingForward]
  /// * When starts scrolling
  /// [InjectedScrolling.isScrollingReverse]
  /// * When starts scrolling to the forward direction
  /// [InjectedScrolling.hasStartedScrolling]
  /// [InjectedScrolling.hasStartedScrollingForward]
  /// * When starts scrolling to the reverse direction
  /// [InjectedScrolling.hasStartedScrollingReverse]
  /// * When scrolling ends [InjectedScrolling.hasEndedScrolling]
  ///
  /// Example
  /// ```dart
  ///   final scroll = RM.injectScrolling(
  ///     onScrolling: (scroll) {
  ///           if (scroll.hasReachedMinExtent) {
  ///              print('isTop');
  ///            }
  ///
  ///            if (scroll.hasReachedMaxExtent) {
  ///              print('isBottom');
  ///            }
  ///
  ///            if (scroll.hasStartedScrollingReverse) {
  ///              print('hasStartedUp');
  ///            }
  ///            if (scroll.hasStartedScrollingForward) {
  ///              print('hasStartedDown');
  ///            }
  ///
  ///            if (scroll.hasStartedScrolling) {
  ///              print('hasStarted');
  ///            }
  ///
  ///            if (scroll.isScrollingReverse) {
  ///              print('isScrollingUp');
  ///            }
  ///            if (scroll.isScrollingForward) {
  ///              print('isScrollingDown');
  ///            }
  ///
  ///            if (scroll.isScrolling) {
  ///              print('isScrolling');
  ///            }
  ///
  ///            if (scroll.hasEndedScrolling) {
  ///              print('hasEnded');
  ///            }
  ///     },
  ///   );
  /// ```
  ///
  ///
  /// ### `keepScrollOffset`: Optional [bool]. Defaults to true.
  /// Similar to [ScrollController.keepScrollOffset]
  ///
  /// See [OnScrollBuilder]
  static InjectedScrolling injectScrolling({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    void Function(InjectedScrolling)? onScrolling,
    int endScrollDelay = 300,
  }) {
    return InjectedScrollingImp(
      initialScrollOffset: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      onScroll: onScrolling != null ? OnScroll<void>(onScrolling) : null,
      onScrollEndedDelay: endScrollDelay,
    );
  }

  /// {@macro InjectedTabPageView}
  /// ## Parameters:
  ///
  /// ### `length`: Required [int].
  /// The number of tabs / pages to display. It can be dynamically changes later.
  /// Example:
  /// ```dart
  ///    // We start with 2 tabs
  ///    final myInjectedTabPageView = RM.injectedTabPageView(length: 2);
  ///
  ///   // Later on, we can extend or shrink the length of tab views.
  ///
  ///   // Tab/page views are updated to display three views
  ///   myInjectedTabPageView.length = 3
  ///
  ///   // Tab/page views are updated to display one view
  ///   myInjectedTabPageView.length = 1
  /// ```
  ///
  /// ### `initialIndex`: Optional [int]. Defaults to 0.
  /// The index of the tab / page to start with.
  ///
  /// ### `duration`: Optional [Duration]. Defaults to `Duration(milliseconds: 300)`.
  /// The duration the tab / page transition takes.
  ///
  /// ### `curve`: Optional [Curve]. Defaults to `Curves.ease`.
  /// The duration the tab / page transition takes.
  ///
  /// ### `keepPage`: Optional [bool]. Defaults to `true`.
  /// Save the current [page] with [PageStorage] and restore it if this
  /// controller's scrollable is recreated. See [PageController.keepPage]
  ///
  /// ### `viewportFraction`: Optional [double]. Defaults to `1.0`.
  /// The fraction of the viewport that each page should occupy.
  /// See [PageController.viewportFraction]
  static InjectedTabPageView injectTabPageView({
    required int length,
    int initialIndex = 0,
    Duration duration = kTabScrollDuration,
    Curve curve = Curves.ease,
    bool keepPage = true,
    double viewportFraction = 1.0,
  }) {
    return InjectedPageTabImp(
      initialIndex: initialIndex,
      length: length,
      curve: curve,
      duration: duration,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
    );
  }

  ///Static variable the holds the chosen working environment or flavor.
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
    void Function(T? s)? onInitialized,
    SideEffects<T>? sideEffects,
    StateInterceptor<T>? stateInterceptor,
    //
    DependsOn<T>? dependsOn,
    int undoStackLength = 0,
    PersistState<T> Function()? persist,
    //
    bool autoDisposeWhenNotUsed = true,
    bool isLazy = true,
    String? debugPrintWhenNotifiedPreMessage,
    Object? Function(T?)? toDebugString,
  }) {
    return Injected.generic(
      creator: () {
        _envMapLength ??= impl.length;
        assert(RM.env != null, '''
You are using [RM.injectFlavor]. You have to define the [RM.env] before the [runApp] method
    ''');
        assert(impl[env] != null, '''
There is no implementation for $env of $T interface
    ''');
        assert(impl.length == _envMapLength, '''
You must be consistent about the number of flavor environments you have.
you had $_envMapLength flavors and you are defining ${impl.length} flavors.
    ''');
        return impl[env]!();
      },
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
//     late final InjectedImp<T> inj;
//     return inj = InjectedImp<T>(
//       creator: () {
//         _envMapLength ??= impl.length;
//         assert(RM.env != null, '''
// You are using [RM.injectFlavor]. You have to define the [RM.env] before the [runApp] method
//     ''');
//         assert(impl[env] != null, '''
// There is no implementation for $env of $T interface
//     ''');
//         assert(impl.length == _envMapLength, '''
// You must be consistent about the number of flavor environments you have.
// you had $_envMapLength flavors and you are defining ${impl.length} flavors.
//     ''');
//         return impl[env]!();
//       },
//       initialState: initialState,
//       autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,

//       onDisposed: sideEffects?.dispose != null
//           ? (_) => sideEffects!.dispose!()
//           : onDisposed,
//       onInitialized: sideEffects?.initState != null
//           ? (_) => sideEffects!.initState!()
//           : onInitialized != null
//               ? (s) => onInitialized(s)
//               : null,
//       onSetState: On(
//         () {
//           sideEffects
//             ?..onSetState?.call(inj.snapState)
//             ..onAfterBuild?.call();
//           onSetState?.call(inj.snapState);
//         },
//       ),

//       onDataForSideEffect: onData,
//       onError: onError,
//       onWaiting: onWaiting,

//       // watch: watch,
//       dependsOn: dependsOn,
//       undoStackLength: undoStackLength,
//       persist: persist,
//       debugPrintWhenNotifiedPreMessage: debugPrintWhenNotifiedPreMessage,
//       toDebugString: toDebugString,
//       middleSnapState: middleSnapState,
//       isLazy: isLazy,
//     );
  }

  /// Dispose all Injected State
  static void disposeAll() {
    scaffold.dispose();
    navigate.dispose();
    if (injectedModels.isEmpty) return;
    for (var inj in [...injectedModels]) {
      inj.dispose();
    }
    injectedModels.clear();
  }

  ///Initialize the default persistence provider to be used.
  ///
  ///Called in the main method:
  ///```dart
  ///void main()async{
  /// WidgetsFlutterBinding.ensureInitialized();
  ///
  /// await RM.storageInitializer(IPersistStoreImp());
  /// runApp(MyApp());
  ///}
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

  ///Initialize a mock persistence provider.
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

  ///Get an active [BuildContext].
  ///
  ///The obtained [BuildContext] is one of the [states_rebuilder]'s widgets
  ///context;
  ///
  ///For this reason you have to use at least one of [states_rebuilder]'s widgets.
  static BuildContext? get context {
    // if (_context != null) {
    //   return _context;
    // }

    if (_contextSet.isNotEmpty) {
      if (_contextSet.last.findRenderObject()?.attached != true) {
        _contextSet.removeLast();
        // ignore: recursive_getters
        return context;
      }
      return _contextSet.last;
    }

    return navigateObject.navigatorKey.currentState?.context;
  }

  static ReactiveModel<T> get<T>([String? name]) {
    return Injector.getAsReactive<T>(name: name);
  }

  /// Scaffold without BuildContext.
  ///
  static final scaffold = scaffoldObject;

  /// Navigation without BuildContext.
  static final navigate = navigateObject;

  /// Predefined set of route transition animation
  static final transitions = transitionsObject;

  /// {@macro InjectedNavigator}
  ///
  /// ## Parameters:
  ///
  /// ### `routes`: Required [Map<String, Widget Function(RouteData data)>].
  /// A map of route names and a callbacks that return the corresponding widget.
  /// The callback exposes a [RouteData] object. [RouteData] objects holds
  /// information about routing data such as [RouteData.location], [RouteData.path],
  /// [RouteData.pathParams] and [RouteData.queryParams].
  ///
  ///
  /// Example:
  /// ```dart
  ///   final myNavigator = RM.injectNavigator(
  ///     routes: {
  ///       '/': (RouteData data) => Home(),
  ///        // redirect all paths that starts with '/home' to '/' path
  ///       '/home/*': (RouteData data) => data.redirectTo('/'),
  ///       '/page1': (RouteData data) => Page1(),
  ///       '/page1/page11': (RouteData data) => Page11(),
  ///       '/page2/:id': (RouteData data) {
  ///         // Extract path parameters from dynamic links
  ///         final id = data.pathParams['id'];
  ///         // OR inside Page2 you can use `context.routeData.pathParams['id']`
  ///         return Page2(id: id);
  ///        },
  ///       '/page3/:kind(all|popular|favorite)': (RouteData data) {
  ///         // Use custom regular expression
  ///         final kind = data.pathParams['kind'];
  ///         return Page3(kind: kind);
  ///        },
  ///       '/page4': (RouteData data) {
  ///         // Extract query parameters from links
  ///         // Ex link is `/page4?age=4`
  ///         final age = data.queryParams['age'];
  ///         // OR inside Page4 you can use `context.routeData.queryParams['age']`
  ///         return Page4(age: age);
  ///        },
  ///        // Using sub routes
  ///        '/page5': (RouteData data) => RouteWidget(
  ///              builder: (Widget routerOutlet) {
  ///                return MyParentWidget(
  ///                  child: routerOutlet;
  ///                  // OR inside MyParentWidget you can use `context.routerOutlet`
  ///                )
  ///              },
  ///              routes: {
  ///                '/': (RouteData data) => Page5(),
  ///                '/page51': (RouteData data) => Page51(),
  ///              },
  ///            ),
  ///     },
  ///   );
  /// ```
  ///
  /// ### `initialLocation`: Optional [String]. Defaults to '/'.
  /// The initial location the app route to when first starts.
  ///
  /// ### `unknownRoute`: Optional callback that exposes the location to navigate to.
  /// Define the widgets to display if the location can not be resolved to known route.
  ///
  /// ### `builder`: Optional callback that exposes the router outlet widget.
  /// Used to display the matched widget inside another widget.
  ///
  /// In the following example, all pages will be rendered inside `Padding` widget.
  /// ```dart
  ///   final myNavigator = RM.injectNavigator(
  ///     builder: (routerOutlet) {
  ///       return Padding(
  ///         padding: const EdgeInsets.all(8.0),
  ///         child: routerOutlet,
  ///       );
  ///     },
  ///     routes: {
  ///       '/': (RouteData data) => Home(),
  ///       '/page1': (RouteData data) => Page1(),
  ///     },
  ///   );
  /// ```
  ///
  /// ### `pageBuilder`: Optional callback that exposes [MaterialPageArgument] object.
  /// By default, app pages are wrapped with [MaterialPage] widget. If you want to get
  /// more options, you can define your implementation.
  ///
  /// ```dart
  ///   pageBuilder: (MaterialPageArgument arg) {
  ///      return MaterialPage(
  ///        key: arg.key,
  ///        child: arg.child,
  ///      );
  ///    },
  /// ```
  ///
  /// ### `shouldUseCupertinoPage`: Optional callback that exposes [MaterialPageArgument] object.
  /// By default, app pages are wrapped with [MaterialPage] widget. If you want to
  /// use [CupertinoPage] instead, set `shouldUseCupertinoPage` to true.
  /// You can use `pageBuilder` for more customization.
  ///
  /// ### `transitionsBuilder`: Optional callback.
  /// Define the page transition animation. You can use predefined transition
  /// using [RM.transitions] or just define yours.
  ///
  /// The animation transition defined here are global and will be used for each
  /// page transition. You can override this default behavior for a particular route
  /// using [RouteWidget.transitionsBuilder].
  ///
  /// You can also define a particular page transition animation for a single navigation
  /// call:
  /// ```dart
  ///  myNavigator.to('/page1', transitionsBuilder: RM.transitions.rightToLeft())
  /// ```
  /// ### `onNavigate`: Optional callback that exposes [RouteData] object.
  /// Callback fired after a location is resolved and just before navigation.
  ///
  /// It can be used for route guarding and global redirection.
  ///
  /// Example:
  /// ```dart
  ///   final myNavigator = RM.injectNavigator(
  ///     onNavigate: (RouteData data) {
  ///       final toLocation = data.location;
  ///       if (toLocation == '/homePage' && userIsNotSigned) {
  ///         return data.redirectTo('/signInPage');
  ///       }
  ///       if (toLocation == '/signInPage' && userIsSigned) {
  ///         return data.redirectTo('/homePage');
  ///       }
  ///
  ///       //You can also check query or path parameters
  ///       if (data.queryParams['userId'] == '1') {
  ///         return data.redirectTo('/superUserPage');
  ///       }
  ///     },
  ///     routes: {
  ///       '/signInPage': (RouteData data) => SignInPage(),
  ///       '/homePage': (RouteData data) => HomePage(),
  ///     },
  ///   );
  /// ```
  ///
  /// ### `onNavigateBack`: Optional callback that exposes [RouteData] object.
  /// Called when the route is popping back. It can be used to prevent leaving
  /// a page if returns false value.
  ///
  /// Example:
  ///
  /// ```dart
  ///  final myNavigator = RM.injectNavigator(
  ///    onNavigateBack: (RouteData data) {
  ///      final backFrom = data.location;
  ///      if (backFrom == '/SingInFormPage' && formIsNotSaved) {
  ///        RM.navigate.toDialog(
  ///          AlertDialog(
  ///            content: Text('The form is not saved yet! Do you want to exit?'),
  ///            actions: [
  ///              ElevatedButton(
  ///                onPressed: () => RM.navigate.forceBack(),
  ///                child: Text('Yes'),
  ///              ),
  ///              ElevatedButton(
  ///                onPressed: () => RM.navigate.back(),
  ///                child: Text('No'),
  ///              ),
  ///            ],
  ///          ),
  ///        );
  ///
  ///        return false;
  ///      }
  ///    },
  ///    routes: {
  ///      '/SingInFormPage': (RouteData data) => SingInFormPage(),
  ///      '/homePage': (RouteData data) => HomePage(),
  ///    },
  ///  );
  /// ```
  ///
  /// ### `debugPrintWhenRouted`: Optional [bool]. Defaults to false
  /// Print log a debug message when the state of the navigator is changed.
  static InjectedNavigator injectNavigator({
    //ORDER OF routes is important (/signin, /) home is not used even if skipHome slash is false
    required Map<String, Widget Function(RouteData data)> routes,
    String? initialLocation,
    Widget Function(RouteData data)? unknownRoute,
    Widget Function(Widget routerOutlet)? builder,
    Page<dynamic> Function(MaterialPageArgument arg)? pageBuilder,
    bool shouldUseCupertinoPage = false,
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondAnimation,
      Widget child,
    )?
        transitionsBuilder,
    Duration? transitionDuration,
    Redirect? Function(RouteData data)? onNavigate,
    bool? Function(RouteData? data)? onNavigateBack,
    bool debugPrintWhenRouted = false,
    bool ignoreUnknownRoutes = false,
  }) {
    return InjectedNavigatorImp(
      routes: routes,
      unknownRoute: unknownRoute,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: transitionDuration,
      builder: builder,
      initialRoute: initialLocation,
      shouldUseCupertinoPage: shouldUseCupertinoPage,
      redirectTo: onNavigate,
      debugPrintWhenRouted: debugPrintWhenRouted,
      pageBuilder: pageBuilder,
      onBack: onNavigateBack,
      ignoreUnknownRoutes: ignoreUnknownRoutes,
    );
  }
}
