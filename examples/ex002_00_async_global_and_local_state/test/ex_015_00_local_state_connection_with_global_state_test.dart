import 'package:ex002_00_async_global_and_local_state/ex_015_00_local_state_connection_with_global_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final todoItemHome1 = find.descendant(
    of: find.byType(Home).first,
    matching: find.byType(TodoItem),
  );
  final todoItemHome2 = find.descendant(
    of: find.byType(Home).last,
    matching: find.byType(TodoItem),
  );

  testWidgets(
    'Add Todo to global todoViewModel',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(todoItemHome1, findsNWidgets(1));
      expect(todoItemHome2, findsNWidgets(1));

      //
      await tester.enterText(find.byType(TextField).first, 'New Todo 1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(todoItemHome1, findsNWidgets(2));
      expect(todoItemHome2, findsNWidgets(1));

      expect(find.text('New Todo 1'), findsOneWidget);
      expect(todosViewModel.state.todos.length, 2);
      //
      //
      await tester.enterText(find.byType(TextField).last, 'New Todo 2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(todoItemHome1, findsNWidgets(2));
      expect(todoItemHome2, findsNWidgets(2));

      expect(find.text('New Todo 1'), findsOneWidget);
      expect(find.text('New Todo 2'), findsOneWidget);
      expect(todosViewModel.state.todos.length, 2);
    },
  );
}
