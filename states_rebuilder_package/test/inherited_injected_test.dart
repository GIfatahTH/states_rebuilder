// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors
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
      stateOverride: null,
      builder: (ctx) {
        context1 = ctx;
        return counter2.inherited(
            stateOverride: null,
            builder: (ctx) {
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
      stateOverride: () => counter1.state,
      builder: (ctx) {
        context1 = ctx;
        return counter2.inherited(
            stateOverride: () => counter2.state,
            builder: (ctx) {
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
      connectWithGlobal: true,
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
      connectWithGlobal: true,
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
      connectWithGlobal: true,
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
      sideEffects: SideEffects(
        dispose: () => disposedNum++,
      ),
    );
    late BuildContext context;
    late BuildContext context1;
    late BuildContext context2;
    final widget1 = counter.inherited(
      stateOverride: () => 2,
      connectWithGlobal: true,
      builder: (ctx) {
        context = ctx;
        return Text('Inherited: ${counter(ctx).state}');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: OnBuilder(
          listenTo: switcher,
          builder: () => switcher.state ? widget1 : Container(),
        ),
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
    expect((counter).inheritedInjects.length, 0);
  });

  testWidgets('reInherited works when stateOverride is not defined',
      (tester) async {
    int disposedNum = 0;
    final switcher = true.inj();
    final counter = RM.inject(
      () => 2,
      sideEffects: SideEffects(
        dispose: () => disposedNum++,
      ),
    );
    late BuildContext context;
    late BuildContext context1;
    late BuildContext context2;
    final widget1 = counter.inherited(
      stateOverride: null,
      connectWithGlobal: true,
      builder: (ctx) {
        context = ctx;
        return Text('Inherited: ${counter(ctx).state}');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: OnBuilder(
          listenTo: switcher,
          builder: () => switcher.state ? widget1 : Container(),
        ),
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
    expect((counter).inheritedInjects.length, 0);
  });

  testWidgets(
    'WHEN the list of items is updated and WHEN item is refreshed'
    'THEN only updated item is rebuild',
    (tester) async {
      final items = RM.inject(
        () => [1, 2, 3],
      );
      //
      final hideAll = false.inj();
      final widget = MaterialApp(
        home: OnReactive(() {
          return ListView.builder(
            itemCount: items.state.length,
            itemBuilder: (_, i) {
              if (hideAll.state) {
                return Container();
              }
              return _item.inherited(
                stateOverride: () {
                  return items.state[i];
                },
                builder: (context) {
                  return const _Item();
                },
              );
            },
          );
        }),
      );
      await tester.pumpWidget(widget);
      expect(rebuiltItems, [1, 2, 3]);
      rebuiltItems.clear();
      items.state = [1, 2, 3, 4];
      await tester.pump();
      expect(rebuiltItems, [4]);
      rebuiltItems.clear();
      final list = [1, 2, 3, 5];
      items.state = list;
      await tester.pump();
      _item.refresh();
      await tester.pump();
      expect(rebuiltItems, [5]);
      //
      // Provoke UnimplementedError and RangeError that are captured
      list.removeLast();
      hideAll.toggle();
      _item.refresh();
      await tester.pumpAndSettle();
      expect(find.byType(_Item), findsNothing);
      //
      hideAll.toggle();
      _item.refresh();
      await tester.pumpAndSettle();
      expect(find.byType(_Item), findsNWidgets(3));

      //
      _item.refresh();
      hideAll.toggle();
      await tester.pumpAndSettle();
      expect(find.byType(_Item), findsNWidgets(0));
      hideAll.toggle();
      await tester.pump();
      //
      rebuiltItems.clear();
      items.state = [1, 22, 3];
      await tester.pump();
      _item.refresh();
      await tester.pump();
      expect(rebuiltItems, [22]);
    },
  );

  testWidgets(
    'Check that Items anc be linked to item without cyclic loop',
    (tester) async {
      late Injected<_Counter> itemRM;
      late List<Injected<_Counter>> childItem = [];
      final itemsRM = RM.inject<List<_Counter>>(
        () => [_Counter(1, 1), _Counter(2, 2), _Counter(3, 3)],
        debugPrintWhenNotifiedPreMessage: '',
        sideEffects: SideEffects.onData(
          (_) {
            itemRM.refresh();
          },
        ),
      );

      itemRM = RM.inject<_Counter>(
        () => throw UnimplementedError(),
        sideEffects: SideEffects.onData(
          (_) {
            itemsRM.state = [
              for (var item in itemsRM.state)
                if (item.id == _.id) _ else item
            ];
          },
        ),
      );
      //
      final hideAll = false.inj();
      final widget = MaterialApp(
        home: OnReactive(() {
          return ListView.builder(
            itemCount: itemsRM.state.length,
            itemBuilder: (_, i) {
              if (hideAll.state) {
                return Container();
              }
              return itemRM.inherited(
                stateOverride: () {
                  return itemsRM.state[i];
                },
                builder: (context) {
                  childItem.add(itemRM(context));
                  final item = itemRM.of(context);
                  return Text('Item: ${item.id}');
                },
              );
            },
          );
        }),
      );
      await tester.pumpWidget(widget);
      expect(find.text('Item: 1'), findsOneWidget);
      expect(find.text('Item: 2'), findsOneWidget);
      expect(find.text('Item: 3'), findsOneWidget);
      expect(childItem.length, 3);
      //
      childItem[0].state = _Counter(1, 10);
      childItem.clear();
      await tester.pump();
      expect(itemsRM.state.first.counter, 10);
      //
      childItem[2].state = _Counter(3, 30);
      childItem.clear();
      await tester.pump();
      expect(itemsRM.state[2].counter, 30);
      //
      childItem.clear();
      itemsRM.state = [
        for (var item in itemsRM.state)
          if (item.id == 2) _Counter(2, 20) else item
      ];
      await tester.pump();
      expect(childItem[0].state.counter, 10);
      expect(childItem[1].state.counter, 20);
      expect(childItem[2].state.counter, 30);
      expect(itemsRM.state[0].counter, 10);
      expect(itemsRM.state[1].counter, 20);
      expect(itemsRM.state[2].counter, 30);
    },
  );
}

class _Counter {
  final int id;
  final int counter;

  _Counter(this.id, this.counter);
  @override
  String toString() {
    return '_Counter($id, $counter)';
  }
}

final _item = RM.inject<int>(() => throw UnimplementedError());
List<int> rebuiltItems = [];

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final i = _item.of(context);
    rebuiltItems.add(i);
    return Text('$i');
  }
}
