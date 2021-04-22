import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('StateWithMixinBuilder appLifeCycle works',
      (WidgetTester tester) async {
    final widget = Child(
      builder: (child) => Directionality(
        textDirection: TextDirection.ltr,
        child: child,
      ),
      child: Text('From Child'),
    );
    await tester.pumpWidget(widget);
    expect(find.text('From Child'), findsOneWidget);
  });
}
