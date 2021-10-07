part of '../rm.dart';

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

final List<RouteSettingsWithChild> _routeSettingsList = [];
final resolvePathRouteUtil = ResolvePathRouteUtil();

class _RouterDelegate extends RouterDelegate<RouteSettingsWithChild>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<RouteSettingsWithChild> {
  _RouterDelegate() {
    _routeSettingsList.clear();
  }
  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigate._navigatorKey;
  final Map<RouteSettingsWithChild, MaterialPage> _pages = {};
  final Map<RouteSettingsWithChild, Completer> _completers = {};

  @override
  Future<void> setInitialRoutePath(RouteSettingsWithChild configuration) async {
    // return setNewRoutePath(configuration);
    // updatePages();
  }

  void updatePages() {
    final p = {..._pages};
    _pages.clear();
    for (var i = 0; i < _routeSettingsList.length; i++) {
      final settings = _routeSettingsList[i];
      if (p.containsKey(settings)) {
        _pages[settings] = p[settings]!;
      } else {
        _pages[settings] = _createPage(settings);
        if (settings.child != null) {
          return;
        }
        if (resolvePathRouteUtil.absolutePath.isNotEmpty) {
          _routeSettingsList[i] = settings.copyWith(
            name: resolvePathRouteUtil.absolutePath,
          );
        }
      }
    }
    notifyListeners();
  }

  List<MaterialPage> get pages {
    if (_pages.isEmpty) {
      _pages[_routeSettingsList.first] = _createPage(_routeSettingsList.first);
    }
    return _pages.values.toList();
  }

