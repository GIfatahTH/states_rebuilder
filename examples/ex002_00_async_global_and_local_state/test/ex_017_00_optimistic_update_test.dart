import 'package:ex002_00_async_global_and_local_state/ex_017_00_optimistic_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class TodosRepositoryMock extends Mock implements TodosRepository {}

void main() {
  final todosRepositoryMock = TodosRepositoryMock();
  setUp(() {
    todosRepository.injectMock(() => todosRepositoryMock);
    registerFallbackValue(Todo(description: '', id: null));
  });
  when(() => todosRepositoryMock.getTodos()).thenAnswer(
    (_) => Future.delayed(
      const Duration(seconds: 1),
      () => [
        Todo(description: 'todo1', id: 'todo1'),
        Todo(description: 'todo2', id: 'todo2'),
      ],
    ),
  );

  testWidgets(
    'Add todo pessimistically without error',
    (tester) async {
      when(() => todosRepositoryMock.addTodo(
            captureAny(
                that: isA<Todo>().having((t) => t.description, '', 'todo3')),
          )).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => Todo(description: 'todo3', id: 'todo3'),
        ),
      );
      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(TodoItem), findsNWidgets(2));
      //
      await tester.enterText(find.byType(TextField), 'todo3');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(TodoItem), findsNWidgets(3));
      //
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(TodoItem), findsNWidgets(3));
    },
  );

  testWidgets(
    'Add todo pessimistically with error',
    (tester) async {
      when(() => todosRepositoryMock.addTodo(
            captureAny(
                that: isA<Todo>().having((t) => t.description, '', 'todo3')),
          )).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => throw Exception('Adding failed'),
        ),
      );

      await tester.pumpWidget(const MyApp());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(TodoItem), findsNWidgets(2));
      //
      await tester.enterText(find.byType(TextField), 'todo3');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(TodoItem), findsNWidgets(3));
      //
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(TodoItem), findsNWidgets(2));
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Adding failed'), findsOneWidget);
    },
  );
}
