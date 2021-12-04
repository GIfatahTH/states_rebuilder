part of '../../rm.dart';

class RouterDelegateImp extends RouterDelegate<PageSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageSettings> {
  RouterDelegateImp({
    required GlobalKey<NavigatorState> key,
    required Map<Uri, Widget Function(RouteData)> routes,
    required Widget Function(Widget)? builder,
    required ResolvePathRouteUtil resolvePathRouteUtil,
    required this.delegateName,
    this.hasBuilder = true,
    required Widget Function(
      BuildContext,
      Animation<double>,
      Animation<double>,
      Widget,
    )?
        transitionsBuilder,
    required this.delegateImplyLeadingToParent,
  })  : _builder = builder,
        _routes = routes,
        _resolvePathRouteUtil = resolvePathRouteUtil,
        _transitionsBuilder = transitionsBuilder,
        _navigatorKey = key;

  final List<PageSettings> _pageSettingsList = [];
  List<PageSettings> get pageSettingsList => [..._pageSettingsList];

  final Map<Uri, Widget Function(RouteData)> _routes;
  final Widget Function(Widget)? _builder;
  final ResolvePathRouteUtil _resolvePathRouteUtil;
  final GlobalKey<NavigatorState> _navigatorKey;
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? _transitionsBuilder;
  final String delegateName;
  final bool hasBuilder;
  bool delegateImplyLeadingToParent;
  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
  final _pages = <Page<dynamic>>[];
  List<Page<dynamic>> get pages => [..._pages];
  final Map<String, Completer> _completers = {};

  void _updateRouteStack([bool notify = true]) {
    final pages = [..._pages];
    _pages.clear();

    for (var i = 0; i < _pageSettingsList.length; i++) {
      final isLast = i == _pageSettingsList.length - 1 ? null : false;
      PageSettings settings = _pageSettingsList[i];
      if (pages.length > i) {
        bool hasChild = true;
        try {
          hasChild = (pages[i] as dynamic).child is Object;
        } catch (e) {
          hasChild = false;
        }
        if (hasChild) {
          if (settings.child == (pages[i] as dynamic).child) {
            _pages.add(pages[i]);
            continue;
          }
        }
      }
      final childMap = _getChild(settings);
      if (childMap == null) {
        _pageSettingsList.removeAt(i);
        continue;
      }
      if (childMap.values.last is RouteWidget) {
        final r = (childMap.values.last as RouteWidget)._routeData;
        settings = settings.copyWith(
          key: ValueKey(childMap.values.last.key.toString() + '$i'),
          child: childMap.values.last,
          name: r.location,
          delegateName: childMap.keys.last.name,
          routeData: r,
          queryParams: r.queryParams,
          arguments: r.arguments,
        );
      } else {
        settings = settings.copyWith(
          key: ValueKey(childMap.keys.last.signature + '$i'),
          child: childMap.values.last,
          name: childMap.keys.last.name,
          routeData: childMap.keys.last.routeData,
          queryParams: childMap.keys.last.queryParams,
          arguments: childMap.keys.last.arguments,
        );
      }

      if (i > 0 &&
          _pageSettingsList[i - 1]._signatureWithChild ==
              settings._signatureWithChild) {
        _pageSettingsList.removeAt(i);
        continue;
      }

      _pageSettingsList[i] = settings;
      final Page<dynamic> p =
          RouterObjects.injectedNavigator?.pageBuilder == null
              ? _MaterialPage1(
                  child: settings.child!,
                  key: settings.key,
                  name: settings.name ?? _resolvePathRouteUtil.absolutePath,
                  arguments: settings.arguments,
                  fullscreenDialog: isLast ?? _navigate._fullscreenDialog,
                  maintainState: isLast ?? _navigate._maintainState,
                  useTransition: _useTransition,
                  customBuildTransitions: _transitionsBuilder,
                )
              : RouterObjects.injectedNavigator!.pageBuilder!(
                  MaterialPageArgument(
                    child: settings.child!,
                    key: settings.key,
                    name: settings.name ?? _resolvePathRouteUtil.absolutePath,
                    arguments: settings.arguments,
                    fullscreenDialog: isLast ?? _navigate._fullscreenDialog,
                    maintainState: isLast ?? _navigate._maintainState,
                  ),
                );
      _pages.add(p);
      // if (settings.child != null) {
      //   continue;
      // }
      // if (resolvePathRouteUtil.absolutePath.isNotEmpty) {
      //   _pageSettingsList.add(
      //     settings.copyWith(
      //       name: resolvePathRouteUtil.absolutePath,
      //     ),
      //   );
      // }
    }
    _navigate._fullscreenDialog = false;
    _navigate._maintainState = false;
    assert(_pages.length == _pageSettingsList.length);
    assert(_pages.isNotEmpty, '$delegateName has empty pages');
    ResolvePathRouteUtil.globalBaseUrl =
        _pageSettingsList.last.rData!.baseLocation;

    if (this != RouterObjects.rootDelegate) {
      if (notify) {
        notifyListeners();
      }
      RouterObjects.rootDelegate!
        .._ignoreConfiguration = false
        .._notifyListeners();
    } else if (notify) {
      _ignoreConfiguration = _pageSettingsList.last.child is RouteWidget;
      notifyListeners();
    }
  }

