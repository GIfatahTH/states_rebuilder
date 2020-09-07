import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

void main() {
  testWidgets('Throw assertion when no ScaffoldState is found', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(),
        navigatorKey: RM.navigate.navigatorKey,
      ),
    );

    expect(
      () => RM.scaffoldShow.snackBar(SnackBar(content: Container())),
      throwsException,
    );
  });

  testWidgets('Display a snackBar', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            RM.scaffoldShow.context = context;
            return Container();
          },
        ),
      ),
      navigatorKey: RM.navigate.navigatorKey,
    ));

    RM.scaffoldShow.snackBar(SnackBar(content: Container()));

    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });
  testWidgets('Display a bottomSheet', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            RM.scaffoldShow.context = context;
            return Container();
          },
        ),
      ),
      navigatorKey: RM.navigate.navigatorKey,
    ));

    RM.scaffoldShow.bottomSheet(Text('BottomSheet'));

    await tester.pumpAndSettle();
    expect(find.text('BottomSheet'), findsOneWidget);
  });

  testWidgets('openDrawer', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        drawer: Drawer(),
        body: Builder(
          builder: (context) {
            RM.scaffoldShow.context = context;
            return Container();
          },
        ),
      ),
      navigatorKey: RM.navigate.navigatorKey,
    ));

    RM.scaffoldShow.openDrawer();

    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
  });

  testWidgets('openEndDrawer', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        endDrawer: Drawer(),
        body: Builder(
          builder: (context) {
            RM.scaffoldShow.context = context;
            return Container();
          },
        ),
      ),
      navigatorKey: RM.navigate.navigatorKey,
    ));

    RM.scaffoldShow.openEndDrawer();

    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
  });

  testWidgets('should get the context from setState', (tester) async {
    final rm = RM.inject(
      () => 0,
      onData: (_) => RM.scaffoldShow.snackBar(SnackBar(content: Container())),
      onWaiting: () => RM.scaffoldShow.snackBar(SnackBar(content: Container())),
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        endDrawer: Drawer(),
        body: Builder(
          builder: (context) {
            return RaisedButton(
              onPressed: () {
                rm.setState(
                  (s) async {
                    await Future.delayed(Duration(seconds: 1));
                    return s + 1;
                  },
                  context: context,
                  silent: true,
                );
              },
            );
          },
        ),
      ),
      navigatorKey: RM.navigate.navigatorKey,
    ));
    await tester.tap(find.byType(RaisedButton));

    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