  @override
  RouteSettingsWithChild get currentConfiguration {
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

  MaterialPage _createPage(
    RouteSettingsWithChild settings,
  ) {
    late MaterialPage m;
    if (settings.child == null) {
      final child = resolvePathRouteUtil
          .getPagesFromRouteSettings(
            routes: Routers.routers!,
            settings: settings,
          )
          .values
          .last
          .child;

      m = MaterialPage(
        child: child ?? const Text('404'),
        key: ValueKey(settings.name),
        name: resolvePathRouteUtil.absolutePath,
        arguments: settings.arguments,
        fullscreenDialog: _navigate._fullscreenDialog,
        maintainState: _navigate._maintainState,
      );
    } else {
      m = MaterialPage(
        child: settings.child!,
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
      _routeSettingsList.removeLast();
      _completers[_routeSettingsList.last]?.complete(result);
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
      _routeSettingsList.removeLast();
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  Future<void> setNewRoutePath(RouteSettingsWithChild configuration) {
    {
      _routeSettingsList
        ..clear()
        ..add(configuration);
      updatePages();
    }
    return SynchronousFuture(null);
  }

  Future<T?> to<T extends Object?>(RouteSettingsWithChild settings) async {
    final completer = Completer<T?>();
    _completers[_routeSettingsList.last] = completer;
    _routeSettingsList.add(settings);
    updatePages();
    return completer.future;
  }

  // Future<T?> toNamed<T>(RouteSettingsWithChild settings) async {
  //   _routeSettingsList.add(settings);
  //   updatePages();
  // }

  Future<T?> toReplacementNamed<T extends Object?, TO extends Object?>(
    RouteSettingsWithChild settings, {
    TO? result,
  }) async {
    _routeSettingsList
      ..removeLast()
      ..add(settings);
    updatePages();
  }

  Future<T?> toNamedAndRemoveUntil<T extends Object?>(
    RouteSettingsWithChild settings,
    String? untilRouteName,
  ) async {
    if (untilRouteName == null) {
      _routeSettingsList
        ..clear()
        ..add(settings);
    } else {
      while (true) {
        if (_routeSettingsList.last.name == untilRouteName) {
          break;
        }
        if (canPop) {
          _routeSettingsList.removeLast();
        } else {
          break;
        }
      }
      _routeSettingsList.add(settings);
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
      if (_routeSettingsList.last.name == untilRouteName) {
        break;
      }
      if (canPop) {
        _routeSettingsList.removeLast();
      } else {
        break;
      }
    }
    updatePages();
  }

  Future<T?> backAndToNamed<T extends Object?, TO extends Object?>(
    RouteSettingsWithChild settings,
    TO? result,
  ) async {
    if (_routeSettingsList.isNotEmpty) {
      _routeSettingsList.removeLast();
      _routeSettingsList.add(settings);
      updatePages();
    }
  }
}

class _RouteInformationParser
    extends RouteInformationParser<RouteSettingsWithChild> {
  @override
  Future<RouteSettingsWithChild> parseRouteInformation(
      RouteInformation routeInformation) async {
    final settings =
        RouteSettingsWithChild(name: routeInformation.location ?? '/');

    final pages = resolvePathRouteUtil.getPagesFromRouteSettings(
      routes: Routers.routers!,
      settings: settings,
    );
    _routeSettingsList.clear();
    _routeSettingsList.addAll(pages.values);
    // _navigate._resetFields();
    // _routeSettingsList.clear();
    // final child = _navigate._resolvePageFromRouteSettings(settings);
    // _navigate._routeData.forEach((key, value) {
    //   _routeSettingsList
    //       .add(RouteSettingsWithChild(name: value.routeData.urlPath));
    // });
    // if (_routeSettingsList.first.name != '/') {
    //   _routeSettingsList.insert(
    //     0,
    //     const RouteSettingsWithChild(name: '/'),
    //   );
    // }
    // print(_routeSettingsList);
    // if (_routeSettingsList.isEmpty) {
    //   _routeSettingsList.add(settings);
    //   // _routeSettingsList.add(const RouteSettingsWithChild(
    //   //     name: '/book/1', arguments: null, child: null));
    // }
    // print(_routeSettingsList);

    return SynchronousFuture(settings);
  }

  @override
  RouteInformation restoreRouteInformation(
      RouteSettingsWithChild configuration) {
    return RouteInformation(location: configuration.name);
  }
}

@immutable
class RouteSettingsWithChild extends RouteSettings {
  final Widget? child;
  final Map<String, String> pathParams;
  final Map<String, String> queryParams;
  const RouteSettingsWithChild({
    required String name,
    Object? arguments,
    this.child,
    this.pathParams = const {},
    this.queryParams = const {},
  }) : super(name: name, arguments: arguments);

  @override
  RouteSettingsWithChild copyWith({
    String? name,
    Object? arguments,
    Widget? child,
    Map<String, String>? queryParams,
    Map<String, String>? pathParams,
  }) {
    return RouteSettingsWithChild(
      name: name ?? super.name!,
      arguments: arguments ?? super.arguments,
      child: child ?? this.child,
      queryParams: queryParams ?? this.queryParams,
      pathParams: pathParams ?? this.pathParams,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteSettingsWithChild &&
        other.name == name &&
        '${other.queryParams}' == '$queryParams';
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Page(name: $name, child: $child, arguments: $arguments,'
      ' pathParams: $pathParams, queryParams: $queryParams)';
}

class RouteSettingsWithChildAndData extends RouteSettingsWithChild {
  final String routeUriPath;
  final String baseUrlPath;
  final bool isPagesFound;
  const RouteSettingsWithChildAndData({
    required String name,
    required this.routeUriPath,
    required this.baseUrlPath,
    this.isPagesFound = true,
    Object? arguments,
    Widget? child,
    Map<String, String> queryParams = const {},
    Map<String, String> pathParams = const {},
  }) : super(
          name: name,
          child: child,
          arguments: arguments,
          queryParams: queryParams,
          pathParams: pathParams,
        );

  @override
  RouteSettingsWithChildAndData copyWith({
    String? name,
    Object? arguments,
    Widget? child,
    Map<String, String>? queryParams,
    Map<String, String>? pathParams,
    String? routeUriPath,
    String? baseUrlPath,
  }) {
    return RouteSettingsWithChildAndData(
      name: name ?? super.name!,
      arguments: arguments ?? super.arguments,
      child: child ?? this.child,
      queryParams: queryParams ?? this.queryParams,
      pathParams: pathParams ?? this.pathParams,
      routeUriPath: routeUriPath ?? this.routeUriPath,
      baseUrlPath: baseUrlPath ?? this.baseUrlPath,
    );
  }

  @override
  String toString() =>
      isPagesFound ? super.toString() : 'PAGE NOT Found (name: $name)';
}

class RouteSettingsWithChildAndSubRoute extends RouteSettingsWithChildAndData {
  final Widget? subRoute;
  final bool isBaseUrlChanged;
  const RouteSettingsWithChildAndSubRoute({
    required String name,
    required String routeUriPath,
    required String baseUrlPath,
    Object? arguments,
    Widget? child,
    Map<String, String> queryParams = const {},
    Map<String, String> pathParams = const {},
    this.subRoute,
    this.isBaseUrlChanged = false,
    bool isPagesFound = true,
  }) : super(
          name: name,
          child: child,
          arguments: arguments,
          queryParams: queryParams,
          pathParams: pathParams,
          routeUriPath: routeUriPath,
          baseUrlPath: baseUrlPath,
          isPagesFound: isPagesFound,
        );

  @override
  RouteSettingsWithChildAndSubRoute copyWith({
    String? name,
    String? routeUriPath,
    String? baseUrlPath,
    Object? arguments,
    Widget? child,
    Map<String, String>? queryParams,
    Map<String, String>? pathParams,
    Widget? subRoute,
    bool? isBaseUrlChanged,
  }) {
    return RouteSettingsWithChildAndSubRoute(
      name: name ?? super.name!,
      routeUriPath: routeUriPath ?? this.routeUriPath,
      baseUrlPath: baseUrlPath ?? this.baseUrlPath,
      arguments: arguments ?? super.arguments,
      child: child ?? this.child,
      queryParams: queryParams ?? this.queryParams,
      pathParams: pathParams ?? this.pathParams,
      subRoute: subRoute ?? this.subRoute,
      isBaseUrlChanged: isBaseUrlChanged ?? this.isBaseUrlChanged,
    );
  }
}
