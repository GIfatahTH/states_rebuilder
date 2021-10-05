part of '../rm.dart';

mixin TopRouter on TopStatelessWidget {
  final RouteInformationParser<RouteSettings> routeInformationParser =
      _RouteInformationParser();
  late final RouterDelegate<RouteSettings> routerDelegate =
      Routers._routerDelegate!;

  Map<String, Widget Function(RouteData)> get routes;
}

abstract class Routers {
  static _RouterDelegate? _routerDelegate;
  static Map<String, Widget Function(RouteData routeData)>? routers;
  static void initialize(
    Map<String, Widget Function(RouteData routeData)> routes,
  ) {
    routers = routes;
    _routerDelegate = _RouterDelegate();
  }
}

class _RouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigate._navigatorKey;
  final Map<RouteSettings, MaterialPage> _pages = {};
  void updatePages() {
    _pages.clear();
    final p = {..._pages};
    _pages.clear();
    for (var settings in _routeSettingsList) {
      if (p.containsKey(settings)) {
        _pages[settings] = p[settings]!;
      } else {
        _pages[settings] = _createPage(settings: settings);
      }
    }
    notifyListeners();
  }

  List<MaterialPage> get pages {
    if (_pages.isEmpty) {
      _pages[_routeSettingsList.first] =
          _createPage(settings: _routeSettingsList.first);
    }
    return _pages.values.toList();
  }

  final List<RouteSettings> _routeSettingsList = [RouteSettings(name: '/')];

  @override
  RouteSettings get currentConfiguration {
    return _routeSettingsList.last;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: pages,
    );
  }

  bool _onPopPage(Route<dynamic> route, result) {
    /// There’s a request to pop the route. If the route can’t handle it internally,
    /// it returns false.
    final didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }

    /// Otherwise, check to see if we can remove the top page and remove the page from the list of pages.
    if (canPop()) {
      pop();
      return true;
    } else {
      return false;
    }
  }

  bool canPop() {
    return _pages.length > 1;
  }

  void _removePage(RouteSettings page) {
    _routeSettingsList.remove(page);
    updatePages();
  }

  void pop<T>() {
    _removePage(_routeSettingsList.last);
  }

  @override
  Future<bool> popRoute() {
    if (canPop()) {
      _removePage(_routeSettingsList.last);
      return Future.value(true);
    }
    return Future.value(false);
  }

  MaterialPage _createPage({
    RouteSettings? settings,
    Widget? child,
  }) {
    late MaterialPage m;
    if (child == null) {
      assert(settings != null);
      child = _navigate._resolvePageFromRouteSettings(settings!);
      m = MaterialPage(
        child: child ?? Text('404'),
        key: ValueKey(settings.name),
        name: settings.name,
        arguments: settings.arguments,
        fullscreenDialog: _navigate._fullscreenDialog,
        maintainState: _navigate._maintainState,
      );
    } else {
      MaterialPage(
        child: child,
        key: ValueKey(settings?.name ?? child.hashCode),
        name: settings?.name ?? child.hashCode.toString(),
        arguments: settings?.arguments,
        fullscreenDialog: _navigate._fullscreenDialog,
        maintainState: _navigate._maintainState,
      );
    }
    _navigate
      .._fullscreenDialog = false
      .._maintainState = true;
    return m;
  }

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) {
    {
      _routeSettingsList
        ..clear()
        ..add(configuration);
      updatePages();
    }
    return SynchronousFuture(null);
  }

  Future<T?> toNamed<T>(RouteSettings settings) async {
    _routeSettingsList.add(settings);
    updatePages();
  }

  Future<T?> toReplacementNamed<T extends Object?, TO extends Object?>(
    RouteSettings settings, {
    TO? result,
  }) async {
    _routeSettingsList
      ..removeLast()
      ..add(settings);
    updatePages();
  }
}

class _RouteInformationParser extends RouteInformationParser<RouteSettings> {
  @override
  Future<RouteSettings> parseRouteInformation(
      RouteInformation routeInformation) async {
    return RouteSettings(name: routeInformation.location);
  }
}
