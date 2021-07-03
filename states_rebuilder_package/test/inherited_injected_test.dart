import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

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
    expect(() => counter2.call(context1), throwsException);
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
    expect(() => counter2.call(context1), throwsException);
    expect(() => counter2.of(context1), throwsException);
    expect(counter2.of(context1, defaultToGlobal: true), counter2.state);
    expect(counter2.of(context2), counter2.state);
  });

  testWidgets('Mutate inherited will mutate the global ', (tester) async {
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
    final inherited1 = counter1(context1);

    inherited1.state++;
    expect(counter1.state, 11);
    //
    inherited1.setState((s) => Future.delayed(Duration(seconds: 1), () => 12));
    await tester.pump();
    expect(counter1.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(counter1.state, 12);
    //
    inherited1.setState(
      (s) => throw Exception(),
    );
    await tester.pump();
    expect(counter1.hasError, true);
  });
  testWidgets('mutate global with inherited is waiting  ', (tester) async {
    final counter1 = RM.inject(
      () => 1,
      // debugPrintWhenNotifiedPreMessage: 'counter1',
    );
    late BuildContext context1;
    final widget = counter1.inherited(
      stateOverride: () => Future.delayed(Duration(seconds: 1), () {
        return 10;
      }),
      builder: (ctx) {
        context1 = ctx;
        return Container();
      },
      // debugPrintWhenNotifiedPreMessage: 'inherited',
    );

    await tester.pumpWidget(widget);
    final inherited1 = counter1(context1);
    expect(inherited1.isWaiting, true);
    expect(counter1.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    expect(inherited1.state, 10);
    expect(counter1.state, 10);

    counter1.refresh();
    await tester.pump();
    await tester.pump();
    // expect(inherited1.isWaiting, true);
    // expect(counter1.isWaiting, true);
    await tester.pump(Duration(seconds: 1));
    // expect(inherited1.state, 100);
    // expect(counter1.state, 100);
  });

  testWidgets('mutate global with inherited has Error  ', (tester) async {
    final counter1 = RM.inject<int>(() => 1);
    late BuildContext context1;
    final widget = counter1.inherited(
      stateOverride: () => throw Exception('Error'),
      builder: (ctx) {
        context1 = ctx;
        return Container();
      },
    );

    await tester.pumpWidget(widget);
    //
    final inherited1 = counter1(context1);
    expect(inherited1.hasError, true);
    expect(counter1.hasError, true);

    counter1.refresh();
    await tester.pump();
    expect(inherited1.hasError, true);
    expect(counter1.hasError, true);
  });

  testWidgets('reInherited works when stateOverride is defined',
      (tester) async {
    int disposedNum = 0;
    final switcher = true.inj();
    final counter = RM.inject(
      () => 1,
      onDisposed: (_) => disposedNum++,
    );
    late BuildContext context;
    late BuildContext context1;
    late BuildContext context2;
    final widget1 = counter.inherited(
      stateOverride: () => 2,
      builder: (ctx) {
        context = ctx;
        return Text('Inherited: ${counter(ctx).state}');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: On(
          () => switcher.state ? widget1 : Container(),
        ).listenTo(switcher),
      ),
    );

    expect(find.text('Inherited: 2'), findsOneWidget);
    expect(counter.state, 2);
    expect(counter(context).state, 2);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return counter.reInherited(
            context: context,
            builder: (ctx) {
              context1 = ctx;
              return Text('ReInherited1: ${counter(ctx).state}');
            },
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ReInherited1: 2'), findsOneWidget);
    expect(counter.state, 2);
    expect(counter(context1).state, 2);
    counter(context1).state++;
    await tester.pump();
    expect(find.text('ReInherited1: 3'), findsOneWidget);
    expect(counter.state, 3);
    expect(counter(context1).state, 3);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return counter.reInherited(
            context: context,
            builder: (ctx) {
              context2 = ctx;
              return Text('ReInherited2: ${counter(ctx).state}');
            },
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ReInherited2: 3'), findsOneWidget);
    expect(counter.state, 3);
    expect(counter(context2).state, 3);
    counter(context2).state++;
    await tester.pump();
    expect(find.text('ReInherited2: 4'), findsOneWidget);
    expect(counter.state, 4);
    expect(counter(context2).state, 4);

    Navigator.of(context2).pop();
    await tester.pumpAndSettle();

    expect(find.text('ReInherited1: 4'), findsOneWidget);
    expect(counter.state, 4);
    counter(context1).state++;
    await tester.pump();
    expect(find.text('ReInherited1: 5'), findsOneWidget);
    expect(counter.state, 5);
    //
    Navigator.of(context1).pop();
    await tester.pumpAndSettle();

    expect(find.text('Inherited: 5'), findsOneWidget);
    expect(counter.state, 5);
    counter(context).state++;
    await tester.pump();
    expect(find.text('Inherited: 6'), findsOneWidget);
    expect(counter.state, 6);
    expect((counter as InjectedImp).inheritedInjects.length, 1);
    switcher.toggle();
    await tester.pump();
    expect(disposedNum, 1);
    expect((counter as InjectedImp).inheritedInjects.length, 0);
  });

  testWidgets('reInherited works when stateOverride is not defined',
      (tester) async {
    int disposedNum = 0;
    final switcher = true.inj();
    final counter = RM.inject(
      () => 2,
      onDisposed: (_) => disposedNum++,
    );
    late BuildContext context;
    late BuildContext context1;
    late BuildContext context2;
    final widget1 = counter.inherited(
      builder: (ctx) {
        context = ctx;
        return Text('Inherited: ${counter(ctx).state}');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: On(
          () => switcher.state ? widget1 : Container(),
        ).listenTo(switcher),
      ),
    );

    expect(find.text('Inherited: 2'), findsOneWidget);
    expect(counter.state, 2);
    expect(counter(context).state, 2);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return counter.reInherited(
            context: context,
            builder: (ctx) {
              context1 = ctx;
              return Text('ReInherited1: ${counter(ctx).state}');
            },
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ReInherited1: 2'), findsOneWidget);
    expect(counter.state, 2);
    expect(counter(context1).state, 2);
    counter(context1).state++;
    await tester.pump();
    expect(find.text('ReInherited1: 3'), findsOneWidget);
    expect(counter.state, 3);
    expect(counter(context1).state, 3);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return counter.reInherited(
            context: context,
            builder: (ctx) {
              context2 = ctx;
              return Text('ReInherited2: ${counter(ctx).state}');
            },
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ReInherited2: 3'), findsOneWidget);
    expect(counter.state, 3);
    expect(counter(context2).state, 3);
    counter(context2).state++;
    await tester.pump();
    expect(find.text('ReInherited2: 4'), findsOneWidget);
    expect(counter.state, 4);
    expect(counter(context2).state, 4);

    Navigator.of(context2).pop();
    await tester.pumpAndSettle();

    expect(find.text('ReInherited1: 4'), findsOneWidget);
    expect(counter.state, 4);
    counter(context1).state++;
    await tester.pump();
    expect(find.text('ReInherited1: 5'), findsOneWidget);
    expect(counter.state, 5);
    //
    Navigator.of(context1).pop();
    await tester.pumpAndSettle();

    expect(find.text('Inherited: 5'), findsOneWidget);
    expect(counter.state, 5);
    counter(context).state++;
    await tester.pump();
    expect(find.text('Inherited: 6'), findsOneWidget);
    expect(counter.state, 6);
    expect((counter as InjectedImp).inheritedInjects.length, 0);
    switcher.toggle();
    await tester.pump();
    expect(disposedNum, 1);
    expect((counter as InjectedImp).inheritedInjects.length, 0);
  });
}
