part of '../rm.dart';

class _RouteFullWidget1 extends StatefulWidget {
  final Map<String, RouteSettingsWithChildAndData> pages;

  final Animation<double>? animation;
  final void Function()? initState;
  final void Function()? dispose;
  const _RouteFullWidget1({
    Key? key,
    required this.pages,
    this.animation,
    this.initState,
    this.dispose,
  }) : super(key: key);

  @override
  __RouteFullWidget1State createState() => __RouteFullWidget1State();
}

class __RouteFullWidget1State extends State<_RouteFullWidget1> {
  Widget? child;
  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() {
    Widget getChild({
      required List<String> keys,
      required Widget? route,
      required Widget? lastSubRoute,
    }) {
      var key = keys.last;
      final lastPage = widget.pages[key]!;
      child = SubRoute._(
        child: () {
          var c = lastPage.child;
          if (lastPage is RouteSettingsWithChildAndSubRoute) {
            if (route != null) {
              return (c as RouteWidget).builder!(route);
            }
            if (lastPage.subRoute != null) {
              return lastPage.subRoute!;
            }
            if (c is RouteWidget) {
              return c.builder!(route ?? const SizedBox());
            }
          }
          return c!;
        }(),
        route: route,
        lastSubRoute: lastSubRoute,
        routeData: RouteData(
          arguments: lastPage.arguments,
          urlPath: lastPage.name!,
          routePath: lastPage.routeUriPath,
          baseUrl: lastPage.baseUrlPath,
          queryParams: lastPage.queryParams,
          pathParams: lastPage.pathParams,
        ),
        animation: widget.animation,
        transitionsBuilder: lastPage.child is RouteWidget
            ? (lastPage.child as RouteWidget).transitionsBuilder
            : null,
        shouldAnimate: false,
        key: Key(key),
      );
      return child!;
    }

    var keys = widget.pages.keys.toList();
    getChild(keys: keys, route: null, lastSubRoute: null);
    while (true) {
      keys.removeLast();

      if (keys.isEmpty) {
        break;
      }
      final r = widget.pages[keys.last];
      if (r is RouteSettingsWithChildAndSubRoute) {
        final c = r.child as RouteWidget;
        if (c.builder != null) {
          getChild(
            keys: keys,
            route: child,
            lastSubRoute: null,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return child!;
  }
}

class _RouteFullWidget extends StatefulWidget {
  final Widget child;
  final Map<String, _RouteData> routeData;
  final Animation<double>? animation;
  final void Function()? initState;
  final void Function()? dispose;
  const _RouteFullWidget({
    Key? key,
    required this.child,
    required this.routeData,
    this.animation,
    this.initState,
    this.dispose,
  }) : super(key: key);

  @override
  __RouteFullWidgetState createState() => __RouteFullWidgetState();
}

class __RouteFullWidgetState extends State<_RouteFullWidget> {
  late Widget child;

  final Map<int, Widget> _lastSubRoute = {};
  late String _cachedBaseUrl;
  bool _isDeactivated = true;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();

    widget.initState?.call();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      return;
    }
    _isInit = true;
    _initState();
  }

  void _initState() {
    Map<String, _RouteData> routeData = widget.routeData;
    // print('routeData: ${widget.routeData}');

    assert(routeData.isNotEmpty);
    var keys = routeData.keys.toList();
    var key = keys.last;
    final c = routeData[key]!.builder!(Container());

    assert(routeData[key]!.subRoute == null); //TODO maybe not needed
    _cachedBaseUrl = _navigate._baseUrl;
    _navigate._baseUrl = routeData[key]!.routeData.baseUrl;
    child = SubRoute._(
      child: c,
      route: null,
      lastSubRoute: null,
      routeData: routeData[key]!.routeData,
      animation: widget.animation,
      transitionsBuilder: routeData[key]!.transitionsBuilder,
      shouldAnimate: false,
      key: Key(key),
    );
    keys.removeLast();
    if (keys.isEmpty) {
      return;
    }
    bool shouldAnimate = !routeData[key]!.routeData._isBaseUrlChanged;
    bool _shouldAnimate = shouldAnimate;
    for (var i = keys.length - 1; i >= 0; i--) {
      final data = routeData[keys[i]]!;

      // if (!_shouldAnimate && shouldAnimate) {
      //   // if (_shouldAnimate) {
      //   // _lastSubRoute = child;
      //   // }
      //   _shouldAnimate = true;
      // }

      _lastSubRoute[i] = child;
      final ch = shouldAnimate
          ? _getAnimatedChild(
              child,
              _lastSubRoutes.last[i],
              data.transitionsBuilder,
            )
          : child;

      child = SubRoute._(
        child: data.builder!(ch),
        route: ch,
        // lastSubRoute: _lastSubRoutes.isNotEmpty ? _lastSubRoutes.last : null,
        //lastSubRoute: v[keys[i]]?.subRoute ?? _lastSubRoutes.last,
        lastSubRoute: Container(),
        routeData: data.routeData,
        animation: widget.animation,
        transitionsBuilder: data.transitionsBuilder,
        shouldAnimate: shouldAnimate,
        key: Key(key),
      );
      shouldAnimate =
          _shouldAnimate ? false : !data.routeData._isBaseUrlChanged;
    }
  }

  Widget _getAnimatedChild(
    Widget child,
    Widget lastChild,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transitionsBuilder,
  ) {
    final buildTransition = transitionsBuilder ??
        _navigate.transitionsBuilder ??
        _getThemeTransition!;

    bool animationIsRunning = true;
    final stack = Stack(
      children: [
        lastChild,
        buildTransition(
          context,
          widget.animation!,
          widget.animation!,
          child,
        )
      ],
    );
    return StateBuilderBase(
      (_, setState) {
        void listener(status) {
          if (status == AnimationStatus.completed) {
            animationIsRunning = false;
            setState();
          } else if (status == AnimationStatus.reverse) {
            animationIsRunning = true;
            setState();
          }
        }

        widget.animation!.addStatusListener(listener);
        return LifeCycleHooks(
          dispose: (_) => widget.animation!.removeStatusListener(listener),
          builder: (_, __) {
            return animationIsRunning ? stack : child;
          },
        );
      },
      widget: Container(),
    );
  }

  @override
  void deactivate() {
    _isDeactivated = true;
    super.deactivate();
    _navigate._baseUrl = _cachedBaseUrl;
    _lastSubRoutes.remove(_lastSubRoute);
    _activeSubRoutes.remove(widget.routeData);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeactivated) {
      _isDeactivated = false;
      widget.initState?.call();

      if (_lastSubRoute.isNotEmpty) {
        _lastSubRoutes.add(_lastSubRoute);
      }
    }
    return child;
  }
}

final _lastSubRoutes = [];
final List<Map<String, _RouteData>> _activeSubRoutes = [];
