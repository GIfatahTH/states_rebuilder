import 'package:flutter/material.dart';
import '../../rm.dart';

part 'on_Animation.dart';

abstract class InjectedAnimation implements Injected<double> {}

class InjectedAnimationImp extends ReactiveModel<double>
    with InjectedAnimation {
  InjectedAnimationImp({
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.linear,
    this.repeats,
    this.cycles,
    this.endAnimationListener,
  }) : super(
          creator: () => 0.0,
        );

  final Duration duration;
  final Curve curve;
  final int? repeats;
  final int? cycles;
  final void Function()? endAnimationListener;
  AnimationController? controller;
  late Function(AnimationStatus) repeatStatusListenerListener;

  bool isAnimating = false;
  // bool? _isChanged;
  // bool _isDirty = false;
  // bool isInit = true;
  // final _tweens = <String, Tween<dynamic>>{};
  // final _curvedTweens = <String, Animatable<dynamic>>{};
  // final assertionList = [];
  bool isCycle = false;
  bool skipDismissStatus = false;
  int repeatCount = 0;
  // late final Animate animate;
  void initialize(TickerProvider ticker) {
    if (controller != null) {
      return;
    }
    controller = AnimationController(
      duration: duration,
      vsync: ticker,
    );

    repeatStatusListenerListener = (status) {
      if (status == AnimationStatus.completed ||
          (status == AnimationStatus.dismissed &&
              isCycle &&
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
            if (isCycle) {
              controller!.reverse();
            } else {
              controller!
                ..value = 0
                ..forward();
            }
          } else if (status == AnimationStatus.dismissed) {
            if (repeatCount > 1) repeatCount--;

            controller!.forward();
          }
        }
      }
    };

    controller!
      ..addListener(() {
        snapState = snapState.copyToHasData(controller!.value);
        notify();
      })
      ..addStatusListener(repeatStatusListenerListener);

    // animate = Animate._(
    //   value: animateValue,
    //   formTween: animateTween,
    // ).._controller = CurvedAnimation(parent: controller!, curve: curve);
  }

  // T? getValue<T>(String name) {
  //   try {
  //     final val = _curvedTweens[name]?.evaluate(controller!);
  //     return val;
  //   } catch (e) {
  //     if (e is TypeError) {
  //       //For tween that accept null value but when evaluated throw a Null
  //       //is not subtype of T (where T is the type). [Tween.transform]
  //       return null;
  //     }
  //     rethrow;
  //   }
  // }

  // T? _animateTween<T>(dynamic Function(T? begin) fn, String name) {
  //   T? currentValue = getValue(name);
  //   if (isAnimating && currentValue != null) {
  //     return currentValue;
  //   }
  //   assert(() {
  //     if (assertionList.contains(name)) {
  //       assertionList.clear();
  //       throw ArgumentError('Duplication of <$T> with the same name is '
  //           'not allowed. Use distinct name');
  //     }
  //     assertionList.add(name);

  //     return true;
  //   }());

  //   final cachedTween = _tweens[name];
  //   final tween = fn(currentValue);
  //   if (tween == null) {
  //     return null;
  //   }

  //   if (isInit) {
  //     currentValue = tween.begin;
  //     _curvedTweens[name] = tween.chain(CurveTween(curve: curve));
  //     _tweens[name] = tween;
  //     if (tween.begin == tween.end) {
  //       return tween.begin;
  //     }
  //     _isChanged = true;
  //     _isDirty = true;
  //   } else if ((cachedTween?.end != tween.end ||
  //           cachedTween?.begin != tween.begin) &&
  //       _isDirty) {
  //     _curvedTweens[name] = tween.chain(CurveTween(curve: curve));
  //     _tweens[name] = tween;
  //     _isChanged = true;
  //   }

  //   if (tween.begin == tween.end) {
  //     return tween.begin;
  //   }
  //   //At this point controller.value == 0 or 1
  //   // assert(controller!.value == 0.0 || controller!.value == 1.0);
  //   return currentValue ?? tween.lerp(0.0);
  // }

  // T? animateValue<T>(T? value, [String name = '']) {
  //   name = '$T' + name;

  //   return animateTween<T>(
  //     (begin) => _getTween(isInit ? value : begin, value),
  //     name,
  //   );
  // }

  // T? animateTween<T>(dynamic Function(T? begin) fn, [String name = '']) {
  //   name = 'Tween<$T>' + name + '_TwEeN_';
  //   return _animateTween(fn, name);
  // }

  int _setRepeatCount(int? repeats, int? cycles) {
    return repeats == null ? cycles ?? 1 : repeats;
  }

  void triggerAnimation() {
    if (!isAnimating) {
      // _isChanged = false;
      // _isDirty = false;
      isAnimating = true;
      skipDismissStatus = true;
      controller!.value = 0;
      skipDismissStatus = false;
      repeatCount = _setRepeatCount(repeats, cycles);
      isCycle = repeats == null && cycles != null;
      controller!.forward();
    }
  }

  void didUpdateWidget() {
    if (controller!.duration != duration) {
      controller!.duration = duration;
    }
    // animate._controller = CurvedAnimation(
    //   parent: controller!,
    //   curve: curve,
    // );
    // if (isAnimating) {
    //   isAnimating = false;
    // }
    // _isDirty = true;
  }

  @override
  void dispose() {
    controller!.dispose();
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
  final T? Function<T>(Tween<T?> Function(T? currentValue) fn, [String name])
      formTween;

  Animate._({
    required T? Function<T>(T? value, [String name]) value,
    required this.formTween,
  }) : _value = value;

  T? call<T>(T? value, [String name = '']) => _value.call<T>(value, name);
  late Animation<double> _controller;
  Animation<double> get curvedController => _controller;
}
