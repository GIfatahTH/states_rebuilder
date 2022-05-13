part of '../injected_navigator.dart';

class RouteInformationParserImp extends RouteInformationParser<PageSettings> {
  RouteInformationParserImp(this._routerDelegate, [this.resolvedPages]);

  final RouterDelegateImp _routerDelegate;
  final void Function(Map<String, RouteSettingsWithChildAndData>? pages)?
      resolvedPages;
  String? _restoredRouteInformationName;

  @override
  Future<PageSettings> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    RouterDelegateImp.useTransition = false;
    RouterObjects.rootDelegate!.message = 'DeepLink';
    return _parseRouteInformation(routeInformation);
  }

  Future<PageSettings> _parseRouteInformation(
      RouteInformation routeInformation) async {
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
      skipHomeSlash: _pageSettingsList.isNotEmpty ? true : skipHomeSlash,
      redirectedFrom: routeData?._redirectedFrom ?? [],
    );
    resolvedPages?.call(pages);
    if (pages != null) {
      // if (_pageSettingsList.isNotEmpty) {
      //   _pageSettingsList.add(pages.values.last);
      // } else {
      _pageSettingsList.addAll(pages.values);
      // }
    }
    return SynchronousFuture(settings);
  }

  @override
  RouteInformation restoreRouteInformation(PageSettings configuration) {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _routerDelegate.useTransition = true;
    // });
    var name = configuration.name;
    if (configuration.queryParams.isNotEmpty) {
      final uri = Uri(
        path: configuration.name,
        queryParameters: configuration.queryParams,
      );
      name = '$uri';
    }
    assert(_routerDelegate.delegateName == RouterObjects.rootName);

    assert(() {
      if ((!_routerDelegate.canLogMessage ||
              _routerDelegate.message == 'Back') &&
          _restoredRouteInformationName != configuration.name) {
        if (RouterObjects.injectedNavigator!.debugPrintWhenRouted) {
          StatesRebuilerLogger.log('${_routerDelegate.message} to: $name');
        }
        _routerDelegate.message = 'Navigate';
        _restoredRouteInformationName = name;
      }
      return true;
    }());

    return RouteInformation(
      location: name,
    );
  }
}
