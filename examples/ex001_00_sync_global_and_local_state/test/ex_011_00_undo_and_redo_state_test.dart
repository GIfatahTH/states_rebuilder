import 'package:ex001_00_sync_global_and_local_state/ex_011_00_undo_and_redo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final activeUnDoButton = find.byWidgetPredicate(
    (widget) =>
        widget is ElevatedButton &&
        (widget.child as Text).data == "Undo" &&
        widget.enabled,
  );
  final activeReDoButton = find.byWidgetPredicate(
    (widget) =>
        widget is ElevatedButton &&
        (widget.child as Text).data == "Redo" &&
        widget.enabled,
  );
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('0'), findsOneWidget);
    expect(activeUnDoButton, findsNothing);
    expect(activeReDoButton, findsNothing);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsNothing);
    //
    await tester.tap(activeUnDoButton);
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(activeUnDoButton, findsNothing);
    expect(activeReDoButton, findsOneWidget);
    //
    await tester.tap(activeReDoButton);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsNothing);
    //
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsNothing);
    //
    await tester.tap(activeUnDoButton);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsOneWidget);
    //
    await tester.tap(activeUnDoButton);
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(activeUnDoButton, findsNothing);
    expect(activeReDoButton, findsOneWidget);
    //
    //
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsNothing);
    //
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.pump();
    expect(find.text('6'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsNothing);
    //
    await tester.tap(activeUnDoButton);
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsOneWidget);
    //
    await tester.tap(activeUnDoButton);
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
    //
    await tester.tap(activeUnDoButton);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsOneWidget);
    //
    await tester.tap(activeUnDoButton);
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(activeUnDoButton, findsNothing);
    expect(activeReDoButton, findsOneWidget);
    //
    await tester.tap(activeReDoButton);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsOneWidget);
    //
    await tester.tap(activeReDoButton);
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
    //
    await tester.tap(activeReDoButton);
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsOneWidget);
    //
    await tester.tap(activeReDoButton);
    await tester.pump();
    expect(find.text('6'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsNothing);
    //
    await tester.tap(activeUnDoButton);
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
    expect(activeUnDoButton, findsOneWidget);
    expect(activeReDoButton, findsOneWidget);
    //
    await tester.tap(find.text('Clear undo queue'));
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
    expect(activeUnDoButton, findsNothing);
    expect(activeReDoButton, findsNothing);
  });
}
