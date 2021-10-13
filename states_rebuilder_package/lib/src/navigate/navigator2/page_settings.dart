part of '../../rm.dart';

@immutable
class PageSettings extends RouteSettings {
  final Widget? child;
  final Map<String, String> pathParams;
  final Map<String, String> queryParams;
  const PageSettings({
    required String name,
    Object? arguments,
    this.child,
    this.pathParams = const {},
    this.queryParams = const {},
  }) : super(name: name, arguments: arguments);

  @override
  PageSettings copyWith({
    String? name,
    Object? arguments,
    Widget? child,
    Map<String, String>? queryParams,
    Map<String, String>? pathParams,
  }) {
    return PageSettings(
      name: name ?? super.name!,
      arguments: arguments ?? super.arguments,
      child: child ?? this.child,
      queryParams: queryParams ?? this.queryParams,
      pathParams: pathParams ?? this.pathParams,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PageSettings &&
        other.name == name &&
        '${other.queryParams}' == '$queryParams';
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Page(name: $name, child: $child, arguments: $arguments,'
      ' pathParams: $pathParams, queryParams: $queryParams)';
}

class RouteSettingsWithChildAndData extends PageSettings {
  final String routeUriPath;
  final String baseUrlPath;
  final bool isPagesFound;
  final bool isBaseUrlChanged;
  const RouteSettingsWithChildAndData({
    required String name,
    required this.routeUriPath,
    required this.baseUrlPath,
    this.isPagesFound = true,
    this.isBaseUrlChanged = false,
    Object? arguments,
    Widget? child,
    Map<String, String> queryParams = const {},
    Map<String, String> pathParams = const {},
  }) : super(
          name: name,
          child: child,
          arguments: arguments,
          queryParams: queryParams,
          pathParams: pathParams,
        );

  // @override
  // RouteSettingsWithChildAndData copyWith({
  //   String? name,
  //   Object? arguments,
  //   Widget? child,
  //   Map<String, String>? queryParams,
  //   Map<String, String>? pathParams,
  //   String? routeUriPath,
  //   String? baseUrlPath,
  //   bool? isBaseUrlChanged,
  // }) {
  //   return RouteSettingsWithChildAndData(
  //     name: name ?? super.name!,
  //     arguments: arguments ?? super.arguments,
  //     child: child ?? this.child,
  //     queryParams: queryParams ?? this.queryParams,
  //     pathParams: pathParams ?? this.pathParams,
  //     routeUriPath: routeUriPath ?? this.routeUriPath,
  //     baseUrlPath: baseUrlPath ?? this.baseUrlPath,
  //     isBaseUrlChanged: isBaseUrlChanged ?? this.isBaseUrlChanged,
  //   );
  // }

  @override
  String toString() => isPagesFound
      ? 'PageWithData(name: $name, child: $child, arguments: $arguments,'
          'baseUrlPath: $baseUrlPath, routeUriPath: $routeUriPath, '
          ' pathParams: $pathParams, queryParams: $queryParams)'
      : 'PAGE NOT Found (name: $name)';
}

class RouteSettingsWithChildAndSubRoute extends RouteSettingsWithChildAndData {
  final Widget? subRoute;
  const RouteSettingsWithChildAndSubRoute({
    required String name,
    required String routeUriPath,
    required String baseUrlPath,
    Object? arguments,
    Widget? child,
    Map<String, String> queryParams = const {},
    Map<String, String> pathParams = const {},
    this.subRoute,
    bool isPagesFound = true,
    bool isBaseUrlChanged = false,
  }) : super(
          name: name,
          child: child,
          arguments: arguments,
          queryParams: queryParams,
          pathParams: pathParams,
          routeUriPath: routeUriPath,
          baseUrlPath: baseUrlPath,
          isPagesFound: isPagesFound,
          isBaseUrlChanged: isBaseUrlChanged,
        );

  // @override
  // RouteSettingsWithChildAndSubRoute copyWith({
  //   String? name,
  //   String? routeUriPath,
  //   String? baseUrlPath,
  //   Object? arguments,
  //   Widget? child,
  //   Map<String, String>? queryParams,
  //   Map<String, String>? pathParams,
  //   bool? isBaseUrlChanged,
  //   Widget? subRoute,
  // }) {
  //   return RouteSettingsWithChildAndSubRoute(
  //     name: name ?? super.name!,
  //     routeUriPath: routeUriPath ?? this.routeUriPath,
  //     baseUrlPath: baseUrlPath ?? this.baseUrlPath,
  //     arguments: arguments ?? super.arguments,
  //     child: child ?? this.child,
  //     queryParams: queryParams ?? this.queryParams,
  //     pathParams: pathParams ?? this.pathParams,
  //     subRoute: subRoute ?? this.subRoute,
  //     isBaseUrlChanged: isBaseUrlChanged ?? super.isBaseUrlChanged,
  //   );
  // }

  @override
  String toString() =>
      'SubPageWithData(name: $name, child: $child, subRoute: $subRoute, arguments: $arguments,'
      'baseUrlPath: $baseUrlPath, routeUriPath: $routeUriPath, '
      ' pathParams: $pathParams, queryParams: $queryParams)';
}

class _MaterialPage<T> extends Page<T> {
  /// Creates a material page.
  const _MaterialPage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
    this.transitionsBuilder,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? transitionsBuilder;

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return _navigate._pageRouteBuilder<T>(
      (_) => child,
      this,
      fullscreenDialog,
      maintainState,
      transitionsBuilder: transitionsBuilder,
    );
  }
}

mixin NavigatorMixin {
  /// Use
  late final RouterDelegate<PageSettings> routerDelegate =
      RouterObjects._routerDelegate['/']!;
  late final RouteInformationParser<PageSettings> routeInformationParser =
      RouterObjects._routeInformationParser!;

  Map<String, Widget Function(RouteData)> get routes;
  Widget Function(String route)? get unknownRoute => null;
  Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )? get transitionsBuilder => null;
}
