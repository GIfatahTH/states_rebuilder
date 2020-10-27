import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/injected.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/domain/entities/user.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/ui/pages/home_screen/home_screen.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/ui/pages/home_screen/todo_item.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/ui/pages/home_screen/todo_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/app.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todos_app_core/todos_app_core.dart';

import 'fake_auth_repository.dart';
import 'fake_todo_repository.dart';

/// Demonstrates how to test Widgets
void main() {
  final todoListFinder = find.byKey(ArchSampleKeys.todoList);
  final todoItem1Finder = find.byKey(ArchSampleKeys.todoItem('user1-1'));
  final todoItem2Finder = find.byKey(ArchSampleKeys.todoItem('user1-2'));
  final todoItem3Finder = find.byKey(ArchSampleKeys.todoItem('user1-3'));

  authRepository.injectMock(
    () => FakeAuthRepository(
      currentUser: User(
        uid: 'user1',
        displayName: 'user1',
        email: 'user1@email',
      ),
    ),
  );
  todosRepository.injectComputedMock(
    compute: (_) => FakeTodosRepository(user: authState.state.user),
  );

  group('HomeScreen', () {
    testWidgets(
        'should render loading indicator at first then render HomeScreen',
        (tester) async {
      await tester.pumpWidget(App());
      await tester.pump(Duration.zero);
      // expect(find.byType(AuthScreen), findsOneWidget);
      // await tester.pump();
      expect(find.byKey(ArchSampleKeys.todosLoading), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should display a list after loading todos', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(TodoList), findsOneWidget);
      //
      final checkbox1 = find.descendant(
        of: find.byKey(ArchSampleKeys.todoItemCheckbox('user1-1')),
        matching: find.byType(Focus),
      );
      final checkbox2 = find.descendant(
        of: find.byKey(ArchSampleKeys.todoItemCheckbox('user1-2')),
        matching: find.byType(Focus),
      );
      final checkbox3 = find.descendant(
        of: find.byKey(ArchSampleKeys.todoItemCheckbox('user1-3')),
        matching: find.byType(Focus),
      );

      expect(todoListFinder, findsOneWidget);
      expect(todoItem1Finder, findsOneWidget);
      expect(find.text('Task1'), findsOneWidget);
      expect(find.text('Note1'), findsOneWidget);
      expect(tester.getSemantics(checkbox1), isChecked(false));
      expect(todoItem2Finder, findsOneWidget);
      expect(find.text('Task2'), findsOneWidget);
      expect(find.text('Note2'), findsOneWidget);
      expect(tester.getSemantics(checkbox2), isChecked(false));
      expect(todoItem3Finder, findsOneWidget);
      expect(find.text('Task3'), findsOneWidget);
      expect(find.text('Note3'), findsOneWidget);
      expect(tester.getSemantics(checkbox3), isChecked(true));

      handle.dispose();
    });

    testWidgets('should remove todos using a dismissible', (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.drag(todoItem1Finder, Offset(-1000, 0));
      await tester.pumpAndSettle();

      expect(todoItem1Finder, findsNothing);
      expect(todoItem2Finder, findsOneWidget);
      expect(todoItem3Finder, findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets(
        'should remove todos using a dismissible and insert back the removed element if throws',
        (tester) async {
      todosRepository.injectComputedMock(
        compute: (_) =>
            FakeTodosRepository(user: authState.state.user, throwError: true),
      );

      await tester.pumpWidget(App());

      await tester.pumpAndSettle();
      await tester.drag(todoItem1Finder, Offset(-1000, 0));
      await tester.pumpAndSettle();

      //Removed item in inserted back to the list
      expect(todoItem1Finder, findsOneWidget);
      expect(todoItem2Finder, findsOneWidget);
      expect(todoItem3Finder, findsOneWidget);
      //SnackBar with error message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('There is a problem in saving todos'), findsOneWidget);
    });

    testWidgets('should display stats when switching tabs', (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ArchSampleKeys.statsTab));
      await tester.pump();

      expect(find.byKey(ArchSampleKeys.statsNumActive), findsOneWidget);
      expect(find.byKey(ArchSampleKeys.statsNumActive), findsOneWidget);
    });

    testWidgets('should toggle a todo', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      final checkbox1 = find.descendant(
        of: find.byKey(ArchSampleKeys.todoItemCheckbox('user1-1')),
        matching: find.byType(Focus),
      );
      expect(tester.getSemantics(checkbox1), isChecked(false));

      await tester.tap(checkbox1);
      await tester.pump();
      expect(tester.getSemantics(checkbox1), isChecked(true));

      await tester.pumpAndSettle();
      handle.dispose();
    });

    testWidgets('should toggle a todo and toggle back if throws',
        (tester) async {
      todosRepository.injectComputedMock(
        compute: (_) =>
            FakeTodosRepository(user: authState.state.user, throwError: true),
      );

      final handle = tester.ensureSemantics();
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      final checkbox1 = find.descendant(
        of: find.byKey(ArchSampleKeys.todoItemCheckbox('user1-1')),
        matching: find.byType(Focus),
      );
      expect(tester.getSemantics(checkbox1), isChecked(false));

      await tester.tap(checkbox1);
      await tester.pump();

      expect(tester.getSemantics(checkbox1), isChecked(true));
      //NO Error,
      expect(find.byType(SnackBar), findsNothing);

      //
      await tester.pumpAndSettle();
      expect(tester.getSemantics(checkbox1), isChecked(false));

      //SnackBar with error message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('There is a problem in saving todos'), findsOneWidget);
      handle.dispose();
    });
  });
  group('delete from detailed screen', () {
    testWidgets('delete item from the detailed screen', (tester) async {
      await tester.pumpWidget(App());

      await tester.pumpAndSettle();
      //expect to see three Todo items
      expect(find.byType(TodoItem), findsNWidgets(3));

      //tap to navigate to detail screen
      await tester.tap(todoItem1Finder);
      await tester.pumpAndSettle();

      //expect we are in the detailed screen
      expect(find.byKey(ArchSampleKeys.todoDetailsScreen), findsOneWidget);

      //
      await tester.tap(find.byKey(ArchSampleKeys.deleteTodoButton));
      await tester.pumpAndSettle();

      //expect we are back in the home screen
      expect(find.byKey(ArchSampleKeys.todoList), findsOneWidget);
      await tester.pumpAndSettle();

      //expect to see two Todo items
      expect(find.byType(TodoItem), findsNWidgets(2));
      //expect to see a SnackBar to reinsert the deleted todo
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      //reinsert the deleted todo
      await tester.tap(find.byType(SnackBarAction));
      await tester.pump();
      //expect to see three Todo items
      expect(find.byType(TodoItem), findsNWidgets(3));
      await tester.pumpAndSettle();
    });

    testWidgets('delete item from the detailed screen and reinsert it on error',
        (tester) async {
      todosRepository.injectComputedMock(
        compute: (_) => FakeTodosRepository(
          user: authState.state.user,
          throwError: true,
          delay: 500,
        ),
      );

      await tester.pumpWidget(App());

      await tester.pumpAndSettle();

      //tap to navigate to detail screen
      await tester.tap(todoItem1Finder);
      await tester.pumpAndSettle();

      //
      await tester.tap(find.byKey(ArchSampleKeys.deleteTodoButton));
      await tester.pump();
      expect(find.byKey(Key('todo_StateBuilder')), findsOneWidget);

      //expect we are back in the home screen
      expect(find.byKey(ArchSampleKeys.todoList), findsOneWidget);

      //expect to see two Todo items
      expect(find.byType(TodoItem), findsNWidgets(2));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      //
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byType(TodoItem), findsNWidgets(3));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('There is a problem in saving todos'), findsOneWidget);
    });
  });
}

Matcher isChecked(bool isChecked) {
  return matchesSemantics(
    isChecked: isChecked,
    hasCheckedState: true,
    hasEnabledState: true,
    isEnabled: true,
    isFocusable: true,
    hasTapAction: true,
  );
}
