part of '../rm.dart';

/// {@template RouteWidget}
/// Widget use to define sub routes or just for better organization or add custom
/// transition to a particular route.
///
/// For example let's take this routes
/// ```dart
///  final myNavigator = RM.injectNavigator(
///    routes: {
///      '/': (_) => HomePage(),
///      '/Page1': (_) => Page1(),
///      '/Page1/:id': (data) => Page1(id: data.pathParam['id']),
///      '/Page1/page12': (_) => Page12(),
///    },
///  );
/// ```
///
/// The above routes definition can be written like this:
///
/// ```dart
///  final myNavigator = RM.injectNavigator(
///    routes: {
///      '/': (_) => HomePage(),
///      '/Page1': (_) => RouteWidget(
///            routes: {
///              '/': (_) => Page1(),
///              '/:id': (data) => Page1(id: data.pathParam['id']),
///              '/page12': (_) => Page12(),
///            },
///          )
///    },
///  );
/// ```
///
/// You can also use the builder property to wrap the route outlet widget inside
/// an other widget.
///
/// ```dart
///  final myNavigator = RM.injectNavigator(
///    routes: {
///      '/': (_) => HomePage(),
///      '/Page1': (_) => RouteWidget(
///            // Inside widget tree, you can get the router outlet widget using
///            // `context.routerOutlet`
///            builder: (routeOutlet) {
///               // If you extract this Scaffold to a Widget class, you do not
///               // need to use the Builder widget
///              return Scaffold(
///                appBar: AppBar(
///                  title: OnReactive( // It reactive to routeData
///                    () => Builder( // Needed only to get a child BuildContext
///                      builder: (context) {
///                        final location = context.routeData.location;
///                        return Text('Routing to: $location');
///                      },
///                    ),
///                  ),
///                ),
///                body: routeOutlet,
///              );
///            },
///            routes: {
///              '/': (_) => Page1(),
///              '/:id': (data) => Page1(id: data.pathParam['id']),
///              '/page12': (_) => Page12(),
///            },
///          )
///    },
///  );
/// ```
///
/// Inside widget tree, you can get the router outlet widget using
/// `context.routerOutlet`
///
/// RouteWidget can be just used to add custom page transition animation.
///
/// In the following example Page1 will be animated using the custom definition,
/// whereas all other pages will use the default animation.
/// ```dart
///  final myNavigator = RM.injectNavigator(
///    // Default transition
///    transitionDuration: RM.transitions.leftToRight(),
///    routes: {
///      '/': (_) => HomePage(),
///      '/Page1': (_) => RouteWidget(
///            builder: (_) => Page1(),
///            // You can use one of the predefined transitions
///            transitionsBuilder: (context, animation, secondAnimation, child) {
///              // Custom transition implementation
///              return ...;
///            },
///          ),
///      '/page2': (_) => Page2(),
///    },
///  );
/// ```
///
/// See Also [RouteData] and [InjectedNavigator]
/// {@endtemplate}
class RouteWidget extends StatelessWidget {
  /// Used to wrap the the router outlet widget inside another widget.
  ///
  /// ```dart
  ///  final myNavigator = RM.injectNavigator(
  ///    routes: {
  ///      '/': (_) => HomePage(),
  ///      '/Page1': (_) => RouteWidget(
  ///            builder: (routeOutlet) {
  ///               // If you extract this Scaffold to a Widget class, you do not
  ///               // need to use the Builder widget
  ///              return Scaffold(
  ///                appBar: AppBar(
  ///                  title: OnReactive( // It reactive to routeData
  ///                    () => Builder( // Needed only to get a child BuildContext
  ///                      builder: (context) {
  ///                        final location = context.routeData.location;
  ///                        return Text('Routing to: $location');
  ///                      },
  ///                    ),
  ///                  ),
  ///                ),
  ///                body: routeOutlet,
  ///              );
  ///            },
  ///            routes: {
  ///              '/': (_) => Page1(),
  ///              '/:id': (data) => Page1(id: data.pathParam['id']),
  ///              '/page12': (_) => Page12(),
  ///            },
  ///          )
  ///    },
  ///  );
  /// ```
  ///
  final Widget Function(Widget routerOutlet)? builder;

