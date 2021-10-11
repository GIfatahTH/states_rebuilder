import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';
// import 'package:states_rebuilder/src/rm.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  late ResolvePathRouteUtil routePathResolver;
  setUp(() {
    routePathResolver = ResolvePathRouteUtil();
  });
  testWidgets(
    'test setAbsoluteUrlPath',
    (tester) async {
      var absolutePath =
          routePathResolver.setAbsoluteUrlPath(const RouteSettings(name: '/'));
      expect(absolutePath, '/');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: '/page1'));
      expect(absolutePath, '/page1');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: 'page1'));
      expect(absolutePath, '/page1');
      //
      routePathResolver.baseUrl = '/';
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: '/page1'));
      expect(absolutePath, '/page1');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: 'page1'));
      expect(absolutePath, '/page1');

      //
      routePathResolver.baseUrl = '/page1';
      absolutePath =
          routePathResolver.setAbsoluteUrlPath(const RouteSettings(name: '/'));
      expect(absolutePath, '/');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: '/page1'));
      expect(absolutePath, '/page1');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: 'page2'));
      expect(absolutePath, '/page1/page2');
      //
      routePathResolver.baseUrl = '/page1/page2';
      absolutePath =
          routePathResolver.setAbsoluteUrlPath(const RouteSettings(name: '/'));
      expect(absolutePath, '/');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: '/page1'));
      expect(absolutePath, '/page1');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: 'page3'));
      expect(absolutePath, '/page1/page2/page3');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: 'page2/page3'));
      expect(absolutePath, '/page1/page2/page3');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: 'page1/page2/page3'));
      expect(absolutePath, '/page1/page2/page3');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: 'page3/page4'));
      expect(absolutePath, '/page1/page2/page3/page4');
      absolutePath = routePathResolver
          .setAbsoluteUrlPath(const RouteSettings(name: 'page2/page3/page4'));
      expect(absolutePath, '/page1/page2/page3/page4');
      absolutePath = routePathResolver.setAbsoluteUrlPath(
          const RouteSettings(name: 'page1/page2/page3/page4'));
      expect(absolutePath, '/page1/page2/page3/page4');
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a Widget',
    (tester) async {
      final routes = {
        '/': (_) => const Text('/'),
      };
      var routeSetting = const RouteSettings(name: '/');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
      );
      expect(r.values, [const PageSettings(name: '/')]);
      expect(r['/']!.child, isA<Text>());
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
        skipHomeSlash: true,
      );
      expect(r.values, [const PageSettings(name: '/')]);
      expect(r['/']!.child, isA<Text>());
      //
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        initialRoute: '/',
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text(routeSetting.name!), findsOneWidget);
      //
      final widget2 = _TopWidget(routers: routes);
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );

  testWidgets(
    'Navigator2: resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a Widget',
    (tester) async {
      final routes = {
        '/': (_) => const Text('/'),
      };
      var routeSetting = const RouteSettings(name: '/');

      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with builder '
    'and without route',
    (tester) async {
      final routes = {
        '/': (_) => RouteWidget(
              builder: (_) {
                return const Text('/');
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
      );
      expect(r.values, [const PageSettings(name: '/')]);
      expect(r['/']!.child, isA<RouteWidget>());
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
        skipHomeSlash: true,
      );

      expect(r.values, [const PageSettings(name: '/')]);
      expect(r['/']!.child, isA<RouteWidget>());
      //
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        initialRoute: '/',
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );

  testWidgets(
    'Navigator2: resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with builder '
    'and without route',
    (tester) async {
      final routes = {
        '/': (_) => RouteWidget(
              builder: (_) {
                return const Text('/');
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/');
      //
      final widget2 = _TopWidget(
        routers: routes,
        initialRouteSettings: PageSettings(name: routeSetting.name!),
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with routes '
    'and without builder',
    (tester) async {
      final routes = {
        '/': (_) => RouteWidget(
              routes: {
                '/': (_) => const Text('/'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
      );

      expect(r.values, [const PageSettings(name: '/')]);
      expect(r['/']!.child, isA<RouteWidget>());
      expect(
          (r['/'] as RouteSettingsWithChildAndSubRoute).subRoute, isA<Text>());
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
        skipHomeSlash: true,
      );

      expect(r.values, [const PageSettings(name: '/')]);

      expect(r['/']!.child, isA<RouteWidget>());
      expect(
          (r['/'] as RouteSettingsWithChildAndSubRoute).subRoute, isA<Text>());
      //
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        initialRoute: '/',
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text(routeSetting.name!), findsOneWidget);
      //
      final widget2 = _TopWidget(routers: routes);
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );

  testWidgets(
    'Navigator2: resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with routes '
    'and without builder',
    (tester) async {
      final routes = {
        '/': (_) => RouteWidget(
              routes: {
                '/': (_) => const Text('/'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/');
      //
      final widget2 = _TopWidget(routers: routes);
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );
  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and without builder',
    (tester) async {
      final routes = {
        '/': (_) => const Text('/'),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => const Text('/page1'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/page1');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
      );

      expect(r.values,
          [const PageSettings(name: '/'), const PageSettings(name: '/page1')]);
      expect(r['/page1']!.child, isA<RouteWidget>());
      expect((r['/page1'] as RouteSettingsWithChildAndSubRoute).subRoute,
          isA<Text>());
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
        skipHomeSlash: true,
      );

      expect(r.values, [const PageSettings(name: '/page1')]);
      expect(r['/page1']!.child, isA<RouteWidget>());
      expect((r['/page1'] as RouteSettingsWithChildAndSubRoute).subRoute,
          isA<Text>());
      //
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        initialRoute: routeSetting.name,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text(routeSetting.name!), findsOneWidget);
      //
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'Navigator2: resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and without builder',
    (tester) async {
      final routes = {
        '/': (_) => const Text('/'),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => const Text('/page1'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/page1');
      //
      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with routes '
    'and with builder',
    (tester) async {
      final routes = {
        '/': (_) => RouteWidget(
              builder: (_) {
                return _;
              },
              routes: {
                '/': (_) => const Text('/'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
      );
      expect(r.values, [
        const PageSettings(name: '/'),
        // const RouteSettingsWithChild(name: '/')
      ]);
      expect(r['/']!.child, isA<RouteWidget>());
      expect(
          (r['/'] as RouteSettingsWithChildAndSubRoute).subRoute, isA<Text>());
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
        skipHomeSlash: true,
      );
      expect(r.values, [
        const PageSettings(name: '/'),
        // const RouteSettingsWithChild(name: '/')
      ]);
      expect(r['/']!.child, isA<RouteWidget>());
      expect(
          (r['/'] as RouteSettingsWithChildAndSubRoute).subRoute, isA<Text>());
      //
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        initialRoute: routeSetting.name,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );

  testWidgets(
    'Navigator2: resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with routes '
    'and with builder',
    (tester) async {
      final routes = {
        '/': (_) => RouteWidget(
              builder: (_) {
                return _;
              },
              routes: {
                '/': (_) => const Text('/'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/');
      //
      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );
  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with routes '
    'and with builder. route to /page1',
    (tester) async {
      final routes = {
        '/': (_) => Container(),
        '/page1': (_) {
          return RouteWidget(
            builder: (_) {
              return _;
            },
            routes: {
              '/': (_) => const Text('/page1'),
              '/page11': (_) => const Text('/page11'),
            },
          );
        },
      };
      var routeSetting = const RouteSettings(name: '/page1');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
      );
      expect(r.values, [
        const PageSettings(name: '/'),
        const PageSettings(name: '/page1'),
        // const RouteSettingsWithChild(name: '/page1'),
      ]);
      expect(r.keys, [
        '/',
        '/page1',
        // '/page1*',
      ]);
      expect(r['/page1']!.child, isA<RouteWidget>());
      var text =
          (r['/page1'] as RouteSettingsWithChildAndSubRoute).subRoute as Text;
      expect(text.data, '/page1');
      expect((r['/page1'] as RouteSettingsWithChildAndSubRoute).routeUriPath,
          '/page1');

      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
        skipHomeSlash: true,
      );

      expect(r.values, [
        const PageSettings(name: '/page1'),
        // const RouteSettingsWithChild(name: '/page1'),
      ]);
      expect(r.keys, [
        '/page1',
        // '/page1*',
      ]);
      expect(r['/page1']!.child, isA<RouteWidget>());
      text =
          (r['/page1'] as RouteSettingsWithChildAndSubRoute).subRoute as Text;
      expect(text.data, '/page1');

      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        initialRoute: routeSetting.name,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );

  testWidgets(
    'Navigator2: resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with routes '
    'and with builder. route to /page1',
    (tester) async {
      final routes = {
        '/': (_) => const Text('/'),
        '/page1': (_) {
          return RouteWidget(
            builder: (_) {
              return _;
            },
            routes: {
              '/': (_) => const Text('/page1'),
              '/page11': (_) => const Text('/page11'),
            },
          );
        },
      };
      var routeSetting = const RouteSettings(name: '/page1');
      //
      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);

      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has /page1 that return a RouteWidget with routes '
    'and with builder. route to /page1/page11',
    (tester) async {
      final routes = {
        '/': (_) => Container(),
        '/page1': (_) => RouteWidget(
              builder: (_) {
                return _;
              },
              routes: {
                '/': (_) => const Text('/page1'),
                '/page11': (_) => const Text('/page1/page11'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/page1/page11');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
      );
      expect(r.values, [
        const PageSettings(name: '/'),
        const PageSettings(name: '/page1'),
        const PageSettings(name: '/page1/page11')
      ]);
      expect(r['/page1']!.child, isA<RouteWidget>());
      final text =
          (r['/page1'] as RouteSettingsWithChildAndSubRoute).subRoute as Text;
      expect(text.data, '/page1');
      //

      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
        skipHomeSlash: true,
      );
      expect(r.values, [
        // const RouteSettingsWithChild(name: '/'),
        const PageSettings(name: '/page1'),
        const PageSettings(name: '/page1/page11')
      ]);
      //
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        initialRoute: routeSetting.name,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );
  testWidgets(
    'Navigator2: resolve RouteSettingsWithChild from routes and path url'
    'case routes has /page1 that return a RouteWidget with routes '
    'and with builder. route to /page1/page11',
    (tester) async {
      final routes = {
        '/': (_) => const Text('/'),
        '/page1': (_) => RouteWidget(
              builder: (_) {
                return _;
              },
              routes: {
                '/': (_) => const Text('/page1'),
                '/page11': (_) => const Text('/page1/page11'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/page1/page11');
      //
      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );
  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and without builder route to /page1/page11',
    (tester) async {
      final routes = {
        '/': (_) => Container(),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => const Center(),
                '/page11': (_) => const Text('/page1/page11'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/page1/page11');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
      );
      expect(r.values, [
        const PageSettings(name: '/'),
        const PageSettings(name: '/page1'),
        const PageSettings(name: '/page1/page11')
      ]);
      expect(r['/']!.child, isA<Container>());
      expect(r['/page1']!.child, isA<RouteWidget>());
      expect((r['/page1'] as RouteSettingsWithChildAndSubRoute).subRoute,
          isA<Center>());

      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
        skipHomeSlash: true,
      );
      expect(r.values, [
        // const RouteSettingsWithChild(name: '/'),
        const PageSettings(name: '/page1'),
        const PageSettings(name: '/page1/page11')
      ]);
      //
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        initialRoute: routeSetting.name,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );

  testWidgets(
    'Navigator2 resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and without builder route to /page1/page11',
    (tester) async {
      final routes = {
        '/': (_) => Text('/'),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => Text('/page1'),
                '/page11': (_) => const Text('/page1/page11'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/page1/page11');
      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and without builder route to /page1/page11/page111',
    (tester) async {
      final routes = {
        '/': (_) => Container(),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => const Text('/page1'),
                '/page11': (_) => RouteWidget(
                      routes: {
                        '/': (_) => const Text('/page1/page11'),
                        '/page111': (_) => const Text('/page1/page11/page111'),
                      },
                    ),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/page1/page11/page111');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
      );
      expect(r.values, [
        const PageSettings(name: '/'),
        const PageSettings(name: '/page1'),
        const PageSettings(name: '/page1/page11'),
        const PageSettings(name: '/page1/page11/page111')
      ]);
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: routeSetting,
        skipHomeSlash: true,
      );
      expect(r.values, [
        // const RouteSettingsWithChild(name: '/'),
        const PageSettings(name: '/page1'),
        const PageSettings(name: '/page1/page11'),
        const PageSettings(name: '/page1/page11/page111')
      ]);

      //
      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        initialRoute: routeSetting.name,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          routes,
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text(routeSetting.name!), findsOneWidget);
    },
  );
  testWidgets(
    'Navigator2: resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and without builder route to /page1/page11/page111',
    (tester) async {
      final routes = {
        '/': (_) => const Text('/'),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => const Text('/page1'),
                '/page11': (_) => RouteWidget(
                      routes: {
                        '/': (_) => const Text('/page1/page11'),
                        '/page111': (_) => const Text('/page1/page11/page111'),
                      },
                    ),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/page1/page11/page111');
      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1/page11'), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );
  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and with builder route to /page1/page11/page111',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1/page11/page111');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: {
          '/': (_) => Container(),
          '/page1': (_) => RouteWidget(
                builder: (_) {
                  return const Center();
                },
                routes: {
                  '/': (_) => const Text('/'),
                  '/page11': (_) => RouteWidget(
                        routes: {
                          '/': (_) => const Text('/'),
                          '/page111': (_) => const Text('/page111'),
                        },
                      ),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.values, [
        const PageSettings(name: '/'),
        const PageSettings(name: '/page1'),
        const PageSettings(name: '/page1/page11'),
        const PageSettings(name: '/page1/page11/page111')
      ]);
      expect(r['/']!.child, isA<Container>());
      expect(r['/page1']!.child, isA<RouteWidget>());
      expect(r['/page1/page11']!.child, isA<RouteWidget>());
      expect(r['/page1/page11/page111']!.child, isA<Text>());
    },
  );

  testWidgets(
    'Navigator2 resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and with builder route to /page1/page11/page111',
    (tester) async {
      final routes = {
        '/': (_) => const Text('/'),
        '/page1': (_) => RouteWidget(
              builder: (_) {
                return Builder(
                  builder: (context) {
                    return context.routeWidget;
                  },
                );
              },
              routes: {
                '/': (_) => const Text('/page1'),
                '/page11': (_) => RouteWidget(
                      routes: {
                        '/': (_) => const Text('/page1/page11'),
                        '/page111': (_) => const Text('/page1/page11/page111'),
                      },
                    ),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/page1/page11/page111');
      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1/page11'), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild  with path parameter route =/page1/:id',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1/2');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: {
          '/': (_) => Container(),
          '/page1/:id': (_) => const Text(''),
        },
        settings: routeSetting,
      );
      expect(r.values, [
        const PageSettings(name: '/'),
        const PageSettings(name: '/page1/2')
      ]);
      expect(r['/page1/2']!.pathParams, {'id': '2'});
    },
  );
  testWidgets(
    'resolve RouteSettingsWithChild  with path parameter route = /page1/:id/page11/:user',
    (tester) async {
      var routeSetting =
          const RouteSettings(name: '/page1/2/page11/i_am_a_user');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: {
          '/': (_) => Container(),
          '/page1/:id': (_) => RouteWidget(
                routes: {
                  '/': (_) => const Text(''),
                  'page11/:user': (_) => const Center(),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.values, [
        const PageSettings(name: '/'),
        const PageSettings(name: '/page1/2'),
        const PageSettings(name: '/page1/2/page11/i_am_a_user'),
      ]);
      expect(r['/page1/2']!.pathParams, {'id': '2', 'user': 'i_am_a_user'});
      expect(r['/page1/2/page11/i_am_a_user']!.pathParams,
          {'id': '2', 'user': 'i_am_a_user'});
    },
  );

  testWidgets(
    'Navigator2 resolve RouteSettingsWithChild  with path parameter route = /page1/:id/page11/:user',
    (tester) async {
      var routeSetting =
          const RouteSettings(name: '/page1/2/page11/i_am_a_user');
      final routes = {
        '/': (_) => const Text('/'),
        '/page1/:id': (_) => RouteWidget(
              routes: {
                '/': (_) => Text('/page1/${_.pathParams['id']}'),
                'page11/:user': (_) => Text('/page1/${_.pathParams['id']}'
                    '/page11/${_.pathParams['user']}'),
              },
            ),
      };

      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1/2'), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'route / not found',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: {
          '/page1': (_) => RouteWidget(
                routes: {
                  'page11': (_) => const Text(''),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.toString(), '{/: PAGE NOT Found (name: /)}');
    },
  );

  testWidgets(
    'route / inside RouteWidget not found',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: {
          '/page1': (_) => RouteWidget(
                routes: {
                  'page11': (_) => const Text(''),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.toString(), '{/page1: PAGE NOT Found (name: /page1)}');
    },
  );

  testWidgets(
    'get the right basePathUrl based on route path',
    (tester) async {
      // route name does not end with '/'
      var routeSetting = const RouteSettings(name: '/page1');
      routePathResolver.getPagesFromRouteSettings(
        routes: {
          '/page1': (_) => RouteWidget(
                routes: {
                  '/': (_) => const Center(),
                  'page11': (_) => const Text(''),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(routePathResolver.baseUrl, '/');

      // route name ends with '/'
      routeSetting = const RouteSettings(name: '/page1/');
      routePathResolver.getPagesFromRouteSettings(
        routes: {
          '/page1': (_) => RouteWidget(
                routes: {
                  '/': (_) => const Center(),
                  'page11': (_) => const Text(''),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(routePathResolver.baseUrl, '/page1');
    },
  );

  testWidgets(
    'route / inside RouteWidget not found with builder defined',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: {
          '/page1': (_) => RouteWidget(
                builder: (_) => const Center(),
                routes: {
                  'page11': (_) => const Text(''),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.toString(), '{/page1: PAGE NOT Found (name: /page1)}');

      // expect(r.values, [const RouteSettingsWithChild(name: '/')]);
      // expect(r['/']!.child, isA<Text>());
    },
  );

  testWidgets(
    'routes are ordered in the right order',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1/page11');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: {
          '/page1': (_) => RouteWidget(
                routes: {
                  '/': (_) => const Text(''),
                  'page11': (_) => const Text(''),
                },
              ),
        },
        settings: routeSetting,
      );

      expect(r.values, [
        const PageSettings(name: '/page1'),
        const PageSettings(name: '/page1/page11'),
      ]);
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: {
          '/page1': (_) => RouteWidget(
                routes: {
                  'page11': (_) => const Text(''),
                },
              ),
        },
        settings: routeSetting,
      );

      expect(r.values, [
        const PageSettings(name: '/page1'),
        const PageSettings(name: '/page1/page11'),
      ]);
    },
  );

  testWidgets(
    'WHEN u '
    'THEN',
    (tester) async {
      final Map<String, Widget Function(RouteData)> routes = {
        '/': (data) => const Text('/'),
        '/page1': (data) => const Text('/page1'),
        '/page1/:id': (data) => Text(
              '/page1/${data.pathParams['id']}',
            ),
        '/page1/:id/page11': (data) => Text(
              '/page1/${data.pathParams['id']}/page11',
            ),
        '/page1/:id/page12': (data) => Text(
              '/page1/${data.pathParams['id']}/page12',
            ),
      };
      // var r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes,
      //   settings: const RouteSettings(name: '/'),
      // );
      // expect((r['/']!.child as Text).data, '/');
      // //
      // r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes,
      //   settings: const RouteSettings(name: '/page1'),
      // );
      // expect((r['/page1']!.child as Text).data, '/page1');

      // r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes,
      //   settings: const RouteSettings(name: '/page1/1'),
      // );
      // expect((r['/page1/1']!.child as Text).data, '/page1/1');

      var r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: const RouteSettings(name: '/page1/1/page11'),
        skipHomeSlash: true,
      );
      print(r);
      expect((r['/page1/1/page11']!.child as Text).data, '/page1/1/page11');

      // r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes,
      //   settings: const RouteSettings(name: '/page1/1/page12'),
      // );
      // expect((r['/page1/1/page12']!.child as Text).data, '/page1/1/page12');
    },
  );
  testWidgets(
    'WHEN'
    'THEN',
    (tester) async {
      final routes = {
        '/': (data) => Center(),
        '/page1': (data) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => Center(),
                '/page11': (_) => Center(),
                '/page12': (_) => Center(),
              },
            ),
      };

      Map<String, RouteSettingsWithChildAndData> r =
          routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: const RouteSettings(name: '/'),
      );
      expect(r['/']!.isBaseUrlChanged, true);
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: const RouteSettings(name: '/page1'),
      );

      print(r);
      print(r['/']!.isBaseUrlChanged);
      print(r['/page1']!.isBaseUrlChanged);
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: const RouteSettings(name: '/page1/page11'),
      );

      print(r);
      print(r['/']!.isBaseUrlChanged);
      print(r['/page1']!.isBaseUrlChanged);
      print(r['/page1/page11']!.isBaseUrlChanged);
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes,
        settings: const RouteSettings(name: '/page1/page12'),
      );

      print(r);
      print(r['/']!.isBaseUrlChanged);
      print(r['/page1']!.isBaseUrlChanged);
      print(r['/page1/page12']!.isBaseUrlChanged);
    },
  );
}

class _TopWidget extends TopStatelessWidget with NavigatorMixin {
  _TopWidget({
    Key? key,
    required this.routers,
    this.initialRoute,
    this.initialRouteSettings,
  }) : super(key: key);
  final Map<String, Widget Function(RouteData p1)> routers;
  final String? initialRoute;
  final PageSettings? initialRouteSettings;
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: initialRoute == null
          ? routeInformationParser
          : routeInformationParser.setInitialRoute(initialRoute!),
      routerDelegate: initialRouteSettings == null
          ? routerDelegate
          : (routerDelegate..setInitialRoutePath(initialRouteSettings!)),
    );
  }

  @override
  Map<String, Widget Function(RouteData p1)> get routes => routers;
  @override
  Widget Function(String route) get unknownRoute =>
      (route) => Text('404 $route');
}
