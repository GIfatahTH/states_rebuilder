part of '../rm.dart';

class MyStatefulWidget<T> extends IStatefulWidget {
  MyStatefulWidget({
    required Key? key,
    required this.observers,
    required Widget Function(BuildContext, SnapState<T>, ReactiveModel<T>)?
        builder,
    this.onSetState,
    this.sideEffects,
    this.shouldRebuild,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.initState,
    this.dispose,
    this.debugPrintWhenRebuild,
  })  : _builder = builder,
        super(key: key);
  final List<ReactiveModelImp> Function(BuildContext context) observers;
  final SideEffects<T>? sideEffects;
  final Widget Function(BuildContext, SnapState<T>, ReactiveModel<T>)? _builder;
  final void Function(BuildContext, SnapState<T>, ReactiveModel<T>)? onSetState;
  final void Function(BuildContext context, ReactiveModel<T>? model)?
      didChangeDependencies;
  final void Function(BuildContext context, ReactiveModel<T>? model,
      MyStatefulWidget<T> oldWidget)? didUpdateWidget;
  final void Function(BuildContext context, ReactiveModel<T>? model)? initState;
  final void Function(BuildContext context, ReactiveModel<T>? model)? dispose;
  final List<VoidCallback> cleaners = [];

  ///Whether to rebuild the widget after state notification.
  final ShouldRebuild? shouldRebuild;
  final String? debugPrintWhenRebuild;

  Widget builder(BuildContext context, SnapState<T> snap, ReactiveModel<T> rm) {
    assert(_builder != null);
    return _builder!(context, snap, rm);
  }

  @override
  _MyStatefulWidgetState<T> createState() => _MyStatefulWidgetState<T>();
}

class _MyStatefulWidgetState<T> extends ExtendedState<MyStatefulWidget<T>> {
  SnapState<T>? snap;
  ReactiveModel<T>? rm;
  List<VoidCallback> disposers = [];
  ObserveReactiveModel? cachedAddToObs;
  late var models = widget.observers(context);
  @override
  void initState() {
    super.initState();
    cachedAddToObs = ReactiveStatelessWidget.addToObs;
    ReactiveStatelessWidget.addToObs = null;

    setCombinedSnap(models);
    for (final model in models) {
      if (model.autoDisposeWhenNotUsed) {
        // ignore: unused_result
        model.addCleaner(model.dispose);
      }
      final disposer = model.addObserver(
        isSideEffects: false,
        listener: (model) {
          final shouldNotRebuild = false ==
              widget.shouldRebuild?.call(
                model._snapState.oldSnapState!,
                model._snapState,
              );
          if (shouldNotRebuild) {
            return;
          }

          setState(() {
            setCombinedSnap(models, model);
            widget.sideEffects
              ?..onSetState?.call(snap!)
              ..onAfterBuild?.call(!mounted);
            widget.onSetState?.call(context, snap!, rm!);
            if (widget.debugPrintWhenRebuild != null) {
              StatesRebuilerLogger.log('REBUILD <products>: $snap');
            }
          });
        },
        shouldAutoClean: model.autoDisposeWhenNotUsed,
      );
      disposers.add(disposer);
    }
    widget.sideEffects
      ?..initState?.call()
      ..onAfterBuild?.call();
    widget.initState?.call(context, rm);
  }

  void setCombinedSnap(
    List<ReactiveModelImp<dynamic>> models, [
    ReactiveModelImp<dynamic>? model,
  ]) {
    if (models.length == 1) {
      rm = models.first as ReactiveModel<T>;
      snap = (rm as ReactiveModelImp<T>).snapState;
      return;
    }
    bool isWaiting = false;
    bool isIdle = false;
    SnapError? snapError;
    SnapState<T>? _snap;
    rm = null;
    if (model != null) {
      if (model._snapState is SnapState<T>) {
        _snap ??= model._snapState as SnapState<T>;
        rm ??= model as ReactiveModel<T>;
      }
    }
    for (final model in models) {
      if (model.isWaiting) {
        isWaiting = true;
        // break;
      }
      if (model.hasError) {
        snapError = model._snapState.snapError;
      }
      if (model.isIdle) {
        isIdle = true;
      }
      if (model._snapState is SnapState<T>) {
        _snap ??= model._snapState as SnapState<T>;
        rm ??= model as ReactiveModel<T>;
      }
    }
    assert(_snap != null);
    if (isWaiting) {
      snap = _snap!.copyToIsWaiting();
    } else if (snapError != null) {
      snap = _snap!._copyToHasError(snapError);
    } else if (isIdle) {
      snap = _snap!.copyToIsIdle();
    } else {
      snap = _snap;
    }
  }

  @override
  void dispose() {
    widget.sideEffects?.dispose?.call();
    widget.dispose?.call(context, rm);

    for (var disposer in disposers) {
      disposer();
    }

    for (var disposer in widget.cleaners) {
      disposer();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.didChangeDependencies?.call(context, rm!);
  }

  @override
  void didUpdateWidget(covariant MyStatefulWidget<T> oldWidget) {
    // final newModels = widget.observers(context);

    // assert(models.length == newModels.length);
    // for (var i = 0; i < models.length; i++) {
    //   if (newModels[i].hashCode != models[i].hashCode) {
    //     newModels[i].resetDefaultState(models[i]);
    //   }
    // }
    // models = newModels;

    super.didUpdateWidget(oldWidget);
    widget.didUpdateWidget?.call(context, rm, oldWidget);
  }

  @override
  void afterBuild() {
    ReactiveStatelessWidget.addToObs = cachedAddToObs;
  }

  @override
  Widget build(BuildContext context) {
    cachedAddToObs = ReactiveStatelessWidget.addToObs;
    ReactiveStatelessWidget.addToObs = null;
    return widget.builder(context, snap!, rm!);
  }
}

abstract class IStatefulWidget extends StatefulWidget {
  const IStatefulWidget({Key? key}) : super(key: key);
  // final List<ReactiveModelImp> models;

  @override
  StatefulElement createElement() {
    return MyElement(this);
  }
}

class MyElement extends StatefulElement {
  MyElement(
    StatefulWidget widget,
  ) : super(widget);

  @override
  void performRebuild() {
    super.performRebuild();
    if (state is ExtendedState) {
      (state as ExtendedState).afterBuild();
    }
  }
}

abstract class ExtendedState<T extends StatefulWidget> extends State<T> {
  ReactiveModelImp? exposedRM;
  late VoidCallback removeFromContextSet;

  void afterBuild() {}
  void rebuildState(ReactiveModelImp rm) {}
  @override
  void initState() {
    super.initState();
    removeFromContextSet = addToContextSet(context);
  }

  @override
  void dispose() {
    removeFromContextSet();
    super.dispose();
  }
}
