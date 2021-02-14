import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

void main() {
  testWidgets('get inherited using call', (tester) async {
    final counter1 = RM.inject(() => 1);
    final counter2 = RM.inject(() => 2);
    late BuildContext context1;
    late BuildContext context2;
    final widget = counter1.inherited(
      builder: (ctx) {
        context1 = ctx;
        return counter2.inherited(builder: (ctx) {
          context2 = ctx;
          return Container();
        });
      },
    );

    await tester.pumpWidget(widget);
    expect(counter1.call(context1), counter1);
    expect(counter1.call(context2), counter1);
    expect(counter2.call(context1), null);
    expect(counter2.call(context1, defaultToGlobal: true), counter2);
    expect(counter2.call(context2), counter2);
  });

  testWidgets('get inherited using of method', (tester) async {
    final counter1 = RM.inject(() => 1);
    final counter2 = RM.inject(() => 2);
    late BuildContext context1;
    late BuildContext context2;
    final widget = counter1.inherited(
      builder: (ctx) {
        context1 = ctx;
        return counter2.inherited(builder: (ctx) {
          context2 = ctx;
          return Container();
        });
      },
    );

    await tester.pumpWidget(widget);
    expect(counter1.of(context1), counter1.state);
    expect(counter1.of(context2), counter1.state);
    expect(counter2.of(context1), null);
    expect(counter2.of(context1, defaultToGlobal: true), counter2.state);
    expect(counter2.of(context2), counter2.state);
  });

  testWidgets('Mutate inhertied will mutate the globale ', (tester) async {
    final counter1 = RM.inject(() => 1);
    late BuildContext context1;
    final widget = counter1.inherited(
      stateOverride: () => counter1.state * 10,
      builder: (ctx) {
        context1 = ctx;
        return Container();
      },
    );

    await tester.pumpWidget(widget);
    final inherited1 = counter1(context1)!;

    inherited1.state++;
    expect(counter1.state, 11);
    //
    inherited1.setState((s) => Future.delayed(Duration(seconds: 1), () => 12));
    await tester.pump();
    expect(counter1.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(counter1.state, 12);
    //
    inherited1.setState((s) => throw Exception(), catchError: true);
    await tester.pump();
    expect(counter1.hasError, true);
  });
  testWidgets('mutate goble with inherited is wiating  ', (tester) async {
    final counter1 = RM.inject(() => 1);
    late BuildContext context1;
    final widget = counter1.inherited(
      stateOverride: () =>
          Future.delayed(Duration(seconds: 1), () => counter1.state * 10),
      builder: (ctx) {
        context1 = ctx;
        return Container();
      },
    );

    await tester.pumpWidget(widget);
    final inherited1 = counter1(context1)!;
    expect(inherited1.isWaiting, true);
    expect(counter1.isIdle, true);
    await tester.pump(Duration(seconds: 1));
    expect(inherited1.state, 10);
    expect(counter1.state, 10);

    counter1.refresh();
    await tester.pump();
    expect(inherited1.isWaiting, true);
    expect(counter1.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(inherited1.state, 100);
    expect(counter1.state, 100);
  });

  testWidgets('mutate goble with inherited has Error  ', (tester) async {
    final counter1 = RM.inject(() => 1);
    late BuildContext context1;
    final widget = counter1.inherited(
      stateOverride: () => throw Exception('Error'),
      builder: (ctx) {
        context1 = ctx;
        return Container();
      },
    );

    await tester.pumpWidget(widget);
    final inherited1 = counter1(context1)!;
    expect(inherited1.hasError, true);
    expect(counter1.isIdle, true);

    counter1.refresh();
    await tester.pump();
    expect(inherited1.hasError, true);
    expect(counter1.hasError, true);
  });
}
