import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'fake_classes/models.dart';
import 'fake_classes/test_widget.dart';

void main() {
  testWidgets(
    'WHEN state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.error and sync error',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model = RM.inject(
        () => shouldThrow ? throw Exception('Error') : 1,
        initialState: 0,
      );
      final widget = testWidget(
        On.error((err, refresh) {
          refresher = refresh;
          return Text('Error: ${model.state}');
        }).listenTo(model),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Error: 0'), findsOneWidget);
      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Error: 1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.or and sync error',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model = RM.inject(() => shouldThrow ? throw Exception('Error') : 1);
      final widget = testWidget(
        On.or(
          onError: (errn, refresh) {
            refresher = refresh;
            return Text('Error');
          },
          or: () => Text('Data: ${model.state}'),
        ).listenTo(
          model,
          debugPrintWhenRebuild: '',
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Error'), findsOneWidget);
      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Data: 1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.all and sync error'
    // 'On.all refreshes to isIdle',
    ,
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model = RM.inject(() => shouldThrow ? throw Exception('Error') : 1);
      final widget = testWidget(
        On.all(
          onIdle: () => Text('Idle'),
          onWaiting: () => Text('Waiting...'),
          onError: (errn, refresh) {
            refresher = refresh;
            return Text('Error');
          },
          onData: () => Text('Data: ${model.state}'),
        ).listenTo(model),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Error'), findsOneWidget);
      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Data: 1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.error and sync error'
    'SIDE EFFECTS',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model = RM.inject<int?>(
        () => shouldThrow ? throw Exception('Error') : 1,
        onSetState: On.error(
          (errn, refresh) => refresher = refresh,
        ),
      );
      final widget = testWidget(
        On.error((errn, refresh) {
          return Text('Error: ${model.state}');
        }).listenTo(model),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Error: null'), findsOneWidget);
      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Error: 1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.or and sync error'
    'SIDE EFFECTS',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model = RM.inject(
        () => shouldThrow ? throw Exception('Error') : 1,
        onSetState: On.or(
          onError: (errn, refresh) => refresher = refresh,
          or: () {},
        ),
      );
      final widget = testWidget(
        On.or(
          onError: (errn, refresh) {
            return Text('Error');
          },
          or: () => Text('Data: ${model.state}'),
        ).listenTo(model),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Error'), findsOneWidget);
      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Data: 1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN dependent state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.or and sync error',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model1 = RM.inject(
        () => shouldThrow ? throw Exception('Error') : 1,
      );
      final model2 = RM.inject<int>(
        () => model1.state * 10,
        dependsOn: DependsOn({model1}),
      );
      final widget = testWidget(
        On.or(
          onError: (errn, refresh) {
            refresher = refresh;
            return Text('Error');
          },
          or: () => Text('Data: ${model2.state}'),
        ).listenTo(model2),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
      expect(find.text('Error'), findsOneWidget);
      shouldThrow = false;
      refresher();
      await tester.pump();
      await tester.pump();
      await tester.pump();
      //expect(find.text('Data: 10'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.or and ASYNC error created with RM.injectFuture',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model = RM.injectFuture(
        () => Future.delayed(
          Duration(seconds: 1),
          () => shouldThrow ? throw Exception('Error') : 1,
        ),
      );
      final widget = testWidget(
        On.or(
          onWaiting: () => Text('Waiting...'),
          onError: (errn, refresh) {
            refresher = refresh;
            return Text('Error');
          },
          or: () => Text('Data: ${model.state}'),
        ).listenTo(model),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error'), findsOneWidget);

      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Data: 1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.all and ASYNC error created with setState',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model = RM.inject(
        () => 0,
        onSetState: On.error((errn, refresh) => refresher = refresh),
      );

      final widget = testWidget(
        On.all(
          onIdle: () => Text('Idle'),
          onWaiting: () => Text('Waiting...'),
          onError: (errn, refresh) {
            return Text('Error');
          },
          onData: () => Text('Data: ${model.state}'),
        ).listenTo(model),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Idle'), findsOneWidget);

      model.setState(
        (s) => Future.delayed(
          Duration(seconds: 1),
          () => shouldThrow ? throw Exception('Error') : 1,
        ),
      );
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error'), findsOneWidget);

      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Data: 1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN dependent state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.all and ASYNC error created with setState',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model1 = RM.inject(() => 0);
      final model2 = RM.inject<int>(
        () => model1.state * 10,
        dependsOn: DependsOn({model1}),
      );

      final widget = testWidget(
        On.all(
          onIdle: () => Text('Idle'),
          onWaiting: () => Text('Waiting...'),
          onError: (errn, refresh) {
            refresher = refresh;
            return Text('Error');
          },
          onData: () => Text('Data: ${model2.state}'),
        ).listenTo(model2),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Idle'), findsOneWidget);

      model1.setState(
        (s) => Future.delayed(
          Duration(seconds: 1),
          () => shouldThrow ? throw Exception('Error') : 1,
        ),
      );
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error'), findsOneWidget);

      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Data: 10'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN two dependent state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.all and ASYNC error',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model1 = RM.injectFuture(
        () => Future.delayed(
          Duration(seconds: 1),
          () => shouldThrow ? throw Exception('Error1') : 1,
        ),
        debugPrintWhenNotifiedPreMessage: 'model1',
      );
      final model2 = RM.injectFuture(
        () => Future.delayed(
          Duration(seconds: 1),
          () => shouldThrow ? throw Exception('Error2') : 2,
        ),
        debugPrintWhenNotifiedPreMessage: 'model2',
      );
      final model3 = RM.inject<int>(
        () => model1.state + model2.state,
        dependsOn: DependsOn({model1, model2}),
        debugPrintWhenNotifiedPreMessage: '',
      );

      final widget = testWidget(
        On.or(
          onWaiting: () => Text('Waiting...'),
          onError: (err, refresh) {
            refresher = refresh;
            return Text(err.message);
          },
          or: () => Text('Data: ${model3.state}'),
        ).listenTo(model3),
      );

      await tester.pumpWidget(widget);

      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error2'), findsOneWidget);

      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error1'), findsOneWidget);

      refresher();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Data: 3'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN combined state hasError'
    'THEN refresh can recall the creation Function'
    'CASE On.all and ASYNC error',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;
      final model1 = RM.injectFuture(
        () => Future.delayed(
          Duration(seconds: 1),
          () => shouldThrow ? throw Exception('Error1') : 1,
        ),
      );
      final model2 = RM.injectFuture(
        () => Future.delayed(
          Duration(seconds: 1),
          () => shouldThrow ? throw Exception('Error2') : 2,
        ),
      );

      final widget = testWidget(
        OnCombined.or(
          onWaiting: () => Text('Waiting...'),
          onError: (err, refresh) {
            refresher = refresh;
            return Text(err.message);
          },
          or: (_) => Text('Data: ${model1.state + model2.state}'),
        ).listenTo([model1, model2]),
      );

      await tester.pumpWidget(widget);

      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error1'), findsOneWidget);

      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error2'), findsOneWidget);

      refresher();
      await tester.pump();
      expect(find.text('Waiting...'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Data: 3'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN a future from the model throw'
    'THEN calling refresh will recall the future',
    (tester) async {
      bool shouldThrow = true;
      late void Function() refresher;

      final model = RM.inject(() => VanillaModel());
      final widget = testWidget(
        On.future(
          onWaiting: () => Text('Waiting..."'),
          onError: (err, refresh) {
            refresher = refresh;
            return Text('Error');
          },
          onData: (_, __) => Text('Data'),
        ).future(
          model.future(
            (s) =>
                shouldThrow ? s.incrementAsyncWithError() : s.incrementAsync(),
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('Waiting..."'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error'), findsOneWidget);
      //
      shouldThrow = false;
      refresher();
      await tester.pump();
      expect(find.text('Waiting..."'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Data'), findsOneWidget);
    },
  );
}
