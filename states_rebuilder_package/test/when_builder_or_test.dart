import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:states_rebuilder/src/reactive_model.dart';

void main() {
  testWidgets(
    'WhenRebuilderOr widget, synchronous task, case onIdle is not defined',
    (tester) async {
      final reactiveModel =
          ReactiveModelImp(creator: (_) => Model1(), nullState: Model1());
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilderOr<Model1>(
          observe: () => reactiveModel,
          onWaiting: () => Text('waiting'),
          onError: (error) => Text('error'),
          builder: (context, modelRM) => Text('data'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('data'), findsOneWidget);

      reactiveModel.setState(null);
      await tester.pump();
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, synchronous task, case only onData is defined',
    (tester) async {
      final reactiveModel =
          ReactiveModelImp(creator: (_) => Model1(), nullState: Model1());

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilderOr<Model1>(
          observeMany: [() => reactiveModel],
          onData: (data) => Text('data'),
          builder: (context, modelRM) => Text('other'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('other'), findsOneWidget);

      reactiveModel.setState(
        null,
      );
      await tester.pump();
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, synchronous task, case all parameters are defined',
    (tester) async {
      final reactiveModel =
          ReactiveModelImp(creator: (_) => Model1(), nullState: Model1());

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilderOr<Model1>(
          observeMany: [() => reactiveModel],
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('waiting'),
          onError: (error) => Text('error'),
          builder: (context, modelRM) => Text('data'),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

      reactiveModel.setState(null);
      await tester.pump();
      expect(find.text('data'), findsOneWidget);
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, asynchronous task, case all parameters are defined',
    (tester) async {
      final reactiveModel =
          ReactiveModelImp(creator: (_) => Model1(), nullState: Model1());

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilderOr<Model1>(
          observeMany: [() => reactiveModel],
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('waiting'),
          onError: (error) => Text(error.message),
          builder: (context, modelRM) => Text(modelRM.state.counter.toString()),
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
    'WhenRebuilderOr widget, asynchronous task, case onWaiting is not defined',
    (tester) async {
      final reactiveModel =
          ReactiveModelImp(creator: (_) => Model1(), nullState: Model1());

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilderOr<Model1>(
          observeMany: [() => reactiveModel],
          onIdle: () => Text('onIdle'),
          onError: (error) => Text(error.message),
          builder: (context, modelRM) {
            return Text(modelRM.state.counter.toString());
          },
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('onIdle'), findsOneWidget);

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
      final reactiveModel =
          ReactiveModelImp(creator: (_) => Model1(), nullState: Model1());

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilderOr<Model1>(
          observeMany: [() => reactiveModel],
          builder: (context, modelRM) {
            return Text(modelRM.state.counter.toString());
          },
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);

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
      final reactiveModel =
          ReactiveModelImp(creator: (_) => Model1(), nullState: Model1());

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilderOr<Model1>(
          observeMany: [() => reactiveModel],
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('waiting'),
          onError: (error) => Text(error.message),
          builder: (context, modelRM) {
            return Text(modelRM.state.counter.toString());
          },
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
    'WhenRebuilderOr widget, asynchronous task with error , case en error is not defined',
    (tester) async {
      final reactiveModel =
          ReactiveModelImp(creator: (_) => Model1(), nullState: Model1());

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilderOr<Model1>(
          observeMany: [() => reactiveModel],
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('waiting'),
          builder: (context, modelRM) {
            return Text(modelRM.state.counter.toString());
          },
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
      reactiveModel.setState(
        (s) => s.incrementAsyncWithError(),
        /*catchError: true*/
      );
      await tester.pump();
      expect(find.text('waiting'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      // expect(tester.takeException(), isException);
    },
  );

  testWidgets(
    'WhenRebuilderOr widget, asynchronous task with error, case two reactive models',
    (tester) async {
      final reactiveModel1 =
          ReactiveModelImp(creator: (_) => Model1(), nullState: Model1());

      final reactiveModel2 =
          ReactiveModelImp(creator: (_) => Model1(), nullState: Model1());

      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: WhenRebuilderOr<Model1>(
          observeMany: [() => reactiveModel1, () => reactiveModel2],
          onIdle: () => Text('onIdle'),
          onWaiting: () => Text('waiting'),
          onError: (error) => Text(error.message),
          builder: (context, modelRM) {
            return Text('data');
          },
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