  bool _isDirty = false;
  bool forceBack = false;
  bool _useTransition = true;
  String? _message;
  bool _ignoreConfiguration = false;

  void _notifyListeners() {
    if (!_isDirty) {
      _isDirty = true;
      notifyListeners();
    } else {
      WidgetsBinding.instance!.addPostFrameCallback(
        (timeStamp) {
          _isDirty = false;
          notifyListeners();
        },
      );
    }
  }

  List<Page<dynamic>> get _routeStack {
    if (_pages.isEmpty) {
      _updateRouteStack(false);
    }
    assert(_pages.isNotEmpty);
    // TODO test _pages.length <= 2
    if (_pages.length <= 2 &&
        delegateImplyLeadingToParent &&
        RouterObjects.canPop(this)) {
      return [const MaterialPage(child: SizedBox.shrink()), ..._pages];
    }

    return List.of(_pages, growable: false);
  }

  /// Get the current route Stack
  ///
  /// To set the route stack use [RouterDelegateImp.setRouteStack]
  List<PageSettings> get routeStack => [..._pageSettingsList];

  void setRouteStack(
    List<PageSettings> Function(List<PageSettings> pages) stack,
  ) {
    final s = stack(routeStack);
    _pageSettingsList
      ..clear()
      ..addAll(s);
    _updateRouteStack();
    for (var name in [..._completers.keys]) {
      if (!_pageSettingsList.any((e) => e.name == name)) {
        _completers.remove(name);
      }
    }
  }

  PageSettings? get _lastLeafConfiguration {
    if (_pageSettingsList.isEmpty) {
      return null;
    }
    final config = _pageSettingsList.last;
    if (config.child is RouteWidget) {
      return (config.child as RouteWidget)._getLeafConfig();
    }
    return config;
  }

  PageSettings? get _lastConfiguration {
    return _pageSettingsList.isNotEmpty ? _pageSettingsList.last : null;
  }

  @override
  PageSettings? get currentConfiguration {
    if (this == RouterObjects.rootDelegate) {
      // final c = RouterObjects._activeSubRoutes()?.last._lastConfiguration;
      final c = _lastLeafConfiguration;

      if (c != null) {
        RouterObjects.injectedNavigator!.notify();
        // if (_restoredRouteInformationName == c.name) {
        //   return null;
        // }
      }
      return c;
    }
    return null;
  }

  @override
  Future<void> setInitialRoutePath(PageSettings configuration) {
    // RouterObjects._setInitialRoute(configuration.name);
    return SynchronousFuture(null);
  }

  @override
  Future<void> setNewRoutePath(PageSettings configuration) {
    _updateRouteStack();

    return SynchronousFuture(null);
  }

  Map<String, RouteSettingsWithChildAndData>? getPagesFromRouteSettings({
    required PageSettings settings,
    bool skipHomeSlash = false,
    required List<String> redirectedFrom,
  }) {
    return _resolvePathRouteUtil.getPagesFromRouteSettings(
      routes: _routes,
      settings: settings,
      queryParams: settings.queryParams,
      skipHomeSlash: skipHomeSlash,
      unknownRoute: RouterObjects._unknownRoute,
      redirectedFrom: redirectedFrom,
    );
  }

