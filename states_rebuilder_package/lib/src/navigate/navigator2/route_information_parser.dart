part of '../../rm.dart';

class RouteInformationParserImp extends RouteInformationParser<PageSettings> {
  RouteInformationParserImp(this._routerDelegate, [this.resolvedPages]);

  final RouterDelegateImp _routerDelegate;
  final void Function(Map<String, RouteSettingsWithChildAndData>? pages)?
      resolvedPages;
  String? _restoredRouteInformationName;

  @override
  Future<PageSettings> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    dynamic arguments;
    Map<String, String> queryParams = {};
    bool skipHomeSlash = false;
    RouteData? routeData;
    if (routeInformation.state is Map<String, dynamic>) {
      routeData = (routeInformation.state
          as Map<String, dynamic>?)?['routeData'] as RouteData?;
      arguments = routeData?.arguments;
      queryParams =
          (routeInformation.state as Map<String, dynamic>?)?['queryParams'] ??
              {};
      skipHomeSlash =
          (routeInformation.state as Map<String, dynamic>?)?['skipHomeSlash'] ??
              false;
    }
    List<PageSettings> _pageSettingsList = _routerDelegate._pageSettingsList;
    final settings = PageSettings(
      name:
          RouterObjects._initialRouteValue ?? routeInformation.location ?? '/',
      arguments: arguments,
      queryParams: queryParams,
    );
    RouterObjects._initialRouteValue = null;
    final pages = _routerDelegate.getPagesFromRouteSettings(
      settings: settings,
      skipHomeSlash: skipHomeSlash,
      redirectedFrom: routeData?._redirectedFrom ?? [],
    );
    resolvedPages?.call(pages);
    if (pages != null) {
      _pageSettingsList.clear();
      _pageSettingsList.addAll(pages.values);
    }

    if (_routerDelegate == RouterObjects.rootDelegate) {
      _routerDelegate._useTransition = false;
      RouterObjects.rootDelegate!._message = 'DeepLink';
    }
    return SynchronousFuture(settings);
  }

  @override
  RouteInformation restoreRouteInformation(PageSettings configuration) {
    _routerDelegate._useTransition = true;

    var name = configuration.name;
    if (configuration.queryParams.isNotEmpty) {
      final uri = Uri(
        path: configuration.name,
        queryParameters: configuration.queryParams,
      );
      name = '$uri';
    }
    assert(_routerDelegate.delegateName == 'rootDelegate');

    assert(() {
      if ((!_routerDelegate._ignoreConfiguration ||
              _routerDelegate._message == 'Back') &&
          _restoredRouteInformationName != configuration.name) {
        if (RouterObjects.injectedNavigator!.debugPrintWhenRouted) {
          StatesRebuilerLogger.log('${_routerDelegate._message} to: $name');
        }
        _routerDelegate._message = 'Navigate';
        _restoredRouteInformationName = name;
      }
      return true;
    }());

    return RouteInformation(
      location: name,
    );
  }
}
