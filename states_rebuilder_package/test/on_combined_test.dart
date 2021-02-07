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
