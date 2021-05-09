import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

BuildContext? context;
final widget = MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (ctx) {
        context = ctx;
        return On(() => Container()).listenTo(0.inj());
      },
    ),
    drawer: Text('Drawer'),
    endDrawer: Text('EndDrawer'),
  ),
);
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
    expect(() => RM.scaffold.scaffoldState, throwsException);
    expect(() => RM.scaffold.scaffoldMessengerState, throwsAssertionError);

    RM.scaffold.context = context!;
    expect(RM.scaffold.scaffoldState, isNotNull);
    expect(RM.scaffold.scaffoldMessengerState, isNotNull);
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
    expect(() => RM.scaffold.scaffoldState, throwsException);
    expect(RM.scaffold.scaffoldMessengerState, isNotNull);
  });

  testWidgets('showBottomSheet', (tester) async {
    await tester.pumpWidget(widget);
    RM.scaffold.showBottomSheet(
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
    await tester.pumpWidget(widget);
    RM.scaffold.showSnackBar(
        SnackBar(
          content: Text('showSnackBar'),
        ),
        hideCurrentSnackBar: false);
    await tester.pumpAndSettle();
    expect(find.text('showSnackBar'), findsOneWidget);
    RM.scaffold.hideCurrentSnackBar();
    await tester.pump();
    expect(find.text('showSnackBar'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('showSnackBar'), findsNothing);
  });

  testWidgets('removeCurrentSnackBarm', (tester) async {
    await tester.pumpWidget(widget);
    RM.scaffold.showSnackBar(
        SnackBar(
          content: Text('showSnackBar'),
        ),
        hideCurrentSnackBar: false);
    await tester.pumpAndSettle();
    expect(find.text('showSnackBar'), findsOneWidget);
    RM.scaffold.removeCurrentSnackBarm();
    await tester.pump();
    expect(find.text('showSnackBar'), findsNothing);
  });

  testWidgets('openDrawer and openEndDrawer', (tester) async {
    await tester.pumpWidget(widget);
    RM.scaffold.openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('Drawer'), findsOneWidget);
    RM.scaffold.openEndDrawer();
    await tester.pumpAndSettle();
    expect(find.text('EndDrawer'), findsOneWidget);
  });
}
