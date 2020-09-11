part of '../builders.dart';

/// One of the four observer widgets in states_rebuilder
///
/// [WhenRebuilder], [WhenRebuilderOr] and [OnSetStateListener]
///
class StateBuilder<T> extends StatefulWidget {
  ///```dart
  ///StateBuilder(
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state.
  ///
  ///The builder is provided with a [BuildContext] and [ReactiveModel] parameters.
  final Widget Function(BuildContext context, ReactiveModel<T> model) builder;

  ///an observable class to which you want [StateBuilder] to subscribe.
  ///```dart
  ///StateBuilder(
  ///  observe:()=> myModel1,
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///states_rebuilder uses the observer pattern.
  ///
  ///Observable classes are classes that extends [StatesRebuilder].
  ///[ReactiveModel] is one of them.
  final StatesRebuilder<T> Function() observe;

  ///List of observable classes to which you want [StateBuilder] to subscribe.
  ///```dart
  ///StateBuilder(
  ///  observeMany:[()=> myModel1,()=> myModel2,()=> myModel3],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///states_rebuilder uses the observer pattern.
  ///
  ///Observable classes are classes that extends [StatesRebuilder].
  ///[ReactiveModel] is one of them.
  final List<StatesRebuilder Function()> observeMany;

  ///A tag or list of tags you want this [StateBuilder] to register with.
  ///
  ///Whenever any of the observable model to which this [StateBuilder] is subscribed emits
  ///a notifications with a list of filter tags, this [StateBuilder] will rebuild if the
  ///the filter tags list contains at least on of those tags.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  ///
  ///Each [StateBuilder] has a default tag which is its [BuildContext]
  final dynamic tag;

  ///```dart
  ///StateBuilder(
  ///  initState:(BuildContext context, ReactiveModel model)=> myModel.init([context,model]),
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  final void Function(BuildContext context, ReactiveModel<T> model) initState;

  ///```dart
  ///StateBuilder(
  ///  dispose:(BuildContext context, ReactiveModel model) {
  ///     myModel.dispose([context, model]);
  ///   },
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  final void Function(BuildContext context, ReactiveModel<T> model) dispose;

  ///```dart
  ///StateBuilder(
  ///  didChangeDependencies:(BuildContext context, ReactiveModel model) {
  ///     //...your code
  ///   },
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called when a dependency of this [State] object changes.
  final void Function(BuildContext context, ReactiveModel<T> model)
      didChangeDependencies;

  ///```dart
  ///StateBuilder(
  ///  didUpdateWidget:(BuildContext context, ReactiveModel model,StateBuilder oldWidget) {
  ///     myModel.dispose([context, model]);
  ///   },
  ///  models:[myModel],
  ///  builder:(BuildContext context, ReactiveModel model) =>MyWidget(),
  ///)
  ///```
  ///Called whenever the widget configuration changes.
  final void Function(BuildContext context, ReactiveModel<T> model,
      StateBuilder<T> oldWidget) didUpdateWidget;

  ///Called after the widget is first inserted in the widget tree.
  final void Function(BuildContext context, ReactiveModel<T> model)
      afterInitialBuild;

  ///Called after each rebuild of the widget.
  final void Function(BuildContext context, ReactiveModel<T> model)
      afterRebuild;

  ///if it is set to true all observable models will be disposed.
  ///
  ///Models are disposed by calling the 'dispose()' method if exists.
  ///
  ///In any of the injected class you can define a 'dispose()' method to clean up resources.
  final bool disposeModels;

  ///```dart
  ///StateBuilder(
  ///  models:[myModel],
  ///  builderWithChild:(BuildContext context, ReactiveModel model, Widget child) =>MyWidget(child),
  ///  child : MyChildWidget(),
  ///)
  ///```
  ///The build strategy currently used to rebuild the state with child parameter.
  ///
  ///The builder is provided with a [BuildContext], [ReactiveModel] and [Widget] parameters.
  final Widget Function(
          BuildContext context, ReactiveModel<T> model, Widget child)
      builderWithChild;

  ///The child to be used in [builderWithChild].
  final Widget child;

  ///Called whenever this widget is notified.
  final dynamic Function(BuildContext context, ReactiveModel<T> model)
      onSetState;

  /// Called whenever this widget is notified and after rebuilding the widget.
  final void Function(BuildContext context, ReactiveModel<T> model)
      onRebuildState;

