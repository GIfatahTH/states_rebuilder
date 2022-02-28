// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors, body_might_complete_normally_nullable
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'common.dart';

void main() {
  testWidgets(
    'WHEN a sync value is injected '
    'THEN the state is initialized in the idle state AND with the injected value '
    'AND check that onInitialized is called'
    'AND WHEN state is mutated '
    'THEN the state is in the hasData status and the state equals the new value'
    'AND check that onData is called'
    'AND WHEN the state is mutated with exception'
    'THEN the state status is on error with the thrown error'
    'AND check that onError is called',
    (tester) async {
      int? onInitializedValue;
      int? onDataValue;
      dynamic onErrorValue;
      late Injected<int> model;
      model = RM.inject<int>(
        () => 1,
        // onInitialized: (state) {
        //   onInitializedValue = state;
        // },
        sideEffects: SideEffects.onAll(
          initState: () => onInitializedValue = model.state,
          onWaiting: null,
          onError: (err, s) {
            onErrorValue = err;
          },
          onData: ((state) {
            onDataValue = state;
          }),
        ),
      );
      expect(model.isIdle, true);
      expect(model.state, 1);
      expect(onInitializedValue, 1);
      //
      model.state = 2;
      expect(model.hasData, true);
      expect(model.state, 2);
      expect(onDataValue, 2);

      expect(await model.stateAsync, 2);

      //
      model.setState((s) => throw Exception('Error'));
      expect(model.hasError, true);
      expect(model.error.message, 'Error');
      expect(onErrorValue.message, 'Error');
      dynamic error;
      try {
        await model.stateAsync;
      } catch (e) {
        error = e;
      }
      expect(error.message, 'Error');
    },
  );
  testWidgets(
    'WHEN sync injected is mutated asynchronously (Future) '
    'THEN it is in the waiting status while waiting for the future '
    'AND check that onWaiting is called'
    'AND it has data if the future ends with data'
    'AND check that onData is called'
    'AND it has error if the future ends with error'
    'AND check that onError is called',
    (tester) async {
      String? onWaitingValue;
      int? onDataValue;
      dynamic onErrorValue;
      final model = RM.inject<int>(
        () => 1,
        sideEffects: SideEffects.onAll(
          onWaiting: () {
            onWaitingValue = 'Waiting...';
          },
          onError: (err, s) {
            onErrorValue = err;
          },
          onData: (state) {
            onDataValue = state;
          },
        ),
      );
      expect(model.isIdle, true);
      expect(model.state, 1);
      model.setState((s) => future(2));
      expect(model.isWaiting, true);
      expect(model.state, 1);
      expect(onWaitingValue, 'Waiting...');
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.state, 2);
      expect(onDataValue, 2);

      onWaitingValue = null;
      model.setState((s) => future(1, Exception('Error')));
      expect(model.isWaiting, true);
      expect(model.state, 2);
      expect(onWaitingValue, 'Waiting...');

      await tester.pump(Duration(seconds: 1));
      expect(model.hasError, true);
      expect(model.state, 2);
      expect(model.error.message, 'Error');
      expect(onErrorValue.message, 'Error');

      dynamic error;
      try {
        await model.stateAsync;
      } catch (e) {
        error = e;
      }
      expect(error.message, 'Error');
    },
  );

  testWidgets(
    'WHEN sync injected is mutated asynchronously (Stream) '
    'THEN it is in the waiting status while waiting for the future '
    'AND it has data if the future ends with data'
    'AND it has error if the future ends with error',
    (tester) async {
      final model = RM.inject<int>(
        () => 1,
      );

      expect(model.isIdle, true);
      expect(model.state, 1);
      model.setState((s) => stream(3));
      expect(model.isWaiting, true);
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.state, 1);
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.state, 2);
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.state, 3);
      expect(model.isDone, true);
      model.setState((s) => stream(2, Exception('Error')));
      expect(model.isWaiting, true);
      expect(model.isDone, false);
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(model.state, 1);
      await tester.pump(Duration(seconds: 1));
      expect(model.hasError, true);
      expect(model.state, 1);
      expect(model.isDone, true);
      expect(model.error.message, 'Error');
      dynamic error;
      try {
        await model.stateAsync;
      } catch (e) {
        error = e;
      }
      expect(error.message, 'Error');
    },
  );

  testWidgets(
    'WHEN state is injected using RM.injectFuture '
    'THEN it starts in the waiting status '
    'AND check that onWaiting is called'
    'AND WHEN future ends with data '
    'THEN the state is in the has data status'
    'AND check that onData is called'
    'And when refresh is called the future lifecycle repeats',
    (tester) async {
      String? onWaitingValue;
      int? onDataValue;
      final model = RM.injectFuture<int?>(
        () => future(1),
        sideEffects: SideEffects.onAll(
          onWaiting: () {
            onWaitingValue = 'Waiting...';
          },
          onError: null,
          onData: ((state) {
            onDataValue = state;
          }),
        ),
      );
      //
      expect(model.isWaiting, true);
      expect(model.state, null);
      expect(onWaitingValue, 'Waiting...');
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, true);
      expect(onDataValue, 1);
      expect(model.state, 1);
      //
      onWaitingValue = null;
      model.refresh();
      await tester.pump();
      expect(model.isWaiting, true);
      expect(model.state, null);
      expect(onWaitingValue, 'Waiting...');
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, true);
      expect(model.state, 1);
      expect(onDataValue, 1);
    },
  );

  testWidgets(
    'WHEN state is injected using RM.injectFuture '
    'THEN it starts in the waiting status '
    'AND check that onWaiting is called'
    'AND WHEN future ends with error '
    'THEN the state is in  the error status'
    'AND check that onError is called',
    (tester) async {
      String? onWaitingValue;
      dynamic onErrorValue;
      final model = RM.injectFuture<int>(
        () => future(1, Exception('Error')),
        sideEffects: SideEffects.onAll(
          onWaiting: () {
            onWaitingValue = 'Waiting...';
          },
          onError: (err, s) {
            onErrorValue = err;
          },
          onData: null,
        ),
        initialState: 0,
      );
      expect(model.isWaiting, true);
      expect(model.state, 0);
      expect(onWaitingValue, 'Waiting...');
      await tester.pump(Duration(seconds: 1));
      expect(model.hasError, true);
      expect(model.error.message, 'Error');
      expect(onErrorValue.message, 'Error');
      expect(model.state, 0);
      //
      onWaitingValue = null;
      model.refresh();
      expect(model.isWaiting, true);
      expect(model.state, 0);
      expect(onWaitingValue, 'Waiting...');

      await tester.pump(Duration(seconds: 1));
      expect(model.hasError, true);
      expect(model.error.message, 'Error');
      expect(onErrorValue.message, 'Error');
      expect(model.state, 0);
    },
  );

  testWidgets(
    'WHEN state is injected using RM.injectStream '
    'THEN it starts in the waiting status '
    'AND check that onWaiting is called'
    'AND WHEN stream emits with data '
    'THEN the state is in the has data status'
    'AND check that onData is called'
    'And when refresh is called the stream lifecycle repeats',
    (tester) async {
      String? onWaitingValue;
      int? onDataValue;
      final model = RM.injectStream<int>(
        () => stream(3),
        sideEffects: SideEffects.onAll(
          onWaiting: () {
            onWaitingValue = 'Waiting...';
          },
          onError: null,
          onData: ((state) {
            onDataValue = state;
          }),
        ),
        initialState: 0,
      );
      expect(model.isWaiting, true);
      expect(model.state, 0);
      expect(onWaitingValue, 'Waiting...');
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 1);
      expect(model.state, 1);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 2);
      expect(model.state, 2);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, true);
      expect(onDataValue, 3);
      expect(model.state, 3);

      onWaitingValue = null;
      model.refresh();
      expect(model.isWaiting, true);
      expect(model.state, 0);
      expect(onWaitingValue, 'Waiting...');
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 1);
      expect(model.state, 1);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 2);
      expect(model.state, 2);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, true);
      expect(onDataValue, 3);
      expect(model.state, 3);
    },
  );

  testWidgets(
    'WHEN state is injected using RM.injectStream '
    'THEN it starts in the waiting status '
    'AND check that onWaiting is called'
    'AND WHEN stream emits with data '
    'THEN the state is in the has data status'
    'AND check that onData is called'
    'AND WHEN stream emits error '
    'THEN the state is in the error status'
    'AND check that onError is called'
    'And when refresh is called the stream lifecycle repeats',
    (tester) async {
      String? onWaitingValue;
      int? onDataValue;
      dynamic onErrorValue;
      final model = RM.injectStream<int>(
        () => stream(3, Exception('Error')),
        sideEffects: SideEffects.onAll(
          onWaiting: () {
            onWaitingValue = 'Waiting...';
          },
          onError: (err, s) {
            onErrorValue = err;
          },
          onData: ((state) {
            onDataValue = state;
          }),
        ),
      );
      expect(model.isWaiting, true);

      expect(onWaitingValue, 'Waiting...');
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 1);
      expect(model.state, 1);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 2);
      expect(model.state, 2);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasError, true);
      expect(model.error.message, 'Error');
      expect(onErrorValue?.message, 'Error');
      expect(model.state, 2);

      onWaitingValue = null;
      onErrorValue = null;
      model.refresh();
      expect(model.isWaiting, true);
      expect(model.state, 2);
      expect(onWaitingValue, 'Waiting...');
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 1);
      expect(model.state, 1);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 2);
      expect(model.state, 2);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasError, true);
      expect(model.error.message, 'Error');
      expect(onErrorValue?.message, 'Error');
      expect(model.state, 2);
    },
  );

  testWidgets(
    'WHEN state is injected using RM.injectStream '
    'AND WHEN refresh is called before the end of the current stream'
    'THEN the current stream is canceled'
    'AND the state is refreshed',
    (tester) async {
      String? onWaitingValue;
      int? onDataValue;
      final model = RM.injectStream<int>(
        () => stream(3),
        sideEffects: SideEffects.onAll(
          onWaiting: () {
            onWaitingValue = 'Waiting...';
          },
          onError: null,
          onData: ((state) {
            onDataValue = state;
          }),
        ),
        initialState: 0,
      );
      expect(model.isWaiting, true);
      expect(model.state, 0);
      expect(onWaitingValue, 'Waiting...');
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 1);
      expect(model.state, 1);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 2);
      expect(model.state, 2);
      //

      onWaitingValue = null;
      model.refresh();
      expect(model.isWaiting, true);
      expect(model.state, 0);
      expect(onWaitingValue, 'Waiting...');
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 1);
      expect(model.state, 1);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, false);
      expect(onDataValue, 2);
      expect(model.state, 2);
      //
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.isDone, true);
      expect(onDataValue, 3);
      expect(model.state, 3);
    },
  );

  group('Global Injected cross test and mock test', () {
    //

    final model1 = RM.inject(
      () => 1,
      // debugPrintWhenNotifiedPreMessage: '',
    );
    final model2 = RM.inject(() => model1.state * 2);
    final futureModel = RM.injectFuture(() => future(1));
    final streamModel = RM.injectStream(() => stream(1));
    setUp(() {
      model1.dispose();
      model2.dispose();
      futureModel.dispose();
      streamModel.dispose();
    });
    testWidgets(
      'First test',
      (tester) async {
        expect(model2.state, 2);
        model2.state++;
        expect(model2.state, 3);
      },
    );
    testWidgets(
      'Second test',
      (tester) async {
        expect(model2.state, 2);
        model2.state++;
        expect(model2.state, 3);
      },
    );
    testWidgets(
      'Third test',
      (tester) async {
        model1.injectMock(() => 2);
        expect(model2.state, 4);
        model2.state++;
        expect(model2.state, 5);
      },
    );
    testWidgets(
      'forth test',
      (tester) async {
        expect(model2.state, 2);
        model2.state++;
        expect(model2.state, 3);
      },
    );

    testWidgets(
      'First future',
      (tester) async {
        expect(futureModel.isWaiting, true);
        await tester.pump(Duration(seconds: 1));
        expect(futureModel.state, 1);
      },
    );
    testWidgets(
      'Second future',
      (tester) async {
        expect(futureModel.isWaiting, true);
        await tester.pump(Duration(seconds: 1));
        expect(futureModel.state, 1);
      },
    );
    testWidgets(
      'Third future',
      (tester) async {
        futureModel.injectFutureMock(() => future(10));
        expect(futureModel.isWaiting, true);
        await tester.pump(Duration(seconds: 1));
        expect(futureModel.state, 10);
      },
    );
    testWidgets(
      'Forth future',
      (tester) async {
        expect(futureModel.isWaiting, true);
        await tester.pump(Duration(seconds: 1));
        expect(futureModel.state, 1);
      },
    );

    testWidgets(
      'Fifth future',
      (tester) async {
        futureModel.injectMock(() => 100);
        expect(futureModel.isWaiting, false);
        expect(futureModel.state, 100);
        expect(futureModel.hasData, true);
      },
    );

    testWidgets(
      'First stream',
      (tester) async {
        expect(streamModel.isWaiting, true);
        await tester.pump(Duration(seconds: 1));
        expect(streamModel.state, 1);
        expect(streamModel.isDone, true);
      },
    );
    testWidgets(
      'Second stream',
      (tester) async {
        expect(streamModel.isWaiting, true);
        await tester.pump(Duration(seconds: 1));
        expect(streamModel.state, 1);
        expect(streamModel.isDone, true);
      },
    );

    testWidgets(
      'Third stream',
      (tester) async {
        streamModel.injectStreamMock(() => stream(2));
        expect(streamModel.isWaiting, true);
        await tester.pump(Duration(seconds: 1));
        expect(streamModel.state, 1);
        expect(streamModel.isDone, false);
        await tester.pump(Duration(seconds: 1));
        expect(streamModel.state, 2);
        expect(streamModel.isDone, true);
      },
    );

    testWidgets(
      'Forth stream',
      (tester) async {
        expect(streamModel.isWaiting, true);
        await tester.pump(Duration(seconds: 1));
        expect(streamModel.state, 1);
        expect(streamModel.isDone, true);
      },
    );

    testWidgets(
      'Fifth stream',
      (tester) async {
        streamModel.injectFutureMock(() => future(1));
        expect(streamModel.isWaiting, true);
        await tester.pump(Duration(seconds: 1));
        expect(streamModel.state, 1);
        expect(streamModel.isDone, true);
      },
    );
    testWidgets(
      'Sixth stream',
      (tester) async {
        streamModel.injectMock(() => 100);
        expect(streamModel.isWaiting, false);
        expect(streamModel.state, 100);
        expect(streamModel.hasData, true);
      },
    );
  });

  testWidgets(
    'ReactiveModel : inject futures throw argument error if getting a non initialized state while waiting',
    (tester) async {
      final model = RM.injectFuture(
        () => Future.delayed(Duration(seconds: 1), () => 0),
        // debugPrintWhenNotifiedPreMessage: 'model',
      );
      expect(model.stateAsync, isA<Future<int>>());
      expect(() => model.state, throwsArgumentError);
      expect(model.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(model.state, 0);
      expect(model.hasData, isTrue);
      expect((await model.stateAsync), 0);
      //
      // expect(model.isActive, true);// TODO
      expect(model.isDone, true);
    },
  );

  testWidgets(
    'WHEN Model is waiting'
    'THEN it can be sync mutated without changing the isWaiting flag'
    'WHEN Model is waiting and another async task is called'
    'THEN the latter cancels the sooner',
    (tester) async {
      SnapState? sideEffectSnap;
      final model = RM.injectFuture<int?>(
        () => Future.delayed(const Duration(seconds: 2), () => 10),
        sideEffects: SideEffects(
          onSetState: (snap) {
            sideEffectSnap = snap;
          },
        ),
      );
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnReactive(
          () {
            return Text('${model.state}');
          },
        ),
      );
      await tester.pumpWidget(widget);
      expect(model.isWaiting, true);
      expect(model.state, null);
      expect(sideEffectSnap!.isWaiting, true);
      expect(sideEffectSnap!.state, null);
      await tester.pump(const Duration(seconds: 1));
      expect(model.isWaiting, true);
      expect(model.state, null);
      expect(sideEffectSnap!.isWaiting, true);
      expect(sideEffectSnap!.state, null);
      expect(find.text('null'), findsOneWidget);
      model.state = 1;
      await tester.pump();
      expect(model.isWaiting, true);
      expect(model.state, 1);
      expect(sideEffectSnap!.isWaiting, true);
      expect(sideEffectSnap!.state, null);
      expect(find.text('1'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.state, 10);
      expect(sideEffectSnap!.hasData, true);
      expect(sideEffectSnap!.state, 10);
      expect(find.text('10'), findsOneWidget);
      //
      model.stateAsync = Future.delayed(const Duration(seconds: 2), () => 20);
      expect(model.isWaiting, true);
      expect(model.state, 10);
      await tester.pump(const Duration(seconds: 1));
      expect(model.isWaiting, true);
      expect(model.state, 10);
      expect(sideEffectSnap!.isWaiting, true);
      expect(sideEffectSnap!.state, 10);
      expect(find.text('10'), findsOneWidget);
      model.state = 1;
      await tester.pump();
      expect(model.isWaiting, true);
      expect(model.state, 1);
      expect(sideEffectSnap!.isWaiting, true);
      expect(sideEffectSnap!.state, 10);
      expect(find.text('1'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.state, 20);
      //
      model.stateAsync = Future.delayed(const Duration(seconds: 2), () => 20);
      expect(model.isWaiting, true);
      expect(model.state, 20);
      await tester.pump(const Duration(seconds: 1));
      expect(model.isWaiting, true);
      expect(model.state, 20);
      model.stateAsync = Future.delayed(const Duration(seconds: 2), () => 10);
      await tester.pump();
      expect(model.isWaiting, true);
      expect(model.state, 20);
      await tester.pump(const Duration(seconds: 1));
      expect(model.isWaiting, true);
      expect(model.state, 20);
      model.state = 1;
      await tester.pump();
      expect(model.isWaiting, true);
      expect(model.state, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.state, 10);
    },
  );

  testWidgets(
    'Do not throw when a model is disposed while waiting for a future ',
    (tester) async {
      final model = RM.inject<int>(
        () => 0,
      );
      model.stateAsync = Future.delayed(const Duration(seconds: 1), () => 10);
      await tester.pump();
      model.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
  );

  testWidgets(
    'Test when skipWaiting',
    (tester) async {
      final model = RM.inject<int>(
        () => 0,
      );
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnReactive(
          () {
            return Text('${model.state}');
          },
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      //

      model.setState(
        (s) => Future.delayed(const Duration(seconds: 2), () => 10),
        // skipWaiting: true,
        stateInterceptor: (current, next) {
          if (next.isWaiting) return current;
        },
      );
      //
      await tester.pump();
      expect(model.isWaiting, false);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      model.notify();
      await tester.pump();
      expect(model.isWaiting, false);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(model.hasData, true);
      expect(find.text('10'), findsOneWidget);
    },
  );

  testWidgets(
    'Test when skipWaiting using stateInterceptor of Injected state',
    (tester) async {
      SnapState? currentState;
      SnapState? nextState;

      final model = RM.inject<int>(
        () => 0,
        stateInterceptor: (_, __) {
          currentState = _;
          nextState = __;
        },
      );
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnReactive(
          () {
            return Text('${model.state}');
          },
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      //

      model.setState(
        (s) => Future.delayed(const Duration(seconds: 2), () => 10),
        stateInterceptor: (currentSnap, nextSnap) {
          if (nextSnap.isWaiting) {
            return nextSnap.copyToHasData(nextSnap.data);
          }
        },
      );
      //
      await tester.pump();
      expect(model.isWaiting, false);
      expect(find.text('0'), findsOneWidget);
      expect(currentState?.isIdle, true);
      expect(nextState?.hasData, true);
      await tester.pump(const Duration(seconds: 1));
      model.notify();
      await tester.pump();
      expect(model.isWaiting, false);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(model.hasData, true);
      expect(find.text('10'), findsOneWidget);
      expect(currentState?.isIdle, true);
      expect(nextState?.hasData, true);
    },
  );

  testWidgets(
    'Test when skipWaiting using stateInterceptor of Reactive state',
    (tester) async {
      final model = 0.inj();
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnReactive(
          () {
            return Text('${model.state}');
          },
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      //

      model.setState(
        (s) => Future.delayed(const Duration(seconds: 2), () => 10),
        stateInterceptor: (currentSnap, nextSnap) {
          if (nextSnap.isWaiting) {
            return nextSnap.copyToHasData(nextSnap.data);
          }
        },
      );
      //
      await tester.pump();
      expect(model.isWaiting, false);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      model.notify();
      await tester.pump();
      expect(model.isWaiting, false);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(model.hasData, true);
      expect(find.text('10'), findsOneWidget);
    },
  );

  testWidgets(
    'Manual status flag setting for injected state',
    (tester) async {
      SnapState? currentState;
      SnapState? nextState;
      SnapState? sideEffects;

      final model = RM.inject<int>(
        () => 0,
        // debugPrintWhenNotifiedPreMessage: '',
        stateInterceptor: (_, __) {
          currentState = _;
          nextState = __;
        },
        sideEffects: SideEffects(
          onSetState: (snap) {
            sideEffects = snap;
          },
        ),
      );
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnReactive(
          () {
            if (model.isIdle) {
              return Text('isIdle');
            }
            if (model.isWaiting) {
              return Text('isWaiting');
            }
            if (model.hasError) {
              return Text(model.error.message);
            }
            return Text('${model.state}');
          },
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('isIdle'), findsOneWidget);
      //

      Exception? exception;
      void fn() async {
        try {
          model.setToIsWaiting();
          final data =
              await Future.delayed(const Duration(seconds: 1), () => 10);
          if (exception != null) {
            throw exception;
          }
          model.setToHasData(data);
        } catch (e, s) {
          model.setToHasError(
            e,
            stackTrace: s,
            refresher: fn,
          );
        }
      }

      fn();
      //
      await tester.pump();
      expect(model.isWaiting, true);
      expect(find.text('isWaiting'), findsOneWidget);
      expect(currentState!.isIdle, true);
      expect(nextState!.isWaiting, true);
      expect(sideEffects!.isWaiting, true);
      await tester.pump(const Duration(seconds: 1));
      expect(model.hasData, true);
      expect(find.text('10'), findsOneWidget);
      expect(currentState!.isWaiting, true);
      expect(nextState!.hasData, true);
      expect(nextState!.data, 10);
      expect(sideEffects!.data, 10);
      //
      model.setToIsIdle();
      await tester.pump();
      expect(find.text('isIdle'), findsOneWidget);
      // expect(currentState!.hasData, true);
      // expect(nextState!.isIdle, true);
      // expect(sideEffects!.isIdle, true);
      exception = Exception('error');
      fn();
      await tester.pump();
      expect(model.isWaiting, true);
      expect(find.text('isWaiting'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(model.hasError, true);
      expect(find.text('error'), findsOneWidget);
      expect(currentState!.isWaiting, true);
      expect(nextState!.hasError, true);
      expect(nextState!.snapError!.error.message, 'error');
      expect(sideEffects!.snapError!.error.message, 'error');
      //
    },
  );

  testWidgets(
    'Manual status flag setting FOR REACTIVE MODEL',
    (tester) async {
      final model = 0.inj();
      final widget = Directionality(
        textDirection: TextDirection.ltr,
        child: OnReactive(
          () {
            if (model.isIdle) {
              return Text('isIdle');
            }
            if (model.isWaiting) {
              return Text('isWaiting');
            }
            if (model.hasError) {
              return Text(model.error.message);
            }
            return Text('${model.state}');
          },
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('isIdle'), findsOneWidget);
      //

      Exception? exception;
      void fn() async {
        try {
          model.setToIsWaiting();
          final data =
              await Future.delayed(const Duration(seconds: 1), () => 10);
          if (exception != null) {
            throw exception;
          }
          model.setToHasData(data);
        } catch (e, s) {
          model.setToHasError(e, stackTrace: s, refresher: fn);
        }
      }

      fn();
      //
      await tester.pump();
      expect(model.isWaiting, true);
      expect(find.text('isWaiting'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(model.hasData, true);
      expect(find.text('10'), findsOneWidget);
      //
      model.setToIsIdle();
      await tester.pump();
      expect(find.text('isIdle'), findsOneWidget);
      exception = Exception('error');
      fn();
      await tester.pump();
      expect(model.isWaiting, true);
      expect(find.text('isWaiting'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(model.hasError, true);
      expect(find.text('error'), findsOneWidget);
      //
    },
  );
  testWidgets(
    'WHEN notify is called'
    'THEN side effects are not called',
    (tester) async {
      int numberOfSideEffectCall = 0;
      int numberOfBuildCall = 0;
      final model = RM.inject<int>(
        () => 0,
        sideEffects: SideEffects(
          onSetState: (_) => numberOfSideEffectCall++,
        ),
      );
      // ignore: unused_result
      model.addObserver(listener: (_) => numberOfBuildCall++);
      expect(model.state, 0);
      expect(numberOfSideEffectCall, 0);
      expect(numberOfBuildCall, 0);
      //
      model.state++;
      await tester.pump();
      expect(numberOfSideEffectCall, 1);
      expect(numberOfBuildCall, 1);
      //
      model.notify();
      await tester.pump();
      expect(numberOfSideEffectCall, 1);
      expect(numberOfBuildCall, 2);
    },
  );
}