  /// Define a transition builder to be used for the sub route.
  ///
  /// In the follwing example Page1 will be animated using the custom definition,
  /// whereas all other pages will use the default animation.
  /// ```dart
  ///  final myNavigator = RM.injectNavigator(
  ///    // Default transition
  ///    transitionDuration: RM.transitions.leftToRight(),
  ///    routes: {
  ///      '/': (_) => HomePage(),
  ///      '/Page1': (_) => RouteWidget(
  ///            builder: (_) => Page1(),
  ///            // You can use one of the predefined transitions
  ///            transitionsBuilder: (context, animation, secondAnimation, child) {
  ///              // Custom transition implementation
  ///              return ...;
  ///            },
  ///          ),
  ///      '/page2': (_) => Page2(),
  ///    },
  ///  );
  /// ```
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )? transitionsBuilder;
  final Duration? _transitionDuration;
  final bool? delegateImplyLeadingToParent;
  late final bool _delegateImplyLeadingToParent;

  /// {@macro RouteWidget}
  RouteWidget({
    this.builder,
    Map<String, Widget Function(RouteData data)> routes = const {},
    this.transitionsBuilder,
    this.delegateImplyLeadingToParent,
    Key? key,
  })  : assert(builder != null || routes.isNotEmpty),
        _parentToSubRouteMessage = RouteWidget.parentToSubRouteMessage,
        _routes = RouterObjects.transformRoutes(routes),
        _routeKeys = routes.keys.toList(),
        _hasBuilder = builder != null,
        _delegateImplyLeadingToParent =
            delegateImplyLeadingToParent ?? builder == null,
        _transitionDuration =
            transitionsBuilder != null ? _Navigate._transitionDuration : null,
        super(
          key: key ??
              Key(
                RouteWidget.parentToSubRouteMessage.signature,
              ),
        );

  RouteWidget._({
    this.builder,
    required Map<Uri, Widget Function(RouteData data)> routes,
    required List<String> routeKeys,
    this.transitionsBuilder,
    required bool canAnimateTransition,
    required this.delegateImplyLeadingToParent,
    required Duration? transitionDuration,
    required _ParentToSubRouteMessage message,
    Key? key,
  })  : assert(builder != null || routes.isNotEmpty),
        _parentToSubRouteMessage = message,
        _routes = routes,
        _routeKeys = routeKeys,
        _hasBuilder = canAnimateTransition,
        _delegateImplyLeadingToParent =
            delegateImplyLeadingToParent ?? !canAnimateTransition,
        _transitionDuration = transitionDuration,
        super(
          key: key ??
              Key(
                RouteWidget.parentToSubRouteMessage.signature,
              ),
        );

  final Map<Uri, Widget Function(RouteData data)> _routes;
  final List<String> _routeKeys;
  final _ParentToSubRouteMessage _parentToSubRouteMessage;
  final bool _hasBuilder;
  RouteWidget copyWith(Widget Function(Widget child)? builder) {
    return RouteWidget._(
      builder: builder,
      routes: _routes,
      routeKeys: _routeKeys,
      transitionsBuilder: transitionsBuilder,
      key: key,
      canAnimateTransition: _hasBuilder,
      delegateImplyLeadingToParent: delegateImplyLeadingToParent,
      transitionDuration: _transitionDuration,
      message: _parentToSubRouteMessage,
    );
  }

  late final Widget route;
  late final _routeDataList =
      List.from({_parentToSubRouteMessage.routeData}, growable: false);
  final isInitialized = List.from({null}, growable: false);
  RouteData get _routeData => _routeDataList.first;
  late final String _path = _parentToSubRouteMessage.toPath;
  late final String urlName = _routeData._subLocation;
  late final String routeName = _routeData.path;
  late final routePathResolver = ResolvePathRouteUtil(
    urlName: urlName,
    routeName: routeName,
  );
  // Navigator 2
  late final RouterDelegateImp _routerDelegate;
  RouterDelegateImp? get _nullableRouterDelegate {
    if (_routes.isEmpty) {
      return null;
    }
    return _routerDelegate;
  }

  late final RouteInformationParserImp _routeInformationParser;
  Map<String, RouteSettingsWithChildAndData>? initialize() {
    routePathResolver._initialPathParams.addAll(_routeData.pathParams);

    if (_routes.isEmpty) {
      route = routeNotDefinedAssertion;
      return null;
    }

    bool isNavigator2 = RouterObjects.rootDelegate != null;

    if (isNavigator2) {
      final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
      Map<String, RouteSettingsWithChildAndData>? pages;
      final transition = transitionsBuilder ?? RM.navigate.transitionsBuilder;
      _routerDelegate = RouterDelegateImp(
        delegateName: _routeData._subLocation,
        key: key,
        builder: builder != null
            ? (route) {
                final r = RouterObjects.injectedNavigator!.routeData;
                return SubRoute._(
                  key: ValueKey(r._subLocation),
                  child: builder!(route),
                  route: route,
                  routeData: r,
                  animation: null,
                  shouldAnimate: true,
                  lastSubRoute: null,
                  transitionsBuilder: transition,
                );
              }
            : null,
        routes: _routes,
        resolvePathRouteUtil: routePathResolver,
        hasBuilder: _hasBuilder,
        transitionsBuilder: transition,
        transitionDuration: _Navigate._transitionDuration ??
            RouterObjects.rootDelegate!.transitionDuration,
        delegateImplyLeadingToParent: _delegateImplyLeadingToParent,
      );
      isInitialized[0] = true;
      _routeInformationParser =
          RouteInformationParserImp(_routerDelegate, (p) => pages = p);
      _routeInformationParser.parseRouteInformation(
        RouteInformation(location: _path, state: {
          'routeData': _routeData,
          'skipHomeSlash': _parentToSubRouteMessage.skipHomeSlash,
          'queryParams': _parentToSubRouteMessage.queryParams
        }),
      );
      if (pages == null) {
        return null;
      }
      final c = pages!.values.last.child;
      _routeDataList[0] = pages!.values.last.routeData;
      if (c is! RouteWidget ||
          c._path == _path ||
          routeName == '/' && c.routeName != routeName) {
        route = c!;
        return {};
      } else {
        return pages;
      }
    } else {
      _resolve();
      return {};
    }
  }

  Map<String, RouteSettingsWithChildAndData>? _resolve() {
    if (_routes.isEmpty) {
      route = routeNotDefinedAssertion;
    }

    final pages = routePathResolver.getPagesFromRouteSettings(
      routes: _routes,
      settings: RouteSettings(
        name: _path,
        arguments: _routeData.arguments,
      ),
      queryParams: _parentToSubRouteMessage.queryParams,
      skipHomeSlash: _parentToSubRouteMessage.skipHomeSlash,
      unknownRoute: _parentToSubRouteMessage.unknownRoute != null
          ? (_) => _parentToSubRouteMessage.unknownRoute!(_path)
          : null,
    );

    if (pages != null) {
      route = getWidgetFromPages(pages: pages);
    }
    return pages;
  }

  PageSettings? _getLeafConfig() {
    if (isInitialized.first == null) {
      return null;
    }

    PageSettings config = _routerDelegate._lastConfiguration!;
    while (true) {
      if (config.child is RouteWidget) {
        final d = (config.child as RouteWidget)._nullableRouterDelegate;
        if (d == null) {
          break;
        }
        config = d._lastConfiguration!;
      } else {
        break;
      }
    }
    return config;
  }

  @override
  String toString({DiagnosticLevel? minLevel}) {
    String str = '';
    try {
      for (final p in _routerDelegate._pageSettingsList) {
        final l = p.rData!._subLocation;
        final c = p.child;
        str += '\t($l)=>${c is SubRoute ? c.child : c}\n';
      }
    } catch (e) {
      return 'RouteWidget[$routeName](${_routeData._subLocation})';
    }
    return '\nRouteWidget[$routeName](\n$str)\n';
  }

  // late final routePathResolver = ResolvePathRouteUtil(
  //   urlName: urlName,
  //   routeName: routeName,
  // );
  // late Widget route;
  static late _ParentToSubRouteMessage parentToSubRouteMessage;

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      if (_routes.isEmpty) {
        if (urlName != _path) {
          final route = _parentToSubRouteMessage.unknownRoute?.call(_path) ??
              routeNotDefinedAssertion;
          return route;
        }
        return builder!(routeNotDefinedAssertion);
      }
      final isNavigator2 = RouterObjects.rootDelegate != null;

      if (isNavigator2) {
        return Router(
          key: ValueKey(urlName + _path),
          routerDelegate: _routerDelegate,
          routeInformationParser: _routeInformationParser,
        );
      }

      return SubRoute._(
        child: builder!(route),
        route: route,
        lastSubRoute: null,
        routeData: _routeData,
        animation: null,
        transitionsBuilder: transitionsBuilder,
        shouldAnimate: true,
        key: Key(urlName),
      );
    }
    throw UnimplementedError();
  }
}

class _ParentToSubRouteMessage {
  final String toPath;
  final RouteData routeData;
  final bool skipHomeSlash;
  final Widget Function(String route)? unknownRoute;
  final Map<String, String> queryParams;
  String get signature => '$toPath${routeData.arguments}$queryParams';
  _ParentToSubRouteMessage({
    required this.toPath,
    required this.routeData,
    required this.skipHomeSlash,
    required this.unknownRoute,
    required this.queryParams,
  });
}
