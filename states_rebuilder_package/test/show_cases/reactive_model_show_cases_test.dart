import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

void main() {
  testWidgets('simple counter app', (tester) async {
    final rm = RM.inject(() => 0);
    final widget = On.data(
      () => Directionality(
        textDirection: TextDirection.ltr,
        child: Text('${rm.state}'),
      ),
    ).listenTo(rm);
    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);
    rm.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('simple Future counter  app1', (tester) async {
    final rm = RM.injectFuture(
      () => Future.delayed(Duration(seconds: 1), () => 1),
    );

    final widget = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => On.or(
            onWaiting: () => CircularProgressIndicator(),
            or: () => Text('${rm.state}'),
          ).listenTo(
            rm,
            onAfterBuild: On.waiting(
              () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Container(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('async counter without / with error', (tester) async {
    final rm = RM.inject(() => _Model(0));
    final widget = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => On.all(
            onIdle: () => Text('Idle'),
            onWaiting: () => CircularProgressIndicator(),
            onError: (err) => Text('${err.message}'),
            onData: () => Text('${rm.state.count}'),
          ).listenTo(
            rm,
            onSetState: On.or(
              onWaiting: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                rm.state.count > 1
                    ? ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Greater then 1 from SnackBar'),
                        ),
                      )
                    : null;
              },
              onError: (err) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error from SnackBar'),
                  ),
                );
              },
              or: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(widget);
    expect(find.text('Idle'), findsOneWidget);

    //
    //Future without error
    rm.setState((s) => s.incrementFuture());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);
    //
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    //
    //Stream without error
    rm.setState((s) => s.incrementStream());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);
    //
    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    expect(find.text('3'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    expect(find.text('4'), findsOneWidget);
    //
    //
    await tester.pump(Duration(seconds: 1));
    expect(find.text('4'), findsOneWidget);

    //
    //Future with error
    rm.setState((s) => s.incrementFutureWithError());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Greater then 1 from SnackBar'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error Message'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Error from SnackBar'), findsOneWidget);

    //
    //Stream with error
    rm.setState((s) => s.incrementStreamWithError());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Greater then 1 from SnackBar'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    expect(find.text('5'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    expect(find.text('6'), findsOneWidget);
    //
    await tester.pump(Duration(seconds: 1));
    expect(rm.state.count, 5);
    expect(find.text('Error Message'), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Error from SnackBar'), findsOneWidget);
  });

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
    final widget = Directionality(
      textDirection: TextDirection.ltr,
      child: OnCombined.all(
        onIdle: () => Text('Idle'),
        onWaiting: () => Text('Waiting'),
        onError: (e) => Text('${e.message}'),
        onData: (_) => Text(
          '${rm1.state.count}-${rm2.state.count}-${rm3.state.count}',
        ),
      ).listenTo([rm1, rm2, rm3]),
    );
    await tester.pumpWidget(widget);
    expect(find.text('Idle'), findsOneWidget);
    //
    rm1.setState((s) => s.incrementFuture());
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
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
