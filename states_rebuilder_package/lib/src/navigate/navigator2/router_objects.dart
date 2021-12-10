part of '../../rm.dart';

abstract class RouterObjects {
  static const String root = '/RoOoT';
  static String? _initialRouteValue;
  static RouteInformationParserImp? routeInformationParser;
  static Map<Uri, Widget Function(RouteData routeData)>? _routers;
  // ignore: prefer_function_declarations_over_variables
  static Widget Function(RouteData data) _unknownRoute = (data) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${data.location} not found'),
          TextButton(
            onPressed: () => RM.navigate.back(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  };
  static bool _shouldUseCupertinoPage = false;
  static bool? isTransitionAnimated;
  static InjectedNavigatorImp? injectedNavigator;

  static Map<Uri, Widget Function(RouteData data)> transformRoutes(
      Map<String, Widget Function(RouteData data)> r) {
    return r.map((key, value) {
      assert(key.startsWith('/'));
      return MapEntry(Uri.parse(key), value);
    });
  }

  static void initialize({
    required Map<String, Widget Function(RouteData data)> routes,
    required Widget Function(RouteData data)? unknownRoute,
    required Widget Function(
            BuildContext, Animation<double>, Animation<double>, Widget)?
        transitionsBuilder,
    required Duration? transitionDuration,
    required Widget Function(Widget child)? builder,
    required String? initialRoute,
    required bool shouldUseCupertinoPage,
  }) {
    _dispose();
    _routers = transformRoutes(routes);
    _initialRouteValue = initialRoute;
    _unknownRoute = unknownRoute ?? _unknownRoute;
    _shouldUseCupertinoPage = shouldUseCupertinoPage;
    RM.navigate.transitionsBuilder = transitionsBuilder;

    rootDelegate = RouterDelegateImp(
      key: _navigate.navigatorKey,
      routes: _routers!,
      builder: builder != null
          ? (route) {
              final r = injectedNavigator?.routeData ??
                  RouteWidget.parentToSubRouteMessage.routeData;
              return SubRoute._(
                key: ValueKey(
                  r._subLocation,
                ),
                child: builder(route),
                route: route,
                routeData: r,
                animation: null,
                shouldAnimate: true,
                lastSubRoute: null,
                transitionsBuilder: transitionsBuilder,
              );
            }
          : null,
      resolvePathRouteUtil: _navigate._resolvePathRouteUtil,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: transitionDuration ?? _Navigate._transitionDuration,
      delegateName: 'rootDelegate',
      delegateImplyLeadingToParent: false,
    );
    routeInformationParser = RouteInformationParserImp(rootDelegate!);
  }

  static RouterDelegateImp? rootDelegate;
  static void clearStack() => rootDelegate?._pageSettingsList.clear();

  static List<RouterDelegateImp>? _activeSubRoutes(
      [RouterDelegateImp? untilDelegate]) {
    RouterDelegateImp? delegate = rootDelegate;
    if (delegate == null) {
      return null;
    }

    List<RouterDelegateImp> activeSubRoutes = [delegate];
    PageSettings? config = delegate._lastConfiguration;
    while (true) {
      if (config?.child is RouteWidget) {
        final d = (config!.child as RouteWidget)._nullableRouterDelegate;
        if (d == null) {
          break;
        }
        activeSubRoutes.add(d);
        if (d == untilDelegate) {
          break;
        }
        config = d._lastConfiguration;
      } else {
        break;
      }
    }
    return activeSubRoutes;
  }

  static RouterDelegateImp? _getNavigator2Delegate(String routeName) {
    final activeSubRoutes = _activeSubRoutes();
    return _getNavigator2Delegate2(activeSubRoutes, routeName);
  }

  static RouterDelegateImp? _getNavigator2Delegate2(
    List<RouterDelegateImp>? activeSubRoutes,
    String routeName,
  ) {
    if (activeSubRoutes == null) {
      return null;
    }
    RouterDelegateImp? delegate;
    for (final d in activeSubRoutes) {
      delegate ??= d;
      final name = d.delegateName;
      if (name == '/') {
        final canHandle = _ResolveLocation.canHandleLocation(
          routes: d._routes,
          routeName: name,
          location: routeName,
        );
        if (canHandle) {
          delegate = d;
        }
      } else if (routeName.startsWith(name)) {
        delegate = d;
      }
    }

    return delegate;
  }

  static bool _back<T extends Object?>(T? result, [RouterDelegateImp? d]) {
    final activeSubRoutes = _activeSubRoutes();
    if (activeSubRoutes == null) {
      return false;
    }

    bool? isDone = false;
    int index = activeSubRoutes.length - 1;
    while (true) {
      final delegate = activeSubRoutes[index];
      if (delegate._canPop && delegate == d) {
        isDone = false;
        break;
      }

      isDone = delegate._canPop;
      if (isDone) {
        delegate.navigatorKey!.currentState!.pop<T>(result);
        break;
      }

      if (isDone || --index < 0) {
        break;
      }
    }
    return isDone;
  }

  static bool canPop(RouterDelegateImp delegate) {
    final activeSubRoutes = _activeSubRoutes(delegate);
    if (activeSubRoutes == null || !activeSubRoutes.contains(delegate)) {
      return false;
    }

    bool? isDone = false;
    int index = activeSubRoutes.length - 1;
    while (true) {
      final delegate = activeSubRoutes[index];
      isDone = delegate._canPop;
      if (isDone || --index < 0) {
        break;
      }
    }
    return isDone;
  }

  static bool _backUntil(String untilRouteName) {
    final activeSubRoutes = RouterObjects._activeSubRoutes();
    if (activeSubRoutes == null) {
      return false;
    }

    bool isDone = false;

    int index = activeSubRoutes.length - 1;
    while (true) {
      final delegate = activeSubRoutes[index];
      isDone = delegate.backUntil(untilRouteName);
      if (isDone || --index < 0) {
        break;
      }
    }
    return isDone;
  }

  static void _dispose() {
    injectedNavigator?.dispose();
    injectedNavigator = null;
    ResolvePathRouteUtil.globalBaseUrl = '/';
  }
}

@immutable
class MaterialPageArgument {
  final Widget child;
  final bool maintainState;
  final bool fullscreenDialog;
  final LocalKey? key;
  final String? name;
  final Object? arguments;
  const MaterialPageArgument({
    required this.child,
    required this.maintainState,
    required this.fullscreenDialog,
    this.key,
    this.name,
    this.arguments,
  });
}
