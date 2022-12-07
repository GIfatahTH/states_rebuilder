import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navigation_builder/navigation_builder.dart';

import '../state_management/rm.dart';

// part 'build_context_x.dart';
// part 'navigator2/on_navigate_back_scope.dart';
// part 'navigator2/page_settings.dart';
// part 'navigator2/route_information_parser.dart';
// part 'navigator2/router_delegate.dart';
// part 'navigator2/router_objects.dart';
// part 'rm_navigator.dart';
// part 'rm_scaffold.dart';
// part 'page_route_builder.dart';
// part 'rm_resolve_path_route_util.dart';
// part 'route_data.dart';
// part 'route_full_widget.dart';
// // part 'route_widget.dart';
// part 'sub_route.dart';
// part 'transitions.dart';

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

class InjectedNavigator implements NavigationBuilder {
  late final NavigationBuilder _navigationBuilder;

  /// [RouterDelegate] implementation
  RouterDelegate<PageSettings> get routerDelegate =>
      _navigationBuilder.routerDelegate;

  /// [RouteInformationParser] delegate.
  RouteInformationParser<PageSettings> get routeInformationParser =>
      _navigationBuilder.routeInformationParser;

  /// Set the route stack. It exposes the current [PageSettings] stack.
  void setRouteStack(
    List<PageSettings> Function(List<PageSettings> pages) stack, {
    String? subRouteName,
  }) {
    return _navigationBuilder.setRouteStack(stack, subRouteName: subRouteName);
  }

  /// Get the [PageSettings] stack.
  List<PageSettings> get pageStack {
    if (_mock != null) {
      return _mock!.pageStack;
    }
    return _navigationBuilder.pageStack;
  }

  /// Get the current [RouteData]
  RouteData get routeData => _navigationBuilder.routeData;

  /// Find the page with given routeName and add it to the route stack and trigger
  /// route transition.
  ///
  /// If the page belongs to a sub route the page is added to it and only this
  /// particular sub route is triggered to animate transition.
  ///
  /// It is similar to `_navigate.toNamed` method.
  Future<T?> to<T extends Object?>(
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
    return _navigationBuilder.to<T>(
      routeName,
      arguments: arguments,
      queryParams: queryParams,
      builder: builder,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      transitionsBuilder: transitionsBuilder,
    );
  }

  /// Push a pageless route
  ///
  /// Similar to `_navigate.to`
  Future<T?> toPageless<T extends Object?>(
    Widget page, {
    String? name,
    bool fullscreenDialog = false,
    bool maintainState = true,
    // Widget Function(
    //   BuildContext context,
    //   Animation<double> animation,
    //   Animation<double> secondAnimation,
    //   Widget child,
    // )?
    //     transitionsBuilder,
  }) {
    return _navigationBuilder.toPageless<T>(
      page,
      name: name,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      // transitionsBuilder: transitionsBuilder,
    );
  }

