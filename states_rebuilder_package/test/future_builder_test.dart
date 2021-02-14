import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

import 'fake_classes/models.dart';
import 'injected_test.dart';

final vanillaModel = RM.inject(() => VanillaModel());

void main() {
  testWidgets('Injected.futureBuilder without error', (tester) async {
    final widget = vanillaModel.futureBuilder(
      future: (s, _) => s?.incrementAsync().then(
            (_) => Future.delayed(
              Duration(seconds: 1),
              () => VanillaModel(5),
            ),
          ),
      onWaiting: () => Text('waiting ...'),
      onError: null,
      onData: (rm) {
        return Text('data');
      },
      dispose: () {},
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('data'), findsOneWidget);
  });

  testWidgets('Injected.futureBuilder with error', (tester) async {
    final widget = vanillaModel.futureBuilder(
      future: (s, _) => s?.incrementAsyncWithError().then(
            (_) => Future.delayed(
              Duration(seconds: 1),
              () => VanillaModel(5),
            ),
          ),
      onWaiting: () => Text('waiting ...'),
      onError: (e) => Text('${e.message}'),
      onData: (rm) {
        return Text('data');
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets('futureBuilder do not call global onData if types are different',
      (tester) async {
    String? data;

    final modelFuture = RM.inject(
      () => VanillaModel(),
      onData: (_) => data = 'Data from global $_',
    );
    await tester.pumpWidget(modelFuture.futureBuilder(
      future: (s, __) => s?.incrementAsync(), //return int
      onWaiting: () => Container(),
      onError: (_) => Container(),
      onData: (_) => Container(),
    ));

    await tester.pump(Duration(seconds: 1));
    expect(data, null); //mutable and future return different type
    //
  });

  testWidgets(
      'futureBuilder call global onData if types are the same (immutable)',
      (tester) async {
    String? data;

    final modelFuture = RM.inject(
      () => VanillaModel(),
      onData: (_) => data = 'Data from global $_',
    );
    await tester.pumpWidget(modelFuture.futureBuilder(
      future: (s, __) => s?.incrementAsyncImmutable(),
      onWaiting: () => Container(),
      onError: (_) => Container(),
      onData: (_) => Container(),
    ));

    await tester.pump(Duration(seconds: 1));
    expect(data,
        'Data from global VanillaModel(1)'); //mutable and future return different type
    //
  });

  testWidgets('futureBuilder call global onError', (tester) async {
    String? error;

    final modelFuture = RM.inject(
      () => VanillaModel(),
      onError: (_, __) => error = 'Error from global $_',
    );
    await tester.pumpWidget(modelFuture.futureBuilder(
      future: (s, __) => s?.incrementAsyncWithError(),
      onWaiting: () => Container(),
      onError: (_) => Container(),
      onData: (_) => Container(),
    ));

    await tester.pump(Duration(seconds: 1));
    expect(error,
        'Error from global Exception: Error message'); //mutable and future return different type
    //
  });
}
