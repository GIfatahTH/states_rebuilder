import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
          builder: On(
            () => Text(
              model.state.toString(),
            ),
          ),
          sideEffect: SideEffect(
            initState: () {
              print('initState');
            },
            onSetState: On(
              () {
                print('onSetState');
              },
            ),
            onAfterBuild: On(
              () {
                print('onAfterBuild');
              },
            ),
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
          builder: On(
            () => Text(
              model.state.toString(),
            ),
          ),
          sideEffect: SideEffect(
            initState: () {
              print('initState');
            },
            onSetState: On(
              () {
                print('onSetState');
              },
            ),
            onAfterBuild: On(
              () {
                print('onAfterBuild');
              },
            ),
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
        child: OnBuilder(
          listenTo: myState,
          builder: On.all(
            onIdle: () => Text('onIdle'),
            onWaiting: () => Text('onWaiting'),
            onError: (err, refreshError) => Text('onError'),
            onData: () => Text(myState.state.toString()),
          ),
          sideEffect: SideEffect(
            initState: () => print('initState'),
            onSetState: On(() => print('onSetState')),
            onAfterBuild: On(() => print('onAfterBuild')),
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
        child: OnBuilder(
          listenToMany: [myState1, myState2],
          builder: On.or(
            onIdle: () => Text('onIdle'),
            onWaiting: () => Text('onWaiting'),
            onError: (err, refreshError) => Text('$err'),
            or: () => Text('or'),
          ),
          sideEffect: SideEffect(
            onSetState: On.or(
              onIdle: () => onSetState = 'onIdle',
              onWaiting: () => onSetState = 'onWaiting',
              onError: (err, refreshError) => onSetState = err,
              or: () => onSetState = 'or',
            ),
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
          print(value);
          return OnBuilder(
            listenTo: animation,
            builder: On(
              () {
                print('on');
                return Container();
              },
            ),
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(value, 0);
      await tester.pumpAndSettle();
      expect(value, 10);
    },
  );
}
