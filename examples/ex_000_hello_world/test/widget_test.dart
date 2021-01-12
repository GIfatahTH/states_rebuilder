// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ex_000_hello_world/main.dart';

void main() {
  repository.injectMock(() => FakeRepositoryName());
  testWidgets(
    'on app first start, see "Enter your name" text',
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      expect(find.text('Enter your name'), findsOneWidget);
    },
  );

  testWidgets(
    'Enter text and See a CircularProgressIndicator after 400ms (the time of '
    'debounce) for 1 seconds (the time of fake future wait) and '
    'then See the result',
    (tester) async {
      await tester.pumpWidget(MyApp());
      //
      expect(find.text('Enter your name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();
      //As the dependence is debounced, we still see the first text
      expect(find.text('Enter your name'), findsOneWidget);
      await tester.pump(Duration(milliseconds: 400));
      //After 400 ms we see two CircularProgressIndicator one in the center
      //of the screen and the other in the SnackBar
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Hello, This the info of John'), findsOneWidget);
    },
  );

  testWidgets(
    'In case of getNameInfo failure, show the failure message',
    (tester) async {
      //Reset the FakeRepositoryName to throw an error
      //This new mock injection will be valid only for this test
      repository.injectMock(() => FakeRepositoryName(shouldThrow: true));

      await tester.pumpWidget(MyApp());
      //
      expect(find.text('Enter your name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();
      //As the dependence is debounced, we still see the first text
      expect(find.text('Enter your name'), findsOneWidget);
      await tester.pump(Duration(milliseconds: 400));
      //After 400 ms we see two CircularProgressIndicator one in the center
      //of the screen and the other in the SnackBar
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
      expect(find.byType(SnackBar), findsOneWidget);
      //
      //an error will be thrown
      await tester.pumpAndSettle(Duration(seconds: 1));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Fake Server Error'), findsNWidgets(2));
      expect(find.byType(SnackBar), findsOneWidget);
    },
  );
}

class FakeRepositoryName extends NameRepository {
  final bool shouldThrow;
  FakeRepositoryName({this.shouldThrow = false});
  int numberOfGetNameInfoCall = 0;
  @override
  Future<String> getNameInfo(String name) async {
    numberOfGetNameInfoCall++;
    await Future.delayed(Duration(seconds: 1));
    if (shouldThrow) {
      throw Exception('Fake Server Error');
    }
    return 'This the info of $name';
  }
}
