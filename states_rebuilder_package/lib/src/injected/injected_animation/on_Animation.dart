part of 'injected_animation.dart';

class OnAnimation {
  final Widget Function(Animate animate) anim;
  OnAnimation(this.anim);

  ///Listen to the [InjectedAnimation]
  Widget listenTo(
    InjectedAnimation injected, {
    void Function()? onInitialized,
  }) {
    return StateBuilderBaseWithTicker<_OnAnimationWidget>(
      (_, setState, ticker) {
        final inj = injected as InjectedAnimationImp;
        late VoidCallback disposer;
        bool isAnimating = false;
        bool? _isChanged;
        bool _isDirty = false;
        bool isInit = true;
        final _tweens = <String, Tween<dynamic>>{};
        final _curvedTweens = <String, Animatable<dynamic>>{};
        final assertionList = [];
        late final Animate animate;
        T? getValue<T>(String name) {
          try {
            final val = _curvedTweens[name]?.evaluate(injected.controller!);
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

        T? _animateTween<T>(dynamic Function(T? begin) fn, String name) {
          T? currentValue = getValue(name);
          if (isAnimating && currentValue != null) {
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

          final cachedTween = _tweens[name];
          final tween = fn(currentValue);
          if (tween == null) {
            return null;
          }

          if (isInit) {
            currentValue = tween.begin;
            _curvedTweens[name] =
                tween.chain(CurveTween(curve: injected.curve));
            _tweens[name] = tween;
            if (tween.begin == tween.end) {
              return tween.begin;
            }
            _isChanged = true;
            _isDirty = true;
          } else if ((cachedTween?.end != tween.end ||
                  cachedTween?.begin != tween.begin) &&
              _isDirty) {
            _curvedTweens[name] =
                tween.chain(CurveTween(curve: injected.curve));
            _tweens[name] = tween;
            _isChanged = true;
          }

          if (tween.begin == tween.end) {
            return tween.begin;
          }
          //At this point controller.value == 0 or 1
          // assert(controller!.value == 0.0 || controller!.value == 1.0);
          return currentValue ?? tween.lerp(0.0);
        }

        T? animateTween<T>(dynamic Function(T? begin) fn, [String name = '']) {
          name = 'Tween<$T>' + name + '_TwEeN_';
          return _animateTween(fn, name);
        }

        T? animateValue<T>(T? value, [String name = '']) {
          name = '$T' + name;

          return animateTween<T>(
            (begin) => _getTween(isInit ? value : begin, value),
            name,
          );
        }

        void triggerAnimation() {
          if (_isDirty && _isChanged == true) {
            _isChanged = false;
            _isDirty = false;
            isAnimating = true;
            injected.triggerAnimation();
          }
        }

        return LifeCycleHooks(
          mountedState: (_) {
            if (ticker != null) {
              inj.initialize(ticker);
            }
            onInitialized?.call();
            animate = Animate._(
              value: animateValue,
              formTween: animateTween,
            );
            disposer = injected.reactiveModelState.listeners.addListener((_) {
              if (_curvedTweens.isNotEmpty) {
                setState();
              }
            });
          },
          dispose: (_) {
            if (ticker != null) {
              inj.dispose();
            }
            disposer();
          },
          didUpdateWidget: (_, __, ___) {
            inj.didUpdateWidget();
            // animate._controller = CurvedAnimation(
            //   parent: injected.controller!,
            //   curve: injected.curve,
            // );
            if (isAnimating) {
              isAnimating = false;
            }
            _isDirty = true;
          },
          builder: (_, widget) {
            print('builder');
            final child = widget.animate(animate);
            assertionList.clear();
            triggerAnimation();
            isInit = false;
            return child;
          },
        );
      },
      widget: _OnAnimationWidget(anim),
      injected: injected,
    );
  }
}

class _OnAnimationWidget {
  final Widget Function(Animate animate) animate;
  _OnAnimationWidget(this.animate);
}
