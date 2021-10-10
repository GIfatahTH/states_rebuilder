part of '../../rm.dart';

extension RouteInformationParserX on RouteInformationParser<PageSettings> {
  RouteInformationParser<PageSettings> setInitialRoute(String route) {
    RouterObjects._initialRoute = route;
    return this;
  }
}

class _RouteInformationParser extends RouteInformationParser<PageSettings> {
  _RouteInformationParser setInitialRoute(String route) {
    RouterObjects._initialRoute = route;
    return this;
  }

  @override
  Future<PageSettings> parseRouteInformation(
      RouteInformation routeInformation) async {
    final settings = PageSettings(
      name: RouterObjects._initialRoute ?? routeInformation.location ?? '/',
    );
    RouterObjects._initialRoute = null;
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
    return RouteInformation(location: configuration.name);
  }
}
