import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../builders/on_reactive.dart';
import '../../rm.dart';

///{@template InjectedNavigator}
/// Injecting a Navigator 2 that holds a [RouteData] state.
///
/// ```dart
///  final myNavigator = RM.injectNavigator(
///    routes: {
///      '/': (RouteData data) => HomePage(),
///      '/page1': (RouteData data) => Page1(),
///    },
///  );
///
///  class MyApp extends StatelessWidget {
///    const MyApp({Key? key}) : super(key: key);
///
///    @override
///    Widget build(BuildContext context) {
///      return MaterialApp.router(
///        routeInformationParser: myNavigator.routeInformationParser,
///        routerDelegate: myNavigator.routerDelegate,
///      );
///    }
///  }
/// ```
///
/// See also [RouteData] and [RouteWidget]
/// {@endtemplate}
abstract class InjectedNavigator {
  /// [RouterDelegate] implementation
  RouterDelegate<PageSettings> get routerDelegate =>
      RouterObjects.rootDelegate!;

  /// [RouteInformationParser] delegate.
  RouteInformationParser<PageSettings> get routeInformationParser =>
      RouterObjects.routeInformationParser!;

  /// Set the route stack. It exposes the current [PageSettings] stack.
  void setRouteStack(
    List<PageSettings> Function(List<PageSettings> pages) stack, {
    String? subRouteName,
  }) {
    if (_mock != null) {
      return _mock!.setRouteStack(stack, subRouteName: subRouteName);
    }
    return RM.navigate.setRouteStack(stack, subRouteName: subRouteName);
  }

  /// Get the [PageSettings] stack.
  List<PageSettings> get pageStack {
    if (_mock != null) {
      return _mock!.pageStack;
    }
    return (routerDelegate as RouterDelegateImp).pageSettingsList;
  }

  /// Get the current [RouteData]
  RouteData get routeData => throw UnimplementedError();

