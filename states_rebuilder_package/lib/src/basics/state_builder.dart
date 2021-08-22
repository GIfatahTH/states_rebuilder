part of '../rm.dart';

typedef SetState = bool Function();

///Custom StateFullWidget
class StateBuilderBase<T> extends MyStatefulWidget {
  final LifeCycleHooks<T> Function(
    T widget,
    SetState setState,
  ) initState;

  final T widget;
  const StateBuilderBase(
    this.initState, {
    Key? key,
    required this.widget,
  }) : super(key: key);

  @override
  _StateBuilderBaseState<T> createState() {
    return _StateBuilderBaseState();
  }
}

class _StateBuilderBaseState<T> extends ExtendedState<StateBuilderBase<T>> {
  late LifeCycleHooks<T> _builder;
  bool _isMounted = false;
  bool isDirty = false;
  late VoidCallback removeFromContextSet;
  @override
  void initState() {
    super.initState();
    _builder = widget.initState(
      widget.widget,
      () {
        if (mounted) {
          setState(() {});
        }
        return false;
      },
    );

    _isMounted = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = null;
    if (!_isMounted) {
      removeFromContextSet = addToContextSet(context);
      _builder.mountedState?.call(context);
      OnReactiveState.addToObs = cachedAddToObs;
      _isMounted = true;
    }
    _builder.didChangeDependencies?.call(context);
    OnReactiveState.addToObs = cachedAddToObs;
  }

  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = null;
    _builder.didUpdateWidget?.call(context, oldWidget.widget, widget.widget);
    OnReactiveState.addToObs = cachedAddToObs;
  }

  void dispose() {
    _builder.dispose?.call(context);
    removeFromContextSet();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _builder.builder(context, widget.widget);
  }
}

class LifeCycleHooks<T> {
  final void Function(BuildContext context)? mountedState;
  final void Function(BuildContext context)? afterBuild;
  final void Function(BuildContext context)? dispose;
  final void Function(BuildContext context)? didChangeDependencies;
  final void Function(BuildContext context, T oldWidget, T newWidget)?
      didUpdateWidget;
  final Widget Function(BuildContext context, T widget) builder;

  LifeCycleHooks({
    required this.builder,
    this.mountedState,
    this.afterBuild,
    this.dispose,
    this.didUpdateWidget,
    this.didChangeDependencies,
  });
}

class StateBuilderBaseWithTicker<T> extends MyStatefulWidget {
  final LifeCycleHooks<T> Function(
    T widget,
    SetState setState,
    TickerProvider? ticker,
  ) initState;

  final T widget;
  final bool Function() withTicker;
  const StateBuilderBaseWithTicker(
    this.initState, {
    Key? key,
    required this.widget,
    required this.withTicker,
  }) : super(key: key);

  @override
  State<StateBuilderBaseWithTicker<T>> createState() {
    return withTicker()
        ? _StateBuilderBaseWithTickerState<T>()
        : _StateBuilderBaseWithOutTicker<T>();
  }
}

class _StateBuilderBase<T> extends State<StateBuilderBaseWithTicker<T>> {
  late LifeCycleHooks<T> _builder;
  bool _isMounted = false;
  bool isDirty = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = null;
    if (!_isMounted) {
      _builder.mountedState?.call(context);
      _isMounted = true;
    }
    _builder.didChangeDependencies?.call(context);
    OnReactiveState.addToObs = cachedAddToObs;
  }

  void didUpdateWidget(oldWidget) {
    final cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = null;
    super.didUpdateWidget(oldWidget);
    OnReactiveState.addToObs = cachedAddToObs;
    _builder.didUpdateWidget?.call(context, oldWidget.widget, widget.widget);
  }

  @override
  Widget build(BuildContext context) {
    return _builder.builder(context, widget.widget);
  }
}

class _StateBuilderBaseWithOutTicker<T> extends _StateBuilderBase<T> {
  @override
  void initState() {
    super.initState();
    _builder = widget.initState(
      widget.widget,
      () {
        if (mounted) {
          setState(() {});
        }
        return false;
      },
      null,
    );

    _isMounted = false;
  }

  void dispose() {
    _builder.dispose?.call(context);
    super.dispose();
  }
}

class _StateBuilderBaseWithTickerState<T> extends _StateBuilderBase<T>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _builder = widget.initState(
      widget.widget,
      () {
        if (mounted) {
          setState(() {});
        }
        return false;
      },
      this,
    );

    _isMounted = false;
  }

  void dispose() {
    _builder.dispose?.call(context);
    super.dispose();
  }
}

abstract class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  StatefulElement createElement() {
    return MyElement(this);
  }
}

class MyElement extends StatefulElement {
  MyElement(StatefulWidget widget) : super(widget);

  @override
  void performRebuild() {
    super.performRebuild();
    if (state is ExtendedState) {
      (state as ExtendedState).afterBuild();
    }
  }
}

abstract class ExtendedState<T extends StatefulWidget> extends State<T> {
  void afterBuild() {}
}
