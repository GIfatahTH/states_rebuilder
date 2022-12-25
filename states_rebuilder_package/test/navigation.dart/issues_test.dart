import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    '#260',
    (tester) async {
      final navigator = RM.injectNavigator(
        routes: {
          '/': (data) => const Text('/'),
          '/page1': (data) => RouteWidget(
                builder: (_) => const Text('/page1'),
              ),
          '/page2': (data) => RouteWidget(
                routes: {
                  '/': (data) => RouteWidget(
                        builder: (_) => const Text('/page2'),
                      ),
                  '/page21': (data) => RouteWidget(
                        builder: (_) => const Text('/page21'),
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
      navigator.toReplacement('/page1');
      await tester.pumpAndSettle();
      expect(find.text('/page1'), findsOneWidget);
      navigator.toReplacement('/page2');
      await tester.pumpAndSettle();
      expect(find.text('/page2'), findsOneWidget);
      navigator.toReplacement('/page2/page21');
      await tester.pumpAndSettle();
      expect(find.text('/page21'), findsOneWidget);
    },
  );
}
