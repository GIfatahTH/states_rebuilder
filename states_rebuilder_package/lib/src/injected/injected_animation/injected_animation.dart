import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../rm.dart';

part 'on_Animation.dart';

///Inject an animation
abstract class InjectedAnimation implements Injected<double> {
  AnimationController? _controller;

  ///Get the `AnimationController` associated with this [InjectedAnimation]
  AnimationController? get controller => _controller;
  Animation<double>? _curvedAnimation;

  ///Get default animation with `Tween<double>(begin:0.0, end:1.0)` and with the defined curve,
  ///Used with Flutter's widgets that end with Transition (ex SlideTransition,
  ///RotationTransition)
  Animation<double> get curvedAnimation {
    assert(_controller != null);
    return _curvedAnimation ??= CurvedAnimation(
      parent: _controller!,
      curve: (this as InjectedAnimationImp).curve,
    );
  }

  ///Start animation.
  ///
  ///If animation is completed (stopped at the end) then the animation is reversed, and if the animation
  ///is dismissed (stopped at the beginning) then the animation is forwarded.
  ///
  ///You can start animation conventionally using `controller!.forward` for example.
  void triggerAnimation();

  ///Update `On.animation` widgets listening the this animation
  ///
  ///Has similar effect as when the widget rebuilds to invoke implicit animation
  @override
  Future<double> refresh();
}

///InjectedAnimation implementation
class InjectedAnimationImp extends ReactiveModel<double>
    with InjectedAnimation {
  InjectedAnimationImp({
    this.duration = const Duration(milliseconds: 500),
    this.reverseDuration,
    this.curve = Curves.linear,
    this.initialValue,
    this.upperBound = 1.0,
    this.lowerBound = 0.0,
    this.animationBehavior = AnimationBehavior.normal,
    this.repeats,
    this.isReverse = false,
    this.onInitialized,
    this.endAnimationListener,
  }) : super(
          creator: () => 0.0,
        );

  ///The AnimationController's value the animation start with.
  final double? initialValue;

  /// The length of time this animation should last.
  ///
  /// If [reverseDuration] is specified, then [duration] is only used when going
  /// [forward]. Otherwise, it specifies the duration going in both directions.
  Duration duration;

  /// The length of time this animation should last when going in [reverse].
  ///
  /// The value of [duration] us used if [reverseDuration] is not specified or
  /// set to null.
  Duration? reverseDuration;
  final Curve curve;

  /// The value at which this animation is deemed to be dismissed.
  final double lowerBound;

  /// The value at which this animation is deemed to be completed.
  final double upperBound;

  /// The behavior of the controller when [AccessibilityFeatures.disableAnimations]
  /// is true.
  ///
  /// Defaults to [AnimationBehavior.normal].
  final AnimationBehavior animationBehavior;

  ///Number of times the animation should repeat. If 0 animation will repeat
  ///indefinitely
  final int? repeats;

  final bool isReverse;
  final void Function(InjectedAnimation)? onInitialized;
  final void Function()? endAnimationListener;
  late Function(AnimationStatus) repeatStatusListenerListener;

  bool isAnimating = false;

  bool skipDismissStatus = false;
  int? repeatCount;

  void initialize(TickerProvider ticker) {
    if (_controller != null) {
      return;
    }
    _controller = AnimationController(
      vsync: ticker,
      duration: duration,
      reverseDuration: reverseDuration,
      value: initialValue,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: animationBehavior,
    );

    repeatStatusListenerListener = (status) {
      if (status != AnimationStatus.completed &&
          status != AnimationStatus.dismissed) {
        return;
      }
      if (repeats == null) {
        endAnimationListener?.call();
        return;
      }
      if (skipDismissStatus) {
        return;
      }
      repeatCount ??= repeats;

      if (repeatCount == 1) {
        isAnimating = false;
        endAnimationListener?.call();
        repeatCount = null;
        WidgetsBinding.instance!.scheduleFrameCallback((_) {
          notify(); //TODO Check me. Used to trigger a rebuild after animation ends
        });
      } else {
        if (status == AnimationStatus.completed) {
          if (repeatCount! > 1) repeatCount = repeatCount! - 1;
          if (isReverse) {
            _controller!.reverse();
          } else {
            skipDismissStatus = true;
            _controller!.value = lowerBound;
            skipDismissStatus = false;
            _controller!.forward();
          }
        } else if (status == AnimationStatus.dismissed) {
          if (repeatCount! > 1) repeatCount = repeatCount! - 1;
          if (isReverse) {
            _controller!.forward();
          } else {
            skipDismissStatus = true;
            _controller!.value = upperBound;
            skipDismissStatus = false;
            _controller!.reverse();
          }
        }
      }
    };

    _controller!
      ..addListener(() {
        snapState = snapState.copyToHasData(_controller!.value);
        notify();
      })
      ..addStatusListener(repeatStatusListenerListener);
    onInitialized?.call(this);
  }

  bool _isFrameScheduling = false;
  @override
  void triggerAnimation() {
    if (!isAnimating && !_isFrameScheduling) {
      isAnimating = true;
      if (observerLength <= 1) {
        _startAnimation();
      } else {
        //If there are more than one On.animation listener, postpone the reset of
        //animation until the next frame so that all implicit values are calculated
        //correctly.
        _isFrameScheduling = true;
        SchedulerBinding.instance!.scheduleFrameCallback((_) {
          if (_controller != null) {
            _startAnimation();
            _isFrameScheduling = false;
          }
        });
      }
    }
  }

  void _startAnimation() {
    _resetControllerValue();
    if (_controller?.status == AnimationStatus.completed) {
      _controller!.reverse();
    } else {
      _controller!.forward();
    }
  }

  void _resetControllerValue() {
    skipDismissStatus = true;
    _controller!.value = initialValue ?? lowerBound;
    skipDismissStatus = false;
  }

  void didUpdateWidget() {
    if (_controller?.duration != duration) {
      _controller?.duration = duration;
    }
    if (isAnimating && !_isFrameScheduling) {
      isAnimating = false;
    }
  }

  final List<VoidCallback> _didUpdateWidgetListeners = [];
  VoidCallback addToDidUpdateWidgetListeners(VoidCallback fn) {
    _didUpdateWidgetListeners.add(fn);
    return () => _didUpdateWidgetListeners.remove(fn);
  }

  ///Update `On.animation` widgets listening the this animation
  ///
  ///Has similar effect as when the widget rebuilds to invoke implicit animation
  @override
  Future<double> refresh() async {
    _didUpdateWidgetListeners.forEach((fn) => fn());
    notify();
    return 0.0;
  }

  @override
  void dispose() {
    _controller!.dispose();
    _controller = null;
    _curvedAnimation = null;
    isAnimating = false;
    _isFrameScheduling = false;
    _didUpdateWidgetListeners.clear();
    super.dispose();
  }
}

