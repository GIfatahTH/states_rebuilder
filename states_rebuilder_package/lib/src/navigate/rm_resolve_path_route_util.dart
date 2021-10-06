part of '../rm.dart';

class ResolvePathRouteUtil {
  late Map<String, Widget Function(RouteData data)> _routes = Routers.routers!;
  final Map<String, _RouteData> _routeData = {};
  RouteData? routeData;

  String _urlPath = '';
  String baseUrl = '';
  String _routePath = '';
  String absolutePath = '';
  dynamic _routeArguments;
  final Map<String, String> _routeQueryParams = {};
  final Map<String, String> _routePathParams = {};
  void _resetFields() {
    _routeData.clear();
    routeData = null;
    _routeQueryParams.clear();
    _routePathParams.clear();
    _routeArguments = null;

    _urlPath = '';
    _routePath = '';
    absolutePath = '';
  }

  void setAbsoluteUrlPath(RouteSettings settings) {
    _resetFields();
    if (settings.name!.startsWith('/')) {
      absolutePath = settings.name!;
    } else {
      if (baseUrl == '') {
        absolutePath = '/' + settings.name!;
      } else {
        String relativeBasePath = _getBaseUrl('/' + settings.name!);
        String? p;
        while (relativeBasePath.isNotEmpty) {
          // add '/' to ensure the route name and not a stirng containing the name
          final r = (baseUrl + '/').split(relativeBasePath + '/');
          if (r.length > 1) {
            r.removeLast();
            p = r.join('/');
          }
          if (p != null) {
            break;
          }
          relativeBasePath = _getBaseUrl(relativeBasePath);
        }

        absolutePath = (p ?? baseUrl) + '/' + settings.name!;
      }
    }
  }

  List<RouteSettingsWithChild> decodeRouteSettings(
    RouteSettings settings, [
    List<RouteSettingsWithChild>? settingsWithChild,
  ]) {
    if (settingsWithChild == null) {
      setAbsoluteUrlPath(settings);
      settings = settings.copyWith(name: absolutePath);
      settingsWithChild = [];
    }

    final uri = Uri.parse(settings.name!);
    late Uri routeUri;
    late String childName;

    var name = _routes.keys.firstWhereOrNull(
      (key) {
        final matcher = _isMatched(
          Uri.parse(key),
          uri,
        );
        if (matcher.first == true) {
          routeUri = matcher[1];
          childName = matcher[2];

          return true;
        }
        return false;
      },
    );

    final route = _routes[name];
    if (route != null) {
      _routeArguments = settings.arguments;
      if (uri.queryParameters.isNotEmpty) {
        _routeQueryParams.addAll(uri.queryParameters);
      }
      if (routeUri.queryParameters.isNotEmpty) {
        _routePathParams.addAll(routeUri.queryParameters);
      }

      _urlPath += routeUri.path;
      _routePath += name!;
      routeData = RouteData(
        baseUrl: _getBaseUrl(_urlPath),
        routePath: _routePath,
        urlPath: _urlPath,
        arguments: _routeArguments,
        queryParams: {..._routeQueryParams},
        pathParams: {..._routePathParams},
      );
      Widget page = route(routeData!);
      settingsWithChild.add(
        RouteSettingsWithChild(
          name: _urlPath,
          child: page,
          arguments: _routeArguments,
          queryParams: {..._routeQueryParams},
          pathParams: {..._routePathParams},
        ),
      );
    }
    return settingsWithChild;
  }

  Widget? resolvePageFromRouteSettings(RouteSettings settings) {
    setAbsoluteUrlPath(settings);
    settings = settings.copyWith(name: absolutePath);
    return _resolvePage(settings);
  }

  Widget? _resolvePage(RouteSettings settings) {
    assert(settings.name != null);

    final uri = Uri.parse(settings.name!);
    late Uri routeUri;
    late String childName;

    var name = _routes.keys.firstWhereOrNull(
      (key) {
        final matcher = _isMatched(
          Uri.parse(key),
          uri,
        );
        if (matcher.first == true) {
          routeUri = matcher[1];
          childName = matcher[2];

          return true;
        }
        return false;
      },
    );

    final route = _routes[name];
    if (route != null) {
      _routeArguments = settings.arguments;
      if (uri.queryParameters.isNotEmpty) {
        _routeQueryParams.addAll(uri.queryParameters);
      }
      if (routeUri.queryParameters.isNotEmpty) {
        _routePathParams.addAll(routeUri.queryParameters);
      }

      _urlPath += routeUri.path;
      _routePath += name!;
      routeData = RouteData(
        baseUrl: _getBaseUrl(_urlPath),
        urlPath: _urlPath,
        routePath: _routePath,
        arguments: _routeArguments,
        queryParams: {..._routeQueryParams},
        pathParams: {..._routePathParams},
      );
      routeData!._isBaseUrlChanged =
          baseUrl.isEmpty ? true : !baseUrl.startsWith(routeData!.baseUrl);

      Widget page = route(routeData!);

      if (page is RouteWidget) {
        if (page.routes.isEmpty) {
          name = _routeData.containsKey(name)
              ? name + '${_routeData.length}'
              : name;
          _routeData[name] = _RouteData(
            builder: page.builder,
            subRoute: null,
            transitionsBuilder: page.transitionsBuilder,
            routeData: routeData!,
          );
          return page.builder!(Container());
        } else {
          if (page.builder != null) {
            name = _routeData.containsKey(name)
                ? name + '${_routeData.length}'
                : name;
            _routeData[name] = _RouteData(
              builder: page.builder,
              subRoute: null,
              transitionsBuilder: page.transitionsBuilder,
              routeData: routeData!,
            );
          }

          final n = childName.startsWith('/') ? childName : '/$childName';
          _routes = page.routes;
          final p = _resolvePage(settings.copyWith(name: n));
          _routes = Routers.routers!;
          if (p != null) {
            if (page.builder != null) {
              _routeData[name] = _routeData[name]!.copyWith(subRoute: p);
            }
            return p;
          }
          return null;
        }
      }
      name =
          _routeData.containsKey(name) ? name + '${_routeData.length}' : name;
      _routeData[name] = _RouteData(
        builder: (_) => page,
        routeData: routeData!,
        subRoute: null,
        transitionsBuilder: null,
      );
      return page;
    }
    return null;
  }

