part of '../rm.dart';

/// Object that holds information about the active route.
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
      _pathEndsWithSlash ? location : _getBaseUrl(location, path);

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
  String? get redirectedFrom {
    if (_redirectedFrom.isEmpty) {
      return null;
    }
    return _redirectedFrom.first;
  }

  /// redirect to the given route
  Redirect redirectTo(String? route) {
    return Redirect(route);
  }

  final bool _pathEndsWithSlash;
  final List<String> _redirectedFrom;
  const RouteData({
    required this.path,
    required this.location,
    required this.queryParams,
    required this.pathParams,
    required this.arguments,
    required bool pathEndsWithSlash,
    required List<String> redirectedFrom,
  })  : _pathEndsWithSlash = pathEndsWithSlash,
        _redirectedFrom = redirectedFrom;

  /// log the detailed of the navigation steps.
  void log() {
    String l = '';
    if (queryParams.isNotEmpty) {
      l = Uri(path: location, queryParameters: queryParams).toString();
    } else {
      l = location;
    }
    String m = 'Routing to location: "$l" (Path is:"$path"). ';
    if (redirectedFrom != null) {
      m += 'RedirectedFrom: $_redirectedFrom';
    }
    StatesRebuilerLogger.log(m);
  }

  @override
  String toString() {
    if (redirectedFrom == null) {
      return 'RouteData(urlPath: $location, baseUrl: $baseLocation, routePath: $path, queryParams: $queryParams, pathParams: $pathParams, arguments: $arguments)';
    }
    return 'RouteData(directedFrom: $redirectedFrom, urlPath: $location, baseUrl: $baseLocation, routePath: $path, urlPath: $location, '
        'queryParams: $queryParams, pathParams: $pathParams, arguments: $arguments)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteData &&
        other.path == path &&
        other.location == location &&
        mapEquals(other.queryParams, queryParams) &&
        mapEquals(other.pathParams, pathParams) &&
        other.arguments == arguments &&
        other._pathEndsWithSlash == _pathEndsWithSlash;
  }

  @override
  int get hashCode {
    return path.hashCode ^
        location.hashCode ^
        queryParams.hashCode ^
        pathParams.hashCode ^
        arguments.hashCode ^
        _pathEndsWithSlash.hashCode;
  }

  RouteData copyWith({
    bool? pathEndsWithSlash,
  }) {
    return RouteData(
      path: path,
      location: location,
      queryParams: queryParams,
      pathParams: pathParams,
      arguments: arguments,
      pathEndsWithSlash: pathEndsWithSlash ?? _pathEndsWithSlash,
      redirectedFrom: _redirectedFrom,
    );
  }
}

class Redirect extends Widget {
  final String? to;
  // ignore: use_key_in_widget_constructors
  const Redirect(this.to);
  @override
  Element createElement() {
    throw UnimplementedError();
  }
}
