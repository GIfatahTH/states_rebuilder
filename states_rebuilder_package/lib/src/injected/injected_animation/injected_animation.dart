import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../rm.dart';

part 'on_Animation.dart';

class _RebuildAnimation {
  final InjectedAnimation _injected;
  _RebuildAnimation(this._injected);

  ///Listen to the [InjectedAnimation] and rebuild when animation ticks.
  Widget call(Widget Function() builder) {
    return On(builder).listenTo(_injected);
  }

  ///Listen to the [InjectedAnimation] and rebuild when animation ticks.
  ///
  ///The first positional argument is a callback that exposes and [Animate] object.
  ///
  ///The [Animate] object is used to set explicit or implicit animation tweens.
  Widget onAnimation(
    Widget Function(Animate) anim, {
    void Function()? onInitialized,
    Key? key,
  }) {
    return On.animation(anim).listenTo(
      _injected,
      onInitialized: onInitialized,
      key: key,
    );
  }
}

///Inject an animation
abstract class InjectedAnimation implements InjectedBaseState<double> {
  ///Listen to the [InjectedAnimation] and rebuild when animation ticks.
  ///
  ///See [_RebuildAnimation.onAnimation]
  late final rebuild = _RebuildAnimation(this);
  AnimationController? _controller;

  ///Get the `AnimationController` associated with this [InjectedAnimation]
  AnimationController? get controller => _controller;

  Animation<double>? _curvedAnimation;
  Animation<double>? _reverseCurvedAnimation;

  ///Get default animation with `Tween<double>(begin:0.0, end:1.0)` and with the defined curve,
  ///Used with Flutter's widgets that end with Transition (ex SlideTransition,
  ///RotationTransition)
  Animation<double> get curvedAnimation {
    assert(_controller != null);
    final hasReverseCurve = (this as InjectedAnimationImp).reverseCurve != null;
    if (!hasReverseCurve) {
      return _curvedAnimation ??= CurvedAnimation(
        parent: _controller!,
        curve: (this as InjectedAnimationImp).curve,
      );
    }
    return _reverseCurvedAnimation ??= CurvedAnimation(
      parent: _controller!,
      curve: _controller!.status == AnimationStatus.reverse
          ? (this as InjectedAnimationImp).reverseCurve!
          : (this as InjectedAnimationImp).curve,
    );
  }

  ///Start animation.
  ///
  ///If animation is completed (stopped at the upperBound) then the animation
  ///is reversed, and if the animation is dismissed (stopped at the lowerBound)
  ///then the animation is forwarded. IF animation is running nothing will happen.
  ///
  ///You can force animation to restart from the lowerBound by setting the
  ///[restart] parameter to true.
  ///
  ///You can start animation the conventional way using `controller!.forward`
  ///for example.
  ///
  ///It returns Future that resolves when the started animation ends.
  Future<void>? triggerAnimation({bool restart = false});

  ///Update `On.animation` widgets listening the this animation
  ///
  ///Has similar effect as when the widget rebuilds to invoke implicit animation
  ///
  ///It returns Future that resolves when the started animation ends.
  Future<double> refresh();

  ///Used to change any of the global parameters fo the animation such as
  ///duration, reverseDuration, curve, reverseCurve, repeats and
  ///shouldReverseRepeats.
  ///
  ///Change is taken instantaneously while the animation is playing
  void resetAnimation({
    Duration? duration,
    Duration? reverseDuration,
    Curve? curve,
    Curve? reverseCurve,
    int? repeats,
    bool? shouldReverseRepeats,
  });
}

