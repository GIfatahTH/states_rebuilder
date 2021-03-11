import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

void main() {
  testWidgets('On', (tester) async {
    //
    final on = On(() => 'data');
    expect(onCall(on), 'data');
    expect(onCall(on, isWaiting: true), 'data');
    expect(onCall(on, error: 'Error'), 'data');
    expect(onCall(on, data: 'd'), 'data');
  });

  testWidgets('On in widget', (tester) async {
    int onSetState = 0;
    int onBuild = 0;
    final counter = RM.inject(
      () => 0,
      onSetState: On(() => ++onSetState),
    );

    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: On(() => Text('${++onBuild}')).listenTo(counter),
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
      /*catchError: true*/
    );
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(onSetState, 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('3'), findsOneWidget);
    expect(onSetState, 2);
  });

  testWidgets('On.data', (tester) async {
    //
    final on = On.data(() => 'data');
    expect(onCall(on), 'data');
    expect(onCall(on, isWaiting: true), 'data');
    expect(onCall(on, error: 'Error'), 'data');
    expect(onCall(on, data: 'd'), 'data');
  });

  testWidgets('On.data in widget', (tester) async {
    int onSetState = 0;
    int onBuild = 0;
    final counter = RM.inject(
      () => 0,
      onSetState: On.data(() => ++onSetState),
    );

    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: On.data(() => Text('${++onBuild}')).listenTo(counter),
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
      /*catchError: true*/
    );
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(onSetState, 0);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(onSetState, 0);
  });
  testWidgets('On.waiting', (tester) async {
    //
    final on = On.waiting(() => 'Waiting');
    expect(onCall(on), 'Waiting');
    expect(onCall(on, isWaiting: true), 'Waiting');
    expect(onCall(on, error: 'Error'), null);
    expect(onCall(on, data: 'd'), 'Waiting');
  });

  testWidgets('On.waiting in widget', (tester) async {
    int onSetState = 0;
    int onBuild = 0;
    final counter = RM.inject(
      () => 0,
      onSetState: On.waiting(() => ++onSetState),
    );

    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: On.waiting(() => Text('${++onBuild}')).listenTo(counter),
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
      /*catchError: true*/
    );
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

  testWidgets('On.error', (tester) async {
    //
    final on = On.error((_, __) => _);
    expect(onCall(on), null);
    expect(onCall(on, isWaiting: true), null);
    expect(onCall(on, error: 'Error'), 'Error');
    expect(onCall(on, data: 'd'), null);
  });

  testWidgets('On.error in widget', (tester) async {
    int onSetState = 0;
    int onBuild = 0;
    final counter = RM.inject(
      () => 0,
      onSetState: On.error((_, __) => ++onSetState),
    );

    final widget = Directionality(
      textDirection: TextDirection.rtl,
      child: On.error((_, __) => Text('${++onBuild}')).listenTo(counter),
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
      /*catchError: true*/
    );
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
  testWidgets('On.all', (tester) async {
    //
    final on = On.all(
      onIdle: () => 'Idle',
      onWaiting: () => 'Waiting',
      onError: (_, __) => _,
      onData: () => 'Data',
    );
    expect(onCall(on), 'Idle');
    expect(onCall(on, isWaiting: true), 'Waiting');
    expect(onCall(on, error: 'Error'), 'Error');
    expect(onCall(on, data: 'd'), 'Data');
  });
  testWidgets('On.or, only or', (tester) async {
    //
    final on = On.or(or: () => 'Or');
    expect(onCall(on), 'Or');
    expect(onCall(on, isWaiting: true), 'Or');
    expect(onCall(on, error: 'Error'), 'Or');
    expect(onCall(on, data: 'd'), 'Or');
  });
  testWidgets('On.or, or with onIdle', (tester) async {
    //
    final on = On.or(onIdle: () => 'Idle', or: () => 'Or');
    expect(onCall(on), 'Idle');
    expect(onCall(on, isWaiting: true), 'Or');
    expect(onCall(on, error: 'Error'), 'Or');
    expect(onCall(on, data: 'd'), 'Or');
  });
  testWidgets('On.or, or with onWaiting', (tester) async {
    //
    final on = On.or(
      onWaiting: () => 'Waiting',
      or: () => 'Or',
    );
    expect(onCall(on), 'Or');
    expect(onCall(on, isWaiting: true), 'Waiting');
    expect(onCall(on, error: 'Error'), 'Or');
    expect(onCall(on, data: 'd'), 'Or');
  });
  testWidgets('On.or, or with onError', (tester) async {
    //
    final on = On.or(
      onError: (_, __) => _,
      or: () => 'Or',
    );
    expect(onCall(on), 'Or');
    expect(onCall(on, isWaiting: true), 'Or');
    expect(onCall(on, error: 'Error'), 'Error');
    expect(onCall(on, data: 'd'), 'Or');
  });
  testWidgets('On.or, or with onData', (tester) async {
    //
    final on = On.or(
      onData: () => 'Data',
      or: () => 'Or',
    );
    expect(onCall(on), 'Or');
    expect(onCall(on, isWaiting: true), 'Or');
    expect(onCall(on, error: 'Error'), 'Or');
    expect(onCall(on, data: 'd'), 'Data');
  });
  testWidgets('On.or, or with onData and onWaiting', (tester) async {
    //
    final on = On.or(
      onWaiting: () => 'Waiting',
      onData: () => 'Data',
      or: () => 'Or',
    );
    expect(onCall(on), 'Or');
    expect(onCall(on, isWaiting: true), 'Waiting');
    expect(onCall(on, error: 'Error'), 'Or');
    expect(onCall(on, data: 'd'), 'Data');
  });
  testWidgets('On.or, or with onData and onError', (tester) async {
    //
    final on = On.or(
      onError: (_, __) => _,
      onData: () => 'Data',
      or: () => 'Or',
    );
    expect(onCall(on), 'Or');
    expect(onCall(on, isWaiting: true), 'Or');
    expect(onCall(on, error: 'Error'), 'Error');
    expect(onCall(on, data: 'd'), 'Data');
  });
  testWidgets('On.or, or with onWaiting, onData and onError', (tester) async {
    //
    final on = On.or(
      onWaiting: () => 'Waiting',
      onError: (_, __) => _,
      onData: () => 'Data',
      or: () => 'Or',
    );
    expect(onCall(on), 'Or');
    expect(onCall(on, isWaiting: true), 'Waiting');
    expect(onCall(on, error: 'Error'), 'Error');
    expect(onCall(on, data: 'd'), 'Data');
  });

  testWidgets('On.or, or with all', (tester) async {
    //
    final on = On.or(
      onIdle: () => 'Idle',
      onWaiting: () => 'Waiting',
      onError: (_, __) => _,
      onData: () => 'Data',
      or: () => 'Or',
    );
    expect(onCall(on), 'Idle');
    expect(onCall(on, isWaiting: true), 'Waiting');
    expect(onCall(on, error: 'Error'), 'Error');
    expect(onCall(on, data: 'd'), 'Data');
  });

  testWidgets('On.erro when return void', (tester) async {
    String? error;
    //
    final on = On<void>.error((_, __) => error = 'error: ' + _);
    onCall(on, isSideEffect: true);
    expect(error, null);
    onCall(on, isWaiting: true, isSideEffect: true);
    expect(error, null);
    onCall(on, error: 'Error', isSideEffect: true);
    expect(error, 'error: Error');
    error = null;
    onCall(on, data: 'data', isSideEffect: true);
    expect(error, null);
  });
}
