import 'package:flutter/material.dart';
import 'package:flutter_default_counter_app/pages/simple_counter_with_functional_injection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should increment counter and show snackbar', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MyHomePage(
        title: 'simple counter',
      ),
    ));

    expect(find.text('0'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    //first tap
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    //find two: one in the body of the scaffold and the other in the SnackBar
    expect(find.text('1'), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);

    //second tap
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text('2'), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
