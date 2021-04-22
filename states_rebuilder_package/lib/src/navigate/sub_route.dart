part of '../rm.dart';

class SubRoute extends InheritedWidget {
  const SubRoute._({
    Key? key,
    required Widget child,
    required this.route,
    required this.lastSubRoute,
    required this.animation,
    required this.shouldAnimate,
    required this.routeData,
    this.transitionsBuilder,
  }) : super(key: key, child: child);
  final Widget? route;
  final Widget? lastSubRoute;
  final RouteData routeData;
  final Animation<double>? animation;
  final bool shouldAnimate;
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? transitionsBuilder;

  @override
  bool updateShouldNotify(SubRoute _) {
    return false;
  }
}
