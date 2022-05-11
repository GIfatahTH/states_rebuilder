part of 'injected_navigator.dart';

final navigateObject = _Navigate();

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
  PageRoute Function(Widget nextPage, RouteSettings? settings)?
      pageRouteBuilder;

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

  static Duration? _transitionDuration;

  bool _fullscreenDialog = false;
  bool _maintainState = true;
  final _resolvePathRouteUtil = ResolvePathRouteUtil();

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
    Map<String, Widget Function(RouteData data)> routes_, {
    Widget Function(
      BuildContext,
      Animation<double>,
      Animation<double>,
      Widget,
    )?
        transitionsBuilder,
    Widget Function(String routeName)? unknownRoute,
  }) {
    assert(routes_.isNotEmpty);
    if (transitionsBuilder != null) {
      this.transitionsBuilder = transitionsBuilder;
    }
    RouterObjects._routers = RouterObjects.transformRoutes(routes_);
    pageRouteBuilder = null;

    return (RouteSettings settings) {
      final pages = _resolvePathRouteUtil.getPagesFromRouteSettings(
        routes: RouterObjects._routers!,
        settings: settings,
        unknownRoute:
            unknownRoute != null ? (data) => unknownRoute(data.location) : null,
        skipHomeSlash: true,
      )!;

      if (pages.isNotEmpty) {
        bool isSubRouteTransition = pages.values.any(
          (e) {
            if (e is RouteSettingsWithRouteWidget) {
              // return !e.isBaseUrlChanged;
            }
            return false;
          },
        );
        final r = _pageRouteBuilder(
          (animation) {
            return getWidgetFromPages(
              pages: pages,
              animation: animation,
            );
          },
          RouteSettings(
            name: _resolvePathRouteUtil.absolutePath,
            arguments: settings.arguments,
          ),
          _fullscreenDialog,
          _maintainState,
          isSubRouteTransition: isSubRouteTransition,
        );
        //set to default
        _fullscreenDialog = false;
        _maintainState = true;
        return r;
      }
      return null;
    };
  }

  PageRoute<T> _pageRouteBuilder<T>(
    Widget Function(Animation<double>? animation) page,
    RouteSettings? settings,
    bool fullscreenDialog,
    bool maintainState, {
    bool isSubRouteTransition = false,
    Widget Function(
      BuildContext,
      Animation<double>,
      Animation<double>,
      Widget,
    )?
        transitionsBuilder,
  }) {
    Widget? _page;
    return pageRouteBuilder != null
        ? pageRouteBuilder!.call(_page ??= page(null), settings) as PageRoute<T>
        : _PageRouteBuilder<T>(
            builder: (context, animation) {
              return _page ??= page(animation);
            },
            settings: settings,
            fullscreenDialog: fullscreenDialog,
            maintainState: maintainState,
            isSubRouteTransition: isSubRouteTransition,
            customBuildTransitions:
                transitionsBuilder ?? this.transitionsBuilder,
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

  void setRouteStack(
    List<PageSettings> Function(List<PageSettings> pages) stack, {
    String? subRouteName,
  }) {
    if (subRouteName == null) {
      RouterObjects.rootDelegate!.setRouteStack(stack);
    } else {
      var absoluteName = _resolvePathRouteUtil.setAbsoluteUrlPath(subRouteName);
      absoluteName =
          absoluteName.endsWith('/') ? absoluteName : absoluteName + '/';
      final delegate = RouterObjects._getNavigator2Delegate(absoluteName);
      if (delegate == null) {
        StatesRebuilerLogger.log(
          '',
          'There are no sub route with $subRouteName name',
        );
      }
      delegate!.setRouteStack(stack);
    }
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
    if (RouterObjects.rootDelegate != null && name != null) {
      _fullscreenDialog = fullscreenDialog;
      _maintainState = maintainState;
      return RouterObjects.rootDelegate!.to<T>(
        PageSettings(
          name: name,
          child: page,
        ),
      );
    }
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
    Widget Function(Widget route)? builder,
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondAnimation,
      Widget child,
    )?
        transitionsBuilder,
  }) {
    _fullscreenDialog = fullscreenDialog;
    _maintainState = maintainState;

    if (RouterObjects.rootDelegate != null) {
      final absoluteName = _resolvePathRouteUtil.setAbsoluteUrlPath(routeName);
      var delegate = RouterObjects._getNavigator2Delegate(absoluteName);

      final child = delegate!.getPagesFromRouteSettings(
        settings: PageSettings(
          name: absoluteName,
          arguments: arguments,
          queryParams: queryParams ?? {},
          builder: builder,
        ),
        redirectedFrom: [],
        skipHomeSlash: true,
      );
      final page = child?.values.last;
      if (page == null) {
        return Future.value(null);
      }
      if (delegate.delegateName != RouterObjects.rootName &&
          !page.name!.startsWith(delegate.delegateName)) {
        delegate = RouterObjects._getNavigator2Delegate(page.name!);
      }
      Future<T?> fn() {
        return delegate!.to<T>(
          child!.values.last,
          // PageSettings(
          //   name: absoluteName,
          //   arguments: arguments,
          //   queryParams: queryParams ?? {},
          // ),
        );
      }

      if (transitionsBuilder != null) {
        final cacheTransitionsBuilder = delegate!.transitionsBuilder;
        final cacheTransitionDuration = delegate.transitionDuration;
        delegate.transitionsBuilder = transitionsBuilder;
        delegate.transitionDuration = _Navigate._transitionDuration;
        final r = fn();
        delegate.transitionsBuilder = cacheTransitionsBuilder;
        delegate.transitionDuration = cacheTransitionDuration;
        return r;
      }
      return fn();
    }
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

    if (RouterObjects.rootDelegate != null) {
      final absoluteName = _resolvePathRouteUtil.setAbsoluteUrlPath(routeName);
      final delegate = RouterObjects._toBack(null);
      final config = delegate?._lastLeafConfiguration;
      final r = toNamed<T>(
        absoluteName,
        arguments: arguments,
        queryParams: queryParams,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
      );
      // if (delegate?._canPop == true) {
      RouterDelegateImp.shouldMarkForComplete = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        RouterDelegateImp.shouldMarkForComplete = false;
      });
      delegate!.remove<TO>(config!.name!, result);
      // }
      return r;
    }
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

    if (RouterObjects.rootDelegate != null) {
      final absoluteName =
          _resolvePathRouteUtil.setAbsoluteUrlPath(newRouteName);
      RouterDelegateImp.shouldMarkForComplete = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        RouterDelegateImp.shouldMarkForComplete = false;
      });
      bool isDone = false;
      if (untilRouteName != null) {
        isDone = RouterObjects._backUntil(untilRouteName);
      } else {
        RouterObjects.rootDelegate!._pageSettingsList.clear();
        isDone = true;
      }
      if (!isDone) {
        return Future.value(null);
        // final delegate = RouterObjects._getNavigator2Delegate(absoluteName);
        // if (delegate != null) {
        //   return delegate.toNamedAndRemoveUntil<T>(
        //     PageSettings(
        //       name: absoluteName,
        //       arguments: arguments,
        //       queryParams: queryParams ?? {},
        //     ),
        //     untilRouteName,
        //   );
        // }
      }
      return toNamed(
        absoluteName,
        arguments: arguments,
        queryParams: queryParams,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
      );
    }

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

  /// Navigate back to the last page, ie
  /// Pop the top-most route off the navigator.
  ///
  /// Equivalent to: [NavigatorState.pop]
  ///
  /// See also: [forceBack]
  void back<T extends Object>([T? result]) {
    final cache = RouterObjects.rootDelegate?.delegateImplyLeadingToParent;
    RouterObjects.rootDelegate?.delegateImplyLeadingToParent = true;
    navigatorState.pop<T>(result);
    RouterObjects.rootDelegate?.delegateImplyLeadingToParent = cache ?? true;
  }

  ///{@template forceBack}

  /// Navigate Back by popping the top-most page route with all pagesless route
  /// associated with it and without calling `onNavigateBack` hook.
  ///
  /// For example:
  /// In case a `Dialog` (a `Dialog` is an example pageless route) is displayed and
  /// we invoke `forceBack`, the dialog and the last page are popped from route stack.
  /// Contrast this with the case when we call [back] where only the dialog is popped.
  /// {@endtemplate}
  /// See also: [back]
  ///
  void forceBack<T extends Object>([T? result]) {
    if (RouterObjects.canPop) {
      RouterObjects.rootDelegate!
        ..forceBack = true
        ..rootDelegatePop(result);
    } else {
      RouterObjects.rootDelegate!.navigatorKey!.currentState!.pop();
      SystemNavigator.pop();
    }
  }

  ///Navigate back and remove all the previous routes until meeting the route
  ///with defined name
  ///
  ///Equivalent to: [NavigatorState.popUntil]
  void backUntil(String untilRouteName) {
    if (RouterObjects.rootDelegate != null) {
      RouterObjects._backUntil(untilRouteName);
      return;
    }

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

    final delegate = RouterObjects._getNavigator2Delegate(routeName);
    if (delegate != null) {
      return delegate.backAndToNamed<T, TO>(
        PageSettings(name: routeName, arguments: arguments),
        result,
      );
    }
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
    bool postponeToNextFrame = false,
  }) {
    Future<T?> fn() {
      try {
        return showDialog<T>(
          context: navigatorState.context,
          builder: (_) => dialog,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          useSafeArea: useSafeArea,
        );
      } catch (e) {
        if (!postponeToNextFrame) {
          StatesRebuilerLogger.log(
            'Try setting `toDialog.postponeToNextFrame` argument to true',
            e,
          );
        }
        rethrow;
      }
    }

    if (postponeToNextFrame) {
      Completer<T?> completer = Completer<T?>();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final r = fn();
        completer.complete(r);
      });
      return completer.future;
    }
    return fn();
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
    bool postponeToNextFrame = false,
  }) {
    Future<T?> fn() {
      try {
        return showCupertinoDialog<T>(
          context: navigatorState.context,
          builder: (_) => dialog,
          barrierDismissible: barrierDismissible,
        );
      } catch (e) {
        if (!postponeToNextFrame) {
          StatesRebuilerLogger.log(
            'Try setting `toCupertinoDialog.postponeToNextFrame` argument to true',
            e,
          );
        }
        rethrow;
      }
    }

    if (postponeToNextFrame) {
      Completer<T?> completer = Completer<T?>();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final r = fn();
        completer.complete(r);
      });
      return completer.future;
    }
    return fn();
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
    bool postponeToNextFrame = false,
  }) {
    Future<T?> fn() {
      try {
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
      } catch (e) {
        if (!postponeToNextFrame) {
          StatesRebuilerLogger.log(
            'Try setting `toBottomSheet.postponeToNextFrame` argument to true',
            e,
          );
        }
        rethrow;
      }
    }

    if (postponeToNextFrame) {
      Completer<T?> completer = Completer<T?>();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final r = fn();
        completer.complete(r);
      });
      return completer.future;
    }
    return fn();
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
    bool postponeToNextFrame = false,
  }) {
    Future<T?> fn() {
      try {
        return showCupertinoModalPopup<T>(
          context: navigatorState.context,
          builder: (_) => cupertinoModalPopup,
          semanticsDismissible: semanticsDismissible,
          filter: filter,
        );
      } catch (e) {
        if (!postponeToNextFrame) {
          StatesRebuilerLogger.log(
            'Try setting `toCupertinoModalPopup.postponeToNextFrame` argument to true',
            e,
          );
        }
        rethrow;
      }
    }

    if (postponeToNextFrame) {
      Completer<T?> completer = Completer<T?>();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final r = fn();
        completer.complete(r);
      });
      return completer.future;
    }
    return fn();
  }

  void dispose() {
    RouterObjects._dispose();
    transitionsBuilder = null;
    _transitionDuration = null;
    pageRouteBuilder = null;
  }
}
