import 'package:ex_006_5_navigation/ex14_return_data_from_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test navigation logic', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Pick an option, any option!'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yep!'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Yep!'), findsOneWidget);
    //
    await tester.tap(find.text('Pick an option, any option!'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nope.'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Nope.'), findsOneWidget);
  });
}