///InjectedAnimation implementation
class InjectedAnimationImp extends InjectedBaseBaseImp<double>
    with InjectedAnimation {
  InjectedAnimationImp({
    Duration duration = const Duration(milliseconds: 500),
    Duration? reverseDuration,
    Curve curve = Curves.linear,
    Curve? reverseCurve,
    this.initialValue,
    this.upperBound = 1.0,
    this.lowerBound = 0.0,
    this.animationBehavior = AnimationBehavior.normal,
    int? repeats,
    bool shouldReverseRepeats = false,
    this.shouldAutoStart = false,
    this.onInitialized,
    this.endAnimationListener,
  }) : super(
          creator: () => 0.0,
        ) {
    _resetDefaultState = () {
      this.duration = duration;
      this.reverseDuration = reverseDuration;
      this.curve = curve;
      this.reverseCurve = reverseCurve;
      this.repeats = repeats;
      this.shouldReverseRepeats = shouldReverseRepeats;
      animationEndFuture = null;
      isAnimating = false;
      skipDismissStatus = false;
      repeatCount = null;
      _didUpdateWidgetListeners.clear();
      _resetAnimationListeners.clear();
      _controller = null;
      //
      _curvedAnimation = null;
      _reverseCurvedAnimation = null;
    };
    _resetDefaultState();
  }

  ///The AnimationController's value the animation start with.
  final double? initialValue;

  /// The value at which this animation is deemed to be dismissed.
  final double lowerBound;

  /// The value at which this animation is deemed to be completed.
  final double upperBound;

  /// The behavior of the controller when [AccessibilityFeatures.disableAnimations]
  /// is true.
  ///
  /// Defaults to [AnimationBehavior.normal].
  final AnimationBehavior animationBehavior;
  final bool shouldAutoStart;
  final void Function(InjectedAnimation)? onInitialized;
  final void Function()? endAnimationListener;

  /// The length of time this animation should last.
  ///
  /// If [reverseDuration] is specified, then [duration] is only used when going
  /// [forward]. Otherwise, it specifies the duration going in both directions.
  late Duration duration;

  /// The length of time this animation should last when going in [reverse].
  ///
  /// The value of [duration] is used if [reverseDuration] is not specified or
  /// set to null.
  Duration? reverseDuration;

  /// The default curve of the animation.
  ///
  /// If [reverseCurve] is specified, then [curve] is only used when going
  /// [forward]. Otherwise, it specifies the curve going in both directions.
  late Curve curve;

  /// The curve of the animation when going in [reverse].
  ///
  /// The value of [curve] is used if [reverseCurve] is not specified or
  /// set to null.
  late Curve? reverseCurve;

  ///Number of times the animation should repeat. If 0 animation will repeat
  ///indefinitely
  late int? repeats;
  late bool shouldReverseRepeats;
  late Completer<void>? animationEndFuture;
  late bool isAnimating;
  late bool skipDismissStatus;
  late int? repeatCount;
  final List<VoidCallback> _didUpdateWidgetListeners = [];
  final List<VoidCallback> _resetAnimationListeners = [];
  //
  late final VoidCallback _resetDefaultState;
  //
  late Function(AnimationStatus) repeatStatusListenerListener;

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
        _reverseCurvedAnimation = null;
        return;
      }
      // if (repeats == null) {
      //   isAnimating = false;
      //   endAnimationListener?.call();
      //   return;
      // }
      if (skipDismissStatus) {
        return;
      }
      repeatCount ??= repeats ?? 1;

      if (repeatCount == 1) {
        isAnimating = false;
        if (animationEndFuture?.isCompleted == false) {
          animationEndFuture!.complete();
          animationEndFuture = null;
        }
        endAnimationListener?.call();
        repeatCount = null;
        WidgetsBinding.instance!.scheduleFrameCallback((_) {
          notify(); //TODO Check me. Used to trigger a rebuild after animation ends
        });
      } else {
        if (status == AnimationStatus.completed) {
          if (repeatCount! > 1) repeatCount = repeatCount! - 1;
          if (shouldReverseRepeats) {
            _controller!.reverse();
          } else {
            skipDismissStatus = true;
            _controller!.value = lowerBound;
            skipDismissStatus = false;
            _controller!.forward();
          }
        } else if (status == AnimationStatus.dismissed) {
          if (repeatCount! > 1) repeatCount = repeatCount! - 1;
          if (shouldReverseRepeats) {
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
    if (shouldAutoStart) {
      triggerAnimation();
    }
  }

  @override
  Future<void>? triggerAnimation({bool restart = false}) {
    if (restart) {
      animationEndFuture ??= Completer();
      repeatCount = null;
      _startAnimation(true);
      return animationEndFuture?.future;
    }
    if (!isAnimating) {
      animationEndFuture ??= Completer();
      _startAnimation(!shouldReverseRepeats);
    }
    return animationEndFuture?.future;
  }

  void _startAnimation(bool rest) {
    if (rest) {
      _resetControllerValue();
    } else if (repeatCount != null) {
      return;
    }

    isAnimating = true;
    if (_controller?.status == AnimationStatus.completed) {
      _controller!.reverse();
    } else {
      _controller!.forward();
    }
    repeatCount ??= repeats ?? 1;
  }

  void _resetControllerValue() {
    skipDismissStatus = true;
    _controller!.value = initialValue ?? lowerBound;
    skipDismissStatus = false;
  }

  void didUpdateWidget() {
    if (isAnimating) {
      isAnimating = false;
    }
  }

  VoidCallback addToDidUpdateWidgetListeners(VoidCallback fn) {
    _didUpdateWidgetListeners.add(fn);
    return () => _didUpdateWidgetListeners.remove(fn);
  }

  VoidCallback addToResetAnimationListeners(VoidCallback fn) {
    _resetAnimationListeners.add(fn);
    return () => _resetAnimationListeners.remove(fn);
  }

  ///Update `On.animation` widgets listening the this animation
  ///
  ///Has similar effect as when the widget rebuilds to invoke implicit animation
  @override
  Future<double> refresh() async {
    animationEndFuture ??= Completer();
    _didUpdateWidgetListeners.forEach((fn) => fn());
    notify();
    await animationEndFuture?.future;
    return 0.0;
  }

  void resetAnimation({
    Duration? duration,
    Duration? reverseDuration,
    Curve? curve,
    Curve? reverseCurve,
    int? repeats,
    bool? shouldReverseRepeats,
  }) {
    if (duration != null) {
      _controller?.duration = duration;
    }
    if (reverseDuration != null) {
      _controller?.reverseDuration = reverseDuration;
    }
    if (repeats != null) {
      this.repeats = repeats;
      repeatCount = null;
    }
    if (shouldReverseRepeats != null) {
      this.shouldReverseRepeats = shouldReverseRepeats;
      repeatCount = null;
    }
    bool isCurveChanged = false;
    if (curve != null) {
      this.curve = curve;
      isCurveChanged = true;
    }
    if (reverseCurve != null) {
      this.reverseCurve = reverseCurve;
      isCurveChanged = true;
    }
    if (isCurveChanged) {
      _resetAnimationListeners.forEach((fn) => fn());
      _curvedAnimation = null;
      _reverseCurvedAnimation = null;
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    _resetDefaultState();
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
