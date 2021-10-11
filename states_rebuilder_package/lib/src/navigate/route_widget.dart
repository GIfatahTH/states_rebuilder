part of '../rm.dart';

class RouteWidget extends StatefulWidget {
  final Widget Function(Widget child)? builder;
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? transitionsBuilder;

  final Map<String, Widget Function(RouteData data)> routes;
  RouteWidget({
    this.builder,
    this.routes = const {},
    this.transitionsBuilder,
    Key? key,
  })  : assert(builder != null || routes.isNotEmpty),
        super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}

class SubRouteWidget extends StatefulWidget {
  final Widget Function(Widget child)? builder;
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? transitionsBuilder;

  final Map<String, Widget Function(RouteData data)> routes;

  SubRouteWidget({
    this.builder,
    this.routes = const {},
    this.transitionsBuilder,
    Key? key,
  })  : assert(builder != null || routes.isNotEmpty),
        super(
          key: key,
        );

  @override
  _SubRouteWidgetState createState() => _SubRouteWidgetState();
}

class _SubRouteWidgetState extends State<SubRouteWidget> {
  late final String name;
  late final _RouterDelegate _routerDelegate;
  late final _RouteInformationParser _routeInformationParser;
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    name = '/page1';
    _routerDelegate = _RouterDelegate(
      key: key,
      routes: widget.routes,
      transitionsBuilder: widget.transitionsBuilder,
    );
    _routeInformationParser =
        _RouteInformationParser(_routerDelegate._pageSettingsList);
    _routeInformationParser.parseRouteInformation(
      const RouteInformation(location: '/'),
    );
    RouterObjects._routerDelegate[name] = _routerDelegate;
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      key: const ValueKey('/page1'),
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}
