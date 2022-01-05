import 'package:ex002_00_async_global_and_local_state/ex_001_00_async_counter_app_with_user_defined_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MyRepositoryMock implements MyRepository {
  final Exception? exception;
  MyRepositoryMock({
    this.exception,
  });
  @override
  Future<int> incrementAsync(int data) async {
    await Future.delayed(const Duration(seconds: 1));
    if (exception != null) {
      throw exception!;
    }
    return data + 1;
  }
}

void main() {
  setUp(() {
    // Put your mocks inside setUp method
    myRepository.injectMock(() => MyRepositoryMock());
  });
  testWidgets('Counter increments without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
        find.text('You have pushed the button this many times:'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets(
    'Counter increments with error',
    (WidgetTester tester) async {
      // Override the default mock for this particular test
      myRepository.injectMock(
        () => MyRepositoryMock(
          exception: Exception('Some exception'),
        ),
      );

      await tester.pumpWidget(const MyApp());
      expect(find.text('0'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('You have pushed the button this many times:'),
          findsNothing);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('0'), findsNothing);
      expect(find.text('Some exception'), findsOneWidget);
    },
  );

  testWidgets('Counter refresh without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('You have pushed the button this many times:'),
        findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets(
    'Counter refresh with error',
    (WidgetTester tester) async {
      // Override the default mock for this particular test
      myRepository.injectMock(
        () => MyRepositoryMock(
          exception: Exception('Some exception'),
        ),
      );

      await tester.pumpWidget(const MyApp());
      expect(find.text('0'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('You have pushed the button this many times:'),
          findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Some exception'), findsNothing);
    },
  );

  testWidgets('Counter refresh and increment without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('You have pushed the button this many times:'),
        findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
        find.text('You have pushed the button this many times:'), findsNothing);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('1'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('1'), findsOneWidget);
  });
}
