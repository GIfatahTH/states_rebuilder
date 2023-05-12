part of 'injected_animation.dart';

extension InjectedAnimationX on InjectedAnimation {
  _Rebuild get rebuild => _Rebuild(this);
}

class _Rebuild {
  final InjectedAnimation inj;
  _Rebuild(this.inj);
  OnAnimationBuilder onAnimation(
    Widget Function(Animate) builder, {
    Key? key,
    void Function()? onInitialized,
  }) {
    return OnAnimationBuilder(
      key: key,
      listenTo: inj,
      builder: builder,
      onInitialized: onInitialized,
    );
  }

  call(Widget Function() builder) {
    return OnBuilder(
      listenTo: inj,
      builder: builder,
    );
  }
}

/// Widget used to listen to an [InjectedAnimation] and call its builder each
/// time the animation ticks.
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

class OnAnimationBuilder extends StatefulWidget {
  const OnAnimationBuilder({
    Key? key,
    required this.listenTo,
    required this.builder,
    this.onInitialized,
  }) : super(key: key);

  /// [InjectedAnimation] to listen to.
  final InjectedAnimation listenTo;

  /// The builder callback. It is invoked for each tick.
  /// It exposes an [Animate] object. The [Animate] object is used to set Tweens,
  /// explicitly or implicitly
  ///
  ///
  final Widget Function(Animate) builder;

  /// Callback fired after animation is set up.
  final void Function()? onInitialized;
  @override
  _OnAnimationBuilderState createState() => _OnAnimationBuilderState();
}

class _OnAnimationBuilderState extends State<OnAnimationBuilder>
    with SingleTickerProviderStateMixin {
  bool isInitialized = false;
  bool _isDirty = false;
  bool? _isChanged;
  bool _hasChanged = false;
  bool isSchedulerBinding = false;
  final _assertionList = [];

  late final _injected = widget.listenTo as InjectedAnimationImp;

  late VoidCallback disposer;

  final _evaluateAnimation = <String, _EvaluateAnimation>{};
  late final Animate animate;

  void triggerAnimation([bool restart = false]) {
    if (_isChanged == true) {
      _isChanged = false;
      if (_isDirty) {
        _injected.triggerAnimation(restart: true);
      }
    }
  }

  T? _animateTween<T>(
    dynamic Function(T? begin, bool isInitialized) fn,
    T? targetValue,
    Curve? curve,
    Curve? reverseCurve,
    String name,
    bool isTween,
  ) {
    assert(() {
      if (isInitialized && !_isDirty) return true;
      if (_assertionList.contains(name)) {
        if (_assertionList.isNotEmpty) {
          _assertionList.clear();
          throw ArgumentError('Duplication of <$T> with the same name is '
              'not allowed. Use distinct name. The name is: $name');
        }
      }
      _assertionList.add(name);
      return true;
    }());
    _EvaluateAnimation? evaluateAnimation = _evaluateAnimation[name];
    T? value;
    if (evaluateAnimation == null) {
      _evaluateAnimation[name] = evaluateAnimation = _EvaluateAnimation(
        onAnimation: this,
        curve: curve,
        reverseCurve: reverseCurve,
      );
    }
    value = evaluateAnimation.animate<T>(
      fn,
      targetValue,
      curve,
      reverseCurve,
      name,
      isTween,
    );
    if (!_injected.isAnimating) {
      triggerAnimation();
    }
    return value;
  }

  T? animateTween<T>(
    dynamic Function(T? begin) fn,
    Curve? curve,
    Curve? reserveCurve, [
    String name = '',
  ]) {
    name = 'Tween<$T>' + name + '_TwEeN_';

    // if (!isInit && _evaluateAnimation.containsKey(name)) {
    //   return getValue(name);
    // }
    return _animateTween(
      (begin, _) => fn(begin),
      null,
      curve,
      reserveCurve,
      name,
      true,
    );
  }

  T? animateValue<T>(
    T? value,
    Curve? curve,
    Curve? reserveCurve, [
    String name = '',
  ]) {
    name = '$T' + name;

    return _animateTween<T>(
      (begin, isInitialized) => _getTween(
        isInitialized ? begin : begin ?? value,
        value,
      ),
      value,
      curve,
      reserveCurve,
      name,
      false,
    );
  }

  void _didUpdateWidget() {
    assert(() {
      //Sometimes two succusef call of _didUpdateWidget (happen in hot restart)
      //while _isDirty is true. This my throw for value duplication.
      if (_isDirty) {
        _assertionList.clear();
      }
      return true;
    }());
    _isDirty = true;
    _evaluateAnimation.forEach((key, value) {
      value._isDirty = true;
    });
    _injected.didUpdateWidget();
  }

  late final VoidCallback disposeDidUpdateWidget;
  late final VoidCallback disposeAnimationReset;

  @override
  void initState() {
    super.initState();
    _injected.initializer(this);
    widget.onInitialized?.call();
    animate = Animate._(
      value: animateValue,
      fromTween: animateTween,
    );

    disposer = _injected.addObserver(
      isSideEffects: false,
      listener: (_) {
        if (_hasChanged || animate.shouldAlwaysRebuild) {
          try {
            assert(() {
              _assertionList.clear();
              return true;
            }());
            setState(() {});
          } catch (e) {
            if (e is! FlutterError) {
              rethrow;
            }
          }
        }
      },
      shouldAutoClean: true,
    );

    disposeDidUpdateWidget = _injected.addToDidUpdateWidgetListeners(
      () {
        _hasChanged = true;
        _didUpdateWidget();
      },
    );
    disposeAnimationReset = _injected.addToResetAnimationListeners(
      () {
        _evaluateAnimation.forEach((key, value) {
          value.forwardAnimation = null;
          value.backwardAnimation = null;
        });
      },
    );
  }

  void resetState() {
    isInitialized = false;
    _isDirty = false;
    _isChanged = null;
    _hasChanged = false;
    isSchedulerBinding = false;
    _assertionList.clear();
  }

  @override
  void dispose() {
    _injected.dispose();

    // resetState();
    disposer();
    disposeDidUpdateWidget();
    disposeAnimationReset();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OnAnimationBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _didUpdateWidget();
  }

  void didChangeDependencies() {
    _didUpdateWidget();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(animate);
  }
}
