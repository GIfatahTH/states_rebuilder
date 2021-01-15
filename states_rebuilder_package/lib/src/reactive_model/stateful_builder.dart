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
    this.rm = const [],
  }) : super(key: key);

  /// Called to obtain the child widget.
  ///
  /// This function is called whenever this widget is included in its parent's
  /// build and the old widget (if any) that it synchronizes with has a distinct
  /// object identity. Typically the parent's build method will construct
  /// a new tree of widgets and so a new Builder child will not be [identical]
  /// to the corresponding old one.
  final WidgetBuilder builder;
  final Disposer Function(BuildContext context, bool Function() setState)
      initState;
  final void Function(BuildContext context)? dispose;
  final void Function(BuildContext context)? didChangeDependencies;
  final void Function(BuildContext context, _StateBuilder oldWidget)?
      didUpdateWidget;
  final Object? Function()? watch;
  final List<ReactiveModel<T>?> rm;
  @override
  _StateBuilderState createState() => watch == null
      ? _StateBuilderWithoutWatchState()
      : _StateBuilderWithWatchState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // properties.add(
    //     StringProperty('state', widget.rm.first.toString(), showName: true));
    // if (textSpan != null) {
    //   properties.add(textSpan!.toDiagnosticsNode(name: 'textSpan', style: DiagnosticsTreeStyle.transition));
    // }
    // style?.debugFillProperties(properties);
    // properties.add(EnumProperty<TextAlign>('textAlign', textAlign, defaultValue: null));
    // properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
    properties.add(IterableProperty<ReactiveModel<T>?>(
      'Injected',
      rm,
      defaultValue: null,
      showName: true,
    ));
    // properties.add(FlagProperty('softWrap', value: softWrap, ifTrue: 'wrapping at box width', ifFalse: 'no wrapping except at line break characters', showName: true));
    // properties.add(EnumProperty<TextOverflow>('overflow', overflow, defaultValue: null));
    // properties.add(DoubleProperty('textScaleFactor', textScaleFactor, defaultValue: null));
    // properties.add(IntProperty('maxLines', maxLines, defaultValue: null));
    // properties.add(EnumProperty<TextWidthBasis>('textWidthBasis', textWidthBasis, defaultValue: null));
    // properties.add(DiagnosticsProperty<ui.TextHeightBehavior>('textHeightBehavior', textHeightBehavior, defaultValue: null));
    // if (semanticsLabel != null) {
    //   properties.add(StringProperty('semanticsLabel', semanticsLabel));
    // }
  }
}

class _StateBuilderState extends State<_StateBuilder> {
  late Disposer _disposer;
  late Disposer _removeContext;
  bool _isDirty = true;
  bool _isDeactivate = true;
  Object? _cachedWatch;

  @override
  void deactivate() {
    super.deactivate();
    _isDeactivate = true;
    _removeContext();
  }

  void dispose() {
    widget.dispose?.call(context);
    Future.microtask(() => _disposer());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.didChangeDependencies?.call(context);
  }

  @override
  void didUpdateWidget(covariant _StateBuilder oldWidget) {
    for (var i = 0; i < widget.rm.length; i++) {
      if (oldWidget.rm[i] != widget.rm[i]) {
        oldWidget.rm[i]!.cloneToAndClean(widget.rm[i]!);
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
    return widget.builder(context);
  }
}

class _StateBuilderWithoutWatchState extends _StateBuilderState {
  @override
  void initState() {
    super.initState();
    _disposer = widget.initState(
      context,
      () {
        if (!_isDirty) {
          _isDirty = true;
          setState(() {});
          return true;
        }
        return false;
      },
    );
  }
}

class _StateBuilderWithWatchState extends _StateBuilderState {
  @override
  void initState() {
    super.initState();
    _cachedWatch = widget.watch?.call();
    _disposer = widget.initState(
      context,
      () {
        if (widget.watch != null) {
          if (deepEquality.equals(
              _cachedWatch, _cachedWatch = widget.watch!())) {
            return false;
          }
        }

        if (!_isDirty) {
          _isDirty = true;
          setState(() {});
          return true;
        }
        return false;
      },
    );
  }
}
