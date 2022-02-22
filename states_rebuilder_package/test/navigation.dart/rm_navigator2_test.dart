// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors, prefer_function_declarations_over_variables, body_might_complete_normally_nullable
import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/scr/navigation/injected_navigator.dart';
import 'package:states_rebuilder/scr/state_management/common/logger.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

SimpleRouteInformationProvider? _provider;
_RouteInformationParserTest? informationParser;
BackButtonDispatcher dispatcher = RootBackButtonDispatcher();

late InjectedNavigator _navigator;

class _TopWidget extends TopStatelessWidget {
  _TopWidget({
    Key? key,
    required this.routers,
    this.initialRoute,
    Redirect? Function(RouteData)? routeInterceptor,
    bool debugPrintWhenRouted = false,
    Page<dynamic> Function(MaterialPageArgument)? pageBuilder,
    Widget Function(Widget)? builder,
    bool? Function(RouteData?)? onBack,
    Duration? transitionDuration,
    Widget Function(RouteData)? unknownRoute,
    bool shouldUseCupertinoPage = false,
    bool ignoreSingleRouteMapAssertion = true,
  }) : super(key: key) {
    InjectedNavigatorImp.ignoreSingleRouteMapAssertion =
        ignoreSingleRouteMapAssertion;
    _navigator = RM.injectNavigator(
      routes: routers,
      unknownRoute: unknownRoute ?? (data) => Text('404 ${data.location}'),
      transitionsBuilder: _transitionsBuilder,
      transitionDuration: transitionDuration,
      onNavigate: routeInterceptor,
      debugPrintWhenRouted: debugPrintWhenRouted,
      pageBuilder: pageBuilder,
      onNavigateBack: onBack,
      initialLocation: initialRoute,
      builder: builder,
      shouldUseCupertinoPage: shouldUseCupertinoPage,
    );
  }
  final Map<String, Widget Function(RouteData p1)> routers;
  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: _provider,
      routeInformationParser: _provider != null
          ? informationParser = _RouteInformationParserTest(
              _navigator.routerDelegate as RouterDelegateImp,
            )
          : _navigator.routeInformationParser,
      routerDelegate: _navigator.routerDelegate,
      backButtonDispatcher: dispatcher,
    );
  }
}

Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
)? _transitionsBuilder;

class Route1 extends StatefulWidget {
  final dynamic data;
  const Route1(this.data);

  @override
  _Route1State createState() => _Route1State();
}

class _Route1State extends State<Route1> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Route1: ${widget.data}');
  }
}

class Route2 extends StatefulWidget {
  final dynamic data;
  const Route2(this.data);

  @override
  _Route2State createState() => _Route2State();
}

class _Route2State extends State<Route2> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Route2: ${widget.data}');
  }
}

_TopWidget get app => _TopWidget(
      routers: {
        '/': (_) => Text('Home'),
        '/Route1': (data) => Route1(data.arguments as String),
        '/Route2': (data) => Route2(data.arguments as String),
        '/Route3': (_) => Text('Route3'),
      },
    );

