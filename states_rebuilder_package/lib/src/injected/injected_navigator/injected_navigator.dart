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
/// {@endtemplate}
abstract class InjectedNavigator implements InjectedBaseState<RouteData> {
  /// [RouterDelegate] implementation
  late final RouterDelegate<PageSettings> routerDelegate =
      RouterObjects.rootDelegate!;

  /// [RouteInformationParser] delegate.
  late final RouteInformationParser<PageSettings> routeInformationParser =
      RouterObjects.routeInformationParser!;

  /// Set the route stack. It exposes the current [PageSettings] stack.
  void setRouteStack(
    List<PageSettings> Function(List<PageSettings> pages) stack,
  ) {
    return RM.navigate.setRouteStack(stack);
  }

  /// Get the [PageSettings] stack.
  List<PageSettings> get pageStack =>
      (routerDelegate as RouterDelegateImp).pageSettingsList;

  /// Get the current [RouteData]
  RouteData get routeData => state;

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
  }) {
    return RM.navigate.toNamed<T>(
      routeName,
      arguments: arguments,
      queryParams: queryParams,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
    );
  }

  /// Whether a page can be popped off from the root route stack or sub route
  /// stacks.
  bool get canPop {
    OnReactiveState.addToObs?.call(this);
    return RouterObjects.canPop(RouterObjects.rootDelegate!);
  }

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
// TODO to test
  void toDeeply(
    String routeName, {
    Object? arguments,
    Map<String, String>? queryParams,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
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
    return RM.navigate.backUntil(untilRouteName);
  }

  /// Navigate back to the last page, ie Pop the top-most route off the navigator.
  ///
  /// It is similar to `RM.navigate.back` method.
  void back<T extends Object>([T? result]) {
    return RM.navigate.back<T>(result);
  }

  /// {@macro forceBack}
  /// It is similar to `RM.navigate.forceBack` method.
  void forceBack<T extends Object>([T? result]) {
    return RM.navigate.forceBack<T>(result);
  }
}

class InjectedNavigatorImp extends InjectedBaseBaseImp<RouteData>
    with InjectedNavigator {
  InjectedNavigatorImp({
    required Map<String, Widget Function(RouteData data)> routes,
    required Widget Function(String)? unknownRoute,
    required Widget Function(
            BuildContext, Animation<double>, Animation<double>, Widget)?
        transitionsBuilder,
    required Widget Function(Widget child)? builder,
    required String? initialRoute,
    required bool shouldUseCupertinoPage,
    required Redirect? Function(RouteData data)? redirectTo,
    required this.debugPrintWhenRouted,
    required this.pageBuilder,
    required this.onBack,
  })  : _redirectTo = redirectTo,
        super(
          creator: () => const RouteData(
            path: '/',
            location: '/',
            queryParams: {},
            pathParams: {},
            arguments: null,
            pathEndsWithSlash: false,
            redirectedFrom: [],
          ),
        ) {
    RouterObjects.initialize(
      routes: routes,
      unknownRoute: unknownRoute,
      transitionsBuilder: transitionsBuilder,
      builder: builder,
      initialRoute: initialRoute,
      shouldUseCupertinoPage: shouldUseCupertinoPage,
    );
    _resetDefaultState = () {};
    _resetDefaultState();
    RouterObjects.injectedNavigator = this;
  }
  final Redirect? Function(RouteData data)? _redirectTo;
  Redirect? Function(RouteData data)? get redirectTo {
    if (_redirectTo == null) {
      return null;
    }
    return (RouteData data) {
      return _redirectTo!(data);
    };
  }

  final bool debugPrintWhenRouted;
  final Page<dynamic> Function(MaterialPageArgument arg)? pageBuilder;
  final bool? Function(RouteData data)? onBack;

  late final VoidCallback _resetDefaultState;

  set routeData(RouteData value) {
    snapState = SnapState.data(value);
  }

  @override
  void dispose() {
    _resetDefaultState();
    super.dispose();
  }
}
