import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

void main() {
  testWidgets('many simple counters app', (tester) async {
    final rm1 = ReactiveModelImp(creator: (_) => 0, nullState: 0);
    final rm2 = ReactiveModelImp(creator: (_) => 0, nullState: 0);
    final rm3 = ReactiveModelImp(creator: (_) => 0, nullState: 0);
    final widget = OnCombined.data(
      (_) => Directionality(
        textDirection: TextDirection.ltr,
        child: Text('${rm1.state}-${rm2.state}-${rm3.state}'),
      ),
    ).listenTo([rm1, rm2, rm3]);
    await tester.pumpWidget(widget);
    expect(find.text('0-0-0'), findsOneWidget);
    //
    rm1.state++;
    await tester.pump();
    expect(find.text('1-0-0'), findsOneWidget);
    //
    rm2.state++;
    await tester.pump();
    expect(find.text('1-1-0'), findsOneWidget);
    //
    rm3.state++;
    await tester.pump();
    expect(find.text('1-1-1'), findsOneWidget);
  });

  testWidgets('many async counters app', (tester) async {
    final rm1 =
        ReactiveModelImp(creator: (_) => _Model(0), nullState: _Model(0));
    final rm2 =
        ReactiveModelImp(creator: (_) => _Model(0), nullState: _Model(0));
    final rm3 =
        ReactiveModelImp(creator: (_) => _Model(0), nullState: _Model(0));
    String onWaitngSideEffect = '';
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: OnCombined.all(
        onIdle: () => Text('Idle'),
        onWaiting: () => Text('Waiting'),
        onError: (e) => Text('${e.message}'),
        onData: (_) => Text(
          '${rm1.state.count}-${rm2.state.count}-${rm3.state.count}',
        ),
      ).listenTo(
        [rm1, rm2, rm3],
        onSetState: OnCombined.waiting(
          () => onWaitngSideEffect = 'Waiting',
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('Idle'), findsOneWidget);
    expect(onWaitngSideEffect, '');
    //
    rm1.setState((s) => s.incrementFuture());
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    expect(onWaitngSideEffect, 'Waiting');

    await tester.pump(Duration(seconds: 1));
    expect(find.text('Idle'), findsOneWidget);
    //
    rm2.setState((s) => s.incrementFuture());
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Idle'), findsOneWidget);
    //
    rm3.setState((s) => s.incrementFuture());
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1-1-1'), findsOneWidget);
    //
    rm1.setState((s) => s.incrementFuture());
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('2-1-1'), findsOneWidget);
    //
    rm2.setState((s) => s.incrementFutureWithError('Error from rm2'));
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error from rm2'), findsOneWidget);
    //
    rm3.setState((s) => s.incrementFuture());
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error from rm2'), findsOneWidget);
    //
    rm2.setState((s) => s.incrementFuture());
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('2-2-2'), findsOneWidget);
  });

  testWidgets('exposed state of list of injected with defined generic type',
      (tester) async {
    final intInj = 0.inj();
    final stringInj = ''.inj();
    final boolInj = false.inj();

    dynamic exposedState;

    final widget = OnCombined(
      (s) {
        exposedState = s;
        return Container();
      },
    ).listenTo<String>([intInj, stringInj, boolInj]);
    await tester.pumpWidget(widget);

    expect(exposedState, '');
    boolInj.toggle();
    await tester.pump();
    expect(exposedState, '');
    intInj.state++;
    await tester.pump();
    expect(exposedState, '');
  });

  testWidgets('exposed state of list of injected with non defined generic type',
      (tester) async {
    final intInj = 0.inj();
    final stringInj = ''.inj();
    final boolInj = false.inj();

    dynamic exposedState;

    final widget = OnCombined(
      (s) {
        exposedState = s;
        return Container();
      },
    ).listenTo([intInj, stringInj, boolInj]);
    await tester.pumpWidget(widget);

    expect(exposedState, 0);
    boolInj.toggle();
    await tester.pump();
    expect(exposedState, true);
    intInj.state++;
    await tester.pump();
    expect(exposedState, 1);
    stringInj.state = 'new';
    await tester.pump();
    expect(exposedState, 'new');
  });

  testWidgets('exposed state of list of injected with non defined generic type',
      (tester) async {
    final intInj = 0.inj();
    final boolInj = false.inj();

    String message = '';
    final widget = OnCombined(
      (s) {
        return Container();
      },
    ).listenTo(
      [intInj, boolInj],
      onAfterBuild: OnCombined((_) => message = 'onAfterBuild'),
    );
    await tester.pumpWidget(widget);
    expect(message, 'onAfterBuild');
    message = '';
    boolInj.toggle();
    await tester.pump();
    expect(message, 'onAfterBuild');
  });

  testWidgets('OnCombined', (tester) async {
    //
    final onCombined = OnCombined((_) => _);
    expect(onCombinedCall(onCombined, 'data'), 'data');
    expect(onCombinedCall(onCombined, 'data', isWaiting: true), 'data');
    expect(onCombinedCall(onCombined, 'data', error: 'Error'), 'data');
    expect(onCombinedCall(onCombined, 'data', data: 'd'), 'data');
  });

  testWidgets('OnCombined in widget', (tester) async {
    int onSetState = 0;
    int onBuild = 0;
    final counter = RM.inject(
      () => 0,
      onSetState: On(() => ++onSetState),
    );

    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: OnCombined((_) => Text('${++onBuild}')).listenTo([counter]),
    );
    await tester.pumpWidget(widget);
    expect(onSetState, 0);
    expect(find.text('1'), findsOneWidget);
    //
    counter.setState(
        (s) => Future.delayed(
              Duration(seconds: 1),
              () => throw Exception('Error'),
            ),
        catchError: true);
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(onSetState, 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('3'), findsOneWidget);
    expect(onSetState, 2);
  });

  testWidgets('OnCombined.data', (tester) async {
    //
    final onCombined = OnCombined.data((_) => _);
    expect(onCombinedCall(onCombined, 'data'), 'data');
    expect(onCombinedCall(onCombined, 'data', isWaiting: true), 'data');
    expect(onCombinedCall(onCombined, 'data', error: 'Error'), 'data');
    expect(onCombinedCall(onCombined, 'data', data: 'd'), 'data');
  });

  testWidgets('OnCombined.data in widget', (tester) async {
    int onSetState = 0;
    int onBuild = 0;
    final counter = RM.inject(
      () => 0,
      onSetState: On.data(() => ++onSetState),
    );

    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: OnCombined.data((_) => Text('${++onBuild}')).listenTo([counter]),
    );
    await tester.pumpWidget(widget);
    expect(onSetState, 0);
    expect(find.text('1'), findsOneWidget);
    //
    counter.setState(
        (s) => Future.delayed(
              Duration(seconds: 1),
              () => throw Exception('Error'),
            ),
        catchError: true);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(onSetState, 0);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(onSetState, 0);
  });

  testWidgets('OnCombined.waiting', (tester) async {
    //
    final onCombined = OnCombined.waiting(() => 'Waiting');
    expect(onCombinedCall(onCombined, 'data'), 'Waiting');
    expect(onCombinedCall(onCombined, 'data', isWaiting: true), 'Waiting');
    expect(onCombinedCall(onCombined, 'data', error: 'Error'), null);
    expect(onCombinedCall(onCombined, 'data', data: 'd'), 'Waiting');
  });

  testWidgets('OnCombined.waiting in widget', (tester) async {
    int onSetState = 0;
    int onBuild = 0;
    final counter = RM.inject(
      () => 0,
      onSetState: On.waiting(() => ++onSetState),
    );

    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: OnCombined.waiting(() => Text('${++onBuild}')).listenTo([counter]),
    );
    await tester.pumpWidget(widget);
    expect(onSetState, 0);
    expect(find.text('1'), findsOneWidget);
    //
    counter.setState(
        (s) => Future.delayed(
              Duration(seconds: 1),
              () => throw Exception('Error'),
            ),
        catchError: true);
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(onSetState, 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);
    expect(onSetState, 1);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(onSetState, 1);
  });

  testWidgets('OnCombined.error', (tester) async {
    //
    final onCombined = OnCombined.error((_) => _);
    expect(onCombinedCall(onCombined, 'data'), null);
    expect(onCombinedCall(onCombined, 'data', isWaiting: true), null);
    expect(onCombinedCall(onCombined, 'data', error: 'Error'), 'Error');
    expect(onCombinedCall(onCombined, 'data', data: 'd'), null);
  });

  testWidgets('OnCombined.error in widget', (tester) async {
    int onSetState = 0;
    int onBuild = 0;
    final counter = RM.inject(
      () => 0,
      onSetState: On.error((_) => ++onSetState),
    );

    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: OnCombined.error((_) => Text('${++onBuild}')).listenTo([counter]),
    );
    await tester.pumpWidget(widget);
    expect(onSetState, 0);
    expect(find.text('1'), findsOneWidget);
    //
    counter.setState(
        (s) => Future.delayed(
              Duration(seconds: 1),
              () => throw Exception('Error'),
            ),
        catchError: true);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(onSetState, 0);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);
    expect(onSetState, 1);
    //
    counter.state++;
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(onSetState, 1);
  });

  testWidgets('OnCombined.all', (tester) async {
    //
    final onCombined = OnCombined.all(
      onIdle: () => 'Idle',
      onWaiting: () => 'Waiting',
      onError: (_) => _,
      onData: (_) => _,
    );
    expect(onCombinedCall(onCombined, 'data'), 'Idle');
    expect(onCombinedCall(onCombined, 'data', isWaiting: true), 'Waiting');
    expect(onCombinedCall(onCombined, 'data', error: 'Error'), 'Error');
    expect(onCombinedCall(onCombined, 'data', data: 'd'), 'data');
  });

  testWidgets('OnCombined.or, only or', (tester) async {
    //
    final onCombined = OnCombined.or(
      or: (_) => _,
    );
    expect(onCombinedCall(onCombined, 'Or'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', isWaiting: true), 'Or');
    expect(onCombinedCall(onCombined, 'Or', error: 'Error'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', data: 'd'), 'Or');
  });

  testWidgets('OnCombined.or, or with onIdle', (tester) async {
    //
    final onCombined = OnCombined.or(
      onIdle: () => 'Idle',
      or: (_) => _,
    );
    expect(onCombinedCall(onCombined, 'Or'), 'Idle');
    expect(onCombinedCall(onCombined, 'Or', isWaiting: true), 'Or');
    expect(onCombinedCall(onCombined, 'Or', error: 'Error'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', data: 'd'), 'Or');
  });

  testWidgets('OnCombined.or, or with onWaiting', (tester) async {
    //
    final onCombined = OnCombined.or(
      onWaiting: () => 'Waiting',
      or: (_) => _,
    );
    expect(onCombinedCall(onCombined, 'Or'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', isWaiting: true), 'Waiting');
    expect(onCombinedCall(onCombined, 'Or', error: 'Error'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', data: 'd'), 'Or');
  });

  testWidgets('OnCombined.or, or with onError', (tester) async {
    //
    final onCombined = OnCombined.or(
      onError: (_) => _,
      or: (_) => _,
    );
    expect(onCombinedCall(onCombined, 'Or'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', isWaiting: true), 'Or');
    expect(onCombinedCall(onCombined, 'Or', error: 'Error'), 'Error');
    expect(onCombinedCall(onCombined, 'Or', data: 'd'), 'Or');
  });

  testWidgets('OnCombined.or, or with onData', (tester) async {
    //
    final onCombined = OnCombined.or(
      onData: (_) => _,
      or: (_) => _,
    );
    expect(onCombinedCall(onCombined, 'Or'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', isWaiting: true), 'Or');
    expect(onCombinedCall(onCombined, 'Or', error: 'Error'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', data: 'd'), 'Or');
  });

  testWidgets('OnCombined.or, or with onData and onWaiting', (tester) async {
    //
    final onCombined = OnCombined.or(
      onWaiting: () => 'Waiting',
      onData: (_) => _,
      or: (_) => _,
    );
    expect(onCombinedCall(onCombined, 'Or'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', isWaiting: true), 'Waiting');
    expect(onCombinedCall(onCombined, 'Or', error: 'Error'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', data: 'd'), 'Or');
  });

  testWidgets('OnCombined.or, or with onData and onError', (tester) async {
    //
    final onCombined = OnCombined.or(
      onError: (_) => _,
      onData: (_) => _,
      or: (_) => _,
    );
    expect(onCombinedCall(onCombined, 'Or'), 'Or');
    expect(onCombinedCall(onCombined, 'Or', isWaiting: true), 'Or');
    expect(onCombinedCall(onCombined, 'Or', error: 'Error'), 'Error');
    expect(onCombinedCall(onCombined, 'Or', data: 'd'), 'Or');
  });

  testWidgets('OnCombined.or, or with all', (tester) async {
    //
    final onCombined = OnCombined.or(
      onIdle: () => 'Idle',
      onWaiting: () => 'Waiting',
      onError: (_) => _,
      onData: (_) => _,
      or: (_) => _,
    );
    expect(onCombinedCall(onCombined, 'Or'), 'Idle');
    expect(onCombinedCall(onCombined, 'Or', isWaiting: true), 'Waiting');
    expect(onCombinedCall(onCombined, 'Or', error: 'Error'), 'Error');
    expect(onCombinedCall(onCombined, 'Or', data: 'd'), 'Or');
  });
}

class _Model {
  int count;
  _Model(this.count);
  void incrementFuture() => Future.delayed(Duration(seconds: 1), () => count++);
  void incrementFutureWithError([String? error]) => Future.delayed(
      Duration(seconds: 1), () => throw Exception(error ?? 'Error Message'));
  Stream<void> incrementStream() async* {
    await Future.delayed(Duration(seconds: 1), () => count++);
    yield null;
    await Future.delayed(Duration(seconds: 1), () => count++);
    yield null;
    await Future.delayed(Duration(seconds: 1), () => count++);
    yield null;
  }

  Stream<void> incrementStreamWithError() async* {
    await Future.delayed(Duration(seconds: 1), () => count++);

    yield null;
    await Future.delayed(Duration(seconds: 1), () => count++);

    yield null;
    await Future.delayed(Duration(seconds: 1), () => count--);
    yield null;
    throw Exception('Error Message');
  }
}
