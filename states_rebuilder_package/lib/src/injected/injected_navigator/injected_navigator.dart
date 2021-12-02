import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../builders/on_reactive.dart';
import '../../rm.dart';

abstract class InjectedNavigator implements InjectedBaseState<RouteData> {
  late final RouterDelegate<PageSettings> routerDelegate =
      RouterObjects.rootDelegate!;
  late final RouteInformationParser<PageSettings> routeInformationParser =
      RouterObjects.routeInformationParser!;

  void setRouteStack(
    List<PageSettings> Function(List<PageSettings> pages) stack,
  ) {
    return RM.navigate.setRouteStack(stack);
  }

  List<PageSettings> get pageStack =>
      (routerDelegate as RouterDelegateImp).pageSettingsList;

  RouteData get routeData => state;

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

  bool get canPop {
    OnReactiveState.addToObs?.call(this);
    return RouterObjects.canPop(RouterObjects.rootDelegate!);
  }

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

  void backUntil(String untilRouteName) {
    return RM.navigate.backUntil(untilRouteName);
  }

  void back<T extends Object>([T? result]) {
    return RM.navigate.back<T>(result);
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