  /// Whether a page can be popped off from the root route stack or sub route
  /// stacks.
  bool get canPop => _navigationBuilder.canPop;

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
    return _navigationBuilder.toDeeply(
      routeName,
      arguments: arguments,
      queryParams: queryParams,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
    );
  }

  /// Find the page with given routeName and remove the current route and
  /// replace it with the new one.
  ///
  /// It is similar to `_navigate.toReplacementNamed` method.
  Future<T?> toReplacement<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
    Map<String, String>? queryParams,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    return _navigationBuilder.toReplacement<T, TO>(
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
  /// It is similar to `_navigate.toNamedAndRemoveUntil` method.
  Future<T?> toAndRemoveUntil<T extends Object?>(
    String newRouteName, {
    String? untilRouteName,
    Object? arguments,
    Map<String, String>? queryParams,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    return _navigationBuilder.toAndRemoveUntil<T>(
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
  /// It is similar to `_navigate.backUntil` method.
  void backUntil(String untilRouteName) {
    return _navigationBuilder.backUntil(untilRouteName);
  }

  /// Navigate back to the last page, ie Pop the top-most route off the navigator.
  ///
  /// It is similar to `_navigate.back` method.
  void back<T extends Object>([T? result]) {
    return _navigationBuilder.back<T>(result);
  }

  /// {@macro forceBack}
  /// It is similar to `_navigate.forceBack` method.
  void forceBack<T extends Object>([T? result]) {
    return _navigationBuilder.forceBack<T>(result);
  }

  /// Remove a pages from the route stack.
  void removePage<T extends Object>(String routeName, [T? result]) {
    return _navigationBuilder.removePage<T>(routeName, result);
  }

  /// Invoke `onNavigate` callback and navigate according the logic defined there.
  void onNavigate() => _navigationBuilder.onNavigate();

  /// Used in test to simulate a deep link call.
  void deepLinkTest(String url) {
    return _navigationBuilder.deepLinkTest(url);
  }

  InjectedNavigator? _mock;

  /// Mock InjectedNavigator
  void injectMock(NavigationBuilder mock) {
    return _navigationBuilder.injectMock(mock);
  }

  /// {@macro toDialog}
  Future<T?> toDialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    bool postponeToNextFrame = false,
  }) {
    return _navigationBuilder.toDialog<T>(
      dialog,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      useSafeArea: useSafeArea,
      postponeToNextFrame: postponeToNextFrame,
    );
  }

  /// {@macro toCupertinoDialog}
  Future<T?> toCupertinoDialog<T>(
    Widget dialog, {
    bool barrierDismissible = false,
    bool postponeToNextFrame = false,
  }) =>
      _navigationBuilder.toCupertinoDialog<T>(
        dialog,
        barrierDismissible: barrierDismissible,
        postponeToNextFrame: postponeToNextFrame,
      );

  /// {@macro toBottomSheet}
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
  }) =>
      _navigationBuilder.toBottomSheet<T>(
        bottomSheet,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        isScrollControlled: isScrollControlled,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        barrierColor: barrierColor,
        postponeToNextFrame: postponeToNextFrame,
      );

  /// {@macro toCupertinoModalPopup}
  Future<T?> toCupertinoModalPopup<T>(
    Widget cupertinoModalPopup, {
    ImageFilter? filter,
    bool? semanticsDismissible,
    bool postponeToNextFrame = false,
  }) =>
      _navigationBuilder.toCupertinoModalPopup<T>(
        cupertinoModalPopup,
        filter: filter,
        semanticsDismissible: semanticsDismissible,
        postponeToNextFrame: postponeToNextFrame,
      );

  /// Show ScaffoldMessenger related widgets such as SnackBar, Drawer, and
  /// BottomSheets
  // final scaffold = _navigationBuilder.scaffold;
  @override
  get scaffold {
    if (RM.context != null &&
        RM.context != RM.navigate.navigatorKey.currentContext) {
      _navigationBuilder.scaffold.context = RM.context!;
    }
    return _navigationBuilder.scaffold;
  }

  @override
  Future<T?> backAndToNamed<T extends Object?, TO extends Object?>(
      String routeName,
      {TO? result,
      Object? arguments,
      bool fullscreenDialog = false,
      bool maintainState = true}) {
    return _navigationBuilder.backAndToNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
    );
  }

  @override
  void disposeAll() {
    return _navigationBuilder.disposeAll();
  }
}

InjectedNavigator createNavigator({
  required Map<String, Widget Function(RouteData data)> routes,
  String? initialLocation,
  Widget Function(RouteData data)? unknownRoute,
  Widget Function(Widget routerOutlet)? builder,
  Page<dynamic> Function(MaterialPageArgument arg)? pageBuilder,
  bool shouldUseCupertinoPage = false,
  Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondAnimation,
    Widget child,
  )?
      transitionsBuilder,
  Duration? transitionDuration,
  Redirect? Function(RouteData data)? onNavigate,
  bool? Function(RouteData? data)? onNavigateBack,
  bool debugPrintWhenRouted = false,
  bool ignoreUnknownRoutes = false,
  List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
}) {
  final navigationBuilder = NavigationBuilder.create(
    routes: routes,
    unknownRoute: unknownRoute,
    transitionsBuilder: transitionsBuilder,
    transitionDuration: transitionDuration,
    builder: builder,
    initialLocation: initialLocation,
    shouldUseCupertinoPage: shouldUseCupertinoPage,
    onNavigate: onNavigate,
    onNavigateBack: onNavigateBack,
    debugPrintWhenRouted: debugPrintWhenRouted,
    pageBuilder: pageBuilder,
    ignoreUnknownRoutes: ignoreUnknownRoutes,
    navigatorObservers: navigatorObservers,
  );
  return InjectedNavigator().._navigationBuilder = navigationBuilder;
}
