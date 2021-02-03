import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todo_mvc_the_flutter_bloc_way/injected.dart';
import 'package:todo_mvc_the_flutter_bloc_way/run_app.dart';
import 'package:todo_mvc_the_flutter_bloc_way/widgets/widgets.dart';
import 'package:todos_app_core/todos_app_core.dart';

import 'fake_repository.dart';

void main() {
  todosRepository = RM.inject(() => FakeRepository());

  final todoItem1Finder = find.byKey(ArchSampleKeys.todoItem('1'));

  testWidgets('delete item from the detailed screen', (tester) async {
    await tester.pumpWidget(TodosApp());

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
}