  /// Find the page with given routeName and add it to the route stack and trigger
  /// route transition.
  ///
  /// If the page belongs to a sub route the page is added to it and only this
  /// particular sub route is triggered to animate transition.
  ///
  /// It is similar to `RM.navigate.toNamed` method.
  Future<T?> to<T extends Object?>(
    String routeName, {
    Object? arguments,
    Map<String, String>? queryParams,
    bool fullscreenDialog = false,
    bool maintainState = true,
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondAnimation,
      Widget child,
    )?
        transitionsBuilder,
  }) {
    if (_mock != null) {
      return _mock!.to<T>(
        routeName,
        arguments: arguments,
        queryParams: queryParams,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
        transitionsBuilder: transitionsBuilder,
      );
    }

    return RM.navigate.toNamed<T>(
      routeName,
      arguments: arguments,
      queryParams: queryParams,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      transitionsBuilder: transitionsBuilder,
    );
  }

  /// Push a pageless route
  ///
  /// Similar to `RM.navigate.to`
  Future<T?> toPageless<T extends Object?>(
    Widget page, {
    String? name,
    bool fullscreenDialog = false,
    bool maintainState = true,
    // Widget Function(//TODO
    //   BuildContext context,
    //   Animation<double> animation,
    //   Animation<double> secondAnimation,
    //   Widget child,
    // )?
    //     transitionsBuilder,
  }) {
    if (_mock != null) {
      return _mock!.toPageless<T>(
        page,
        name: name,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
        // transitionsBuilder: transitionsBuilder,
      );
    }

    return RM.navigate.to<T>(
      page,
      name: name,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      // transitionsBuilder: transitionsBuilder,
    );
  }

  /// Whether a page can be popped off from the root route stack or sub route
  /// stacks.
  bool get canPop => throw UnimplementedError();

  /// Deeply navigate to the given routeName. Deep navigation means that the
  /// root stack is cleaned and pages corresponding to sub paths are added to
  /// the stack.
  ///
  /// Example:
  /// Suppose our navigator is :
  /// ```dart
  ///  final myNavigator = RM.injectNavigator(
  ///    routes: {
  ///      '/': (RouteData data) => HomePage(),
  ///      '/page1': (RouteData data) => Page1(),
  ///      '/page1/page11': (RouteData data) => Page11(),
  ///      '/page1/page11/page111': (RouteData data) => Page111(),
  ///    },
  ///  );
  /// ```
  /// On app start up, the route stack is `['/']`.
  ///
  /// If we call `myNavigator.to('/page1/page11/page111')`, the route stack is
  /// `['/', '/page1/page11/page111']`.
  ///
  /// In contrast, if we invoke myNavigator.toDeeply('/page1/page11/page111'),
  /// the route stack is `['/', '/page1', '/page1/page11', '/page1/page11/page111']`.
  void toDeeply(
    String routeName, {
    Object? arguments,
    Map<String, String>? queryParams,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    if (_mock != null) {
      return _mock!.toDeeply(
        routeName,
        arguments: arguments,
        queryParams: queryParams,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
      );
    }

    RouterObjects.clearStack();
    final pathSegments = Uri.parse(routeName).pathSegments;

    if (pathSegments.isEmpty) {
      to('/', arguments: arguments, queryParams: queryParams);
      return;
    }
    to('/');
    String path = '';
    for (var i = 0; i < pathSegments.length; i++) {
      path += '/${pathSegments[i]}';
      if (i == pathSegments.length - 1) {
        to(
          path,
          arguments: arguments,
          queryParams: queryParams,
          fullscreenDialog: fullscreenDialog,
          maintainState: maintainState,
        );
      } else {
        to(
          path,
          maintainState: maintainState,
        );
      }
    }
  }

  /// Find the page with given routeName and remove the current route and
  /// replace it with the new one.
  ///
  /// It is similar to `RM.navigate.toReplacementNamed` method.
  Future<T?> toReplacement<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
    Map<String, String>? queryParams,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    if (_mock != null) {
      return _mock!.toReplacement<T, TO>(
        routeName,
        result: result,
        arguments: arguments,
        queryParams: queryParams,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
      );
    }

    return RM.navigate.toReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
      queryParams: queryParams,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
    );
  }

  /// Find the page with given routeName and then remove all the previous routes
  /// until meeting the route with defined route name [untilRouteName].
  /// If no route name is given ([untilRouteName] is null) , all routes will be
  /// removed except the new page route.
  ///
  /// It is similar to `RM.navigate.toNamedAndRemoveUntil` method.
  Future<T?> toAndRemoveUntil<T extends Object?>(
    String newRouteName, {
    String? untilRouteName,
    Object? arguments,
    Map<String, String>? queryParams,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    if (_mock != null) {
      return _mock!.toAndRemoveUntil<T>(
        newRouteName,
        untilRouteName: untilRouteName,
        arguments: arguments,
        queryParams: queryParams,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
      );
    }
    return RM.navigate.toNamedAndRemoveUntil<T>(
      newRouteName,
      untilRouteName: untilRouteName,
      arguments: arguments,
      queryParams: queryParams,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
    );
  }

  /// Navigate back and remove all the previous routes until meeting the route
  /// with defined name
  ///
  /// It is similar to `RM.navigate.backUntil` method.
  void backUntil(String untilRouteName) {
    if (_mock != null) {
      return _mock!.backUntil(untilRouteName);
    }
    return RM.navigate.backUntil(untilRouteName);
  }

  /// Navigate back to the last page, ie Pop the top-most route off the navigator.
  ///
  /// It is similar to `RM.navigate.back` method.
  void back<T extends Object>([T? result]) {
    if (_mock != null) {
      return _mock!.back<T>(result);
    }
    return RM.navigate.back<T>(result);
  }

  /// {@macro forceBack}
  /// It is similar to `RM.navigate.forceBack` method.
  void forceBack<T extends Object>([T? result]) {
    if (_mock != null) {
      return _mock!.forceBack<T>(result);
    }
    return RM.navigate.forceBack<T>(result);
  }

  void removePage<T extends Object>(String routeName, [T? result]) {
    if (_mock != null) {
      return _mock!.removePage<T>(routeName, result);
    }
    RouterObjects.removePage<T>(
      routeName: routeName,
      activeSubRoutes: RouterObjects.getActiveSubRoutes(),
      result: result,
    );
  }

  /// Invoke `onNavigate` callback and navigate according the logic defined there.
  void onNavigate() => throw UnimplementedError();

  /// Used in test to simulate a deep link call.
  void deepLinkTest(String url) {
    routeInformationParser.parseRouteInformation(
      RouteInformation(location: url),
    );
    (routerDelegate as RouterDelegateImp).updateRouteStack();
  }

  InjectedNavigator? _mock;

  //
  void injectMock(InjectedNavigator mock) {
    assert(() {
      _mock = mock;
      return true;
    }());
  }
}

