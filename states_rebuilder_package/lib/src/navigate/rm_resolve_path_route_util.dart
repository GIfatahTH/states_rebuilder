part of '../rm.dart';

class ResolvePathRouteUtil {
  ResolvePathRouteUtil({
    this.urlName = '/',
    this.routeName = '/',
  });
  final String urlName;
  final String routeName;
  String absolutePath = '';
  static String globalBaseUrl = '/';

  String globalBaseRouteUri = '/';
  List<String> remainingUrlSegments = [];
  bool _isPagesFound = true;

  final Map<String, String> _pathParams = {};
  final Map<String, String> _initialPathParams = {};
  void _resetFields() {
    _pathParams
      ..clear()
      ..addAll(_initialPathParams);
    absolutePath = '';
    remainingUrlSegments = [];
    _isPagesFound = true;
  }

  String setAbsoluteUrlPath(String name) {
    late String absolutePath;
    _resetFields();
    if (name.startsWith('/')) {
      absolutePath = name;
    } else {
      if (globalBaseUrl == '/' || globalBaseUrl.isEmpty) {
        absolutePath = '/' + name;
      } else {
        String relativeBasePath = _getBaseUrl('/' + name);
        String? p;
        while (relativeBasePath.isNotEmpty) {
          // add '/' to ensure the route name and not a stirng containing the name
          final r = (globalBaseUrl + '/').split(relativeBasePath + '/');
          if (r.length > 1) {
            r.removeLast();
            p = r.join('/');
          }
          if (p != null) {
            break;
          }
          relativeBasePath = _getBaseUrl(relativeBasePath);
          if (relativeBasePath == '/') {
            break;
          }
        }

        absolutePath = (p ?? globalBaseUrl) + '/' + name;
      }
    }
    return this.absolutePath = absolutePath;
  }

  static Map<Uri, Widget Function(RouteData)>? inRoutes;
  static String? inRouteName;
  Map<String, RouteSettingsWithChildAndData>? getPagesFromRouteSettings({
    required Map<Uri, Widget Function(RouteData)> routes,
    required RouteSettings settings,
    Map<String, String> queryParams = const {},
    Widget Function(String routeName)? unknownRoute,
    bool skipHomeSlash = false,
    List<String> redirectedFrom = const [],
  }) {
    final absolutePath = setAbsoluteUrlPath(settings.name!);
    final uri = Uri.parse(absolutePath);
    assert(uri.path.isNotEmpty);
    final queryParameters =
        uri.queryParameters.isNotEmpty ? uri.queryParameters : queryParams;
    final arguments = settings.arguments;

    remainingUrlSegments = [...uri.pathSegments];
    for (final e in urlName.split('/')) {
      remainingUrlSegments.remove(e);
    }
    inRoutes ??= routes;
    inRouteName ??= routeName;
    final pages = _ResolveLocation(
      routes: routes,
      path: uri.path,
      arguments: arguments,
      queryParams: queryParameters,
      pathParam: _pathParams,
      baseUrlPath: urlName,
      routeUri: routeName,
      unknownRoute: unknownRoute,
      skipHomeSlash: skipHomeSlash,
      isAbsolutePath: settings.name!.startsWith('/'),
      redirectedFrom: redirectedFrom,
      util: this,
    ).call();
    inRoutes = null;
    inRouteName = null;
    if (pages == null) {
      return null;
    }

    if (pages.values.last.isPagesFound) {
      if (remainingUrlSegments.any((e) => e.isNotEmpty)) {
        _isPagesFound = false;
        pages[absolutePath] = RouteSettingsWithChildAndData(
          routeData: RouteData(
            location: absolutePath,
            path: absolutePath,
            arguments: null,
            pathParams: {},
            queryParams: {},
            pathEndsWithSlash: false,
            redirectedFrom: [],
          ),
          child: unknownRoute != null ? unknownRoute(absolutePath) : null,
          isPagesFound: false,
        );
        StatesRebuilerLogger.log('Page "$absolutePath" is not found');
      }
    }
    return pages;
  }
}

String _getBaseUrl(String path, [String? routeUri]) {
  final segments = path.split('/');
  segments.removeLast();
  if (segments.length < 2) {
    return '/';
  }
  if (routeUri != null) {
    final routeList = routeUri.split('/');
    if (routeList[routeList.length - 1].startsWith(':') &&
        !routeList[routeList.length - 2].startsWith(':')) {
      segments.removeLast();
      if (segments.length < 2) {
        return '/';
      }
    }
  }
  return segments.join('/');
}

