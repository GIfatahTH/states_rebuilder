import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injected.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'injected_test.dart';

final counter = RM.inject(() => 0);

void main() {
  StatesRebuilerLogger.isTestMode = true;
  testWidgets('OnData for widget and onSetState', (tester) async {
    //
    int onData;
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: counter.listen(
        initState: () {
          StatesRebuilerLogger.log('initState');
        },
        dispose: () {},
        onSetState: When.data(() => onData = counter.state),
        onRebuildState: When.data(() => onData++),
        rebuild: When.data(
          () => Text('${counter.state}'),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(StatesRebuilerLogger.message.contains('initState'), isTrue);
    expect(find.text('0'), findsOneWidget);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(onData, 2);
  });

  testWidgets('onError for widget and onSetState', (tester) async {
    //
    int onData;
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: counter.listen(
        onSetState: When.error((_) => onData = counter.state),
        onRebuildState: When.error((_) => onData++),
        rebuild: When.error(
          (err) {
            return Text('${err?.message}');
          },
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('null'), findsOneWidget);
    //
    counter.setState((s) => throw Exception('Error'));
    await tester.pump();
    expect(find.text('Error'), findsOneWidget);
    expect(onData, 1);
  });

  testWidgets('onWaiting for widget and onSetState', (tester) async {
    //
    int onData;
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: counter.listen(
        onSetState: When.waiting(() => onData = counter.state),
        onRebuildState: When.waiting(() => onData++),
        rebuild: When.waiting(
          () {
            return Text('Waiting');
          },
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('Waiting'), findsOneWidget);
    //
    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 1));
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    expect(onData, 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Waiting'), findsOneWidget);
    expect(onData, 1);
  });

  testWidgets('when.all for widget and onSetState', (tester) async {
    //
    int onData;
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: counter.listen(
        onSetState: When.all(
          onIdle: () => onData = counter.state,
          onWaiting: () => onData = counter.state,
          onError: (err) => onData = counter.state,
          onData: () => onData = counter.state,
        ),
        onRebuildState: When.all(
          onIdle: () => onData++,
          onWaiting: () => onData++,
          onError: (err) => onData++,
          onData: () => onData++,
        ),
        rebuild: When.all(
          onIdle: () => Text('Idle'),
          onWaiting: () => Text('Waiting'),
          onError: (err) => Text('error: ${err.message}'),
          onData: () => Text('${counter.state}'),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('Idle'), findsOneWidget);

    //
    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 1));
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    expect(onData, 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(onData, 2);
  });

  testWidgets('when.or for widget and onSetState', (tester) async {
    //
    int onData;
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: counter.listen(
        onSetState: When.or(
          onIdle: () => onData = counter.state,
          onWaiting: () => onData = counter.state,
          onError: (err) => onData = counter.state,
          or: () => onData = counter.state,
        ),
        onRebuildState: When.or(
          onIdle: () => onData++,
          onWaiting: () => onData++,
          onError: (err) => onData++,
          or: () => onData++,
        ),
        rebuild: When.or(
          onIdle: () => Text('Idle'),
          onWaiting: () => Text('Waiting'),
          onError: (err) => Text('error: ${err.message}'),
          or: () => Text('${counter.state}'),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('Idle'), findsOneWidget);

    //
    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 1));
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    expect(onData, 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(onData, 2);
  });

  testWidgets('when.or (waiting and or)', (tester) async {
    //
    int onData;
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: counter.listen(
        onSetState: When.or(
          onWaiting: () => onData = counter.state,
          or: () => onData = counter.state,
        ),
        onRebuildState: When.or(
          onWaiting: () => onData++,
          or: () => onData++,
        ),
        rebuild: When.or(
          onWaiting: () => Text('Waiting'),
          or: () => Text('${counter.state}'),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);

    //
    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 1));
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    expect(onData, 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(onData, 2);
  });

  testWidgets('when.or (error and or)', (tester) async {
    //
    int onData;
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: counter.listen(
        onSetState: When.or(
          onError: (_) => onData = counter.state,
          or: () => onData = counter.state,
        ),
        onRebuildState: When.or(
          onError: (_) => onData++,
          or: () => onData++,
        ),
        rebuild: When.or(
          onError: (_) => Text('Error'),
          or: () => Text('${counter.state}'),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);

    //
    counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => throw Exception()));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(onData, 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error'), findsOneWidget);
    expect(onData, 1);
  });

  testWidgets('when.or (or)', (tester) async {
    //
    int onData;
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: counter.listen(
        onSetState: When.or(
          or: () => onData = counter.state,
        ),
        onRebuildState: When.or(
          or: () => onData++,
        ),
        rebuild: When.or(
          or: () => Text('${counter.state}'),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);

    //
    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 1));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(onData, 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(onData, 2);
  });

  testWidgets('when.always', (tester) async {
    //
    int onData;
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: counter.listen(
        onSetState: When.always(
          () => onData = counter.state,
        ),
        onRebuildState: When.always(
          () => onData++,
        ),
        rebuild: When.always(
          () => Text('${counter.state}'),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);

    //
    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 1));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(onData, 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(onData, 2);
  });

  testWidgets('listen When.always with many observers preserve state',
      (tester) async {
    final counter1 = RM.inject(() => 0);
    Injected<int> counter2;
    final widget = counter1.listen(
      rebuild: When.always(
        () {
          counter2 = RM.inject(() => 10);
          return [counter1, counter2].listen(
            rebuild: When.always(
              () => Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    Text('${counter1.state}'),
                    Text('${counter2.state}'),
                  ],
                ),
              ),
            ),
            initState: () {},
            dispose: () {},
            shouldRebuild: () => true,
            watch: () => [counter1.state, counter2.state],
          );
        },
      ),
    );

    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    counter1.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    //

    counter2.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
  });

  testWidgets('listen When all with many observers preserve state',
      (tester) async {
    final counter1 = RM.inject(() => VanillaModel(0),
        debugPrintWhenNotifiedPreMessage: 'counter1');
    Injected<VanillaModel> counter2;
    final widget = counter1.listen(
      rebuild: When.always(
        () {
          counter2 = RM.inject(() => VanillaModel(10));
          return Directionality(
            textDirection: TextDirection.ltr,
            child: [counter1, counter2].listen(
              rebuild: When.all(
                onIdle: () => Text('Idle'),
                onWaiting: () => Text('onWaiting'),
                onData: () => Column(
                  children: [
                    Text('${counter1.state.counter}'),
                    Text('${counter2.state.counter}'),
                  ],
                ),
                onError: (e) => Text('${e.message}'),
              ),
              initState: () {},
              dispose: () {},
              shouldRebuild: () => true,
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(widget);
    expect(find.text('Idle'), findsOneWidget);
    //
    counter1.setState((s) => s.incrementAsync());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Idle'), findsOneWidget);

    //
    counter2.setState((s) => s.incrementAsync());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);

    //
    counter2.setState((s) => s.incrementError());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets('listen when or with many observers preserve state',
      (tester) async {
    final counter1 = RM.inject(() => VanillaModel(0),
        debugPrintWhenNotifiedPreMessage: 'counter1');
    Injected<VanillaModel> counter2;
    final widget = counter1.listen(
      rebuild: When.data(
        () {
          counter2 = RM.inject(() => VanillaModel(10));
          return Directionality(
            textDirection: TextDirection.ltr,
            child: [counter1, counter2].listen(
              onSetState: When.always(() => null),
              onRebuildState: When.always(() => null),
              rebuild: When.or(
                onWaiting: () => Text('onWaiting'),
                or: () => Column(
                  children: [
                    Text('${counter1.state.counter}'),
                    Text('${counter2.state.counter}'),
                  ],
                ),
                onIdle: () => Text('Idle'),
                onError: (e) => Text('${e.message}'),
              ),
              initState: () {},
              dispose: () {},
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(widget);
    expect(find.text('Idle'), findsOneWidget);
    //
    counter1.setState((s) => s.incrementAsync());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Idle'), findsOneWidget);

    //
    counter2.setState((s) => s.incrementAsync());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);

    //
    counter2.setState((s) => s.incrementError());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets(
      'injected model preserve state when when created inside a build method',
      (WidgetTester tester) async {
    final counter1 = RM.inject(() => 0);
    Injected<int> counter2;
    await tester.pumpWidget(
      counter1.listen(
        shouldRebuild: () => true,
        rebuild: When.data(
          () {
            counter2 = RM.inject(
              () => 0,
              // debugPrintWhenNotifiedPreMessage: 'counter2',
            );
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  Text('counter1: ${counter1.state}'),
                  counter2.listen(
                    onSetState: When.data(() => null),
                    onRebuildState: When.data(() => null),
                    rebuild: When.data(
                      () => Text('counter2: ${counter2.state}'),
                    ),
                  ),
                  counter2.listen(
                    onSetState: When.waiting(() => null),
                    onRebuildState: When.waiting(() => null),
                    rebuild: When.data(
                      () => Text(''),
                    ),
                  ),
                  counter2.listen(
                    shouldRebuild: () => true,
                    rebuild: When.or(
                      or: () => Column(
                        children: [
                          Text('whenRebuilderOr counter2: ${counter2.state}'),
                          counter2.whenRebuilder(
                            onIdle: () => Text('idle'),
                            onWaiting: () => Text('Waiting'),
                            onData: () => Text(
                                'whenRebuilder counter2: ${counter2.state}'),
                            onError: (_) => Text('Error'),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);

    // expect(find.text('counter2-waiting-null'), findsOneWidget);

    //increment counter1
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 2'), findsOneWidget);

    //increment counter1
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 2'), findsOneWidget);
    expect(find.text('counter2: 2'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 2'), findsOneWidget);
    expect(find.text('counter2: 3'), findsOneWidget);
    expect(find.text('whenRebuilderOr counter2: 3'), findsOneWidget);
    expect(find.text('whenRebuilder counter2: 3'), findsOneWidget);
  });
}
