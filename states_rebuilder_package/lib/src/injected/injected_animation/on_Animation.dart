part of 'injected_animation.dart';

class OnAnimation {
  final Widget Function(Animate animate) anim;
  OnAnimation(this.anim);
  late InjectedAnimationImp _injected;
  bool? _isChanged;
  bool _hasChanged = false;
  bool isSchedulerBinding = false;
  final assertionList = [];

  ///Listen to the [InjectedAnimation]
  Widget listenTo(
    InjectedAnimation inj, {
    void Function()? onInitialized,
    Key? key,
  }) {
    _injected = inj as InjectedAnimationImp;

    return StateBuilderBaseWithTicker<_OnAnimationWidget>(
      (widget, setState, ticker) {
        late VoidCallback disposer;

        bool _isDirty = false;
        bool isInit = true;

        final _tweens = <String, Tween<dynamic>>{};
        final _curvedTweens = <String, EvaluateAnimation>{};
        late final Animate animate;

        void triggerAnimation() {
          if (_isDirty && _isChanged == true) {
            _isChanged = false;
            _injected.triggerAnimation();
          }
        }

        // T? getValue<T>(String name) {
        //   try {
        //     final val = _curvedTweens[name]?.evaluate();
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

        T? _animateTween<T>(
          dynamic Function(T? begin, bool isInitialized) fn,
          T? targetValue,
          Curve? curve,
          Curve? reverseCurve,
          String name,
          bool isTween,
        ) {
          EvaluateAnimation? evaluateAnimation = _curvedTweens[name];
          T? value;
          if (evaluateAnimation == null) {
            _curvedTweens[name] = evaluateAnimation = EvaluateAnimation(
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
          );
          if (!_injected.isAnimating) {
            triggerAnimation();
          }
          return value;
          // if (!_isDirty && !isInit) {
          //   return currentValue;
          // }
          // if (!isSchedulerBinding) {
          //   isSchedulerBinding = true;
          //   SchedulerBinding.instance!.addPostFrameCallback(
          //     (_) {
          //       isSchedulerBinding = false;
          //       assertionList.clear();
          //       if (!isInit && _injected._controller != null) {
          //         triggerAnimation();
          //       }
          //       isInit = false;
          //       _isDirty = false;
          //     },
          //   );
          // }

          // assert(() {
          //   if (assertionList.contains(name)) {
          //     assertionList.clear();
          //     throw ArgumentError('Duplication of <$T> with the same name is '
          //         'not allowed. Use distinct name');
          //   }
          //   assertionList.add(name);

          //   return true;
          // }());
          // _hasChanged = isTween;
          // final cachedTween = _tweens[name];
          // var tween;
          // if (cachedTween != null && cachedTween.end == targetValue) {
          //   _hasChanged = true;
          //   return currentValue;
          // } else {
          //   tween = fn(currentValue);
          // }
          // if (tween == null) {
          //   return null;
          // }

          // if (isInit) {
          //   // if (currentValue != null) {
          //   //   return currentValue;
          //   // }
          //   _curvedTweens[name] = EvaluateAnimation(
          //     injected: _injected,
          //     tween: tween,
          //     curve: curve,
          //     reverseCurve: reserveCurve,
          //   );

          //   _tweens[name] = tween;
          //   currentValue = getValue(name);
          //   if (tween.begin == tween.end) {
          //     return tween.begin;
          //   }
          //   _hasChanged = true;

          //   // _isChanged = true;
          //   // _isDirty = true;
          // } else if ((cachedTween?.end != tween.end ||
          //         cachedTween?.begin != tween.begin) &&
          //     _isDirty) {
          //   _curvedTweens[name] = EvaluateAnimation(
          //     injected: _injected,
          //     tween: tween,
          //     curve: curve,
          //     reverseCurve: reserveCurve,
          //   );

          //   _tweens[name] = tween;
          //   _isChanged = true;
          //   _hasChanged = true;
          // }
          // if (tween.begin == tween.end) {
          //   return tween.begin;
          // }
          // //At this point controller.value == 0 or 1
          // // assert(controller!.value == 0.0 || controller!.value == 1.0);
          // return currentValue ??
          //     tween.lerp(_injected.initialValue ?? _injected.lowerBound);
        }

        T? animateTween<T>(
          dynamic Function(T? begin) fn,
          Curve? curve,
          Curve? reserveCurve, [
          String name = '',
        ]) {
          name = 'Tween<$T>' + name + '_TwEeN_';

          // if (!isInit && _curvedTweens.containsKey(name)) {
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
            (begin, isInitialized) =>
                _getTween(isInitialized ? value : begin, value),
            value,
            curve,
            reserveCurve,
            name,
            false,
          );
        }

        void _didUpdateWidget() {
          _isDirty = true;
          _curvedTweens.forEach((key, value) {
            value._isDirty = true;
          });
          _injected.didUpdateWidget();
        }

        final disposeDidUpdateWidget = _injected.addToDidUpdateWidgetListeners(
          () {
            _hasChanged = true;
            _didUpdateWidget();
          },
        );
        final disposeAnimationReset = _injected.addToResetAnimationListeners(
          () {
            _injected.shouldResetCurvedAnimation = true;
          },
        );

        return LifeCycleHooks(
          mountedState: (_) {
            if (ticker != null) {
              _injected.initialize(ticker);
            }
            onInitialized?.call();
            animate = Animate._(
              value: animateValue,
              fromTween: animateTween,
            );
            disposer = _injected.reactiveModelState.listeners
                .addListenerForRebuild((_) {
              if (_hasChanged || animate.shouldAlwaysRebuild) {
                setState();
              }
            });
          },
          dispose: (_) {
            if (ticker != null) {
              _injected.dispose();
            }
            disposer();
            disposeDidUpdateWidget();
            disposeAnimationReset();
          },
          didUpdateWidget: (_, __, ___) {
            _didUpdateWidget();
          },
          builder: (_, widget) {
            return widget.animate(animate);
          },
        );
      },
      widget: _OnAnimationWidget(anim),
      injected: _injected,
      key: key,
    );
  }
}