class InjectedNavigatorImp extends InjectedBaseBaseImp<RouteData>
    with InjectedNavigator {
  InjectedNavigatorImp({
    required Map<String, Widget Function(RouteData data)> routes,
    required Widget Function(RouteData)? unknownRoute,
    required Widget Function(
            BuildContext, Animation<double>, Animation<double>, Widget)?
        transitionsBuilder,
    required Duration? transitionDuration,
    required Widget Function(Widget child)? builder,
    required String? initialRoute,
    required bool shouldUseCupertinoPage,
    required Redirect? Function(RouteData data)? redirectTo,
    required this.debugPrintWhenRouted,
    required this.pageBuilder,
    required this.onBack,
    required this.ignoreUnknownRoutes,
  })  : _redirectTo = redirectTo,
        super(
          creator: () => initialState,
          initialState: initialState,
          autoDisposeWhenNotUsed: true,
          onDisposed: null,
          onInitialized: null,
        ) {
    _resetDefaultState = () {
      RouterObjects.initialize(
        routes: routes,
        unknownRoute: unknownRoute,
        transitionsBuilder: transitionsBuilder,
        transitionDuration: transitionDuration,
        builder: builder,
        initialRoute: initialRoute,
        shouldUseCupertinoPage: shouldUseCupertinoPage,
      );
      RouterObjects.injectedNavigator = this;
    };
  }
  bool _isInitialized = false;

  @override
  RouterDelegate<PageSettings> get routerDelegate {
    if (!_isInitialized) {
      _isInitialized = true;
      _resetDefaultState();
    }
    return super.routerDelegate;
  }

  @override
  RouteInformationParser<PageSettings> get routeInformationParser {
    if (!_isInitialized) {
      _isInitialized = true;
      _resetDefaultState();
    }
    return super.routeInformationParser;
  }

  static final initialState = RouteData(
    path: '/',
    location: '/',
    subLocation: '/',
    queryParams: const {},
    pathParams: const {},
    arguments: null,
    pathEndsWithSlash: false,
    redirectedFrom: const [],
  );
  static bool ignoreSingleRouteMapAssertion = false;
  final bool ignoreUnknownRoutes;

  final Redirect? Function(RouteData data)? _redirectTo;
  Redirect? Function(RouteData data)? get redirectTo {
    if (_redirectTo == null) {
      return null;
    }
    return (RouteData data) {
      return _redirectTo!(data);
    };
  }

  @override
  void onNavigate() {
    final toLocation = _redirectTo?.call(routeData);
    if (toLocation is Redirect && toLocation.to != null) {
      setRouteStack(
        (pages) {
          pages.clear();
          return pages.to(
            toLocation.to!,
            arguments: routeData.arguments,
            queryParams: routeData.queryParams,
            isStrictMode: true,
          );
        },
      );
    }
  }

  final bool debugPrintWhenRouted;
  final Page<dynamic> Function(MaterialPageArgument arg)? pageBuilder;
  final bool? Function(RouteData? data)? onBack;

  late final VoidCallback _resetDefaultState;

  set routeData(RouteData value) {
    if (state.signature != value.signature) {
      snapState = SnapState.data(value);
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    // _resetDefaultState();
    super.dispose();
  }

  @override
  bool get canPop {
    if (_mock != null) {
      return _mock!.canPop;
    }
    OnReactiveState.addToObs?.call(this);
    return RouterObjects.canPop;
  }

  @override
  RouteData get routeData {
    if (_mock != null) {
      return _mock!.routeData;
    }
    return state;
  }
}
