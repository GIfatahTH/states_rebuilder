import 'package:ex005_00_crud_operations/ex_001_crud_app_using_injected_crud/app.dart';
import 'package:ex005_00_crud_operations/ex_001_crud_app_using_injected_crud/blocs/todos_bloc.dart';
import 'package:ex005_00_crud_operations/ex_001_crud_app_using_injected_crud/models/todo.dart';
import 'package:ex005_00_crud_operations/ex_001_crud_app_using_injected_crud/ui/todos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Using injectedMock',
    (tester) async {
      todosViewModel().injectMock(
        () => List.generate(
          10,
          (i) => Todo(
            id: '$i',
            description: 'Description $i',
            completed: i % 3 == 0,
          ),
        ),
      );
      await tester.pumpWidget(const MyApp());
      expect(find.byType(TodoItemWidget), findsNWidgets(10));
    },
  );

  testWidgets(
    'Using injectFutureMock',
    (tester) async {
      todosViewModel().injectFutureMock(
        () async {
          await Future.delayed(const Duration(seconds: 3));
          return List.generate(
            10,
            (i) => Todo(
              id: '$i',
              description: 'Description $i',
              completed: i % 3 == 0,
            ),
          );
        },
      );
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(TodoItemWidget), findsNWidgets(0));
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(TodoItemWidget), findsNWidgets(10));
    },
  );
}