  Map<RouteSettingsWithChildAndData, Widget>? _getChild(
    PageSettings settings,
  ) {
    if (settings.child == null) {
      final p = getPagesFromRouteSettings(
        settings: settings,
        skipHomeSlash: true,
        redirectedFrom: [],
      );
      if (p == null) {
        return null;
      }
      return {p.values.last: getWidgetFromPages(pages: p)};
    }
    if (settings is RouteSettingsWithChildAndData) {
      return {
        settings: getWidgetFromPages(pages: {settings.name!: settings})
      };
    }
    if (settings.name != null) {
      assert(settings.child != null);
      final s = RouteSettingsWithChildAndData(
        routeData: RouteData(
          location: settings.name!,
          arguments: settings.arguments,
          path: settings.routePattern ?? '/',
          pathParams: settings is RouteSettingsWithChildAndData
              ? settings.routeData.pathParams
              : {},
          queryParams: settings.queryParams,
          pathEndsWithSlash: settings is RouteSettingsWithChildAndData
              ? settings.routeData._pathEndsWithSlash
              : false,
          redirectedFrom: settings is RouteSettingsWithChildAndData
              ? settings.routeData._redirectedFrom
              : [],
        ),
        child: settings.child,
      );
      return {
        s: getWidgetFromPages(
          pages: {
            settings.name!: s,
          },
        ),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    _isDirty = true;
    if (_builder != null) {
      if (this == RouterObjects.rootDelegate) {
        return Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) {
              return _builder!(
                Navigator(
                  key: navigatorKey,
                  onPopPage: _onPopPage,
                  pages: _routeStack,
                ),
              );
            },
          ),
        );
      }

      return _builder!(
        Navigator(
          key: navigatorKey,
          onPopPage: _onPopPage,
          pages: _routeStack,
        ),
      );
    }
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: _routeStack,
    );
  }

  void rootDelegatePop(dynamic result) {
    _message = 'Back';
    _ignoreConfiguration = false;
    if (!RouterObjects._back(result)) {
      _message = 'Navigate';
    }
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (delegateImplyLeadingToParent && this == RouterObjects.rootDelegate) {
      rootDelegatePop(result);
      return false;
    }

    /// There’s a request to pop the route. If the route can’t handle it internally,
    /// it returns false.
    final didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }

    /// Otherwise, check to see if we can remove the top page and remove the page from the list of pages.
    if (_canPop) {
      back(result);
      return true;
    } else {
      if (delegateImplyLeadingToParent) {
        RouterObjects.rootDelegate!
          .._message = 'Back'
          .._ignoreConfiguration = false;
        if (!RouterObjects._back(result)) {
          RouterObjects.rootDelegate!._message = 'Navigate';
        }
      }
      return false;
    }
  }

  bool get _canPop {
    return _pageSettingsList.length > 1;
  }

  bool _canPopUntil(String untilRouteName) {
    if (!_pageSettingsList.any((e) => e.name == untilRouteName)) {
      return false;
    }
    return true;
  }

  // @override
  // Future<bool> popRoute() async {
  //   print(await super.popRoute());
  //   return SynchronousFuture(true);
  // }

  Future<T?> to<T extends Object?>(PageSettings settings) async {
    _pageSettingsList.add(settings);
    Completer<T?>? completer = Completer<T?>();
    _completers[_pageSettingsList.last.name!] = completer;
    _updateRouteStack();
    return completer.future;
  }

  Future<T?> toReplacementNamed<T extends Object?, TO extends Object?>(
    PageSettings settings, {
    TO? result,
  }) async {
    _completers.remove(_pageSettingsList.last.name!)?.complete(result);
    _pageSettingsList.removeLast();
    return to(settings);
  }

  Future<T?> toNamedAndRemoveUntil<T extends Object?>(
    PageSettings settings,
    String? untilRouteName,
  ) async {
    if (untilRouteName == null) {
      _pageSettingsList.clear();
    } else {
      if (!_canPopUntil(untilRouteName)) {
        return Future.value(null);
      }
      while (true) {
        if (_pageSettingsList.last.name == untilRouteName) {
          break;
        }
        if (_canPop) {
          _pageSettingsList.removeLast();
        } else {
          break;
        }
      }
    }
    return to(settings);
  }

  bool? back<T extends Object?>([T? result]) {
    if (_canPop) {
      if (!forceBack && RouterObjects.injectedNavigator!.onBack != null) {
        final canBack = RouterObjects.injectedNavigator!.onBack?.call(
          _pageSettingsList.last.rData!,
        );
        if (canBack == false) {
          return null;
        }
      }
      forceBack = false;
      _completers.remove(_pageSettingsList.last.name!)?.complete(result);
      _pageSettingsList.removeLast();
      _updateRouteStack();
      RouterObjects.injectedNavigator!.routeData =
          _lastLeafConfiguration!.rData!;
      return true;
    } else {
      return false;
    }
  }

  bool _backUntil(String untilRouteName) {
    if (!_canPopUntil(untilRouteName)) {
      return false;
    }
    while (true) {
      if (_pageSettingsList.last.name == untilRouteName) {
        break;
      }
      if (_canPop) {
        _pageSettingsList.removeLast();
      } else {
        break;
      }
    }
    return true;
  }

  bool backUntil(String untilRouteName) {
    bool isDone = _backUntil(untilRouteName);
    _updateRouteStack();
    return isDone;
  }

  Future<T?> backAndToNamed<T extends Object?, TO extends Object?>(
    PageSettings settings,
    TO? result,
  ) async {
    if (_pageSettingsList.isNotEmpty) {
      _pageSettingsList.removeLast();
      _completers[_pageSettingsList.last.key]?.complete(result);
      return to(settings);
    }
  }

  @override
  String toString() {
    String str = '';
    for (var page in _pageSettingsList) {
      str += '\t${page.toStringShort()}\n';
    }
    return '_RouterDelegate[$delegateName](\n$str\t)\n';
  }
}

