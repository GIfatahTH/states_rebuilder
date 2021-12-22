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
    required this.transitionsBuilder,
    required this.transitionDuration,
    required this.delegateImplyLeadingToParent,
  })  : _builder = builder,
        _routes = routes,
        _resolvePathRouteUtil = resolvePathRouteUtil,
        _navigatorKey = key;

  final Map<Uri, Widget Function(RouteData)> _routes;
  final Widget Function(Widget)? _builder;
  final ResolvePathRouteUtil _resolvePathRouteUtil;
  final GlobalKey<NavigatorState> _navigatorKey;
  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
  Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? transitionsBuilder;
  Duration? transitionDuration;
  final String delegateName;
  final bool hasBuilder;

  final List<PageSettings> _pageSettingsList = [];
  List<PageSettings> get pageSettingsList => [..._pageSettingsList];
  final _pages = <Page<dynamic>>[];
  List<Page<dynamic>> get pages => [..._pages];

  static final Map<String, Completer> _completers = {};
  bool delegateImplyLeadingToParent;

  void updateRouteStack([bool notify = true]) {
    final pages = [..._pages];
    _pages.clear();

    for (var i = 0; i < _pageSettingsList.length; i++) {
      final isLast = i == _pageSettingsList.length - 1 ? null : false;
      PageSettings settings = _pageSettingsList[i];
      if (pages.length > i) {
        bool skip = false;
        for (var j = i; j < pages.length; j++) {
          final p = pages[j];
          if (settings.child == (p as dynamic).child) {
            _pages.add(p);
            skip = true;
            break;
          }
        }
        if (skip) {
          continue;
        }
      }
      final childMap = _getChild(settings);
      if (childMap == null) {
        // CASE The PageSettings can not have a resolved child
        _pageSettingsList.removeAt(i);
        continue;
      }

      Widget Function(
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      )? routeWidgetTransitionsBuilder;
      Duration? routeWidgetTransitionDuration;
      final child = childMap.values.last;
      final hash = child.hashCode;
      if (child is RouteWidget) {
        final r = child._routeData;
        settings = settings.copyWith(
          key: ValueKey(child.key.toString() + '$hash'),
          child: child,
          name: r._subLocation,
          delegateName: childMap.keys.last.name,
          routeData: r,
          queryParams: r.queryParams,
          arguments: r.arguments,
        );
        routeWidgetTransitionsBuilder = child.transitionsBuilder;
        routeWidgetTransitionDuration = child._transitionDuration;
      } else {
        settings = settings.copyWith(
          key: ValueKey(childMap.keys.last.signature + '$hash'),
          child: child,
          name: childMap.keys.last.name,
          routeData: childMap.keys.last.routeData,
          queryParams: childMap.keys.last.queryParams,
          arguments: childMap.keys.last.arguments,
        );
      }

      if (i > 0 &&
          _pageSettingsList[i - 1]._signatureWithChild ==
              settings._signatureWithChild) {
        // Do not allow pages with the same signutre to pile up on top of each other
        _pageSettingsList.removeAt(i);
        continue;
      }

      _pageSettingsList[i] = settings;
      final Page<dynamic> p =
          RouterObjects.injectedNavigator?.pageBuilder == null
              ? MaterialPageImp(
                  child: settings.child!,
                  key: settings.key,
                  name: settings.name ?? _resolvePathRouteUtil.absolutePath,
                  arguments: settings.arguments,
                  fullscreenDialog: isLast ?? _navigate._fullscreenDialog,
                  maintainState: isLast ?? _navigate._maintainState,
                  useTransition: isLast ?? useTransition,
                  customBuildTransitions:
                      routeWidgetTransitionsBuilder ?? transitionsBuilder,
                  transitionDuration:
                      routeWidgetTransitionDuration ?? transitionDuration,
                )
              : //A custom pageBuilder is defined
              RouterObjects.injectedNavigator!.pageBuilder!(
                  MaterialPageArgument(
                    child: settings.child!,
                    key: settings.key,
                    name: settings.name ?? _resolvePathRouteUtil.absolutePath,
                    arguments: settings.arguments,
                    fullscreenDialog: isLast ?? _navigate._fullscreenDialog,
                    maintainState: isLast ?? _navigate._maintainState,
                  ),
                );
      assert(
        () {
          bool hasChild = true;
          try {
            hasChild = (p as dynamic).child is Widget;
          } catch (e) {
            hasChild = false;
          }
          if (!hasChild) {
            throw 'Custom "pageBuilder" must have a child argument';
          }
          return true;
        }(),
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
    _navigate._maintainState = true;
    assert(_pages.length == _pageSettingsList.length);
    // assert(_pages.isNotEmpty, '$delegateName has empty pages');
    // Set globalBaseUrl
    if (_pages.isNotEmpty) {
      ResolvePathRouteUtil.globalBaseUrl =
          _pageSettingsList.last.rData!.baseLocation;
      RouterObjects.injectedNavigator!.routeData =
          _pageSettingsList.last.rData!;
    }

    if (this != RouterObjects.rootDelegate) {
      // If this is a subRoute
      if (notify) {
        // Notify the subRoute
        notifyListeners();
      }
      // Notify the root route without logging
      RouterObjects.rootDelegate!
        ..canLogMessage = false
        .._notifyListeners();
    } else if (notify) {
      canLogMessage = _pageSettingsList.last.child is RouteWidget;
      notifyListeners();
    }
  }

  bool _isDirty = false;
  bool useTransition = true;
  bool forceBack = false;
  String? message;
  bool canLogMessage = false;

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
      updateRouteStack(false);
    }
    // assert(_pages.isNotEmpty);
    if (_pages.isEmpty) {
      return [const MaterialPage(child: SizedBox.shrink())];
    }

    // TODO test _pages.length <= 2
    if (_pages.length <= 2 &&
        delegateImplyLeadingToParent &&
        RouterObjects.getDelegateToPop(this) != null) {
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
    final s = stack(routeStack).map(
      (e) {
        final name = e.name!;
        if (name.startsWith('/')) {
          return e;
        }
        return e.copyWith(
          name: _resolvePathRouteUtil.urlName == '/'
              ? '/$name'
              : _resolvePathRouteUtil.urlName + '/$name',
        );
      },
    );

    _pageSettingsList
      ..clear()
      ..addAll(s);
    updateRouteStack();
    for (var name in [..._completers.keys]) {
      if (!_pageSettingsList.any((e) => e.name == name)) {
        final completer = _completers[name];
        if (!completer!.isCompleted) {
          completer.complete(null);
        }
        _completers.remove(name);
      }
    }
  }

  // Get the configuration of the deepest active sub route
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
      final c = _lastLeafConfiguration;
      if (c != null) {
        RouterObjects.injectedNavigator!.notify();
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
    updateRouteStack();
    return SynchronousFuture(null);
  }

  Map<String, RouteSettingsWithChildAndData>? getPagesFromRouteSettings({
    required PageSettings settings,
    bool skipHomeSlash = false,
    required List<RouteData> redirectedFrom,
  }) {
    return _resolvePathRouteUtil.getPagesFromRouteSettings(
      routes: _routes,
      settings: settings,
      queryParams: settings.queryParams,
      skipHomeSlash: skipHomeSlash,
      unknownRoute: RouterObjects._unknownRoute,
      redirectedFrom: redirectedFrom,
      ignoreUnknownRoutes: RouterObjects.rootDelegate!._pageSettingsList.isEmpty
          ? false
          : RouterObjects.injectedNavigator!.ignoreUnknownRoutes,
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
          subLocation: settings is RouteSettingsWithChildAndData
              ? settings.routeData._subLocation
              : settings.name!,
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
        return _RootRouterWidget(
          child: Overlay(
            initialEntries: [
              OverlayEntry(
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
            ],
          ),
          dispose: RouterObjects._dispose,
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
    assert(this == RouterObjects.rootDelegate);

    return _RootRouterWidget(
      child: Navigator(
        key: navigatorKey,
        onPopPage: _onPopPage,
        pages: _routeStack,
      ),
      dispose: RouterObjects._dispose,
    );
  }

  void rootDelegatePop(dynamic result) {
    message = 'Back';
    canLogMessage = false;
    if (RouterObjects._back(result, this)) {
      message = 'Navigate';
    } else {
      back(result);
    }
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (delegateImplyLeadingToParent && this == RouterObjects.rootDelegate) {
      // rootDelegatePop(result);
      message = 'Back';
      canLogMessage = false;
      final r = RouterObjects._back(result, this);

      if (r) {
        return false;
      }

      if (_canPop) {
        if (back(result) == true) {
          final didPop = route.didPop(result);
          if (!didPop) {
            return false;
          }
          message = 'Navigate';
          return true;
        }
        return false;
        // return true;
      }
      return false;
    }
    if (delegateImplyLeadingToParent) {
      var r = RouterObjects._back(result, this);
      if (r) {
        return false;
      }
    }

    /// There’s a request to pop the route. If the route can’t handle it internally,
    /// it returns false.

    // return false;

    /// Otherwise, check to see if we can remove the top page and remove the page from the list of pages.
    if (_canPop) {
      if (back(result) == true) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }
        return true;
      }
      return false;
      // return true;
    }
    // else {
    //   if (delegateImplyLeadingToParent) {
    //     RouterObjects.rootDelegate!
    //       ..message = 'Back'
    //       ..canLogMessage = false;
    //     if (!RouterObjects._back(result)) {
    //       RouterObjects.rootDelegate!.message = 'Navigate';
    //     }
    //   }
    //   return false;
    // }
    return false;
  }

  bool get _canPop {
    return _pageSettingsList.length > 1;
  }

  bool _canPopUntil(String untilRouteName) {
    if (_pageSettingsList
        .any((e) => e.name! == RouterObjects.trimLastSlash(untilRouteName))) {
      return true;
    }
    return false;
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
    updateRouteStack();
    return completer.future;
  }

  // Future<T?> toReplacementNamed<T extends Object?, TO extends Object?>(
  //   PageSettings settings, {
  //   TO? result,
  // }) async {
  //   _completers.remove(_pageSettingsList.last.name!)?.complete(result);
  //   _pageSettingsList.removeLast();
  //   return to(settings);
  // }

  // Future<T?> toNamedAndRemoveUntil<T extends Object?>(
  //   PageSettings settings,
  //   String? untilRouteName,
  // ) async {
  //   if (untilRouteName == null) {
  //     _pageSettingsList.clear();
  //   } else {
  //     if (!_canPopUntil(untilRouteName)) {
  //       return Future.value(null);
  //     }
  //     while (true) {
  //       if (_pageSettingsList.last.name == untilRouteName) {
  //         break;
  //       }
  //       if (_canPop) {
  //         _pageSettingsList.removeLast();
  //       } else {
  //         break;
  //       }
  //     }
  //   }
  //   return to(settings);
  // }

  void remove<T extends Object?>(String routeName, [T? result]) {
    final page = _pageSettingsList.firstWhereOrNull((e) => e.name == routeName);
    if (page == null || !_canPop) {
      return;
    }
    _completers.remove(routeName)?.complete(result);
    _pageSettingsList.remove(page);
    updateRouteStack();
    RouterObjects.injectedNavigator!.routeData = _lastLeafConfiguration!.rData!;
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
      updateRouteStack();
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
    if (isDone) {
      updateRouteStack();
    }
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

class MaterialPageImp<T> extends MaterialPage<T> {
  // ignore: prefer_const_constructors_in_immutables
  MaterialPageImp({
    required Widget child,
    required this.customBuildTransitions,
    required this.transitionDuration,
    this.useTransition = true,
    bool maintainState = true,
    bool fullscreenDialog = false,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
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
  final Duration? transitionDuration;
  final bool useTransition;
  @override
  Route<T> createRoute(BuildContext context) {
    final shouldUseCupertinoPage = RouterObjects._shouldUseCupertinoPage ||
        Localizations.of<MaterialLocalizations>(
                context, MaterialLocalizations) ==
            null;
    if (shouldUseCupertinoPage) {
      return PageBasedCupertinoPageRoute<T>(
        page: this,
        customBuildTransitions: customBuildTransitions,
        transitionDuration: transitionDuration,
        useTransition: useTransition,
      );
    }
    return PageBasedMaterialPageRoute<T>(
      page: this,
      useTransition: useTransition,
      customBuildTransitions: customBuildTransitions,
      transitionDuration: transitionDuration,
    );
  }
}

class PageBasedMaterialPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  PageBasedMaterialPageRoute({
    required MaterialPage<T> page,
    required this.customBuildTransitions,
    required Duration? transitionDuration,
    this.useTransition = false,
  })  : _transitionDuration = transitionDuration,
        super(settings: page) {
    assert(opaque);
  }
  final bool useTransition;
  MaterialPage<T> get _page => settings as MaterialPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    if (_page.child is SubRoute) {
      return (_page.child as SubRoute).copyWith(
        animation: _animation,
        secondaryAnimation: _secondaryAnimation,
      );
    }
    return _page.child;
  }

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
  Animation<double>? _animation;
  Animation<double>? _secondaryAnimation;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )? customBuildTransitions;

  final Duration? _transitionDuration;

  @override
  Duration get transitionDuration {
    if (useTransition && RouterObjects.isTransitionAnimated != false) {
      return _transitionDuration ??
          const Duration(
            milliseconds: 300,
          );
    }
    return Duration.zero;
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
    _animation = animation;
    _secondaryAnimation = secondaryAnimation;
    if (!useTransition) {
      // RouterObjects.isTransitionAnimated = false;
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

class PageBasedCupertinoPageRoute<T> extends PageRoute<T>
    with CupertinoRouteTransitionMixin<T> {
  PageBasedCupertinoPageRoute({
    required MaterialPage<T> page,
    required this.customBuildTransitions,
    required Duration? transitionDuration,
    this.useTransition = false,
  })  : _transitionDuration = transitionDuration,
        super(settings: page) {
    assert(opaque);
  }
  final bool useTransition;
  Animation<double>? _animation;
  Animation<double>? _secondaryAnimation;
  MaterialPage<T> get _page => settings as MaterialPage<T>;

  @override
  Widget buildContent(BuildContext context) {
    if (_page.child is SubRoute) {
      return (_page.child as SubRoute).copyWith(
        animation: _animation,
        secondaryAnimation: _secondaryAnimation,
      );
    }
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
  final Duration? _transitionDuration;

  @override
  Duration get transitionDuration {
    if (useTransition && RouterObjects.isTransitionAnimated != false) {
      return _transitionDuration ??
          const Duration(
            milliseconds: 300,
          );
    }
    return Duration.zero;
  }

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    _animation = animation;
    _secondaryAnimation = secondaryAnimation;

    if (!useTransition) {
      // RouterObjects.isTransitionAnimated = false;
      return child;
    }

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

class _RootRouterWidget extends StatefulWidget {
  const _RootRouterWidget({
    Key? key,
    required this.dispose,
    required this.child,
  }) : super(key: key);
  final VoidCallback dispose;
  final Widget child;

  @override
  _RootRouterWidgetState createState() => _RootRouterWidgetState();
}

class _RootRouterWidgetState extends State<_RootRouterWidget> {
  @override
  void dispose() {
    super.dispose();
    widget.dispose();
    RouterObjects.injectedNavigator?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
