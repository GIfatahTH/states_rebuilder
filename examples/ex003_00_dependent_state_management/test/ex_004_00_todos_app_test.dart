import 'package:ex003_00_dependent_state_management/ex_004_00_todos_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final checkedBoxFinder = find.byWidgetPredicate(
    (widget) => widget is Checkbox && widget.value == true,
  );
  final unCheckedBoxFinder = find.byWidgetPredicate(
    (widget) => widget is Checkbox && widget.value != true,
  );

  final checkedToggleAllFinder = find.descendant(
    of: find.byType(Toolbar),
    matching: find.byWidgetPredicate(
      (widget) => widget is Checkbox && widget.value == true,
    ),
  );

  final toggleAllToCompletedFinder = find.descendant(
    of: find.byType(Toolbar),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Tooltip &&
          widget.message == 'Toggle All todos to completed',
    ),
  );
  final toggleAllToUncompletedFinder = find.descendant(
    of: find.byType(Toolbar),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Tooltip &&
          widget.message == 'Toggle All todos to uncompleted',
    ),
  );
  testWidgets(
    'WHEN app starts, todos are displayed ',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(4));
      expect(checkedToggleAllFinder, findsNWidgets(0));
    },
  );

  testWidgets(
    'Filter todos',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(4));
      expect(checkedToggleAllFinder, findsNWidgets(0));
      //
      await tester.tap(find.text('Active'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(4));
      expect(checkedToggleAllFinder, findsNWidgets(0));
      //
      await tester.tap(find.text('Completed'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(0));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(1));
      expect(checkedToggleAllFinder, findsNWidgets(0));
      //
      await tester.tap(find.text('All'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(4));
      expect(checkedToggleAllFinder, findsNWidgets(0));
      //
      await tester.tap(unCheckedBoxFinder.at(1));
      await tester.pump();
      expect(checkedBoxFinder, findsNWidgets(1));
      expect(unCheckedBoxFinder, findsNWidgets(3));
      expect(checkedToggleAllFinder, findsNWidgets(0));
      //
      await tester.tap(find.text('Completed'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(1));
      expect(checkedBoxFinder, findsNWidgets(1));
      expect(unCheckedBoxFinder, findsNWidgets(1));
      //
      await tester.tap(checkedBoxFinder.first);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(0));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(1));
      //
      await tester.tap(find.text('Active'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(4));
    },
  );

  testWidgets(
    'Add todo',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(4));
      expect(checkedToggleAllFinder, findsNWidgets(0));
      //
      await tester.enterText(find.byType(TextField), 'new Todo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(4));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(5));
      expect(checkedToggleAllFinder, findsNWidgets(0));
      //
      await tester.tap(find.text('Active'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(4));
      expect(checkedBoxFinder, findsNWidgets(0));
      //
      await tester.enterText(find.byType(TextField), 'new Todo1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(find.text('new Todo1'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets(
    'Check todo',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(4));
      expect(checkedToggleAllFinder, findsNWidgets(0));
      expect(find.text('3 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.tap(unCheckedBoxFinder.at(1));
      await tester.pump();
      expect(checkedBoxFinder, findsNWidgets(1));
      expect(unCheckedBoxFinder, findsNWidgets(3));
      expect(find.text('2 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.tap(unCheckedBoxFinder.at(1));
      await tester.pump();
      expect(checkedBoxFinder, findsNWidgets(2));
      expect(unCheckedBoxFinder, findsNWidgets(2));
      expect(find.text('1 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.tap(unCheckedBoxFinder.at(1));
      await tester.pump();
      expect(checkedBoxFinder, findsNWidgets(4));
      expect(unCheckedBoxFinder, findsNWidgets(0));
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
      //

      await tester.enterText(find.byType(TextField), 'new Todo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(checkedBoxFinder, findsNWidgets(3));
      expect(unCheckedBoxFinder, findsNWidgets(2));
      expect(find.text('1 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
    },
  );

  testWidgets(
    'Toggle all todos',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(4));
      expect(checkedToggleAllFinder, findsNWidgets(0));
      expect(find.text('3 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.tap(toggleAllToCompletedFinder);
      await tester.pump();
      expect(checkedBoxFinder, findsNWidgets(4));
      expect(unCheckedBoxFinder, findsNWidgets(0));
      expect(checkedToggleAllFinder, findsOneWidget);
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
      //
      await tester.tap(toggleAllToUncompletedFinder);
      await tester.pump();
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(4));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('3 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
    },
  );

  testWidgets(
    'Delete todos',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(4));
      expect(checkedToggleAllFinder, findsNWidgets(0));
      expect(find.text('3 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.drag(unCheckedBoxFinder.at(1), const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(2));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(3));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('2 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.drag(unCheckedBoxFinder.at(1), const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(1));
      expect(checkedBoxFinder, findsNWidgets(0));
      expect(unCheckedBoxFinder, findsNWidgets(2));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('1 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.drag(unCheckedBoxFinder.at(1), const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(0));
      expect(checkedBoxFinder, findsNWidgets(1));
      expect(unCheckedBoxFinder, findsNWidgets(0));
      expect(checkedToggleAllFinder, findsOneWidget);
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
    },
  );

  testWidgets(
    'Update todo',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(find.text('hi'), findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
      expect(find.text('bonjour'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      //
      await tester.tap(find.text('hello'));
      await tester.pump();
      expect(find.byType(TextField), findsNWidgets(2));
      //
      await tester.enterText(find.byType(TextField).at(1), 'hello world');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(find.text('hi'), findsOneWidget);
      expect(find.text('hello'), findsNothing);
      expect(find.text('hello world'), findsOneWidget);
      expect(find.text('bonjour'), findsOneWidget);
    },
  );
}
