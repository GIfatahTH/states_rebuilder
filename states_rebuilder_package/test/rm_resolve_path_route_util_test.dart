import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injected/injected_navigator/injected_navigator.dart';
import 'package:states_rebuilder/src/rm.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  InjectedNavigatorImp.ignoreSingleRouteMapAssertion = true;
  late ResolvePathRouteUtil routePathResolver;
  setUp(() {
    routePathResolver = ResolvePathRouteUtil();
  });
  testWidgets(
    'test setAbsoluteUrlPath',
    (tester) async {
      var absolutePath = routePathResolver.setAbsoluteUrlPath('/');
      expect(absolutePath, '/');
      absolutePath = routePathResolver.setAbsoluteUrlPath('/page1');
      expect(absolutePath, '/page1');
      absolutePath = routePathResolver.setAbsoluteUrlPath('page1');
      expect(absolutePath, '/page1');
      //
      ResolvePathRouteUtil.globalBaseUrl = '/';
      absolutePath = routePathResolver.setAbsoluteUrlPath('/page1');
      expect(absolutePath, '/page1');
      absolutePath = routePathResolver.setAbsoluteUrlPath('page1');
      expect(absolutePath, '/page1');

      //
      ResolvePathRouteUtil.globalBaseUrl = '/page1';
      absolutePath = routePathResolver.setAbsoluteUrlPath('/');
      expect(absolutePath, '/');
      absolutePath = routePathResolver.setAbsoluteUrlPath('/page1');
      expect(absolutePath, '/page1');
      absolutePath = routePathResolver.setAbsoluteUrlPath('page2');
      expect(absolutePath, '/page1/page2');
      //
      ResolvePathRouteUtil.globalBaseUrl = '/page1/page2';
      absolutePath = routePathResolver.setAbsoluteUrlPath('/');
      expect(absolutePath, '/');
      absolutePath = routePathResolver.setAbsoluteUrlPath('/page1');
      expect(absolutePath, '/page1');
      absolutePath = routePathResolver.setAbsoluteUrlPath('page3');
      expect(absolutePath, '/page1/page2/page3');
      absolutePath = routePathResolver.setAbsoluteUrlPath('page2/page3');
      expect(absolutePath, '/page1/page2/page3');
      absolutePath = routePathResolver.setAbsoluteUrlPath('page1/page2/page3');
      expect(absolutePath, '/page1/page2/page3');
      absolutePath = routePathResolver.setAbsoluteUrlPath('page3/page4');
      expect(absolutePath, '/page1/page2/page3/page4');
      absolutePath = routePathResolver.setAbsoluteUrlPath('page2/page3/page4');
      expect(absolutePath, '/page1/page2/page3/page4');
      absolutePath =
          routePathResolver.setAbsoluteUrlPath('page1/page2/page3/page4');
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
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
      )!;
      expect(r.values, [const PageSettings(name: '/')]);
      expect(r['/']!.child, isA<Text>());
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
        skipHomeSlash: true,
      )!;
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
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
      )!;
      expect(r.values, [const PageSettings(name: '/')]);
      expect(r['/']!.child, isA<RouteWidget>());
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
        skipHomeSlash: true,
      )!;

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
      // Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
      //   settings: routeSetting,
      // )!;

      // expect(r.values, [const PageSettings(name: '/')]);
      // expect(r['/']!.child, isA<RouteWidget>());
      // expect((r['/'] as RouteSettingsWithRouteWidget).subRoute, isA<Text>());
      // //
      // r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
      //   settings: routeSetting,
      //   skipHomeSlash: true,
      // )!;

      // expect(r.values, [const PageSettings(name: '/')]);

      // expect(r['/']!.child, isA<RouteWidget>());
      // expect((r['/'] as RouteSettingsWithRouteWidget).subRoute, isA<Text>());
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
    'case routes has home (/) that return a RouteWidget with routes '
    'and builder',
    (tester) async {
      final routes = {
        '/': (_) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => const Text('/'),
                '/page1': (_) => const Text('/page1'),
              },
            ),
      };
      var routeSetting = const RouteSettings(name: '/page1');
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
      )!;

      expect(r.values, [
        const PageSettings(name: '/'), /*const PageSettings(name: '/page1')*/
      ]);
      expect(r['/']!.child, isA<RouteWidget>());
      expect((r['/'] as RouteSettingsWithRouteWidget).subRoute, null);

      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
        skipHomeSlash: true,
      )!;

      expect(r.values, [
        const PageSettings(name: '/'), /*const PageSettings(name: '/page1')*/
      ]);
      // expect(r['/page1']!.child, isA<RouteWidget>());
      // expect((r['/page1'] as RouteSettingsWithRouteWidget).subRoute, null);

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
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    },
  );

  testWidgets(
    'Navigator2: resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with routes '
    'and builder',
    (tester) async {
      final routes = {
        '/': (_) => RouteWidget(
              routes: {
                '/': (_) => const Text('/'),
                '/page1': (_) => const Text('/page1'),
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
      // Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
      //   settings: routeSetting,
      // )!;

      // expect(r.values,
      //     [const PageSettings(name: '/'), const PageSettings(name: '/page1')]);
      // expect(r['/page1']!.child, isA<RouteWidget>());
      // expect(
      //     (r['/page1'] as RouteSettingsWithRouteWidget).subRoute, isA<Text>());
      // r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
      //   settings: routeSetting,
      //   skipHomeSlash: true,
      // )!;

      // expect(r.values, [const PageSettings(name: '/page1')]);
      // expect(r['/page1']!.child, isA<RouteWidget>());
      // expect(
      //     (r['/page1'] as RouteSettingsWithRouteWidget).subRoute, isA<Text>());
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
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
      )!;
      expect(r.values, [
        const PageSettings(name: '/'),
        // const RouteSettingsWithChild(name: '/')
      ]);
      expect(r['/']!.child, isA<RouteWidget>());
      // expect((r['/'] as RouteSettingsWithRouteWidget).subRoute, isA<Text>());
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
        skipHomeSlash: true,
      )!;
      expect(r.values, [
        const PageSettings(name: '/'),
        // const RouteSettingsWithChild(name: '/')
      ]);
      expect(r['/']!.child, isA<RouteWidget>());
      // expect((r['/'] as RouteSettingsWithRouteWidget).subRoute, isA<Text>());
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
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
      )!;
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
      // var text = (r['/page1'] as RouteSettingsWithRouteWidget).subRoute as Text;
      // expect(text.data, '/page1');
      expect((r['/page1'] as RouteSettingsWithRouteWidget).routeData.path,
          '/page1');

      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
        skipHomeSlash: true,
      )!;

      expect(r.values, [
        const PageSettings(name: '/page1'),
        // const RouteSettingsWithChild(name: '/page1'),
      ]);
      expect(r.keys, [
        '/page1',
        // '/page1*',
      ]);
      expect(r['/page1']!.child, isA<RouteWidget>());
      // text = (r['/page1'] as RouteSettingsWithRouteWidget).subRoute as Text;
      // expect(text.data, '/page1');

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
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
      )!;
      expect(r.values, [
        const PageSettings(name: '/'),
        const PageSettings(name: '/page1'),
        // const PageSettings(name: '/page1/page11')
      ]);
      expect(r['/page1']!.child, isA<RouteWidget>());
      // final text =
      //     (r['/page1'] as RouteSettingsWithRouteWidget).subRoute as Text;
      // expect(text.data, '/page1');
      // //

      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
        skipHomeSlash: true,
      )!;
      expect(r.values, [
        // const RouteSettingsWithChild(name: '/'),
        const PageSettings(name: '/page1'),
        // const PageSettings(name: '/page1/page11')
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
      // Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
      //   settings: routeSetting,
      // )!;
      // expect(r.values, [
      //   const PageSettings(name: '/'),
      //   const PageSettings(name: '/page1'),
      //   const PageSettings(name: '/page1/page11')
      // ]);
      // expect(r['/']!.child, isA<Container>());
      // expect(r['/page1']!.child, isA<RouteWidget>());
      // expect((r['/page1'] as RouteSettingsWithRouteWidget).subRoute,
      //     isA<Center>());

      // r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
      //   settings: routeSetting,
      //   skipHomeSlash: true,
      // )!;
      // expect(r.values, [
      //   // const RouteSettingsWithChild(name: '/'),
      //   // const PageSettings(name: '/page1'),
      //   const PageSettings(name: '/page1/page11')
      // ]);
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
        '/': (_) => const Text('/'),
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => const Text('/page1'),
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
      // Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
      //   settings: routeSetting,
      // )!;
      // expect(r.values, [
      //   const PageSettings(name: '/'),
      //   const PageSettings(name: '/page1'),
      //   const PageSettings(name: '/page1/page11'),
      //   const PageSettings(name: '/page1/page11/page111')
      // ]);
      // //
      // r = routePathResolver.getPagesFromRouteSettings(
      //   routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
      //   settings: routeSetting,
      //   skipHomeSlash: true,
      // )!;
      // expect(r.values, [
      //   // const RouteSettingsWithChild(name: '/'),
      //   // const PageSettings(name: '/page1'),
      //   // const PageSettings(name: '/page1/page11'),
      //   const PageSettings(name: '/page1/page11/page111')
      // ]);

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
      final routes = {
        '/': (_) => Container(),
        '/page1': (_) => RouteWidget(
              builder: (_) {
                return _;
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
      Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: routeSetting,
      )!;
      expect(r.values, [
        const PageSettings(name: '/'),
        const PageSettings(name: '/page1'),
        // const PageSettings(name: '/page1/page11'),
        // const PageSettings(name: '/page1/page11/page111')
      ]);
      expect(r['/']!.child, isA<Container>());
      expect(r['/page1']!.child, isA<RouteWidget>());
      // expect(r['/page1/page11']!.child, isA<RouteWidget>());
      // expect(r['/page1/page11/page111']!.child, isA<RouteWidget>());
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
    'and with builder route to /page1/page11/page111',
    (tester) async {
      final routes = {
        '/': (_) => const Text('/'),
        '/page1': (_) => RouteWidget(
              builder: (_) {
                return Builder(
                  builder: (context) {
                    return context.routerOutlet;
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
      Map<String, RouteSettingsWithChildAndData> r =
          routePathResolver.getPagesFromRouteSettings(
        routes: {
          Uri(path: '/'): (_) => Container(),
          Uri(path: '/page1/:id'): (_) => const Text(''),
        },
        settings: routeSetting,
      )!;
      expect(r.values, [
        const PageSettings(name: '/'),
        const PageSettings(name: '/page1/2')
      ]);
      expect(r['/page1/2']!.routeData.pathParams, {'id': '2'});
    },
  );
  testWidgets(
    'resolve RouteSettingsWithChild  with path parameter route = /page1/:id/page11/:user',
    (tester) async {
      var routeSetting =
          const RouteSettings(name: '/page1/2/page11/i_am_a_user');
      final routes = {
        '/': (_) => Container(),
        '/page1/:id': (_) => RouteWidget(
              routes: {
                '/': (_) => Text('/page1/${_.pathParams['id']}'),
                '/page11/:user': (_) => Text(
                      '/page1/${_.pathParams['id']}/page11/${_.pathParams['user']}',
                    ),
              },
            ),
      };
      // expect(r.values, [
      //   const PageSettings(name: '/'),
      //   const PageSettings(name: '/page1/2'),
      //   const PageSettings(name: '/page1/2/page11/i_am_a_user'),
      // ]);
      // expect(r['/page1/2']!.routeData.pathParams,
      //     {'id': '2', 'user': 'i_am_a_user'});
      // expect(r['/page1/2/page11/i_am_a_user']!.routeData.pathParams,
      //     {'id': '2', 'user': 'i_am_a_user'});

      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text(routeSetting.name!), findsOneWidget);
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1/2'), findsOneWidget);
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
                '/page11/:user': (_) => Text('/page1/${_.pathParams['id']}'
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
      Map<String, RouteSettingsWithChildAndData> r =
          routePathResolver.getPagesFromRouteSettings(
        routes: {
          Uri(path: '/page1'): (_) => RouteWidget(
                routes: {
                  '/page11': (_) => const Text(''),
                },
              ),
        },
        settings: routeSetting,
      )!;
      expect(r.toString(), '{/: PAGE NOT Found (name: /)}');
      expect(() => getWidgetFromPages(pages: r), throwsAssertionError);
    },
  );

  testWidgets(
    'route / inside RouteWidget not found',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1');
      final routes = {
        '/page1': (_) => RouteWidget(
              routes: {
                '/page11': (_) => const Text(''),
              },
            ),
      };
      // expect(r.toString(), '{/page1: PAGE NOT Found (name: /page1)}');
      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(find.text('404 ' + routeSetting.name!), findsOneWidget);
    },
  );

  testWidgets(
    'get the right basePathUrl based on route path',
    (tester) async {
      // route name does not end with '/'
      var routeSetting = const RouteSettings(name: '/page1');
      routePathResolver.getPagesFromRouteSettings(
        routes: {
          Uri(path: '/page1'): (_) => RouteWidget(
                routes: {
                  '/': (_) => const Center(),
                  '/page11': (_) => const Text(''),
                },
              ),
        },
        settings: routeSetting,
      )!;
      expect(ResolvePathRouteUtil.globalBaseUrl, '/');

      // route name ends with '/'
      routeSetting = const RouteSettings(name: '/page1/');
      final routes = {
        '/page1': (_) => RouteWidget(
              routes: {
                '/': (_) => const Center(),
                '/page11': (_) => const Text(''),
              },
            ),
      };
      final widget2 = _TopWidget(
        routers: routes,
        initialRoute: routeSetting.name,
      );
      await tester.pumpWidget(widget2);
      expect(ResolvePathRouteUtil.globalBaseUrl, '/page1');
    },
  );

  testWidgets(
    'route / inside RouteWidget not found with builder defined',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1');

      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        initialRoute: routeSetting.name,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          {
            '/page1': (_) => RouteWidget(
                  builder: (_) => _,
                  routes: {
                    '/page11': (_) => const Text(''),
                  },
                ),
          },
          unknownRoute: (name) => Text('404 $name'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('404 ' + routeSetting.name!), findsOneWidget);
    },
  );

  // testWidgets(
  //   'routes are ordered in the right order',
  //   (tester) async {
  //     var routeSetting = const RouteSettings(name: '/page1/page11');
  //     Map<String, PageSettings> r = routePathResolver.getPagesFromRouteSettings(
  //       routes: {
  //         '/page1': (_) => RouteWidget(
  //               routes: {
  //                 '/': (_) => const Text(''),
  //                 '/page11': (_) => const Text(''),
  //               },
  //             ),
  //       },
  //       settings: routeSetting,
  //     )!;

  //     expect(r.values, [
  //       const PageSettings(name: '/page1'),
  //       const PageSettings(name: '/page1/page11'),
  //     ]);
  //     //
  //     r = routePathResolver.getPagesFromRouteSettings(
  //       routes: {
  //         '/page1': (_) => RouteWidget(
  //               routes: {
  //                 '/page11': (_) => const Text(''),
  //               },
  //             ),
  //       },
  //       settings: routeSetting,
  //     )!;

  //     expect(r.values, [
  //       // const PageSettings(name: '/page1'),
  //       const PageSettings(name: '/page1/page11'),
  //     ]);
  //   },
  // );

  testWidgets(
    'Check that RouterObjects.routerDelegates are added and removed when disposed'
    'And that back method pops the innermost sub route',
    (tester) async {
      final routes = {
        '/': (data) => const Text('/'),
        '/page1': (data) => RouteWidget(
              builder: (_) => Builder(builder: (context) {
                return context.routerOutlet;
              }),
              routes: {
                '/': (_) => const Text('/page1'),
                '/page11': (_) => const Text('/page1/page11'),
                '/page12': (_) => RouteWidget(
                      builder: (_) => _,
                      routes: {
                        '/': (_) => const Text('/page1/page12'),
                        '/page121': (_) => const Text('/page1/page12/page121'),
                      },
                    )
              },
            ),
        '/page2': (data) => RouteWidget(
              builder: (_) => _,
              routes: {
                '/': (_) => const Text('/page2'),
              },
            ),
      };

      final widget = _TopWidget(routers: routes);
      await tester.pumpWidget(widget);
      expect(find.text('/'), findsOneWidget);
      // expect(RouterObjects.routerDelegates.length, 1);
      // expect(
      //   RouterObjects
      //       .routerDelegates[RouterObjects.root]!.values.last.routeStack.length,
      //   1,
      // );

      RM.navigate.toNamed('/page1');
      await tester.pumpAndSettle();
      // expect(RouterObjects.routerDelegates.length, 2);
      // expect(
      //   RouterObjects
      //       .routerDelegates[RouterObjects.root]!.values.last.routeStack.length,
      //   2,
      // );
      // expect(
      //   RouterObjects.routerDelegates['/page1']!.values.last.routeStack.length,
      //   1,
      // );
      expect(find.text('/page1'), findsOneWidget);
      //
      RM.navigate.toNamed('/page1/page11');
      await tester.pumpAndSettle();
      // expect(RouterObjects.routerDelegates.length, 2);
      // expect(
      //   RouterObjects
      //       .routerDelegates[RouterObjects.root]!.values.last.routeStack.length,
      //   2,
      // );
      // expect(
      //   RouterObjects.routerDelegates['/page1']!.values.last.routeStack.length,
      //   2,
      // );
      expect(find.text('/page1/page11'), findsOneWidget);
      //
      RM.navigate.toNamed('/page1/page12/page121');
      await tester.pumpAndSettle();
      expect(find.text('/page1/page12/page121'), findsOneWidget);
      //
      RM.navigate.toNamed('/page2');
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      // expect(RouterObjects.routerDelegates.length, 4);
      // expect(
      //   RouterObjects
      //       .routerDelegates[RouterObjects.root]!.values.last.routeStack.length,
      //   3,
      // );
      // expect(
      //   RouterObjects.routerDelegates['/page1']!.values.last.routeStack.length,
      //   3,
      // );
      // expect(
      //   RouterObjects
      //       .routerDelegates['/page1/page12']!.values.last.routeStack.length,
      //   1,
      // );
      // expect(
      //   RouterObjects.routerDelegates['/page2']!.values.last.routeStack.length,
      //   1,
      // );
      // //
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1/page12/page121'), findsOneWidget);
      // expect(RouterObjects.routerDelegates.length, 3);
      // expect(
      //   RouterObjects
      //       .routerDelegates[RouterObjects.root]!.values.last.routeStack.length,
      //   2,
      // );
      // expect(
      //   RouterObjects.routerDelegates['/page1']!.values.last.routeStack.length,
      //   3,
      // );
      // expect(
      //   RouterObjects
      //       .routerDelegates['/page1/page12']!.values.last.routeStack.length,
      //   1,
      // );
      // expect(RouterObjects.routerDelegates['/page2'], null);
      //
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1/page11'), findsOneWidget);
      // expect(RouterObjects.routerDelegates.length, 2);
      // expect(
      //   RouterObjects
      //       .routerDelegates[RouterObjects.root]!.values.last.routeStack.length,
      //   2,
      // );
      // expect(
      //   RouterObjects.routerDelegates['/page1']!.values.last.routeStack.length,
      //   2,
      // );
      // expect(RouterObjects.routerDelegates['/page1/page12'], null);
      // expect(RouterObjects.routerDelegates['/page2'], null);
      //
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      // expect(RouterObjects.routerDelegates.length, 2);
      // expect(
      //   RouterObjects
      //       .routerDelegates[RouterObjects.root]!.values.last.routeStack.length,
      //   2,
      // );
      // expect(
      //   RouterObjects.routerDelegates['/page1']!.values.last.routeStack.length,
      //   1,
      // );
      // expect(RouterObjects.routerDelegates['/page1/page12'], null);
      // expect(RouterObjects.routerDelegates['/page2'], null);
      //
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      // expect(RouterObjects.routerDelegates.length, 1);
      // expect(
      //   RouterObjects
      //       .routerDelegates[RouterObjects.root]!.values.last.routeStack.length,
      //   1,
      // );
      // expect(RouterObjects.routerDelegates['/page1'], null);
      // expect(RouterObjects.routerDelegates['/page1/page12'], null);
      // expect(RouterObjects.routerDelegates['/page2'], null);
      //
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
      // expect(RouterObjects.routerDelegates.length, 1);
      // expect(
      //   RouterObjects
      //       .routerDelegates[RouterObjects.root]!.values.last.routeStack.length,
      //   1,
      // );
    },
  );

  testWidgets(
    'WHEN nested route uri are used without RouteWidget '
    'THEN it works as expected',
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
      var r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/'),
      )!;
      expect((r['/']!.child as Text).data, '/');
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/page1'),
      )!;
      expect((r['/page1']!.child as Text).data, '/page1');

      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/page1/1'),
      )!;
      expect((r['/page1/1']!.child as Text).data, '/page1/1');

      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/page1/1/page11'),
        skipHomeSlash: true,
      )!;

      expect((r['/page1/1/page11']!.child as Text).data, '/page1/1/page11');

      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/page1/1/page12'),
      )!;
      expect((r['/page1/1/page12']!.child as Text).data, '/page1/1/page12');
    },
  );
  // TODO
  // testWidgets(
  //   'WHEN isBaseUrlChanged'
  //   'THEN',
  //   (tester) async {
  //     final routes = {
  //       '/': (data) => const Text('/'),
  //       '/page1': (data) => RouteWidget(
  //             builder: (_) => _,
  //             routes: {
  //               '/': (_) => const Text('/page1'),
  //               '/page11': (_) => const Text('/page1/page11'),
  //               '/page12': (_) => const Text('/page1/page12'),
  //             },
  //           ),
  //     };

  //     Map<String, RouteSettingsWithChildAndData> r =
  //         routePathResolver.getPagesFromRouteSettings(
  //       routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
  //       settings: const RouteSettings(name: '/'),
  //     )!;
  //     expect(r['/']!.isBaseUrlChanged, true);
  //     //
  //     r = routePathResolver.getPagesFromRouteSettings(
  //       routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
  //       settings: const RouteSettings(name: '/page1'),
  //     )!;

  //     print(r['/']!.isBaseUrlChanged);
  //     print(r['/page1']!.isBaseUrlChanged);
  //     //
  //     r = routePathResolver.getPagesFromRouteSettings(
  //       routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
  //       settings: const RouteSettings(name: '/page1/page11'),
  //     )!;

  //     print(r['/']!.isBaseUrlChanged);
  //     print(r['/page1']!.isBaseUrlChanged);
  //     print(r['/page1/page11']!.isBaseUrlChanged);
  //     //
  //     r = routePathResolver.getPagesFromRouteSettings(
  //       routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
  //       settings: const RouteSettings(name: '/page1/page12'),
  //     )!;

  //     print(r['/']!.isBaseUrlChanged);
  //     print(r['/page1']!.isBaseUrlChanged);
  //     print(r['/page1/page12']!.isBaseUrlChanged);
  //   },
  // );

  group(
    'redirection',
    () {
      testWidgets(
        'WHEN redirect is defined'
        'WHEN it is null THEN it return null'
        'THEN not null in navigates to it',
        (tester) async {
          String? directTo;
          final routes = {
            '/': (data) => const Text('/'),
            '/page1': (RouteData data) {
              if (data.arguments != null) {
                return data.redirectTo(null);
              }
              return const Text('/page1');
            },
            '/page2': (data) => RouteWidget(
                  routes: {
                    '/page21': (data) => RouteWidget(
                          routes: {
                            '/page211': (data) => RouteWidget(
                                  routes: {
                                    '/page2111': (data) => RouteWidget(
                                          routes: {
                                            '/page21111': (RouteData data) {
                                              if (data.arguments != null) {
                                                return data
                                                    .redirectTo(directTo);
                                              }
                                              return const Text('/page2');
                                            }
                                          },
                                        ),
                                  },
                                ),
                          },
                        ),
                  },
                ),
            '/page3': (RouteData data) => const Text('/page3'),
          };

          final widget2 = _TopWidget(
            routers: routes,
          );
          await tester.pumpWidget(widget2);
          expect(find.text('/'), findsOneWidget);

          // RM.navigate.toNamed('/page1', arguments: 'arg');
          // await tester.pumpAndSettle();
          // expect(find.text('/'), findsOneWidget);

          // RM.navigate.toNamed(
          //   '/page2/page21/page211/page2111/page21111',
          //   arguments: 'arg',
          // );
          // await tester.pumpAndSettle();
          // expect(find.text('/'), findsOneWidget);

          directTo = '/page3';

          RM.navigate.toNamed(
            '/page2/page21/page211/page2111/page21111',
            arguments: 'arg',
          );
          await tester.pumpAndSettle();
          expect(find.text('/page3'), findsOneWidget);
        },
      );
    },
  );
  testWidgets(
    'Test dynamic links',
    (tester) async {
      RouteData? routeData;
      final routes = {
        '/page1/:id': (data) => RouteWidget(
              builder: (_) {
                routeData = data;
                return Builder(
                  builder: (context) {
                    return _;
                  },
                );
              },
              routes: {
                '/': (_) => Text('/page1/${_.pathParams['id']}'),
                '/page11': (data) {
                  final id = data.pathParams['id'];
                  return Text('/page1/$id/page11');
                },
                '/page12': (data) {
                  return Builder(
                    builder: (ctx) {
                      final id = data.pathParams['id'];
                      return Text('/page1/$id/page12');
                    },
                  );
                }
              },
            ),
        '/page2': (data) {
          return RouteWidget(
            routes: {
              '/': (data) {
                return const Text('page2');
              },
              '/:id': (_) => RouteWidget(
                    routes: {'/': (_) => Text('/page2/${_.pathParams['id']}')},
                  ),
            },
          );
        },
      };

      var widget = _TopWidget(
        routers: routes,
        initialRoute: '/page1/1/',
      );
      await tester.pumpWidget(widget);
      expect(find.text('/page1/1'), findsOneWidget);
      //
      RM.navigate.toNamed(routeData!.location + '/page11');
      await tester.pumpAndSettle();
      expect(find.text('/page1/1/page11'), findsOneWidget);
      //
      RM.navigate.toNamed(routeData!.location + '/page12');
      await tester.pumpAndSettle();
      expect(find.text('/page1/1/page12'), findsOneWidget);
      //
      RM.navigate.toNamed(routeData!.location + '/');
      await tester.pumpAndSettle();
      expect(find.text('/page1/1'), findsOneWidget);
      //
      RM.navigate.toNamed('/page2/2');
      await tester.pumpAndSettle();
      expect(find.text('/page2/2'), findsOneWidget);
    },
  );

  testWidgets(
    'test route param regex extraction',
    (tester) async {
      final Map<String, Widget Function(RouteData)> routes = {
        '/one/:id': (data) => Text(data.location),
        '/two/:id(.*)': (data) => Text(data.location),
        '/three/:id(\\d+)': (data) => Text(data.location),
        '/four/:id(one|two|three)': (data) => Text(data.location),
        '/five/:id(*)': (data) => Text(data.location),
        '/six/:id(one|(two))': (data) => Text(data.location),
        '/seven/*': (data) => Text(data.location),
        '*': (data) => Text('404 ' + data.location),
      };
      String? getValue(RouteSettingsWithChildAndData data) {
        return (data.child as Text?)?.data;
      }

      var r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: 'one/5'),
      )!;

      expect(getValue(r.values.last), '/one/5');
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/two/fffffffJJJJJJ'),
      )!;
      expect(getValue(r.values.last), '/two/fffffffJJJJJJ');
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/three/one'),
      )!;
      expect(getValue(r.values.last), '404 /three/one');
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/four/one'),
      )!;
      expect(getValue(r.values.last), '/four/one');

      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/four/one1'),
      )!;
      expect(getValue(r.values.last), '404 /four/one1');

      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/four/three'),
      )!;
      expect(getValue(r.values.last), '/four/three');
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/four/four'),
      )!;
      expect(getValue(r.values.last), '404 /four/four');
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/five/5'),
      )!;
      expect(getValue(r.values.last), '404 /five/5');
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/six/6'),
      )!;
      expect(getValue(r.values.last), '404 /six/6');
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/six/one'),
      )!;
      expect(getValue(r.values.last), '/six/one');
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/six/two'),
      )!;
      expect(getValue(r.values.last), '/six/two');
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/six/one-two'),
      )!;
      expect(getValue(r.values.last), '404 /six/one-two');

      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/seven/one/two/three'),
      )!;
      expect(getValue(r.values.last), '/seven/one/two/three');
      //
      r = routePathResolver.getPagesFromRouteSettings(
        routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
        settings: const RouteSettings(name: '/eight/one/two/three'),
      )!;
      expect(getValue(r.values.last), '404 /eight/one/two/three');
    },
  );

  testWidgets(
    'throw invalid path',
    (tester) async {
      final Map<String, Widget Function(RouteData)> routes = {
        '/:': (data) => Text(data.pathParams['id']!),
      };

      String message = '';

      try {
        routePathResolver.getPagesFromRouteSettings(
          routes: routes.map((key, value) => MapEntry(Uri.parse(key), value)),
          settings: const RouteSettings(name: '/5'),
        )!;
      } catch (e) {
        message = e as String;
      }
      expect(message, '":" is invalid path');
    },
  );
}

late InjectedNavigator _navigator;

class _TopWidget extends TopStatelessWidget {
  _TopWidget({
    Key? key,
    required this.routers,
    this.initialRoute,
    this.initialRouteSettings,
  }) : super(key: key) {
    _navigator = RM.injectNavigator(
      routes: routers,
      unknownRoute: (route) => Text('404 ${route.location}'),
      initialLocation: initialRoute ?? initialRouteSettings?.name,
    );
  }
  final Map<String, Widget Function(RouteData p1)> routers;
  final String? initialRoute;
  final PageSettings? initialRouteSettings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: _navigator.routeInformationParser,
      routerDelegate: _navigator.routerDelegate,
    );
  }
}
