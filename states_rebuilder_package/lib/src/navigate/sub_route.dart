part of '../rm.dart';

/// SubRoute inherited widget
class SubRoute extends InheritedWidget {
  const SubRoute._({
    Key? key,
    required Widget child,
    required this.route,
    required this.lastSubRoute,
    required this.animation,
    this.secondaryAnimation,
    required this.shouldAnimate,
    required this.routeData,
    this.transitionsBuilder,
  }) : super(key: key, child: child);
  final Widget? route;
  final Widget? lastSubRoute;
  final RouteData routeData;
  final Animation<double>? animation;
  final Animation<double>? secondaryAnimation;
  final bool shouldAnimate;
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? transitionsBuilder;

  SubRoute copyWith({
    Animation<double>? animation,
    Animation<double>? secondaryAnimation,
  }) {
    return SubRoute._(
      child: child,
      route: route,
      lastSubRoute: lastSubRoute,
      animation: animation ?? this.animation,
      secondaryAnimation: secondaryAnimation ?? this.secondaryAnimation,
      shouldAnimate: shouldAnimate,
      routeData: routeData,
    );
  }

  @override
  bool updateShouldNotify(SubRoute oldWidget) {
    return true;
  }
}
