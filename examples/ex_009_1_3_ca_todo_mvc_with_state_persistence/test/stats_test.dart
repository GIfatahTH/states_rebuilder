import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence/main.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence/ui/pages/home_screen/extra_actions_button.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence/ui/pages/home_screen/stats_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'home_screen_test.dart';

void main() async {
  final storage = await RM.storageInitializerMock();
  setUp(() {
    storage.clear();
  });
  testWidgets('Show stats, and toggle completed', (tester) async {
    storage.store.addAll({'__Todos__': todos3});
    await tester.pumpWidget(App());
    //
    await tester.tap(find.byIcon(Icons.show_chart));
    await tester.pumpAndSettle();

    expect(find.byType(StatsCounter), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    //Top to toggle all to completed
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__toggleAll__')));
    await tester.pumpAndSettle();

    //
    expect(find.text('3'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    //
    //Toggle all to uncompleted
    await tester.tap(find.byType(ExtraActionsButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('__toggleAll__')));
    await tester.pumpAndSettle();

    //Only active todos are displayed
    expect(find.text('0'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Show stats, and clear completed', (tester) async {
    storage.store.addAll({'__Todos__': todos3});
    await tester.pumpWidget(App());
    //
    await tester.tap(find.byIcon(Icons.show_chart));
    await tester.pumpAndSettle();

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
