part of '../../rm.dart';

abstract class RouterObjects {
  static String? _initialRouteValue;
  static bool _isInitialRouteSet = false;
  static void _setInitialRoute(String? route) {
    if (_isInitialRouteSet) {
      return;
    }
    _initialRouteValue = route;
  }

  static _RouterDelegate? _routerDelegate;
  static _RouteInformationParser? _routeInformationParser;
  static Map<String, Widget Function(RouteData routeData)>? _routers;
  static Widget Function(String route)? _unknownRoute;
  static void initialize({
    required Map<String, Widget Function(RouteData routeData)> routes,
    required Widget Function(String route)? unknownRoute,
    required Widget Function(
            BuildContext, Animation<double>, Animation<double>, Widget)?
        transitionsBuilder,
  }) {
    _isInitialRouteSet = false;
    _routers = routes;
    _routerDelegate = _RouterDelegate();
    _routeInformationParser = _RouteInformationParser();
    _unknownRoute = unknownRoute;
    _navigate.transitionsBuilder = transitionsBuilder;
  }
}

final List<PageSettings> _pageSettingsList = [];
final resolvePathRouteUtil = ResolvePathRouteUtil();

class _RouterDelegate extends RouterDelegate<PageSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageSettings> {
  _RouterDelegate() {
    _pageSettingsList.clear();
  }
  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigate._navigatorKey;
  final Map<PageSettings, _MaterialPage> _pages = {};
  final Map<PageSettings, Completer> _completers = {};

  void updatePages() {
    final p = {..._pages};
    _pages.clear();
    for (var i = 0; i < _pageSettingsList.length; i++) {
      final settings = _pageSettingsList[i];
      // if (p.containsKey(settings)) {
      //   _pages[settings] = p[settings]!;
      //   continue;
      // }
      _pages[settings] = _createPage(settings);
      if (settings.child != null) {
        continue;
      }
      if (resolvePathRouteUtil.absolutePath.isNotEmpty) {
        _pageSettingsList[i] = settings.copyWith(
          name: resolvePathRouteUtil.absolutePath,
        );
      }
    }
    notifyListeners();
  }

  List<_MaterialPage> get pages {
    if (_pages.isEmpty) {
      for (final setting in _pageSettingsList) {
        _pages[setting] = _createPage(setting);
      }
    }
    return _pages.values.toList();
  }

  @override
  PageSettings get currentConfiguration {
    return _pageSettingsList.last;
  }

  @override
  Future<void> setInitialRoutePath(PageSettings configuration) {
    RouterObjects._setInitialRoute(configuration.name);
    return SynchronousFuture(null);
  }

  @override
  Future<void> setNewRoutePath(PageSettings configuration) {
    {
      // _routeSettingsList
      //   ..clear()
      //   ..add(configuration);
      updatePages();
    }
    return SynchronousFuture(null);
  }

  @override
  Widget build(BuildContext context) {
    print('');
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: pages,
    );
  }

  _MaterialPage _createPage(
    PageSettings settings,
  ) {
    late _MaterialPage m;
    late Widget child;
    if (settings.child == null) {
      final p = resolvePathRouteUtil.getPagesFromRouteSettings(
        routes: RouterObjects._routers!,
        settings: settings,
        skipHomeSlash: true,
        unknownRoute: RouterObjects._unknownRoute,
      );
      final child = getWidgetFromPages(pages: p);

      m = _MaterialPage(
        child: child,
        key: ValueKey(settings.name),
        name: resolvePathRouteUtil.absolutePath,
        arguments: settings.arguments,
        fullscreenDialog: _navigate._fullscreenDialog,
        maintainState: _navigate._maintainState,
      );
    } else {
      if (settings is RouteSettingsWithChildAndData) {
        child = getWidgetFromPages(pages: {settings.name!: settings});
      } else {
        child = settings.child!;
      }
      m = _MaterialPage(
        child: child,
        key: ValueKey(settings.name),
        name: settings.name,
        arguments: settings.arguments,
        fullscreenDialog: _navigate._fullscreenDialog,
        maintainState: _navigate._maintainState,
      );
    }
    _navigate
      .._fullscreenDialog = false
      .._maintainState = true;
    return m;
  }

  bool _onPopPage(Route<dynamic> route, result) {
    /// There’s a request to pop the route. If the route can’t handle it internally,
    /// it returns false.
    final didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }

    /// Otherwise, check to see if we can remove the top page and remove the page from the list of pages.
    if (canPop) {
      _pageSettingsList.removeLast();
      _completers[_pageSettingsList.last]?.complete(result);
      updatePages();
      return true;
    } else {
      return false;
    }
  }

  bool get canPop {
    return _pages.length > 1;
  }

  // void _removePage(RouteSettingsWithChild page) {
  //   _routeSettingsList.remove(page);
  //   updatePages();
  // }

  // void pop<T>() {
  //   _removePage(_routeSettingsList.last);
  // }

  @override
  Future<bool> popRoute() {
    if (canPop) {
      _pageSettingsList.removeLast();
      return Future.value(true);
    }
    return Future.value(false);
  }

  Future<T?> to<T extends Object?>(PageSettings settings) async {
    final completer = Completer<T?>();
    _completers[_pageSettingsList.last] = completer;
    _pageSettingsList.add(settings);
    updatePages();
    return completer.future;
  }

  // Future<T?> toNamed<T>(RouteSettingsWithChild settings) async {
  //   _routeSettingsList.add(settings);
  //   updatePages();
  // }

  Future<T?> toReplacementNamed<T extends Object?, TO extends Object?>(
    PageSettings settings, {
    TO? result,
  }) async {
    _pageSettingsList
      ..removeLast()
      ..add(settings);
    updatePages();
  }

  Future<T?> toNamedAndRemoveUntil<T extends Object?>(
    PageSettings settings,
    String? untilRouteName,
  ) async {
    if (untilRouteName == null) {
      _pageSettingsList
        ..clear()
        ..add(settings);
    } else {
      while (true) {
        if (_pageSettingsList.last.name == untilRouteName) {
          break;
        }
        if (canPop) {
          _pageSettingsList.removeLast();
        } else {
          break;
        }
      }
      _pageSettingsList.add(settings);
    }
    updatePages();
  }

  // void back<T extends Object>([T? result]) {
  //   if (canPop) {
  //     _routeSettingsList.removeLast();
  //     _completers[_routeSettingsList.last]?.complete(result);
  //     updatePages();
  //   }
  // }

  void backUntil(String untilRouteName) {
    while (true) {
      if (_pageSettingsList.last.name == untilRouteName) {
        break;
      }
      if (canPop) {
        _pageSettingsList.removeLast();
      } else {
        break;
      }
    }
    updatePages();
  }

  Future<T?> backAndToNamed<T extends Object?, TO extends Object?>(
    PageSettings settings,
    TO? result,
  ) async {
    if (_pageSettingsList.isNotEmpty) {
      _pageSettingsList.removeLast();
      _pageSettingsList.add(settings);
      updatePages();
    }
  }
}
