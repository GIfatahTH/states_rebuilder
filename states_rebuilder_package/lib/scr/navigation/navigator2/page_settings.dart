part of '../injected_navigator.dart';

/// Extension on List<PageSettings>
extension PageSettingsX on List<PageSettings> {
  /// Add the page of routeName to PageSettings
  ///
  /// if `isStrictMode` is true and if the add page already exists in the route
  /// stack then all pages above the added page will be removed and the add page
  /// is displayed.
  ///
  List<PageSettings> to(
    String routeName, {
    Object? arguments,
    Map<String, String> queryParams = const {},
    bool isStrictMode = false,
  }) {
    if (isStrictMode) {
      bool isThere = false;
      final l = where(
        (e) {
          if (e.name == routeName) {
            isThere = true;
          }
          return !isThere;
        },
      ).toList();
      l.add(PageSettings(
        name: routeName,
        arguments: arguments,
        queryParams: queryParams,
      ));
      return l;
    }
    add(PageSettings(
      name: routeName,
      arguments: arguments,
      queryParams: queryParams,
    ));
    return this;
  }

  /// Add the page with the given `routeName` and remove the last page.
  List<PageSettings> toReplacement(String routeName) {
    if (isNotEmpty) {
      removeLast();
    }

    add(PageSettings(name: routeName));
    return this;
  }

  /// Add the page with the given `routeName` and remove all pages until the
  /// page with `untilRouteName` name.
  List<PageSettings> toAndRemoveUntil(
    String routeName,
    String untilRouteName,
  ) {
    while (true) {
      if (last.name == untilRouteName) {
        break;
      }
      if (isNotEmpty) {
        removeLast();
      } else {
        break;
      }
    }

    add(PageSettings(name: routeName));
    return this;
  }
}

/// Data that might be useful in constructing a [Page]. It extends [RouteSettings]
class PageSettings extends RouteSettings {
  /// If provided this is the widget associated with this page
  final Widget? child;

  /// parameter of the query params of the url
  final Map<String, String> queryParams;

  /// A [Key] is an identifier for page
  final ValueKey? key;

  /// The route uir
  final String? routePattern;

  /// Object that holds information about the active route.

  final RouteData? rData;
  final String? _delegateName;

  /// The builder of the page
  final Widget Function(Widget route)? builder;

  Widget _getChildWithBuilder() {
    return builder != null ? builder!(child!) : child!;
  }

  /// Get sub pages of the page
  List<PageSettings> get getSubPages {
    if (child is RouteWidget) {
      return (child as RouteWidget)._routerDelegate._pageSettingsList;
    }
    return const [];
  }

  /// Data that might be useful in constructing a [Page]. It extends [RouteSettings]
  const PageSettings({
    required String name,
    this.routePattern,
    Object? arguments,
    this.child,
    this.builder,
    this.queryParams = const {},
  })  : key = null,
        rData = null,
        _delegateName = null,
        super(name: name, arguments: arguments);
  const PageSettings._({
    required String name,
    this.routePattern,
    this.key,
    this.rData,
    Object? arguments,
    this.child,
    this.builder,
    this.queryParams = const {},
    String? delegateName,
  })  : _delegateName = delegateName,
        super(name: name, arguments: arguments);

  String get signature => '${rData?.signature}';
  String get _signatureWithChild =>
      '$signature${child is RouteWidget ? (child as RouteWidget)._getLeafConfig()?.child?.key : child?.key}';

