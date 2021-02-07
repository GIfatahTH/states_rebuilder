import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

import 'injected_test.dart';

final vanillaModel = RM.inject(() => VanillaModel());

void main() {
  testWidgets('On.futurewithout error', (tester) async {
    final widget = On.future(
      onWaiting: () => Text('waiting ...'),
      onError: null,
      onData: (rm) {
        return Text('data');
      },
    ).future(
      () => vanillaModel.state.incrementAsync().then(
            (_) => Future.delayed(
              Duration(seconds: 1),
              () => VanillaModel(5),
            ),
          ),
      dispose: () {},
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('data'), findsOneWidget);
  });

  testWidgets('On.futurewith error', (tester) async {
    final widget = On.future(
      onWaiting: () => Text('waiting ...'),
      onError: (e) => Text('${e.message}'),
      onData: (rm) {
        return Text('data');
      },
    ).future(
      () => vanillaModel.state.incrementError().then(
            (_) => Future.delayed(
              Duration(seconds: 1),
              () => VanillaModel(5),
            ),
          ),
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets('On.future do not call global onData if types are different',
      (tester) async {
    String? data;

    final modelFuture = RM.inject(
      () => VanillaModel(),
      onData: (_) => data = 'Data from global $_',
    );
    await tester.pumpWidget(
      On.future(
        onWaiting: () => Container(),
        onError: (_) => Container(),
        onData: (_) => Container(),
      ).future(
        modelFuture.future(
          (s) => s.incrementAsync(),
        ),
      ), //return int
    );

    await tester.pump(Duration(seconds: 1));
    expect(data, null); //mutable and future return different type
    //
  });

  testWidgets('On.future call global onData if types are the same (immutable)',
      (tester) async {
    String? data;

    final modelFuture = RM.inject(
      () => VanillaModel(),
      onData: (_) => data = 'Data from global $_',
    );

    await tester.pumpWidget(On.future(
      onWaiting: () => Container(),
      onError: (_) => Container(),
      onData: (_) => Container(),
    ).future(
      modelFuture.future((s) => s.incrementAsyncImmutable()),
    ));

    await tester.pump(Duration(seconds: 1));
    expect(data,
        'Data from global VanillaModel(1)'); //mutable and future return different type
    //
  });

  testWidgets('On.future call global onError', (tester) async {
    String? error;

    final modelFuture = RM.inject(
      () => VanillaModel(),
      onError: (_, __) => error = 'Error from global $_',
    );

    await tester.pumpWidget(On.future(
      onWaiting: () => Container(),
      onError: (_) => Container(),
      onData: (_) => Container(),
    ).future(modelFuture.future((s) => s.incrementError())));

    await tester.pump(Duration(seconds: 1));
    expect(error,
        'Error from global Exception: Error message'); //mutable and future return different type
    //
  });

  testWidgets('On.future listen only one time', (tester) async {
    final counter = RM.injectFuture(
      () => Future.delayed(Duration(seconds: 1), () => 1),
    );

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: On.future(
        onWaiting: () => Text('Waiting...'),
        onError: (_) => Text('Error'),
        onData: (_) => Text(counter.state.toString()),
      ).future(() => counter.stateAsync),
    ));
    expect(find.text('Waiting...'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    expect(find.text('1'), findsOneWidget);
    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 2));
    await tester.pump();
    expect(find.text('Waiting...'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsNothing);
  });

  testWidgets(
      'On.future with listenTo listen  listen to onData after initial future',
      (tester) async {
    final counter = RM.injectFuture(
      () => Future.delayed(Duration(seconds: 1), () => 1),
    );

    int numberOfRebuild = 0;

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: On.future(
        onWaiting: () => Text('Waiting...'),
        onError: (_) => Text('Error'),
        onData: (_) => Text('${counter.state}-${++numberOfRebuild}'),
      ).listenTo(counter),
    ));
    expect(find.text('Waiting...'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    expect(find.text('1-1'), findsOneWidget);
    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 2));
    await tester.pump();
    expect(find.text('Waiting...'), findsNothing);
    expect(find.text('1-1'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('2-2'), findsOneWidget);
    //
    counter.state++;
    counter.setState((s) => throw Exception(), catchError: true);
    await tester.pump();
    expect(find.text('3-3'), findsOneWidget);
  });
}