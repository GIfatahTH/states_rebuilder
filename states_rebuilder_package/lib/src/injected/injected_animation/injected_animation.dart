import 'package:flutter/material.dart';
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

  ///Start animation
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
    this.curve = Curves.linear,
    this.repeats = 1,
    this.isReverse = false,
    this.onInitialized,
    this.endAnimationListener,
  }) : super(
          creator: () => 0.0,
        );

  final Duration duration;
  final Curve curve;
  final int repeats;
  final bool isReverse;
  final void Function(InjectedAnimation)? onInitialized;
  final void Function()? endAnimationListener;
  late Function(AnimationStatus) repeatStatusListenerListener;

  bool isAnimating = false;

  bool skipDismissStatus = false;
  int repeatCount = 0;

  void initialize(TickerProvider ticker) {
    if (_controller != null) {
      return;
    }
    _controller = AnimationController(
      duration: duration,
      vsync: ticker,
    );

    repeatStatusListenerListener = (status) {
      if (status == AnimationStatus.completed ||
          (status == AnimationStatus.dismissed &&
              isReverse &&
              !skipDismissStatus)) {
        if (repeatCount == 1) {
          isAnimating = false;
          endAnimationListener?.call();

          WidgetsBinding.instance!.scheduleFrameCallback((_) {
            notify(); //TODO Check me. Used to trigger a rebuild after animation ends
          });
        } else {
          if (status == AnimationStatus.completed) {
            if (repeatCount > 1) repeatCount--;
            if (isReverse) {
              _controller!.reverse();
            } else {
              _controller!
                ..value = 0
                ..forward();
            }
          } else if (status == AnimationStatus.dismissed) {
            if (repeatCount > 1) repeatCount--;
            _controller!.forward();
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
        WidgetsBinding.instance!.scheduleFrameCallback((_) {
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
    repeatCount = repeats;
    _controller!.forward();
  }

  void _resetControllerValue() {
    skipDismissStatus = true;
    _controller!.value = 0;
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
