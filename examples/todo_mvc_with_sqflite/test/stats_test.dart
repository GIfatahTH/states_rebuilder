import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todo_mvc_with_sqflite/injected.dart';
import 'package:todo_mvc_with_sqflite/main.dart';
import 'package:todo_mvc_with_sqflite/ui/pages/home_screen/extra_actions_button.dart';
import 'package:todo_mvc_with_sqflite/ui/pages/home_screen/stats_counter.dart';

import 'fake_Sqflite_Repository.dart';

void main() async {
  final storage = await RM.storageInitializerMock();
  todos.injectCRUDMock(() => FakeSqfliteRepository(todos3));

  setUp(() {
    storage.clear();
  });
  testWidgets('Show stats, and toggle completed', (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    //
    await tester.tap(find.byIcon(Icons.show_chart));
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.byType(StatsCounter), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    //Top to toggle all to completed
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__toggleAll__')));
    await tester.pumpAndSettle(Duration(seconds: 1));

    //
    expect(find.text('3'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    //
    //Toggle all to uncompleted
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__toggleAll__')));
    await tester.pumpAndSettle(Duration(seconds: 1));

    //Only active todos are displayed
    expect(find.text('0'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Show stats, and clear completed', (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    //
    await tester.tap(find.byIcon(Icons.show_chart));
    await tester.pumpAndSettle(Duration(seconds: 1));

    expect(find.byType(StatsCounter), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    //Top to clear completed
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__toggleClearCompleted__')));
    await tester.pumpAndSettle();

    //one completed todo is removed. Remains to active todos
    expect(find.text('2'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    //
    //Toggle all to completed
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__toggleAll__')));
    await tester.pumpAndSettle();

    //Two completed todos
    expect(find.text('0'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__toggleClearCompleted__')));
    await tester.pumpAndSettle();

    //all todos are removed
    expect(find.text('0'), findsNWidgets(2));
  });
}
