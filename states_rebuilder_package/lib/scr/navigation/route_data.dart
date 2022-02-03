part of 'injected_navigator.dart';

/// Object that holds information about the active route.
///
/// Inside the widget tree you can get the scoped [RouteData] using
/// `context.routeData`.
///
/// See also [InjectedNavigator] and [RouteWidget]
@immutable
class RouteData {
  /// The current Base location.
  /// Example :
  /// * if the current location is `'/page1'` baseLocation will be `'/'`.
  /// * if the current location is `'/page1/'` baseLocation will be `'/page1'`.
  /// * if the current location is `'/page1/page2'` baseLocation will be `'/page1'`.
  /// * if the current location is `'/page1/page2/'` baseLocation will be
  /// `'/page1/page2`'.
  ///
  /// Notice that the ending slash changes the baseLocation.
  String get baseLocation =>
      _pathEndsWithSlash ? _subLocation : _getBaseUrl(_subLocation, path);

  /// The current used route.
  ///
  /// For example if our route map is:
  /// ```dart
  /// route: {
  ///    '/': (RouteData data) => Home(),
  ///    '/page1/:id': (RouteData data) => Page1(),
  /// }
  /// ```
  /// * if we navigate to `'/'`, the path is `'/'` and the location is `'/'`.
  /// * if we navig`ate to '/page1/1', the path is '/page1/:id' and the location
  /// is `'/page1/1'.
  ///
  final String path;

  /// The current resolved location.
  ///
  /// For example if our route map is:
  /// ```dart
  /// route: {
  ///    '/': (RouteData data) => Home(),
  ///    '/page1/:id': (RouteData data) => Page1(),
  /// }
  /// ```
  /// * if we navigate to `'/'`, the location is `'/'` and the path is `'/'`.
  /// * if we navigate to '/page1/1', the location is '/page1/1' and the path
  /// is `'/page1/:id'.
  ///
  final String location;

  /// Get the [Uri] representation of the resolved location

  late final Uri uri;

  String get _subLocation => uri.path;

  /// A map of query parameters extracted from the url link.
  ///
  /// Example if the link is `/products?id=1` the `queryParams` is `{'id': '1'}`
  final Map<String, String> queryParams;

  /// A map of path parameters extracted from the url link.
  ///
  /// Example if the route is `/products/:id` and the url link is `/products/1`
  /// the `pathParams` is `{'id': '1'}`
  final Map<String, String> pathParams;

  /// Arguments passed when pushing a route.
  final dynamic arguments;

  /// Holds the url location the route is redirected from.
  ///
  /// For Example if our routes are:
  /// ```dart
  ///   routes: {
  ///       '/login': (RouteData data) => LoginPage(),
  ///       '/home': (RouteData data) {
  ///           if(notSigned) {
  ///              return date.redirectTo(/login);
  ///           } else {
  ///             return HomePage();
  ///           }
  ///         },
  ///   }
  /// ```
  ///
  /// If an unsigned user routes to '/home', he will be redirect to `LoginPage`.
  /// The `redirectedFrom` will hold '/home' so we can route to it.
  ///
  RouteData? get redirectedFrom {
    if (_redirectedFrom.isEmpty) {
      return null;
    }
    return _redirectedFrom.first;
  }

  Widget get unKnownRoute =>
      RouterObjects.rootDelegate!._lastConfiguration != null &&
              RouterObjects.injectedNavigator!.ignoreUnknownRoutes
          ? const Redirect(null)
          : RouterObjects._unknownRoute(this);

  /// redirect to the given route
  Redirect redirectTo(String? route) {
    assert(route == null || route.startsWith('/'));
    return Redirect(route);
  }

  final bool _pathEndsWithSlash;
  final List<RouteData> _redirectedFrom;

  String get signature => '$uri$arguments${redirectedFrom?.uri}';

  /// Object that holds information about the active route.
  RouteData({
    required this.path,
    required this.location,
    required this.queryParams,
    required this.pathParams,
    required this.arguments,
    required bool pathEndsWithSlash,
    required List<RouteData> redirectedFrom,
    required String subLocation,
  })  : _pathEndsWithSlash = pathEndsWithSlash,
        _redirectedFrom = redirectedFrom {
    if (queryParams.isEmpty) {
      uri = Uri(path: subLocation);
    } else {
      uri = Uri(path: subLocation, queryParameters: queryParams);
    }
  }

  /// log the detailed of the navigation steps.
  void log() {
    String l = uri.toString();

    String m = 'Routing to location: "$l" (Path is:"$path"). ';
    if (redirectedFrom != null) {
      m += 'RedirectedFrom: $_redirectedFrom';
    }
    StatesRebuilerLogger.log(m);
  }

  @override
  String toString() {
    if (redirectedFrom == null) {
      return 'RouteData(urlPath: $_subLocation, baseUrl: $baseLocation, routePath: $path, queryParams: $queryParams, pathParams: $pathParams, arguments: $arguments)';
    }
    return 'RouteData(directedFrom: $redirectedFrom, urlPath: $_subLocation, baseUrl: $baseLocation, routePath: $path, '
        'queryParams: $queryParams, pathParams: $pathParams, arguments: $arguments)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteData &&
        other.path == path &&
        other._subLocation == _subLocation &&
        mapEquals(other.queryParams, queryParams) &&
        mapEquals(other.pathParams, pathParams) &&
        other.arguments == arguments &&
        other._pathEndsWithSlash == _pathEndsWithSlash;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        _subLocation.hashCode ^
        queryParams.hashCode ^
        pathParams.hashCode ^
        arguments.hashCode ^
        _pathEndsWithSlash.hashCode;
  }

  RouteData copyWith({
    bool? pathEndsWithSlash,
    String? subLocation,
  }) {
    return RouteData(
      path: path,
      location: location,
      queryParams: queryParams,
      pathParams: pathParams,
      arguments: arguments,
      pathEndsWithSlash: pathEndsWithSlash ?? _pathEndsWithSlash,
      redirectedFrom: _redirectedFrom,
      subLocation: subLocation ?? _subLocation,
    );
  }
}

class Redirect extends Widget {
  final String? to;
  final bool isUnknownRoute;
  // ignore: use_key_in_widget_constructors
  const Redirect(
    this.to, {
    this.isUnknownRoute = false,
  });
  @override
  Element createElement() {
    throw UnimplementedError();
  }
}