void main() {
  setUp(() {
    _transitionsBuilder = null;
    _provider = null;
  });
  testWidgets('navigate to', (tester) async {
    await tester.pumpWidget(app);
    expect(RM.context, isNotNull);
    expect(Navigator.of(RM.context!), isNotNull);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.to(
      Route1('data'),
      fullscreenDialog: true,
      maintainState: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Route1: data'), findsOneWidget);
    //
    RM.navigate.toReplacement(Route2('data'), result: '');
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
    //
    _navigator.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('navigate to named', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    _navigator.to(
      'Route1',
      arguments: 'data',
      fullscreenDialog: true,
      maintainState: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Route1: data'), findsOneWidget);
    //
    _navigator.toReplacement(
      'Route2',
      arguments: 'data',
      result: '',
      fullscreenDialog: true,
      maintainState: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
    //
    _navigator.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  // testWidgets('navigate to remove until', (tester) async {
  //   await tester.pumpWidget(app);

  //   expect(find.text('Home'), findsOneWidget);
  //   _navigator.to('Route1', arguments: 'data');
  //   await tester.pumpAndSettle();
  //   _navigator.to('Route3', arguments: 'data');
  //   await tester.pumpAndSettle();
  //   //
  //   RM.navigate.toAndRemoveUntil(
  //     Route2('data'),
  //     name: 'ROUTE2',
  //     untilRouteName: '/',
  //     fullscreenDialog: true,
  //     maintainState: false,
  //   );
  //   await tester.pumpAndSettle();
  //   expect(find.text('Route2: data'), findsOneWidget);
  //   //
  //   _navigator.back();
  //   await tester.pumpAndSettle();
  //   expect(find.text('Home'), findsOneWidget);
  //   //With route name
  //   RM.navigate.toAndRemoveUntil(
  //     Route2('data'),
  //     name: 'ROUTE2',
  //     untilRouteName: '/',
  //   );
  //   _navigator.to('Route1', arguments: 'data');
  //   await tester.pumpAndSettle();
  //   _navigator.to('Route3', arguments: 'data');
  //   await tester.pumpAndSettle();
  //   //
  //   RM.navigate.toAndRemoveUntil(
  //     Route1(''),
  //     untilRouteName: 'ROUTE2',
  //   );
  //   await tester.pumpAndSettle();
  //   expect(find.text('Route1: '), findsOneWidget);
  //   _navigator.back();
  //   await tester.pumpAndSettle();
  //   expect(find.text('Route2: data'), findsOneWidget);
  //   //
  //   _navigator.back();
  //   await tester.pumpAndSettle();
  //   expect(find.text('Home'), findsOneWidget);
  // });

  // testWidgets('navigate to remove all', (tester) async {
  //   await tester.pumpWidget(app);

  //   expect(find.text('Home'), findsOneWidget);
  //   _navigator.to('Route1', arguments: 'data');
  //   await tester.pumpAndSettle();
  //   _navigator.to('Route3', arguments: 'data');
  //   await tester.pumpAndSettle();
  //   //
  //   RM.navigate.toAndRemoveUntil(
  //     Route2('data'),
  //     name: 'ROUTE2',
  //     fullscreenDialog: true,
  //     maintainState: false,
  //   );
  //   await tester.pumpAndSettle();
  //   expect(find.text('Route2: data'), findsOneWidget);
  //   //
  //   _navigator.back();
  //   await tester.pumpAndSettle();
  //   expect(find.text('Route2: data'), findsNothing);
  //   expect(find.text('Home'), findsNothing);
  // });

  testWidgets('navigate to named remove  until', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    _navigator.to('Route1', arguments: '');
    await tester.pumpAndSettle();
    _navigator.to('Route2', arguments: '');
    await tester.pumpAndSettle();
    //
    _navigator.toAndRemoveUntil(
      'Route3',
      arguments: 'data',
      untilRouteName: '/Route1',
      fullscreenDialog: true,
      maintainState: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    _navigator.back();
    await tester.pumpAndSettle();
    expect(find.text('Route1: '), findsOneWidget);
    _navigator.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('navigate to named remove  all', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    _navigator.to('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    _navigator.to('Route2', arguments: 'data');
    await tester.pumpAndSettle();
    //
    _navigator.toAndRemoveUntil(
      'Route3',
      arguments: 'data',
    );
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    _navigator.back();
    await tester.pumpAndSettle();
    // only one route so it can not pop
    expect(find.text('Route3'), findsOneWidget);
  });

  testWidgets('back until', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    _navigator.to('Route1', arguments: 'data');
    await tester.pumpAndSettle();

    _navigator.to('Route2', arguments: 'data');
    await tester.pumpAndSettle();

    _navigator.to('Route3', arguments: 'data');
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    _navigator.backUntil('/Route1');
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.text('Route1: data'), findsOneWidget);
    //
    _navigator.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('back and to named', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    _navigator.to('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    _navigator.to('Route2', arguments: 'data');
    await tester.pumpAndSettle();
    _navigator.to('Route3', arguments: 'data');
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    RM.navigate.backAndToNamed(
      'Route1',
      arguments: 'data',
      result: '',
      fullscreenDialog: true,
      maintainState: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Route1: data'), findsOneWidget);
    //
    _navigator.back();
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
  });

  testWidgets('to CupertinoDialog', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toCupertinoDialog(
      Dialog(
        child: Text(''),
      ),
      barrierDismissible: false,
    );
    await tester.pumpAndSettle();
    //
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('to BottomSheet', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toBottomSheet(
      Text('bottom sheet'),
      isDismissible: true,
      backgroundColor: Colors.red,
      barrierColor: Colors.black,
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      enableDrag: true,
      isScrollControlled: true,
      shape: BorderDirectional(),
    );
    await tester.pumpAndSettle();
    //
    expect(find.text('bottom sheet'), findsOneWidget);
  });

  testWidgets('to CupertinoModalPopup', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toCupertinoModalPopup(
      Text('toCupertinoModalPopup'),
      semanticsDismissible: true,
      filter: ImageFilter.blur(),
    );
    await tester.pumpAndSettle();
    //
    expect(find.text('toCupertinoModalPopup'), findsOneWidget);
  });

  testWidgets(
      'WHEN RM.navigate.pageRouteBuilder is defined'
      'Route animation uses it'
      'CASE named route', (tester) async {
    //
    //IT will not used because pageRouteBuilder is defined
    RM.navigate.transitionsBuilder = RM.transitions.leftToRight();

    RM.navigate.pageRouteBuilder =
        (Widget nextPage, settings) => PageRouteBuilder(
              settings: settings,
              transitionDuration: Duration(milliseconds: 2000),
              reverseTransitionDuration: Duration(milliseconds: 2000),
              pageBuilder: (context, animation, secondaryAnimation) => nextPage,
              transitionsBuilder: RM.transitions.bottomToUp(),
            );

    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    _navigator.to('Route1', arguments: 'data');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Route1: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);

    //
    _navigator.toReplacement('Route2', arguments: 'data', result: '');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);
    expect(find.text('Route2: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route2: data'), findsOneWidget);
    //
    _navigator.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets(
      'WHEN RM.navigate.transitionsBuilder is defined'
      'Route animation uses it'
      'CASE Widget route', (tester) async {
    RM.disposeAll();
    RM.navigate.transitionsBuilder = RM.transitions.leftToRight(
      duration: Duration(milliseconds: 2000),
    );

    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.to(Route1('data'));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Route1: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);
    //
    RM.navigate.toReplacement(Route2('data'), result: '');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);
    expect(find.text('Route2: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route2: data'), findsOneWidget);
    //
    _navigator.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets(
      'WHEN RM.navigate.transitionsBuilder is defined'
      'Route animation uses it'
      'CASE named route', (tester) async {
    _transitionsBuilder = RM.transitions.rightToLeft(
      duration: Duration(milliseconds: 2000),
    );

    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    _navigator.to('Route1', arguments: 'data');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Route1: data'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Route1: data'), findsOneWidget);

    //
    _navigator.toReplacement('Route2', arguments: 'data', result: '');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);
    expect(find.text('Route2: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route2: data'), findsOneWidget);
    //
    _navigator.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets(
    'WHEN RM.navigate.onGenerateRoute defines an empty routes map'
    'THEN it throws an assertion error',
    (tester) async {
      expect(
        () => MaterialApp(
          home: Container(),
          onGenerateRoute: RM.navigate.onGenerateRoute({}),
        ),
        throwsAssertionError,
      );
    },
  );

  testWidgets(
      'WHEN transitionsBuilder is defined in RM.navigate.onGenerateRoute'
      'THEN it will work', (tester) async {
    final app = _TopWidget(routers: {
      '/': (_) => Text('Home'),
      '/Route1': (data) => Route1(data.arguments as String),
      '/Route2': (data) => Route2(data.arguments as String),
      '/Route3': (_) => Text('Route3'),
    });

    _transitionsBuilder = RM.transitions.rightToLeft(
      duration: Duration(milliseconds: 2000),
    );

    await tester.pumpWidget(app);

    // expect(find.text('Home'), findsOneWidget);
    // _navigator.to('Route1', arguments: 'data');
    // await tester.pump(Duration(seconds: 1));
    // expect(find.text('Home'), findsOneWidget);
    // expect(find.text('Route1: data'), findsNothing);
    // await tester.pump(Duration(seconds: 1));
    // expect(find.text('Route1: data'), findsOneWidget);

    // //
    // _navigator.toReplacement('Route2', arguments: 'data', result: '');
    // await tester.pump(Duration(seconds: 1));
    // expect(find.text('Route1: data'), findsOneWidget);
    // expect(find.text('Route2: data'), findsNothing);
    // await tester.pump(Duration(seconds: 1));
    // expect(find.text('Route2: data'), findsOneWidget);
    // //
    // _navigator.back();
    // await tester.pumpAndSettle();
    // expect(find.text('Home'), findsOneWidget);
  });

  // testWidgets(
  //     'WHEN undefined name route is given'
  //     'THEN it route to default route not found', (tester) async {
  //   final app = MaterialApp(
  //     navigatorKey: RM.navigate.navigatorKey,
  //     onGenerateRoute: RM.navigate.onGenerateRoute(
  //       {
  //         '/': (_) => Text('Home'),
  //         'Route1': (param) => Route1(param as String),
  //         'Route2': (param) => Route2(param as String),
  //         'Route3': (_) => Text('Route3'),
  //       },
  //     ),
  //   );

  //   await tester.pumpWidget(app);

  //   expect(find.text('Home'), findsOneWidget);
  //   _navigator.to('/NAN');
  //   await tester.pumpAndSettle();

  //   expect(find.text('No route defined for /NAN'), findsOneWidget);
  // });

  testWidgets(
      'WHEN undefined name route is given'
      'AND WHEN unknownRoute is defined'
      'THEN it route to custom unknownRoute ', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    _navigator.to('/NAN');
    await tester.pumpAndSettle();

    expect(find.text('404 /NAN'), findsOneWidget);
  });

  // testWidgets(
  //   'WHEN parseRouteUri is used'
  //   'THEN it will extract data from route name',
  //   (tester) async {
  //     final app = MaterialApp(
  //       navigatorKey: RM.navigate.navigatorKey,
  //       onGenerateRoute: RM.navigate.onGenerateRoute(
  //         {
  //           '/': (_) => Text('Home'),
  //           'Route1/:id': (param) => Route1(param as String),
  //           'Route2': (param) => Route2(param as String),
  //         },
  //         // parseRouteUri: (uri, _) {
  //         //   if (uri.pathSegments.length == 2) {
  //         //     if (uri.pathSegments[1] != '1') return null;
  //         //     return RouteSettings(
  //         //       name: 'Route1',
  //         //       arguments: 'Parsed data : ${uri.pathSegments[1]}',
  //         //     );
  //         //   } else if (uri.queryParameters.isNotEmpty) {
  //         //     return RouteSettings(
  //         //       name: 'Route1',
  //         //       arguments: 'Parsed data : ${uri.queryParameters['id']}',
  //         //     );
  //         //   }
  //         // },
  //         unknownRoute: (_) => Text('Unknown Route'),
  //       ),
  //     );
  //     await tester.pumpWidget(app);

  //     expect(find.text('Home'), findsOneWidget);

  //     _navigator.to('Route1/1');
  //     await tester.pumpAndSettle();
  //     expect(find.text('Route1: Parsed data : 1'), findsOneWidget);
  //     //
  //     _navigator.to('Route1/2');
  //     await tester.pumpAndSettle();
  //     expect(find.text('Unknown Route'), findsOneWidget);
  //     //
  //     _navigator.to(Uri(path: 'Route1', queryParameters: {
  //       'id': '2',
  //     }).toString());
  //     await tester.pumpAndSettle();
  //     expect(find.text('Route1: Parsed data : 2'), findsOneWidget);
  //   },
  // );

  testWidgets(
    'WHEN  mixing query params and path params'
    'THEN both are parsed',
    (tester) async {
      final app = _TopWidget(
        routers: {
          '/': (_) => Text('Home'),
          '/Route1/:id': (param) {
            final map = {...param.queryParams, ...param.pathParams};
            return Route1((map['id'] ?? '') + (map['data'] ?? ''));
          },
          '/Route2': (param) => Route2(param as String),
        },
      );
      await tester.pumpWidget(app);

      expect(find.text('Home'), findsOneWidget);

      _navigator.to('Route1/Parsed data : 1');
      await tester.pumpAndSettle();
      expect(find.text('Route1: Parsed data : 1'), findsOneWidget);

      _navigator.to(
        'Route1/toNamed,',
        queryParams: {'data': ' Parsed data : 2'},
      );
      await tester.pumpAndSettle();
      expect(find.text('Route1: toNamed, Parsed data : 2'), findsOneWidget);

      _navigator.toReplacement(
        'Route1/toReplacementNamed,',
        queryParams: {'data': ' Parsed data : 2'},
      );
      await tester.pumpAndSettle();
      expect(find.text('Route1: toReplacementNamed, Parsed data : 2'),
          findsOneWidget);

      _navigator.toAndRemoveUntil(
        'Route1/toNamedAndRemoveUntil,',
        queryParams: {'data': ' Parsed data : 2'},
      );
      await tester.pumpAndSettle();
      expect(find.text('Route1: toNamedAndRemoveUntil, Parsed data : 2'),
          findsOneWidget);
    },
  );

  testWidgets(
    'Nested route trial',
    (tester) async {
      final home = (_) => Text('/');
      final page00 = (_) => Text('$_');
      final page1 = (_) => Text('$_');
      final page11 = (_) => Text('$_');
      final page111 = (_) => Text('$_');
      final page1121 = (_) => Text('$_');
      final page1122 = (_) => Text('$_');
      final page12 = (_) => Text('$_');
      final page13 = (_) => Text('$_');
      final page2 = (_) => Text('$_');
      final page3 = (_) => Text('$_');
      final page4 = (_) => Text('$_');
      final page5 = (_) => Text('$_');
      final page52 = (_) => Text('$_');
      final page521 = (_) => Text('$_');

      Map<String, String> pathParams = {};
      Map<String, String> queryParams = {};
      String routePath = '';
      String baseUrl = '';
      final routes = {
        '/': home,
        '/page0': (_) => RouteWidget(
              routes: {
                '/page00': (_) => page00(_.arguments),
              },
            ),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => page1(_.arguments),
                '/page11': (_) => RouteWidget(
                      routes: {
                        '/': (_) => page11(_.arguments),
                        '/page111': (_) => page111(_.arguments),
                        '/page112': (_) => RouteWidget(
                              routes: {
                                '/page1121': (_) => page1121(_.arguments),
                                '/page1122': (_) => page1122(_.arguments),
                              },
                            ),
                      },
                    ),
                '/page12': (_) => RouteWidget(
                      routes: {
                        '/': (_) => page12(_.arguments),
                      },
                    ),
                '/page13': (_) => page13(_.arguments),
              },
            ),
        '/page2': (_) => page2(_.arguments),
        '/page3': (_) => RouteWidget(
              builder: (__) => page3(_.arguments),
            ),
        '/page4': (_) => page4(_.arguments),
        '/page5/:page5ID': (__) => RouteWidget(
              routes: {
                '/': (data) => Builder(
                      builder: (__) {
                        queryParams = data.queryParams;
                        pathParams = data.pathParams;
                        routePath = data.path;
                        baseUrl = data.baseLocation;
                        return page5(data.arguments);
                      },
                    ),
                '/page51': (data) {
                  return Builder(
                    builder: (ctx) {
                      queryParams = ctx.routeData.queryParams;
                      pathParams = ctx.routeData.pathParams;
                      routePath = ctx.routeData.path;
                      baseUrl = ctx.routeData.baseLocation;
                      return page5(ctx.routeData.arguments);
                    },
                  );
                },
                '/page52/:page52ID': (_) {
                  return RouteWidget(
                    routes: {
                      '/': (_) {
                        return Builder(
                          builder: (ctx) {
                            queryParams = ctx.routeData.queryParams;
                            pathParams = ctx.routeData.pathParams;
                            routePath = ctx.routeData.path;
                            baseUrl = ctx.routeData.baseLocation;
                            return page52(ctx.routeData.arguments);
                          },
                        );
                      },
                      '/:page521ID': (_) => Builder(
                            builder: (ctx) {
                              queryParams = ctx.routeData.queryParams;
                              assert(_.queryParams == queryParams);
                              pathParams = ctx.routeData.pathParams;
                              routePath = ctx.routeData.path;
                              baseUrl = ctx.routeData.baseLocation;
                              return page521(ctx.routeData.arguments);
                            },
                          ),
                    },
                  );
                }
              },
            )
      };
      final widget = _TopWidget(routers: routes);

      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);

      Future navigateAndExpect(String name, [bool isFound = true]) async {
        _navigator.to(name, arguments: name);
        await tester.pumpAndSettle();
        if (isFound) {
          expect(find.text(name), findsOneWidget);
        }
      }

      await navigateAndExpect('/page0/page00');

      await navigateAndExpect('/page1');
      // await navigateAndExpect('/page1/');
      await navigateAndExpect('page1/page1', false);
      expect(find.text('404 /page1/page1'), findsOneWidget);
      await navigateAndExpect('/page1/');
      await navigateAndExpect('page11/');
      //
      await navigateAndExpect('page12', false);
      expect(find.text('404 /page1/page11/page12'), findsOneWidget);
      await navigateAndExpect('page111');
      await navigateAndExpect('page11/page111');
      await navigateAndExpect('page112/page1121');
      await navigateAndExpect('page1122');
      await navigateAndExpect('/page1/page11/page112/page1122');
      await navigateAndExpect('page1/page12');
      await navigateAndExpect('page1/page13');
      await navigateAndExpect('/page2');
      await navigateAndExpect('page4');
      await navigateAndExpect('page3');

      await navigateAndExpect('/page5', false);
      expect(find.text('404 /page5'), findsOneWidget);
      await navigateAndExpect('/page5/id-1');

      expect(baseUrl, '/');
      expect(routePath, '/page5/:page5ID');
      expect(pathParams, {'page5ID': 'id-1'});

      await navigateAndExpect('page5/id-2/');

      expect(baseUrl, '/page5/id-2');
      expect(routePath, '/page5/:page5ID');
      expect(pathParams, {'page5ID': 'id-2'});
      //
      await navigateAndExpect('page51');

      expect(baseUrl, '/page5/id-2');
      expect(routePath, '/page5/:page5ID/page51');
      expect(pathParams, {'page5ID': 'id-2'});

      await navigateAndExpect('page52/id-3/');

      expect(baseUrl, '/page5/id-2/page52/id-3');
      expect(routePath, '/page5/:page5ID/page52/:page52ID');
      expect(pathParams, {'page5ID': 'id-2', 'page52ID': 'id-3'});
      //
      await navigateAndExpect('id-4');
      _navigator.to(
        baseUrl + '/id-5/',
        arguments: 'id-5',
        queryParams: {
          'queryId': 'id-6',
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('id-5'), findsOneWidget);

      expect(baseUrl, '/page5/id-2/page52/id-3/id-5');
      expect(routePath, '/page5/:page5ID/page52/:page52ID/:page521ID');
      expect(pathParams,
          {'page5ID': 'id-2', 'page52ID': 'id-3', 'page521ID': 'id-5'});
      expect(queryParams, {'queryId': 'id-6'});

      _navigator.to('/', arguments: '/');
      _navigator.to('/page1/', arguments: '/page1');
      _navigator.to('page11/', arguments: 'page11');
      _navigator.to('page112/page1122', arguments: 'page112/page1122');
      await tester.pumpAndSettle();
      expect(find.text('page112/page1122'), findsOneWidget);
      //
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('page11'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN Nested routes are defined using RouteWidget'
    'THEN context.routeWidget get the right subRoute',
    (tester) async {
      final home = (_) => Text('/');
      final page1 = (_) => Text('$_');
      final page11 = (_) => Text('$_');
      final page111 = (_) => Text('$_');
      final page112 = (_) => Text('$_');
      final page1121 = (_) => Text('$_');
      final page1122 = (_) => Text('$_');
      final page12 = (_) => Text('$_');
      // final page2 = (_) => Text('$_');
      var getSubRoute = false;

      final routes = {
        '/': home,
        '/page1': (_) {
          return RouteWidget(
            builder: (child) {
              return getSubRoute
                  ? Builder(
                      builder: (context) {
                        assert(child == context.routerOutlet);
                        return context.routerOutlet;
                      },
                    )
                  : page1('/page1');
            },
            routes: {
              '/page12': (_) {
                return Builder(
                  builder: (context) {
                    return page12(_.arguments);
                  },
                );
              },
              '/page11': (_) => RouteWidget(
                    builder: (_) => _,
                    routes: {
                      '/': (_) => Builder(
                            builder: (context) {
                              return page11(context.routeData.arguments);
                            },
                          ),
                      '/page111': (_) => page111(_.arguments),
                      '/page112': (_) {
                        return RouteWidget(
                          builder: (_) => getSubRoute
                              ? Builder(
                                  builder: (context) {
                                    return context.routerOutlet;
                                  },
                                )
                              : page112('/page112'),
                          routes: {
                            '/page1121': (_) => page1121(_.arguments),
                            '/page1122': (_) => page1122(_.arguments),
                          },
                        );
                      },
                    },
                  ),
            },
          );
        },
        '/page2': (_) => Builder(
              builder: (context) {
                return context.routerOutlet;
              },
            ),
      };
      final widget = _TopWidget(routers: routes);

      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);

      Future navigateAndExpect(String name, [bool isFound = true]) async {
        _navigator.to(name, arguments: name);
        await tester.pumpAndSettle();
        if (isFound) {
          expect(find.text(name), findsOneWidget);
        }
      }

      _navigator.to('page1/page12', arguments: 'page1/page12');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);

      getSubRoute = true;
      await navigateAndExpect('page1/page11');

      await navigateAndExpect('page1/page12');

      await navigateAndExpect('page1/page11/page112', false);
      expect(find.text('404 /page1/page11/page112'), findsOneWidget);

      await navigateAndExpect('page1/page12');
      await navigateAndExpect('page111', false);
      expect(find.text('404 /page1/page111'), findsOneWidget);
      await navigateAndExpect('page1/page11/');
      await navigateAndExpect('page111');
      await navigateAndExpect('page11/page111');
      await navigateAndExpect('page112/page1121');
      await navigateAndExpect('page1122');
      await navigateAndExpect('/page1/page11/page112/page1122');
      await navigateAndExpect('page1/page12');
      await navigateAndExpect('page13', false);
      expect(find.text('404 /page1/page13'), findsOneWidget);

      await navigateAndExpect('/page2', false);
      expect(tester.takeException(), isAssertionError);
    },
  );

  testWidgets(
    'WHEN RouteWidget is defined with builder and without routes'
    'AND WHEN the exposed route or the route from the context is used'
    'THEN it throws non defined sub routes assertion',
    (tester) async {
      final routes = {
        '/': (data) => RouteWidget(
              builder: (route) {
                return Text('');
              },
            ),
        '/page1': (data) => RouteWidget(
              builder: (route) {
                return Builder(
                  builder: (context) {
                    return context.routerOutlet;
                  },
                );
              },
            ),
      };

      final widget = _TopWidget(routers: routes);

      await tester.pumpWidget(widget);
      // expect(tester.takeException(), isAssertionError);
      _navigator.to('/page1');
      await tester.pump();
      expect(tester.takeException(), isAssertionError);
    },
  );

  testWidgets(
    'WHEN RouteWidget builder do not use the route'
    'THEN it works normally even if route is not found',
    (tester) async {
      final routes = {
        '/': (data) => RouteWidget(
              builder: (route) {
                return Text('builder/');
              },
              routes: {
                '/': (data) => Text('/'),
              },
            ),
        '/page1': (data) => RouteWidget(
              builder: (route) {
                return Builder(
                  builder: (context) {
                    return Text('builder/page1');
                  },
                );
              },
              routes: {
                '/': (data) => Text('/page1'),
                '/page11': (data) => Text('/page11'),
              },
            ),
      };

      final widget = _TopWidget(routers: routes);

      await tester.pumpWidget(widget);
      expect(find.text('builder/'), findsOneWidget);
      //
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('builder/page1'), findsOneWidget);

      _navigator.to('/page1/page11');
      await tester.pumpAndSettle();
      expect(find.text('builder/page1'), findsOneWidget);
      //
      _navigator.to('/page1/notFound');
      await tester.pumpAndSettle();
      expect(find.text('builder/page1'), findsOneWidget);
    },
  );

  testWidgets(
    'context.routeBaseUrl get the right value',
    (tester) async {
      RouteData? data1;
      RouteData? data2;
      RouteData? data3;
      final Map<String, Widget Function(RouteData)> routes = {
        '/page1/:id': (data) {
          return RouteWidget(
            builder: (route) {
              final id = data.pathParams['id'];
              return Column(
                children: [
                  Text('page1/$id'),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        data1 = context.routeData;
                        assert(data1!.location == data.location);
                        return route;
                      },
                    ),
                  ),
                ],
              );
            },
            routes: {
              '/': (data) {
                return RouteWidget(
                  builder: (route) {
                    return Builder(
                      builder: (context) {
                        data2 = context.routeData;
                        assert(data2!.location == data.location);
                        return context.routerOutlet;
                      },
                    );
                  },
                  routes: {
                    '/': (data) {
                      return Text('page1/' + data.pathParams['id']!);
                    },
                    '/page11/:user': (data) {
                      return RouteWidget(
                        builder: (route) {
                          return Builder(
                            builder: (context) {
                              data3 = context.routeData;
                              assert(data3!.location == data.location);
                              return context.routerOutlet;
                            },
                          );
                        },
                        routes: {
                          '/': (data) {
                            return Text('page11/' + data.pathParams['user']!);
                          },
                        },
                      );
                    },
                  },
                );
              },
            },
          );
        },
        '/page2/:id': (data) {
          return RouteWidget(
            routes: {
              '/': (data) {
                return RouteWidget(
                  routes: {
                    '/': (data) {
                      return Builder(
                        builder: (context) {
                          data1 = context.routeData;
                          data2 = context.routeData;
                          assert(data1.toString() == data.toString());
                          assert(data2.toString() == data.toString());
                          return Text('page2/' + data.pathParams['id']!);
                        },
                      );
                    },
                    '/page21/:user': (data) => RouteWidget(
                          routes: {
                            '/': (data) => Builder(
                                  builder: (context) {
                                    data3 = context.routeData;
                                    assert(data3.toString() == data.toString());
                                    return Text(
                                        'page21/' + data.pathParams['user']!);
                                  },
                                ),
                          },
                        )
                  },
                );
              },
            },
          );
        },
      };

      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);

      await tester.pumpWidget(widget);
      expect(find.text('404 /'), findsOneWidget);

      _navigator.to('/page1/1');
      await tester.pumpAndSettle();
      expect(find.text('page1/1'), findsNWidgets(2));
      expect(data1!.baseLocation, '/');
      expect(data1!.location, '/page1/1');
      expect(data2!.baseLocation, '/');
      expect(data2!.location, '/page1/1');
      expect(data3, null);
      //
      _navigator.back();
      await tester.pumpAndSettle();
      data1 = data2 = data3 = null;
      _navigator.to('/page1/1/');
      await tester.pumpAndSettle();
      expect(find.text('page1/1'), findsNWidgets(2));
      expect(data1!.baseLocation, '/page1/1');
      expect(data1!.location, '/page1/1');
      expect(data2!.baseLocation, '/page1/1');
      expect(data2!.location, '/page1/1');
      expect(data3, null);
      _navigator.back();
      await tester.pumpAndSettle();
      //
      data1 = data2 = data3 = null;
      _navigator.to('/page1/1/page11/user1');
      await tester.pumpAndSettle();
      expect(data1!.baseLocation, '/page1/1');
      expect(data1!.location, '/page1/1/page11/user1');
      expect(data2!.baseLocation, '/page1/1');
      expect(data2!.location, '/page1/1/page11/user1');
      expect(data3!.baseLocation, '/page1/1');
      expect(data3!.location, '/page1/1/page11/user1');
      _navigator.back();
      await tester.pumpAndSettle();
      //
      // data1 = data2 = data3 = null;
      _navigator.to('/page1/1/page11/user1/');
      await tester.pumpAndSettle();
      expect(data1!.baseLocation, '/page1/1/page11/user1');
      expect(data1!.location, '/page1/1/page11/user1');
      expect(data2!.baseLocation, '/page1/1/page11/user1');
      expect(data2!.location, '/page1/1/page11/user1');
      expect(data3!.baseLocation, '/page1/1/page11/user1');
      expect(data3!.location, '/page1/1/page11/user1');

      data1 = data2 = data3 = null;
      _navigator.to('/page2/1');
      await tester.pumpAndSettle();
      expect(find.text('page2/1'), findsNWidgets(1));
      expect(data1!.baseLocation, '/');
      expect(data1!.location, '/page2/1');
      expect(data2!.baseLocation, '/');
      expect(data2!.location, '/page2/1');
      expect(data3, null);
      //
      _navigator.back();
      await tester.pumpAndSettle();
      data1 = data2 = data3 = null;
      _navigator.to('/page2/1/');
      await tester.pumpAndSettle();
      expect(find.text('page2/1'), findsNWidgets(1));
      expect(data1!.baseLocation, '/page2/1');
      expect(data1!.location, '/page2/1');
      expect(data2!.baseLocation, '/page2/1');
      expect(data2!.location, '/page2/1');
      expect(data3, null);
      //
      data1 = data2 = data3 = null;
      _navigator.to('/page2/1/page21/user1');
      await tester.pumpAndSettle();
      expect(data1, null);
      expect(data2, null);
      expect(data3!.baseLocation, '/page2/1');
      expect(data3!.location, '/page2/1/page21/user1');

      //
      _navigator.back();
      await tester.pumpAndSettle();
      data1 = data2 = data3 = null;
      _navigator.to('/page2/1/page21/user1/');
      await tester.pumpAndSettle();
      expect(data1, null);
      expect(data2, null);
      expect(data3!.baseLocation, '/page2/1/page21/user1');
      expect(data3!.location, '/page2/1/page21/user1');
    },
  );
  testWidgets(
    'Test route is not found',
    (tester) async {
      final Map<String, Widget Function(RouteData)> routes = {
        '/page1': (_) => Text(''),
        '/page2': (_) => RouteWidget(
              builder: (_) => Text(''),
            ),
        '/page3': (_) => RouteWidget(
              routes: {
                '/': (_) => Text(''),
                '/page31': (_) {
                  return RouteWidget(
                    builder: (_) => Text(''),
                  );
                },
              },
            ),
        '/page4': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text(''),
                '/page41': (_) {
                  return RouteWidget(
                    builder: (_) => Text(''),
                  );
                },
              },
            ),
      };

      final widget = _TopWidget(routers: routes);

      await tester.pumpWidget(widget);
      expect(find.text('404 /'), findsOneWidget);
      _navigator.to('/page1/notFound');
      await tester.pumpAndSettle();
      expect(find.text('404 /page1/notFound'), findsOneWidget);
      //
      _navigator.to('/page2/notFound');
      await tester.pumpAndSettle();
      expect(find.text('404 /page2/notFound'), findsOneWidget);
      //
      _navigator.to('/page3/notFound');
      await tester.pumpAndSettle();
      expect(find.text('404 /page3/notFound'), findsOneWidget);
      _navigator.to('/page3/page31/notFound');
      await tester.pumpAndSettle();
      expect(find.text('404 /page3/page31/notFound'), findsOneWidget);
      //
      _navigator.to('/page4/notFound');
      await tester.pumpAndSettle();
      expect(find.text('404 /page4/notFound'), findsOneWidget);
      _navigator.to('/page4/page41/notFound');
      await tester.pumpAndSettle();
      expect(find.text('404 /page4/page41/notFound'), findsOneWidget);
    },
  );

  testWidgets(
    'Check we get the right baseUrl',
    (tester) async {
      RouteData? routeData;
      final routes = {
        '/': (data) => Text('/'),
        '/page1': (data) => RouteWidget(
              builder: (r) {
                return r;
              },
              routes: {
                '/': (d) {
                  return Builder(
                    builder: (context) {
                      routeData = d;
                      final ctxData = context.routeData;
                      assert(routeData == ctxData);
                      return Text('/page1');
                    },
                  );
                },
                '/page11': (d) {
                  return Builder(
                    builder: (context) {
                      routeData = d;
                      final ctxData = context.routeData;
                      assert(routeData == ctxData);
                      return Text('/page1/page11');
                    },
                  );
                },
              },
            ),
        '/page2/:id': (_) => RouteWidget(
              builder: (r) {
                return r;
              },
              routes: {
                '/': (d) {
                  return Builder(
                    builder: (context) {
                      routeData = d;
                      final ctxData = context.routeData;
                      assert(routeData == ctxData);
                      return Text('/page2: id=' + ctxData.pathParams['id']!);
                    },
                  );
                },
                '/page21': (d) {
                  return Builder(
                    builder: (context) {
                      routeData = d;
                      final ctxData = context.routeData;
                      assert(routeData == ctxData);
                      return Text(
                          '/page2/1/page21: id=' + ctxData.pathParams['id']!);
                    },
                  );
                },
              },
            ),
      };
      final widget = _TopWidget(routers: routes);

      await tester.pumpWidget(widget);
      //
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(routeData!.baseLocation, '/');
      routeData = null;
      _navigator.to('/page1/page11');
      await tester.pumpAndSettle();
      expect(routeData!.baseLocation, '/page1');
      routeData = null;
      _navigator.to('/page1/');
      await tester.pumpAndSettle();
      expect(routeData!.baseLocation, '/page1');
      routeData = null;
      _navigator.to('/page1/page11/');
      await tester.pumpAndSettle();
      expect(routeData!.baseLocation, '/page1/page11');
      expect(find.text('/page1/page11'), findsOneWidget);
      //
      routeData = null;
      _navigator.to('/page2/1');
      await tester.pumpAndSettle();
      expect(routeData!.baseLocation, '/');
      expect(find.text('/page2: id=1'), findsOneWidget);
      //
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page2: id=1'), findsNothing);
      expect(find.text('/page1/page11'), findsOneWidget);
      routeData = null;
      _navigator.to('/page2/1/');
      await tester.pumpAndSettle();
      expect(routeData!.baseLocation, '/page2/1');
      expect(find.text('/page2: id=1'), findsOneWidget);
      //
      routeData = null;
      _navigator.to('/page2/1/page21');
      await tester.pumpAndSettle();
      expect(routeData!.baseLocation, '/page2/1');
      expect(find.text('/page2/1/page21: id=1'), findsOneWidget);
      //
      _navigator.back();
      await tester.pumpAndSettle();
      routeData = null;
      _navigator.to('/page2/1/page21/');
      await tester.pumpAndSettle();
      expect(routeData!.baseLocation, '/page2/1/page21');
      _navigator.to('/page2/1/page21/');
    },
  );

  testWidgets(
    'WHEN the same route is pushed twice'
    'THEN the new route is ignored',
    (tester) async {
      final routes = {
        '/': (_) {
          return Builder(
            builder: (context) {
              return Text('/');
            },
          );
        },
        '/page1': (_) => Text('/page1'),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      _navigator.to('/');
      await tester.pumpAndSettle();
      //
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      //
      _navigator.to('/');
      await tester.pumpAndSettle();
      _navigator.to('/');
      await tester.pumpAndSettle();
      //
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      //
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );
  testWidgets(
    'when back is called it will resolves the future and returns the result'
    'case without sub routes',
    (tester) async {
      final routes = {
        '/': (_) {
          return Builder(
            builder: (context) {
              return Text('/');
            },
          );
        },
        '/page1': (_) => Text('/page1'),
        '/page2': (_) => Text('/page2'),
        '/page3': (_) => Text('/page2'),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      dynamic message;
      _navigator.to('/page1').then((value) {
        return message = '$value page1';
      });

      await tester.pumpAndSettle();
      expect(message, null);
      _navigator.to('page2').then((value) {
        return message = '$value page2';
      });
      await tester.pumpAndSettle();
      _navigator.to('page3');
      await tester.pumpAndSettle();
      _navigator.back('message from');
      await tester.pumpAndSettle();
      expect(message, null);
      //
      _navigator.back('message from');
      await tester.pumpAndSettle();
      expect(message, 'message from page2');
      //
      _navigator.back('message from');
      await tester.pumpAndSettle();
      expect(message, 'message from page1');
      //
      message = null;
      _navigator.to('/page1').then((value) {
        return message = '$value page1';
      });
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      //
      _navigator.toReplacement('/page2', result: 'message from').then((value) {
        return message = '$value page2';
      });
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      expect(message, 'message from page1');
      _navigator.back('message from');
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(message, 'message from page2');
      //
    },
  );
  testWidgets(
    'when back is called it will resolves the future and returns the result'
    'case with sub routes',
    (tester) async {
      final routes = {
        '/': (_) {
          return Builder(
            builder: (context) {
              return Text('/');
            },
          );
        },
        '/page1': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page1'),
              },
            ),
        '/page2': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page2'),
              },
            ),
        '/page3': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page3'),
              },
            ),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      dynamic message;
      _navigator.to('/page1').then((value) {
        return message = '$value page1';
      });

      await tester.pumpAndSettle();
      expect(message, null);
      _navigator.to('page2').then((value) {
        return message = '$value page2';
      });
      await tester.pumpAndSettle();
      _navigator.to('page3');
      await tester.pumpAndSettle();
      _navigator.back('message from');
      await tester.pumpAndSettle();
      expect(message, null);
      //
      _navigator.back('message from');
      await tester.pumpAndSettle();
      expect(message, 'message from page2');
      //
      _navigator.back('message from');
      await tester.pumpAndSettle();
      expect(message, 'message from page1');
      //
      message = null;
      _navigator.to('/page1').then((value) {
        return message = '$value page1';
      });
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      //
      _navigator.toReplacement('/page2', result: 'message from').then((value) {
        return message = '$value page2';
      });
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      expect(message, 'message from page1');
      _navigator.back('message from');
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(message, 'message from page2');
      //
    },
  );

  testWidgets(
    'Check backUntil'
    'Case without sub routes',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => Text('/page1'),
        '/page2': (_) => Text('/page2'),
        '/page3': (_) => Text('/page3'),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      _navigator.to('/page3');
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      //
      _navigator.backUntil('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      _navigator.backUntil('/404');
      await tester.pumpAndSettle();
      // expect(RouterObjects.routerDelegates.length, 1);
      // expect(RouterObjects.routerDelegates.keys, ['/RoOoT']);
    },
  );
  testWidgets(
    'Check backUntil'
    'Case with sub routes',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page1'),
              },
            ),
        '/page2': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page2'),
              },
            ),
        '/page3': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page3'),
              },
            ),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      dynamic message;
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      _navigator.to('/page3');
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      //
      _navigator.backUntil('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      // expect(RouterObjects.routerDelegates.length, 2);
      // expect(RouterObjects.routerDelegates.keys, ['/RoOoT', '/page1']);
      //
      _navigator.backUntil('/404');
      await tester.pumpAndSettle();
      // expect(RouterObjects.routerDelegates.length, 2);
      // expect(RouterObjects.routerDelegates.keys, ['/RoOoT', '/page1']);
    },
  );

  testWidgets(
    'Check toReplacement'
    'Case without sub routes',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => Text('/page1'),
        '/page2': (_) => Text('/page2'),
        '/page3': (_) => Text('/page3'),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(RouterObjects.rootDelegate!.routeStack.length, 3);
      _navigator.toReplacement('/page3');
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 3);
      //
    },
  );
  testWidgets(
    'Check toReplacement'
    'Case with sub routes',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page1'),
              },
            ),
        '/page2': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page2'),
                '/page21': (_) => Text('/page21'),
              },
            ),
        '/page3': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page3'),
              },
            ),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      _navigator.to('/page2/page21');
      await tester.pumpAndSettle();
      _navigator.toReplacement('/page3');
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      //
    },
  );

  testWidgets(
    'Check toNamedAndRemoveUntil'
    'Case without sub routes',
    (tester) async {
      final navigator = RM.injectNavigator(
        transitionDuration: const Duration(seconds: 1),
        routes: {
          '/': (_) => Scaffold(appBar: AppBar(title: Text('/'))),
          '/page1': (_) => Scaffold(appBar: AppBar(title: Text('/page1'))),
          '/page2': (_) => Scaffold(appBar: AppBar(title: Text('/page2'))),
          '/page3': (_) => Scaffold(appBar: AppBar(title: Text('/page3'))),
        },
      );
      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      navigator.toAndRemoveUntil('/page1');
      await tester.pump();
      await tester.pump();
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      //
      navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);
      //
      navigator.toAndRemoveUntil('/');
      await tester.pump();
      await tester.pump();
      expect(find.text('/page2'), findsOneWidget);
      expect(find.text('/'), findsOneWidget);
      //Should be findsOneWidget (Maybe no problem because we get similar similar behavior with Navigator1 flutter)
      expect(find.byType(BackButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/page2'), findsOneWidget);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/page2'), findsNothing);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      //
      navigator.to('/page3');
      navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(RouterObjects.rootDelegate!.routeStack.length, 3);
      //
      navigator.toAndRemoveUntil('/page2', untilRouteName: '/');
      await tester.pump();
      await tester.pump();
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/page1'), findsNothing);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 2);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(RouterObjects.rootDelegate!.routeStack.length, 1);
    },
  );

  testWidgets(
    'Check toNamedAndRemoveUntil functionality'
    'Case with sub routes',
    (tester) async {
      final navigator = RM.injectNavigator(
        transitionDuration: const Duration(seconds: 1),
        routes: {
          '/': (_) => Scaffold(appBar: AppBar(title: Text('/'))),
          '/page1': (_) => RouteWidget(
                routes: {
                  '/': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page1'))),
                  '/page11': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page11'))),
                },
              ),
          '/page2': (_) => RouteWidget(
                routes: {
                  '/': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page2'))),
                  '/page11': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page21'))),
                },
              ),
          '/page3': (_) => RouteWidget(
                routes: {
                  '/': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page3'))),
                  '/page11': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page31'))),
                },
              ),
        },
      );
      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      navigator.toAndRemoveUntil('/page1');
      await tester.pump();
      await tester.pump();
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      //
      navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);
      //
      navigator.toAndRemoveUntil('/');
      await tester.pump();
      await tester.pump();
      expect(find.text('/page2'), findsOneWidget);
      expect(find.text('/'), findsOneWidget);
      // With no nested route we get findsNothing
      // (It is logic here (delegateImplyLeadingToParent is true))
      expect(find.byType(BackButton), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/page2'), findsOneWidget);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/page2'), findsNothing);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      //
      navigator.to('/page3');
      navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(RouterObjects.rootDelegate!.routeStack.length, 3);
      //
      navigator.toAndRemoveUntil('/page2', untilRouteName: '/');
      await tester.pump();
      await tester.pump();
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/page1'), findsNothing);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 2);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(RouterObjects.rootDelegate!.routeStack.length, 1);
    },
  );

  testWidgets(
    'Check toNamedAndRemoveUntil with no untilRoute'
    'Case without sub routes',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => Text('/page1'),
        '/page2': (_) => Text('/page2'),
        '/page3': (_) => Text('/page3'),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(RouterObjects.rootDelegate!.routeStack.length, 3);
      _navigator.toAndRemoveUntil('/page3');
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 1);
      // expect(
      //     RouterObjects.routerDelegates[RouterObjects.root]!.values.last
      //         .routeStack.first.name,
      //     '/page3');
      //
    },
  );

  testWidgets(
    'Check toNamedAndRemoveUntil'
    'Case with sub routes',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page1'),
              },
            ),
        '/page2': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page2'),
                '/page21': (_) => Text('/page21'),
              },
            ),
        '/page3': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page3'),
              },
            ),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      // expect(RouterObjects.routerDelegates.length, 3);
      _navigator.toAndRemoveUntil('/page3', untilRouteName: '/');
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      // expect(RouterObjects.routerDelegates.length, 2);
      //
    },
  );

  testWidgets(
    'Check toNamedAndRemoveUntil with no untilRoute'
    'Case with sub routes',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page1'),
              },
            ),
        '/page2': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page2'),
                '/page21': (_) => Text('/page21'),
              },
            ),
        '/page3': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page3'),
              },
            ),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(RouterObjects.rootDelegate!.routeStack.length, 3);
      _navigator.toAndRemoveUntil('/page3');
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 1);
      // expect(
      //     RouterObjects.routerDelegates[RouterObjects.root]!.values.last
      //         .routeStack.first.name,
      //     '/page3');
    },
  );

  testWidgets(
    'Check toReplacement functionality'
    'Case without sub routes',
    (tester) async {
      final navigator = RM.injectNavigator(
        transitionDuration: const Duration(seconds: 1),
        routes: {
          '/': (_) => Scaffold(appBar: AppBar(title: Text('/'))),
          '/page1': (_) => Scaffold(appBar: AppBar(title: Text('/page1'))),
          '/page2': (_) => Scaffold(appBar: AppBar(title: Text('/page2'))),
          '/page3': (_) => Scaffold(appBar: AppBar(title: Text('/page3'))),
        },
      );
      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      navigator.toReplacement('/page1');
      await tester.pump();
      await tester.pump();
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      //
      navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);
      //
      navigator.toReplacement('/');
      await tester.pump();
      await tester.pump();
      expect(find.text('/page2'), findsOneWidget);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/page2'), findsOneWidget);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/page2'), findsNothing);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      //
      navigator.to('/page3');
      await tester.pumpAndSettle();
      navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(RouterObjects.rootDelegate!.routeStack.length, 4);
      //
      navigator.toReplacement('/page2');
      await tester.pump();
      await tester.pump();
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/page1'), findsNothing);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 4);

      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 3);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 2);

      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(RouterObjects.rootDelegate!.routeStack.length, 1);
    },
  );

  testWidgets(
    'Check toReplacement functionality'
    'Case with sub routes',
    (tester) async {
      final navigator = RM.injectNavigator(
        transitionDuration: const Duration(seconds: 1),
        routes: {
          '/': (_) => Scaffold(appBar: AppBar(title: Text('/'))),
          '/page1': (_) => RouteWidget(
                routes: {
                  '/': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page1'))),
                  '/page11': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page11'))),
                },
              ),
          '/page2': (_) => RouteWidget(
                routes: {
                  '/': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page2'))),
                  '/page21': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page21'))),
                },
              ),
          '/page3': (_) => RouteWidget(
                routes: {
                  '/': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page3'))),
                  '/page31': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page31'))),
                },
              ),
        },
      );
      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      navigator.toReplacement('/page1');
      await tester.pump();
      await tester.pump();
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      //
      navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);

      //
      navigator.toReplacement('/page2/page21');
      await tester.pump();
      await tester.pump();
      expect(find.text('/page2'), findsOneWidget);
      expect(find.text('/page21'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/page2'), findsOneWidget);
      expect(find.text('/page21'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/page2'), findsNothing);
      expect(find.text('/page21'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      //
      navigator.to('/page3');
      await tester.pumpAndSettle();
      navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(RouterObjects.rootDelegate!.routeStack.length, 4);
      //
      navigator.toReplacement('/page2');
      await tester.pump();
      await tester.pump();
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('/page1'), findsNothing);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 4);

      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 3);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page21'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(RouterObjects.rootDelegate!.routeStack.length, 2);

      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsNothing);
      expect(RouterObjects.rootDelegate!.routeStack.length, 1);
    },
  );

  testWidgets(
    'WHEN a dialog is pushed and back is invoked'
    'THEN the dialog is popped'
    'case without sub routes',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => Text('/page1'),
        '/page2': (_) => Text('/page2'),
        '/page3': (_) => Text('/page3'),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      RM.navigate.toDialog(AboutDialog());
      await tester.pumpAndSettle();
      expect(find.byType(AboutDialog), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(AboutDialog), findsNothing);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );
  testWidgets(
    'WHEN a dialog is pushed and back is invoked'
    'THEN the dialog is popped'
    'case with sub routes',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page1'),
              },
            ),
        '/page2': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page2'),
                '/page21': (_) => Text('/page21'),
              },
            ),
        '/page3': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page3'),
              },
            ),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      _navigator.to('/page2/page21');
      await tester.pumpAndSettle();
      expect(find.text('/page21'), findsOneWidget);
      RM.navigate.toDialog(AboutDialog());
      await tester.pumpAndSettle();
      expect(find.byType(AboutDialog), findsOneWidget);
      //
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page21'), findsOneWidget);
      expect(find.byType(AboutDialog), findsNothing);

      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'test setRouteStack',
    (tester) async {
      final widget = _TopWidget(
        routers: {
          '/': (_) => Text('/'),
          '/page1': (_) => Text('/page1${_.arguments}${_.queryParams['id']}'),
        },
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      _navigator.setRouteStack((pages) => [
            ...pages,
            PageSettings(
              name: '/page1',
              arguments: 'arg',
              queryParams: const {'id': '1'},
            ),
            PageSettings(
              name: 'new-page',
              child: Text('New page'),
            ),
          ]);
      await tester.pumpAndSettle();
      expect(find.text('New page'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1arg1'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      //
      _navigator.setRouteStack(
        (pages) => pages.to(
          '/page1',
          arguments: 'arg',
          queryParams: const {'id': '1'},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('/page1arg1'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      //
      _navigator.setRouteStack(
        (pages) {
          final p = pages.to(
            '/page1',
            arguments: 'arg',
            queryParams: const {'id': '1'},
          );
          return p..add(PageSettings(name: '/name', child: Text('/name')));
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('/name'), findsOneWidget);
      _navigator.setRouteStack(
        (pages) => pages.to(
          '/page1',
          isStrictMode: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('/page1nullnull'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      //
    },
  );

  testWidgets(
    'Global base url is updated when back is called'
    'THEN',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Text('/page1'),
                '/page11': (_) => Text('/page11'),
              },
            ),
      };
      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      expect(ResolvePathRouteUtil.globalBaseUrl, '/');
      _navigator.to('/page1/');
      await tester.pumpAndSettle();
      expect(ResolvePathRouteUtil.globalBaseUrl, '/page1');
      _navigator.back();
      await tester.pumpAndSettle();
      expect(ResolvePathRouteUtil.globalBaseUrl, '/');
    },
  );

  testWidgets(
    'RouteInformationParser work as expected',
    (tester) async {
      StatesRebuilerLogger.isTestMode = false;
      final routes = {
        '/': (_) {
          return Text('/');
        },
        '/page1': (_) {
          return RouteWidget(
            builder: (_) => Builder(builder: (context) {
              return _;
            }),
            routes: {
              '/': (_) {
                return Text('/page1');
              },
              '/page11': (_) {
                return Text('/page11-${_.queryParams['q']}');
              },
            },
          );
        },
        '/page2': (_) {
          return RouteWidget(
            builder: (_) => Builder(builder: (context) {
              return _;
            }),
            routes: {
              '/': (_) {
                return Text('/page2-${_.queryParams['q']}');
              },
            },
          );
        },
      };

      _provider = SimpleRouteInformationProvider();

      _provider!.value = const RouteInformation(
        location: '/',
      );
      final widget = _TopWidget(
        routers: routes,
        debugPrintWhenRouted: true,
        routeInterceptor: (data) {
          if (data.queryParams['q'] == '10') {
            return data.redirectTo('/page1/page11?q=1');
          }
          if (data.queryParams['q'] == '15') {
            return data.redirectTo('/page2?q=1');
          }
          return null;
        },
      );
      await tester.pumpWidget(widget);

      //
      expect(find.text('/'), findsOneWidget);
      expect(informationParser!.info!.location, '/');
      expect(StatesRebuilerLogger.message.endsWith('DeepLink to: /'), true);
      //
      _provider!.value = const RouteInformation(
        location: '/page1/page11',
      );
      await tester.pumpAndSettle();
      expect(find.text('/page11-null'), findsOneWidget);
      expect(informationParser!.info!.location, '/page1/page11');
      expect(
        StatesRebuilerLogger.message.endsWith('DeepLink to: /page1/page11'),
        true,
      );

      _navigator.back();
      await tester.pumpAndSettle();
      // expect(find.text('/page1'), findsOneWidget);
      // expect(informationParser!.info!.location, '/page1');
      // expect(StatesRebuilerLogger.message.endsWith('Back to: /page1'), true);
      // _navigator.back();
      // await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(informationParser!.info!.location, '/');
      expect(StatesRebuilerLogger.message.endsWith('Back to: /'), true);

      _provider!.value = const RouteInformation(
        location: '/page1/page11?q=1',
      );
      await tester.pumpAndSettle();
      expect(find.text('/page11-1'), findsOneWidget);
      expect(informationParser!.info!.location, '/page1/page11?q=1');
      expect(
        StatesRebuilerLogger.message.endsWith('DeepLink to: /page1/page11?q=1'),
        true,
      );

      _navigator.to('/page1/page11?q=2');
      await tester.pumpAndSettle();
      expect(find.text('/page11-2'), findsOneWidget);
      expect(informationParser!.info!.location, '/page1/page11?q=2');
      expect(
        StatesRebuilerLogger.message.endsWith('Navigate to: /page1/page11?q=2'),
        true,
      );
      //
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page11-1'), findsOneWidget);
      expect(informationParser!.info!.location, '/page1/page11?q=1');
      expect(
          StatesRebuilerLogger.message.endsWith('Back to: /page1/page11?q=1'),
          true);

      // _navigator.back();
      // await tester.pumpAndSettle();
      // expect(find.text('/page1'), findsOneWidget);
      // expect(informationParser!.info!.location, '/page1');
      // expect(StatesRebuilerLogger.message.endsWith('Back to: /page1'), true);

      // //
      // _navigator.back();
      // await tester.pumpAndSettle();
      // expect(find.text('/'), findsOneWidget);
      // expect(informationParser!.info!.location, '/');
      // expect(StatesRebuilerLogger.message.endsWith('Back to: /'), true);

      _navigator.to('/page1/page11?q=1');
      await tester.pumpAndSettle();
      expect(
        StatesRebuilerLogger.message.endsWith('Navigate to: /page1/page11?q=1'),
        true,
      );
      _navigator.to('/page1/page11?q=2');
      await tester.pumpAndSettle();
      expect(
        StatesRebuilerLogger.message.endsWith('Navigate to: /page1/page11?q=2'),
        true,
      );
      _navigator.to('/page1/page11?q=3');
      await tester.pumpAndSettle();
      expect(find.text('/page11-3'), findsOneWidget);
      expect(informationParser!.info!.location, '/page1/page11?q=3');
      expect(
        StatesRebuilerLogger.message.endsWith('Navigate to: /page1/page11?q=3'),
        true,
      );
      //
      _navigator.backUntil('/');
      await tester.pumpAndSettle();
      _provider!.value = const RouteInformation(
        location: '/page1/page11?q=2',
      );
      await tester.pumpAndSettle();
      expect(find.text('/page11-2'), findsOneWidget);
      expect(informationParser!.info!.location, '/page1/page11?q=2');
      expect(
        StatesRebuilerLogger.message.endsWith('DeepLink to: /page1/page11?q=2'),
        true,
      );
      // _navigator.back();
      // await tester.pumpAndSettle();
      // expect(find.text('/page1'), findsOneWidget);
      // expect(StatesRebuilerLogger.message.endsWith('Back to: /page1'), true);

      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(StatesRebuilerLogger.message.endsWith('Back to: /'), true);

      _provider!.value = const RouteInformation(
        location: '/page1/page11?q=10',
      );
      await tester.pumpAndSettle();
      expect(informationParser!.info!.location, '/page1/page11?q=1');
      expect(find.text('/page11-1'), findsOneWidget);
      expect(
        StatesRebuilerLogger.message.endsWith('DeepLink to: /page1/page11?q=1'),
        true,
      );
      // _navigator.back();
      // await tester.pumpAndSettle();
      // expect(find.text('/page1'), findsOneWidget);
      // expect(StatesRebuilerLogger.message.endsWith('Back to: /page1'), true);

      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(StatesRebuilerLogger.message.endsWith('Back to: /'), true);

      _provider!.value = const RouteInformation(
        location: '/page2?q=15',
      );
      await tester.pumpAndSettle();
      expect(find.text('/page2-1'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'test pageBuilder',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/login': (_) => Text('/login'),
      };
      bool useCupertino = true;
      final widget = _TopWidget(
        routers: routes,
        pageBuilder: (arg) {
          if (useCupertino) {
            return CupertinoPage(
              child: arg.child,
              arguments: arg.arguments,
              fullscreenDialog: arg.fullscreenDialog,
              key: arg.key,
              maintainState: arg.maintainState,
              name: arg.name,
              title: arg.name,
            );
          }
          return _MyPage(
            name: arg.name,
            key: arg.key,
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(
          (_navigator.routerDelegate as RouterDelegateImp).pages.last
              is CupertinoPage,
          true);
      useCupertino = false;
      String error = '';
      try {
        await _navigator.to('/login');
      } catch (e) {
        error = e as String;
      }
      expect(error, 'Custom "pageBuilder" must have a child argument');
    },
  );

  testWidgets(
    'test onBack',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/form': (_) => Scaffold(
              appBar: AppBar(),
              body: Text('/form'),
            ),
        '/page1': (_) => Text('/page1'),
      };
      bool isFormDirty = true;
      bool showDialog = false;
      bool showOtherDialog = false;
      final widget = _TopWidget(
        routers: routes,
        onBack: (data) {
          if (data == null) {
            return false;
          }
          if (data.location == '/form' && isFormDirty) {
            if (showDialog) {
              RM.navigate.toDialog(
                AlertDialog(content: Text('')),
                postponeToNextFrame: true,
              );
            }

            RM.scaffold.showSnackBar(SnackBar(content: Text('')));
            return false;
          }
          if (showOtherDialog) {
            RM.navigate.toBottomSheet(
              Text('toBottomSheet'),
              postponeToNextFrame: true,
            );

            RM.navigate.toCupertinoDialog(
              Text('toCupertinoDialog'),
              postponeToNextFrame: true,
            );
            RM.navigate.toCupertinoModalPopup(
              Text('toCupertinoModalPopup'),
              postponeToNextFrame: true,
            );
          }
        },
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      _navigator.to('/form');
      await tester.pumpAndSettle();
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/form'), findsOneWidget);
      // _navigator.back();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('/form'), findsOneWidget);
      showDialog = true;
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      isFormDirty = false;
      showDialog = false;
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/form'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      showOtherDialog = true;
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('toBottomSheet'), findsOneWidget);
      expect(find.text('toCupertinoDialog'), findsOneWidget);
      expect(find.text('toCupertinoModalPopup'), findsOneWidget);
    },
  );

  testWidgets(
    'Text back button',
    (tester) async {
      RouteData? backData;
      bool exitApp = false;
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => Text('/page1'),
                '/page11': (_) => Text('/page11'),
              },
            ),
        '/page2': (_) => Text('/page2'),
      };
      final navigator = RM.injectNavigator(
        routes: routes,
        onNavigateBack: (data) {
          backData = data;
          if (data == null) {
            if (exitApp) return exitApp;
            RM.navigate.toDialog(AlertDialog());
            return exitApp;
          }
        },
      );
      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
        backButtonDispatcher: dispatcher,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      navigator.to('/page1');
      await tester.pumpAndSettle();
      navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      expect(backData!.location, '/page2');
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(backData!.location, '/page1');
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(backData?.location, null);
      expect(find.byType(AlertDialog), findsOneWidget);
      //
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('/'), findsOneWidget);
      //
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(backData?.location, null);
      expect(find.byType(AlertDialog), findsOneWidget);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('/'), findsOneWidget);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('/'), findsOneWidget);
      //
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(backData?.location, null);
      expect(find.byType(AlertDialog), findsOneWidget);
      //
      navigator.forceBack();
      await tester.pumpAndSettle();
      // expect(find.text('/'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      exitApp = true;
      dispatcher.invokeCallback(SynchronousFuture<bool>(true));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      // expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'Text shouldUseCupertinoPage',
    (tester) async {
      bool shouldUseCupertinoPage = false;
      final routes = {
        '/': (_) => Builder(builder: (context) {
              shouldUseCupertinoPage =
                  ModalRoute.of(context) is PageBasedCupertinoPageRoute;
              return Text('/');
            }),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => Text('/page1'),
              },
            ),
      };
      final widget = _TopWidget(
        routers: routes,
        shouldUseCupertinoPage: true,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(shouldUseCupertinoPage, true);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );
  testWidgets(
    'Text shouldUseCupertinoPage with CupertinoApp.router',
    (tester) async {
      bool shouldUseCupertinoPage = false;
      final routes = {
        '/': (_) => Builder(builder: (context) {
              shouldUseCupertinoPage =
                  ModalRoute.of(context) is PageBasedCupertinoPageRoute;
              return Text('/');
            }),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => Text('/page1'),
                '/page11': (_) => Text('/page11'),
              },
            ),
      };
      final navigator = RM.injectNavigator(routes: routes);
      final widget = CupertinoApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(shouldUseCupertinoPage, true);
      navigator.to('/page1');
      await tester.pumpAndSettle();
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  group(
    'redirect',
    () {
      testWidgets(
        'test cyclic redirect infinite loop',
        (tester) async {
          final Map<String, Widget Function(RouteData)> routes = {
            '/': (_) => Text('/'),
            '/page1': (_) => Text('/page1'),
            '/page2': (_) => Text('/page2'),
            '/page3': (_) => Text('/page3'),
            '/page4': (_) => _.redirectTo('/page5'),
            '/page5': (_) => Text('/page3'),
            '/page6': (_) => Text('/page6'),
            '/page7': (_) => RouteWidget(
                  routes: {
                    '/': (_) => _.redirectTo('/page7/0'),
                    '/:id': (_) => Text('/page7/${_.pathParams['id']}'),
                  },
                ),
            '/page8': (_) => _.redirectTo('/page8/0'),
            '/page8/:id': (_) => Text('/page8/${_.pathParams['id']}'),
          };
          final widget = _TopWidget(
            routers: routes,
            // // debugPrintWhenRouted: true,
            routeInterceptor: (data) {
              if (data.location == '/') {
                return data.redirectTo('/');
              }
              if (data.location == '/page1') {
                return data.redirectTo('/page2');
              }
              if (data.location == '/page2') {
                return data.redirectTo('/page3');
              }
              if (data.location == '/page3') {
                return data.redirectTo('/page1');
              }
              if (data.location == '/page5') {
                return data.redirectTo('/page4');
              }
              return null;
            },
          );
          await tester.pumpWidget(widget);
          expect(find.text('404 Infinite redirect loop: (/)'), findsOneWidget);

          _navigator.to('/page1');
          await tester.pumpAndSettle();
          expect(
              find.text('404 Infinite redirect loop: (/page1, /page2, /page3)'),
              findsOneWidget);
          //
          _navigator.to('/page4');
          await tester.pumpAndSettle();
          expect(find.text('404 Infinite redirect loop: (/page4, /page5)'),
              findsOneWidget);

          _navigator.to('/page6');
          await tester.pumpAndSettle();
          expect(find.text('/page6'), findsOneWidget);
          //
          _navigator.to('/unknown');
          await tester.pumpAndSettle();
          expect(find.text('404 /unknown'), findsOneWidget);
          _navigator.to('/page7/10');
          await tester.pumpAndSettle();
          expect(find.text('/page7/10'), findsOneWidget);
          //
          _navigator.to('/page8/10');
          await tester.pumpAndSettle();
          expect(find.text('/page8/10'), findsOneWidget);
        },
      );

      testWidgets(
        'Test global redirect with navigation on data of an other state'
        'THEN',
        (tester) async {
          final isLogged = RM.inject<bool>(
            () => false,
            sideEffects: SideEffects.onData(
              (data) {
                if (!data) {
                  _navigator.toAndRemoveUntil('/login');
                } else {
                  _navigator.toAndRemoveUntil('/');
                }
              },
            ),
          );
          final routes = {
            '/': (_) => Text('/'),
            '/login': (_) => Text('/login'),
          };
          final widget = _TopWidget(
            routers: routes,
            routeInterceptor: (data) {
              if (!isLogged.state && data.location != '/login') {
                return data.redirectTo('/login');
              }

              if (isLogged.state && data.location == '/login') {
                return data.redirectTo('/');
              }
            },
          );
          await tester.pumpWidget(widget);
          expect(find.text('/login'), findsOneWidget);
          isLogged.toggle();
          await tester.pumpAndSettle();
          expect(find.text('/'), findsOneWidget);
          //
          isLogged.toggle();
          await tester.pumpAndSettle();
          expect(find.text('/login'), findsOneWidget);
        },
      );

      testWidgets(
        'Text global redirection',
        (tester) async {
          final routes = {
            '/': (_) => Text('Not reached'),
            '/home': (_) => Text('/home'),
            '/home1': (_) => Text('/home1'),
            '/home2': (_) => Text('/home2'),
            '/home3': (_) => Text('Not reached'),
            '/home4': (_) => Text('Not reached'),
            '/home5': (_) => Text('Not reached'),
            '/page1': (_) => RouteWidget(
                  builder: (_) => Builder(builder: (context) {
                    return _;
                  }),
                  routes: {
                    '/': (_) => Text('/page1'),
                    '/page11': (_) => Text('/page11'),
                  },
                ),
            '/page2': (_) => RouteWidget(
                  builder: (_) => Builder(builder: (context) {
                    return _;
                  }),
                  routes: {
                    '/': (_) => Text('/page2'),
                    '/page21': (_) => Text('/page21'),
                  },
                ),
          };

          _provider = SimpleRouteInformationProvider();

          _provider!.value = const RouteInformation(
            location: '/',
          );
          final widget = _TopWidget(
            routers: routes,
            // // debugPrintWhenRouted: true,
            routeInterceptor: (data) {
              if (data.location == '/') {
                return data.redirectTo('/home');
              }

              if (data.location == '/home3') {
                return data.redirectTo(null);
              }
              if (data.location == '/home4') {
                return data.redirectTo('/');
              }
              if (data.location == '/home5') {
                return data.redirectTo('/page1');
              }
              if (data.location == '/page2') {
                return data.redirectTo('/');
              }
              if (data.location == '/page1/page11') {
                return data.redirectTo('/home');
              }
            },
          );
          await tester.pumpWidget(widget);
          expect(find.text('/home'), findsOneWidget);
          expect(_navigator.routeData.redirectedFrom?.location, '/');
          _navigator.to('/home1');
          await tester.pumpAndSettle();
          expect(find.text('/home1'), findsOneWidget);
          _navigator.to('/home2');
          await tester.pumpAndSettle();
          expect(find.text('/home2'), findsOneWidget);

          _navigator.to('/home3');
          await tester.pumpAndSettle();
          expect(find.text('/home2'), findsOneWidget);
          expect(_navigator.routeData.redirectedFrom, null);

          //
          _navigator.to('/home4?q=1');
          await tester.pumpAndSettle();
          expect(find.text('/home'), findsOneWidget);
          expect(_navigator.routeData.redirectedFrom?.uri.toString(),
              '/home4?q=1');

          // //
          _navigator.to('/home5?q=1');
          await tester.pumpAndSettle();
          expect(find.text('/page1'), findsOneWidget);
          expect(_navigator.routeData.redirectedFrom?.uri.toString(),
              '/home5?q=1');

          _navigator.to('/page1/page11');
          await tester.pumpAndSettle();
          expect(find.text('/home'), findsOneWidget);

          _navigator.to('/page2?q=1');
          await tester.pumpAndSettle();
          expect(find.text('/home'), findsOneWidget);
          expect(_navigator.routeData.redirectedFrom?.uri.toString(),
              '/page2?q=1');
          //
          _navigator.toAndRemoveUntil('/');
          await tester.pumpAndSettle();
          _navigator.back();
          await tester.pumpAndSettle();
          expect(find.text('/home'), findsOneWidget);

          _provider!.value = const RouteInformation(
            location: '/',
          );
          await tester.pumpAndSettle();
          expect(find.text('/home'), findsOneWidget);

          _provider!.value = const RouteInformation(
            location: '/home4',
          );
          await tester.pumpAndSettle();
          expect(find.text('/home'), findsOneWidget);
          _provider!.value = const RouteInformation(
            location: '/home5',
          );
          await tester.pumpAndSettle();
          expect(find.text('/page1'), findsOneWidget);
          expect(informationParser!.info!.location, '/page1');
          _navigator.back();
          await tester.pumpAndSettle();
          expect(find.text('/home'), findsOneWidget);
          expect(informationParser!.info!.location, '/home');
        },
      );

      testWidgets(
        'The default home route is redirected to another route',
        (tester) async {
          final widget = _TopWidget(
            routers: {
              '/': (_) {
                return _.redirectTo('/page1');
              },
              '/page1': (_) => RouteWidget(
                    builder: (_) => _,
                    routes: {
                      '/': (_) {
                        return _.redirectTo(_.location + '/page11');
                      },
                      '/page11': (_) {
                        return RouteWidget(
                          routes: {
                            '/': (_) {
                              return _.redirectTo(_.location + '/page111');
                            },
                            '/page111': (_) {
                              return Text('/page1');
                            },
                          },
                        );
                      },
                    },
                  ),
            },
            routeInterceptor: (data) {
              // data.log();
            },
          );
          await tester.pumpWidget(widget);
          expect(find.text('/page1'), findsOneWidget);
          _navigator.back();
          await tester.pumpAndSettle();
          expect(find.text('/page1'), findsOneWidget);
        },
      );

      testWidgets(
        'WHEN sdf'
        'THEN',
        (tester) async {
          final Map<String, Widget Function(RouteData)> routes = {
            '/': (_) {
              return RouteWidget(
                routes: {
                  '/': (_) {
                    return _.redirectTo('/page1');
                  },
                  '/page1': (_) {
                    return _.redirectTo('/page1/popular');
                  },
                  '/page1/:kind(all|popular)': (_) {
                    return Text(_.pathParams['kind']!);
                  },
                },
              );
            },
            '/login': (data) {
              return Text('login');
            },
          };
          final widget = _TopWidget(
            routers: routes,
            initialRoute: '/login',
            // // debugPrintWhenRouted: true,
            routeInterceptor: (data) {
              // data.log();
            },
          );
          await tester.pumpWidget(widget);
          expect(find.text('login'), findsOneWidget);
          _navigator.to('/');
          await tester.pumpAndSettle();
          expect(find.text('popular'), findsOneWidget);
          _navigator.to('/page1/all');
          await tester.pumpAndSettle();
          expect(find.text('all'), findsOneWidget);
          _navigator.to('/');
          await tester.pumpAndSettle();
          expect(find.text('popular'), findsOneWidget);
          //
          _navigator.back();
          await tester.pumpAndSettle();
          expect(find.text('all'), findsOneWidget);
          //
          _navigator.back();
          await tester.pumpAndSettle();
          expect(find.text('popular'), findsOneWidget);
          //
          _navigator.back();
          await tester.pumpAndSettle();
          expect(find.text('login'), findsOneWidget);
          //
          _navigator.back();
          await tester.pumpAndSettle();
          expect(find.text('popular'), findsOneWidget);
        },
      );
      testWidgets(
        'WHEN redirect is used inside a "/" routeWidget',
        (tester) async {
          bool isSignedIn = false;
          final Map<String, Widget Function(RouteData)> routes = {
            '/signIn': (data) => Text('signIn'),
            '/': (_) {
              return RouteWidget(
                builder: (_) {
                  return Center(child: _);
                },
                routes: {
                  '/': (_) {
                    return _.redirectTo('/books');
                  },
                  '/books': (_) {
                    return RouteWidget(
                      routes: {
                        '/': (_) {
                          return _.redirectTo('/books/popular');
                        },
                        '/:kind(all|popular)': (_) =>
                            Text(_.pathParams['kind']!),
                      },
                    );
                  },
                },
              );
            }
          };
          final widget = _TopWidget(
            routers: routes,
            // // debugPrintWhenRouted: true,
            ignoreSingleRouteMapAssertion: false,
            routeInterceptor: (data) {
              final signingIn = data.location == '/signIn';

              if (!isSignedIn && !signingIn) {
                return data.redirectTo('/signIn');
              } else if (isSignedIn && signingIn) {
                return data.redirectTo('/books');
              }
            },
          );
          await tester.pumpWidget(widget);
          expect(find.text('signIn'), findsOneWidget);
          isSignedIn = true;
          _navigator.to('/signIn');
          await tester.pumpAndSettle();
          expect(find.text('popular'), findsOneWidget);
        },
      );

      testWidgets(
        'WHEN redirect is used inside a "/" routeWidget with builder',
        (tester) async {
          bool isSignedIn = false;
          final Map<String, Widget Function(RouteData)> routes = {
            '/signIn': (data) => Text('signIn'),
            '/': (_) {
              return RouteWidget(
                builder: (_) {
                  return Center(child: _);
                },
                routes: {
                  '/': (_) {
                    return _.redirectTo('/books');
                  },
                  '/books': (_) {
                    return RouteWidget(
                      routes: {
                        '/': (_) {
                          return _.redirectTo('/popular');
                        },
                        '/:kind(all|popular)': (_) =>
                            Text(_.pathParams['kind']!),
                      },
                    );
                  },
                },
              );
            }
          };
          final widget = _TopWidget(
            routers: routes,
            // // debugPrintWhenRouted: true,
            ignoreSingleRouteMapAssertion: false,
            routeInterceptor: (data) {
              final signingIn = data.location == '/signIn';
              if (!isSignedIn && !signingIn) {
                return data.redirectTo('/signIn');
              } else if (isSignedIn && signingIn) {
                return data.redirectTo('/books');
              }
            },
          );
          await tester.pumpWidget(widget);
          expect(find.text('signIn'), findsOneWidget);
          isSignedIn = true;
          _navigator.to('/signIn');
          await tester.pumpAndSettle();
          expect(find.text('popular'), findsOneWidget);
          expect(find.byType(Center), findsOneWidget);
        },
      );

      testWidgets(
        'WHEN redirect form RouteWidget to an outside route',
        (tester) async {
          final Map<String, Widget Function(RouteData)> routes = {
            '/': (data) => Text('/'),
            '/page1': (_) {
              return RouteWidget(
                builder: (_) {
                  return Center(child: _);
                },
                routes: {
                  '/': (_) {
                    return _.redirectTo('/books');
                  },
                },
              );
            },
            // '/books': (data) {
            //   return const Text('/books');
            // },
            '/books': (data) {
              return RouteWidget(
                builder: (_) {
                  return SizedBox(child: _);
                },
                routes: {
                  '/': (data) => const Text('/books'),
                },
              );
            },
          };
          final widget = _TopWidget(
            routers: routes,
            // // debugPrintWhenRouted: true,
            routeInterceptor: (data) {
              // data.log();
            },
          );
          await tester.pumpWidget(widget);
          _navigator.to('/page1');
          await tester.pumpAndSettle();
          expect(find.byType(Center), findsNothing);
          expect(find.byType(SizedBox), findsOneWidget);
          expect(find.text('/books'), findsOneWidget);
        },
      );
      testWidgets(
        'WHEN redirect form RouteWidget to an inside route',
        (tester) async {
          final Map<String, Widget Function(RouteData)> routes = {
            '/': (data) => Text('/'),
            '/page1': (_) {
              return RouteWidget(
                builder: (_) {
                  return Center(child: _);
                },
                routes: {
                  '/': (_) {
                    return _.redirectTo('/books');
                  },
                  '/books': (data) {
                    // return const Text('/books');
                    return RouteWidget(
                      builder: (_) {
                        return SizedBox(child: _);
                      },
                      routes: {
                        '/': (data) => data.redirectTo('/1'),
                        '/:id': (data) {
                          // return const Text('/books');
                          return RouteWidget(
                            builder: (_) {
                              // ignore: avoid_unnecessary_containers
                              return Container(
                                child: Text('/books/${data.pathParams['id']}'),
                              );
                            },
                          );
                        },
                      },
                    );
                  },
                },
              );
            },
          };
          final widget = _TopWidget(
            routers: routes,
            // debugPrintWhenRouted: true,
            ignoreSingleRouteMapAssertion: false,
            routeInterceptor: (data) {
              // data.log();
            },
          );
          await tester.pumpWidget(widget);
          expect(find.byType(Container), findsNothing);
          _navigator.to('/page1');
          await tester.pumpAndSettle();
          expect(find.byType(Center), findsOneWidget);
          expect(find.byType(SizedBox), findsOneWidget);
          expect(find.byType(Container), findsOneWidget);
          expect(find.text('/books/1'), findsOneWidget);
        },
      );

      testWidgets(
        'WHEN redirect form RouteWidget to an inside route (case "/")',
        (tester) async {
          final Map<String, Widget Function(RouteData)> routes = {
            '/signIn': (data) => const Text('/signIn'),
            '/': (_) {
              return RouteWidget(
                builder: (_) {
                  return Center(child: _);
                },
                routes: {
                  '/': (_) {
                    return _.redirectTo('/books');
                  },
                  '/books': (data) {
                    // return const Text('/books');
                    // return _.redirectTo('/books/1');
                    return RouteWidget(
                      builder: (_) {
                        return Container(child: _);
                      },
                      routes: {
                        '/': (data) => _.redirectTo('/books/1'),
                        '/:id': (_) => Text('/books/${_.pathParams['id']}'),
                      },
                    );
                  },
                  // '/books/:id': (data) {
                  //   // return const Text('/books');
                  //   return RouteWidget(
                  //     builder: (_) {
                  //       return Container(child: _);
                  //     },
                  //     routes: {
                  //     },
                  //   );
                  // },
                },
              );
            },
          };
          final widget = _TopWidget(
            initialRoute: 'signIn',
            routers: routes,
            // debugPrintWhenRouted: true,
            routeInterceptor: (data) {
              // data.log();
            },
          );
          await tester.pumpWidget(widget);
          expect(find.text('/signIn'), findsOneWidget);
          _navigator.to('/');
          await tester.pumpAndSettle();
          expect(find.byType(Center), findsOneWidget);
          expect(find.byType(Container), findsOneWidget);
          expect(find.text('/books/1'), findsOneWidget);
          //
          _navigator.to('/books/2');
          await tester.pumpAndSettle();
          expect(find.byType(Center), findsOneWidget);
          expect(find.byType(Container), findsOneWidget);
          expect(find.text('/books/2'), findsOneWidget);
          //
          _navigator.to('/books');
          await tester.pumpAndSettle();
          expect(find.byType(Center), findsOneWidget);
          expect(find.byType(Container), findsOneWidget);
          expect(find.text('/books/1'), findsOneWidget);
        },
      );
      testWidgets(
        'Redirect to unknown route',
        (tester) async {
          final Map<String, Widget Function(RouteData)> routes = {
            '/': (data) => Text('Home'),
            '/page1': (data) => RouteWidget(
                  builder: (_) {
                    return Center(child: _);
                  },
                  routes: {
                    '/': (data) => data.redirectTo('/page3'),
                    '/page11': (data) => data.redirectTo('/page1/page11'),
                    '/page12': (data) => data.redirectTo('/page1/page13'),
                  },
                ),
          };

          final widget = _TopWidget(
            routers: routes,
            routeInterceptor: (data) {
              data.log();
            },
            unknownRoute: (data) {
              return Text('404 ${data.location}');
            },
          );
          await tester.pumpWidget(widget);
          expect(find.text('Home'), findsOneWidget);
          //
          _navigator.to('/page1');
          await tester.pumpAndSettle();
          expect(find.text('404 /page3'), findsOneWidget);
          expect(find.byType(Center), findsNothing);
          //
          _navigator.to('/page1/page11');
          await tester.pumpAndSettle();
          expect(
            find.text('404 Infinite redirect loop: (/page1/page11)'),
            findsOneWidget,
          );
          expect(find.byType(Center), findsOneWidget);

          _navigator.to('/page1/page12');
          await tester.pumpAndSettle();
          expect(
            find.text('404 /page1/page13'),
            findsOneWidget,
          );
          expect(find.byType(Center), findsOneWidget);
        },
      );

      // testWidgets(
      //   'WHEN redirect unknown route',
      //   (tester) async {
      //     final Map<String, Widget Function(RouteData)> routes = {
      //       '/': (data) => data.redirectTo('/home'),
      //       '/home': (data) => Text('Home'),
      //       '/page1': (data) => Text('page1'),
      //       '/page2': (data) => RouteWidget(
      //             builder: (_) => Center(child: _),
      //             routes: {
      //               '/': (data) => data.redirectTo('/page2/page21/404'),
      //               '/page1': (data) => data.redirectTo('/page3'),
      //             },
      //           ),
      //     };
      //     String location = '';
      //     final widget = _TopWidget(
      //       initialRoute: '/signIn',
      //       routers: routes,
      //       unknownRoute: (data) {
      //         location = data.location;
      //         return data.redirectTo('/');
      //       },
      //       routeInterceptor: (data) {
      //         data.log();
      //       },
      //     );
      //     await tester.pumpWidget(widget);
      //     expect(find.text('Home'), findsOneWidget);
      //     expect(location, '/signIn');
      //     //
      //     _navigator.to('/page1');
      //     await tester.pumpAndSettle();
      //     expect(find.text('page1'), findsOneWidget);
      //     _navigator.to('/404');
      //     await tester.pumpAndSettle();
      //     expect(find.text('Home'), findsOneWidget);
      //     expect(location, '/404');
      //     //
      //     _navigator.to('/page2/404');
      //     await tester.pumpAndSettle();
      //     expect(find.text('Home'), findsOneWidget);
      //     expect(location, '/page2/404');
      //     expect(find.byType(Center), findsOneWidget);
      //   },
      // );
    },
  );

  testWidgets(
    'WHEN RouteWidget with "/" only are nested '
    'THEN it works ',
    (tester) async {
      final Map<String, Widget Function(RouteData)> routes = {
        '/': (_) {
          return RouteWidget(
            routes: {
              '/': (_) => RouteWidget(
                    routes: {
                      '/': (_) => RouteWidget(
                            routes: {
                              '/': (_) => Text('/'),
                              '/page1': (_) => Text('/page1'),
                            },
                          ),
                      //shadowed by the above route
                      '/page1': (_) => Text('/page1-bis'),
                      '/page2': (_) => RouteWidget(
                            routes: {
                              '/': (data) => Text('/page2'),
                              '/page22': (data) => Text('/page22'),
                            },
                          ),
                    },
                  ),
            },
          );
        },
      };
      final widget = _TopWidget(
        routers: routes,
        // debugPrintWhenRouted: true,
        routeInterceptor: (data) {},
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      _navigator.to('/page2/');
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      _navigator.to('page22');
      await tester.pumpAndSettle();
      expect(find.text('/page22'), findsOneWidget);
    },
  );

  testWidgets(
    'Test delegateImplyLeadingToParent',
    (tester) async {
      final routes = {
        '/': (data) => Text('/'),
        '/page1': (data) => Scaffold(
              appBar: AppBar(),
              body: Text('/page1'),
            ),
        '/page2': (data) => RouteWidget(
              routes: {
                '/': (_) => Scaffold(
                      appBar: AppBar(),
                      body: Text('/page2'),
                    ),
              },
            ),
        '/page3': (data) => RouteWidget(
              routes: {
                '/': (_) => RouteWidget(
                      routes: {
                        '/': (_) => Scaffold(
                              appBar: AppBar(),
                              body: Text('/page3'),
                            ),
                      },
                    ),
              },
            ),
        '/page4': (data) => RouteWidget(
              routes: {
                '/': (_) => RouteWidget(
                      delegateImplyLeadingToParent: false,
                      routes: {
                        '/': (_) => Scaffold(
                              appBar: AppBar(),
                              body: Text('/page4'),
                            ),
                      },
                    ),
              },
            ),
        '/page5': (data) => RouteWidget(
              routes: {
                '/': (_) => RouteWidget(
                      builder: (_) => _,
                      routes: {
                        '/': (_) => Scaffold(
                              appBar: AppBar(),
                              body: Text('/page5'),
                            ),
                        '/page51': (_) => Scaffold(
                              appBar: AppBar(),
                              body: Text('/page51'),
                            ),
                      },
                    ),
              },
            ),
        '/page6': (data) => RouteWidget(
              builder: (_) {
                return Scaffold(
                  appBar: AppBar(),
                  body: Text('/page6'),
                );
              },
            ),
      };
      final widget = _TopWidget(
        routers: routes,
        // debugPrintWhenRouted: true,
        routeInterceptor: (data) {},
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      //
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      //
      _navigator.to('/page3');
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);

      _navigator.toAndRemoveUntil('/page3');
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      //
      _navigator.to('/page4');
      await tester.pumpAndSettle();
      expect(find.text('/page4'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      //
      _navigator.to('/page5');
      await tester.pumpAndSettle();
      expect(find.text('/page5'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      //
      _navigator.to('/page5/page51');
      await tester.pumpAndSettle();
      expect(find.text('/page51'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      //
      _navigator.to('/page6');
      await tester.pumpAndSettle();
      expect(find.text('/page6'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    },
  );

  testWidgets(
    'Check InjectedNavigator.builder works',
    (tester) async {
      _transitionsBuilder = RM.transitions.rightToLeft(
        duration: Duration(seconds: 1),
      );
      final routes = {
        '/': (data) => Redirect('/page1'),
        '/page1': (data) => RouteWidget(
              routes: {
                '/': (data) => Scaffold(
                      appBar: AppBar(),
                      body: Text('/page1'),
                    ),
              },
            ),
        '/page2': (data) => RouteWidget(
              routes: {
                '/': (data) => Scaffold(
                      appBar: AppBar(),
                      body: Text('/page2'),
                    ),
              },
            ),
      };

      final widget = _TopWidget(
        routers: routes,
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text('title'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Center(
                    key: Key('Center'),
                    child: Builder(
                      builder: (context) {
                        return context.routerOutlet;
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _navigator.to('page1'),
                  child: Text('ToPage1'),
                ),
                ElevatedButton(
                  onPressed: () => _navigator.to('page2'),
                  child: Text('ToPage2'),
                ),
              ],
            ),
          );
        },
      );

      await tester.pumpWidget(widget);

      expect(find.byKey(Key('Center')), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(find.byType(BackButton), findsNothing);
      //
      await tester.tap(find.text('ToPage2'));
      await tester.pump();
      await tester.pump(500.milliseconds);
      expect(find.byKey(Key('Center')), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(
        find.byType(BackButton),
        findsNWidgets(2),
      ); // should be findOnWidget

      await tester.pumpAndSettle();
      expect(find.byKey(Key('Center')), findsOneWidget);
      expect(find.text('/page1'), findsNothing);
      expect(find.text('/page2'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(find.byType(BackButton), findsOneWidget);
      //
      _navigator.back();
      await tester.pump();
      await tester.pump(500.milliseconds);
      expect(find.byType(BackButton), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(Key('Center')), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsNothing);
    },
  );

  testWidgets(
    'Check that back is reactive',
    (tester) async {
      final routes = {
        '/': (data) => Redirect('/page1/1'),
        '/page1/:id': (data) => RouteWidget(
              delegateImplyLeadingToParent: false,
              builder: (_) => Scaffold(
                appBar: AppBar(
                  key: Key('AppBar/page1'),
                ),
                body: _,
              ),
              routes: {
                '/': (data) => Scaffold(
                      appBar: AppBar(
                        key: Key('AppBar/page1/'),
                      ),
                      body: Builder(
                        builder: (context) {
                          return Text('/page1/${data.pathParams['id']}');
                        },
                      ),
                    ),
                '/page2/:id': (data) => RouteWidget(
                      delegateImplyLeadingToParent: false,
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          key: Key('AppBar/page2'),
                        ),
                        body: _,
                      ),
                      routes: {
                        '/': (data) => Scaffold(
                              appBar: AppBar(
                                key: Key('AppBar/page2/'),
                              ),
                              body: Text('/page2/${data.pathParams['id']}'),
                            ),
                      },
                    ),
              },
            ),
      };

      final widget = _TopWidget(
        routers: routes,
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              leading: () {
                if (_navigator.canPop) {
                  return BackButton(
                    key: Key('BackButton'),
                    onPressed: () => _navigator.back(),
                  );
                }
                return Container();
              }(),
              title: Text('Title: ${_navigator.routeData.location}'),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) => context.routerOutlet,
                  ),
                ),
              ],
            ),
          );
        },
      );

      //
      final backPage1 = find.descendant(
        of: find.byKey(Key('AppBar/page1')),
        matching: find.byType(BackButton),
      );
      final backPage1Home = find.descendant(
        of: find.byKey(Key('AppBar/page1/')),
        matching: find.byType(BackButton),
      );
      final backPage2 = find.descendant(
        of: find.byKey(Key('AppBar/page2')),
        matching: find.byType(BackButton),
      );

      final backPage2Home = find.descendant(
        of: find.byKey(Key('AppBar/page2/')),
        matching: find.byType(BackButton),
      );
      await tester.pumpWidget(widget);
      expect(find.text('/page1/1'), findsOneWidget);
      expect(find.text('Title: /page1/1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(backPage1, findsNothing);
      expect(backPage1Home, findsNothing);
      expect(backPage2, findsNothing);
      expect(backPage2Home, findsNothing);
      //
      _navigator.to('/page1/2');
      await tester.pumpAndSettle();
      expect(find.text('/page1/2'), findsOneWidget);
      expect(find.text('Title: /page1/2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(2));
      expect(backPage1, findsOneWidget);
      expect(backPage1Home, findsNothing);
      expect(backPage2, findsNothing);
      expect(backPage2Home, findsNothing);
      //
      await tester.tap(find.byKey(Key('BackButton')));
      await tester.pumpAndSettle();
      expect(find.text('/page1/1'), findsOneWidget);
      expect(find.text('Title: /page1/1'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(0));
      expect(backPage1, findsNothing);
      expect(backPage1Home, findsNothing);
      expect(backPage2, findsNothing);
      expect(backPage2Home, findsNothing);

      _navigator.to('/page1/2');
      _navigator.to('/page1/2/page2/1');
      _navigator.to('/page1/2/page2/2');
      _navigator.to('/page1/3');
      _navigator.to('/page1/3/page2/1');
      await tester.pumpAndSettle();
      expect(find.text('/page2/1'), findsOneWidget);
      expect(find.text('Title: /page1/3/page2/1'), findsOneWidget);
      _navigator.to('/page1/3/page2/2');
      await tester.pumpAndSettle();
      expect(find.text('/page2/2'), findsOneWidget);
      expect(find.text('Title: /page1/3/page2/2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(3));
      expect(find.byKey(Key('BackButton')), findsOneWidget);
      expect(backPage1, findsOneWidget);
      expect(backPage2, findsOneWidget);
      //
      await tester.tap(find.byKey(Key('BackButton')));
      await tester.pumpAndSettle();
      expect(find.text('/page2/1'), findsOneWidget);
      expect(find.text('Title: /page1/3/page2/1'), findsOneWidget);
      await tester.tap(find.byKey(Key('BackButton')));
      await tester.pumpAndSettle();
      expect(find.text('/page1/3'), findsOneWidget);
      expect(find.text('Title: /page1/3'), findsOneWidget);
      await tester.tap(find.byKey(Key('BackButton')));
      await tester.pumpAndSettle();
      expect(find.text('/page2/2'), findsOneWidget);
      expect(find.text('Title: /page1/2/page2/2'), findsOneWidget);
      await tester.tap(find.byKey(Key('BackButton')));
      await tester.pumpAndSettle();
      expect(find.text('/page2/1'), findsOneWidget);
      expect(find.text('Title: /page1/2/page2/1'), findsOneWidget);
      await tester.tap(find.byKey(Key('BackButton')));
      await tester.pumpAndSettle();
      expect(find.text('/page1/2'), findsOneWidget);
      expect(find.text('Title: /page1/2'), findsOneWidget);
      await tester.tap(find.byKey(Key('BackButton')));
      await tester.pumpAndSettle();
      expect(find.text('/page1/1'), findsOneWidget);
      expect(find.text('Title: /page1/1'), findsOneWidget);
      expect(find.byKey(Key('BackButton')), findsNothing);
      //
      _navigator.to('/page1/2');
      _navigator.to('/page1/2/page2/1');
      _navigator.to('/page1/2/page2/2');
      _navigator.to('/page1/3');
      _navigator.to('/page1/3/page2/1');
      await tester.pumpAndSettle();
      expect(find.text('/page2/1'), findsOneWidget);
      _navigator.to('/page1/3/page2/2');
      await tester.pumpAndSettle();
      expect(find.text('/page2/2'), findsOneWidget);
      expect(find.text('Title: /page1/3/page2/2'), findsOneWidget);
      expect(find.byType(BackButton), findsNWidgets(3));
      expect(find.byKey(Key('BackButton')), findsOneWidget);
      expect(backPage1, findsOneWidget);
      expect(backPage2, findsOneWidget);
      //
      await tester.tap(backPage1);
      await tester.pumpAndSettle();
      expect(find.text('/page2/2'), findsOneWidget);
      expect(find.text('Title: /page1/2/page2/2'), findsOneWidget);
      await tester.tap(backPage1);
      await tester.pumpAndSettle();
      expect(find.text('/page1/1'), findsOneWidget);
      expect(find.text('Title: /page1/1'), findsOneWidget);
      expect(find.byKey(Key('BackButton')), findsNothing);
    },
  );

  testWidgets(
    'Check forceBack',
    (tester) async {
      final routes = {
        '/': (data) => Text('/'),
        '/page1': (data) => Text('/page1'),
      };
      final widget = _TopWidget(
        builder: (_) => _,
        routers: routes,
        // debugPrintWhenRouted: true,
        onBack: (data) {
          if (data == null) {
            return false;
          }
          if (data.location == '/page1') {
            RM.navigate.toDialog(
              AlertDialog(
                content: Text('Alert'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      _navigator.forceBack();
                    },
                    child: Text('Yes'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _navigator.back();
                    },
                    child: Text('No'),
                  ),
                ],
              ),
              postponeToNextFrame: true,
            );
            return false;
          }
        },
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      //
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      //
      _navigator.forceBack();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );
  testWidgets(
    'Test toDeeply',
    (tester) async {
      final routes = {
        '/': (data) => Text('/'),
        '/page1': (data) => Text('/page1'),
        '/page1/page11': (data) => Text('/page11'),
        '/page1/page11/page111': (data) => RouteWidget(
              routes: {
                '/': (data) => Text('/page111'),
                '/page1111': (data) => Text('/page1111'),
              },
            ),
      };
      final widget = _TopWidget(
        routers: routes,
        // debugPrintWhenRouted: true,
        initialRoute: '/page1/page11/page111/page1111',
      );
      await tester.pumpWidget(widget);
      expect(find.text('/page1111'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page111'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      //
      _navigator.to('/page1/page11/page111/page1111');
      await tester.pumpAndSettle();
      expect(find.text('/page1111'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      //
      _navigator.to('/page1/page11/page111/page1111');
      await tester.pumpAndSettle();
      _navigator.toDeeply('/page1/page11/page111/page1111');
      await tester.pumpAndSettle();
      expect(find.text('/page1111'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page111'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'Test setRouteStack for subRoutes',
    (tester) async {
      final routes = {
        '/': (data) => Text('/'),
        '/page1': (data) => RouteWidget(
              routes: {
                '/': (data) => Text('/page1'),
                '/page11': (data) => RouteWidget(
                      routes: {
                        '/': (data) => Text('/page11'),
                        '/page111': (data) => Text('/page111'),
                      },
                    ),
                '/page12': (data) => Text('/page12'),
              },
            ),
        '/page2': (data) => RouteWidget(
              routes: {
                '/': (data) => Text('/page2'),
                '/page21': (data) => Text('/page21'),
                '/page22': (data) => Text('/page22'),
              },
            ),
        '/page3': (data) => Text('/page3'),
      };
      final widget = _TopWidget(
        routers: routes,
        // debugPrintWhenRouted: true,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      _navigator.setRouteStack((pages) {
        return pages.to('/page1');
      });
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      //
      _navigator.setRouteStack(
        (pages) {
          return pages.to('page11');
        },
        subRouteName: '/page1',
      );
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      //
      _navigator.setRouteStack(
        (pages) {
          return pages.to('page111');
        },
        subRouteName: '/page1/page11',
      );
      await tester.pumpAndSettle();
      expect(find.text('/page111'), findsOneWidget);
      //
      _navigator.setRouteStack(
        (pages) {
          return pages.to('page12');
        },
        subRouteName: '/page1',
      );
      await tester.pumpAndSettle();
      expect(find.text('/page12'), findsOneWidget);
      //
      _navigator.setRouteStack(
        (pages) {
          return pages.to('page2');
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      _navigator.setRouteStack(
        (pages) {
          return pages.toReplacement('page3');
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page12'), findsOneWidget);
      //
      String? isCompleted = '';
      _navigator.to('page2').then((value) => isCompleted = value as String?);
      await tester.pumpAndSettle();
      _navigator.setRouteStack(
        (pages) {
          return pages.toAndRemoveUntil('page3', '/');
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('/page3'), findsOneWidget);
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(isCompleted, isNull);
    },
  );

  testWidgets(
    'Test animation and secondaryAnimation',
    (tester) async {
      Animation<double>? animation;
      Animation<double>? secondaryAnimation;
      final routes = {
        '/': (data) => Builder(
              builder: (context) {
                animation = context.animation;
                secondaryAnimation = context.secondaryAnimation;
                return Text('/');
              },
            ),
        '/page1': (data) => Builder(
              builder: (context) {
                animation = context.animation;
                secondaryAnimation = context.secondaryAnimation;
                return Text('/page1');
              },
            ),
        '/page2': (data) => RouteWidget(
              routes: {
                '/': (data) {
                  return Builder(
                    builder: (context) {
                      animation = context.animation;
                      secondaryAnimation = context.secondaryAnimation;
                      return Text('/page2');
                    },
                  );
                },
              },
            ),
      };
      final widget = _TopWidget(
        transitionDuration: 1.seconds,
        routers: routes,
        // debugPrintWhenRouted: true,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(animation, isNotNull);
      expect(secondaryAnimation, isNotNull);
      //
      animation = null;
      secondaryAnimation = null;
      _navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      expect(animation, isNotNull);
      expect(secondaryAnimation, isNotNull);
      //
      animation = null;
      secondaryAnimation = null;
      _navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      expect(animation, isNotNull);
      expect(secondaryAnimation, isNotNull);
      //
      _navigator.toAndRemoveUntil('/');
      await tester.pumpAndSettle();
      _navigator.to('/page1');
      await tester.pump();
      await tester.pump(500.milliseconds);
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(animation!.value, 0.5);
      expect(animation!.status, AnimationStatus.forward);
      await tester.pumpAndSettle();
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      expect(animation!.status, AnimationStatus.completed);
      _navigator.back();
      await tester.pump();
      await tester.pump(500.milliseconds);
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(animation!.value, 0.5);
      expect(animation!.status, AnimationStatus.reverse);
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsNothing);
      expect(animation!.status, AnimationStatus.dismissed);
      //
      _navigator.to(
        '/page1',
        transitionsBuilder: RM.transitions.none(duration: 2.seconds),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('/page1'), findsOneWidget);
      await tester.pump(1000.milliseconds);
      // expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      expect(animation!.value, 0.5);
      expect(animation!.status, AnimationStatus.forward);
      await tester.pumpAndSettle();
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      expect(animation!.status, AnimationStatus.completed);
      //
      _navigator.back();
      await tester.pump();
      await tester.pump(1000.milliseconds);
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(animation!.value, 0.5);
      expect(animation!.status, AnimationStatus.reverse);
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsNothing);
      expect(animation!.status, AnimationStatus.dismissed);
      //
      _navigator.to('/page1');
      await tester.pump();
      await tester.pump(500.milliseconds);
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      expect(animation!.value, 0.5);
      expect(animation!.status, AnimationStatus.forward);
      await tester.pumpAndSettle();
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      expect(animation!.status, AnimationStatus.completed);
    },
  );

  testWidgets(
    'test context.routeData',
    (tester) async {
      String location = '';
      String location1 = '';
      String location2 = '';
      String location3 = '';
      final routes = {
        '/': (data) => Text('/'),
        '/page1': (data) => Text('/page1'),
        '/page1/page11': (data) {
          return RouteWidget(
            builder: (routerOutlet) {
              return Builder(
                builder: (context) {
                  assert(context.routerOutlet == routerOutlet);
                  location1 = context.routeData.location;
                  location2 = _navigator.routeData.location;
                  return routerOutlet;
                },
              );
            },
            routes: {
              '/': (data) => Text('/page11'),
              '/page12': (data) => Text('/page12'),
            },
          );
        },
        '/page1/page11/page111': (data) => Text('/page111'),
      };
      final widget = _TopWidget(
        routers: routes,
        builder: (routerOutlet) {
          return Builder(
            builder: (context) {
              assert(context.routerOutlet == routerOutlet);
              location = context.routeData.location;
              location3 = _navigator.routeData.location;
              return routerOutlet;
            },
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(location, '/');
      expect(location3, location);
      _navigator.to('/page1/page11/page111');
      await tester.pumpAndSettle();
      expect(find.text('/page111'), findsOneWidget);
      expect(location, '/page1/page11/page111');
      expect(location3, location);
      expect(location1, '');
      expect(location2, '');
      _navigator.to('/page1/page11');
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      expect(location, '/page1/page11');
      expect(location3, location);
      expect(location1, '/page1/page11');
      expect(location2, location1);
      location1 = '';
      _navigator.to('/page1/page11/page12');
      await tester.pumpAndSettle();
      expect(find.text('/page12'), findsOneWidget);
      expect(location, '/page1/page11/page12');
      expect(location3, location);
      expect(location1, '/page1/page11/page12');
      expect(location2, '/page1/page11/page12');
      //
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      expect(location, '/page1/page11');
      expect(location3, '/page1/page11');
      expect(location1, '/page1/page11');
      expect(location2, location1);
    },
  );

  testWidgets(
    'test InjectedNavigator.onNavigate',
    (tester) async {
      final routes = {
        '/': (data) => Text('/'),
        '/page1': (data) => Text('/page1'),
        '/page1/page11': (data) {
          return RouteWidget(
            builder: (routerOutlet) {
              return Builder(
                builder: (context) {
                  return routerOutlet;
                },
              );
            },
            routes: {
              '/': (data) => Text('/page11'),
              '/page12': (data) => Text('/page12'),
            },
          );
        },
      };

      String to = '';
      final widget = _TopWidget(
        routers: routes,
        builder: (routerOutlet) {
          return Builder(
            builder: (context) {
              return routerOutlet;
            },
          );
        },
        routeInterceptor: (data) {
          final location = data.location;
          if (to == '/') {
            return data.redirectTo('/');
          }
          if (to == '/page1' && location != '/page1') {
            return data.redirectTo('/page1');
          }
          if (to == '/page1/page11' && location != '/page1/page11') {
            return data.redirectTo('/page1/page11');
          }
          if (to == '/page1/page11/page12' &&
              location != '/page1/page11/page12') {
            return data.redirectTo('/page1/page11/page12');
          }
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      _navigator.onNavigate();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      to = '/page1';
      _navigator.onNavigate();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      to = '/page1/page11';
      _navigator.onNavigate();
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      to = '/page1/page11/page12';
      _navigator.onNavigate();
      await tester.pumpAndSettle();
      expect(find.text('/page12'), findsOneWidget);
      //
      _navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page12'), findsOneWidget);
    },
  );

  testWidgets(
    'Test unKnownRoute',
    (tester) async {
      final datum = ['1', '2'];
      final Map<String, Widget Function(RouteData)> routes = {
        '/': (data) => Text('/'),
        '/page1/:id': (data) {
          try {
            final index = int.parse(data.pathParams['id']!);
            final d = datum[index];
            return Text('/page1-$d');
          } catch (e) {
            return data.unKnownRoute;
          }
        },
        '/page2/:id': (data) => Builder(
              builder: (context) {
                {
                  try {
                    final index = int.parse(data.pathParams['id']!);
                    final d = datum[index];
                    return Text('/page2-$d');
                  } catch (e) {
                    return context.routeData.unKnownRoute;
                  }
                }
              },
            ),
      };

      final widget = _TopWidget(
        routers: routes,
      );

      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      //
      _navigator.to('/page1/1');
      await tester.pumpAndSettle();
      expect(find.text('/page1-2'), findsOneWidget);
      //
      _navigator.to('/page1/2');
      await tester.pumpAndSettle();
      expect(find.text('404 /page1/2'), findsOneWidget);
      //
      _navigator.to('/page1/NaN');
      await tester.pumpAndSettle();
      expect(find.text('404 /page1/NaN'), findsOneWidget);
      //
      _navigator.to('/page2/2');
      await tester.pumpAndSettle();
      expect(find.text('404 /page2/2'), findsOneWidget);
      //
      _navigator.to('/page2/NaN');
      await tester.pumpAndSettle();
      expect(find.text('404 /page2/NaN'), findsOneWidget);
    },
  );

  testWidgets(
    'Text Mocking InjectedNavigator',
    (tester) async {
      final navigator = RM.injectNavigator(
        routes: {'/': (data) => Text('/'), '/page1': (date) => Text('Page1')},
      );

      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      final mock = NavigatorMock();
      navigator.injectMock(mock);
      //
      navigator.canPop;
      expect(mock.message, 'canPop');
      navigator.pageStack;
      expect(mock.message, 'pageStack');
      try {
        navigator.routeData;
        expect(mock.message, 'routeData');
      } catch (e) {
        expect(e is UnimplementedError, true);
      }
      navigator.back();
      expect(mock.message, 'back');
      navigator.backUntil('untilRouteName');
      expect(mock.message, 'backUntil');
      navigator.forceBack();
      expect(mock.message, 'forceBack');
      navigator.setRouteStack((pages) => pages);
      expect(mock.message, 'setRouteStack');
      navigator.to('routeName');
      expect(mock.message, 'to');
      navigator.toAndRemoveUntil('routeName');
      expect(mock.message, 'toAndRemoveUntil');
      navigator.toDeeply('routeName');
      expect(mock.message, 'toDeeply');
      navigator.toPageless(Text(''));
      expect(mock.message, 'toPageless');
      navigator.toReplacement('routeName');
      expect(mock.message, 'toReplacement');
    },
  );
  testWidgets(
    'Test InjectedNavigator.toReplacement for nested routes',
    (tester) async {
      final navigator = RM.injectNavigator(
        routes: {
          '/': (data) => Text('/'),
          '/page1': (_) => RouteWidget(
                routes: {
                  '/': (date) => Text('Page1'),
                  '/page11': (data) => RouteWidget(
                        routes: {
                          '/': (data) => Text('Page11'),
                          '/page111': (data) => Text('Page111'),
                        },
                      ),
                },
              ),
          '/page2': (data) => Text('Page2'),
        },
      );

      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      navigator.toReplacement('/page2');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      //
      navigator.toDeeply('/page1/page11/page111');
      await tester.pumpAndSettle();
      expect(find.text('Page111'), findsOneWidget);
      //
      navigator.toReplacement('/page2');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page11'), findsOneWidget);
      //
      navigator.toReplacement('/page2');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsOneWidget);
      //
      navigator.toReplacement('/page2');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'Test InjectedNavigator.toAndRemoveUntil for nested routes',
    (tester) async {
      final navigator = RM.injectNavigator(
        routes: {
          '/': (data) => Text('/'),
          '/page1': (_) => RouteWidget(
                routes: {
                  '/': (date) => Text('Page1'),
                  '/page11': (data) => RouteWidget(
                        routes: {
                          '/': (data) => Text('Page11'),
                          '/page111': (data) => Text('Page111'),
                        },
                      ),
                },
              ),
          '/page2': (data) => Text('Page2'),
        },
      );

      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      navigator.toAndRemoveUntil('/page2');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      //
      navigator.toDeeply('/page1/page11/page111');
      await tester.pumpAndSettle();
      expect(find.text('Page111'), findsOneWidget);
      //
      navigator.toAndRemoveUntil('/page2', untilRouteName: '/page1/page11/');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page11'), findsOneWidget);
      //
      navigator.toAndRemoveUntil('/page2', untilRouteName: '/page1');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsOneWidget);
      //
      navigator.toAndRemoveUntil('/page2', untilRouteName: '/');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'Test InjectedNavigator.navigator for nested routes',
    (tester) async {
      final navigator = RM.injectNavigator(
        initialLocation: '/page1/page11/page111',
        routes: {
          '/': (data) => Text('/'),
          '/page1': (_) => RouteWidget(
                routes: {
                  '/': (date) => Text('Page1'),
                  '/page11': (data) => RouteWidget(
                        routes: {
                          '/': (data) => Text('Page11'),
                          '/page111': (data) => Text('Page111'),
                        },
                      ),
                },
              ),
        },
      );

      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('Page111'), findsOneWidget);
      //
      navigator.removePage('/');
      await tester.pump();
      expect(find.text('Page111'), findsOneWidget);
      //
      navigator.removePage('/page1');
      await tester.pump();
      expect(find.text('Page111'), findsOneWidget);
      //

      navigator.removePage('/page1/page11');
      await tester.pump();
      expect(find.text('Page111'), findsOneWidget);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('Page111'), findsOneWidget);
      //
      navigator.removePage('/page1/page11/page111');
      await tester.pump();
      expect(find.text('Page111'), findsOneWidget);
      //
      String futureResult = '';
      navigator.to('/page1').then((value) => futureResult = value as String);
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsOneWidget);
      navigator.to('/page1/page11');
      await tester.pumpAndSettle();
      expect(find.text('Page11'), findsOneWidget);
      //
      navigator.removePage<String>('/page1', 'Return Result');
      await tester.pump();
      expect(find.text('Page11'), findsOneWidget);
      expect(futureResult, 'Return Result');
    },
  );

  testWidgets(
    'Fix bug two pages have the same key',
    (tester) async {
      final navigator = RM.injectNavigator(
        routes: {
          '/': (data) => Text('/'),
          '/page1': (_) => const Text('Page1'),
          '/page2': (_) => const Text('Page2'),
        },
      );

      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      expect(navigator.pageStack.length, 1);
      navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsOneWidget);
      expect(navigator.pageStack.length, 2);
      //
      navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      expect(navigator.pageStack.length, 3);
      //
      navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('Page1'), findsOneWidget);
      expect(navigator.pageStack.length, 4);
      //
      navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      expect(navigator.pageStack.length, 5);
      expect(navigator.pageStack.map((e) => e.name).toString(),
          '(/, /page1, /page2, /page1, /page2)');
      navigator.removePage('/page1');
      await tester.pump();
      expect(find.text('Page2'), findsOneWidget);
      expect(navigator.pageStack.map((e) => e.name).toString(),
          '(/, /page1, /page2, /page2)');
      navigator.setRouteStack((pages) {
        pages.removeAt(1);
        pages.removeAt(1);
        return pages;
      });
      await tester.pump();
      expect(find.text('Page2'), findsOneWidget);
      expect(navigator.pageStack.map((e) => e.name).toString(), '(/, /page2)');
      //
      navigator.to('/page2');
      await tester.pumpAndSettle();
      expect(find.text('Page2'), findsOneWidget);
      expect(navigator.pageStack.map((e) => e.name).toString(), '(/, /page2)');
    },
  );

  group(
    'unknown routes',
    () {
      testWidgets(
        'Check different unknown route scenarios',
        (tester) async {
          final navigator = RM.injectNavigator(
            initialLocation: '/page1/page2/page22/404',
            unknownRoute: (data) => Text('404'),
            routes: {
              '/': (data) => Text('/'),
              '/page1': (data) => data.redirectTo('/404'),
              '/page1/page11': (data) => Text('Page11'),
              '/page2': (data) => RouteWidget(
                    routes: {
                      '/': (data) => data.redirectTo('/page21'),
                      '/page21': (data) => data.redirectTo('/404'),
                      '/page22': (data) {
                        return RouteWidget(
                          routes: {
                            '/': (data) => Text('Page22'),
                            '/page23': (data) => Text('Page23'),
                          },
                        );
                      },
                    },
                  ),
              '/page3': (data) => data.redirectTo('/page1/page11'),
            },
          );

          final widget = MaterialApp.router(
            routeInformationParser: navigator.routeInformationParser,
            routerDelegate: navigator.routerDelegate,
          );
          await tester.pumpWidget(widget);
          expect(find.text('404'), findsOneWidget);
          navigator.to('/404');
          await tester.pumpAndSettle();
          expect(find.text('404'), findsOneWidget);
          //
          navigator.to('/page1');
          await tester.pumpAndSettle();
          expect(find.text('404'), findsOneWidget);
          //
          navigator.to('/page1/page11');
          await tester.pumpAndSettle();
          expect(find.text('Page11'), findsOneWidget);
          //
          navigator.to('/page1/page11/404');
          await tester.pumpAndSettle();
          expect(find.text('404'), findsOneWidget);
          //
          navigator.to('/page2');
          await tester.pumpAndSettle();
          expect(find.text('404'), findsOneWidget);
          //
          navigator.to('/page2/page22/404');
          await tester.pumpAndSettle();
          expect(find.text('404'), findsOneWidget);
          //
          navigator.to('/page2/page22/page23/404');
          await tester.pumpAndSettle();
          expect(find.text('404'), findsOneWidget);

          navigator.to('/page3/404');
          await tester.pumpAndSettle();
          expect(find.text('404'), findsOneWidget);
        },
      );
      testWidgets(
        'Check ignore unknown route scenarios',
        (tester) async {
          final navigator = RM.injectNavigator(
            initialLocation: '/page1/page2/page22/404',
            ignoreUnknownRoutes: true,
            unknownRoute: (data) => Text('404'),
            routes: {
              '/': (data) => Text('/'),
              '/page1': (data) => data.redirectTo('/404'),
              '/page1/page11': (data) => Text('Page11'),
              '/page2': (data) => RouteWidget(
                    routes: {
                      '/': (data) => data.redirectTo('/page21'),
                      '/page21': (data) => data.redirectTo('/404'),
                      '/page22': (data) => RouteWidget(
                            routes: {
                              '/': (data) => Text('Page22'),
                              '/page23': (data) => Text('Page23'),
                            },
                          ),
                    },
                  ),
            },
          );

          final widget = MaterialApp.router(
            routeInformationParser: navigator.routeInformationParser,
            routerDelegate: navigator.routerDelegate,
          );
          await tester.pumpWidget(widget);
          expect(find.text('404'), findsOneWidget);
          //
          navigator.to('/page1/page11');
          await tester.pumpAndSettle();
          expect(find.text('Page11'), findsOneWidget);
          //
          navigator.to('/page1');
          await tester.pumpAndSettle();
          expect(find.text('Page11'), findsOneWidget);
          //
          navigator.to('/page1/page11/404');
          await tester.pumpAndSettle();
          expect(find.text('Page11'), findsOneWidget);
          //
          navigator.to('/page2');
          await tester.pumpAndSettle();
          expect(find.text('Page11'), findsOneWidget);
          //
          navigator.to('/page2/page22/404');
          await tester.pumpAndSettle();
          expect(find.text('Page11'), findsOneWidget);
          //
          navigator.to('/page2/page22/page23/404');
          await tester.pumpAndSettle();
          expect(find.text('Page11'), findsOneWidget);
        },
      );
    },
  );

  testWidgets(
    'WHEN '
    ' THEN ',
    (tester) async {
      final navigator = RM.injectNavigator(
        routes: {
          '/': (data) => Text('/'),
          '/page1': (data) => Text('/page1'),
        },
      );

      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      navigator.to(
        '/page1',
        builder: (route) {
          return Center(
            child: route,
          );
        },
      );
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    },
  );

  testWidgets(
    'test deepLinkTest'
    'THEN',
    (tester) async {
      final navigator = RM.injectNavigator(
        // debugPrintWhenRouted: true,
        routes: {
          '/': (data) => Text('/'),
          '/page1': (data) => Text('/page1'),
          '/page1/page11': (data) => Text('/page11'),
        },
      );
      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      navigator.deepLinkTest('/page1/page11');
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      // expect(find.text('/page1'), findsOneWidget);
      // As the routeStack is not empty the skipHome is true. page1 is not rendred
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'Test Navigator2 with TopStatelessWidget',
    (tester) async {
      final navigator = RM.injectNavigator(
        // debugPrintWhenRouted: true,
        routes: {
          '/': (data) => Text('/'),
          '/page1': (data) => Text('/page1'),
        },
      );
      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      bool shouldThrow = true;
      await tester.pumpWidget(
        TopAppWidget(
          ensureInitialization: () => [
            Future.delayed(
              1.seconds,
              () => shouldThrow ? throw Exception('error') : 1,
            )
          ],
          onWaiting: () => Scaffold(
            body: Text('Waiting...'),
          ),
          onError: (err, refresh) => Scaffold(
            body: ElevatedButton(
              child: Text('Error'),
              onPressed: refresh,
            ),
          ),
          builder: (context) {
            return widget;
          },
        ),
      );
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(1.seconds);
      expect(find.text('Error'), findsOneWidget);
      shouldThrow = false;
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      //
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(1.seconds);
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'Test OnNavigateBackScope',
    (tester) async {
      bool shouldPopPage1 = false;
      bool shouldPopPage11 = false;
      final navigator = RM.injectNavigator(
        routes: {
          '/': (data) => Text('/'),
          '/page1': (data) => OnNavigateBackScope(
                onNavigateBack: () {
                  return shouldPopPage1;
                },
                child: Text('/page1'),
              ),
          '/page1/page11': (data) => OnNavigateBackScope(
                onNavigateBack: () {
                  return shouldPopPage11;
                },
                child: Text('/page11'),
              ),
        },
      );
      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      navigator.toDeeply('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      //
      shouldPopPage1 = true;
      navigator.toDeeply('/page1/page11');
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      //
      shouldPopPage11 = true;
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      //
      shouldPopPage1 = false;
      navigator.toDeeply('/page1/page11');
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      navigator.forceBack();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );
  testWidgets(
    'WHEN'
    'THEN',
    (tester) async {
      final navigator = RM.injectNavigator(
        // debugPrintWhenRouted: true,

        routes: {
          '/': (data) => Text('/'),
          '/page1': (data) => RouteWidget(
                routes: {
                  '/': (data) => RouteWidget(
                        routes: {
                          '/': (data) {
                            return Text('/page1');
                          },
                          '/page11': (data) => Text('/page11'),
                        },
                      ),
                  '/page111': (data) => Text('/page111'),
                },
              ),
        },
      );
      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      navigator.to('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      // navigator.to('/page1/page11');
      // await tester.pumpAndSettle();
      // expect(find.text('/page11'), findsOneWidget);
    },
  );

  testWidgets(
    'Test deep link page transition is prevented',
    (tester) async {
      final provider = SimpleRouteInformationProvider();

      provider.value = const RouteInformation(
        location: '/',
      );
      final navigator = RM.injectNavigator(
        routes: {
          '/': (data) => const Text('/'),
          '/page1': (data) => const Text('/page1'),
          '/page2': (data) => const Text('/page2'),
        },
      );
      final widget = MaterialApp.router(
        routeInformationProvider: provider,
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      provider.value = const RouteInformation(
        location: '/page1',
      );
      await tester.pump();
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      await tester.pump();
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      //
      navigator.to('/page2');
      await tester.pump();
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page2'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsNothing);
      expect(find.text('/page2'), findsOneWidget);
      //
      provider.value = const RouteInformation(
        location: '/',
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page2'), findsNothing);
      //
      navigator.to('/page1');
      await tester.pump();
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page1'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
    },
  );

  testWidgets(
    'Test deep link page transition is prevented for nested routed'
    'THEN',
    (tester) async {
      final provider = SimpleRouteInformationProvider();

      provider.value = const RouteInformation(
        location: '/',
      );
      final navigator = RM.injectNavigator(
        transitionDuration: const Duration(seconds: 20),
        routes: {
          '/': (data) => const Text('/'),
          '/page1': (data) => RouteWidget(
                builder: (_) {
                  return Container(child: _);
                },
                routes: {
                  '/': (data) => const Text('/page1'),
                  '/page11': (data) => RouteWidget(
                        routes: {
                          '/': (data) => const Text('/page11'),
                          '/page111': (data) => const Text('/page111'),
                        },
                      ),
                },
              ),
        },
      );
      final widget = MaterialApp.router(
        routeInformationProvider: provider,
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      provider.value = const RouteInformation(
        location: '/page1',
      );
      await tester.pump();
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      await tester.pump();
      expect(find.text('/'), findsNothing);
      expect(find.text('/page1'), findsOneWidget);
      //
      navigator.to('/page1/page11');
      await tester.pump();
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page11'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('/page1'), findsOneWidget);
      expect(find.text('/page11'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsNothing);
      expect(find.text('/page11'), findsOneWidget);
      //
      provider.value = const RouteInformation(
        location: '/',
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('/'), findsOneWidget);
      expect(find.text('/page11'), findsNothing);
      //
      provider.value = const RouteInformation(
        location: '/page1/page11',
      );
      await tester.pump();
      expect(find.text('/'), findsNothing);
      expect(find.text('/page11'), findsOneWidget);
      await tester.pump();
      expect(find.text('/'), findsNothing);
      expect(find.text('/page11'), findsOneWidget);
      //
      provider.value = const RouteInformation(
        location: '/page1/page11/page111',
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('/page11'), findsNothing);
      expect(find.text('/page111'), findsOneWidget);
      await tester.pump();
      expect(find.text('/page11'), findsNothing);
      expect(find.text('/page111'), findsOneWidget);
      //
      navigator.to('/page1/page11');
      await tester.pump();
      expect(find.text('/page111'), findsOneWidget);
      expect(find.text('/page11'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('/page111'), findsOneWidget);
      expect(find.text('/page11'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('/page111'), findsNothing);
      expect(find.text('/page11'), findsOneWidget);
    },
  );

  testWidgets(
    'BUG when popping form page111, the back button is hidden while transition',
    (tester) async {
      // delegate != null && !activeSubRoutes.contains(delegate) in RoutersObject
      final navigator = RM.injectNavigator(
        routes: {
          '/': (data) => Scaffold(appBar: AppBar(title: Text('/'))),
          '/page1': (data) => RouteWidget(
                routes: {
                  '/': (data) =>
                      Scaffold(appBar: AppBar(title: Text('/page1'))),
                  '/page11': (data) => RouteWidget(
                        routes: {
                          '/': (data) =>
                              Scaffold(appBar: AppBar(title: Text('/page11'))),
                          '/page111': (data) => Text('page111'),
                        },
                      ),
                },
              ),
        },
      );
      final widget = MaterialApp.router(
        routeInformationParser: navigator.routeInformationParser,
        routerDelegate: navigator.routerDelegate,
      );
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      navigator.toDeeply('/page1/page11');
      await tester.pumpAndSettle();
      expect(find.text('/page11'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump();
      await tester.pump(Duration(milliseconds: 200));
      expect(find.byType(BackButton), findsNWidgets(2));
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  // group(
  //   'InjectedNavigator is disposed between tests',
  //   () {
  //     final navigator = RM.injectNavigator(
  //       routes: {
  //         '/': (data) => Text('/'),
  //         '/page1': (data) => Text('/page1'),
  //       },
  //     );

  //     testWidgets(
  //       'test1',
  //       (tester) async {
  //         final widget = MaterialApp.router(
  //           routeInformationParser: navigator.routeInformationParser,
  //           routerDelegate: navigator.routerDelegate,
  //         );
  //         await tester.pumpWidget(widget);
  //         expect(find.text('/'), findsOneWidget);
  //         navigator.to('/page1');
  //         await tester.pumpAndSettle();
  //         expect(find.text('/page1'), findsOneWidget);
  //       },
  //     );
  //     testWidgets(
  //       'the same test1',
  //       (tester) async {
  //         final widget = MaterialApp.router(
  //           routeInformationParser: navigator.routeInformationParser,
  //           routerDelegate: navigator.routerDelegate,
  //         );
  //         await tester.pumpWidget(widget);
  //         expect(find.text('/'), findsOneWidget);
  //         navigator.to('/page1');
  //         await tester.pumpAndSettle();
  //         expect(find.text('/page1'), findsOneWidget);
  //       },
  //     );
  //   },
  // );
}

class _RouteInformationParserTest extends RouteInformationParserImp {
  _RouteInformationParserTest(RouterDelegateImp routerDelegate)
      : super(routerDelegate);
  RouteInformation? info;
  @override
  RouteInformation restoreRouteInformation(PageSettings configuration) {
    info = super.restoreRouteInformation(configuration);
    return info!;
  }
}

class SimpleRouteInformationProvider extends RouteInformationProvider
    with ChangeNotifier {
  SimpleRouteInformationProvider({
    this.onRouterReport,
  });

  void Function(RouteInformation, bool)? onRouterReport;

  @override
  RouteInformation get value => _value;
  late RouteInformation _value;
  set value(RouteInformation newValue) {
    _value = newValue;
    notifyListeners();
  }

  @override
  void routerReportsNewRouteInformation(RouteInformation routeInformation,
      {required RouteInformationReportingType type}) {
    _value = routeInformation;
  }
}

class _MyPage extends Page {
  const _MyPage({
    String? name,
    LocalKey? key,
  }) : super(
          name: name,
          key: key,
        );
  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      builder: (_) => Text('_myPage'),
      settings: this,
    );
  }
}

// class name extends StatelessWidget {
//   const name({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return OnReactive(
//       () => Text('${context.routeData.location}'),
//     );
//   }
// }

class NavigatorMock extends InjectedNavigator {
  String message = '';
  @override
  void back<T extends Object>([T? result]) {
    message = 'back';
  }

  @override
  void backUntil(String untilRouteName) {
    message = 'backUntil';
  }

  @override
  bool get canPop {
    message = 'canPop';
    return true;
  }

  @override
  void deepLinkTest(String url) {
    message = 'deepLinkTest';
  }

  @override
  void forceBack<T extends Object>([T? result]) {
    message = 'forceBack';
  }

  @override
  List<PageSettings> get pageStack {
    message = 'pageStack';
    return [];
  }

  @override
  RouteData get routeData {
    message = 'routeData';
    throw UnimplementedError();
  }

  @override
  void setRouteStack(
      List<PageSettings> Function(List<PageSettings> pages) stack,
      {String? subRouteName}) {
    message = 'setRouteStack';
  }

  @override
  Future<T?> to<T extends Object?>(String routeName,
      {Object? arguments,
      Map<String, String>? queryParams,
      bool fullscreenDialog = false,
      bool maintainState = true,
      Widget Function(Widget route)? builder,
      Widget Function(BuildContext context, Animation<double> animation,
              Animation<double> secondAnimation, Widget child)?
          transitionsBuilder}) async {
    message = 'to';
  }

  @override
  Future<T?> toAndRemoveUntil<T extends Object?>(String newRouteName,
      {String? untilRouteName,
      Object? arguments,
      Map<String, String>? queryParams,
      bool fullscreenDialog = false,
      bool maintainState = true}) async {
    message = 'toAndRemoveUntil';
  }

  @override
  void toDeeply(String routeName,
      {Object? arguments,
      Map<String, String>? queryParams,
      bool fullscreenDialog = false,
      bool maintainState = true}) {
    message = 'toDeeply';
  }

  @override
  Future<T?> toPageless<T extends Object?>(Widget page,
      {String? name,
      bool fullscreenDialog = false,
      bool maintainState = true}) async {
    message = 'toPageless';
  }

  @override
  Future<T?> toReplacement<T extends Object?, TO extends Object?>(
      String routeName,
      {TO? result,
      Object? arguments,
      Map<String, String>? queryParams,
      bool fullscreenDialog = false,
      bool maintainState = true}) async {
    message = 'toReplacement';
  }
}
