part of '../../rm.dart';

extension RouteInformationParserX on RouteInformationParser<PageSettings> {
  RouteInformationParser<PageSettings> setInitialRoute(String route) {
    RouterObjects._setInitialRoute(route);
    return this;
  }
}

class _RouteInformationParser extends RouteInformationParser<PageSettings> {
  const _RouteInformationParser(
    this._routerDelegate,
  );

  final _RouterDelegate _routerDelegate;
  @override
  Future<PageSettings> parseRouteInformation(
      RouteInformation routeInformation) async {
    List<PageSettings> _pageSettingsList = _routerDelegate._pageSettingsList;
    final settings = PageSettings(
      name:
          RouterObjects._initialRouteValue ?? routeInformation.location ?? '/',
    );
    RouterObjects._initialRouteValue = null;
    RouterObjects._isInitialRouteSet = true;
    final pages = _routerDelegate.getPagesFromRouteSettings(
      settings: settings,
    );
    _pageSettingsList.clear();
    _pageSettingsList.addAll(pages.values);
    return SynchronousFuture(settings);
  }

  @override
  RouteInformation restoreRouteInformation(PageSettings configuration) {
    if (configuration.queryParams.isNotEmpty) {
      final uri = Uri(
        path: configuration.name,
        queryParameters: configuration.queryParams,
      );
      return RouteInformation(
        location: '$uri',
      );
    }
    return RouteInformation(
      location: configuration.name,
    );
  }
}