  /// callback to be executed before notifying listeners. It the returned value is
  /// the same as the last one, the rebuild process is interrupted.
  ///
  final Object Function(ReactiveModel<T> model) watch;

  ///Callback to determine whether this StateBuilder will rebuild or not.
  ///
  final bool Function(ReactiveModel<T> model) shouldRebuild;

  ///ReactiveModel key used to control this widget from outside its [builder] method.
  final RMKey rmKey;

  /// One of the four observer widgets in states_rebuilder
  ///
  /// [WhenRebuilder], [WhenRebuilderOr] and [OnSetStateListener]
  StateBuilder({
    Key key,
    // For state management
    this.builder,
    // this.models,
    this.observe,
    this.observeMany,
    this.tag,
    this.builderWithChild,
    this.child,
    this.onSetState,
    this.onRebuildState,
    this.watch,
    this.shouldRebuild,
    this.rmKey,

    // For state lifecycle
    this.initState,
    this.dispose,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.afterInitialBuild,
    this.afterRebuild,
    this.disposeModels,
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
        super(key: key);

  @override
  State<StateBuilder<T>> createState() {
    // if (observeMany == null && observe != null) {
    //   return StateBasic<T>();
    // }
    return StateBuilderState<T>();
  }
}

///The state of [StateBuilder]
class StateBuilderState<T> extends State<StateBuilder<T>>
    with ObserverOfStatesRebuilder {
  String _autoGeneratedTag;
  _IObserversResolver<T> _observersResolver;
  ReactiveModel<T> get _exposedModel => _observersResolver._exposedModel;
  List<StatesRebuilder<dynamic>> get _models => _observersResolver._models;
  @override
  void initState() {
    super.initState();
    InjectorState.contextSet.add(context);
    _autoGeneratedTag = 'AutoGeneratedTag#|:${context.hashCode}';
    _observersResolver = widget.observeMany == null
        ? _ObserversResolverOne(widget.observe)
        : _ObserversResolverMany(widget.observe, widget.observeMany);
    _observersResolver._resolveModels(this);
    _initState(this);

    if (widget.initState != null) {
      final rm = _observersResolver._exposedModelFromGenericType;
      (rm as ReactiveModelInternal).activeRM = _observersResolver._activeRM;
      widget.initState(
        context,
        rm,
      );
    }
    if (widget.afterInitialBuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterInitialBuild(context, _exposedModel),
      );
    }
    if (widget.watch != null) {
      _cashedWatch = widget.watch(_exposedModel);
    }
  }

  // void Function(ReactiveModel) _rmKeyInitCallback;

  @override
  void dispose() {
    if (widget.dispose != null) {
      final rm = _observersResolver._exposedModelFromGenericType;
      (rm as ReactiveModelInternal).activeRM = _observersResolver._activeRM;
      widget.dispose(
        context,
        rm,
      );
    }
    _dispose<T>(this);
    _cashedWatch = null;
    _actualWatch = null;
    InjectorState.contextSet.remove(context);
    super.dispose();
  }

  dynamic _cashedWatch;
  dynamic _actualWatch;
  int _numberOfRebuild = 0;
  bool _isDirty = false;
  @override
  void update(
      [dynamic Function(BuildContext) onSetState, dynamic reactiveModel]) {
    if (!mounted) {
      return;
    }
    final _exposedModelFromNotification =
        reactiveModel is ReactiveModel<T> ? reactiveModel : null;
    _observersResolver._exposedModelFromNotification =
        _exposedModelFromNotification;
    bool canRebuild = true;
    if (widget.watch != null) {
      _actualWatch = widget.watch(_exposedModel);

      canRebuild =
          !(const DeepCollectionEquality().equals(_actualWatch, _cashedWatch));

      _cashedWatch = _actualWatch;
    }

    if (canRebuild == false) {
      return;
    }

    if (widget.onSetState != null) {
      widget.onSetState(context, _exposedModel);
    } else if (onSetState != null) {
      onSetState(context);
    }

    if (_exposedModel != null &&
        (widget.shouldRebuild ??
                (rm) => rm.hasData || rm.isIdle != false)(_exposedModel) ==
            false) {
      return;
    }

    setState(() {});

    assert(() {
      if (!_isDirty) {
        _isDirty = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (RM.debugWidgetsRebuild == true &&
              _exposedModelFromNotification != null) {
            String observer = 'StateBuilder';
            if (widget.builderWithChild == null && widget.child != null) {
              if (widget.child is Text) {
                final data = (widget.child as Text).data;
                if (data.contains('#|0|#')) {
                  observer = 'WhenRebuilder';
                } else if (data.contains('#|1|#')) {
                  observer = 'WhenRebuilderOr';
                }
              }
            }
            final status = _exposedModelFromNotification?.whenConnectionState(
              onIdle: () => 'isIdle',
              onWaiting: () => 'isWaiting',
              onData: (T _) => 'hasData',
              onError: (dynamic _) => 'hasError',
              catchError: false,
            );
            final name = widget.key != null ? '${widget.key} | ' : '';

            developer.log(
              '$observer($hashCode) |'
              '$name'
              '${_exposedModelFromNotification?.type()}($status)',
              name: 'states_rebuilder Widget Rebuild',
              error: '|# ${++_numberOfRebuild} #| rebuild times',
            );
          }
        });
      }
      return true;
    }());

