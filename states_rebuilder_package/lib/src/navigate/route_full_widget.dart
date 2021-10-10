part of '../rm.dart';

class _RouteFullWidget1 extends StatefulWidget {
  final Map<String, RouteSettingsWithChildAndData> pages;

  final Animation<double>? animation;
  final void Function()? initState;
  final void Function()? dispose;

  _RouteFullWidget1({
    Key? key,
    required this.pages,
    this.animation,
    this.initState,
    this.dispose,
  }) : super(key: key) {
    print('');
  }

  @override
  __RouteFullWidget1State createState() => __RouteFullWidget1State();
}

Widget get routeNotDefinedAssertion {
  return Builder(
    builder: (_) {
      assert(() {
        StatesRebuilerLogger.log(
          'NO sub-routes is defined',
          'You are trying to use a sub-route inside the builder '
              'of RouteWidget But the parameter "routes" of RouteWidget '
              'is not defined\n'
              'Do not use the exposed route widget or define routes '
              'parameters',
        );
        return false;
      }());

      return const SizedBox();
    },
  );
}

Widget getWidgetFromPages({
  required Map<String, RouteSettingsWithChildAndData> pages,
  Animation<double>? animation,
}) {
  late Widget child;
  Widget getChild({
    required List<String> keys,
    required Widget? route,
    required Widget? lastSubRoute,
  }) {
    var key = keys.last;
    final lastPage = pages[key]!;
    var c = lastPage.child;
    if (c is RouteWidget) {
      route ??= (lastPage as RouteSettingsWithChildAndSubRoute).subRoute ??
          routeNotDefinedAssertion;
    }
    child = SubRoute._(
      child: () {
        if (lastPage is RouteSettingsWithChildAndSubRoute) {
          if (c is RouteWidget) {
            if (c.builder != null) {
              return c.builder!(route!);
            }
          }
          return lastPage.subRoute!;
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
      animation: animation,
      transitionsBuilder: lastPage.child is RouteWidget
          ? (lastPage.child as RouteWidget).transitionsBuilder
          : null,
      shouldAnimate: true,
      key: Key(key),
    );
    return child;
  }

  var keys = pages.keys.toList();
  getChild(keys: keys, route: null, lastSubRoute: null);
  while (true) {
    keys.removeLast();

    if (keys.isEmpty) {
      break;
    }
    final r = pages[keys.last];
    if (r is RouteSettingsWithChildAndSubRoute) {
      final c = r.child as RouteWidget;
      if (c.builder != null && c.routes.isNotEmpty) {
        getChild(
          keys: keys,
          route: child,
          lastSubRoute: null,
        );
      }
    }
  }

  return child;
}

class __RouteFullWidget1State extends State<_RouteFullWidget1> {
  Widget? child;

  @override
  void initState() {
    super.initState();
    child = getWidgetFromPages(
      pages: widget.pages,
      animation: widget.animation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return child!;
  }
}

// class _RouteFullWidget extends StatefulWidget {
//   final Widget child;
//   final Map<String, _RouteData> routeData;
//   final Animation<double>? animation;
//   final void Function()? initState;
//   final void Function()? dispose;
//   const _RouteFullWidget({
//     Key? key,
//     required this.child,
//     required this.routeData,
//     this.animation,
//     this.initState,
//     this.dispose,
//   }) : super(key: key);

//   @override
//   __RouteFullWidgetState createState() => __RouteFullWidgetState();
// }

// class __RouteFullWidgetState extends State<_RouteFullWidget> {
//   late Widget child;

//   final Map<int, Widget> _lastSubRoute = {};
//   late String _cachedBaseUrl;
//   bool _isDeactivated = true;
//   bool _isInit = false;

//   @override
//   void initState() {
//     super.initState();

//     widget.initState?.call();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (_isInit) {
//       return;
//     }
//     _isInit = true;
//     _initState();
//   }

//   void _initState() {
//     Map<String, _RouteData> routeData = widget.routeData;
//     // print('routeData: ${widget.routeData}');

//     assert(routeData.isNotEmpty);
//     var keys = routeData.keys.toList();
//     var key = keys.last;
//     final c = routeData[key]!.builder!(Container());

//     assert(routeData[key]!.subRoute == null); //TODO maybe not needed
//     _cachedBaseUrl = _navigate._baseUrl;
//     _navigate._baseUrl = routeData[key]!.routeData.baseUrl;
//     child = SubRoute._(
//       child: c,
//       route: null,
//       lastSubRoute: null,
//       routeData: routeData[key]!.routeData,
//       animation: widget.animation,
//       transitionsBuilder: routeData[key]!.transitionsBuilder,
//       shouldAnimate: false,
//       key: Key(key),
//     );
//     keys.removeLast();
//     if (keys.isEmpty) {
//       return;
//     }
//     bool shouldAnimate = !routeData[key]!.routeData._isBaseUrlChanged;
//     bool _shouldAnimate = shouldAnimate;
//     for (var i = keys.length - 1; i >= 0; i--) {
//       final data = routeData[keys[i]]!;

//       // if (!_shouldAnimate && shouldAnimate) {
//       //   // if (_shouldAnimate) {
//       //   // _lastSubRoute = child;
//       //   // }
//       //   _shouldAnimate = true;
//       // }

//       _lastSubRoute[i] = child;
//       final ch = shouldAnimate
//           ? _getAnimatedChild(
//               child,
//               _lastSubRoutes.last[i],
//               data.transitionsBuilder,
//             )
//           : child;

//       child = SubRoute._(
//         child: data.builder!(ch),
//         route: ch,
//         // lastSubRoute: _lastSubRoutes.isNotEmpty ? _lastSubRoutes.last : null,
//         //lastSubRoute: v[keys[i]]?.subRoute ?? _lastSubRoutes.last,
//         lastSubRoute: Container(),
//         routeData: data.routeData,
//         animation: widget.animation,
//         transitionsBuilder: data.transitionsBuilder,
//         shouldAnimate: shouldAnimate,
//         key: Key(key),
//       );
//       shouldAnimate =
//           _shouldAnimate ? false : !data.routeData._isBaseUrlChanged;
//     }
//   }

//   Widget _getAnimatedChild(
//     Widget child,
//     Widget lastChild,
//     Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
//         transitionsBuilder,
//   ) {
//     final buildTransition = transitionsBuilder ??
//         _navigate.transitionsBuilder ??
//         _getThemeTransition!;

//     bool animationIsRunning = true;
//     final stack = Stack(
//       children: [
//         lastChild,
//         buildTransition(
//           context,
//           widget.animation!,
//           widget.animation!,
//           child,
//         )
//       ],
//     );
//     return StateBuilderBase(
//       (_, setState) {
//         void listener(status) {
//           if (status == AnimationStatus.completed) {
//             animationIsRunning = false;
//             setState();
//           } else if (status == AnimationStatus.reverse) {
//             animationIsRunning = true;
//             setState();
//           }
//         }

//         widget.animation!.addStatusListener(listener);
//         return LifeCycleHooks(
//           dispose: (_) => widget.animation!.removeStatusListener(listener),
//           builder: (_, __) {
//             return animationIsRunning ? stack : child;
//           },
//         );
//       },
//       widget: Container(),
//     );
//   }

//   @override
//   void deactivate() {
//     _isDeactivated = true;
//     super.deactivate();
//     _navigate._baseUrl = _cachedBaseUrl;
//     _lastSubRoutes.remove(_lastSubRoute);
//     _activeSubRoutes.remove(widget.routeData);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isDeactivated) {
//       _isDeactivated = false;
//       widget.initState?.call();

//       if (_lastSubRoute.isNotEmpty) {
//         _lastSubRoutes.add(_lastSubRoute);
//       }
//     }
//     return child;
//   }
// }

// final _lastSubRoutes = [];
// final List<Map<String, _RouteData>> _activeSubRoutes = [];
