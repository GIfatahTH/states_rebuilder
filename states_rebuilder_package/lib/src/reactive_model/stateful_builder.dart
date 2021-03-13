part of '../reactive_model.dart';

class _StateBuilder<T> extends StatefulWidget {
  /// Creates a widget that both has state and delegates its build to a callback.
  ///
  /// The [builder] argument must not be null.
  const _StateBuilder({
    Key? key,
    required this.builder,
    required this.initState,
    this.dispose,
    this.watch,
    this.didChangeDependencies,
    this.didUpdateWidget,
    this.rm,
    this.isLite = false,
  }) : super(key: key);

  /// Called to obtain the child widget.
  ///
  /// This function is called whenever this widget is included in its parent's
  /// build and the old widget (if any) that it synchronizes with has a distinct
  /// object identity. Typically the parent's build method will construct
  /// a new tree of widgets and so a new Builder child will not be [identical]
  /// to the corresponding old one.
  final Widget Function(BuildContext context, ReactiveModel? rm) builder;
  final Disposer Function(BuildContext context,
      bool Function(ReactiveModel? rm) setState, ReactiveModel? rm) initState;
  final void Function(BuildContext context)? dispose;
  final void Function(BuildContext context)? didChangeDependencies;
  final void Function(BuildContext context, _StateBuilder<T> oldWidget)?
      didUpdateWidget;
  final Object? Function()? watch;
  final List<ReactiveModel<dynamic>>? rm;
  final bool isLite;
  @override
  State createState() => isLite
      ? _StateBuilderLiteState<T>()
      : watch == null
          ? _StateBuilderWithoutWatchState<T>()
          : _StateBuilderWithWatchState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<ReactiveModel<dynamic>?>(
      'Injected',
      rm,
      defaultValue: null,
      showName: true,
    ));
  }
}

class _StateBuilderState<T> extends State<_StateBuilder<T>> {
  late Disposer _disposer;
  late Disposer _removeContext;
  bool _isDirty = true;
  bool _isDeactivate = true;
  bool _isMounted = false;
  Object? _cachedWatch;
  ReactiveModel<T>? rm;
  ReactiveModel? rmNotified;

  @override
  void initState() {
    super.initState();
    _isMounted = false;
    bool isA<D>() => T == D;

    if (!isA<Object?>() && T != dynamic && T != Object) {
      rm = widget.rm?.firstWhereOrNull((e) => e is ReactiveModel<T>)
          as ReactiveModel<T>?;
    }

    // _removeContext = RM._addToContextSet(context);
  }

  @override
  void deactivate() {
    super.deactivate();
    _isDeactivate = true;
    _removeContext();
  }

  @override
  void dispose() {
    widget.dispose?.call(context);
    Future.microtask(() => _disposer());
    // _disposer();
    // _removeContext();

    rm = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.didChangeDependencies?.call(context);
  }

  @override
  void didUpdateWidget(covariant _StateBuilder<T> oldWidget) {
    if (widget.rm == null) {
      return;
    }
    for (var i = 0; i < widget.rm!.length; i++) {
      if (oldWidget.rm![i] != widget.rm![i]) {
        oldWidget.rm![i].cloneToAndClean(widget.rm![i]);
      }
    }

    super.didUpdateWidget(oldWidget);
    widget.didUpdateWidget?.call(context, oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    _isDirty = false;
    if (_isDeactivate) {
      _removeContext = RM._addToContextSet(context);
      _isDeactivate = false;
    }
    return widget.builder(context, rm ?? rmNotified ?? widget.rm?.first);
  }
}

class _StateBuilderWithoutWatchState<T> extends _StateBuilderState<T> {
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isMounted) {
      return;
    }
    _isMounted = true;
    _disposer = widget.initState(
      context,
      (rm) {
        if (!_isDirty) {
          _isDirty = true;
          rmNotified = rm;
          // print(SchedulerBinding.instance?.schedulerPhase);
          setState(() {});
          // SchedulerBinding.instance?.scheduleFrameCallback(
          //   (_) => ,
          // );
          return true;
        }
        return false;
      },
      rm ?? rmNotified,
    );
  }
}

class _StateBuilderWithWatchState<T> extends _StateBuilderState<T> {
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isMounted) {
      return;
    }
    _isMounted = true;
    _cachedWatch = widget.watch?.call();
    _disposer = widget.initState(
      context,
      (rm) {
        if (widget.watch != null) {
          if (deepEquality.equals(
              _cachedWatch, _cachedWatch = widget.watch!())) {
            return false;
          }
        }

        if (!_isDirty) {
          _isDirty = true;
          rmNotified = rm;
          setState(() {});
          // SchedulerBinding.instance?.scheduleFrameCallback(
          //   (_) => ,
          // );
          return true;
        }
        return false;
      },
      rm ?? rmNotified,
    );
  }
}

class _StateBuilderLiteState<T> extends State<_StateBuilder<T>> {
  late Disposer _disposer;

  @override
  void initState() {
    super.initState();
    _disposer = widget.initState(
      context,
      (_) {
        if (mounted) {
          setState(() {});
        }
        return false;
      },
      null,
    );
  }

  void dispose() {
    widget.dispose?.call(context);
    Future.microtask(() => _disposer());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, null);
  }
}