class _ResolveLocation {
  final Map<Uri, Widget Function(RouteData)> routes;
  final String path;
  final Object? arguments;
  final Map<String, String> queryParams;
  final Map<String, String> pathParam;
  final String baseUrlPath;
  final String routeUri;
  final Widget Function(String routeName)? unknownRoute;
  final bool skipHomeSlash;
  final bool isAbsolutePath;
  final List<String> redirectedFrom;
  final ResolvePathRouteUtil util;
  _ResolveLocation({
    required this.routes,
    required this.path,
    required this.arguments,
    required this.queryParams,
    required this.pathParam,
    required this.baseUrlPath,
    required this.routeUri,
    required this.unknownRoute,
    required this.skipHomeSlash,
    required this.isAbsolutePath,
    required this.redirectedFrom,
    required this.util,
  });

  late String subPath;
  final matched = <String, RouteSettingsWithChildAndData>{};
  bool isRouteNotFound = true;
  bool isInfiniteRedirectLoop = false;

  Map<String, RouteSettingsWithChildAndData>? call({
    Map<Uri, Widget Function(RouteData)>? routes,
    String? path,
    String? baseUrlPath,
    String? routeUri,
    bool? skipHomeSlash,
    Map<String, String>? queryParams,
  }) {
    routes = routes ?? this.routes;
    path = path ?? this.path;
    baseUrlPath = baseUrlPath ?? this.baseUrlPath;
    routeUri = routeUri ?? this.routeUri;
    skipHomeSlash = skipHomeSlash ?? this.skipHomeSlash;
    queryParams = queryParams ?? this.queryParams;
    subPath = path;
    if (baseUrlPath != '/') {
      final newName = path.replaceFirst(baseUrlPath, '');
      subPath = newName.isEmpty ? '/' : newName;
    }
    final pathUrl = Uri.parse(subPath);
    var results = getLocation(
      routes: routes,
      pathUrl: pathUrl,
      baseUrlPath: baseUrlPath,
      routeUri: routeUri,
      queryParams: queryParams,
    );

    if (results.isEmpty) {
      if (isRouteNotFound) {
        util._isPagesFound = false;
        String message = '';
        if (isInfiniteRedirectLoop) {
          message = 'Infinite redirect loop: ';
        }
        matched[path] = RouteSettingsWithChildAndData(
          routeData: RouteData(
            location: path,
            path: path,
            arguments: null,
            pathParams: {},
            queryParams: {},
            pathEndsWithSlash: false,
            redirectedFrom: [],
          ),
          child: unknownRoute != null ? unknownRoute!('$message$path') : null,
          isPagesFound: false,
        );
        assert(() {
          StatesRebuilerLogger.log(
            '${message}Page "${util.absolutePath}" is not found',
          );
          return true;
        }());
      }
      return matched;
    }

    if (results.length > 1 && skipHomeSlash) {
      final route = results.keys.last;
      results = {
        route: results[route]!,
      };
    }

    Map<String, RouteSettingsWithChildAndData>? fn(
      Uri route,
      RouteData routeData,
    ) {
      final matched = <String, RouteSettingsWithChildAndData>{};
      _RouteWidgetState.parentToSubRouteMessage = _ParentToSubRouteMessage(
        toPath: path!,
        routeData: routeData,
        skipHomeSlash: skipHomeSlash!,
        unknownRoute: unknownRoute,
        queryParams: queryParams!,
      );
      RouterObjects.injectedNavigator?.routeData = routeData;

      Widget? page;
      page = RouterObjects.injectedNavigator?.redirectTo?.call(routeData);

      if (page is Redirect) {
        if (page.to == null) {
          return null;
        }
        final resolvedMatch = _resolveRedirect(
          route: route,
          to: page.to!,
          routeRedirectedFrom: routeData.location,
        );
        if (resolvedMatch != null) {
          matched.addAll(resolvedMatch);
        }
        return matched;
      }

      if (page == null) {
        page = routes![route]!(routeData);
        if (route.path != '/') {
          if (routeData._pathEndsWithSlash &&
              util.remainingUrlSegments.isEmpty) {
            if (page is! RouteWidget) {
              RouterObjects.injectedNavigator?.routeData = routeData;
              page = routes[route]!(
                  routeData = routeData.copyWith(pathEndsWithSlash: false));
            } else if (!page._routeKeys.contains('/')) {
              RouterObjects.injectedNavigator?.routeData = routeData;
              page = routes[route]!(
                  routeData = routeData.copyWith(pathEndsWithSlash: false));
            }
          }
        }
        if (page is Redirect) {
          final to = page.to;
          if (to == null) {
            return null;
          }
          final resolvedMatch = _resolveRedirect(
            route: route,
            to: page.to!,
            routeRedirectedFrom: routeData.location,
          );
          if (resolvedMatch != null) {
            matched.addAll(resolvedMatch);
          }
          return matched;
        }
      }
      if (page is RouteWidget) {
        if (page.builder == null) {
          page = page.copyWith((_) => _);
        }
        final pages = page.initialize();
        if (pages == null && page._routes.isNotEmpty) {
          return null;
        }

        if (pages?.isNotEmpty == true) {
          matched.addAll(pages!);
        } else {
          matched[routeData.location] = RouteSettingsWithRouteWidget(
            routeData: routeData,
            child: page,
            isPagesFound: util._isPagesFound,
          );
        }

        util.remainingUrlSegments = [];
      } else {
        ResolvePathRouteUtil.globalBaseUrl = routeData.baseLocation;
        util.globalBaseRouteUri = routeData.path;
        matched[routeData.location] = RouteSettingsWithChildAndData(
          routeData: routeData,
          child: page,
          isPagesFound: util._isPagesFound,
        );
      }

      return matched;
    }

    Map<String, RouteSettingsWithChildAndData> m = {};
    results.forEach((route, routeData) {
      final r = fn(route, routeData);
      if (redirectedFrom.isNotEmpty) {
        redirectedFrom.clear();
      }
      if (r != null) {
        r.forEach((key, value) {
          m.remove(key);
          m[key] = value;
        });
      }
    });
    return m.isNotEmpty ? m : null;
  }

