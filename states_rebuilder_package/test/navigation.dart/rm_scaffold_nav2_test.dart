// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final _navigator = RM.injectNavigator(routes: {
  '/': (data) => Scaffold(
        body: Builder(
          builder: (ctx) {
            context = ctx;
            return OnBuilder(listenTo: 0.inj(), builder: () => Container());
          },
        ),
        drawer: Text('Drawer'),
        endDrawer: Text('EndDrawer'),
      ),
});
BuildContext? context;

void main() {
  setUp(() {
    context = null;
    RM.disposeAll();
  });
  testWidgets('Throw exception no scaffold', (tester) async {
    final widget = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) {
            context = ctx;
            return Container();
          },
        ),
      ),
    );

    await tester.pumpWidget(widget);
    expect(() => _navigator.scaffold.scaffoldState, throwsException);
    expect(
        () => _navigator.scaffold.scaffoldMessengerState, throwsAssertionError);

    _navigator.scaffold.context = context!;
    expect(_navigator.scaffold.scaffoldState, isNotNull);
    expect(_navigator.scaffold.scaffoldMessengerState, isNotNull);
  });

  testWidgets('Scaffold messenger is defined from RM.navigate', (tester) async {
    final widget = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) {
            context = ctx;
            return Container();
          },
        ),
      ),
      navigatorKey: RM.navigate.navigatorKey,
    );

    await tester.pumpWidget(widget);
    expect(() => _navigator.scaffold.scaffoldState, throwsException);
    expect(_navigator.scaffold.scaffoldMessengerState, isNotNull);
  });

  testWidgets('showBottomSheet', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: _navigator.routerDelegate,
        routeInformationParser: _navigator.routeInformationParser,
      ),
    );
    _navigator.scaffold.showBottomSheet(
      Text('showBottomSheet'),
      backgroundColor: Colors.red,
      clipBehavior: Clip.antiAlias,
      elevation: 2.0,
      shape: BorderDirectional(),
    );
    await tester.pumpAndSettle();
    expect(find.text('showBottomSheet'), findsOneWidget);
  });

  testWidgets('hideCurrentSnackBar', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: _navigator.routerDelegate,
        routeInformationParser: _navigator.routeInformationParser,
      ),
    );
    _navigator.scaffold.showSnackBar(
        SnackBar(
          content: Text('showSnackBar'),
        ),
        hideCurrentSnackBar: false);
    await tester.pumpAndSettle();
    expect(find.text('showSnackBar'), findsOneWidget);
    _navigator.scaffold.hideCurrentSnackBar();
    await tester.pump();
    expect(find.text('showSnackBar'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('showSnackBar'), findsNothing);
  });

  testWidgets('removeCurrentSnackBarm', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: _navigator.routerDelegate,
        routeInformationParser: _navigator.routeInformationParser,
      ),
    );
    _navigator.scaffold.showSnackBar(
        SnackBar(
          content: Text('showSnackBar'),
        ),
        hideCurrentSnackBar: false);
    await tester.pumpAndSettle();
    expect(find.text('showSnackBar'), findsOneWidget);
    _navigator.scaffold.removeCurrentSnackBarm();
    await tester.pump();
    expect(find.text('showSnackBar'), findsNothing);
  });

  testWidgets('openDrawer and openEndDrawer', (tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerDelegate: _navigator.routerDelegate,
      routeInformationParser: _navigator.routeInformationParser,
    ));
    _navigator.scaffold.openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('Drawer'), findsOneWidget);
    _navigator.scaffold.openEndDrawer();
    await tester.pumpAndSettle();
    expect(find.text('EndDrawer'), findsOneWidget);
  });
}
