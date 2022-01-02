import 'package:ex002_00_async_global_and_local_state/ex_007_00_plugins_intialization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class SemBastLocalStorageMock extends Mock implements SemBastLocalStorage {}

void main() {
  final semBastLocalStorageMock = SemBastLocalStorageMock();
  setUp(() {
    // Even if semBastLocalStorageRM is an injected using RM.injectFuture, we
    // can mock is as a simple Injected state
    //
    // As we want to test HomePage only we pretend as semBastLocalStorageRM is
    // already initialized
    semBastLocalStorageRM.injectMock(() => semBastLocalStorageMock);
  });

  testWidgets(
    'Test HomePage',
    (tester) async {
      when(() => semBastLocalStorageMock.write('key', 'a data'))
          .thenAnswer((_) => Future.value());
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );
      await tester.enterText(find.byType(TextField), 'a data');
      await tester.tap(find.byType(TextButton));
      await tester.pump();
      verify(() => semBastLocalStorageMock.write('key', 'a data')).called(1);
      //
      when(() => semBastLocalStorageMock.read('key'))
          .thenAnswer((_) => Future<String>.value('a data'));
      //
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('a data'), findsNWidgets(2));
    },
  );
}
