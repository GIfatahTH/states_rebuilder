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

        final _tweens = <String, Tween<dynamic>>{};
        final _curvedTweens = <String, EvaluateAnimation>{};
        final assertionList = [];
        late final Animate animate;
        T? getValue<T>(String name) {
          try {
            final val = _curvedTweens[name]?.evaluate(inj.controller!);
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
            if (currentValue != null) {
              return currentValue;
            }
            _curvedTweens[name] = EvaluateAnimation(
              tween.chain(CurveTween(curve: curve ?? inj.curve)),
              inj.reverseCurve != null || reserveCurve != null
                  ? tween.chain(
                      CurveTween(curve: reserveCurve ?? inj.reverseCurve!),
                    )
                  : null,
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
              tween.chain(CurveTween(curve: curve ?? inj.curve)),
              inj.reverseCurve != null || reserveCurve != null
                  ? tween.chain(
                      CurveTween(curve: reserveCurve ?? inj.reverseCurve!),
                    )
                  : null,
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
          return currentValue ?? tween.lerp(0.0);
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

        void triggerAnimation() {
          if (_isDirty && _isChanged == true) {
            _isChanged = false;
            injected.triggerAnimation();
          }
        }

        void _didUpdateWidget() {
          _isDirty = true;
          inj.didUpdateWidget();
          inj._isFrameScheduling = false;
          SchedulerBinding.instance!.addPostFrameCallback(
            (_) {
              assertionList.clear();
              if (inj._controller != null) {
                triggerAnimation();
              }
              _isDirty = false;
            },
          );
        }

        final disposeDidUpdateWidget = inj.addToDidUpdateWidgetListeners(
          () {
            _hasChanged = true;
            _didUpdateWidget();
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
              if (_hasChanged) {
                setState();
              }
            });
            SchedulerBinding.instance!.addPostFrameCallback((_) {
              assertionList.clear();
              isInit = false;
            });
          },
          dispose: (_) {
            if (ticker != null) {
              inj.dispose();
            }
            disposer();
            disposeDidUpdateWidget();
          },
          didUpdateWidget: (_, __, ___) {
            _didUpdateWidget();
          },
          builder: (_, widget) {
            return widget.animate(animate);
          },
        );
      },
      widget: _OnAnimationWidget(anim, injected as InjectedAnimationImp),
      injected: injected,
      key: key,
    );
  }
}

class _OnAnimationWidget {
  final Widget Function(Animate animate) animate;
  final InjectedAnimationImp injected;
  _OnAnimationWidget(this.animate, this.injected);
}

class EvaluateAnimation {
  final Animatable<dynamic> forwardAnimation;
  final Animatable<dynamic>? backwardAnimation;

  EvaluateAnimation(this.forwardAnimation, this.backwardAnimation);
  dynamic evaluate(AnimationController controller) {
    if (backwardAnimation == null) {
      return forwardAnimation.evaluate(controller);
    }
    if (controller.status == AnimationStatus.reverse) {
      return backwardAnimation!.evaluate(controller);
    }
    return forwardAnimation.evaluate(controller);
  }
}
