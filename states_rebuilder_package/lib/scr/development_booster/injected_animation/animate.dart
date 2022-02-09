part of 'injected_animation.dart';

/// Object exposed by the builder method of the [OnAnimationBuilder]. It is used
/// to set tweens explicitly or implicitly.
///
///   ```dart
///      child: OnAnimationBuilder(
///        listenTo: animation,
///        builder: (animate) {
///          //Implicit animation
///          final width = animate(selected ? 200.0 : 100.0);
///
///          // Explicit animation
///          final height = animate.fromTween((_)=> Tween(200.0, 100.0));
///
///          return Container(
///            width: width,
///            height: height,
///            child: const FlutterLogo(size: 75),
///          );
///        },
///      ),
///    ```
class Animate {
  final T? Function<T>(
    T? value,
    Curve? curve,
    Curve? reserveCurve, [
    String name,
  ]) _value;
  Curve? _curve;
  Curve? _reserveCurve;

  bool shouldAlwaysRebuild = false;

  final T? Function<T>(
    Tween<T?> Function(T? currentValue) fn,
    Curve? curve,
    Curve? reserveCurve, [
    String name,
  ]) _fromTween;

  Animate._({
    required T? Function<T>(
      T? value,
      Curve? curve,
      Curve? reserveCurve, [
      String name,
    ])
        value,
    required T? Function<T>(
      Tween<T?> Function(T? currentValue) fn,
      Curve? curve,
      Curve? reserveCurve, [
      String name,
    ])
        fromTween,
  })  : _value = value,
        _fromTween = fromTween;

  ///Implicitly animate to the given value
  T? call<T>(T? value, [String name = '']) {
    final curve = _curve;
    final reserveCurve = _reserveCurve;
    _curve = null;
    _reserveCurve = null;
    return _value.call<T>(value, curve, reserveCurve, name);
  }

  /// Set animation explicitly by defining the Tween.
  ///
  /// The callback exposes the currentValue value
  T? fromTween<T>(Tween<T?> Function(T? currentValue) fn, [String? name]) {
    final curve = _curve;
    final reserveCurve = _reserveCurve;
    _curve = null;
    _reserveCurve = null;
    return _fromTween(fn, curve, reserveCurve, name ?? '');
  }

  /// Set the curve for this tween.
  ///
  /// Used for staggered animation.
  Animate setCurve(Curve curve) {
    _curve = curve;
    return this;
  }

  /// Set the curve for this tween.
  ///
  /// Used for staggered animation.
  Animate setReverseCurve(Curve curve) {
    _reserveCurve = curve;
    return this;
  }
}

class EvaluateAnimation {
  final _OnAnimationBuilderState onAnimation;
  final InjectedAnimationImp injected;
  dynamic tween;
  final Curve? curve;
  final Curve? reverseCurve;

  EvaluateAnimation({
    required this.onAnimation,
    required this.curve,
    required this.reverseCurve,
  }) : injected = onAnimation._injected;

  bool _isDirty = true;
  bool _isInitialized = false;

  dynamic currentValue;
  T? animate<T>(
    dynamic Function(T? begin, bool isInitialized) fn,
    T? targetValue,
    Curve? curve,
    Curve? reserveCurve,
    String name,
    bool isTween,
  ) {
    if (!_isDirty) {
      return currentValue = getValue(name);
    }
    _isDirty = false;
    onAnimation._hasChanged = true;
    if (!onAnimation.isSchedulerBinding) {
      onAnimation.isSchedulerBinding = true;

      SchedulerBinding.instance!.addPostFrameCallback(
        (_) {
          onAnimation
            ..isSchedulerBinding = false
            .._assertionList.clear()
            ..isInitialized = true
            .._isDirty = false;
        },
      );
    }

    if (tween != null && tween.end == targetValue) {
      //If the new target value equal to end value of the last tween,
      //just return the value;
      // print(injected.isAnimating);
      // print(currentValue);
      if (tween.begin != tween.end) {
        //Reset the tween to the target value
        tween = _getTween(
          targetValue,
          targetValue,
        );
        //set forwardAnimation and backwardAnimation to null to reset animation
        //to take into account the new tween
        forwardAnimation = null;
        backwardAnimation = null;
      }
      onAnimation._isChanged = false;
      return currentValue = getValue(name);
    }
    //Calculate the new tween

    var newTween = fn(currentValue, _isInitialized);
    if (newTween == null) {
      _isInitialized = true;
      onAnimation._hasChanged = false;
      return null;
    }
    if (!_isInitialized) {
      _isInitialized = true;
      tween = newTween;
      currentValue = getValue(name);
    } else if (tween?.begin != newTween.begin || tween?.end != newTween.end) {
      tween = newTween;
      forwardAnimation = null;
      backwardAnimation = null;
      if (tween.begin == tween.end) {
        return tween.begin;
      }
      onAnimation._isChanged = true;
    } else {
      onAnimation._hasChanged = isTween;
      currentValue = getValue(name);
    }

    return currentValue ??
        tween.lerp(
          injected.initialValue ?? injected.lowerBound,
        );
  }

  T? getValue<T>(String name) {
    try {
      if (tween == null) return null;
      final val = _evaluate();
      return val;
    } catch (e) {
      if (e is TypeError) {
        //For tween that accept null value but when evaluated throw a Null
        //is not subtype of T (where T is the type). [Tween.transform]
        return null;
      }
      rethrow;
    }
  }

  Animatable<dynamic>? forwardAnimation;
  Animatable<dynamic>? backwardAnimation;
  dynamic _evaluate() {
    if (injected.reverseCurve == null && reverseCurve == null) {
      forwardAnimation ??= tween.chain(
        CurveTween(curve: curve ?? injected.curve),
      );
      return forwardAnimation!.evaluate(injected.controller!);
    }
    if (injected.controller!.status == AnimationStatus.reverse) {
      backwardAnimation ??= tween.chain(
        CurveTween(curve: reverseCurve ?? injected.reverseCurve!),
      );
      return backwardAnimation!.evaluate(injected.controller!);
    }
    forwardAnimation ??= tween.chain(
      CurveTween(curve: curve ?? injected.curve),
    );
    return forwardAnimation!.evaluate(injected.controller!);
  }
}
