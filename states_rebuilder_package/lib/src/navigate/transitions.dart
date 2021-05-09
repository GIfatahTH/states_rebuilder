part of '../rm.dart';

final _transitions = _Transitions();

class _Transitions {
  ///A right to left predefined [TransitionBuilder].
  ///
  ///The TransitionBuilder animate the position and the opacity
  ///of the page.
  ///
  ///You can set the tween the curve , and the duration of the position and opacity
  ///animation
  ///
  ///Default values are :
  ///
  ///* For position animation:
  ///```dart
  ///positionTween = Tween<Offset>(
  ///   begin: const Offset(0.25, 0),
  ///   end: Offset.zero,
  /// )
  ///
  ///positionCurve = Curves.fastOutSlowIn;
  ///```
  ///
  ///* For opacity animation:
  ///```dart
  ///opacityTween = Tween<double>(begin: 0.0, end: 1.0)
  ///
  ///opacityCurve = Curves.easeIn;
  ///```
  ///
  Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) rightToLeft({
    Tween<Offset>? positionTween,
    Curve? positionCurve,
    Tween<double>? opacityTween,
    Curve? opacityCurve,
    Duration? duration,
  }) {
    _Navigate._transitionDuration = duration;
    return (context, animation, secondaryAnimation, child) {
      positionTween ??= Tween<Offset>(
        begin: const Offset(0.25, 0),
        end: Offset.zero,
      );
      opacityTween ??= Tween<double>(begin: 0.0, end: 1.0);
      final Animation<Offset> _positionAnimation = animation.drive(
        positionTween!.chain(
          CurveTween(curve: positionCurve ?? Curves.fastOutSlowIn),
        ),
      );
      final Animation<double> _opacityAnimation = animation.drive(
        opacityTween!.chain(
          CurveTween(curve: opacityCurve ?? Curves.easeIn),
        ),
      );

      return SlideTransition(
        position: _positionAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: child,
        ),
      );
    };
  }

  ///A left to right predefined [TransitionBuilder].
  ///
  ///The TransitionBuilder animate the position and the opacity
  ///of the page.
  ///
  ///You can set the tween the curve , and the duration of the position and opacity
  ///animation
  ///
  ///Default values are :
  ///
  ///* For position animation:
  ///```dart
  ///positionTween = Tween<Offset>(
  ///   begin: const Offset(-0.25, 0),
  ///   end: Offset.zero,
  /// )
  ///
  ///positionCurve = Curves.fastOutSlowIn;
  ///```
  ///
  ///* For opacity animation:
  ///```dart
  ///opacityTween = Tween<double>(begin: 0.0, end: 1.0)
  ///
  ///opacityCurve = Curves.easeIn;
  ///```
  ///
  Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) leftToRight({
    Tween<Offset>? positionTween,
    Curve? positionCurve,
    Tween<double>? opacityTween,
    Curve? opacityCurve,
    Duration? duration,
  }) {
    _Navigate._transitionDuration = duration;
    return (context, animation, secondaryAnimation, child) {
      positionTween ??= Tween<Offset>(
        begin: const Offset(-0.25, 0),
        end: Offset.zero,
      );
      opacityTween ??= Tween<double>(begin: 0.0, end: 1.0);
      final Animation<Offset> _positionAnimation = animation.drive(
        positionTween!.chain(
          CurveTween(curve: positionCurve ?? Curves.fastOutSlowIn),
        ),
      );
      final Animation<double> _opacityAnimation = animation.drive(
        opacityTween!.chain(
          CurveTween(curve: opacityCurve ?? Curves.easeIn),
        ),
      );
      return SlideTransition(
        position: _positionAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: child,
        ),
      );
    };
  }

  ///A bottom to up predefined [TransitionBuilder].
  ///
  ///The TransitionBuilder animate the position and the opacity
  ///of the page.
  ///
  ///You can set the tween the curve , and the duration of the position and opacity
  ///animation
  ///
  ///Default values are :
  ///
  ///* For position animation:
  ///```dart
  ///positionTween = Tween<Offset>(
  ///   begin: const Offset(0.0, 0.25),
  ///   end: Offset.zero,
  /// )
  ///
  ///positionCurve = Curves.fastOutSlowIn;
  ///```
  ///
  ///* For opacity animation:
  ///```dart
  ///opacityTween = Tween<double>(begin: 0.0, end: 1.0)
  ///
  ///opacityCurve = Curves.easeIn;
  ///```
  ///
  Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) bottomToUp({
    Tween<Offset>? positionTween,
    Curve? positionCurve,
    Tween<double>? opacityTween,
    Curve? opacityCurve,
    Duration? duration,
  }) {
    _Navigate._transitionDuration = duration;
    return (context, animation, secondaryAnimation, child) {
      positionTween ??= Tween<Offset>(
        begin: const Offset(0.0, 0.25),
        end: Offset.zero,
      );
      opacityTween ??= Tween<double>(begin: 0.0, end: 1.0);
      final Animation<Offset> _positionAnimation = animation.drive(
        positionTween!.chain(
          CurveTween(curve: positionCurve ?? Curves.fastOutSlowIn),
        ),
      );
      final Animation<double> _opacityAnimation = animation.drive(
        opacityTween!.chain(
          CurveTween(curve: opacityCurve ?? Curves.easeIn),
        ),
      );
      return SlideTransition(
        position: _positionAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: child,
        ),
      );
    };
  }

  ///A up to bottom predefined [TransitionBuilder].
  ///
  ///The TransitionBuilder animate the position and the opacity
  ///of the page.
  ///
  ///You can set the tween the curve , and the duration of the position and opacity
  ///animation
  ///
  ///Default values are :
  ///
  ///* For position animation:
  ///```dart
  ///positionTween = Tween<Offset>(
  ///   begin: const Offset(0.0, -0.25),
  ///   end: Offset.zero,
  /// )
  ///
  ///positionCurve = Curves.fastOutSlowIn;
  ///```
  ///
  ///* For opacity animation:
  ///```dart
  ///opacityTween = Tween<double>(begin: 0.0, end: 1.0)
  ///
  ///opacityCurve = Curves.easeIn;
  ///```
  ///
  Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  ) upToBottom({
    Tween<Offset>? positionTween,
    Curve? positionCurve,
    Tween<double>? opacityTween,
    Curve? opacityCurve,
    Duration? duration,
  }) {
    return (context, animation, secondaryAnimation, child) {
      _Navigate._transitionDuration = duration;
      positionTween ??= Tween<Offset>(
        begin: const Offset(0.0, -0.25),
        end: Offset.zero,
      );
      opacityTween ??= Tween<double>(begin: 0.0, end: 1.0);
      final Animation<Offset> _positionAnimation = animation.drive(
        positionTween!.chain(
          CurveTween(curve: positionCurve ?? Curves.fastOutSlowIn),
        ),
      );
      final Animation<double> _opacityAnimation = animation.drive(
        opacityTween!.chain(
          CurveTween(curve: opacityCurve ?? Curves.easeIn),
        ),
      );

      return SlideTransition(
        position: _positionAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: child,
        ),
      );
    };
  }
}
