part of '../../rm.dart';

abstract class RouterObjects {
  static const String rootName = '/RoOoTName';
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
      delegateName: rootName,
      delegateImplyLeadingToParent: false,
    );
    RouterDelegateImp._completers.clear();
    routeInformationParser = RouteInformationParserImp(rootDelegate!);
  }

  static RouterDelegateImp? rootDelegate;
  static void clearStack() => rootDelegate?._pageSettingsList.clear();

  static List<RouterDelegateImp>? getActiveSubRoutes(
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
    final activeSubRoutes = getActiveSubRoutes();
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
      } else if (routeName.startsWith(name + '/')) {
        delegate = d;
      }
    }

    return delegate;
  }

  static void removePage<T extends Object?>({
    required String routeName,
    required List<RouterDelegateImp>? activeSubRoutes,
    T? result,
  }) {
    if (activeSubRoutes == null) {
      return;
    }
    RouterDelegateImp? delegate;
    int index = activeSubRoutes.length - 1;
    while (true) {
      delegate = activeSubRoutes[index];

      if (delegate._pageSettingsList.any((e) => e.name == routeName)) {
        break;
      }

      if (--index < 0) {
        break;
      }
    }
    delegate.remove(routeName, result);
  }

  static RouterDelegateImp? _toBack(RouterDelegateImp? d) {
    final activeSubRoutes = getActiveSubRoutes();
    if (activeSubRoutes == null) {
      return null;
    }
    RouterDelegateImp? delegate;
    int index = activeSubRoutes.length - 1;
    while (true) {
      delegate = activeSubRoutes[index];
      if (delegate._canPop && delegate == d) {
        break;
      }

      if (delegate._canPop) {
        break;
      }

      if (--index < 0) {
        break;
      }
    }
    return delegate;
  }

  static bool _back<T extends Object?>(T? result, [RouterDelegateImp? d]) {
    final delegate = _toBack(d);
    if (delegate == null || delegate == d) {
      return false;
    }
    delegate.navigatorKey!.currentState!.pop<T>(result);
    return true;
    // final activeSubRoutes = _activeSubRoutes();
    // if (activeSubRoutes == null) {
    //   return false;
    // }

    // bool? isDone = false;
    // int index = activeSubRoutes.length - 1;
    // while (true) {
    //   final delegate = activeSubRoutes[index];
    //   if (delegate._canPop && delegate == d) {
    //     isDone = false;
    //     break;
    //   }

    //   isDone = delegate._canPop;
    //   if (isDone) {
    //     delegate.navigatorKey!.currentState!.pop<T>(result);
    //     break;
    //   }

    //   if (isDone || --index < 0) {
    //     break;
    //   }
    // }
    // return isDone;
  }

  static RouterDelegateImp? getDelegateToPop([
    RouterDelegateImp? delegate,
    String? untilRouteName,
  ]) {
    final activeSubRoutes = getActiveSubRoutes(delegate);
    if (activeSubRoutes == null ||
        delegate != null && !activeSubRoutes.contains(delegate)) {
      return null;
    }

    int index = activeSubRoutes.length - 1;
    while (true) {
      final delegate = activeSubRoutes[index];
      final canPop = untilRouteName == null
          ? delegate._canPop
          : delegate._canPopUntil(untilRouteName);
      if (canPop) {
        return delegate;
      }
      if (--index < 0) {
        return null;
      }
    }
  }

  static String trimLastSlash(String name) {
    if (name == '/') {
      return name;
    }
    if (name.endsWith('/')) {
      return name.substring(0, name.length - 1);
    }
    return name;
  }

  static bool _backUntil(String untilRouteName) {
    final activeSubRoutes = RouterObjects.getActiveSubRoutes();
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
    rootDelegate = null;
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