  Map<Uri, RouteData> getLocation({
    required Map<Uri, Widget Function(RouteData)> routes,
    required Uri pathUrl,
    required String baseUrlPath,
    required String routeUri,
    required Map<String, String> queryParams,
  }) {
    var results = <Uri, RouteData>{};

    for (final route in routes.keys) {
      final routeData = _getRouteData(
        route: route,
        routeUriSegments: route.pathSegments,
        pathUrl: pathUrl,
        pathEndsWithSlash: path.endsWith('/'),
        baseUrlPath: baseUrlPath,
        routeUri: routeUri,
        queryParams: queryParams,
      );

      if (routeData != null) {
        if (redirectedFrom.isNotEmpty) {
          String toAppend = route.path == '/'
              ? routes == RouterObjects._routers
                  ? ''
                  : '/'
              : '';

          if (toAppend == '/' && routes == RouterObjects._routers) {
            toAppend = '';
          }
          if (redirectedFrom.contains(routeData.location + toAppend)) {
            isInfiniteRedirectLoop = true;
            continue;
          }
        }

        if (route.pathSegments.isEmpty && pathUrl.pathSegments.isNotEmpty) {
          if (skipHomeSlash && routes.length > 1) {
            Widget? page = routes[route]!(routeData);
            if (page is! RouteWidget) {
              continue;
            }
            final _canHandleLocation = canHandleLocation(
              routes: page._routes,
              routeName: util.routeName,
              uri: pathUrl,
            );
            if (!_canHandleLocation) {
              continue;
            }
          }
        }

        results[route] = routeData;
        if (subPath == routeData.location) {
          break;
        }
      }
    }
    return results;
  }

  Map<String, RouteSettingsWithChildAndData>? _resolveRedirect({
    required Uri route,
    required String to,
    required String routeRedirectedFrom,
  }) {
    final toAppend = route.path == '/'
        ? routes == RouterObjects._routers
            ? ''
            : '/'
        : '';

    if (queryParams.isEmpty) {
      // assert(!redirectedFrom.contains(path));
      redirectedFrom.add(routeRedirectedFrom + toAppend);
    } else {
      final uri = Uri(
        path: routeRedirectedFrom,
        queryParameters: queryParams,
      );
      // assert(!redirectedFrom.contains(path));
      redirectedFrom.add('$uri$toAppend');
    }

    final absolutePath = util.setAbsoluteUrlPath(to);
    final uri = Uri.parse(absolutePath);
    assert(uri.path.isNotEmpty);
    var r = RouterObjects._routers!;
    var inRouteName = ResolvePathRouteUtil.inRouteName;
    bool _canHandleLocation = canHandleLocation(
      routes: routes,
      routeName: util.routeName,
      uri: uri,
    );

    if (_canHandleLocation) {
      r = routes;
      inRouteName = null;
    } else if (routes != ResolvePathRouteUtil.inRoutes &&
        r != ResolvePathRouteUtil.inRoutes) {
      _canHandleLocation = canHandleLocation(
        routes: ResolvePathRouteUtil.inRoutes!,
        routeName: util.routeName,
        uri: uri,
      );

      if (_canHandleLocation) {
        r = ResolvePathRouteUtil.inRoutes!;
      }
    }

    return call(
      routes: r,
      path: uri.path,
      baseUrlPath: _canHandleLocation ? inRouteName ?? baseUrlPath : '/',
      routeUri: _canHandleLocation ? routeUri : '/',
      skipHomeSlash: true,
      queryParams: uri.queryParameters,
    );
  }

