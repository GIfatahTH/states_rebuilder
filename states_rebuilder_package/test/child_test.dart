import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('Child', (WidgetTester tester) async {
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

  testWidgets('Child2', (WidgetTester tester) async {
    final widget = Child2(
      builder: (child1, child2) => Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            child1,
            child2,
          ],
        ),
      ),
      child1: Text('From Child1'),
      child2: Text('From Child2'),
    );
    await tester.pumpWidget(widget);
    expect(find.text('From Child1'), findsOneWidget);
    expect(find.text('From Child2'), findsOneWidget);
  });

  testWidgets('Child3', (WidgetTester tester) async {
    final widget = Child3(
      builder: (child1, child2, child3) => Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            child1,
            child2,
            child3,
          ],
        ),
      ),
      child1: Text('From Child1'),
      child2: Text('From Child2'),
      child3: Text('From Child3'),
    );
    await tester.pumpWidget(widget);
    expect(find.text('From Child1'), findsOneWidget);
    expect(find.text('From Child2'), findsOneWidget);
    expect(find.text('From Child3'), findsOneWidget);
  });
}
