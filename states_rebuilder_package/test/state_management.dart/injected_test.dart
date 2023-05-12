// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/scr/state_management/common/logger.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

import 'fake_classes/models.dart';

final vanillaModel = RM.inject(() => VanillaModel());
final streamVanillaModel = RM.injectStream<VanillaModel>(
  () => Stream.periodic(Duration(seconds: 1),
      (n) => n < 3 ? VanillaModel(n) : VanillaModel(3)).take(6),
  watch: (model) => model?.counter,
  initialState: VanillaModel(0),
  // isLazy: false,
  // onData: (s) => print('streamVanillaModel :: $s'),
);

final futureModel = RM.injectFuture(
  () => Future.delayed(Duration(seconds: 1), () => 10),
  initialState: 0,
);

final interface = RM.injectFlavor({
  Env.prod: () => ModelProd(),
  Env.test: () => ModelTest(),
});

final asyncComputed = RM.injectStream<VanillaModel>(
  () async* {
    yield await Future.delayed(
      Duration(seconds: 1),
      () => vanillaModel.state,
    );
  },
  dependsOn: DependsOn({vanillaModel}),
  initialState: VanillaModel(0),
);

void main() {
  StatesRebuilerLogger.isTestMode = true;
  testWidgets(
    'should not throw if async method is called from initState',
    (tester) async {
      final widget = vanillaModel.rebuild(
        () {
          return Column(
            children: <Widget>[
              Container(),
            ],
          );
        },
        sideEffects: SideEffects(
          initState: () {
            vanillaModel.setState(
              (s) => s.incrementAsyncWithError(),
            );
          },
        ),
      );

      await tester.pumpWidget(widget);
      expect(vanillaModel.isWaiting, isTrue);
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      expect(vanillaModel.hasError, isTrue);
      expect(
        vanillaModel.toString(),
        endsWith('SnapState<VanillaModel>(hasError: Exception: Error message)'),
      );
    },
  );

  testWidgets(
    'will  stream dispose if the injected stream is disposed',
    (tester) async {
      final switcherRM = RM.inject(() => true);

      final widget = switcherRM.rebuild(() {
        if (switcherRM.state) {
          return streamVanillaModel.rebuild(
            () => Directionality(
              textDirection: TextDirection.ltr,
              child: Text(streamVanillaModel.state.counter.toString()),
            ),
          );
        } else {
          return Container();
        }
      });

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);

      expect(streamVanillaModel.subscription?.isPaused, isFalse);
      //
      switcherRM.state = false;
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsNothing);
      expect(streamVanillaModel.subscription, isNull);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsNothing);
    },
  );

  testWidgets(
      'should register Stream and Rebuild StateBuilder each time stream sends data with watch',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      streamVanillaModel.rebuild(
        () {
          numberOfRebuild++;
          return Container();
        },
      ),
    );

    expect(numberOfRebuild, equals(1));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(2));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(3));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(4));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(5));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(5));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(5));
    streamVanillaModel.notify();
    await tester.pump();
    expect(numberOfRebuild, equals(5));
  });

  testWidgets('RM.injectFuture', (WidgetTester tester) async {
    await tester.pumpWidget(
      futureModel.rebuild(
        () {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text('${futureModel.state}'),
          );
        },
      ),
    );

    expect(find.text('0'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('Injected.injectMock', (WidgetTester tester) async {
    futureModel.injectFutureMock(
      () => Future.delayed(Duration(seconds: 1), () => 50),
    );

    await tester.pumpWidget(
      futureModel.rebuild(
        () {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text('${futureModel.state}'),
          );
        },
      ),
    );

    expect(find.text('0'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('50'), findsOneWidget);
  });
  testWidgets(
    'Injector : should not throw when onError is defined',
    (WidgetTester tester) async {
      await tester.pumpWidget(vanillaModel.rebuild(() => Container()));
      String? errorMessage;
      vanillaModel.setState(
        (state) => state.incrementAsyncWithError(),
        sideEffects: SideEffects.onError(
          (error, _) {
            errorMessage = error.message;
          },
        ),
      );
      await tester.pump();
      await tester.pump(Duration(seconds: 2));
      expect(errorMessage, 'Error message');
    },
  );
  testWidgets('Injector.interface should work Env.prod', (tester) async {
    RM.env = Env.prod;

    Widget widget = interface.rebuild(() {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Text(interface.state.counter.toString()),
      );
    });

    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);

    interface.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Injector.interface should work Env.test', (tester) async {
    RM.env = Env.test;
    Widget widget = interface.rebuild(() {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Text(interface.state.counter.toString()),
      );
    });

    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);

    interface.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  // testWidgets('Injector.flavor assertions', (tester) async {
  //   StatesRebuilerLogger.isTestMode = true;
  //   final model = RM.injectFlavor({
  //     '1': () => 1,
  //     '2': () => 2,
  //   });
  //   print(model.state);

  //   expect(() => model.state, throwsAssertionError);
  //   // model.dispose();
  //   // //
  //   // final model2 = RM.injectFlavor({
  //   //   '1': () => 1,
  //   //   '2': () => 2,
  //   //   '3': () => 3,
  //   // });
  //   // RM.env = '1';
  //   // expect(() => model2.state, throwsAssertionError);
  //   // //
  //   // RM.env = '3';
  //   // final model3 = RM.injectFlavor({
  //   //   '1': () => 1,
  //   //   '2': () => 2,
  //   // });
  //   // expect(() => model3.state, throwsAssertionError);
  // });

  testWidgets('Injected.streamBuilder without error', (tester) async {
    // final widget = vanillaModel.streamBuilder<int>(
    final widget = OnBuilder<int>.createStream(
      creator: () => vanillaModel.state.incrementStream(),
      sideEffects: SideEffects(
        dispose: () => vanillaModel.dispose(),
      ),
      builder: (rm) {
        return rm.onAll(
          onError: null,
          onWaiting: () => Text('waiting ...'),
          onData: (state) {
            if (rm.isDone) {
              return Text('done $state');
            }
            return Text('$state');
          },
        );
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));

    expect(find.text('waiting ...'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    expect(find.text('done 3'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('done 3'), findsOneWidget);
  });

  testWidgets('Injected.streamBuilder immutable without error', (tester) async {
    final widget = OnBuilder<VanillaModel>.createStream(
      creator: () =>
          vanillaModel.state.incrementStream().map((e) => VanillaModel(e)),
      sideEffects: SideEffects(
        dispose: () => vanillaModel.dispose(),
      ),
      builder: (rm) {
        return rm.onAll(
          onError: null,
          onWaiting: () => Text('waiting ...'),
          onData: (state) {
            if (rm.isDone) {
              return Text('done ${state.counter}');
            }
            return Text('${state.counter}');
          },
        );
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));

    expect(find.text('waiting ...'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    expect(find.text('done 3'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('done 3'), findsOneWidget);
  });

  testWidgets('Injected.streamBuilder with error', (tester) async {
    late SnapState sideSnap;

    final widget = OnBuilder<int>.createStream(
      creator: () => vanillaModel.state.incrementStreamWithError(),
      initialState: 0,
      sideEffects: SideEffects(
        onSetState: (snap) {
          sideSnap = snap;
        },
      ),
      builder: (rm) {
        return rm.onAll(
          onWaiting: null,
          onError: (e, _) => Text('${e.message}'),
          onData: (state) {
            return Text('$state');
          },
        );
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    // expect(sideSnap.isWaiting, true);
    expect(find.text('0'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(sideSnap.data, 1);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);
    expect(sideSnap.data, 2);

    await tester.pump(Duration(seconds: 1));

    expect(find.text('Error message'), findsOneWidget);
    expect(sideSnap.hasError, true);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
    expect(sideSnap.hasError, true);
  });

  testWidgets('Injected.whenRebuilder', (tester) async {
    final widget = OnBuilder.all(
      listenTo: vanillaModel,
      sideEffects: SideEffects(
        initState: () => vanillaModel.setState(
          (s) => s.incrementAsyncWithError().then(
                (_) => Future.delayed(
                  Duration(seconds: 1),
                  () => VanillaModel(5),
                ),
              ),
        ),
      ),
      onIdle: () => Text('Idle'),
      onWaiting: () => Text('waiting ...'),
      onError: (e, _) => Text('${e.message}'),
      shouldRebuild: (_, __) => true,
      onData: (_) {
        return Text('data');
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets('RM.injectComputed', (tester) async {
    vanillaModel.injectMock(() => VanillaModel(1));

    final model2 = RM.injectFuture(
      () => Future.delayed(Duration(seconds: 3), () => 5),
      initialState: 0,
    );

    final computed = RM.inject<int>(
      () => vanillaModel.state.counter * model2.state,
      dependsOn: DependsOn({vanillaModel, model2}),
    );
    //
    final widget = computed.rebuild.onOrElse(
      onWaiting: () => Text('waiting ...'),
      onError: (e, __) => Text('${e.message}'),
      orElse: (_) {
        return Text('${computed.state}');
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('5'), findsOneWidget);
    vanillaModel.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('10'), findsOneWidget);
    vanillaModel.setState((s) => s.incrementAsync());
    await tester.pump();
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('15'), findsOneWidget);
    vanillaModel.setState((s) => s.incrementAsyncWithError());
    await tester.pump();
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets(
    'Nested dependent futures ',
    (tester) async {
      final future1 = RM.injectFuture(
        () => Future.delayed(Duration(seconds: 1), () => 2),
        // isLazy: false, // TODO
      );
      final future2 = RM.injectFuture<int>(
        () async {
          final future1Value = await future1.stateAsync;
          await Future.delayed(Duration(seconds: 1));
          return future1Value * 2;
        },
        initialState: 1,
        // isLazy: false,
      );

      expect(future1.isWaiting, isTrue);
      expect(future2.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(future1.hasData, isTrue);
      expect(future2.isWaiting, isTrue);
      // future2.setState(
      //   (future) async {
      //     await future2.stateAsync;
      //     return Future.delayed(Duration(seconds: 1), () => 2 * future);
      //   },
      //   stateInterceptor: (current, next) => next.isWaiting ? current : next,
      // );
      await tester.pump(Duration(seconds: 1));
      expect(future1.state, 2);
      // expect(future2.isWaiting, isTrue);
      // await tester.pump(Duration(seconds: 1));
      expect(future1.state, 2);
      expect(future2.state, 4);

      //Ensure injected models are disposed;
      await tester.pumpWidget(future2.rebuild(() => Container()));
    },
  );

  testWidgets(
    'Injector : should not throw when using whenRebuilderOr',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        vanillaModel.rebuild.onOrElse(
          onError: (e, _) => Directionality(
            textDirection: TextDirection.ltr,
            child: Text(e.message),
          ),
          orElse: (_) => Container(),
        ),
      );
      vanillaModel.setState(
        (state) => state.incrementAsyncWithError(),
      );
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error message'), findsOneWidget);
    },
  );

  testWidgets('autoDispose dependent injected model', (tester) async {
    bool counter1IsDisposed = false;
    bool counter2IsDisposed = false;
    bool counter3IsDisposed = false;
    final counter1 = RM.inject(
      () => 0,
      sideEffects: SideEffects(
        dispose: () => counter1IsDisposed = true,
      ),
    );
    final counter2 = RM.inject(
      () => 0,
      sideEffects: SideEffects(
        dispose: () => counter2IsDisposed = true,
      ),
    );
    final counter3 = RM.inject<int>(
      () {
        return counter1.state + counter2.state;
      },
      dependsOn: DependsOn({counter1, counter2}),
      sideEffects: SideEffects(
        dispose: () => counter3IsDisposed = true,
      ),
    );
    final switcher = RM.inject(() => true);
    await tester.pumpWidget(switcher.rebuild(() {
      if (switcher.state) {
        return counter3.rebuild(() => Container());
      }
      return Container();
    }));
    switcher.state = false;
    await tester.pump();
    expect(counter3IsDisposed, true);
    await tester.pump();
    expect(counter1IsDisposed, true);
    expect(counter2IsDisposed, true);
  });

  testWidgets('autoDispose dependent injected model (do not dispose counter1)',
      (tester) async {
    bool counter1IsDisposed = false;
    bool counter2IsDisposed = false;
    bool counter3IsDisposed = false;
    bool counter4IsDisposed = false;
    final counter1 = RM.inject(
      () => 0,
      sideEffects: SideEffects(
        dispose: () => counter1IsDisposed = true,
      ),
      // // debugPrintWhenNotifiedPreMessage: true,: 'counter1',
    );
    final counter2 = RM.inject(
      () => 0,
      sideEffects: SideEffects(
        dispose: () => counter2IsDisposed = true,
      ),
      // debugPrintWhenNotifiedPreMessage: true,: 'counter2',
    );
    final counter3 = RM.inject<int>(
      () {
        return counter1.state + counter2.state;
      },
      dependsOn: DependsOn({counter2, counter1}),
      sideEffects: SideEffects(
        dispose: () => counter3IsDisposed = true,
      ),
      // debugPrintWhenNotifiedPreMessage: true,: 'counter3',
    );
    final counter4 = RM.inject(
      () => counter1.state,
      dependsOn: DependsOn({counter1}),
      sideEffects: SideEffects(
        dispose: () => counter4IsDisposed = true,
      ),
      // debugPrintWhenNotifiedPreMessage: true,: 'counter4',
    );

    final switcher = RM.inject(() => true);
    await tester.pumpWidget(switcher.rebuild(() {
      if (switcher.state) {
        return counter3.rebuild(() => Container());
      }
      return Container();
    }));

    switcher.state = false;
    expect(counter4.state, 0);
    await tester.pump();
    expect(counter3IsDisposed, true);
    await tester.pump();
    expect(counter1IsDisposed, false);
    expect(counter2IsDisposed, true);
    expect(counter4IsDisposed, false);
  });

  testWidgets(
    'autoDispose dependent injected model1',
    (tester) async {
      // bool counter1IsDisposed = false;
      // bool counter2IsDisposed = false;
      bool counter3IsDisposed = false;
      final counter1 = RM.inject(
        () => 0,
        // sideEffects: SideEffects(
        //   dispose: () => counter1IsDisposed = true,
        // ),
        // debugPrintWhenNotifiedPreMessage: true,: 'counter1',
      );
      final counter2 = RM.inject(
        () => counter1.state,
        dependsOn: DependsOn({counter1}),
        // sideEffects: SideEffects(
        //   dispose: () => counter2IsDisposed = true,
        // ),
        // debugPrintWhenNotifiedPreMessage: true,: 'counter2',
      );
      final counter3 = RM.inject<int>(
        () {
          return counter1.state;
        },
        dependsOn: DependsOn({counter1}),
        sideEffects: SideEffects(
          dispose: () => counter3IsDisposed = true,
        ),
        // debugPrintWhenNotifiedPreMessage: true,: 'counter3',
      );
      final switcher = RM.inject(() => true);
      await tester.pumpWidget(switcher.rebuild(() {
        counter2.state;
        if (switcher.state) {
          return counter3.rebuild(() => Container());
        }
        return Container();
      }));
      switcher.state = false;
      await tester.pump();
      expect(counter3IsDisposed, true);
      await tester.pump();
      // expect(counter1IsDisposed, true);// TODO
      // expect(counter2IsDisposed, true);
    },
  );

  testWidgets('async computed ', (tester) async {
    final counter1 = RM.inject(() => 1);
    final counter2 = RM.inject(() => 1);

    final counter3 = RM.injectFuture<int>(
      () async {
        await Future.delayed(Duration(seconds: 1));
        return counter1.state + counter2.state;
      },
      dependsOn: DependsOn({counter1, counter2}),
      initialState: 0,
      // isLazy: false,
      // // debugPrintWhenNotifiedPreMessage: true,: 'counter3',
    );

    expect(counter3.isWaiting, isTrue);
    expect(counter3.state, 0);
    await tester.pump(Duration(seconds: 1));
    expect(counter3.hasData, isTrue);
    expect(counter3.state, 2);
    //
    counter1.state++;
    expect(counter3.isWaiting, isTrue);
    expect(counter3.state, 2);
    await tester.pump(Duration(seconds: 1));
    expect(counter3.hasData, isTrue);
    expect(counter3.state, 3);

    //Ensure injected models are disposed;
    await tester.pumpWidget(counter3.rebuild(() => Container()));
  });

  testWidgets('compute async works', (WidgetTester tester) async {
    vanillaModel.injectMock(() => VanillaModel(10));

    await tester.pumpWidget(
      asyncComputed.rebuild(
        () {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text('${asyncComputed.state.counter}'),
          );
        },
      ),
    );

    expect(find.text('0'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('10'), findsOneWidget);
    vanillaModel.state = VanillaModel(20);
    await tester.pump();
    expect(find.text('10'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('20'), findsOneWidget);
  });
  // // group('description', () {
  testWidgets(
      'Injector : should register Stream and Rebuild StateBuilder each time stream sends data with watch',
      (WidgetTester tester) async {
    streamVanillaModel.injectStreamMock(
      () => Stream.periodic(
        Duration(seconds: 1),
        (n) => VanillaModel((n + 1) * 2),
      ).take(6),
    );
    await tester.pumpWidget(
      streamVanillaModel.rebuild(
        () {
          return Directionality(
              textDirection: TextDirection.ltr,
              child: Text(streamVanillaModel.state.counter.toString()));
        },
      ),
    );
    expect(streamVanillaModel.subscription, isNotNull);
    expect(find.text('0'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('4'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('6'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('mock future', (WidgetTester tester) async {
    futureModel.injectFutureMock(
      () => Future.delayed(Duration(seconds: 1), () => 100),
    );
    await tester.pumpWidget(
      futureModel.rebuild(
        () {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text('${futureModel.state}'),
          );
        },
      ),
    );

    expect(find.text('0'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('mock compute async works', (WidgetTester tester) async {
    vanillaModel.injectMock(() => VanillaModel(10));

    asyncComputed.injectStreamMock(
      () async* {
        yield await Future.delayed(
          Duration(seconds: 1),
          () => VanillaModel(vanillaModel.state.counter + 100),
        );
      },
    );

    await tester.pumpWidget(
      asyncComputed.rebuild(
        () {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text('${asyncComputed.state.counter}'),
          );
        },
      ),
    );

    expect(find.text('0'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('110'), findsOneWidget);
    vanillaModel.state = VanillaModel(20);
    await tester.pump();
    expect(find.text('110'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('120'), findsOneWidget);
  });
  // // });

  // testWidgets(
  //     'injected model preserve state when when created inside a build method',
  //     (WidgetTester tester) async {
  //   final counter1 = RM.inject(() => 0);
  //   late Injected<int> counter2;
  //   await tester.pumpWidget(
  //     counter1.rebuild(() {
  //       counter2 = RM.inject(
  //         () => 0,
  //         // debugPrintWhenNotifiedPreMessage: true,: 'counter2',
  //       );
  //       return Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: Column(
  //           children: [
  //             Text('counter1: ${counter1.state}'),
  //             counter2.rebuild(
  //               () {
  //                 print('r');
  //                 return Text('counter2: ${counter2.state}');
  //               },
  //             ),
  //             counter2.rebuild.onOrElse(
  //               shouldRebuild: (_, __) => true,
  //               orElse: (_) => Column(
  //                 children: [
  //                   Text('whenRebuilderOr counter2: ${counter2.state}'),
  //                   counter2.rebuild.onAll(
  //                     onIdle: () => Text('idle'),
  //                     onWaiting: () => Text('Waiting'),
  //                     onData: (_) =>
  //                         Text('whenRebuilder counter2: ${counter2.state}'),
  //                     onError: (_, __) => Text('Error'),
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     }),
  //   );

  //   expect(find.text('counter1: 0'), findsOneWidget);
  //   expect(find.text('counter2: 0'), findsOneWidget);

  //   //increment counter2
  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 0'), findsOneWidget);
  //   expect(find.text('counter2: 1'), findsOneWidget);

  //   //increment counter1
  //   counter1.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 1'), findsOneWidget);

  //   //increment counter2
  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 2'), findsOneWidget);

  //   //increment counter1
  //   counter1.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 2'), findsOneWidget);
  //   expect(find.text('counter2: 2'), findsOneWidget);

  //   //increment counter2
  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 2'), findsOneWidget);
  //   expect(find.text('counter2: 3'), findsOneWidget);
  //   expect(find.text('whenRebuilderOr counter2: 3'), findsOneWidget);
  //   expect(find.text('whenRebuilder counter2: 3'), findsOneWidget);
  // });

  // testWidgets('injected model preserve state (with whenRebuilderOr)',
  //     (WidgetTester tester) async {
  //   final counter1 = RM.inject(() => 0);
  //   late Injected<int> counter2;
  //   await tester.pumpWidget(
  //     counter1.rebuild(
  //       () {
  //         counter2 = RM.inject(
  //           () => 0,
  //           // // debugPrintWhenNotifiedPreMessage: true,: 'counter2',
  //         );
  //         return Directionality(
  //           textDirection: TextDirection.ltr,
  //           child: Column(
  //             children: [
  //               Text('counter1: ${counter1.state}'),
  //               counter2.rebuild.onOrElse(
  //                 orElse: (_) => Column(
  //                   children: [
  //                     Text('whenRebuilderOr counter2: ${counter2.state}'),
  //                     counter2.rebuild.onAll(
  //                       onIdle: () => Text('idle'),
  //                       onWaiting: () => Text('Waiting'),
  //                       onData: (_) =>
  //                           Text('whenRebuilder counter2: ${counter2.state}'),
  //                       onError: (_, __) => Text('Error'),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               counter2.rebuild(
  //                 () => Text('counter2: ${counter2.state}'),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );

  //   expect(find.text('counter1: 0'), findsOneWidget);
  //   expect(find.text('counter2: 0'), findsOneWidget);

  //   //increment counter2
  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 0'), findsOneWidget);
  //   expect(find.text('counter2: 1'), findsOneWidget);

  //   //increment counter1
  //   counter1.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 1'), findsOneWidget);

  //   //increment counter2
  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 2'), findsOneWidget);

  //   //increment counter1
  //   counter1.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 2'), findsOneWidget);
  //   expect(find.text('counter2: 2'), findsOneWidget);

  //   //increment counter2
  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 2'), findsOneWidget);
  //   expect(find.text('counter2: 3'), findsOneWidget);
  //   expect(find.text('whenRebuilderOr counter2: 3'), findsOneWidget);
  //   expect(find.text('whenRebuilder counter2: 3'), findsOneWidget);
  // });

  // testWidgets('injected model preserve state (with whenRebuilder)',
  //     (WidgetTester tester) async {
  //   final counter1 = RM.inject(() => 0);
  //   late Injected<int> counter2;
  //   await tester.pumpWidget(
  //     counter1.rebuild(
  //       () {
  //         counter2 = RM.inject(
  //           () => 0,
  //           // // debugPrintWhenNotifiedPreMessage: true,: 'counter2',
  //         );
  //         return Directionality(
  //           textDirection: TextDirection.ltr,
  //           child: Column(
  //             children: [
  //               Text('counter1: ${counter1.state}'),
  //               counter2.rebuild.onAll(
  //                 onIdle: () => Text('idle'),
  //                 onWaiting: () => Text('Waiting'),
  //                 onError: (_, __) => Text('Error'),
  //                 onData: (_) => Column(
  //                   children: [
  //                     Text('whenRebuilderOr counter2: ${counter2.state}'),
  //                     counter2.rebuild.onOrElse(
  //                       orElse: (_) =>
  //                           Text('whenRebuilder counter2: ${counter2.state}'),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               counter2.rebuild(
  //                 () => Text('counter2: ${counter2.state}'),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );

  //   expect(find.text('counter1: 0'), findsOneWidget);
  //   expect(find.text('counter2: 0'), findsOneWidget);

  //   //increment counter2
  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 0'), findsOneWidget);
  //   expect(find.text('counter2: 1'), findsOneWidget);

  //   //increment counter1
  //   counter1.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 1'), findsOneWidget);

  //   //increment counter2
  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 2'), findsOneWidget);

  //   //increment counter1
  //   counter1.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 2'), findsOneWidget);
  //   expect(find.text('counter2: 2'), findsOneWidget);

  //   //increment counter2
  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 2'), findsOneWidget);
  //   expect(find.text('counter2: 3'), findsOneWidget);
  //   expect(find.text('whenRebuilderOr counter2: 3'), findsOneWidget);
  //   expect(find.text('whenRebuilder counter2: 3'), findsOneWidget);
  // });

  // testWidgets('injected model preserve state with stream',
  //     (WidgetTester tester) async {
  //   final counter1 = RM.inject(() => 0);
  //   late Injected<int?> counter2;
  //   int? onData;
  //   int numberOfOnInitialized = 0;
  //   int numberOfOnDisposed = 0;
  //   await tester.pumpWidget(
  //     counter1.rebuild(
  //       () {
  //         counter2 = RM.injectStream<int?>(
  //           () {
  //             return Stream.periodic(Duration(seconds: 1), (n) {
  //               return n + 1;
  //             }).take(3);
  //           },
  //           sideEffects: SideEffects(
  //             onSetState: (snap) {
  //               if (snap.hasData) onData = snap.data;
  //             },
  //             initState: () => numberOfOnInitialized++,
  //             dispose: () => numberOfOnDisposed++,
  //           ),
  //           // debugPrintWhenNotifiedPreMessage: true,: 'counter2',
  //           // isLazy: false,
  //         );

  //         return Directionality(
  //           textDirection: TextDirection.ltr,
  //           child: Column(
  //             children: [
  //               Text('counter1: ${counter1.state}'),
  //               counter2.rebuild(
  //                 () {
  //                   print('');
  //                   return Text('counter2: ${counter2.state}');
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );

  //   expect(find.text('counter1: 0'), findsOneWidget);
  //   expect(find.text('counter2: null'), findsOneWidget);

  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('counter1: 0'), findsOneWidget);
  //   expect(find.text('counter2: 1'), findsOneWidget);
  //   expect(onData, 1);

  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('counter1: 0'), findsOneWidget);
  //   expect(find.text('counter2: 2'), findsOneWidget);
  //   expect(onData, 2);
  //   // increment counter1
  //   counter1.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 2'), findsOneWidget);

  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 3'), findsOneWidget);
  //   expect(onData, 3);
  //   expect(numberOfOnInitialized, 2); //Better 1
  //   expect(numberOfOnDisposed, 0);
  // });

  // testWidgets('injected model preserve state computed injected',
  //     (WidgetTester tester) async {
  //   final counter0 = RM.inject(() => 0);
  //   late Injected<int> counter1;
  //   late Injected<int> counter2;
  //   await tester.pumpWidget(
  //     counter0.rebuild(
  //       () {
  //         counter1 = RM.inject(() => 0);
  //         counter2 = RM.inject<int>(
  //           () => counter1.state * 10,
  //           dependsOn: DependsOn({counter1}),
  //         );

  //         return Directionality(
  //           textDirection: TextDirection.ltr,
  //           child: Column(
  //             children: [
  //               counter1.rebuild(
  //                 () => Text('counter1: ${counter1.state}'),
  //               ),
  //               counter2.rebuild(
  //                 () => Text('counter2: ${counter2.state}'),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );

  //   expect(find.text('counter1: 0'), findsOneWidget);
  //   expect(find.text('counter2: 0'), findsOneWidget);

  //   // increment counter1
  //   counter1.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 10'), findsOneWidget);

  //   // increment counter2
  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 11'), findsOneWidget);

  //   // increment counter1
  //   counter0.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 1'), findsOneWidget);
  //   expect(find.text('counter2: 11'), findsOneWidget);
  //   //the dependency is not lost
  //   counter1.state++;
  //   await tester.pump();
  //   expect(find.text('counter1: 2'), findsOneWidget);
  //   expect(find.text('counter2: 20'), findsOneWidget);
  // });

  testWidgets('setState onDate and onError overrides global definition',
      (tester) async {
    String? data;
    String? error;
    final model = RM.inject<VanillaModel>(
      () => VanillaModel(),
      sideEffects: SideEffects.onAll(
        onWaiting: null,
        onError: (_, __) => error = 'Error from global',
        onData: (_) => data = 'Data from global',
      ),
    );

    model.setState((s) => s.increment());
    expect(data, 'Data from global');
    model.setState(
      (s) => s.increment(),
      sideEffects: SideEffects.onData((_) => data = 'Data from setState'),
      shouldOverrideDefaultSideEffects: (_) => true,
    );
    expect(data, 'Data from setState');

    //
    model.setState((s) => throw Exception('error'));
    expect(error, 'Error from global');

    model.setState(
      (s) => throw Exception('error'),
      sideEffects: SideEffects.onError(
        (_, __) => error = 'Error from setState',
      ),
      shouldOverrideDefaultSideEffects: (_) => true,
    );
    expect(error, 'Error from setState');
  });

  // //

  testWidgets('Mock flavor case InjectedImp', (tester) async {
    RM.env = '1';

    final interface = RM.injectFlavor({
      '1': () => 1,
      '2': () => 2,
    });
    interface.injectMock(() => 10);
    expect(interface.state, 10);
  });

  testWidgets('Mock flavor case InjectFuture', (tester) async {
    RM.env = '2';

    final interface = RM.injectFlavor(
      {
        '1': () => Future.delayed(Duration(seconds: 1), () => 1),
        '2': () => Future.delayed(Duration(seconds: 1), () => 2),
      },
      initialState: 0,
    );
    interface
        .injectFutureMock(() => Future.delayed(Duration(seconds: 1), () => 10));
    expect(interface.state, 0);
    await tester.pump(Duration(seconds: 1));
    expect(interface.state, 10);
  });

  testWidgets('rebuilder with many observers', (tester) async {
    final counter1 = RM.inject(() => 0);
    final counter2 = RM.inject(() => 10);

    final widget = [counter1, counter2].rebuild(
      () => Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Text('${counter1.state}'),
            Text('${counter2.state}'),
          ],
        ),
      ),
    );

    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    counter1.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    //

    counter2.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
  });

  // testWidgets('rebuilder with many observers preserve state', (tester) async {
  //   final counter1 = RM.inject(() => 0);
  //   late Injected<int> counter2;
  //   final widget = counter1.rebuild(
  //     () {
  //       counter2 = RM.inject(() => 10);
  //       return [counter1, counter2].rebuild(
  //         () => Directionality(
  //           textDirection: TextDirection.ltr,
  //           child: Column(
  //             children: [
  //               Text('${counter1.state}'),
  //               Text('${counter2.state}'),
  //             ],
  //           ),
  //         ),
  //         watch: () => [counter1.state, counter2.state],
  //       );
  //     },
  //   );

  //   await tester.pumpWidget(widget);
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('10'), findsOneWidget);

  //   counter1.state++;
  //   await tester.pump();
  //   expect(find.text('1'), findsOneWidget);
  //   expect(find.text('10'), findsOneWidget);
  //   //

  //   counter2.state++;
  //   await tester.pump();
  //   expect(find.text('1'), findsOneWidget);
  //   expect(find.text('11'), findsOneWidget);
  // });

  // testWidgets('whenRebuilder with many observers preserve state',
  //     (tester) async {
  //   final counter1 = RM.inject(
  //     () => VanillaModel(0),
  //     // // debugPrintWhenNotifiedPreMessage: true,: 'counter1',
  //   );
  //   late Injected<VanillaModel> counter2;
  //   final widget = counter1.rebuild(
  //     () {
  //       counter2 = RM.inject(() => VanillaModel(10));
  //       return Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: [counter1, counter2].rebuild.onAll(
  //               onIdle: () => Text('Idle'),
  //               onWaiting: () => Text('onWaiting'),
  //               onError: (_, __) => Text('Error'),
  //               onData: (_) => Column(
  //                 children: [
  //                   Text('${counter1.state.counter}'),
  //                   Text('${counter2.state.counter}'),
  //                 ],
  //               ),
  //               sideEffects: SideEffects.onError(
  //                   (err, refresh) => Text('${err.message}')),
  //             ),
  //       );
  //     },
  //   );

  //   await tester.pumpWidget(widget);
  //   expect(find.text('Idle'), findsOneWidget);
  //   //
  //   counter1.setState((s) => s.incrementAsync());
  //   await tester.pump();
  //   expect(find.text('onWaiting'), findsOneWidget);
  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('Idle'), findsOneWidget);

  //   //
  //   counter2.setState((s) => s.incrementAsync());
  //   await tester.pump();
  //   expect(find.text('onWaiting'), findsOneWidget);
  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('1'), findsOneWidget);
  //   expect(find.text('11'), findsOneWidget);

  //   //
  //   counter2.setState((s) => s.incrementAsyncWithError());
  //   await tester.pump();
  //   expect(find.text('onWaiting'), findsOneWidget);
  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('Error message'), findsOneWidget);
  // });

  // testWidgets('whenRebuilderOr with many observers preserve state',
  //     (tester) async {
  //   final counter1 = RM.inject(
  //     () => VanillaModel(0),
  //     // // debugPrintWhenNotifiedPreMessage: true,: 'counter1',
  //   );
  //   late Injected<VanillaModel> counter2;
  //   final widget = counter1.rebuild(
  //     () {
  //       counter2 = RM.inject(() => VanillaModel(10));
  //       return Directionality(
  //         textDirection: TextDirection.ltr,
  //         child: [counter1, counter2].rebuild.onOrElse(
  //               onWaiting: () => Text('onWaiting'),
  //               orElse: (_) => Column(
  //                 children: [
  //                   Text('${counter1.state.counter}'),
  //                   Text('${counter2.state.counter}'),
  //                 ],
  //               ),
  //               onIdle: () => Text('Idle'),
  //               onError: (e, _) => Text('${e.message}'),
  //             ),
  //       );
  //     },
  //   );

  //   await tester.pumpWidget(widget);
  //   expect(find.text('Idle'), findsOneWidget);
  //   //
  //   counter1.setState((s) => s.incrementAsync());
  //   await tester.pump();
  //   expect(find.text('onWaiting'), findsOneWidget);
  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('Idle'), findsOneWidget);

  //   //
  //   counter2.setState((s) => s.incrementAsync());
  //   await tester.pump();
  //   expect(find.text('onWaiting'), findsOneWidget);
  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('1'), findsOneWidget);
  //   expect(find.text('11'), findsOneWidget);

  //   //
  //   counter2.setState((s) => s.incrementAsyncWithError());
  //   await tester.pump();
  //   expect(find.text('onWaiting'), findsOneWidget);
  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('Error message'), findsOneWidget);
  // });

  testWidgets(
    'Injected onSetState work',
    (tester) async {
      int counter1OnSetState = 0;
      String counter2OnSetState = '';
      final counter1 = RM.inject<int>(
        () => 0,
        sideEffects: SideEffects(
          onSetState: (snap) => counter1OnSetState++,
        ),
      );

      final counter2 = RM.inject<int>(
        () => 0,
        sideEffects: SideEffects.onAll(
          onWaiting: () => counter2OnSetState += 'Waiting ',
          onError: (_, __) => counter2OnSetState += 'Error ',
          onData: (_) => counter2OnSetState += 'Data ',
        ),
      );
      expect(counter1OnSetState, 0);
      expect(counter2OnSetState, '');
      //
      counter1.state++;
      counter2.setState(
          (s) => Future.delayed(Duration(seconds: 1), () => 'newState'));
      await tester.pump();
      expect(counter1OnSetState, 1);
      expect(counter2OnSetState, 'Waiting ');
      await tester.pump(Duration(seconds: 1));
      expect(counter1OnSetState, 1);
      expect(counter2OnSetState, 'Waiting Data ');
      //
      counter1.state++;
      counter2.setState(
          (s) => Future.delayed(Duration(seconds: 1), () => throw Exception()));
      await tester.pump();
      expect(counter1OnSetState, 2);
      expect(counter2OnSetState, 'Waiting Data Waiting ');
      await tester.pump(Duration(seconds: 1));
      expect(counter1OnSetState, 2);
      expect(counter2OnSetState, 'Waiting Data Waiting Error ');
    },
  );

  testWidgets(
    'onSetState of setState override onSetState if inject if they have the '
    'same status',
    (tester) async {
      int injectOnSetState = 0;
      int setStateOnSetState = 0;
      final counter = RM.inject<int>(
        () => 0,
        sideEffects: SideEffects(
          onSetState: (snap) => injectOnSetState++,
        ),
      );

      counter.setState(
        (s) => s + 1,
        sideEffects: SideEffects.onData((_) => setStateOnSetState++),
        shouldOverrideDefaultSideEffects: (_) => true,
      );
      await tester.pump();
      expect(injectOnSetState, 0);
      expect(setStateOnSetState, 1);

      counter.setState(
        (s) => s + 1,
        sideEffects: SideEffects.onOrElse(orElse: (_) => setStateOnSetState++),
        shouldOverrideDefaultSideEffects: (_) => true,
      );
      await tester.pump();
      expect(injectOnSetState, 0);
      expect(setStateOnSetState, 2);
    },
  );

  testWidgets(
    'onSetState of setState does not override onSetState if inject if they have '
    'different status, case On.onData is defined for setState',
    (tester) async {
      int injectOnSetState = 0;
      int setStateOnSetState = 0;
      final counter = RM.inject(
        () => 0,
        sideEffects: SideEffects(
          onSetState: (snap) {
            injectOnSetState++;
          },
        ),
      );

      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => 1),
        sideEffects: SideEffects.onData(
          (_) {
            setStateOnSetState++;
          },
        ),
        shouldOverrideDefaultSideEffects: (snap) => snap.hasData,
      );
      await tester.pump();
      expect(injectOnSetState, 1);
      expect(setStateOnSetState, 0);
      await tester.pump(Duration(seconds: 1));
      expect(injectOnSetState, 1);
      expect(setStateOnSetState, 1);
      //
      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => throw Exception()),
        sideEffects: SideEffects.onData((_) {
          setStateOnSetState++;
        }),
        shouldOverrideDefaultSideEffects: (snap) => snap.hasData,
      );
      await tester.pump();
      expect(injectOnSetState, 2);
      expect(setStateOnSetState, 1);
      await tester.pump(Duration(seconds: 1));
      expect(injectOnSetState, 3);
      expect(setStateOnSetState, 1);
      //
      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => throw Exception()),
        sideEffects: SideEffects(onSetState: (_) {
          setStateOnSetState++;
        }),
        shouldOverrideDefaultSideEffects: (snap) => true,
      );
      await tester.pump();
      expect(injectOnSetState, 3);
      expect(setStateOnSetState, 2);
      await tester.pump(Duration(seconds: 1));
      expect(injectOnSetState, 3);
      expect(setStateOnSetState, 3);
    },
  );

  testWidgets(
    'onSetState of setState does not override onSetState if inject if they have '
    'different status, case On.error is defined for setState',
    (tester) async {
      int injectOnSetState = 0;
      int setStateOnSetState = 0;
      final counter = RM.inject(
        () => 0,
        sideEffects: SideEffects(
          onSetState: (_) => injectOnSetState++,
        ),
      );

      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => 1),
        sideEffects: SideEffects.onError((err, _) {
          setStateOnSetState++;
        }),
        shouldOverrideDefaultSideEffects: (snap) => snap.hasError,
      );
      await tester.pump();
      expect(injectOnSetState, 1);
      expect(setStateOnSetState, 0);
      await tester.pump(Duration(seconds: 1));
      expect(injectOnSetState, 2);
      expect(setStateOnSetState, 0);
      //
      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => throw Exception()),
        sideEffects: SideEffects.onError((err, _) {
          setStateOnSetState++;
        }),
        shouldOverrideDefaultSideEffects: (snap) => snap.hasError,
      );
      await tester.pump();
      expect(injectOnSetState, 3);
      expect(setStateOnSetState, 0);
      await tester.pump(Duration(seconds: 1));
      expect(injectOnSetState, 3);
      expect(setStateOnSetState, 1);
      //
      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => throw Exception()),
        sideEffects: SideEffects(onSetState: (_) {
          setStateOnSetState++;
        }),
        shouldOverrideDefaultSideEffects: (snap) => true,
      );
      await tester.pump();
      expect(injectOnSetState, 3);
      expect(setStateOnSetState, 2);
      await tester.pump(Duration(seconds: 1));
      expect(injectOnSetState, 3);
      expect(setStateOnSetState, 3);
    },
  );

  testWidgets(
    'onSetState of setState does not override onSetState if inject if they have '
    'different status, case On.waiting is defined for setState',
    (tester) async {
      int injectOnSetState = 0;
      int setStateOnSetState = 0;
      final counter = RM.inject(
        () => 0,
        sideEffects: SideEffects(
          onSetState: (_) => injectOnSetState++,
        ),
      );

      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => 1),
        sideEffects: SideEffects.onWaiting(() {
          setStateOnSetState++;
        }),
        shouldOverrideDefaultSideEffects: (snap) => snap.isWaiting,
      );
      await tester.pump();
      expect(injectOnSetState, 0);
      expect(setStateOnSetState, 1);
      await tester.pump(Duration(seconds: 1));
      expect(injectOnSetState, 1);
      expect(setStateOnSetState, 1);
      //
      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => throw Exception()),
        sideEffects: SideEffects.onWaiting(() {
          setStateOnSetState++;
        }),
        shouldOverrideDefaultSideEffects: (snap) => snap.isWaiting,
      );
      await tester.pump();
      expect(injectOnSetState, 1);
      expect(setStateOnSetState, 2);
      await tester.pump(Duration(seconds: 1));
      expect(injectOnSetState, 2);
      expect(setStateOnSetState, 2);
      //
      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => throw Exception()),
        sideEffects: SideEffects(onSetState: (_) {
          setStateOnSetState++;
        }),
        shouldOverrideDefaultSideEffects: (snap) => true,
      );
      await tester.pump();
      expect(injectOnSetState, 2);
      expect(setStateOnSetState, 3);
      await tester.pump(Duration(seconds: 1));
      expect(injectOnSetState, 2);
      expect(setStateOnSetState, 4);
    },
  );

  testWidgets(
    'Injected model invoke mutable future',
    (tester) async {
      // final model = RM.injectFuture(
      //   vanillaModel.future((s) => s.incrementAsync()),
      // );
      final model = RM.injectFuture(
        () => vanillaModel.state.incrementAsync(),
        sideEffects: SideEffects.onAll(
          onWaiting: () {},
          onError: (err, ref) {
            vanillaModel.setToHasError(err, refresher: ref);
          },
          onData: (_) => vanillaModel.setToHasData(_),
        ),
      );
      expect(model.isWaiting, true);
      expect(vanillaModel.isIdle, true);
      expect(vanillaModel.state.counter, 0);
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      expect(model.state, 1);
      expect(vanillaModel.hasData, true);
      expect(vanillaModel.state.counter, 1);

      final model1 = RM.injectFuture(
        () => vanillaModel.state.incrementAsyncWithError(),
        sideEffects: SideEffects.onAll(
          onWaiting: () {},
          onError: (err, ref) {
            vanillaModel.setToHasError(err, refresher: ref);
          },
          onData: (_) => vanillaModel.setToHasData(_),
        ),
      );
      expect(model1.isWaiting, true);
      expect(vanillaModel.hasData, true);
      expect(vanillaModel.state.counter, 1);
      await tester.pump(Duration(seconds: 1));
      expect(model1.hasError, true);
      expect(vanillaModel.hasError, true);
      vanillaModel.dispose();
    },
  );

  // testWidgets(//TODO
  //   'Injected model invoke immutable future',
  //   (tester) async {
  //     final model = RM.injectFuture(
  //       vanillaModel.future((s) => s.incrementAsyncImmutable()),
  //     );
  //     expect(model.isWaiting, true);
  //     expect(vanillaModel.isIdle, true);
  //     expect(vanillaModel.state.counter, 0);
  //     await tester.pump(Duration(seconds: 1));
  //     expect(model.hasData, true);
  //     expect(model.state.counter, 1);
  //     expect(vanillaModel.hasData, true);
  //     expect(vanillaModel.state.counter, 1);
  //     //

  //     final model1 = RM.injectFuture(
  //       vanillaModel.future((s) => s.incrementAsyncWithError()),
  //     );
  //     expect(model1.isWaiting, true);
  //     expect(vanillaModel.hasData, true);
  //     await tester.pump(Duration(seconds: 1));
  //     expect(model1.hasError, true);
  //     expect(vanillaModel.hasError, true);
  //   },
  // );

  testWidgets(
    'Test toDebugString for sync state ',
    (tester) async {
      final model = RM.inject(
        () => [],
        debugPrintWhenNotifiedPreMessage: 'model',
        toDebugString: (List? s) => '${s?.length}',
      );
      model.state = ['1'];
      expect(
        StatesRebuilerLogger.message,
        '[states_rebuilder::INFO]: <model> : INITIALIZING... ==> hasData: 1',
      );
      RM.disposeAll();
      expect(
        StatesRebuilerLogger.message,
        '[states_rebuilder::INFO]: <model> : hasData: 1 ==> DISPOSING...',
      );
    },
  );

  testWidgets(
    'Test toDebugString for async state ',
    (tester) async {
      final model = RM.inject(
        () => [],
        debugPrintWhenNotifiedPreMessage: 'model',
        toDebugString: (List? s) => '${s?.length}',
      );
      model.stateAsync =
          Future.delayed(const Duration(seconds: 1), () => ['1']);
      await tester.pump();
      expect(
        StatesRebuilerLogger.message,
        '[states_rebuilder::INFO]: <model> : INITIALIZING... ==> isWaiting (): null',
      );
      await tester.pump(const Duration(seconds: 1));
      expect(
        StatesRebuilerLogger.message,
        '[states_rebuilder::INFO]: <model> : isWaiting (): null ==> hasData: 1',
      );
      RM.disposeAll();
      expect(
        StatesRebuilerLogger.message,
        '[states_rebuilder::INFO]: <model> : hasData: 1 ==> DISPOSING...',
      );
    },
  );

  testWidgets(
    'test when future return a stream',
    (tester) async {
      final model = RM.injectFuture(() async {
        await Future.delayed(Duration(seconds: 1));
        return Stream.fromFuture(
            Future.delayed(Duration(seconds: 1), () => 'ok'));
      });
      expect(model.isWaiting, true);
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
      await tester.pump(Duration(seconds: 1));
      expect(model.hasData, true);
    },
  );
}

abstract class IModelInterface {
  int counter = 0;
  void increment();
}

class ModelProd implements IModelInterface {
  @override
  void increment() {
    counter += 1;
  }

  @override
  int counter = 0;
}

class ModelTest implements IModelInterface {
  @override
  void increment() {
    counter += 2;
  }

  @override
  int counter = 0;
}

enum Env { prod, test }
