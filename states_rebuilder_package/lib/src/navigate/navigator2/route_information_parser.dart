part of '../../rm.dart';

extension RouteInformationParserX on RouteInformationParser<PageSettings> {
  RouteInformationParser<PageSettings> setInitialRoute(String route) {
    RouterObjects._setInitialRoute(route);
    return this;
  }
}

class _RouteInformationParser extends RouteInformationParser<PageSettings> {
  @override
  Future<PageSettings> parseRouteInformation(
      RouteInformation routeInformation) async {
    print(RouterObjects._initialRouteValue);
    final settings = PageSettings(
      name:
          RouterObjects._initialRouteValue ?? routeInformation.location ?? '/',
    );
    print('settings $settings');
    RouterObjects._initialRouteValue = null;
    RouterObjects._isInitialRouteSet = true;
    final pages = resolvePathRouteUtil.getPagesFromRouteSettings(
      routes: RouterObjects._routers!,
      settings: settings,
      unknownRoute: RouterObjects._unknownRoute,
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
      print('configuration $configuration');
      print('uri $uri');
      print('${uri.path}?${uri.query}');

      return RouteInformation(
        location: '$uri',
      );
    }
    print('configuration without query $configuration');

    return RouteInformation(
      location: configuration.name,
    );
  }
}