  // Widget _getChild(Widget Function(RouteData) fn) {

  // }

  RouteData? _getRouteData({
    required List<String> routeUriSegments,
    required RouteSettings settings,
    required String? baseUrlPath,
    required String? baseRouteUri,
  }) {
    final pathUrl = Uri.parse(settings.name!);
    final pathUrlSegments = pathUrl.pathSegments;
    if (routeUriSegments.length > pathUrlSegments.length) {
      return null;
    }
    if (routeUriSegments.isEmpty) {
      baseUrlPath ??= '/';
      return RouteData(
        baseUrl: baseUrlPath,
        urlPath: baseUrlPath,
        routePath: baseUrlPath,
        arguments: settings.arguments,
        queryParams: pathUrl.queryParameters,
        pathParams: {},
      );
    }
    Map<String, String> params = {};
    baseUrlPath ??= '/';
    String parsedPathUrl = baseUrlPath.length > 1 ? baseUrlPath : '';
    String parsedRouteUri = baseRouteUri ?? '';
    for (var i = 0; i < routeUriSegments.length; i++) {
      if (routeUriSegments[i].startsWith(':')) {
        params[routeUriSegments[i].substring(1)] = pathUrlSegments[i];
      } else {
        if (routeUriSegments[i] != pathUrlSegments[i]) {
          return null;
        }
      }

      parsedRouteUri += '/${routeUriSegments[i]}';
      parsedPathUrl += '/${pathUrlSegments[i]}';
    }
    final routeData = RouteData(
      baseUrl: baseUrlPath,
      urlPath: parsedPathUrl,
      routePath: parsedRouteUri,
      arguments: settings.arguments,
      queryParams: pathUrl.queryParameters,
      pathParams: {...params},
    );
    routeData._isBaseUrlChanged =
        baseUrlPath.isEmpty ? true : !baseUrlPath.startsWith(routeData.baseUrl);

    return routeData;
  }

  Map<String, RouteSettingsWithChild> resolve({
    required Map<String, Widget Function(RouteData)> routes,
    required RouteSettings settings,
    String? baseUrlPath,
    String? baseRouteUri,
  }) {
    RouteSettings s = settings;
    final matched = <String, RouteSettingsWithChild>{};
    if (baseUrlPath != null && baseUrlPath != '/') {
      s = settings.copyWith(
        name: settings.name!.replaceFirst(baseUrlPath, ''),
      );
    }

    for (final route in routes.keys) {
      final routeUriSegments = Uri.parse(route).pathSegments;
      final routeData = _getRouteData(
        routeUriSegments: routeUriSegments,
        settings: s,
        baseUrlPath: baseUrlPath,
        baseRouteUri: baseRouteUri,
      );
      if (routeData != null) {
        Widget page = routes[route]!(routeData);
        if (page is RouteWidget && page.routes.isNotEmpty) {
          final subSettings = routeData.urlPath;
          final subRouteMatches = resolve(
            routes: page.routes,
            settings: settings,
            baseUrlPath: routeData.urlPath,
            baseRouteUri: routeData.routePath,
          );
          matched.addAll(subRouteMatches);
          matched[subSettings] = RouteSettingsWithChildAndSubRoute(
            name: subSettings,
            child: page,
            subRoute: subRouteMatches[subSettings]!.child,
            isBaseUrlChanged: routeData._isBaseUrlChanged,
            arguments: routeData.arguments,
            pathParams: routeData.pathParams,
            queryParams: routeData.queryParams,
          );
        } else {
          matched[routeData.urlPath] = RouteSettingsWithChild(
            name: routeData.urlPath,
            child: page,
            arguments: routeData.arguments,
            pathParams: routeData.pathParams,
            queryParams: routeData.queryParams,
          );
        }
      }
    }
    return matched;
  }
}

String _getBaseUrl(String path) {
  final segments = path.split('/');
  segments.removeLast();
  return segments.join('/');
}

List<dynamic> _isMatched(Uri routeUri, Uri pathUrl) {
  Map<String, String>? params;
  final routeUriSegments = routeUri.pathSegments;
  final pathUrlSegments = pathUrl.pathSegments;
  if (routeUriSegments.length > pathUrlSegments.length) {
    return [false, null, null];
  }
  if (routeUriSegments.isEmpty) {
    if (pathUrlSegments.isEmpty) {
      return [true, routeUri, ''];
    } else {
      return [false, null, null];
    }
  }

  String parsedUrl = '';
  for (var i = 0; i < routeUriSegments.length; i++) {
    if (routeUriSegments[i].startsWith(':')) {
      params ??= {};
      params[routeUriSegments[i].substring(1)] = pathUrlSegments[i];
    } else {
      if (routeUriSegments[i] != pathUrlSegments[i]) {
        return [false, params, ''];
      }
    }
    parsedUrl += '/${pathUrlSegments[i]}';
  }
  return [
    true,
    routeUri.replace(path: parsedUrl, queryParameters: params),
    pathUrl.path.replaceFirst(parsedUrl, ''),
  ];
}
