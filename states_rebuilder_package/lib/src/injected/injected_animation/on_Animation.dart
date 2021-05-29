part of 'injected_animation.dart';

class OnAnimation {
  final Widget Function(Animate animate) anim;
  OnAnimation(this.anim);

  ///Listen to the [InjectedAnimation]
  Widget listenTo(
    InjectedAnimation injected, {
    void Function()? onInitialized,
    Key? key,
  }) {
    return StateBuilderBaseWithTicker<_OnAnimationWidget>(
      (widget, setState, ticker) {
        final inj = injected as InjectedAnimationImp;
        late VoidCallback disposer;
        bool? _isChanged;
        bool _hasChanged = false;
        bool _isDirty = false;
        bool isInit = true;
        bool isSchedulerBinding = false;

        final _tweens = <String, Tween<dynamic>>{};
        final _curvedTweens = <String, EvaluateAnimation>{};
        final assertionList = [];
        late final Animate animate;

        void triggerAnimation() {
          if (_isDirty && _isChanged == true) {
            _isChanged = false;
            injected.triggerAnimation();
          }
        }

        T? getValue<T>(String name) {
          try {
            final val = _curvedTweens[name]?.evaluate();
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
            fn,
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
            (begin) => _getTween(isInit ? value : begin, value),
            value,
            curve,
            reserveCurve,
            name,
            false,
          );
        }

        void _didUpdateWidget() {
          _isDirty = true;
          inj.didUpdateWidget();
        }

        final disposeDidUpdateWidget = inj.addToDidUpdateWidgetListeners(
          () {
            _hasChanged = true;
            _didUpdateWidget();
          },
        );
        final disposeAnimationReset = inj.addToResetAnimationListeners(
          () {
            inj.shouldResetCurvedAnimation = true;
          },
        );

        return LifeCycleHooks(
          mountedState: (_) {
            if (ticker != null) {
              inj.initialize(ticker);
            }
            onInitialized?.call();
            animate = Animate._(
              value: animateValue,
              fromTween: animateTween,
            );
            disposer = injected.reactiveModelState.listeners
                .addListenerForRebuild((_) {
              if (_hasChanged || animate.shouldAlwaysRebuild) {
                setState();
              }
            });
          },
          dispose: (_) {
            if (ticker != null) {
              inj.dispose();
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
      injected: injected,
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
  final InjectedAnimationImp injected;
  final dynamic tween;
  final Curve? curve;
  final Curve? reverseCurve;

  EvaluateAnimation({
    required this.injected,
    required this.tween,
    required this.curve,
    required this.reverseCurve,
  });
  Animatable<dynamic>? forwardAnimation;
  Animatable<dynamic>? backwardAnimation;
  dynamic evaluate() {
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
