part of '../reactive_model.dart';

class _RouteData {
  final Widget Function(Widget child)? builder;
  final Widget? subRoute;

  final RouteData routeData;
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? transitionsBuilder;
  _RouteData({
    required this.builder,
    required this.subRoute,
    required this.routeData,
    //
    required this.transitionsBuilder,
  });

  _RouteData copyWith({
    Widget Function(Widget child)? builder,
    Widget? subRoute,
    List<String>? paths,
    String? baseUrl,
    String? name,
    RouteData? routeData,
    Widget Function(
      BuildContext,
      Animation<double>,
      Animation<double>,
      Widget,
    )?
        transitionsBuilder,
  }) {
    return _RouteData(
      builder: builder ?? this.builder,
      subRoute: subRoute ?? this.subRoute,
      routeData: routeData ?? this.routeData,
      transitionsBuilder: transitionsBuilder ?? this.transitionsBuilder,
    );
  }

  @override
  String toString() =>
      '_RouteData(child: $builder, subRoute: $subRoute, routeData: $routeData)';
}

class RouteData {
  final String baseUrl;
  final String routePath;
  // final String routeName;
  final Map<String, String> queryParams;
  final Map<String, String> pathParams;
  final dynamic arguments;
  bool _isBaseUrlChanged = false;
  RouteData({
    required this.baseUrl,
    required this.routePath,
    // required this.routeName,
    required this.queryParams,
    required this.pathParams,
    required this.arguments,
  });

  @override
  String toString() {
    return 'RouteData(baseUrl: $baseUrl, routePath: $routePath, queryParams: $queryParams, pathParams: $pathParams, arguments: $arguments, _isBaseUrlChanged: $_isBaseUrlChanged)';
  }
}
