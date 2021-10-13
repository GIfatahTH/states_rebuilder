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

// class SubRouteWidget extends StatefulWidget {
//   final Widget Function(Widget child)? builder;
//   final Widget Function(
//     BuildContext,
//     Animation<double>,
//     Animation<double>,
//     Widget,
//   )? transitionsBuilder;

//   final Map<String, Widget Function(RouteData data)> routes;

//   SubRouteWidget({
//     this.builder,
//     this.routes = const {},
//     this.transitionsBuilder,
//     Key? key,
//   })  : assert(builder != null || routes.isNotEmpty),
//         super(
//           key: key,
//         );

//   @override
//   _SubRouteWidgetState createState() => _SubRouteWidgetState();
// }

// class _SubRouteWidgetState extends State<SubRouteWidget> {
//   late final String name;
//   late final _RouterDelegate _routerDelegate;
//   late final _RouteInformationParser _routeInformationParser;
//   final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
//   static late String? initialRoute;
//   late VoidCallback disposer;

//   @override
//   void initState() {
//     super.initState();
//     name = resolvePathRouteUtil.absolutePath
//         .replaceFirst(initialRoute == '/' ? '' : initialRoute!, '');
//     _routerDelegate = _RouterDelegate(
//       key: key,
//       routes: widget.routes,
//       baseRouteName: name,
//       transitionsBuilder:
//           widget.transitionsBuilder ?? RM.navigate.transitionsBuilder,
//     );
//     RouterObjects._routerDelegate[name] = _routerDelegate;
//     disposer = () => RouterObjects._routerDelegate.remove(name);
//     _routeInformationParser = _RouteInformationParser(_routerDelegate);
//     _routeInformationParser.parseRouteInformation(
//       RouteInformation(location: initialRoute),
//     );
//     initialRoute = null;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     disposer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final router = Router(
//       key: ValueKey(name),
//       routerDelegate: _routerDelegate,
//       routeInformationParser: _routeInformationParser,
//     );
//     if (widget.builder != null) {
//       return widget.builder!(router);
//     }
//     return router;
//   }
// }
