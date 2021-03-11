part of '../reactive_model.dart';

final _navigate = _Navigate();

class _Navigate {
  ///get the NavigatorState
  NavigatorState get navigatorState {
    final navigatorState = _navigatorKey.currentState;
    assert(navigatorState != null, '''
The MaterialApp has no defined navigatorKey.

To fix:
MaterialApp(
   navigatorKey: RM.navigate.navigatorKey,
   //
   //
)
''');
    return navigatorState!;
  }

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey {
    return _navigatorKey;
  }

  ///Creates a route that delegates to builder callbacks. It is used to animate
  ///page transition.
  ///
  ///If defined, it overrides the [transitionsBuilder].
  ///
  ///Similar ot [PageRouteBuilder]
  ///
  PageRoute Function(Widget nextPage)? pageRouteBuilder;

  ///Used to change the page animation transition.
  ///
  ///You can defined your custom transitions builder or use one
  ///of the four predefined transitions :
  ///* [_Transitions.rightToLeft]
  ///* [_Transitions.leftToRight]
  ///* [_Transitions.upToBottom]
  ///* [_Transitions.bottomToUp]
  Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? transitionsBuilder;

  bool _fullscreenDialog = false;
  bool _maintainState = true;

  //For onGenerateRoute
  late Map<String, Widget Function(RouteData data)> _routes;
  Map<String, _RouteData> _routeData = {};
  RouteData? routeData;

  String _urlPath = '';
  String _baseUrl = '';
  String _routePath = '';
  dynamic _routeArguments;
  Map<String, String> _routeQueryParams = {};
  Map<String, String> _routePathParams = {};

  ///It takes the map of routes and return the onGenerateRoute to be used
  ///in the [MaterialApp.onGenerateRoute]
  ///
  ///The routes map is of type `<String, Widget Function(Object? arguments)>`
  ///where arguments is the [RouteSettings.settings.arguments]
  ///
  ///You can provide the the route page transition builder usning [transitionsBuilder] and the
  ///unknown route page using [unknownRoute]
  ///
  Route<dynamic>? Function(RouteSettings settings) onGenerateRoute(
    Map<String, Widget Function(RouteData data)> routes, {
    Widget Function(
      BuildContext,
      Animation<double>,
      Animation<double>,
      Widget,
    )?
        transitionsBuilder,
    Widget Function(String routeName)? unknownRoute,
  }) {
    assert(routes.isNotEmpty);
    this.transitionsBuilder = transitionsBuilder;
    _routes = routes;
    _baseUrl = '';
    pageRouteBuilder = null;
    Widget? resolvePage(RouteSettings settings) {
      assert(settings.name != null);

      final uri = Uri.parse(settings.name!);
      late Uri routeUri;
      late String childName;

      var name = _routes.keys.firstWhereOrNull(
        (key) {
          final matcher = _isMatched(
            Uri.parse(key),
            uri,
          );
          if (matcher.first == true) {
            routeUri = matcher[1];
            childName = matcher[2];

            return true;
          }
          return false;
        },
      );

      final route = _routes[name];
      if (route != null) {
        _routeArguments = settings.arguments;
        if (uri.queryParameters.isNotEmpty) {
          _routeQueryParams.addAll(uri.queryParameters);
        }
        if (routeUri.queryParameters.isNotEmpty) {
          _routePathParams.addAll(routeUri.queryParameters);
        }

        _urlPath += routeUri.path;
        _routePath += name!;
        routeData = RouteData(
          baseUrl: _getBaseUrl(_urlPath),
          routePath: _routePath,
          arguments: _routeArguments,
          queryParams: {..._routeQueryParams},
          pathParams: {..._routePathParams},
        );
        routeData!._isBaseUrlChanged =
            _baseUrl.isEmpty ? true : !_baseUrl.startsWith(routeData!.baseUrl);

        Widget page = route(routeData!);

        if (page is RouteWidget) {
          if (page.routes.isEmpty) {
            name = _routeData.containsKey(name)
                ? '$name' + '${_routeData.length}'
                : name;
            _routeData[name] = _RouteData(
              builder: page.builder,
              subRoute: null,
              transitionsBuilder: page.transitionsBuilder,
              routeData: routeData!,
            );
            return page.builder!(Container());
          } else {
            if (page.builder != null) {
              name = _routeData.containsKey(name)
                  ? '$name' + '${_routeData.length}'
                  : name;
              _routeData[name] = _RouteData(
                builder: page.builder,
                subRoute: null,
                transitionsBuilder: page.transitionsBuilder,
                routeData: routeData!,
              );
            }

            final n = childName.startsWith('/') ? childName : '/$childName';
            _routes = page.routes;
            final p = resolvePage(settings.copyWith(name: n));
            _routes = routes;
            if (p != null) {
              if (page.builder != null) {
                _routeData[name] = _routeData[name]!.copyWith(subRoute: p);
              }
              return p;
            }
            return null;
          }
        }
        name = _routeData.containsKey(name)
            ? '$name' + '${_routeData.length}'
            : name;
        _routeData[name] = _RouteData(
          builder: (_) => page,
          routeData: routeData!,
          subRoute: null,
          transitionsBuilder: null,
        );
        return page;
      }
      return null;
    }

    return (RouteSettings settings) {
      _routeData.clear();
      routeData = null;
      _routeQueryParams.clear();
      _routePathParams.clear();
      _routeArguments = null;

      _urlPath = '';
      _routePath = '';
      late String absolutePath;
      if (settings.name!.startsWith('/')) {
        absolutePath = settings.name!;
      } else {
        if (_baseUrl == '') {
          absolutePath = '/' + settings.name!;
        } else {
          String relativeBasePath = _getBaseUrl('/' + settings.name!);
          String? p;
          while (relativeBasePath.isNotEmpty) {
            // add '/' to ensure the route name and not a stirng containing the name
            final r = (_baseUrl + '/').split(relativeBasePath + '/');
            if (r.length > 1) {
              r.removeLast();
              p = r.join('/');
            }
            if (p != null) {
              break;
            }
            relativeBasePath = _getBaseUrl(relativeBasePath);
          }

          absolutePath = (p ?? _baseUrl) + '/' + settings.name!;
        }
      }

      settings = settings.copyWith(name: absolutePath);

      final page = resolvePage(settings);
      if (page != null) {
        bool isSubRouteTransition = _routeData.values.any(
          (e) {
            return !e.routeData._isBaseUrlChanged;
          },
        );
        final _routeDataCopy = {..._routeData};

        final r = _pageRouteBuilder(
          (animation) {
            return _RouteFullWidget(
              child: page,
              routeData: _routeDataCopy,
              animation: animation,
              key: Key(_routeDataCopy.keys.toString()),
            );
          },
          RouteSettings(
            name: settings.name,
            arguments: _routeArguments,
          ),
          _fullscreenDialog,
          _maintainState,
          isSubRouteTransition: isSubRouteTransition,
        );
        //set to default
        _fullscreenDialog = false;
        _maintainState = true;
        return r;
      } else {
        return unknownRoute != null
            ? _pageRouteBuilder(
                (_) => unknownRoute(absolutePath), settings, false, true)
            : null;
      }
    };
  }