Tween<dynamic>? _getTween<T>(T? begin, T? end) {
  final val = begin ?? end;
  if (val == null) {
    return null;
  }
  if (val is double?) {
    return Tween(
      begin: begin as double?,
      end: end as double?,
    );
  }

  if (val is Color?) {
    return ColorTween(
      begin: begin as Color?,
      end: end as Color?,
    );
  }
  if (val is Offset?) {
    return Tween<Offset>(
      begin: begin as Offset?,
      end: end as Offset?,
    );
  }
  if (val is Size) {
    return SizeTween(
      begin: begin as Size?,
      end: end as Size?,
    );
  }

  if (val is AlignmentGeometry?) {
    return AlignmentGeometryTween(
      begin: begin as AlignmentGeometry?,
      end: end as AlignmentGeometry?,
    );
  }

  if (val is EdgeInsetsGeometry?) {
    return EdgeInsetsGeometryTween(
      begin: begin as EdgeInsetsGeometry?,
      end: end as EdgeInsetsGeometry?,
    );
  }

  if (val is Decoration?) {
    return DecorationTween(
      begin: begin as Decoration?,
      end: end as Decoration?,
    );
  }

  if (val is BoxConstraints?) {
    return BoxConstraintsTween(
      begin: begin as BoxConstraints?,
      end: end as BoxConstraints?,
    );
  }

  if (val is TextStyle?) {
    return TextStyleTween(
      begin: begin as TextStyle?,
      end: end as TextStyle?,
    );
  }

  if (val is Rect) {
    return RectTween(
      begin: begin as Rect?,
      end: end as Rect?,
    );
  }

  if (val is RelativeRect) {
    return RelativeRectTween(
      begin: begin as RelativeRect?,
      end: end as RelativeRect?,
    );
  }

  if (val is int) {
    return IntTween(
      begin: begin as int?,
      end: end as int?,
    );
  }

  if (val is BorderRadius?) {
    return BorderRadiusTween(
      begin: begin as BorderRadius?,
      end: end as BorderRadius?,
    );
  }

  if (val is ThemeData?) {
    return ThemeDataTween(
      begin: begin as ThemeData?,
      end: end as ThemeData?,
    );
  }

  if (val is Matrix4?) {
    return Matrix4Tween(
      begin: begin as Matrix4?,
      end: end as Matrix4?,
    );
  }

  throw UnimplementedError('The $T property has no built-in tween. '
      'Please use [Animate.fromTween] and define your tween');
}

class Animate {
  final T? Function<T>(T? value, [String name]) _value;

  ///Set animation explicitly by defining the Tween.
  ///
  ///The callback exposes the currentValue value
  final T? Function<T>(Tween<T?> Function(T? currentValue) fn, [String name])
      formTween;

  Animate._({
    required T? Function<T>(T? value, [String name]) value,
    required this.formTween,
  }) : _value = value;

  ///Implicitly animate to the given value
  T? call<T>(T? value, [String name = '']) => _value.call<T>(value, name);
}
