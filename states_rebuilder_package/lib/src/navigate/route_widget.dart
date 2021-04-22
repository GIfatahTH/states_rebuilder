part of '../rm.dart';

class RouteWidget extends Widget {
  final Widget Function(Widget child)? builder;
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? transitionsBuilder;

  final Map<String, Widget Function(RouteData data)> routes;
  RouteWidget({
    this.builder,
    this.routes = const {},
    this.transitionsBuilder,
  }) : assert(builder != null || routes.isNotEmpty);

  @override
  Element createElement() {
    throw UnimplementedError();
  }
}
