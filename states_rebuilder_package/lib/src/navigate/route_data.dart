part of '../rm.dart';

class RouteData {
  String get baseLocation =>
      _pathEndsWithSlash ? location : _getBaseUrl(location, path);
  final String path;
  final String location;
  final Map<String, String> queryParams;
  final Map<String, String> pathParams;
  final dynamic arguments;
  final bool _pathEndsWithSlash;
  final List<String> _redirectedFrom;
  String? get redirectedFrom {
    if (_redirectedFrom.isEmpty) {
      return null;
    }
    return _redirectedFrom.first;
  }

  // ignore: prefer_final_fields
  Redirect redirectTo(String? route) {
    return Redirect(route);
  }

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
