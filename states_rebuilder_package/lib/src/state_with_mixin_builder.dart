import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/src/state_builder.dart';

import 'states_rebuilder.dart';

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

class StateWithMixinBuilder<T> extends StatefulWidget {
  ///```dart
  ///StateWithMixinBuilder(
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state.
  ///
  ///The builder is provided with an [BuildContext] and [ReactiveModel<T>] parameters.
  final Widget Function(BuildContext context, ReactiveModel<T> model) builder;

  ///```dart
  ///StateWithMixinBuilder(
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model, Widget child) =>MyWidget(),
  ///  child : MyChildWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state with child parameter.
  ///
  ///The builder is provided with a [BuildContext], [ReactiveModel] and [Widget] parameters.
  final Widget Function(BuildContext context, Widget child) builderWithChild;

  ///The child to be used in [builderWithChild].
  final Widget child;

  ///```dart
  ///StateWithMixinBuilder(
  ///  models:[myModel1, myModel2,myModel3],//If you want this widget to not rebuild, do not define any model.
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///List of your logic classes you want to rebuild this widget from.
  ///The logic class should extend  `StatesWithMixinRebuilder`of the states_rebuilder package.
  final List<StatesRebuilder> models;
  final StatesRebuilder Function() observe;
  final List<StatesRebuilder Function()> observeMany;

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
  ///  initState:(BuildContext context,  TickerProvider ticker)=> myModel.init([context, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, T mix) initState;

  ///```dart
  ///StateWithMixinBuilder(
  ///  dispose:(BuildContext context,  TickerProvider ticker)=> myModel.dispose([context, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, T mix) dispose;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeDependencies:(BuildContext context,  TickerProvider ticker)=> myModel.myMethod([context, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  ///
  ///The second parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, T mix) didChangeDependencies;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didUpdateWidget:(BuildContext context, StateBuilderBase oldWidget, TickerProvider ticker)=> myModel.myMethod([context,oldWidget, ticker]),
  ///  MixinWith : MixinWith.singleTickerProviderStateMixin
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(
          BuildContext context, StateWithMixinBuilder<dynamic> oldWidget, T mix)
      didUpdateWidget;

  ///Called after the widget is inserted in the widget tree.
  final void Function(BuildContext context, T mix) afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context) afterRebuild;

  ///```dart
  ///StateWithMixinBuilder(
  ///  didChangeAppLifecycleState:(BuildContext context,  AppLifecycleState state)=> myModel.myMethod([context, state]),
  ///  MixinWith : MixinWith.widgetsBindingObserver
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when the system puts the app in the background or returns the app to the foreground.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, AppLifecycleState state)
      didChangeAppLifecycleState;

  StateWithMixinBuilder({
    Key key,
    this.tag,
    this.models,
    this.observe,
    this.observeMany,
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
    @required this.mixinWith,
  })  : assert(builder != null || builderWithChild != null, '''
  
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
        assert(mixinWith != null),
        super(key: key);
  @override
  _State<T> createState() {
    switch (mixinWith) {
      case MixinWith.singleTickerProviderStateMixin:
        assert(
            (initState != null || afterInitialBuild != null) && dispose != null,
            '''
initState` `dispose` must not be null because you are using SingleTickerProviderStateMixin
and you are supposed to to instantiate your controllers in the initState() and dispose them
 in the dispose() method'
        ''');
        return _StateWithSingleTickerProvider<T>();
        break;
      case MixinWith.tickerProviderStateMixin:
        assert(
            (initState != null || afterInitialBuild != null) && dispose != null,
            '''
initState` `dispose` must not be null because you are using TickerProviderStateMixin
and you are supposed to to instantiate your controllers in the initState() and dispose them
 in the dispose() method'
        ''');
        return _StateWithTickerProvider<T>();
        break;
      case MixinWith.automaticKeepAliveClientMixin:
        return _StateWithKeepAliveClient<T>();
        break;
      case MixinWith.widgetsBindingObserver:
        return _StateWithWidgetsBindingObserver<T>();
        break;
      default:
        return null;
    }
  }
}

class _State<T> extends State<StateWithMixinBuilder<T>> {
  T _mixin;

  @override
  void initState() {
    super.initState();
    if (widget.initState != null) {
      widget.initState(context, _mixin);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null) {
      widget.didChangeDependencies(context, _mixin);
    }
  }

  @override
  void didUpdateWidget(StateWithMixinBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.didUpdateWidget != null) {
      widget.didUpdateWidget(context, oldWidget, _mixin);
    }
  }

  Widget get _stateBuilder => StateBuilder(
        models: widget.models ?? [],
        observe: widget.observe,
        observeMany: widget.observeMany ?? [],
        tag: widget.tag,
        afterInitialBuild: (context, _) {
          if (widget.afterInitialBuild != null) {
            widget.afterInitialBuild(context, _mixin);
          }
        },
        afterRebuild: (context, _) {
          if (widget.afterRebuild != null) {
            widget.afterRebuild(context);
          }
        },
        builder: (context, _) {
          if (widget.builderWithChild != null) {
            return widget.builderWithChild(context, widget.child);
          }
          return widget.builder(context, null);
        },
      );

  @override
  Widget build(BuildContext context) {
    return _stateBuilder;
  }
}

class _StateWithSingleTickerProvider<T> extends _State<T>
    with SingleTickerProviderStateMixin {
  @override
  T get _mixin => this as T;
  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose(context, _mixin);
    }
    super.dispose();
  }
}

class _StateWithTickerProvider<T> extends _State<T>
    with TickerProviderStateMixin {
  @override
  T get _mixin => this as T;
  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose(context, _mixin);
    }
    super.dispose();
  }
}

class _StateWithKeepAliveClient<T> extends _State<T>
    with AutomaticKeepAliveClientMixin {
  @override
  T get _mixin => this as T;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _stateBuilder;
  }

  @override
  bool get wantKeepAlive => true;
}

class _StateWithWidgetsBindingObserver<T> extends _State<T>
    with WidgetsBindingObserver {
  @override
  T get _mixin => this as T;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.didChangeAppLifecycleState != null)
      widget.didChangeAppLifecycleState(context, state);
  }
}
