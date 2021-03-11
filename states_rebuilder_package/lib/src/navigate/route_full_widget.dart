part of '../reactive_model.dart';

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

  Map<int, Widget> _lastSubRoute = {};
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
    return _StateBuilder(
      isLite: true,
      initState: (context, setState, _) {
        final listener = (status) {
          if (status == AnimationStatus.completed) {
            animationIsRunning = false;
            setState(null);
          } else if (status == AnimationStatus.reverse) {
            animationIsRunning = true;
            setState(null);
          }
        };
        widget.animation!.addStatusListener(listener);
        return () {
          widget.animation!.removeStatusListener(listener);
        };
      },
      builder: (_, __) {
        return animationIsRunning ? stack : child;
      },
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
