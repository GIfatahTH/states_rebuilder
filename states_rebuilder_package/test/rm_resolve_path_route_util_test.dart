import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';

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
      var routeSetting = const RouteSettings(name: '/');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
        routes: {
          '/': (_) => const Text('/'),
        },
        settings: routeSetting,
      );
      expect(r.values, [const RouteSettingsWithChild(name: '/')]);
      expect(r['/']!.child, isA<Text>());
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with builder '
    'and without route',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
        routes: {
          '/': (_) => RouteWidget(
                builder: (_) {
                  return const Text('/');
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.values, [const RouteSettingsWithChild(name: '/')]);
      expect(r['/']!.child, isA<RouteWidget>());
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with routes '
    'and without builder',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
        routes: {
          '/': (_) => RouteWidget(
                routes: {
                  '/': (_) => const Text('/'),
                },
              ),
        },
        settings: routeSetting,
      );
      print(r);
      expect(r.values, [const RouteSettingsWithChild(name: '/')]);
      expect(r['/']!.child, isA<RouteWidget>());
      expect(
          (r['/'] as RouteSettingsWithChildAndSubRoute).subRoute, isA<Text>());
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and without builder',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
        routes: {
          '/': (_) => Container(),
          '/page1': (_) => RouteWidget(
                routes: {
                  '/': (_) => const Text('/'),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.values, [
        const RouteSettingsWithChild(name: '/'),
        const RouteSettingsWithChild(name: '/page1')
      ]);
      expect(r['/page1']!.child, isA<RouteWidget>());
      expect((r['/page1'] as RouteSettingsWithChildAndSubRoute).subRoute,
          isA<Text>());
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with routes '
    'and with builder',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
        routes: {
          '/': (_) => RouteWidget(
                builder: (_) {
                  return Container();
                },
                routes: {
                  '/': (_) => const Text('/'),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.values, [const RouteSettingsWithChild(name: '/')]);
      expect(r['/']!.child, isA<RouteWidget>());
      expect(
          (r['/'] as RouteSettingsWithChildAndSubRoute).subRoute, isA<Text>());
    },
  );
  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has home (/) that return a RouteWidget with routes '
    'and with builder. route to /page1',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
        routes: {
          '/page1': (_) => RouteWidget(
                builder: (_) {
                  return Container();
                },
                routes: {
                  '/': (_) => const Text('/page1'),
                  '/page11': (_) => const Text('/page11'),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.values, [const RouteSettingsWithChild(name: '/page1')]);
      expect(r['/page1']!.child, isA<RouteWidget>());
      final text =
          (r['/page1'] as RouteSettingsWithChildAndSubRoute).subRoute as Text;
      expect(text.data, '/page1');
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes has /page1 that return a RouteWidget with routes '
    'and with builder. route to /page1/page11',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1/page11');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
        routes: {
          '/page1': (_) => RouteWidget(
                builder: (_) {
                  return Container();
                },
                routes: {
                  '/': (_) => const Text('/page1'),
                  '/page11': (_) => const Text('/page11'),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.values, [
        const RouteSettingsWithChild(name: '/page1'),
        const RouteSettingsWithChild(name: '/page1/page11')
      ]);
      expect(r['/page1']!.child, isA<RouteWidget>());
      final text =
          (r['/page1'] as RouteSettingsWithChildAndSubRoute).subRoute as Text;
      expect(text.data, '/page1');
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and without builder route to /page1/page11',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1/page11');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
        routes: {
          '/': (_) => Container(),
          '/page1': (_) => RouteWidget(
                routes: {
                  '/': (_) => const Center(),
                  '/page11': (_) => const Text('/page11'),
                },
              ),
        },
        settings: routeSetting,
      );
      expect(r.values, [
        const RouteSettingsWithChild(name: '/'),
        const RouteSettingsWithChild(name: '/page1'),
        const RouteSettingsWithChild(name: '/page1/page11')
      ]);
      expect(r['/']!.child, isA<Container>());
      expect(r['/page1']!.child, isA<RouteWidget>());
      expect((r['/page1'] as RouteSettingsWithChildAndSubRoute).subRoute,
          isA<Center>());
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and without builder route to /page1/page11/page111',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1/page11/page111');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
        routes: {
          '/': (_) => Container(),
          '/page1': (_) => RouteWidget(
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
        const RouteSettingsWithChild(name: '/'),
        const RouteSettingsWithChild(name: '/page1'),
        const RouteSettingsWithChild(name: '/page1/page11'),
        const RouteSettingsWithChild(name: '/page1/page11/page111')
      ]);
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild from routes and path url'
    'case routes  (/page) that return a RouteWidget with routes '
    'and with builder route to /page1/page11/page111',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1/page11/page111');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
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
        const RouteSettingsWithChild(name: '/'),
        const RouteSettingsWithChild(name: '/page1'),
        const RouteSettingsWithChild(name: '/page1/page11'),
        const RouteSettingsWithChild(name: '/page1/page11/page111')
      ]);
      expect(r['/']!.child, isA<Container>());
      expect(r['/page1']!.child, isA<RouteWidget>());
      expect(r['/page1/page11']!.child, isA<RouteWidget>());
      expect(r['/page1/page11/page111']!.child, isA<Text>());
    },
  );

  testWidgets(
    'resolve RouteSettingsWithChild  with path parameter route =/page1/:id',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1/2');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
        routes: {
          '/': (_) => Container(),
          '/page1/:id': (_) => const Text(''),
        },
        settings: routeSetting,
      );
      expect(r.values, [
        const RouteSettingsWithChild(name: '/'),
        const RouteSettingsWithChild(name: '/page1/2')
      ]);
      expect(r['/page1/2']!.pathParams, {'id': '2'});
    },
  );
  testWidgets(
    'resolve RouteSettingsWithChild  with path parameter route = /page1/:id/page11/:user',
    (tester) async {
      var routeSetting =
          const RouteSettings(name: '/page1/2/page11/i_am_a_user');
      Map<String, RouteSettingsWithChild> r = routePathResolver.resolve(
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
        const RouteSettingsWithChild(name: '/'),
        const RouteSettingsWithChild(name: '/page1/2'),
        const RouteSettingsWithChild(name: '/page1/2/page11/i_am_a_user'),
      ]);
      expect(r['/page1/2']!.pathParams, {'id': '2', 'user': 'i_am_a_user'});
      expect(r['/page1/2/page11/i_am_a_user']!.pathParams,
          {'id': '2', 'user': 'i_am_a_user'});
    },
  );

  testWidgets(
    'route / not found',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/');
      Map<String, RouteSettingsWithChild> r =
          routePathResolver.getPagesFromRouteSettings(
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
      Map<String, RouteSettingsWithChild> r =
          routePathResolver.getPagesFromRouteSettings(
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
      Map<String, RouteSettingsWithChild> r =
          routePathResolver.getPagesFromRouteSettings(
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
      print(r);
      // expect(r.values, [const RouteSettingsWithChild(name: '/')]);
      // expect(r['/']!.child, isA<Text>());
    },
  );

  testWidgets(
    'routes are ordered in the right order',
    (tester) async {
      var routeSetting = const RouteSettings(name: '/page1/page11');
      Map<String, RouteSettingsWithChild> r =
          routePathResolver.getPagesFromRouteSettings(
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
        const RouteSettingsWithChild(name: '/page1'),
        const RouteSettingsWithChild(name: '/page1/page11'),
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
        const RouteSettingsWithChild(name: '/page1'),
        const RouteSettingsWithChild(name: '/page1/page11'),
      ]);
    },
  );
}
