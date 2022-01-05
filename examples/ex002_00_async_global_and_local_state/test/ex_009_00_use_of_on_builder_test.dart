import 'package:ex002_00_async_global_and_local_state/ex_009_00_use_of_on_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements MyRepository {}

void main() {
  final mockRepository = MockRepository();
  setUp(() {
    myRepository.injectMock(() => mockRepository);
  });
  when(() => mockRepository.incrementAsync(0)).thenAnswer(
    (invocation) => Future.delayed(const Duration(seconds: 1), () => 1),
  );
  when(() => mockRepository.incrementAsync(1)).thenAnswer(
    (invocation) => Future.delayed(const Duration(seconds: 1), () => 2),
  );

  testWidgets(
    'WHEN autoDispose is true'
    'THEN the state is disposed when not used',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Go to counter view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to counter view'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
    },
  );
}
