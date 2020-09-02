import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/builders.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'WhenRebuilder widget, synchronous task, case one reactive model',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilder<Model1>(
              observe: () => Injector.getAsReactive<Model1>(),
              tag: 'tag1',
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              onError: (error) => Text('error'),
              onData: (data) => Text('data'),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

      final reactiveModel = Injector.getAsReactive<Model1>();
      reactiveModel.setState(null, filterTags: ['tag1']);
      await tester.pump();
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilder widget, synchronous task, case two reactive models',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1()), Inject(() => Model2())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilder<Model1>(
              observeMany: [
                () => Injector.getAsReactive<Model1>(),
                () => Injector.getAsReactive<Model2>()
              ],
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              onError: (error) => Text('error'),
              onData: (data) => Text('data'),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

      final reactiveModel1 = Injector.getAsReactive<Model1>();
      final reactiveModel2 = Injector.getAsReactive<Model2>();
      reactiveModel1.setState(null);
      await tester.pump();
      expect(find.text('onIdle'), findsOneWidget);

      reactiveModel2.setState(null);
      await tester.pump();
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilder widget, asynchronous task, case one reactive model',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilder<Model1>(
              observeMany: [() => Injector.getAsReactive<Model1>()],
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              onError: (error) => Text(error.message),
              onData: (data) => Text(data.counter.toString()),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

      final reactiveModel = Injector.getAsReactive<Model1>();
      //async task without error
      reactiveModel.setState((s) => s.incrementAsync());
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);

      //async task with error
      reactiveModel.setState((s) => s.incrementAsyncWithError());
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('error message'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilder widget, asynchronous task without error, case two reactive models',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1()), Inject(() => Model2())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilder<Model1>(
              observeMany: [
                () => Injector.getAsReactive<Model1>(),
                () => Injector.getAsReactive<Model2>()
              ],
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              onError: (error) => Text('error'),
              onData: (data) => Text('data'),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

      final reactiveModel1 = Injector.getAsReactive<Model1>();
      final reactiveModel2 = Injector.getAsReactive<Model2>();

      //final status is onIdle because reactiveModel2 is on Idle state
      reactiveModel1.setState((s) => s.incrementAsync());
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('onIdle'), findsOneWidget);

      //final status is onData
      reactiveModel2.setState((s) => s.incrementAsync());
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilder widget, asynchronous task with error, case two reactive models',
    (tester) async {
      RM.debugWidgetsRebuild = true;
      final widget = Injector(
        inject: [Inject(() => Model1()), Inject(() => Model2())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilder<Model1>(
              observeMany: [
                () => Injector.getAsReactive<Model1>(),
                () => Injector.getAsReactive<Model2>()
              ],
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              onError: (error) => Text(error.message),
              onData: (data) => Text('data'),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

      final reactiveModel1 = Injector.getAsReactive<Model1>();
      final reactiveModel2 = Injector.getAsReactive<Model2>();

      //final status is onError because reactiveModel1 is on error state
      reactiveModel1.setState((s) => s.incrementAsyncWithError());
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('error message'), findsOneWidget);

      //final status is onError because reactiveModel1 is still on error state
      reactiveModel2.setState((s) => s.incrementAsync());
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('error message'), findsOneWidget);

      //final status is data
      reactiveModel1.setState((s) => s.incrementAsync());
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('data'), findsOneWidget);

      //final status is onError because reactiveModel2 is  on error state
      reactiveModel2.setState((s) => s.incrementAsyncWithError());
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('error message'), findsOneWidget);
      RM.debugWidgetsRebuild = false;
    },
  );

  testWidgets(
    'WhenRebuilder throws if resolving model type fails',
    (tester) async {
      RM.debugWidgetsRebuild = true;
      final widget = Injector(
        inject: [Inject(() => Model1()), Inject(() => Model2())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilder<Model1>(
              observeMany: [
                () => RM.create(Model1()),
                () => Injector.getAsReactive<Model2>()
              ],
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              onError: (error) => Text(error.message),
              onData: (data) => Text('data'),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(tester.takeException(), isException);
    },
  );

  test(
    'WhenRebuilder throws if onWaiting is null',
    () {
      expect(
        () => WhenRebuilder<Model1>(
          onIdle: () => Container(),
          observeMany: [() => null],
          onWaiting: null,
          onError: (error) => Text(error.message),
          onData: (data) => Text('data'),
        ),
        throwsAssertionError,
      );
    },
  );

  test(
    'WhenRebuilder throws if onError is null',
    () {
      expect(
        () => WhenRebuilder<Model1>(
          onIdle: () => Container(),
          observeMany: [() => null],
          onWaiting: () => Text(''),
          onError: null,
          onData: (data) => Text('data'),
        ),
        throwsAssertionError,
      );
    },
  );

  test(
    'WhenRebuilder throws if onData is null',
    () {
      expect(
        () => WhenRebuilder<Model1>(
          onIdle: () => Container(),
          observeMany: [() => null],
          onWaiting: () => Text(''),
          onError: (_) => Text(''),
          onData: null,
        ),
        throwsAssertionError,
      );
    },
  );
}

class Model1 {
  int counter = 0;
  void incrementAsync() async {
    await Future.delayed(Duration(seconds: 1));
    counter++;
  }

  void incrementAsyncWithError() async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception('error message');
  }
}

class Model2 {
  int counter = 0;
  void incrementAsync() async {
    await Future.delayed(Duration(seconds: 1));
    counter++;
  }

  void incrementAsyncWithError() async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception('error message');
  }
}
