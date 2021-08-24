import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter {
  final counter1 = 0.inj();
  final counter2 = 0.inj();
  int get sum => counter1.state + counter2.state;
  void incrementCounter1() => counter1.state++;
  void incrementCounter2() => counter2.state++;
}

final counterState = Counter();

void main() {
  testWidgets(
    'OnReactive get implicit subscribe to observer via state getter',
    (tester) async {
      late int counter1Value;
      late int counter2Value;
      late int sumValue;
      final widget = Column(
        children: [
          OnReactive(
            () {
              counter1Value = counterState.counter1.state;
              return Container();
            },
          ),
          OnReactive(
            () {
              counter2Value = counterState.counter2.state;
              return Container();
            },
          ),
          OnReactive(
            () {
              sumValue = counterState.sum;
              return Container();
            },
          ),
        ],
      );

      await tester.pumpWidget(widget);
      expect(counter1Value, 0);
      expect(counter2Value, 0);
      expect(sumValue, 0);
      counterState.incrementCounter1();
      await tester.pump();
      expect(counter1Value, 1);
      expect(counter2Value, 0);
      expect(sumValue, 1);
      counterState.incrementCounter2();
      await tester.pump();
      expect(counter1Value, 1);
      expect(counter2Value, 1);
      expect(sumValue, 2);
    },
  );
  testWidgets(
    'OnReactive get implicit subscribe to observer via state getter (run test All)',
    (tester) async {
      late int counter1Value;
      late int counter2Value;
      late int sumValue;
      final widget = Column(
        children: [
          OnReactive(
            () {
              counter1Value = counterState.counter1.state;
              return Container();
            },
          ),
          OnReactive(
            () {
              counter2Value = counterState.counter2.state;
              return Container();
            },
          ),
          OnReactive(
            () {
              sumValue = counterState.sum;
              return Container();
            },
          ),
        ],
      );

      await tester.pumpWidget(widget);
      expect(counter1Value, 0);
      expect(counter2Value, 0);
      expect(sumValue, 0);
      counterState.incrementCounter1();
      await tester.pump();
      expect(counter1Value, 1);
      expect(counter2Value, 0);
      expect(sumValue, 1);
      counterState.incrementCounter2();
      await tester.pump();
      expect(counter1Value, 1);
      expect(counter2Value, 1);
      expect(sumValue, 2);
    },
  );
  testWidgets(
    'OnReactive get injected model from state and listens to them',
    (tester) async {
      final counter = RM.inject(() => 0);
      final counter2 = 0.inj();
      final counter3 = 0.inj();
      final counter4 = 0.inj();
      final counter5 = 0.inj();
      final counter6 =
          RM.inject(() => 0, debugPrintWhenNotifiedPreMessage: 'counter6');
      final widget = OnReactive(
        () {
          return Column(
            children: [
              Text(counter.state.toString()),
              Builder(
                builder: (_) {
                  return Builder(
                    builder: (_) {
                      return Builder(
                        builder: (_) {
                          return Builder(
                            builder: (_) {
                              return Text(counter2.state.toString());
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (_, __) {
                    return Column(
                      children: [
                        OnReactive(() {
                          return Text(counter3.state.toString());
                        }),
                        Builder(
                          builder: (_) {
                            return Text(counter6.state.toString());
                          },
                        ),
                        // Text(counter6.state.toString()),
                      ],
                    );
                  },
                ),
              ),
              OnReactive(() {
                return Text(counter4.state.toString());
              }),
              Builder(builder: (context) {
                return Text(counter5.state.toString());
              }),
            ],
          );
        },
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        ),
      );
      expect(find.text('0'), findsNWidgets(6));
      counter.state++;
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      counter2.state++;
      await tester.pump();
      expect(find.text('1'), findsNWidgets(2));
      counter3.state++;
      await tester.pump();
      expect(find.text('1'), findsNWidgets(3));
      counter4.state++;
      await tester.pump();
      expect(find.text('1'), findsNWidgets(4));
      counter5.state++;
      await tester.pump();
      expect(find.text('1'), findsNWidgets(5));
      await tester.pump();
      counter6.state++;
      await tester.pump();
      expect(find.text('1'), findsNWidgets(6));
    },
  );

  testWidgets(
    'OnReactive with isWaiting can get observers'
    'THEN',
    (tester) async {
      final counter = 0.inj();
      final counter2 = RM.inject(() => 0);

      final widget = OnReactive(
        () {
          return Column(
            children: [
              Builder(
                builder: (_) {
                  if (counter.isWaiting) {
                    return Text('isWaiting');
                  }
                  if (counter.hasData) {
                    return Text(counter.state.toString());
                  }
                  return Text('isIdle');
                },
              ),
              Builder(
                builder: (_) {
                  if (counter2.isWaiting) {
                    return Text('isWaiting');
                  }
                  if (counter2.hasData) {
                    return Text(counter2.state.toString());
                  }
                  return Text('isIdle');
                },
              ),
            ],
          );
        },
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.text('isIdle'), findsNWidgets(2));
      counter.setState((s) => Future.delayed(1.seconds, () => 1));
      await tester.pump();
      expect(find.text('isWaiting'), findsNWidgets(1));
      expect(find.text('isIdle'), findsNWidgets(1));
      await tester.pump(1.seconds);
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('isIdle'), findsNWidgets(1));
      //
      counter2.setState((s) => Future.delayed(1.seconds, () => 1));
      await tester.pump();
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('isWaiting'), findsNWidgets(1));
      await tester.pump(1.seconds);
      expect(find.text('1'), findsNWidgets(2));
    },
  );

  testWidgets(
    'OnReactive with hasError can get observers'
    'THEN',
    (tester) async {
      final counter = 0.inj();
      final counter2 = RM.inject(() => 0);

      final widget = OnReactive(
        () {
          return Column(
            children: [
              Builder(
                builder: (_) {
                  if (counter.hasError) {
                    return Text('hasError');
                  }

                  return Text('isIdle');
                },
              ),
              Builder(
                builder: (_) {
                  if (counter2.hasError) {
                    return Text('hasError');
                  }

                  return Text('isIdle');
                },
              ),
            ],
          );
        },
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.text('isIdle'), findsNWidgets(2));
      counter.setState((s) => Future.delayed(1.seconds, () => throw 'error'));
      await tester.pump();
      expect(find.text('isIdle'), findsNWidgets(2));
      await tester.pump(1.seconds);
      expect(find.text('hasError'), findsNWidgets(1));
      expect(find.text('isIdle'), findsNWidgets(1));
      //
      counter2.setState((s) => Future.delayed(1.seconds, () => throw 'error'));
      await tester.pump();
      expect(find.text('hasError'), findsNWidgets(1));
      expect(find.text('isIdle'), findsNWidgets(1));
      await tester.pump(1.seconds);
      expect(find.text('hasError'), findsNWidgets(2));
    },
  );

  testWidgets(
    'OnReactive with onAll can get observers',
    (tester) async {
      final counter = 0.inj();
      final counter2 = RM.inject(() => 0);

      final widget = OnReactive(
        () {
          return Column(
            children: [
              Builder(
                builder: (_) {
                  return counter.onAll(
                    onIdle: () => Text('isIdle'),
                    onWaiting: () => Text('isWaiting'),
                    onError: (_, __) => Text('error'),
                    onData: (data) => Text(data.toString()),
                  );
                },
              ),
              Builder(
                builder: (_) {
                  // print(counter2.state);
                  return counter2.onOrElse(
                    onWaiting: () => Text('isWaiting'),
                    onError: (_, __) => Text('error'),
                    orElse: (data) => Text(data.toString()),
                  );
                },
              ),
            ],
          );
        },
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.text('isIdle'), findsNWidgets(1));
      expect(find.text('0'), findsNWidgets(1));
      counter.setState((s) => Future.delayed(1.seconds, () => 1));
      await tester.pump();
      expect(find.text('isWaiting'), findsNWidgets(1));
      expect(find.text('0'), findsNWidgets(1));
      await tester.pump(1.seconds);
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('0'), findsNWidgets(1));
      //
      counter2.setState((s) => Future.delayed(1.seconds, () => throw 'error'));
      await tester.pump();
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('isWaiting'), findsNWidgets(1));
      await tester.pump(1.seconds);
      expect(find.text('error'), findsNWidgets(1));
    },
  );

  testWidgets(
    'OnReactive with onOr can get observers',
    (tester) async {
      final counter = 0.inj();
      final counter2 = RM.inject(() => 0);

      final widget = OnReactive(
        () {
          return Column(
            children: [
              Builder(
                builder: (_) {
                  return counter.onOrElse(
                    onIdle: () => Text('isIdle'),
                    onWaiting: () => Text('isWaiting'),
                    onError: (_, __) => Text('error'),
                    orElse: (data) => Text(data.toString()),
                  );
                },
              ),
              Builder(
                builder: (_) {
                  return counter2.onOrElse(
                    onWaiting: () => Text('isWaiting'),
                    onError: (_, __) => Text('error'),
                    orElse: (data) => Text(data.toString()),
                  );
                },
              ),
            ],
          );
        },
      );
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ));
      expect(find.text('isIdle'), findsNWidgets(1));
      expect(find.text('0'), findsNWidgets(1));
      counter.setState((s) => Future.delayed(1.seconds, () => 1));
      await tester.pump();
      expect(find.text('isWaiting'), findsNWidgets(1));
      expect(find.text('0'), findsNWidgets(1));
      await tester.pump(1.seconds);
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('0'), findsNWidgets(1));
      //
      counter2.setState((s) => Future.delayed(1.seconds, () => throw 'error'));
      await tester.pump();
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('isWaiting'), findsNWidgets(1));
      await tester.pump(1.seconds);
      expect(find.text('error'), findsNWidgets(1));
    },
  );

  testWidgets(
    'Check onSetState',
    (tester) async {
      final counter1 = RM.inject(
        () => 0,
      );
      final counter2 = RM.injectFuture<int?>(
        () => Future.delayed(1.seconds, () => 10),
      );
      String onSetStateCounter1 = '';
      String onSetStateCounter2 = '';
      final widget = OnReactive(
        () {
          return Column(
            children: [
              Builder(builder: (_) {
                counter1.isDone;
                counter1.isActive;
                counter2.isActive;
                counter2.isDone;
                return Container();
              }),
              Text(counter1.state.toString()),
              Text(counter2.state.toString()),
            ],
          );
        },
        sideEffects: SideEffects(
          initState: () {},
          dispose: () {},
          onSetState: (snap) {
            if (snap == counter1.snapState) {
              onSetStateCounter1 = 'counter1';
            } else if (snap == counter2.snapState) {
              onSetStateCounter2 = 'counter2';
            }
          },
        ),
        shouldRebuild: (old, nex) {
          if (nex == counter1.snapState) {
            if (counter1.state > 1) {
              return false;
            }
            return true;
          }
          return true;
        },
      );

      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: widget),
      );

      await tester.pump(1.seconds);
      expect(onSetStateCounter2, 'counter2');
      counter1.state++;
      await tester.pump();
      expect(onSetStateCounter1, 'counter1');
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('10'), findsNWidgets(1));
      //
      counter1.state++;
      await tester.pump();
      expect(find.text('1'), findsNWidgets(1));
      expect(find.text('10'), findsNWidgets(1));
    },
  );

  testWidgets(
    'WHEN a state is removed inside OnReactive'
    'THEN it will be removed from listener and disposed if has no observers',
    (tester) async {
      bool isDisposed1 = false;
      bool isDisposed2 = false;
      final switcher = true.inj();
      final counter1 = RM.inject(
        () => 0,
        onDisposed: (_) {
          isDisposed1 = true;
        },
      );
      final counter2 = RM.inject(
        () => 0,
        onDisposed: (_) {
          isDisposed2 = true;
        },
      );
      final counter3 = 0.inj();
      //
      final widget = OnReactive(() {
        return Column(
          children: [
            if (switcher.state) Text('${counter1.state}'),
            if (switcher.state) Text('${counter2.state}'),
            Text('${counter3.state}'),
          ],
        );
      });
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            widget,
            OnReactive(
              () => Text('${counter2.state}'),
              debugPrintWhenRebuild: '',
              debugPrintWhenObserverAdd: '',
            ),
          ],
        ),
      ));
      expect(find.text('0'), findsNWidgets(4));
      expect(isDisposed1, false);
      expect(isDisposed2, false);

      //
      switcher.toggle();
      await tester.pump();
      expect(find.text('0'), findsNWidgets(2));
      expect(isDisposed1, true);
      expect(isDisposed2, false);
      counter3.state++;
      await tester.pump();
      expect(find.text('1'), findsNWidgets(1));
      counter2.state++;
      await tester.pump();
      expect(find.text('1'), findsNWidgets(2));
      counter1.state++;
      await tester.pump();
      expect(find.text('1'), findsNWidgets(2));
      //
    },
  );

  testWidgets(
    'ReactiveStatelessWidget get implicit subscribe to observer via state getter',
    (tester) async {
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: _ParentWidget(),
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsNWidgets(3));

      counterState.incrementCounter1();
      await tester.pump();
      expect(find.text('0'), findsNWidgets(1));
      expect(find.text('1'), findsNWidgets(2));

      counterState.incrementCounter2();
      await tester.pump();
      expect(find.text('0'), findsNWidgets(0));
      expect(find.text('1'), findsNWidgets(2));
      expect(find.text('2'), findsNWidgets(1));
    },
  );
}

class _ParentWidget extends ReactiveStatelessWidget {
  const _ParentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Widget1(),
        _Widget2(),
        _Widget3(),
      ],
    );
  }
}

class _Widget1 extends StatelessWidget {
  const _Widget1({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(counterState.counter1.state.toString());
  }
}

class _Widget2 extends StatelessWidget {
  const _Widget2({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(counterState.counter2.state.toString());
  }
}

class _Widget3 extends StatelessWidget {
  const _Widget3({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(counterState.sum.toString());
  }
}