    if (widget.onRebuildState != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          widget.onRebuildState(context, _exposedModel);
        },
      );
    }
  }

  void _setState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    _isDirty = false;

    if (widget.afterRebuild != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.afterRebuild(context, _exposedModel),
      );
    }

    if (widget.builderWithChild != null) {
      return widget.builderWithChild(context, _exposedModel, widget.child);
    }
    return widget.builder(context, _exposedModel);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.didChangeDependencies != null)
      widget.didChangeDependencies(context, _exposedModel);
  }

  @override
  void didUpdateWidget(StateBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rmKey != null) {
      oldWidget.rmKey.rm = null;
      oldWidget.rmKey.initialValue = null;
      oldWidget.rmKey.initCallBack = null;
      widget.rmKey.rm = _exposedModel;
      _models?.where((m) => m is ReactiveModel)?.forEach((rm) {
        widget.rmKey.associate(rm as ReactiveModel);
      });
    }
    if (this is StateBuilderState<Injector>) {
      return;
    }

    if (widget.didUpdateWidget != null) {
      widget.didUpdateWidget(context, _exposedModel, oldWidget);
    }
  }
}

void _initState<T>(StateBuilderState<T> state) {
  if (state._models == null) {
    return;
  }

  for (StatesRebuilder model in state._models) {
    assert(model != null);
    _subscribe<T>(model, state);

    if (model is RMKey && !model.isLinked) {
      model.initCallBack.add((rm, rmInit) {
        (rmInit ?? model.rm).copy(rm);
        Future.microtask(() => state._setState());
      });
    }
  }

  if (state.widget.rmKey != null) {
    state.widget.rmKey.rm = state._exposedModel;
    state.widget.rmKey.refreshCallBack = (rm) {
      state._observersResolver
        .._exposedModelFromNotification = null
        .._resolveModels(state, true);
      state.widget.rmKey.rm = state._exposedModel;
    };

    state._models.where((m) => m is ReactiveModel).forEach((rm) {
      state.widget.rmKey.associate(rm as ReactiveModel);
    });
  }
}

void _dispose<T>(StateBuilderState<T> state) {
  state._observersResolver.dispose(state);
  state.widget.rmKey?.cleanRMKey();
}

void _subscribe<T>(StatesRebuilder model, StateBuilderState<T> state) {
  final widget = state.widget;

  model?.addObserver(observer: state, tag: state._autoGeneratedTag);
  if (widget.tag != null) {
    if (widget.tag is List) {
      for (var tag in widget.tag) {
        model?.addObserver(observer: state, tag: tag.toString());
      }
    } else {
      model?.addObserver(observer: state, tag: state.widget.tag.toString());
    }
  }
}

void _unsubscribe<T>(StatesRebuilder model, StateBuilderState<T> state) {
  final widget = state.widget;
  model?.removeObserver(observer: state, tag: state._autoGeneratedTag);
  if (widget.tag != null) {
    if (widget.tag is List) {
      for (var tag in widget.tag) {
        model?.removeObserver(observer: state, tag: tag.toString());
      }
    } else {
      model?.removeObserver(observer: state, tag: widget.tag.toString());
    }
  }
}

