import 'package:ex005_00_crud_operations/ex_000_crud_app_using_core_state_management/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ex005_00_crud_operations/ex_000_crud_app_using_core_state_management/blocs/todos_bloc.dart';
import 'package:ex005_00_crud_operations/ex_000_crud_app_using_core_state_management/data_source/todos_fake_repository.dart';
import 'package:ex005_00_crud_operations/ex_000_crud_app_using_core_state_management/ui/todos_page.dart';

void main() {
  setUp(() {
    todosRepository.injectMock(() => TodosFakeRepository());
  });

  final checkedItemFinder = find.descendant(
    of: find.byType(Column),
    matching: find.byWidgetPredicate(
      (widget) => widget is Checkbox && widget.value == true,
    ),
  );
  final unCheckedItemFinder = find.descendant(
    of: find.byType(Column),
    matching: find.byWidgetPredicate(
      (widget) => widget is Checkbox && widget.value != true,
    ),
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
    'WHEN app starts '
    'THEN it will display CircularProgressIndicator while looking for todos '
    'from repository '
    'AND it will display 5 TodoItemWidget; 3 of them checked, after getting todos'
    'CASE without error',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
    },
  );
  testWidgets(
    'WHEN app starts '
    'THEN it will display CircularProgressIndicator while looking for todos '
    'from repository '
    'AND display error message with refresh button after fetching failure '
    'AND WHEN error is refreshed '
    'THEN todos are re-fetched',
    (tester) async {
      bool shouldThrow = true;
      todosRepository.injectMock(
        () => TodosFakeRepository(
          shouldThrowExceptions: () => shouldThrow,
        ),
      );
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Fetch Todo failure'), findsOneWidget);
      //
      // Refreshing the error
      shouldThrow = false; // do not throw an error
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
    },
  );

  testWidgets(
    'Filter todos',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
      //
      await tester.tap(find.text('Active'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(2));
      expect(checkedItemFinder, findsNWidgets(0));
      //
      await tester.tap(find.text('Completed'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedItemFinder, findsNWidgets(3));
      //
      await tester.tap(find.text('All'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
      //
      //
      await tester.tap(find.text('Completed'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedItemFinder, findsNWidgets(3));
      //
      await tester.tap(checkedItemFinder.first);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(2));
      expect(checkedItemFinder, findsNWidgets(2));
      await tester.tap(checkedItemFinder.first);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(1));
      expect(checkedItemFinder, findsNWidgets(1));
      await tester.tap(checkedItemFinder.first);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(0));
      expect(checkedItemFinder, findsNWidgets(0));
      //
      await tester.tap(find.text('Active'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(0));
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets(
    'Add todo',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
      //
      await tester.enterText(find.byType(TextField), 'new Todo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(6));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(find.text('new Todo'), findsOneWidget);
      //
      await tester.tap(find.text('Active'));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(3));
      expect(checkedItemFinder, findsNWidgets(0));
      //
      await tester.enterText(find.byType(TextField), 'new Todo1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(4));
      expect(find.text('new Todo1'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets(
    'Add todo with error',
    (tester) async {
      bool shouldThrow = false;
      todosRepository.injectMock(
        () => TodosFakeRepository(
          shouldThrowExceptions: () => shouldThrow,
        ),
      );
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
      //
      shouldThrow = true;
      await tester.enterText(find.byType(TextField), 'new Todo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(6));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(find.text('new Todo'), findsOneWidget);
      //
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(find.text('new Todo'), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      //
      shouldThrow = false;
      await tester.tap(find.byType(SnackBarAction));
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(6));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(find.text('new Todo'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(find.text('new Todo'), findsOneWidget);
    },
  );
  testWidgets(
    'Check todo',
    (tester) async {
      bool shouldThrow = false;
      todosRepository.injectMock(
        () => TodosFakeRepository(
          shouldThrowExceptions: () {
            return shouldThrow;
          },
        ),
      );
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(2));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('2 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.tap(unCheckedItemFinder.first);
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(4));
      expect(unCheckedItemFinder, findsNWidgets(1));
      expect(find.text('1 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.tap(unCheckedItemFinder.first);
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(5));
      expect(unCheckedItemFinder, findsNWidgets(0));
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
      //
      await tester.enterText(find.byType(TextField), 'new Todo');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(5));
      expect(unCheckedItemFinder, findsNWidgets(1));
      expect(find.text('1 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1000));
      //
      await tester.drag(checkedItemFinder.first, const Offset(0, -200));
      await tester.pumpAndSettle();
      shouldThrow = true;
      await tester.tap(unCheckedItemFinder.first);
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(6));
      expect(unCheckedItemFinder, findsNWidgets(0));
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(5));
      expect(unCheckedItemFinder, findsNWidgets(1));
      expect(find.text('1 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      shouldThrow = false;
      await tester.tap(find.byType(SnackBarAction));
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(6));
      expect(unCheckedItemFinder, findsNWidgets(0));
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(checkedItemFinder, findsNWidgets(6));
      expect(unCheckedItemFinder, findsNWidgets(0));
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
    },
  );

  testWidgets(
    'Toggle all todos without error',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(2));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('2 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.tap(toggleAllToCompletedFinder);
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(5));
      expect(unCheckedItemFinder, findsNWidgets(0));
      expect(checkedToggleAllFinder, findsOneWidget);
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
      //
      await tester.tap(toggleAllToUncompletedFinder);
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(0));
      expect(unCheckedItemFinder, findsNWidgets(5));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('5 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.pump(const Duration(milliseconds: 600));
    },
  );

  testWidgets(
    'Toggle all todos with error',
    (tester) async {
      bool shouldThrow = false;
      todosRepository.injectMock(
        () => TodosFakeRepository(
          shouldThrowExceptions: () {
            return shouldThrow;
          },
        ),
      );
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(2));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('2 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      shouldThrow = true;
      await tester.tap(toggleAllToCompletedFinder);
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(5));
      expect(unCheckedItemFinder, findsNWidgets(0));
      expect(checkedToggleAllFinder, findsOneWidget);
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
      //
      await tester.pump(const Duration(milliseconds: 600));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(2));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('2 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      //
      shouldThrow = false;
      await tester.tap(find.byType(SnackBarAction));
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(5));
      expect(unCheckedItemFinder, findsNWidgets(0));
      expect(checkedToggleAllFinder, findsOneWidget);
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(checkedItemFinder, findsNWidgets(5));
      expect(unCheckedItemFinder, findsNWidgets(0));
      expect(checkedToggleAllFinder, findsOneWidget);
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
    },
  );
  testWidgets(
    'Delete todos without error',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(2));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('2 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.drag(unCheckedItemFinder.first, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(1));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('1 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      await tester.drag(unCheckedItemFinder.first, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(0));
      expect(checkedToggleAllFinder, findsOneWidget);
      expect(find.text('0 items left'), findsOneWidget);
      expect(toggleAllToUncompletedFinder, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      // Toggle all todos after deleting some of them
      await tester.tap(toggleAllToUncompletedFinder);
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(0));
      expect(unCheckedItemFinder, findsNWidgets(3));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('3 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
    },
  );

  testWidgets(
    'Delete todos with error',
    (tester) async {
      bool shouldThrow = false;
      todosRepository.injectMock(
        () => TodosFakeRepository(
          shouldThrowExceptions: () {
            return shouldThrow;
          },
        ),
      );
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(2));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('2 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      //
      shouldThrow = true;
      await tester.drag(unCheckedItemFinder.first, const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(1));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('1 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(2));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('2 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      //
      shouldThrow = false;
      await tester.tap(find.byType(SnackBarAction));
      await tester.pump();
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(1));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('1 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(checkedItemFinder, findsNWidgets(3));
      expect(unCheckedItemFinder, findsNWidgets(1));
      expect(checkedToggleAllFinder, findsNothing);
      expect(find.text('1 items left'), findsOneWidget);
      expect(toggleAllToCompletedFinder, findsOneWidget);
    },
  );

  testWidgets(
    'Update todo without error',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(find.text('description of todo 0'), findsOneWidget);
      expect(find.text('description of todo 1'), findsOneWidget);
      expect(find.text('description of todo 2'), findsOneWidget);
      expect(find.text('description of todo 3'), findsOneWidget);
      expect(find.text('description of todo 4'), findsOneWidget);
      expect(
          todosViewModel.filteredTodos[2].description, 'description of todo 2');

      expect(find.byType(TextField), findsOneWidget);
      //
      await tester.tap(find.text('description of todo 2'));
      await tester.pump();
      expect(find.byType(TextField), findsNWidgets(2));
      //
      await tester.enterText(find.byType(TextField).at(1), 'hello world');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(find.text('description of todo 0'), findsOneWidget);
      expect(find.text('description of todo 1'), findsOneWidget);
      expect(find.text('hello world'), findsOneWidget);
      expect(find.text('description of todo 3'), findsOneWidget);
      expect(find.text('description of todo 4'), findsOneWidget);
      expect(todosViewModel.filteredTodos[2].description, 'hello world');
      await tester.pump(const Duration(milliseconds: 600));
    },
  );

  testWidgets(
    'Update todo with error',
    (tester) async {
      bool shouldThrow = false;
      todosRepository.injectMock(
        () => TodosFakeRepository(
          shouldThrowExceptions: () {
            return shouldThrow;
          },
        ),
      );
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(find.text('description of todo 0'), findsOneWidget);
      expect(find.text('description of todo 1'), findsOneWidget);
      expect(find.text('description of todo 2'), findsOneWidget);
      expect(find.text('description of todo 3'), findsOneWidget);
      expect(find.text('description of todo 4'), findsOneWidget);
      expect(
          todosViewModel.filteredTodos[2].description, 'description of todo 2');

      expect(find.byType(TextField), findsOneWidget);
      //
      await tester.tap(find.text('description of todo 2'));
      await tester.pump();
      expect(find.byType(TextField), findsNWidgets(2));
      //
      shouldThrow = true;
      await tester.enterText(find.byType(TextField).at(1), 'hello world');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(find.text('description of todo 0'), findsOneWidget);
      expect(find.text('description of todo 1'), findsOneWidget);
      expect(find.text('hello world'), findsOneWidget);
      expect(find.text('description of todo 3'), findsOneWidget);
      expect(find.text('description of todo 4'), findsOneWidget);
      expect(todosViewModel.filteredTodos[2].description, 'hello world');
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(TodoItemWidget), findsNWidgets(5));
      expect(find.text('description of todo 0'), findsOneWidget);
      expect(find.text('description of todo 1'), findsOneWidget);
      expect(find.text('description of todo 2'), findsOneWidget);
      expect(find.text('description of todo 3'), findsOneWidget);
      expect(find.text('description of todo 4'), findsOneWidget);
      expect(
          todosViewModel.filteredTodos[2].description, 'description of todo 2');
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      shouldThrow = false;
      await tester.tap(find.byType(SnackBarAction));
      await tester.pump();
      expect(find.text('description of todo 0'), findsOneWidget);
      expect(find.text('description of todo 1'), findsOneWidget);
      expect(find.text('hello world'), findsOneWidget);
      expect(find.text('description of todo 3'), findsOneWidget);
      expect(find.text('description of todo 4'), findsOneWidget);
      expect(todosViewModel.filteredTodos[2].description, 'hello world');
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('description of todo 0'), findsOneWidget);
      expect(find.text('description of todo 1'), findsOneWidget);
      expect(find.text('hello world'), findsOneWidget);
      expect(find.text('description of todo 3'), findsOneWidget);
      expect(find.text('description of todo 4'), findsOneWidget);
      expect(todosViewModel.filteredTodos[2].description, 'hello world');
    },
  );
}
