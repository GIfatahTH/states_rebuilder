import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'WhenRebuilder widget, synchronous task, case one reactive model',
    (tester) async {
      final reactiveModel =
          ReactiveModel(creator: () => Model1(), initialState: Model1());
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilder<Model1>(
          observe: () => reactiveModel,
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('waiting'),
          onError: (error) => Text('error'),
          onData: (data) => Text('data'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

      reactiveModel.setState((s) => null);
      await tester.pump();
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilder widget, synchronous task, case two reactive models',
    (tester) async {
      final reactiveModel1 =
          ReactiveModel(creator: () => Model1(), initialState: Model1());
      final reactiveModel2 =
          ReactiveModel(creator: () => Model2(), initialState: Model2());
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilder<Model1>(
          observeMany: [() => reactiveModel1, () => reactiveModel2],
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('waiting'),
          onError: (error) => Text('error'),
          onData: (data) => Text('data'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

      reactiveModel1.setState((s) => null);
      await tester.pump();
      expect(find.text('onIdle'), findsOneWidget);

      reactiveModel2.setState((s) => null);
      await tester.pump();
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilder widget, asynchronous task, case one reactive model',
    (tester) async {
      final reactiveModel =
          ReactiveModel(creator: () => Model1(), initialState: Model1());

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilder<Model1>(
          observeMany: [() => reactiveModel],
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('waiting'),
          onError: (error) => Text(error.message),
          onData: (data) => Text(data.counter.toString()),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

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
      final reactiveModel1 =
          ReactiveModel(creator: () => Model1(), initialState: Model1());
      final reactiveModel2 =
          ReactiveModel(creator: () => Model2(), initialState: Model2());
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilder<Model1>(
          observeMany: [() => reactiveModel1, () => reactiveModel2],
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('waiting'),
          onError: (error) => Text('error'),
          onData: (data) => Text('data'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

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
      final reactiveModel1 =
          ReactiveModel(creator: () => Model1(), initialState: Model1());
      final reactiveModel2 =
          ReactiveModel(creator: () => Model2(), initialState: Model2());

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilder<Model1>(
          observeMany: [() => reactiveModel1, () => reactiveModel2],
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('waiting'),
          onError: (error) => Text(error.message),
          onData: (data) => Text('data'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

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
