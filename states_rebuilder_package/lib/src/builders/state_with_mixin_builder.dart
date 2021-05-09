import 'package:flutter/material.dart';
import '../rm.dart';

///Mixin StateWithMixinBuilder
enum MixinWith {
  ///Mixin with [TickerProviderStateMixin]
  tickerProviderStateMixin,

  ///Mixin with [SingleTickerProviderStateMixin]
  singleTickerProviderStateMixin,

  ///Mixin with [AutomaticKeepAliveClientMixin]
  automaticKeepAliveClientMixin,

  ///Mixin with [WidgetsBindingObserver]
  widgetsBindingObserver,
}

///StateBuilder that can be mixin with one of the predefined mixin in [mixinWith]
class StateWithMixinBuilder<T, R> extends StatefulWidget {
  ///```dart
  ///StateWithMixinBuilder(
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, Injected model) =>MyWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state.
  ///
  ///The builder is provided with an [BuildContext] and [Injected<R>] parameters.
  final Widget Function(BuildContext context, Injected<R>? rm)? builder;

  ///```dart
  ///StateWithMixinBuilder(
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, Injected model, Widget child) =>MyWidget(),
  ///  child : MyChildWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state with child parameter.
  ///
  ///The builder is provided with a [BuildContext], [Injected] and [Widget] parameters.
  final Widget Function(BuildContext context, Injected<R>? rm, Widget child)?
      builderWithChild;

  ///The child to be used in [builderWithChild].
  final Widget? child;

  ///```dart
  ///StateWithMixinBuilder(
  ///  models:[myModel1, myModel2,myModel3],//If you want this widget to not rebuild, do not define any model.
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, Injected model) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesWithMixinRebuilder`of the states_rebuilder package.
  // final List<Injected> models;

  ///an observable to which you want [StateWithMixinBuilder] to subscribe.
  final InjectedBaseState<R> Function()? observe;

  // ///List of observables to which you want [StateWithMixinBuilder] to subscribe.
  // final List<Injected Function()>? observeMany;

  ///A custom name of your widget. It is used to rebuild this widget
  ///from your logic classes.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  ///
  ///  ///Each [StateBuilder] has a default tag which is its [BuildContext]
  final dynamic tag;

  ///An enum of Pre-defined mixins (ex: MixinWith.tickerProviderStateMixin)
  final MixinWith mixinWith;

  ///```dart
  ///StateWithMixinBuilder(
  ///  initState:(BuildContext context, Injected model,  TickerProvider ticker)=> myModel.init([context, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, Injected model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, Injected<R>? rm, T? mix)? initState;

  ///```dart
  ///StateWithMixinBuilder(
  ///  dispose:(BuildContext context,  TickerProvider ticker)=> myModel.dispose([context, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, Injected model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, Injected<R>? rm, T? mix)? dispose;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeDependencies:(BuildContext context,  TickerProvider ticker)=> myModel.myMethod([context, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, Injected model) =>MyWidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, Injected<R>? rm, T? mix)?
      didChangeDependencies;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didUpdateWidget:(BuildContext context, StateBuilderBase oldWidget, TickerProvider ticker)=> myModel.myMethod([context,oldWidget, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, Injected model) =>MyWidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(
          BuildContext context, StateWithMixinBuilder<T, R> oldWidget, T? mix)?
      didUpdateWidget;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context, Injected<R>? rm)? afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context, Injected<R>? rm)? afterRebuild;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeAppLifecycleState:(BuildContext context,  AppLifecycleState state)=> myModel.myMethod([context, state]),
  ///  MixinWith : MixinWith.widgetsBindingObserver
  ///  builder:(BuildContext context, Injected model) =>MyWidget(),
  ///)
  ///```
  ///Called when the system puts the app in the background or returns the app to the foreground.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, AppLifecycleState state)?
      didChangeAppLifecycleState;

  ///Called when the system tells the app that the user's locale has changed.
  ///For example, if the user changes the system language settings.
  ///* Required parameters:
  ///   * [BuildContext] (positional parameter): the [BuildContext]
  ///   * [List<Locale>] (positional parameter): List of system Locales as defined in
  /// the system language settings
  final void Function(BuildContext context, List<Locale>? locale)?
      didChangeLocales;

  ///StateBuilder that can be mixin with one of the predefined mixin in [mixinWith]
  StateWithMixinBuilder({
    Key? key,
    this.tag,
    this.observe,
    // this.observeMany,
    this.builder,
    this.builderWithChild,
    this.child,
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.afterInitialBuild,
    this.afterRebuild,
    this.didChangeAppLifecycleState,
    this.didChangeLocales,
    required this.mixinWith,
  })   : assert(builder != null || builderWithChild != null, '''
  
  | ***Builder not defined***
  | You have to define either 'builder' or 'builderWithChild' parameter.
  | Use 'builderWithChild' with 'child' parameter. 
  | If 'child' is null use 'builder' instead.
  
        '''),
        assert(builderWithChild == null || child != null, '''
  | ***child is null***
  | You have defined the 'builderWithChild' parameter without defining the child parameter.
  | Use 'builderWithChild' with 'child' parameter. 
  | If 'child' is null use 'builder' instead.
  
        '''),
        super(key: key);

  ///StateBuilder mixin with [TickerProviderStateMixin]
  ///
  ///* Required parameters:
  ///   * [builder] : The builder callback to be executed whenever the widget is
  /// notified.
  ///   * [builderWithChild] : The builder callback to be executed whenever the
  /// widget is notified. It must be use with [child] parameter.
  ///   * [child] : Widget to be used with [builderWithChild]. Used for optimization.
  /// [builder] or and only or [builderWithChild]  with [child] must be defined.
  /// * Optional parameters:
  ///   * [observe] : The model to observer.
  ///   * [dispose] : Callback to be called when the widget is removed.
  ///   * [didChangeDependencies] : Callback to be called when dependencies changed.
  ///   * [didUpdateWidget] : Callback to be called when the widget updated
  ///   * [afterInitialBuild] : Callback to be called after the first build of the
  /// widget.
  ///   * [afterRebuild] : Callback to be called after each build.
  static StateWithMixinBuilder<TickerProviderStateMixin, R> tickerProvider<R>({
    Key? key,
    dynamic tag,
    Widget Function(BuildContext context, Injected<R>? rm)? builder,
    Widget Function(BuildContext context, Injected<R>? rm, Widget? child)?
        builderWithChild,
    Widget? child,
    InjectedBaseState<R> Function()? observe,
    void Function(BuildContext context, Injected<R>? rm,
            TickerProviderStateMixin? ticker)?
        initState,
    void Function(BuildContext context, Injected<R>? rm,
            TickerProviderStateMixin? ticker)?
        dispose,
    void Function(BuildContext context, Injected<R>? rm,
            TickerProviderStateMixin? ticker)?
        didChangeDependencies,
    void Function(
            BuildContext context,
            StateWithMixinBuilder<TickerProviderStateMixin, R> old,
            TickerProviderStateMixin? ticker)?
        didUpdateWidget,
    void Function(BuildContext context, Injected<R>? rm)? afterInitialBuild,
    void Function(BuildContext context, Injected<R>? rm)? afterRebuild,
  }) {
    return StateWithMixinBuilder<TickerProviderStateMixin, R>(
      mixinWith: MixinWith.tickerProviderStateMixin,
      key: key,
      observe: observe,
      builder: builder,
      builderWithChild: builderWithChild,
      child: child,
      initState: initState,
      dispose: dispose,
      didChangeDependencies: didChangeDependencies,
      didUpdateWidget: didUpdateWidget,
      afterInitialBuild: afterInitialBuild,
      afterRebuild: afterRebuild,
    );
  }

  ///StateBuilder mixin with [SingleTickerProviderStateMixin]
  ///
  ///* Required parameters:
  ///   * [builder] : The builder callback to be executed whenever the widget is
  /// notified.
  ///   * [builderWithChild] : The builder callback to be executed whenever the
  /// widget is notified. It must be use with [child] parameter.
  ///   * [child] : Widget to be used with [builderWithChild]. Used for optimization.
  /// [builder] or and only or [builderWithChild]  with [child] must be defined.
  /// * Optional parameters:
  ///   * [observe] : The model to observer.
  ///   * [observeMany] Callback to be called when the widget is first inserted.
  ///   * [dispose] : Callback to be called when the widget is removed.
  ///   * [didChangeDependencies] : Callback to be called when dependencies changed.
  ///   * [didUpdateWidget] : Callback to be called when the widget updated
  ///   * [afterInitialBuild] : Callback to be called after the first build of the
  /// widget.
  ///   * [afterRebuild] : Callback to be called after each build.
  static StateWithMixinBuilder<SingleTickerProviderStateMixin, R>
      singleTickerProvider<R>({
    Key? key,
    dynamic tag,
    InjectedBaseState<R> Function()? observe,
    Widget Function(BuildContext context, Injected<R>? rm)? builder,
    Widget Function(BuildContext context, Injected<R>? rm, Widget? child)?
        builderWithChild,
    Widget? child,
    void Function(BuildContext context, Injected<R>? rm,
            SingleTickerProviderStateMixin? ticker)?
        initState,
    void Function(BuildContext context, Injected<R>? rm,
            SingleTickerProviderStateMixin? ticker)?
        dispose,
    void Function(BuildContext context, Injected<R>? rm,
            SingleTickerProviderStateMixin? ticker)?
        didChangeDependencies,
    void Function(
            BuildContext context,
            StateWithMixinBuilder<SingleTickerProviderStateMixin, R> old,
            SingleTickerProviderStateMixin? ticker)?
        didUpdateWidget,
    void Function(BuildContext context, Injected<R>? rm)? afterInitialBuild,
    void Function(BuildContext context, Injected<R>? rm)? afterRebuild,
  }) {
    return StateWithMixinBuilder<SingleTickerProviderStateMixin, R>(
      mixinWith: MixinWith.singleTickerProviderStateMixin,
      key: key,
      observe: observe,
      builder: builder,
      builderWithChild: builderWithChild,
      child: child,
      initState: initState,
      dispose: dispose,
      didChangeDependencies: didChangeDependencies,
      didUpdateWidget: didUpdateWidget,
      afterInitialBuild: afterInitialBuild,
      afterRebuild: afterRebuild,
    );
  }

  ///StateBuilder mixin with [AutomaticKeepAliveClientMixin]
  ///
  ///* Required parameters:
  ///   * [builder] : The builder callback to be executed whenever the widget is
  /// notified.
  ///   * [builderWithChild] : The builder callback to be executed whenever the
  /// widget is notified. It must be use with [child] parameter.
  ///   * [child] : Widget to be used with [builderWithChild]. Used for optimization.
  /// [builder] or and only or [builderWithChild]  with [child] must be defined.
  /// * Optional parameters:
  ///   * [observe] : The model to observer.
  ///   * [observeMany] Callback to be called when the widget is first inserted.
  ///   * [dispose] : Callback to be called when the widget is removed.
  ///   * [didChangeDependencies] : Callback to be called when dependencies changed.
  ///   * [didUpdateWidget] : Callback to be called when the widget updated
  ///   * [afterInitialBuild] : Callback to be called after the first build of the
  /// widget.
  ///   * [afterRebuild] : Callback to be called after each build.

  static StateWithMixinBuilder<AutomaticKeepAliveClientMixin, R>
      automaticKeepAlive<R>({
    Key? key,
    dynamic tag,
    InjectedBaseState<R> Function()? observe,
    Widget Function(BuildContext context, Injected<R>? rm)? builder,
    Widget Function(BuildContext context, Injected<R>? rm, Widget? child)?
        builderWithChild,
    Widget? child,
    void Function(BuildContext context, Injected<R>? rm)? initState,
    void Function(BuildContext context, Injected<R>? rm)? dispose,
    void Function(BuildContext context, Injected<R>? rm)? didChangeDependencies,
    void Function(
      BuildContext context,
      StateWithMixinBuilder<AutomaticKeepAliveClientMixin, R> old,
    )?
        didUpdateWidget,
    void Function(BuildContext context, Injected<R>? rm)? afterInitialBuild,
    void Function(BuildContext context, Injected<R>? rm)? afterRebuild,
  }) {
    return StateWithMixinBuilder<AutomaticKeepAliveClientMixin, R>(
      mixinWith: MixinWith.automaticKeepAliveClientMixin,
      key: key,
      observe: observe,
      builder: builder,
      builderWithChild: builderWithChild,
      child: child,
      initState: initState != null
          ? (context, rm, mix) => initState(context, rm)
          : null,
      dispose:
          dispose != null ? (context, rm, mix) => dispose(context, rm) : null,
      didChangeDependencies: didChangeDependencies != null
          ? (context, rm, mix) => didChangeDependencies(context, rm)
          : null,
      didUpdateWidget: didUpdateWidget != null
          ? (context, old, mix) => didUpdateWidget(context, old)
          : null,
      afterInitialBuild: afterInitialBuild,
      afterRebuild: afterRebuild,
    );
  }

  ///StateBuilder mixin with [WidgetsBindingObserver]
  ///
  ///* Required parameters:
  ///   * [builder] : The builder callback to be executed whenever the widget is
  /// notified.
  ///   * [builderWithChild] : The builder callback to be executed whenever the
  /// widget is notified. It must be use with [child] parameter.
  ///   * [child] : Widget to be used with [builderWithChild]. Used for optimization.
  /// [builder] or and only or [builderWithChild]  with [child] must be defined.
  /// * Optional parameters:
  ///   * [observe] : The model to observer.
  ///   * [observeMany] Callback to be called when the widget is first inserted.
  ///   * [dispose] : Callback to be called when the widget is removed.
  ///   * [didChangeDependencies] : Callback to be called when dependencies changed.
  ///   * [didUpdateWidget] : Callback to be called when the widget updated
  ///   * [afterInitialBuild] : Callback to be called after the first build of the
  /// widget.
  ///   * [afterRebuild] : Callback to be called after each build.
  ///   * [didChangeAppLifecycleState] : Called when the system puts the app in
  /// the background or returns the app to the foreground.
  ///   * [didChangeLocales] : Called when the system tells the app that the
  /// user's locale has changed. For example, if the user changes the system language settings..
  static StateWithMixinBuilder<WidgetsBindingObserver, R>
      widgetsBindingObserver<R>({
    Key? key,
    dynamic? tag,
    InjectedBaseState<R> Function()? observe,
    Widget Function(BuildContext context, Injected<R>? rm)? builder,
    Widget Function(BuildContext context, Injected<R>? rm, Widget? child)?
        builderWithChild,
    Widget? child,
    void Function(BuildContext context, Injected<R>? rm)? initState,
    void Function(BuildContext context, Injected<R>? rm)? dispose,
    void Function(BuildContext context, Injected<R>? rm)? didChangeDependencies,
    void Function(
      BuildContext context,
      StateWithMixinBuilder<WidgetsBindingObserver, R> old,
    )?
        didUpdateWidget,
    void Function(BuildContext context, Injected<R>? rm)? afterInitialBuild,
    void Function(BuildContext context, Injected<R>? rm)? afterRebuild,
    void Function(BuildContext context, AppLifecycleState lifecycleState)?
        didChangeAppLifecycleState,
    void Function(BuildContext context, List<Locale>? locale)? didChangeLocales,
  }) {
    return StateWithMixinBuilder<WidgetsBindingObserver, R>(
      mixinWith: MixinWith.widgetsBindingObserver,
      key: key,
      observe: observe,
      builder: builder,
      builderWithChild: builderWithChild,
      child: child,
      initState: initState != null
          ? (context, rm, mix) => initState(context, rm)
          : null,
      dispose:
          dispose != null ? (context, rm, mix) => dispose(context, rm) : null,
      didChangeDependencies: didChangeDependencies != null
          ? (context, rm, mix) => didChangeDependencies(context, rm)
          : null,
      didUpdateWidget: didUpdateWidget != null
          ? (context, old, mix) => didUpdateWidget(context, old)
          : null,
      afterInitialBuild: afterInitialBuild,
      afterRebuild: afterRebuild,
      didChangeAppLifecycleState: didChangeAppLifecycleState,
      didChangeLocales: didChangeLocales,
    );
  }

  @override
  _State<T, R> createState() {
    switch (mixinWith) {
      case MixinWith.singleTickerProviderStateMixin:
        assert(
            (initState != null || afterInitialBuild != null) && dispose != null,
            '''
initState` `dispose` must not be null because you are using SingleTickerProviderStateMixin
and you are supposed to to instantiate your controllers in the initState() and dispose them
 in the dispose() method'
        ''');
        return _StateWithSingleTickerProvider<T, R>();
      case MixinWith.tickerProviderStateMixin:
        assert(
            (initState != null || afterInitialBuild != null) && dispose != null,
            '''
initState` `dispose` must not be null because you are using TickerProviderStateMixin
and you are supposed to to instantiate your controllers in the initState() and dispose them
 in the dispose() method'
        ''');
        return _StateWithTickerProvider<T, R>();
      case MixinWith.automaticKeepAliveClientMixin:
        return _StateWithKeepAliveClient<T, R>();
      case MixinWith.widgetsBindingObserver:
        return _StateWithWidgetsBindingObserver<T, R>();
    }
  }
}