abstract class _IObserversResolver<T> {
  List<StatesRebuilder> _models = [];
  ReactiveModel<T> get _exposedModel;
  ReactiveModel<T> _exposedModelFromGenericType;
  ReactiveModel<T> _exposedModelFromNotification;
  List<ReactiveModel<dynamic>> _activeRM;

  void _resolveModels(StateBuilderState<T> state, [bool refresh = false]);
  void dispose(StateBuilderState<T> state) {
    _exposedModelFromGenericType?.inject
        ?.removeFromReactiveNewInstanceList(_exposedModelFromGenericType);
    if (_models == null) {
      return;
    }
    for (var model in _models) {
      if (state.widget.disposeModels == true) {
        try {
          if (model != null) {
            (model as dynamic)?.dispose();
          }
        } catch (e) {
          if (e is! NoSuchMethodError) {
            rethrow;
          }
        }
      }
      _unsubscribe(model, state);
    }

    _models = null;
    _exposedModelFromGenericType = null;
    _exposedModelFromNotification = null;
  }
}

class _ObserversResolverOne<T> extends _IObserversResolver<T> {
  final StatesRebuilder<T> Function() observe;

  _ObserversResolverOne(this.observe);

  @override
  ReactiveModel<T> get _exposedModel => _exposedModelFromGenericType;

  @override
  void _resolveModels(StateBuilderState<T> state, [bool refresh = false]) {
    if (observe == null) {
      _models.clear();
      //No observer is provided
      //Create new ReactiveModel model and expose it.
      if (T == dynamic) {
        throw Exception(AssertMessage.noModelsAndDynamicType());
      }
      _exposedModelFromGenericType =
          Injector.getAsReactive<T>()?.inject?.getReactive(true);

      _activeRM = (_exposedModelFromGenericType as ReactiveModelInternal)
          .activeRM = [_exposedModelFromGenericType];

      _subscribe<T>(_exposedModelFromGenericType, state);
      return;
    }
    if (refresh) {
      final m = observe?.call();
      _models.removeAt(0).copy(m);
      _models.insert(0, m);
    } else {
      _models.add(observe?.call());
    }

    if (_models.first is ReactiveModel<T>) {
      _exposedModelFromGenericType = _models.first as ReactiveModel<T>;
      _activeRM = (_exposedModelFromGenericType as ReactiveModelInternal)
          .activeRM = [_exposedModelFromGenericType];
    }
  }
}

class _ObserversResolverMany<T> extends _IObserversResolver<T> {
  final StatesRebuilder<T> Function() observe;
  final List<StatesRebuilder Function()> observeMany;

  _ObserversResolverMany(this.observe, this.observeMany);

  ReactiveModel<T> get _exposedModel {
    final rm = T == dynamic
        ? _exposedModelFromNotification ?? _exposedModelFromGenericType
        : _exposedModelFromGenericType;
    (rm as ReactiveModelInternal).activeRM = _activeRM;
    return rm;
  }

  @override
  void _resolveModels(StateBuilderState<T> state, [bool refresh = false]) {
    //_resolveModels means fill _models and assign _exposedModelFromGenericType
    _exposedModelFromGenericType = null;

    if (observe != null) {
      if (refresh) {
        final m = observe?.call();
        _models.removeAt(0).copy(m);
        _models.insert(0, m);
      } else {
        _models.add(observe?.call());
      }

      if (_models.first is ReactiveModel<T>) {
        _exposedModelFromGenericType = _models.first as ReactiveModel<T>;
      }
    } else if (observeMany.isEmpty) {
      return;
    }

    if (observeMany != null) {
      for (var fn in observeMany) {
        _models.add(fn?.call());
      }
    }

    _activeRM =
        _models.where((m) => m is ReactiveModel).toList().cast<ReactiveModel>();

    if (_exposedModelFromGenericType != null) {
      //if _exposedModelFromGenericType is obtained for observer, return;
      return;
    }

    if (T != dynamic) {
      //expose the model of the type T
      for (var model in _models) {
        if (model is ReactiveModel<T>) {
          _exposedModelFromGenericType = model;
          return;
        }
      }
    }
    //At the end expose the first model
    if (_models.first is ReactiveModel<T>) {
      _exposedModelFromGenericType = _models.first as ReactiveModel<T>;
      return;
    }
  }
}
