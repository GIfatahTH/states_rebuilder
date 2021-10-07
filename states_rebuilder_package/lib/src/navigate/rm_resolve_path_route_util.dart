part of '../rm.dart';

class ResolvePathRouteUtil {
  late Map<String, Widget Function(RouteData data)> _routes = Routers.routers!;
  final Map<String, _RouteData> _routeData = {};
  RouteData? routeData;
  String absolutePath = '';
  String baseUrl = '';
  String _urlPath = '';
  String _routePath = '';
  dynamic _routeArguments;
  bool _isPagesFound = true;
  final Map<String, String> _queryParams = {};
  final Map<String, String> _pathParams = {};
  void _resetFields() {
    _routeData.clear();
    routeData = null;
    _queryParams.clear();
    _pathParams.clear();
    _routeArguments = null;
    absolutePath = '';

    _urlPath = '';
    _routePath = '';
    _isPagesFound = true;
  }

  String setAbsoluteUrlPath(RouteSettings settings) {
    late String absolutePath;
    _resetFields();
    if (settings.name!.startsWith('/')) {
      absolutePath = settings.name!;
    } else {
      if (baseUrl == '/' || baseUrl.isEmpty) {
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
    return this.absolutePath = absolutePath;
  }

  Map<String, RouteSettingsWithChildAndData> getPagesFromRouteSettings({
    required Map<String, Widget Function(RouteData)> routes,
    required RouteSettings settings,
    String? baseUrlPath,
    String? baseRouteUri,
    Widget Function(String routeName)? unknownRoute,
  }) {
    final absolutePath = setAbsoluteUrlPath(settings);
    final pages = resolve(
      routes: routes,
      settings: settings.copyWith(name: absolutePath),
      baseRouteUri: baseRouteUri,
      baseUrlPath: baseUrlPath,
      unknownRoute: unknownRoute,
    );
    if (pages.values.last.isPagesFound) {
      baseUrl = settings.name!.endsWith('/')
          ? pages.values.last.name!
          : pages.values.last.baseUrlPath;
    }
    return pages;
  }

  Map<String, RouteSettingsWithChildAndData> resolve({
    required Map<String, Widget Function(RouteData)> routes,
    required RouteSettings settings,
    String? baseUrlPath,
    String? baseRouteUri,
    Widget Function(String routeName)? unknownRoute,
  }) {
    RouteSettings s = settings;
    final matched = <String, RouteSettingsWithChildAndData>{};
    String? foundRoute;
    if (baseUrlPath != null && baseUrlPath != '/') {
      final newName = settings.name!.replaceFirst(baseUrlPath, '');
      s = settings.copyWith(
        name: newName.isEmpty ? '/' : newName,
      );
      // if (s.name!.isEmpty) {
      //   return matched;
      // }
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
        if (route != '/' || route == '/' && s.name == "/") {
          foundRoute = route;
        }
        Widget page = routes[route]!(routeData);
        if (page is RouteWidget) {
          final subSettings = routeData.urlPath;
          Map<String, RouteSettingsWithChildAndData> subRouteMatches = {};
          if (page.routes.isNotEmpty) {
            subRouteMatches = resolve(
              routes: page.routes,
              settings: settings.copyWith(name: Uri.parse(settings.name!).path),
              baseUrlPath: routeData.urlPath,
              baseRouteUri: routeData.routePath,
              unknownRoute: unknownRoute,
            );
            if (subRouteMatches.isEmpty) {
              continue;
            }
          }
          matched[subSettings] = RouteSettingsWithChildAndSubRoute(
            name: subSettings,
            routeUriPath: routeData.routePath,
            baseUrlPath: routeData.baseUrl,
            child: page,
            subRoute: page.routes.isNotEmpty
                ? subRouteMatches[subSettings]?.child ??
                    subRouteMatches.values.last.child
                : null,
            isBaseUrlChanged: routeData._isBaseUrlChanged,
            arguments: routeData.arguments,
            pathParams: routeData.pathParams,
            queryParams: routeData.queryParams,
            isPagesFound: _isPagesFound,
          );
          //Used to ensure keys are ordered
          subRouteMatches.forEach((key, value) {
            if (!matched.containsKey(key)) {
              matched[key] = value;
            }
          });
        } else {
          matched[routeData.urlPath] = RouteSettingsWithChildAndData(
            name: routeData.urlPath,
            routeUriPath: routeData.routePath,
            baseUrlPath: routeData.baseUrl,
            child: page,
            arguments: routeData.arguments,
            pathParams: routeData.pathParams,
            queryParams: routeData.queryParams,
            isPagesFound: _isPagesFound,
          );
        }
      }
    }
    if (foundRoute == null) {
      _isPagesFound = false;
      matched[settings.name!] = RouteSettingsWithChildAndData(
        name: settings.name!,
        baseUrlPath: settings.name!,
        routeUriPath: settings.name!,
        child: unknownRoute != null ? unknownRoute(settings.name!) : null,
        isPagesFound: false,
      );
    }
    return matched;
  }

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
      baseRouteUri ??= '/';
      return RouteData(
        baseUrl: baseUrlPath,
        urlPath: baseUrlPath,
        routePath: baseRouteUri,
        arguments: settings.arguments,
        queryParams: _queryParams,
        pathParams: _pathParams,
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
    _queryParams.addAll(pathUrl.queryParameters);
    _pathParams.addAll(params);
    final routeData = RouteData(
      baseUrl: baseUrlPath,
      urlPath: parsedPathUrl,
      routePath: parsedRouteUri,
      arguments: settings.arguments,
      queryParams: _queryParams,
      pathParams: _pathParams,
    );
    routeData._isBaseUrlChanged =
        baseUrlPath.isEmpty ? true : !baseUrlPath.startsWith(routeData.baseUrl);

    return routeData;
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