class _OnAnimationWidget {
  final Widget Function(Animate animate) animate;
  _OnAnimationWidget(this.animate);
}

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
  Animate setCurve(Curve curve) {
    _curve = curve;
    return this;
  }

  Animate setReverseCurve(Curve curve) {
    _reserveCurve = curve;
    return this;
  }

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
  })   : _value = value,
        _fromTween = fromTween;

  ///Implicitly animate to the given value
  T? call<T>(T? value, [String name = '']) {
    final curve = _curve;
    final reserveCurve = _reserveCurve;
    _curve = null;
    _reserveCurve = null;
    return _value.call<T>(value, curve, reserveCurve, name);
  }

  ///Set animation explicitly by defining the Tween.
  ///
  ///The callback exposes the currentValue value
  T? fromTween<T>(Tween<T?> Function(T? currentValue) fn, [String? name]) {
    final curve = _curve;
    final reserveCurve = _reserveCurve;
    _curve = null;
    _reserveCurve = null;
    return _fromTween(fn, curve, reserveCurve, name ?? '');
  }
}

class EvaluateAnimation {
  final OnAnimation onAnimation;
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

  T? animate<T>(
    dynamic Function(T? begin, bool isInitialized) fn,
    T? targetValue,
    Curve? curve,
    Curve? reserveCurve,
    String name,
    // bool isTween,
  ) {
    T? currentValue = getValue(name);
    if (!_isDirty) {
      return currentValue;
    }
    _isDirty = false;
    if (!onAnimation.isSchedulerBinding) {
      onAnimation.isSchedulerBinding = true;
      SchedulerBinding.instance!.addPostFrameCallback(
        (_) {
          onAnimation.isSchedulerBinding = false;
          onAnimation.assertionList.clear();
          // if (!isInit && _injected._controller != null) {
          //   triggerAnimation();
          // }
          // isInit = false;
          // _isDirty = false;
        },
      );
    }

    assert(() {
      if (onAnimation.assertionList.contains(name)) {
        onAnimation.assertionList.clear();
        throw ArgumentError('Duplication of <$T> with the same name is '
            'not allowed. Use distinct name');
      }
      onAnimation.assertionList.add(name);

      return true;
    }());

    if (tween != null && tween.end == targetValue) {
      onAnimation._hasChanged = true;
      return currentValue;
    }
    // _hasChanged = isTween;

    var newTween = fn(currentValue, _isInitialized);
    if (newTween == null) {
      return null;
    }
    if (!_isInitialized) {
      _isInitialized = true;
      tween = newTween;
      if (tween.begin == tween.end) {
        return tween.begin;
      }
      currentValue = getValue(name);
      onAnimation._hasChanged = true;
    } else if (tween != newTween) {
      // _curvedTweens[name] = EvaluateAnimation(
      //   injected: inj,
      //   tween: tween,
      //   curve: curve,
      //   reverseCurve: reserveCurve,
      // );
      tween = newTween;
      if (tween.begin == tween.end) {
        return tween.begin;
      }
      onAnimation._isChanged = true;
      onAnimation._hasChanged = true;
    }

    //At this point controller.value == 0 or 1
    // assert(controller!.value == 0.0 || controller!.value == 1.0);
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
    if (injected.shouldResetCurvedAnimation) {
      injected.shouldResetCurvedAnimation = false;
      forwardAnimation = null;
      backwardAnimation = null;
    }
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

/*
 T? _animateTween<T>(
          dynamic Function(T? begin) fn,
          T? targetValue,
          Curve? curve,
          Curve? reserveCurve,
          String name,
          bool isTween,
        ) {
          T? currentValue = getValue(name);
          if (inj.isAnimating && currentValue != null) {
            _hasChanged = true;
            return currentValue;
          }
          if (!_isDirty && !isInit) {
            return currentValue;
          }
          if (!isSchedulerBinding) {
            isSchedulerBinding = true;
            SchedulerBinding.instance!.addPostFrameCallback(
              (_) {
                isSchedulerBinding = false;
                assertionList.clear();
                if (!isInit && inj._controller != null) {
                  triggerAnimation();
                }
                isInit = false;
                _isDirty = false;
              },
            );
          }

          assert(() {
            if (assertionList.contains(name)) {
              assertionList.clear();
              throw ArgumentError('Duplication of <$T> with the same name is '
                  'not allowed. Use distinct name');
            }
            assertionList.add(name);

            return true;
          }());
          _hasChanged = isTween;
          final cachedTween = _tweens[name];
          var tween;
          if (cachedTween != null && cachedTween.end == targetValue) {
            _hasChanged = true;
            return currentValue;
          } else {
            tween = fn(currentValue);
          }
          if (tween == null) {
            return null;
          }

          if (isInit) {
            // if (currentValue != null) {
            //   return currentValue;
            // }
            _curvedTweens[name] = EvaluateAnimation(
              injected: inj,
              tween: tween,
              curve: curve,
              reverseCurve: reserveCurve,
            );

            _tweens[name] = tween;
            currentValue = getValue(name);
            if (tween.begin == tween.end) {
              return tween.begin;
            }
            _hasChanged = true;

            // _isChanged = true;
            // _isDirty = true;
          } else if ((cachedTween?.end != tween.end ||
                  cachedTween?.begin != tween.begin) &&
              _isDirty) {
            _curvedTweens[name] = EvaluateAnimation(
              injected: inj,
              tween: tween,
              curve: curve,
              reverseCurve: reserveCurve,
            );

            _tweens[name] = tween;
            _isChanged = true;
            _hasChanged = true;
          }
          if (tween.begin == tween.end) {
            return tween.begin;
          }
          //At this point controller.value == 0 or 1
          // assert(controller!.value == 0.0 || controller!.value == 1.0);
          return currentValue ?? tween.lerp(inj.initialValue ?? inj.lowerBound);
        }
    */
