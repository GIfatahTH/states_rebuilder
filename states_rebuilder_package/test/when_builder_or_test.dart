import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/src/builders.dart';

void main() {
  testWidgets(
    'WhenRebuilderOr widget, synchronous task, case onIdle is not defined',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilderOr<Model1>(
              observe: () => Injector.getAsReactive<Model1>(),
              tag: 'tag1',
              onWaiting: () => Text('waiting'),
              onError: (error) => Text('error'),
              builder: (context, modelRM) => Text('data'),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('data'), findsOneWidget);

      final reactiveModel = Injector.getAsReactive<Model1>();
      reactiveModel.setState(null, filterTags: ['tag1']);
      await tester.pump();
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, synchronous task, case only onData is defined',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilderOr<Model1>(
              observeMany: [() => Injector.getAsReactive<Model1>()],
              tag: 'tag1',
              onData: (data) => Text('data'),
              builder: (context, modelRM) => Text('other'),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('other'), findsOneWidget);

      final reactiveModel = Injector.getAsReactive<Model1>();
      reactiveModel.setState(null, filterTags: ['tag1']);
      await tester.pump();
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, synchronous task, case all parameters are defined',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilderOr<Model1>(
              observeMany: [() => Injector.getAsReactive<Model1>()],
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              onError: (error) => Text('error'),
              builder: (context, modelRM) => Text('data'),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

      final reactiveModel = Injector.getAsReactive<Model1>();
      reactiveModel.setState(null);
      await tester.pump();
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, asynchronous task, case all parameters are defined',
    (tester) async {
      RM.debugWidgetsRebuild = true;
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilderOr<Model1>(
              observeMany: [() => Injector.getAsReactive<Model1>()],
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              onError: (error) => Text(error.message),
              builder: (context, modelRM) =>
                  Text(modelRM.state.counter.toString()),
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
      RM.debugWidgetsRebuild = false;
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, asynchronous task, case onWaiting is not defined',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilderOr<Model1>(
              observeMany: [() => Injector.getAsReactive<Model1>()],
              onIdle: () => Text('onIdle'),
              onError: (error) => Text(error.message),
              builder: (context, modelRM) {
                return Text(modelRM.state.counter.toString());
              },
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
      expect(find.text('0'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);

      //async task with error
      reactiveModel.setState((s) => s.incrementAsyncWithError());
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('error message'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, asynchronous task, case only builder is defined',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilderOr<Model1>(
              observeMany: [() => Injector.getAsReactive<Model1>()],
              builder: (context, modelRM) {
                return Text(modelRM.state.counter.toString());
              },
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);

      final reactiveModel = Injector.getAsReactive<Model1>();
      //async task without error
      reactiveModel.setState((s) => s.incrementAsync());
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, asynchronous task with error , case en error is defined',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilderOr<Model1>(
              observeMany: [() => Injector.getAsReactive<Model1>()],
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              onError: (error) => Text(error.message),
              builder: (context, modelRM) {
                return Text(modelRM.state.counter.toString());
              },
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
    'WhenRebuilderOr widget, asynchronous task with error , case en error is not defined',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilderOr<Model1>(
              observeMany: [() => Injector.getAsReactive<Model1>()],
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              builder: (context, modelRM) {
                return Text(modelRM.state.counter.toString());
              },
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
      reactiveModel.setState((s) => s.incrementAsyncWithError(),
          catchError: true);
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      // expect(tester.takeException(), isException);
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, asynchronous task with error, case two reactive models',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model1()), Inject(() => Model2())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilderOr<Model1>(
              observeMany: [
                () => Injector.getAsReactive<Model1>(),
                () => Injector.getAsReactive<Model2>()
              ],
              onIdle: () => Text('onIdle'),
              onWaiting: () => Text('waiting'),
              onError: (error) => Text(error.message),
              builder: (context, modelRM) {
                return Text('data');
              },
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
            child: WhenRebuilderOr<Model1>(
              observeMany: [
                () => RM.create(Model1()),
                () => Injector.getAsReactive<Model2>()
              ],
              builder: (_, __) => Container(),
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(tester.takeException(), isException);
    },
  );

  test(
    'WhenRebuilderOr throws if builder is null',
    () {
      expect(
        () => WhenRebuilderOr<Model1>(
          observeMany: [() => null],
          builder: null,
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
