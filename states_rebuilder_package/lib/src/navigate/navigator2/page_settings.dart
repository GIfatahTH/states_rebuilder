part of '../../rm.dart';

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
  List<PageSettings> toAndRemoveUntil(String routeName,
      [String? untilRouteName]) {
    if (untilRouteName == null) {
      clear();
    } else {
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
    }

    add(PageSettings(name: routeName));
    return this;
  }
}

/// Data that might be useful in constructing a [Page]. It extends [RouteSettings]
class PageSettings extends RouteSettings {
  final Widget? child;
  final Map<String, String> queryParams;
  final ValueKey? key;
  final String? routePattern;
  final RouteData? rData;
  final String? _delegateName;

  /// Data that might be useful in constructing a [Page]. It extends [RouteSettings]
  const PageSettings({
    required String name,
    this.routePattern,
    Object? arguments,
    this.child,
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
    this.queryParams = const {},
    String? delegateName,
  })  : _delegateName = delegateName,
        super(name: name, arguments: arguments);

  String get signature => '$name$arguments$queryParams';
  String get _signatureWithChild =>
      '$name$arguments$queryParams${child is RouteWidget ? (child as RouteWidget)._getLeafConfig()?.child?.key : child?.key}';

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
  }) {
    return PageSettings._(
      name: name ?? super.name!,
      routePattern: routePattern ?? this.routePattern,
      key: key ?? this.key,
      rData: routeData ?? rData,
      arguments: arguments ?? super.arguments,
      child: child ?? this.child,
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
  }) : super._(
          child: child,
          name: routeData.location,
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
    bool isPagesFound = true,
  }) : super(
          routeData: routeData,
          child: child,
          isPagesFound: isPagesFound,
        );

  @override
  String toString() => isPagesFound
      ? 'SubPageWithData(child: $child, subRoute: $subRoute, routeData: $routeData)'
      : super.toString();
}