class _MaterialPage1<T> extends MaterialPage<T> {
  const _MaterialPage1({
    required Widget child,
    required this.customBuildTransitions,
    bool maintainState = true,
    bool fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
    this.useTransition = true,
  }) : super(
          child: child,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
          key: key,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )? customBuildTransitions;
  final bool useTransition;

  @override
  Route<T> createRoute(BuildContext context) {
    if (useTransition && RouterObjects._shouldUseCupertinoPage) {
      return _PageBasedCupertinoPageRoute<T>(
        page: this,
        customBuildTransitions: customBuildTransitions,
      );
    }
    return _PageBasedMaterialPageRoute<T>(
      page: this,
      useTransition: useTransition,
      customBuildTransitions: customBuildTransitions,
    );
  }
}

class _PageBasedMaterialPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  _PageBasedMaterialPageRoute({
    required MaterialPage<T> page,
    required this.customBuildTransitions,
    this.useTransition = false,
  }) : super(settings: page) {
    assert(opaque);
  }
  final bool useTransition;
  MaterialPage<T> get _page => settings as MaterialPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )? customBuildTransitions;

  @override
  Duration get transitionDuration {
    if (useTransition &&
        (RouterObjects.isTransitionAnimated != false ||
            _Navigate._transitionDuration != null)) {
      return _Navigate._transitionDuration ??
          const Duration(
            milliseconds: 300,
          );
    }
    return const Duration(microseconds: 1);
  }

  @override
  Duration get reverseTransitionDuration {
    return transitionDuration;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!useTransition) {
      RouterObjects.isTransitionAnimated = false;
      return child;
    }
    if (customBuildTransitions != null) {
      RouterObjects.isTransitionAnimated = true;
      return customBuildTransitions!(
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }
    final c = super.buildTransitions(
      context,
      animation,
      secondaryAnimation,
      child,
    );
    // super.buildTransitions return the same child, this means that transition
    // is not animated.
    // It is used to reduce the default animation duration to zero.
    RouterObjects.isTransitionAnimated = c != child;
    return c;
  }
}

class _PageBasedCupertinoPageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  _PageBasedCupertinoPageRoute({
    required MaterialPage<T> page,
    required this.customBuildTransitions,
  }) : super(settings: page) {
    assert(opaque);
  }

  MaterialPage<T> get _page => settings as MaterialPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  String? get title => _page.name;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )? customBuildTransitions;
  @override
  Duration get transitionDuration =>
      _Navigate._transitionDuration ??
      const Duration(
        milliseconds: 300,
      );

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (customBuildTransitions != null) {
      return customBuildTransitions!(
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }

    final c = super.buildTransitions(
      context,
      animation,
      secondaryAnimation,
      child,
    );

    RouterObjects.isTransitionAnimated = c != child;
    return c;
  }
}