  @override
  PageSettings copyWith({
    String? name,
    String? delegateName,
    String? routePattern,
    ValueKey? key,
    Object? arguments,
    Widget? child,
    Map<String, String>? queryParams,
    RouteData? routeData,
    Widget Function(Widget route)? builder,
  }) {
    return PageSettings._(
      name: name ?? super.name!,
      routePattern: routePattern ?? this.routePattern,
      key: key ?? this.key,
      rData: routeData ?? rData,
      arguments: arguments ?? super.arguments,
      child: child ?? this.child,
      builder: builder ?? this.builder,
      queryParams: queryParams ?? this.queryParams,
      delegateName: delegateName ?? _delegateName ?? name ?? super.name,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PageSettings &&
        other.name == name &&
        '${other.queryParams}' == '$queryParams';
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      'Page(name: $_delegateName, child: $child, arguments: $arguments,'
      ' queryParams: $queryParams)';

  String toStringShort() => 'Page(name: $name, child: $child)';
}

class RouteSettingsWithChildAndData extends PageSettings {
  final RouteData routeData;
  final bool isPagesFound;
  RouteSettingsWithChildAndData({
    required this.routeData,
    this.isPagesFound = true,
    Widget? child,
    Widget Function(Widget route)? builder,
  }) : super._(
          child: child,
          builder: builder,
          name: routeData._subLocation,
          arguments: routeData.arguments,
          queryParams: routeData.queryParams,
          rData: routeData,
        );

  @override
  String toString() => isPagesFound
      ? 'PageWithData(child: $child, routeData: $routeData)'
      : 'PAGE NOT Found (name: $name)';
}

class RouteSettingsWithRouteWidget extends RouteSettingsWithChildAndData {
  final Widget? subRoute;
  RouteSettingsWithRouteWidget({
    required RouteData routeData,
    this.subRoute,
    Widget? child,
    Widget Function(Widget route)? builder,
    bool isPagesFound = true,
  }) : super(
          routeData: routeData,
          child: child,
          builder: builder,
          isPagesFound: isPagesFound,
        );

  @override
  String toString() => isPagesFound
      ? 'SubPageWithData(child: $child, subRoute: $subRoute, routeData: $routeData)'
      : super.toString();
}

class DefaultTransitionDelegateImp extends DefaultTransitionDelegate {
  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final List<RouteTransitionRecord> results = <RouteTransitionRecord>[];
    // This method will handle the exiting route and its corresponding pageless
    // route at this location. It will also recursively check if there is any
    // other exiting routes above it and handle them accordingly.
    void handleExitingRoute(RouteTransitionRecord? location, bool isLast) {
      final RouteTransitionRecord? exitingPageRoute =
          locationToExitingPageRoute[location];
      if (exitingPageRoute == null) return;
      if (exitingPageRoute.isWaitingForExitingDecision) {
        final bool hasPagelessRoute =
            pageRouteToPagelessRoutes.containsKey(exitingPageRoute);
        final bool isLastExitingPageRoute =
            isLast && !locationToExitingPageRoute.containsKey(exitingPageRoute);

        if (RouterDelegateImp.shouldMarkForComplete) {
          exitingPageRoute
              .markForComplete(exitingPageRoute.route.currentResult);
        } else if (isLastExitingPageRoute && !hasPagelessRoute) {
          exitingPageRoute.markForPop(exitingPageRoute.route.currentResult);
        } else {
          exitingPageRoute
              .markForComplete(exitingPageRoute.route.currentResult);
        }
        if (hasPagelessRoute) {
          final List<RouteTransitionRecord> pagelessRoutes =
              pageRouteToPagelessRoutes[exitingPageRoute]!;
          for (final RouteTransitionRecord pagelessRoute in pagelessRoutes) {
            // It is possible that a pageless route that belongs to an exiting
            // page-based route does not require exiting decision. This can
            // happen if the page list is updated right after a Navigator.pop.
            if (pagelessRoute.isWaitingForExitingDecision) {
              if (isLastExitingPageRoute &&
                  pagelessRoute == pagelessRoutes.last) {
                pagelessRoute.markForPop(pagelessRoute.route.currentResult);
              } else {
                pagelessRoute
                    .markForComplete(pagelessRoute.route.currentResult);
              }
            }
          }
        }
      }
      results.add(exitingPageRoute);

      // It is possible there is another exiting route above this exitingPageRoute.
      handleExitingRoute(exitingPageRoute, isLast);
    }

    // Handles exiting route in the beginning of list.
    handleExitingRoute(null, newPageRouteHistory.isEmpty);

    for (final RouteTransitionRecord pageRoute in newPageRouteHistory) {
      final bool isLastIteration = newPageRouteHistory.last == pageRoute;
      if (pageRoute.isWaitingForEnteringDecision) {
        if (!locationToExitingPageRoute.containsKey(pageRoute) &&
            isLastIteration) {
          pageRoute.markForPush();
        } else {
          pageRoute.markForAdd();
        }
      }
      results.add(pageRoute);
      handleExitingRoute(pageRoute, isLastIteration);
    }
    return results;
  }
}
