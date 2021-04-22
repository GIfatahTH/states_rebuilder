import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/common/extensions.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/entities/user.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/value_object/token.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/main.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/service/exceptions/persistance_exception.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/pages/add_edit_screen.dart/add_edit_screen.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/pages/detail_screen/detail_screen.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/pages/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'fake_todos_repository.dart';

void main() async {
  final storage = await RM.storageInitializerMock();

  setUp(
    () {
      todos.injectCRUDMock(() => FakeTodosRepository());
      DateTimeX.customNow = DateTime(2020);
      storage.clear();
      //auto log with _user12;
      storage.store.addAll({
        '__UserToken__': _user2,
      });
    },
  );
  testWidgets('Start with zero todo', (tester) async {
    storage.store.addAll({
      '__UserToken__': _user1,
    });
    await tester.pumpWidget(App());
    expect(find.byType(TodoItem), findsNothing);
  });

  testWidgets('Start with some stored todos', (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(TodoItem), findsNWidgets(3));
  });

  testWidgets('add todo', (tester) async {
    storage.store.addAll({
      '__UserToken__': _user1,
    });
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    //No todos
    expect(find.byType(TodoItem), findsNothing);
    //Tap on FloatingActionButton to add a todo
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    //We are in the AddEditPage
    expect(find.byType(AddEditPage), findsOneWidget);
    //
    //Enter some text
    await tester.enterText(find.byKey(Key('__TaskField')), 'Task1');
    await tester.enterText(find.byKey(Key('__NoteField')), 'Note1');
    //
    //Tap on FloatingActionButton to add  the todo
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    //We are back in the HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
    //And a todo is displayed
    expect(find.byType(TodoItem), findsOneWidget);
    // await tester.pump(Duration(seconds: 1));

    final storedTodos =
        todos.getRepoAs<FakeTodosRepository>().todos['__Todos__/user1'].first;
    expect(storedTodos.task, 'Task1');
    expect(storedTodos.note, 'Note1');
  });
  testWidgets('Remove todo using a dismissible and undo', (tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    //Start with three todos
    expect(find.byType(TodoItem), findsNWidgets(3));

    final repo = todos.getRepoAs<FakeTodosRepository>();
    expect(repo.todos['__Todos__/user2'].length, 3);
    expect(repo.todos['__Todos__/user2'][1].task, 'Task2');
    expect(repo.todos['__Todos__/user2'][1].note, 'Note2');

    //Dismiss the second todo
    await tester.drag(find.text('Note2'), Offset(-1000, 0));
    await tester.pumpAndSettle();
    //
    //the second todo is removed
    expect(find.text('Note2'), findsNothing);
    expect(find.byType(TodoItem), findsNWidgets(2));
    //The new state is persisted
    expect(repo.todos['__Todos__/user2'].length, 2);
    expect(repo.todos['__Todos__/user2'][1].task, 'Task3');
    expect(repo.todos['__Todos__/user2'][1].note, 'Note3');

    //A SnackBar is displayed with undo button
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    //
    //tap undo to restore the removed todo
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(find.byType(TodoItem), findsNWidgets(3));
    expect(repo.todos['__Todos__/user2'].length, 3);
    expect(repo.todos['__Todos__/user2'][2].task, 'Task2');
    expect(repo.todos['__Todos__/user2'][2].note, 'Note2');
  });

  testWidgets(
    'Remove todo using a dismissible and undo if persistance fails',
    (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      //Start with three todos
      expect(find.byType(TodoItem), findsNWidgets(3));

      //
      //Set the mocked store to throw PersistanceException after one seconds,
      //when writing to the store
      final repo = todos.getRepoAs<FakeTodosRepository>();
      repo.error = PersistanceException('mock message');
      storage.timeToThrow = 1000;
      //Dismiss the second todo
      await tester.drag(find.text('Note2'), Offset(-1000, 0));
      await tester.pumpAndSettle();
      //
      //the second todo is removed
      expect(find.text('Note2'), findsNothing);
      expect(find.byType(TodoItem), findsNWidgets(2));

      //A SnackBar is displayed with undo button
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      //
      //After one seconds
      await tester.pumpAndSettle(Duration(seconds: 1));
      //The second todo is displayed back
      expect(find.text('Note2'), findsOneWidget);
      expect(find.byType(TodoItem), findsNWidgets(3));
      //A SnackBar with error is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    },
  );

  testWidgets(
    'should toggle a todo form home and from DetailScreen',
    (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      //
      final checkedCheckBox = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      );
      final unCheckedCheckBox = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == false,
      );

      expect(checkedCheckBox, findsNWidgets(1));
      expect(unCheckedCheckBox, findsNWidgets(2));

      //Check the first todo
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(checkedCheckBox, findsNWidgets(2));
      expect(unCheckedCheckBox, findsNWidgets(1));
      //
      //to on the first todo to go to detailed page
      await tester.tap(find.byType(TodoItem).first);
      await tester.pumpAndSettle();
      //We are in the DetailScreen
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(checkedCheckBox, findsNWidgets(1));
      expect(unCheckedCheckBox, findsNWidgets(0));
      //toggle the todo in the detailed screen
      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      //It is unchecked
      expect(checkedCheckBox, findsNWidgets(0));
      expect(unCheckedCheckBox, findsNWidgets(1));
      //
      //Back to the home screen
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      //it is updated
      expect(checkedCheckBox, findsNWidgets(1));
      expect(unCheckedCheckBox, findsNWidgets(2));

      final repo = todos.getRepoAs<FakeTodosRepository>();
      expect(repo.todos['__Todos__/user2'][0].task, 'Task1');
      expect(repo.todos['__Todos__/user2'][0].complete, true);
      await tester.pump(Duration(seconds: 1));
      expect(repo.todos['__Todos__/user2'][0].complete, false);
    },
  );

  testWidgets(
    'should Remove a todo form  DetailScreen',
    (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byType(TodoItem), findsNWidgets(3));

      //to on the first todo to go to detailed page
      await tester.tap(find.byType(TodoItem).first);
      await tester.pumpAndSettle();
      //We are in the DetailScreen
      expect(find.byType(DetailScreen), findsOneWidget);
      //tap on the delete icon
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      expect(find.byType(TodoItem), findsNWidgets(2));
      //A SnackBar is displayed with undo button
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
    },
  );

  testWidgets(
    'should edit a todo',
    (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byType(TodoItem), findsNWidgets(3));

      //to on the first todo to go to detailed page
      await tester.tap(find.text('Note1').first);
      await tester.pumpAndSettle();
      //We are in the DetailScreen
      expect(find.byType(DetailScreen), findsOneWidget);
      //top on FloatingActionButton to edit todo
      await tester.tap(find.byType(FloatingActionButton).first);
      await tester.pumpAndSettle();
      expect(find.byType(AddEditPage), findsOneWidget);
      //
      //Enter some text
      await tester.enterText(find.byKey(Key('__TaskField')), 'New Task 1');
      await tester.enterText(find.byKey(Key('__NoteField')), 'New Note 1');
      //
      //Tap on FloatingActionButton to submit  the todo
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      //It is updated
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('New Task 1'), findsOneWidget);
      //Navigate to home screen
      RM.navigate.back();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      //it is updated
      expect(find.text('New Task 1'), findsOneWidget);
    },
  );
  testWidgets(
    'Show filter todos: all, active and completed todos',
    (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      //
      final checkedCheckBox = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      );
      final unCheckedCheckBox = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == false,
      );

      expect(checkedCheckBox, findsNWidgets(1));
      expect(unCheckedCheckBox, findsNWidgets(2));

      //Top to filter active todos
      await tester.tap(find.byType(FilterButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('__Filter_Active__')));
      await tester.pumpAndSettle();

      //Only active todos are displayed
      expect(checkedCheckBox, findsNWidgets(0));
      expect(unCheckedCheckBox, findsNWidgets(2));
      //
      //Top to filter complete todos
      await tester.tap(find.byType(FilterButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('__Filter_Completed__')));
      await tester.pumpAndSettle();

      //Only completed todos are displayed
      expect(checkedCheckBox, findsNWidgets(1));
      expect(unCheckedCheckBox, findsNWidgets(0));
      //
      //Top to show all todos
      await tester.tap(find.byType(FilterButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('__Filter_All__')));
      await tester.pumpAndSettle();

      //Only completed todos are displayed
      expect(checkedCheckBox, findsNWidgets(1));
      expect(unCheckedCheckBox, findsNWidgets(2));
      //
    },
  );

  testWidgets(
    'toggle all completed / uncompleted',
    (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      //
      final checkedCheckBox = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      );
      final unCheckedCheckBox = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == false,
      );

      expect(checkedCheckBox, findsNWidgets(1));
      expect(unCheckedCheckBox, findsNWidgets(2));

      //Top to toggle all to completed
      await tester.tap(find.byType(ExtraActionsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('__toggleAll__')));
      await tester.pumpAndSettle();

      //
      expect(checkedCheckBox, findsNWidgets(3));
      expect(unCheckedCheckBox, findsNWidgets(0));
      //
      //Toggle all to uncompleted
      await tester.tap(find.byType(ExtraActionsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('__toggleAll__')));
      await tester.pumpAndSettle();

      //Only active todos are displayed
      expect(checkedCheckBox, findsNWidgets(0));
      expect(unCheckedCheckBox, findsNWidgets(3));
      await tester.pump(Duration(seconds: 1));
    },
  );

  testWidgets(
    ' clear completed',
    (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      //
      final checkedCheckBox = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      );
      final unCheckedCheckBox = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == false,
      );

      expect(checkedCheckBox, findsNWidgets(1));
      expect(unCheckedCheckBox, findsNWidgets(2));

      //Top to clear completed
      await tester.tap(find.byType(ExtraActionsButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('__toggleClearCompleted__')));
      await tester.pumpAndSettle();

      //one completed todo is removed
      expect(checkedCheckBox, findsNWidgets(0));
      expect(unCheckedCheckBox, findsNWidgets(2));
    },
  );
}

final _user1 = User(
  userId: 'user1',
  email: 'user1@mail.com',
  token: Token(
    token: 'token_user1',
    expiryDate: DateTimeX.current.add(
      Duration(seconds: 10),
    ),
  ),
).toJson();

final _user2 = User(
  userId: 'user2',
  email: 'user1@mail.com',
  token: Token(
    token: 'token_user1',
    expiryDate: DateTimeX.current.add(
      Duration(seconds: 10),
    ),
  ),
).toJson();
