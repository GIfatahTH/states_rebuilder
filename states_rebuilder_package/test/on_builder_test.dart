import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'OnBuilder On()',
    (tester) async {
      final model = 0.inj();
      final Widget widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnBuilder(
          listenTo: model,
          debugPrintWhenRebuild: '',
          builder: () => Text(
            model.state.toString(),
          ),
          sideEffects: SideEffects(
            initState: () {
              print('initState');
            },
            onSetState: (_) {
              print('onSetState');
            },
            onAfterBuild: () {
              print('onAfterBuild');
            },
            dispose: () {
              print('dispose');
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      model.state++;
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'OnBuilder list On()',
    (tester) async {
      final model = 0.inj();
      final Widget widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnBuilder(
          listenToMany: [model],
          debugPrintWhenRebuild: '',
          builder: () => Text(
            model.state.toString(),
          ),
          sideEffects: SideEffects(
            initState: () {
              print('initState');
            },
            onSetState: (_) {
              print('onSetState');
            },
            onAfterBuild: () {
              print('onAfterBuild');
            },
            dispose: () {
              print('dispose');
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      model.state++;
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'OnBuilder On.All()',
    (tester) async {
      final myState = RM.inject(() => 0);
      final Widget widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnBuilder<int>.all(
          listenTo: myState,
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('onWaiting'),
          onError: (err, refreshError) => Text('onError'),
          onData: (data) => Text(data.toString()),
          sideEffects: SideEffects(
            initState: () => print('initState'),
            onSetState: (_) => print('onSetState'),
            onAfterBuild: () => print('onAfterBuild'),
            dispose: () => print('dispose'),
          ),
          shouldRebuild: (oldSnap, newSnap) {
            return true;
          },
          debugPrintWhenRebuild: '',
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);
      myState.state++;
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'OnBuilder list On.or()',
    (tester) async {
      final myState1 = RM.inject(() => 0);
      final myState2 = RM.inject(() => '0');
      String onSetState = '';
      late SnapState shouldRebuild;
      final Widget widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnBuilder.orElse(
          listenToMany: [myState1, myState2],
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('onWaiting'),
          onError: (err, refreshError) => Text('$err'),
          orElse: (data) => Text('or'),
          sideEffects: SideEffects(
            onSetState: (snap) {
              snap.onOrElse(
                onIdle: () => onSetState = 'onIdle',
                onWaiting: () => onSetState = 'onWaiting',
                onError: (err, refreshError) => onSetState = err,
                orElse: (_) => onSetState = 'or',
              );
            },
          ),
          shouldRebuild: (oldSnap, newSnap) {
            shouldRebuild = newSnap;
            return true;
          },
          debugPrintWhenRebuild: '',
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);
      //
      myState1.state++;
      await tester.pump();
      expect(find.text('onIdle'), findsOneWidget);
      expect(onSetState, 'onIdle');
      expect(shouldRebuild.toString(), 'SnapState<int>(hasData: 1)');
      //
      myState2.state = '1';
      await tester.pump();
      expect(find.text('or'), findsOneWidget);
      expect(onSetState, 'or');
      expect(shouldRebuild.toString(), 'SnapState<String>(hasData: 1)');

      //
      myState1.setState((s) => Future.delayed(0.seconds));
      await tester.pump();
      expect(find.text('onWaiting'), findsOneWidget);
      expect(onSetState, 'onWaiting');
      expect(shouldRebuild.toString(), 'SnapState<int>(isWaiting (FUTURE): 1)');

      //
      await tester.pump(1.seconds);
      expect(find.text('or'), findsOneWidget);
      expect(onSetState, 'or');
      expect(shouldRebuild.toString(), 'SnapState<int>(hasData: 1)');

      //
      myState2.setState((s) => throw 'error2');
      await tester.pump();
      expect(find.text('error2'), findsOneWidget);
      expect(onSetState, 'error2');
      expect(shouldRebuild.toString(), 'SnapState<String>(hasError: error2)');
    },
  );

  testWidgets(
    'OnAnimationBuilder',
    (tester) async {
      final animation = RM.injectAnimation(
        duration: 1.seconds,
        shouldAutoStart: true,
      );
      late double value;
      final widget = OnAnimationBuilder(
        listenTo: animation,
        onInitialized: () {},
        builder: (animate) {
          value =
              animate.fromTween((currentValue) => Tween(begin: 0, end: 10))!;
          return OnBuilder(
            listenTo: animation,
            builder: () {
              return Container();
            },
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(value, 0);
      await tester.pumpAndSettle();
      expect(value, 10);
    },
  );

  testWidgets(
    'Test OnFutureBuilder functionality',
    (tester) async {
      bool shouldThrow = false;
      final future1 = RM.injectFuture(
        () async {
          await Future.delayed(1.seconds);
          if (shouldThrow) {
            throw 'Error1';
          }
        },
      );
      final future2 = RM.injectFuture(() => Future.delayed(1.seconds, () => 1));
      var refresh1;
      var refresh2;
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            OnFutureBuilder(
              future: () => future1.stateAsync,
              onWaiting: () => Text('isWaiting1'),
              onError: (err, refresh) {
                refresh1 = refresh;
                return Text('$err');
              },
              onData: (data, refresh) {
                refresh1 = refresh;
                return Text('$data');
              },
            ),
            OnFutureBuilder<int>(
              future: () => future2.stateAsync,
              onWaiting: () => Text('isWaiting2'),
              onError: (err, refresh) {
                return Text('Error2');
              },
              onData: (data, refresh) {
                refresh2 = refresh;
                return Text('$data');
              },
            ),
          ],
        ),
      );

      await tester.pumpWidget(widget);

      expect(find.text('isWaiting1'), findsOneWidget);
      expect(find.text('isWaiting2'), findsOneWidget);

      await tester.pump(1.seconds);

      expect(find.text('null'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      future1.refresh();
      refresh1();
      await tester.pump();
      expect(find.text('isWaiting1'), findsOneWidget);
      expect(find.text('isWaiting2'), findsNothing);

      await tester.pump(1.seconds);

      expect(find.text('null'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      //
      future2.refresh();
      refresh2();
      await tester.pump();
      expect(find.text('isWaiting1'), findsNothing);
      expect(find.text('isWaiting2'), findsOneWidget);

      await tester.pump(1.seconds);

      expect(find.text('null'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      //
      //
      shouldThrow = true;
      future1.refresh();
      refresh1();
      refresh1 = null;
      await tester.pump();
      expect(find.text('isWaiting1'), findsOneWidget);
      expect(find.text('isWaiting2'), findsNothing);

      await tester.pump(1.seconds);

      expect(find.text('Error1'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      //
      shouldThrow = false;
      future1.refresh();
      refresh1();
      await tester.pump();
      expect(find.text('isWaiting1'), findsOneWidget);
      expect(find.text('isWaiting2'), findsNothing);

      await tester.pump(1.seconds);

      expect(find.text('null'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'Test OnStreamBuilder functionality',
    (tester) async {
      bool shouldThrow = true;
      var refresh;
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnStreamBuilder(
          stream: () async* {
            await Future.delayed(1.seconds);
            yield 0;
            await Future.delayed(1.seconds);
            yield 1;
            await Future.delayed(1.seconds);
            if (shouldThrow) {
              throw 'Error';
            }
            yield 2;
          },
          onWaiting: () => Text('onWaiting'),
          onError: (err, ref) {
            refresh = ref;
            return Text('$err');
          },
          onData: (d) => Text('$d'),
          onDone: (d) => Text('onDone: $d'),
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('onWaiting'), findsOneWidget);
      await tester.pump(1.seconds);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(1.seconds);
      expect(find.text('1'), findsOneWidget);
      await tester.pump(1.seconds);
      expect(find.text('Error'), findsOneWidget);
      //
      shouldThrow = false;
      refresh();
      await tester.pumpWidget(widget);
      expect(find.text('onWaiting'), findsOneWidget);
      await tester.pump(1.seconds);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(1.seconds);
      expect(find.text('1'), findsOneWidget);
      await tester.pump(1.seconds);
      expect(find.text('onDone: 2'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN generic type is given for OnBuilder with many listeners'
    'THEN the first model of the same type is always exposed',
    (tester) async {
      final model1 = 0.inj();
      final model2 = true.inj();
      var exposedModel;
      int numberOfRebuild = 0;
      final widget = OnBuilder<int>.data(
        listenToMany: [model1, model2],
        builder: (data) {
          exposedModel = data;
          numberOfRebuild++;
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(exposedModel, 0);
      expect(numberOfRebuild, 1);
      model1.state++;
      await tester.pump();
      expect(exposedModel, 1);
      expect(numberOfRebuild, 2);
      model2.toggle();
      await tester.pump();
      expect(exposedModel, 1);
      expect(numberOfRebuild, 3);
      model1.setState((s) => Future.delayed(1.seconds, () => 3));
      await tester.pump();
      expect(exposedModel, 1);
      expect(numberOfRebuild, 3);
      await tester.pump(1.seconds);
      expect(exposedModel, 3);
      expect(numberOfRebuild, 4);
    },
  );

  testWidgets(
    'WHEN generic type is not given for OnBuilder with many listeners'
    'THEN the model that emits the notification is exposed',
    (tester) async {
      final model1 = 0.inj();
      final model2 = true.inj();
      var exposedModel;
      int numberOfRebuild = 0;
      final widget = OnBuilder.data(
        listenToMany: [model1, model2],
        builder: (data) {
          exposedModel = data;
          numberOfRebuild++;
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(exposedModel, 0);
      expect(numberOfRebuild, 1);
      model1.state++;
      await tester.pump();
      expect(exposedModel, 1);
      expect(numberOfRebuild, 2);
      model2.toggle();
      await tester.pump();
      expect(exposedModel, false);
      expect(numberOfRebuild, 3);
      model1.setState((s) => Future.delayed(1.seconds, () => 3));
      await tester.pump();
      expect(exposedModel, false);
      expect(numberOfRebuild, 3);
      await tester.pump(1.seconds);
      expect(exposedModel, 3);
      expect(numberOfRebuild, 4);
    },
  );
}