class _State<T, R> extends State<StateWithMixinBuilder<T, R>> {
  T? _mixin;
  Injected<R>? rm;
  InjectedBaseState? observe;
  late Widget _widget;
  late bool _isDisposed;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    if (widget.observe != null) {
      observe = widget.observe!();

      if (observe is Injected<R>) {
        rm = observe as Injected<R>;
        // rm?.initialize();
      }
    }

    _widget = observe != null
        ? On(() {
            return widget.builderWithChild != null
                ? widget.builderWithChild!(context, rm, widget.child!)
                : widget.builder!(context, rm);
          }).listenTo(
            observe!,
            onSetState: On(
              () {
                if (widget.afterRebuild != null) {
                  WidgetsBinding.instance?.addPostFrameCallback(
                    (_) =>
                        !_isDisposed ? widget.afterRebuild!(context, rm) : null,
                  );
                }
              },
            ),
            shouldRebuild: (_) => true,
          )
        : widget.builderWithChild != null
            ? widget.builderWithChild!(context, rm, widget.child!)
            : widget.builder!(context, rm);

    widget.initState?.call(context, rm, _mixin);
    if (widget.afterInitialBuild != null) {
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) => widget.afterInitialBuild!(context, rm),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    widget.dispose?.call(context, rm, _mixin);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.didChangeDependencies?.call(context, rm, _mixin);
  }

  @override
  void didUpdateWidget(StateWithMixinBuilder<T, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.didUpdateWidget?.call(context, oldWidget, _mixin);
  }

  @override
  Widget build(BuildContext context) {
    return _widget;
  }
}

class _StateWithSingleTickerProvider<T, R> extends _State<T, R>
    with SingleTickerProviderStateMixin {
  @override
  T get _mixin => this as T;
}

class _StateWithTickerProvider<T, R> extends _State<T, R>
    with TickerProviderStateMixin {
  @override
  T get _mixin => this as T;
}

class _StateWithKeepAliveClient<T, R> extends _State<T, R>
    with AutomaticKeepAliveClientMixin {
  @override
  T get _mixin => this as T;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _widget;
  }

  @override
  bool get wantKeepAlive => true;
}

class _StateWithWidgetsBindingObserver<T, R> extends _State<T, R>
    with WidgetsBindingObserver {
  @override
  T get _mixin => this as T;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.didChangeAppLifecycleState?.call(context, state);
  }

  @override
  void didChangeLocales(List<Locale>? locale) {
    widget.didChangeLocales?.call(context, locale);
  }
}