  RouteData? _getRouteData({
    required Uri route,
    required List<String> routeUriSegments,
    required Uri pathUrl,
    required bool pathEndsWithSlash,
    required String baseUrlPath,
    required String routeUri,
    required Map<String, String> queryParams,
  }) {
    final pathUrlSegments = pathUrl.pathSegments;

    if (routeUriSegments.length > pathUrlSegments.length) {
      return null;
    }
    final bool addQueryParam =
        pathUrlSegments.length > 1 && pathUrlSegments.last == ""
            ? routeUriSegments.length + 1 == pathUrlSegments.length
            : routeUriSegments.length == pathUrlSegments.length;
    if (routeUriSegments.isEmpty) {
      return RouteData(
        pathEndsWithSlash:
            util.remainingUrlSegments.isNotEmpty || pathEndsWithSlash,
        location: baseUrlPath,
        path: routeUri,
        arguments: arguments,
        queryParams: addQueryParam ? {...queryParams} : const {},
        pathParams: {...pathParam},
        redirectedFrom: [...redirectedFrom],
      );
    }

    Map<String, String> params = {};

    String parsedPathUrl = baseUrlPath.length > 1 ? baseUrlPath : '';
    String parsedRouteUri = routeUri.length > 1 ? routeUri : '';

    for (var i = 0; i < routeUriSegments.length; i++) {
      if (routeUriSegments[i].startsWith(':')) {
        final _parameterRegExp = RegExp(r':(\w+)(\(.+\))?');
        final match = _parameterRegExp.firstMatch(routeUriSegments[i]);
        if (match == null) {
          throw '"${routeUriSegments[i]}" is invalid path';
        }
        final paramName = match[1]!;
        final optionalPattern = match[2];
        if (optionalPattern == null) {
          params[paramName] = pathUrlSegments[i];
        } else {
          try {
            final r =
                RegExp(optionalPattern).firstMatch(pathUrlSegments[i])?[0];
            if (r == null) {
              return null;
            }
            params[paramName] = r;
          } catch (e) {
            return null;
          }
        }
      } else if (routeUriSegments[i] != pathUrlSegments[i]) {
        return null;
      }

      parsedRouteUri += '/${routeUriSegments[i]}';
      parsedPathUrl += '/${pathUrlSegments[i]}';
      util.remainingUrlSegments.remove(pathUrlSegments[i]);
    }
    pathParam.addAll(params);

    return RouteData(
      location: parsedPathUrl,
      pathEndsWithSlash:
          util.remainingUrlSegments.isNotEmpty || pathEndsWithSlash,
      path: parsedRouteUri,
      arguments: arguments,
      queryParams: addQueryParam ? {...queryParams} : const {},
      pathParams: {...pathParam},
      redirectedFrom: [...redirectedFrom],
    );
  }

  static bool canHandleLocation({
    required Map<Uri, Widget Function(RouteData)> routes,
    required String routeName,
    Uri? uri,
    String? location,
  }) {
    List<String> pathUrlSegments =
        uri?.pathSegments ?? Uri.parse(routeName).pathSegments;
    location ??= uri?.path;
    if (routeName != '/') {
      final newName = location!.replaceFirst(routeName, '');
      location = newName.isEmpty ? '/' : newName;
    }
    bool hasLocation = false;
    for (var route in routes.keys) {
      if (route.path == location) {
        hasLocation = true;
        break;
      }
      final routeUriSegments = route.pathSegments;
      if (routeUriSegments.length > pathUrlSegments.length) {
        hasLocation = false;
        continue;
      }

      for (var i = 0; i < routeUriSegments.length; i++) {
        if (routeUriSegments[i].startsWith(':')) {
          final _parameterRegExp = RegExp(r':(\w+)(\(.+\))?');
          final match = _parameterRegExp.firstMatch(routeUriSegments[i]);
          if (match == null) {
            hasLocation = false;
            continue;
          }
          final optionalPattern = match[2];
          if (optionalPattern != null) {
            try {
              final r =
                  RegExp(optionalPattern).firstMatch(pathUrlSegments[i])?[0];
              if (r == null) {
                hasLocation = false;
                continue;
              }
            } catch (e) {
              hasLocation = false;
              continue;
            }
          }
        } else if (routeUriSegments[i] != pathUrlSegments[i]) {
          break;
        }
        hasLocation = true;
        break;
      }
      if (hasLocation) {
        break;
      }
    }
    return hasLocation;
  }
}
