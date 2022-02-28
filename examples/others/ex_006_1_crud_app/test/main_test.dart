import 'package:ex_006_crud_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_numbers_repository.dart';

void main() {
  setUp(() {
    numbers.injectCRUDMock(() => FakeNumbersRepository());
  });
  testWidgets(
    'App Starts without read error ',
    (tester) async {
      await tester.pumpWidget(App());
      //Waiting for read
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      //
      await tester.pumpAndSettle();
      //Read successfully
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );

  testWidgets(
    'App Starts with read error ',
    (tester) async {
      final repo = numbers.getRepoAs<FakeNumbersRepository>();
      repo.exception = 'Read Error';
      await tester.pumpWidget(App());
      //Waiting for read
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      //
      await tester.pumpAndSettle();
      //Read successfully

      expect(find.text('All: 0    '), findsOneWidget);
      expect(find.text('Odd: 0    '), findsOneWidget);
      expect(find.text('Even: 0    '), findsOneWidget);
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget); //In appBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget); //In snackBar
      //first failed refresh (from appBar)
      await tester.tap(find.byIcon(Icons.refresh_outlined));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      //
      await tester.pumpAndSettle();
      //Read fails
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      //second failed refresh (from snapBar)
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      //
      await tester.pumpAndSettle();
      //Read fails
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      //Read successfully
      repo.exception = null;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pumpAndSettle();
      //Read successfully
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );

  testWidgets(
    'Create item without create error ',
    (tester) async {
      final repo = numbers.getRepoAs<FakeNumbersRepository>();
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      //Read successfully
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      //
      repo.idToCreate = 100;
      DateTimeX.secondFake = 22;
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('Number 22'), findsOneWidget);
      expect(find.text('All: 3    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 2    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );

  testWidgets(
    'Create item with create error ',
    (tester) async {
      final repo = numbers.getRepoAs<FakeNumbersRepository>();
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      //Read successfully
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      //
      repo.idToCreate = 100;
      DateTimeX.secondFake = 22;
      repo.exception = 'Create error';
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      //create fails
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('Number 22'), findsNothing);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      //create fails
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('Number 22'), findsNothing);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.refresh_outlined));
      await tester.pump();
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      //create fails
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('Number 22'), findsNothing);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      //
      repo.exception = null;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      //Create successfully
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('Number 22'), findsOneWidget);
      expect(find.text('All: 3    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 2    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );

  testWidgets(
    'Update item without update error ',
    (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      //Read successfully
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.update).first);
      await tester.pump();
      expect(find.text('Number 1'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Number 1'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 2    '), findsOneWidget);
      expect(find.text('Even: 0    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.update).last);
      await tester.pump();
      expect(find.text('Number 1'), findsOneWidget);
      expect(find.text('Number 12'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 2    '), findsOneWidget);
      expect(find.text('Even: 0    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Number 1'), findsOneWidget);
      expect(find.text('Number 12'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );

  testWidgets(
    'Update item without with error ',
    (tester) async {
      final repo = numbers.getRepoAs<FakeNumbersRepository>();

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      //Read successfully
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      //
      repo.exception = 'Update error';
      await tester.tap(find.byIcon(Icons.update).first);
      await tester.pump();
      expect(find.text('Number 1'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('Number 1'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.refresh_outlined));
      await tester.pump();
      expect(find.text('Number 1'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      repo.exception = null;
      await tester.tap(find.byIcon(Icons.refresh_outlined));
      await tester.pump();
      expect(find.text('Number 1'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Number 1'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 2    '), findsOneWidget);
      expect(find.text('Even: 0    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );
  testWidgets(
    'Delete item without update error ',
    (tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      //Read successfully
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();
      expect(find.text('Number 0'), findsNothing);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Number 0'), findsNothing);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 1    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 0    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();
      expect(find.text('Number 0'), findsNothing);
      expect(find.text('Number 11'), findsNothing);
      expect(find.text('All: 1    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 0    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Number 0'), findsNothing);
      expect(find.text('Number 11'), findsNothing);
      expect(find.text('All: 0    '), findsOneWidget);
      expect(find.text('Odd: 0    '), findsOneWidget);
      expect(find.text('Even: 0    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );

  testWidgets(
    'Delete item with update error ',
    (tester) async {
      final repo = numbers.getRepoAs<FakeNumbersRepository>();

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      //Read successfully
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      //
      repo.exception = 'Delete Error';
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();
      expect(find.text('Number 0'), findsNothing);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.refresh_outlined));
      await tester.pump();
      expect(find.text('Number 0'), findsNothing);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('Number 0'), findsNothing);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.text('Number 0'), findsOneWidget);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.refresh_outlined), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      //
      repo.exception = null;
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(find.text('Number 0'), findsNothing);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 2    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 1    '), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Number 0'), findsNothing);
      expect(find.text('Number 11'), findsOneWidget);
      expect(find.text('All: 1    '), findsOneWidget);
      expect(find.text('Odd: 1    '), findsOneWidget);
      expect(find.text('Even: 0    '), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    },
  );
}
