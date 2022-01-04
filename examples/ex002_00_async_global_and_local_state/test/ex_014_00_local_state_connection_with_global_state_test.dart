import 'package:ex002_00_async_global_and_local_state/ex_014_00_local_state_connection_with_global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final checkedBox = find.byWidgetPredicate(
    (widget) => widget is Checkbox && widget.value == true,
  );

  testWidgets(
    'Add Todo',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(TodoItem), findsNWidgets(3));
      expect(checkedBox, findsNothing);
      //
      await tester.enterText(find.byType(TextField), 'New Todo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(TodoItem), findsNWidgets(4));
      expect(checkedBox, findsNothing);
      expect(find.text('New Todo'), findsOneWidget);
      expect(todosViewModel.todos.length, 4);
    },
  );
  testWidgets(
    'Check todos',
    (tester) async {
      int getCompletedTodos() =>
          todosViewModel.todos.where((e) => e.completed).length;
      await tester.pumpWidget(const MyApp());
      expect(find.byType(TodoItem), findsNWidgets(3));
      expect(checkedBox, findsNothing);
      expect(getCompletedTodos(), 0);
      //
      // check the last todo
      await tester.tap(find.byType(Checkbox).at(3));
      await tester.pump();
      expect(checkedBox, findsOneWidget);
      expect(getCompletedTodos(), 1);
      // check the first todo
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();
      expect(checkedBox, findsNWidgets(2));
      expect(getCompletedTodos(), 2);
      //
      // check the second todo
      await tester.tap(find.byType(Checkbox).at(2));
      await tester.pump();
      expect(checkedBox, findsNWidgets(4)); // three todos + toggle all
      expect(getCompletedTodos(), 3);
      //
      // check the toggle
      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pump();
      expect(checkedBox, findsNWidgets(0));
      expect(getCompletedTodos(), 0);
      // check the toggle
      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pump();
      expect(checkedBox, findsNWidgets(4));
      expect(getCompletedTodos(), 3);
    },
  );
}
