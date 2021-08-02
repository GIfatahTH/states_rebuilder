import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';

void main() {
  testWidgets(
    'test on method',
    (tester) async {
      final model = RM.inject(() => 0);
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: model.rebuild(
          () {
            return Text(model.state.toString());
          },
          initState: () {
            print('initState');
          },
          dispose: () {},
          onAfterBuild: On(() {
            print('onAfterBuild');
          }),
          onSetState: On(() {
            print('onSetState');
          }),
          shouldRebuild: (_) {
            return true;
          },
          // watch: () {},
          debugPrintWhenRebuild: '',
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
    'test on.data method',
    (tester) async {
      final model = RM.inject(() => 0);
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: model.rebuild.onData(
          () {
            return Text(model.state.toString());
          },
          initState: () {
            print('initState');
          },
          dispose: () {},
          onAfterBuild: On(() {
            print('onAfterBuild');
          }),
          onSetState: On(() {
            print('onSetState');
          }),
          shouldRebuild: (_) {
            return true;
          },
          // watch: () {},
          debugPrintWhenRebuild: '',
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      model.state++;
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    },
  );

  //
  testWidgets(
    'test on.all method',
    (tester) async {
      final model = RM.inject(() => 0);
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: model.rebuild.onAll(
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('onWaiting'),
          onError: (err, refresh) => Text('onError'),
          onData: () => Text('onData'),
          initState: () {
            print('initState');
          },
          dispose: () {},
          onAfterBuild: On(() {
            print('onAfterBuild');
          }),
          onSetState: On(() {
            print('onSetState');
          }),
          shouldRebuild: (_) {
            return true;
          },
          // watch: () {},
          debugPrintWhenRebuild: '',
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);
      model.setState((s) => Future.delayed(Duration(seconds: 1)));
      await tester.pump();
      expect(find.text('onWaiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('onData'), findsOneWidget);
    },
  );

  testWidgets(
    'test on.or method',
    (tester) async {
      final model = RM.inject(() => 0);
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: model.rebuild.onOr(
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('onWaiting'),
          onError: (err, refresh) => Text('onError'),
          or: () => Text('onData'),
          initState: () {
            print('initState');
          },
          dispose: () {},
          onAfterBuild: On(() {
            print('onAfterBuild');
          }),
          onSetState: On(() {
            print('onSetState');
          }),
          shouldRebuild: (_) {
            return true;
          },
          // watch: () {},
          debugPrintWhenRebuild: '',
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);
      model.setState((s) => Future.delayed(Duration(seconds: 1)));
      await tester.pump();
      expect(find.text('onWaiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('onData'), findsOneWidget);
    },
  );
  testWidgets(
    'test on.future method',
    (tester) async {
      final model =
          RM.injectFuture(() => Future.delayed(Duration(seconds: 1), () => 1));
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: model.rebuild.onFuture<int>(
          future: () => model.stateAsync,
          onWaiting: () => Text('onWaiting'),
          onError: (err, refresh) => Text('onError'),
          onData: (f, _) => Text('onData'),
          initState: () {
            print('initState');
          },
          dispose: () {},
          onAfterBuild: On(() {
            print('onAfterBuild');
          }),
          onSetState: On(() {
            print('onSetState');
          }),
          shouldRebuild: (_) {
            return true;
          },
          // watch: () {},
          debugPrintWhenRebuild: '',
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('onWaiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('onData'), findsOneWidget);
    },
  );
}