  static Duration? _transitionDuration;
  PageRoute<T> _pageRouteBuilder<T>(
    Widget Function(Animation<double>? animation) page,
    RouteSettings? settings,
    bool fullscreenDialog,
    bool maintainState, {
    bool isSubRouteTransition = false,
  }) {
    Widget? _page;
    return pageRouteBuilder != null
        ? pageRouteBuilder!.call(_page ??= page(null)) as PageRoute<T>
        : _PageRouteBuilder<T>(
            builder: (context, animation) => _page ??= page(animation),
            settings: settings,
            fullscreenDialog: fullscreenDialog,
            maintainState: maintainState,
            isSubRouteTransition: isSubRouteTransition,
            customBuildTransitions: transitionsBuilder,
            transitionDuration: _transitionDuration ??
                const Duration(
                  milliseconds: 300,
                ),
            reverseTransitionDuration: _transitionDuration ??
                const Duration(
                  milliseconds: 300,
                ),
          );
    // : _MaterialPageRoute<T>(
    //     settings: settings != null ? settings : null,
    //     builder: (_, animation) => _page ??= page(animation),
    //     fullscreenDialog: fullscreenDialog,
    //     maintainState: maintainState,
    //   );
  }

  ///navigate to the given page.
  ///
  ///You can specify a name to the route  (e.g., "/settings"). It will be used with
  ///[backUntil], [toAndRemoveUntil]; [toAndRemoveUntil], [toNamedAndRemoveUntil]
  ///
  ///Equivalent to: [NavigatorState.push]
  Future<T?> to<T extends Object?>(
    Widget page, {
    String? name,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    return navigatorState.push<T>(
      _pageRouteBuilder(
        (_) => page,
        RouteSettings(name: name),
        fullscreenDialog,
        maintainState,
      ),
    );
  }

  ///Navigate to the page with the given named route.
  ///
  ///Equivalent to: [NavigatorState.pushNamed]
  Future<T?> toNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
    Map<String, String>? queryParams,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    _fullscreenDialog = fullscreenDialog;
    _maintainState = maintainState;
    if (queryParams != null) {
      routeName = Uri(path: routeName, queryParameters: queryParams).toString();
    }

    return navigatorState.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  ///Navigate to the given page, and remove the current route and replace it
  ///with the new one.
  ///
  ///You can specify a name to the route  (e.g., "/settings"). It will be used with
  ///[backUntil], [toAndRemoveUntil]; [toAndRemoveUntil], [toNamedAndRemoveUntil]
  ///
  ///Equivalent to: [NavigatorState.pushReplacement]
  Future<T?> toReplacement<T extends Object?, TO extends Object?>(
    Widget page, {
    TO? result,
    String? name,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    return navigatorState.pushReplacement<T, TO>(
      _pageRouteBuilder(
        (_) => page,
        RouteSettings(name: name),
        fullscreenDialog,
        maintainState,
      ),
      result: result,
    );
  }

  ///Navigate to the page with the given named route, and remove the current
  ///route and replace it with the new one.
  ///
  ///Equivalent to: [NavigatorState.pushReplacementNamed]
  Future<T?> toReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
    Map<String, String>? queryParams,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    _fullscreenDialog = fullscreenDialog;
    _maintainState = maintainState;
    if (queryParams != null) {
      routeName = Uri(path: routeName, queryParameters: queryParams).toString();
    }
    return navigatorState.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  ///Navigate to the given page, and then remove all the previous routes until
  ///meeting the route with defined route name [untilRouteName].
  ///
  ///If no route name is given ([untilRouteName] is null) , all routes will be
  ///removed except the new page route.
  ///
  ///You can specify a name to the route  (e.g., "/settings"). It will be used with
  ///[backUntil], [toAndRemoveUntil]; [toAndRemoveUntil], [toNamedAndRemoveUntil].
  ///
  ///
  ///Equivalent to: [NavigatorState.pushAndRemoveUntil]
  Future<T?> toAndRemoveUntil<T extends Object?>(
    Widget page, {
    String? untilRouteName,
    String? name,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    return navigatorState.pushAndRemoveUntil<T>(
      _pageRouteBuilder(
        (_) => page,
        RouteSettings(name: name),
        fullscreenDialog,
        maintainState,
      ),
      untilRouteName != null
          ? ModalRoute.withName(untilRouteName)
          : (r) => false,
    );
  }

  ///Navigate to the page with the given named route (first argument), and then
  ///remove all the previous routes until meeting the route with defined route
  ///name [untilRouteName].
  ///
  ///If no route name is given ([untilRouteName] is null) , all routes will be
  ///removed except the new page route.
  ///
  ///Equivalent to: [NavigatorState.pushNamedAndRemoveUntil]
  Future<T?> toNamedAndRemoveUntil<T extends Object?>(
    String newRouteName, {
    String? untilRouteName,
    Map<String, String>? queryParams,
    Object? arguments,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    _fullscreenDialog = fullscreenDialog;
    _maintainState = maintainState;
    if (queryParams != null) {
      newRouteName =
          Uri(path: newRouteName, queryParameters: queryParams).toString();
    }
    return navigatorState.pushNamedAndRemoveUntil<T>(
      newRouteName,
      untilRouteName != null
          ? ModalRoute.withName(untilRouteName)
          : (r) => false,
      arguments: arguments,
    );
  }

  ///Navigate back to the last page, ie
  ///Pop the top-most route off the navigator.
  ///
  ///Equivalent to: [NavigatorState.pop]
  void back<T extends Object>([T? result]) {
    navigatorState.pop<T>(result);
  }

  ///Navigate back and remove all the previous routes until meeting the route
  ///with defined name
  ///
  ///Equivalent to: [NavigatorState.popUntil]
  void backUntil(String untilRouteName) {
    return navigatorState.popUntil(
      ModalRoute.withName(untilRouteName),
    );
  }

  ///Navigate back than to the page with the given named route
  ///
  ///Equivalent to: [NavigatorState.popAndPushNamed]
  Future<T?> backAndToNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    _fullscreenDialog = fullscreenDialog;
    _maintainState = maintainState;
    return navigatorState.popAndPushNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  ///Displays a Material dialog above the current contents of the app, with
  ///Material entrance and exit animations, modal barrier color, and modal
  ///barrier behavior (dialog is dismissible with a tap on the barrier).
  ///
  ///* Required parameters:
  ///  * [dialog]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [barrierDismissible]: Whether dialog is dismissible when tapping
  /// outside it. Default value is true.
  ///  * [barrierColor]: the color of the modal barrier that darkens everything
  /// the dialog. If null the default color Colors.black54 is used.
  ///  * [useSafeArea]: Whether the dialog should only display in 'safe' areas
  /// of the screen. Default value is true.
  ///
  ///Equivalent to: [showDialog].
  Future<T?> toDialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
  }) {
    return showDialog<T>(
      context: navigatorState.context,
      builder: (_) => dialog,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
    );
  }

  ///Displays an iOS-style dialog above the current contents of the app, with
  ///iOS-style entrance and exit animations, modal barrier color, and modal
  ///barrier behavior
  ///
  ///* Required parameters:
  ///  * [dialog]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [barrierDismissible]: Whether dialog is dismissible when tapping
  /// outside it. Default value is false.
  ///
  ///Equivalent to: [showCupertinoDialog].
  Future<T?> toCupertinoDialog<T>(
    Widget dialog, {
    bool barrierDismissible = false,
  }) {
    return showCupertinoDialog<T>(
      context: navigatorState.context,
      builder: (_) => dialog,
      barrierDismissible: barrierDismissible,
    );
  }

  ///Shows a modal material design bottom sheet that prevents the user from
  ///interacting with the rest of the app.
  ///
  ///A closely related widget is the persistent bottom sheet, which allows
  ///the user to interact with the rest of the app. Persistent bottom sheets
  ///can be created and displayed with the (RM.scaffoldShow.bottomSheet) or
  ///[showBottomSheet] Methods.
  ///
  ///
  ///* Required parameters:
  ///  * [bottomSheet]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [isDismissible]: whether the bottom sheet will be dismissed when user
  /// taps on the scrim. Default value is true.
  ///  * [enableDrag]: whether the bottom sheet can be dragged up and down and
  /// dismissed by swiping downwards. Default value is true.
  ///  * [isScrollControlled]: whether this is a route for a bottom sheet that
  /// will utilize [DraggableScrollableSheet]. If you wish to have a bottom
  /// sheet that has a scrollable child such as a [ListView] or a [GridView]
  /// and have the bottom sheet be draggable, you should set this parameter
  /// to true.Default value is false.
  ///  * [backgroundColor], [elevation], [shape], [clipBehavior] and
  /// [barrierColor]: used to customize the appearance and behavior of modal
  /// bottom sheets
  ///
  ///Equivalent to: [showModalBottomSheet].
  Future<T?> toBottomSheet<T>(
    Widget bottomSheet, {
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: navigatorState.context,
      builder: (_) => bottomSheet,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  ///Shows a modal iOS-style popup that slides up from the bottom of the screen.
  ///* Required parameters:
  ///  * [cupertinoModalPopup]:  (positional parameter) Widget to display.
  /// * optional parameters:
  ///  * [filter]:
  ///  * [semanticsDismissible]: whether the semantics of the modal barrier are
  /// included in the semantics tree
  Future<T?> toCupertinoModalPopup<T>(
    Widget cupertinoModalPopup, {
    ImageFilter? filter,
    bool? semanticsDismissible,
  }) {
    return showCupertinoModalPopup<T>(
      context: navigatorState.context,
      builder: (_) => cupertinoModalPopup,
      semanticsDismissible: semanticsDismissible,
      filter: filter,
    );
  }
}

List<dynamic> _isMatched(Uri route, Uri url) {
  Map<String, String>? params;
  if (route.pathSegments.length > url.pathSegments.length) {
    return [false, null, null];
  }
  if (route.pathSegments.length == 0) {
    if (url.pathSegments.length == 0) {
      return [true, route, ''];
    } else {
      return [false, null, null];
    }
  }

  String parsedUrl = '';
  for (var i = 0; i < route.pathSegments.length; i++) {
    if (route.pathSegments[i].startsWith(':')) {
      params ??= {};
      params[route.pathSegments[i].substring(1)] = url.pathSegments[i];
    } else {
      if (route.pathSegments[i] != url.pathSegments[i]) {
        return [false, params, ''];
      }
    }
    parsedUrl += '/${url.pathSegments[i]}';
  }
  return [
    true,
    route.replace(path: parsedUrl, queryParameters: params),
    url.path.replaceFirst(parsedUrl, ''),
  ];
}

String _getBaseUrl(String path) {
  final segments = path.split('/');
  segments.removeLast();
  return segments.join('/');
}
