import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/when_rebuilder_or.dart';

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
              models: [Injector.getAsReactive<Model1>()],
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
      reactiveModel.setState(null);
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
              models: [Injector.getAsReactive<Model1>()],
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
      final widget = Injector(
        inject: [Inject(() => Model1())],
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: WhenRebuilderOr<Model1>(
              models: [Injector.getAsReactive<Model1>()],
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
              models: [Injector.getAsReactive<Model1>()],
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
              models: [Injector.getAsReactive<Model1>()],
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
              models: [Injector.getAsReactive<Model1>()],
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
              models: [Injector.getAsReactive<Model1>()],
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
      reactiveModel.setState((s) => s.incrementAsyncWithError());
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(tester.takeException(), isException);
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
              models: [
                Injector.getAsReactive<Model1>(),
                Injector.getAsReactive<Model2>()
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

  test(
    'WhenRebuilderOr throws if model is empty',
    () {
      expect(
        () => WhenRebuilderOr<Model1>(
          models: [],
          builder: (context, modelRM) => null,
        ),
        throwsAssertionError,
      );
    },
  );

  test(
    'WhenRebuilderOr throws if builder is null',
    () {
      expect(
        () => WhenRebuilderOr<Model1>(
          models: [null],
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
