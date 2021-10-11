part of '../rm.dart';

class ResolvePathRouteUtil {
  late Map<String, Widget Function(RouteData data)> _routes =
      RouterObjects._routers!;
  final Map<String, _RouteData> _routeData = {};
  RouteData? routeData;
  String absolutePath = '';
  String baseUrl = '/';
  String baseRouteUri = '/';
  String remainingUrlPathToResolve = '';

  bool _isPagesFound = true;
  final Map<String, String> _pathParams = {};
  void _resetFields() {
    _routeData.clear();
    routeData = null;
    _pathParams.clear();
    absolutePath = '';
    remainingUrlPathToResolve = '';
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
    // String baseUrlPath = '/',
    // String? baseRouteUri,
    Widget Function(String routeName)? unknownRoute,
    bool skipHomeSlash = false,
  }) {
    final absolutePath = setAbsoluteUrlPath(settings);
    final uri = Uri.parse(absolutePath);
    assert(uri.path.isNotEmpty);
    final queryParameters = uri.queryParameters;
    final arguments = settings.arguments;
    remainingUrlPathToResolve = absolutePath;
    final pages = resolve(
      routes: routes,
      // settings: settings.copyWith(name: absolutePath),
      path: absolutePath,
      arguments: arguments,
      queryParameters: queryParameters,
      baseRouteUri: '/',
      baseUrlPath: '/',
      unknownRoute: unknownRoute,
      skipHomeSlash: skipHomeSlash,
    );

    if (pages.values.last.isPagesFound) {
      if (Uri.parse(remainingUrlPathToResolve).pathSegments.isNotEmpty) {
        _isPagesFound = false;
        pages[absolutePath] = RouteSettingsWithChildAndData(
          name: absolutePath,
          baseUrlPath: absolutePath,
          routeUriPath: absolutePath,
          child: unknownRoute != null ? unknownRoute(absolutePath) : null,
          isPagesFound: false,
        );
        StatesRebuilerLogger.log('Page "$absolutePath" is not found');
      }
      baseUrl = settings.name!.endsWith('/')
          ? pages.values.last.name!
          : pages.values.last.baseUrlPath;
      baseRouteUri = pages.values.last.routeUriPath;
    }
    cachedPages = pages;
    return pages;
  }

  Map<String, RouteSettingsWithChildAndData> cachedPages = {};

  Map<String, RouteSettingsWithChildAndData> resolve({
    required Map<String, Widget Function(RouteData)> routes,
    // required RouteSettings settings,
    required String path,
    required Object? arguments,
    required Map<String, String> queryParameters,
    String baseUrlPath = '/',
    String baseRouteUri = '/',
    Widget Function(String routeName)? unknownRoute,
    bool skipHomeSlash = false,
  }) {
    String subPath = path;
    final matched = <String, RouteSettingsWithChildAndData>{};

    bool isRouteNotFound = true;
    if (baseUrlPath != '/') {
      final newName = path.replaceFirst(baseUrlPath, '');
      subPath = newName.isEmpty ? '/' : newName;
      // if (s.name!.isEmpty) {
      //   return matched;
      // }
    }

    for (final route in routes.keys) {
      // assert(route.startsWith('/'));
      if (skipHomeSlash) {
        if (route == '/' && subPath != '/') {
          continue;
        }
      }
      final routeUriSegments = Uri.parse(route).pathSegments;
      RouteData? routeData;

      routeData = _getRouteData(
        routeUriSegments: routeUriSegments,
        pathUrl: subPath,
        arguments: arguments,
        queryParameters: queryParameters,
        baseUrlPath: baseUrlPath,
        baseRouteUri: baseRouteUri == '/' ? '/' : _getBaseUrl(baseRouteUri),
      );

      if (routeData != null) {
        // if (skipHomeSlash) {
        //   if (routeData.urlPath == '/' && path != '/' ||
        //       !path.startsWith(routeData.urlPath)) {
        //     // isRouteNotFound = false;
        //     continue;
        //   }
        // }
        Widget? page;

        isRouteNotFound = false;

        page ??= routes[route]!(routeData);
        if (page is RouteWidget) {
          final subSettings = routeData.urlPath;
          Map<String, RouteSettingsWithChildAndData> subRouteMatches = {};
          if (page.routes.isNotEmpty) {
            final pathsAreEqual =
                path.replaceFirst(routeData.urlPath, '').replaceAll('/', '');
            subRouteMatches = resolve(
              routes: skipHomeSlash && pathsAreEqual.isNotEmpty
                  ? () {
                      final r = {...(page as RouteWidget).routes};
                      r.remove('/');
                      return r;
                    }()
                  : page.routes,
              path: path,
              arguments: arguments,
              queryParameters: queryParameters,
              baseUrlPath: routeData.urlPath,
              baseRouteUri: routeData.routePath,
              unknownRoute: unknownRoute,
              skipHomeSlash: skipHomeSlash,
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
                ? () {
                    final r = subRouteMatches[subSettings];
                    return r?.child ?? subRouteMatches.values.last.child;
                  }()
                : null,
            isBaseUrlChanged: false,
            arguments: routeData.arguments,
            pathParams: routeData.pathParams,
            queryParams: routeData.queryParams,
            isPagesFound: _isPagesFound,
          );

          // Used to ensure keys are ordered
          subRouteMatches.forEach((key, value) {
            // add value if not already exists
            // and override the value if page not found (used to ensure
            // RouteSettingsWithChildAndData is used instead of
            // RouteSettingsWithChildAndSubRoute)
            if (!value.isPagesFound) {
              matched[key] = value;
            } else {
              if (!matched.containsKey(key)) {
                matched[key] = value;
              } else {
                final m = matched[key];
                if (m is RouteSettingsWithChildAndSubRoute &&
                    (m.child as RouteWidget).builder != null) {
                  if (m.subRoute is RouteWidget) {
                    matched['$key*'] = value;
                  }
                }
              }
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
            isBaseUrlChanged: true,
          );
        }
      }
    }

    if (isRouteNotFound) {
      _isPagesFound = false;
      matched[path] = RouteSettingsWithChildAndData(
        name: path,
        baseUrlPath: path,
        routeUriPath: path,
        child: unknownRoute != null ? unknownRoute(path) : null,
        isPagesFound: false,
      );
      StatesRebuilerLogger.log('Page "$absolutePath" is not found');
    }
    return matched;
  }

  RouteData? _getRouteData({
    required List<String> routeUriSegments,
    required String pathUrl,
    required Object? arguments,
    required Map<String, String> queryParameters,
    required String baseUrlPath,
    required String baseRouteUri,
  }) {
    final pathUrlSegments = Uri.parse(pathUrl).pathSegments;
    if (routeUriSegments.length > pathUrlSegments.length) {
      return null;
    }
    if (routeUriSegments.isEmpty) {
      return RouteData(
        baseUrl: baseUrlPath,
        urlPath: baseUrlPath,
        routePath: baseRouteUri,
        arguments: arguments,
        queryParams: queryParameters,
        pathParams: _pathParams,
      );
    }
    Map<String, String> params = {};

    String parsedPathUrl = baseUrlPath.length > 1 ? baseUrlPath : '';
    String parsedRouteUri = baseRouteUri.length > 1 ? baseRouteUri : '';

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
      remainingUrlPathToResolve =
          remainingUrlPathToResolve.replaceFirst('/${pathUrlSegments[i]}', '');
    }
    _pathParams.addAll(params);

    final routeData = RouteData(
      baseUrl: baseUrlPath,
      urlPath: parsedPathUrl,
      routePath: parsedRouteUri,
      arguments: arguments,
      queryParams: queryParameters,
      pathParams: _pathParams,
    );
    final p = routeData.baseUrl == '/'
        ? routeData.urlPath
        : routeData.baseUrl + routeData.urlPath;
    // if (cachedPages.containsKey(routeData.urlPath)) {
    //   routeData._isBaseUrlChanged = false;
    // } else {
    //   routeData._isBaseUrlChanged = true;
    // }
    //  !baseUrlPath.startsWith(routeData.baseUrl);

    return routeData;
  }
}

String _getBaseUrl(String path) {
  final segments = path.split('/');
  segments.removeLast();
  return segments.join('/');
}
