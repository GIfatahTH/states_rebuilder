import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

class Route1 extends StatefulWidget {
  final dynamic data;
  Route1(this.data);

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
  Route2(this.data);

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

final app = MaterialApp(
  navigatorKey: RM.navigate.navigatorKey,
  onGenerateRoute: RM.navigate.onGenerateRoute(
    {
      '/': (_) => Text('Home'),
      'Route1': (data) => Route1(data.arguments as String),
      'Route2': (data) => Route2(data.arguments as String),
      'Route3': (_) => Text('Route3'),
    },
  ),
);

void main() {
  testWidgets('Assertion not navigatorKey is not assigned', (tester) async {
    final widget = MaterialApp(
      routes: {
        '/': (_) => Text('Home'),
      },
    );
    await tester.pumpWidget(widget);
    expect(RM.context, null);
    expect(() => RM.navigate.toNamed('/'), throwsAssertionError);
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
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('navigate to named', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed(
      'Route1',
      arguments: 'data',
      fullscreenDialog: true,
      maintainState: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Route1: data'), findsOneWidget);
    //
    RM.navigate.toReplacementNamed(
      'Route2',
      arguments: 'data',
      result: '',
      fullscreenDialog: true,
      maintainState: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('navigate to remove until', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route3', arguments: 'data');
    await tester.pumpAndSettle();
    //
    RM.navigate.toAndRemoveUntil(
      Route2('data'),
      name: 'ROUTE2',
      untilRouteName: '/',
      fullscreenDialog: true,
      maintainState: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    //With route name
    RM.navigate.toAndRemoveUntil(
      Route2('data'),
      name: 'ROUTE2',
      untilRouteName: '/',
    );
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route3', arguments: 'data');
    await tester.pumpAndSettle();
    //
    RM.navigate.toAndRemoveUntil(
      Route1(''),
      untilRouteName: 'ROUTE2',
    );
    await tester.pumpAndSettle();
    expect(find.text('Route1: '), findsOneWidget);
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('navigate to remove all', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route3', arguments: 'data');
    await tester.pumpAndSettle();
    //
    RM.navigate.toAndRemoveUntil(
      Route2('data'),
      name: 'ROUTE2',
      fullscreenDialog: true,
      maintainState: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Route2: data'), findsNothing);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('navigate to named remove  until', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.to(Route1(''), name: 'ROUTE1');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route2', arguments: '');
    await tester.pumpAndSettle();
    //
    RM.navigate.toNamedAndRemoveUntil(
      'Route3',
      arguments: 'data',
      untilRouteName: 'ROUTE1',
      fullscreenDialog: true,
      maintainState: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Route1: '), findsOneWidget);
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('navigate to named remove  all', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route2', arguments: 'data');
    await tester.pumpAndSettle();
    //
    RM.navigate.toNamedAndRemoveUntil(
      'Route3',
      arguments: 'data',
    );
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();

    expect(find.text('Route3'), findsNothing);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('back until', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();

    RM.navigate.toNamed('Route2', arguments: 'data');
    await tester.pumpAndSettle();

    RM.navigate.toNamed('Route3', arguments: 'data');
    await tester.pumpAndSettle();
    expect(find.text('Route3'), findsOneWidget);
    //
    RM.navigate.backUntil('/Route1');
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.text('Route1: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('back and to named', (tester) async {
    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route2', arguments: 'data');
    await tester.pumpAndSettle();
    RM.navigate.toNamed('Route3', arguments: 'data');
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
    RM.navigate.back();
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
      'CASE Widget route', (tester) async {
    RM.navigate.pageRouteBuilder = (Widget nextPage) => PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 2000),
          reverseTransitionDuration: Duration(milliseconds: 2000),
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: RM.transitions.upToBottom(),
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
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets(
      'WHEN RM.navigate.pageRouteBuilder is defined'
      'Route animation uses it'
      'CASE named route', (tester) async {
    //
    //IT will not used because pageRouteBuilder is defined
    RM.navigate.transitionsBuilder = RM.transitions.leftToRight();

    RM.navigate.pageRouteBuilder = (Widget nextPage) => PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 2000),
          reverseTransitionDuration: Duration(milliseconds: 2000),
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: RM.transitions.bottomToUp(),
        );

    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Route1: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);

    //
    RM.navigate.toReplacementNamed('Route2', arguments: 'data', result: '');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);
    expect(find.text('Route2: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets(
      'WHEN RM.navigate.transitionsBuilder is defined'
      'Route animation uses it'
      'CASE Widget route', (tester) async {
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
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets(
      'WHEN RM.navigate.transitionsBuilder is defined'
      'Route animation uses it'
      'CASE named route', (tester) async {
    RM.navigate.transitionsBuilder = RM.transitions.rightToLeft(
      duration: Duration(milliseconds: 2000),
    );

    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Route1: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);

    //
    RM.navigate.toReplacementNamed('Route2', arguments: 'data', result: '');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);
    expect(find.text('Route2: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
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
    final app = MaterialApp(
      navigatorKey: RM.navigate.navigatorKey,
      onGenerateRoute: RM.navigate.onGenerateRoute(
        {
          '/': (_) => Text('Home'),
          'Route1': (data) => Route1(data.arguments as String),
          'Route2': (data) => Route2(data.arguments as String),
          'Route3': (_) => Text('Route3'),
        },
        transitionsBuilder: RM.transitions.rightToLeft(
          duration: Duration(milliseconds: 2000),
        ),
      ),
    );

    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('Route1', arguments: 'data');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Route1: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);

    //
    RM.navigate.toReplacementNamed('Route2', arguments: 'data', result: '');
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route1: data'), findsOneWidget);
    expect(find.text('Route2: data'), findsNothing);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Route2: data'), findsOneWidget);
    //
    RM.navigate.back();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
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
  //   RM.navigate.toNamed('/NAN');
  //   await tester.pumpAndSettle();

  //   expect(find.text('No route defined for /NAN'), findsOneWidget);
  // });

  testWidgets(
      'WHEN undefined name route is given'
      'AND WHEN unknownRoute is defined'
      'THEN it route to custom unknownRoute ', (tester) async {
    final app = MaterialApp(
      navigatorKey: RM.navigate.navigatorKey,
      onGenerateRoute: RM.navigate.onGenerateRoute({
        '/': (_) => Text('Home'),
        'Route1': (param) => Route1(param as String),
        'Route2': (param) => Route2(param as String),
        'Route3': (_) => Text('Route3'),
      }, unknownRoute: (_) => Text('Unknown Route')),
    );

    await tester.pumpWidget(app);

    expect(find.text('Home'), findsOneWidget);
    RM.navigate.toNamed('/NAN');
    await tester.pumpAndSettle();

    expect(find.text('Unknown Route'), findsOneWidget);
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

  //     RM.navigate.toNamed('Route1/1');
  //     await tester.pumpAndSettle();
  //     expect(find.text('Route1: Parsed data : 1'), findsOneWidget);
  //     //
  //     RM.navigate.toNamed('Route1/2');
  //     await tester.pumpAndSettle();
  //     expect(find.text('Unknown Route'), findsOneWidget);
  //     //
  //     RM.navigate.toNamed(Uri(path: 'Route1', queryParameters: {
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
      final app = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          {
            '/': (_) => Text('Home'),
            'Route1/:id': (param) {
              final map = {...param.queryParams, ...param.pathParams};
              return Route1((map['id'] ?? '') + (map['data'] ?? ''));
            },
            'Route2': (param) => Route2(param as String),
          },
          // parseRouteUri: (uri, pathParam) {
          //   if (pathParam != null) {}
          // },
          unknownRoute: (_) => Text('Unknown Route'),
        ),
      );
      await tester.pumpWidget(app);

      expect(find.text('Home'), findsOneWidget);

      RM.navigate.toNamed('Route1/Parsed data : 1');
      await tester.pumpAndSettle();
      expect(find.text('Route1: Parsed data : 1'), findsOneWidget);

      RM.navigate.toNamed(
        'Route1/toNamed, ',
        queryParams: {'data': 'Parsed data : 2'},
      );
      await tester.pumpAndSettle();
      expect(find.text('Route1: toNamed, Parsed data : 2'), findsOneWidget);

      RM.navigate.toReplacementNamed(
        'Route1/toReplacementNamed, ',
        queryParams: {'data': 'Parsed data : 2'},
      );
      await tester.pumpAndSettle();
      expect(find.text('Route1: toReplacementNamed, Parsed data : 2'),
          findsOneWidget);

      RM.navigate.toNamedAndRemoveUntil(
        'Route1/toNamedAndRemoveUntil, ',
        queryParams: {'data': 'Parsed data : 2'},
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
        '/page5/:page5ID': (_) => RouteWidget(
              routes: {
                '/': (data) => Builder(
                      builder: (__) {
                        queryParams = data.queryParams;
                        pathParams = data.pathParams;
                        routePath = data.routePath;
                        baseUrl = data.baseUrl;
                        return page5(data.arguments);
                      },
                    ),
                '/page51': (data) => Builder(
                      builder: (ctx) {
                        queryParams = ctx.routeQueryParams;
                        pathParams = ctx.routePathParams;
                        routePath = ctx.routePath;
                        baseUrl = ctx.routeBaseUrl;
                        return page5(ctx.routeArguments);
                      },
                    ),
                '/page52/:page52ID': (_) => RouteWidget(
                      routes: {
                        '/': (_) => Builder(
                              builder: (ctx) {
                                queryParams = ctx.routeQueryParams;
                                pathParams = ctx.routePathParams;
                                routePath = ctx.routePath;
                                baseUrl = ctx.routeBaseUrl;
                                return page52(ctx.routeArguments);
                              },
                            ),
                        '/:page521ID': (_) => Builder(
                              builder: (ctx) {
                                queryParams = ctx.routeQueryParams;
                                pathParams = ctx.routePathParams;
                                routePath = ctx.routePath;
                                baseUrl = ctx.routeBaseUrl;
                                return page521(ctx.routeArguments);
                              },
                            ),
                      },
                    )
              },
            )
      };
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);

      Future navigateAndExpect(String name, [bool isFound = true]) async {
        RM.navigate.toNamed(name, arguments: name);
        await tester.pumpAndSettle();
        if (isFound) {
          expect(find.text(name), findsOneWidget);
        }
      }

      await navigateAndExpect('/page1');
      await navigateAndExpect('page1', false);
      expect(find.text('404 /page1/page1'), findsOneWidget);
      await navigateAndExpect('/page1/');
      await navigateAndExpect('page11');
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

      expect(baseUrl, '/page5/id-1');
      expect(routePath, '/page5/:page5ID/');
      expect(pathParams, {'page5ID': 'id-1'});

      await navigateAndExpect('page5/id-2');

      expect(baseUrl, '/page5/id-2');
      expect(routePath, '/page5/:page5ID/');
      expect(pathParams, {'page5ID': 'id-2'});
      //
      await navigateAndExpect('page51');

      expect(baseUrl, '/page5/id-2');
      expect(routePath, '/page5/:page5ID/page51');
      expect(pathParams, {'page5ID': 'id-2'});
      //

      await navigateAndExpect('page52/id-3');

      expect(baseUrl, '/page5/id-2/page52/id-3');
      expect(routePath, '/page5/:page5ID/page52/:page52ID/');
      expect(pathParams, {'page5ID': 'id-2', 'page52ID': 'id-3'});
      //
      await navigateAndExpect('id-4');
      RM.navigate.toNamed('id-4', arguments: 'id-4', queryParams: {
        'queryId': 'id-6',
      });
      await tester.pumpAndSettle();
      expect(find.text('id-4'), findsOneWidget);

      expect(baseUrl, '/page5/id-2/page52/id-3');
      expect(routePath, '/page5/:page5ID/page52/:page52ID/:page521ID');
      expect(pathParams,
          {'page5ID': 'id-2', 'page52ID': 'id-3', 'page521ID': 'id-4'});
      expect(queryParams, {'queryId': 'id-6'});

      RM.navigate.toNamed('/', arguments: '/');
      RM.navigate.toNamed('/page1/', arguments: '/page1');
      RM.navigate.toNamed('page11/', arguments: 'page11');
      RM.navigate.toNamed('page112/page1122', arguments: 'page112/page1122');
      await tester.pumpAndSettle();
      expect(find.text('page112/page1122'), findsOneWidget);
      //
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('page11'), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      RM.navigate.back();
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
      final page2 = (_) => Text('$_');
      var getSubRoute = false;

      final routes = {
        '/': home,
        '/page1': (_) => RouteWidget(
              builder: (child) => getSubRoute
                  ? Builder(
                      builder: (context) {
                        print(child);
                        print(context.routeWidget);
                        assert(child == context.routeWidget);
                        return context.routeWidget;
                      },
                    )
                  : page1('/page1'),
              routes: {
                '/page12': (_) {
                  return Builder(
                    builder: (context) {
                      return page12(_.arguments);
                    },
                  );
                },
                '/page11': (_) => RouteWidget(
                      routes: {
                        '/': (_) => Builder(
                              builder: (context) {
                                return page11(context.routeArguments);
                              },
                            ),
                        '/page111': (_) => page111(_.arguments),
                        '/page112': (_) => RouteWidget(
                              builder: (_) => getSubRoute
                                  ? Builder(
                                      builder: (context) {
                                        return context.routeWidget;
                                      },
                                    )
                                  : page112('/page112'),
                              routes: {
                                '/page1121': (_) => page1121(_.arguments),
                                '/page1122': (_) => page1122(_.arguments),
                              },
                            ),
                      },
                    ),
              },
            ),
        'page2': (_) => Builder(
              builder: (context) {
                return context.routeWidget;
              },
            ),
      };
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);

      Future navigateAndExpect(String name, [bool isFound = true]) async {
        RM.navigate.toNamed(name, arguments: name);
        await tester.pumpAndSettle();
        if (isFound) {
          expect(find.text(name), findsOneWidget);
        }
      }

      await navigateAndExpect('page1/page12', false);
      expect(find.text('/page1'), findsOneWidget);

      getSubRoute = true;
      await navigateAndExpect('page1/page12', true);

      await navigateAndExpect('page1/page11', true);

      await navigateAndExpect('page1/page11/page112', false);
      expect(find.text('404 /page1/page11/page112'), findsOneWidget);

      await navigateAndExpect('/page2', false);
      expect(tester.takeException(), isAssertionError);

/////
      // await navigateAndExpect('page1/page11/page112', false);

      // //
      // await navigateAndExpect('page11/page111');
      // expect(routeName, 'page111');
      // expect(parentRoutePath, '/page1/page11');

      // await navigateAndExpect('page12');
      // await navigateAndExpect('page111', false);
      // expect(find.text('404 /page1/page111'), findsOneWidget);
      // await navigateAndExpect('page11/page111');
      // await navigateAndExpect('page112/page1121');
      // await navigateAndExpect('page1122');
      // await navigateAndExpect('/page1/page11/page112/page1122');
      // await navigateAndExpect('page1/page12');
      // await navigateAndExpect('page13');
    },
  );
}
/*
 RoutePage(
  routes: {
    '/': (_)=> page1(_),
  },
)

*/
