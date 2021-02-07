import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:states_rebuilder/src/reactive_model.dart';

final vanillaModel = RM.inject(() => VanillaModel());
final streamVanillaModel = RM.injectStream(
  () => Stream.periodic(Duration(seconds: 1),
      (num) => num < 3 ? VanillaModel(num) : VanillaModel(3)).take(6),
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
  tearDown(() {
    // assert(functionalInjectedModels.isEmpty);
  });
  testWidgets(
    'should not throw if async method is called from initState',
    (tester) async {
      final widget = vanillaModel.rebuilder(
        () {
          return Column(
            children: <Widget>[
              Container(),
            ],
          );
        },
        initState: () {
          vanillaModel.setState(
            (s) => s.incrementError(),
            catchError: true,
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(vanillaModel.isWaiting, isTrue);
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      expect(vanillaModel.hasError, isTrue);
    },
  );

  testWidgets(
    'will  stream dispose if the injected stream is disposed',
    (tester) async {
      final switcherRM = RM.inject(() => true);

      final widget = switcherRM.rebuilder(() {
        if (switcherRM.state) {
          return streamVanillaModel.rebuilder(
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
      switcherRM.state = false;

      await tester.pump();

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsNothing);
      expect(streamVanillaModel.subscription, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsNothing);
    },
  );

  // testWidgets(//TODO
  //   'models are injected lazily and disposed automatically',
  //   (tester) async {
  //     expect(functionalInjectedModels.length, 0);
  //     final switcherRM = RM.create(true);
  //     bool disposeIsCalled = false;
  //     final widget = StateBuilder(
  //       observe: () => switcherRM,
  //       dispose: (_, __) => RM.disposeAll(),
  //       builder: (_, __) => switcherRM.state
  //           ? vanillaModel.rebuilder(
  //               () => Container(),
  //               shouldRebuild: () => true,
  //               watch: () => 1,
  //               dispose: () => disposeIsCalled = true,
  //             )
  //           : Container(),
  //     );
  //     await tester.pumpWidget(widget);
  //     expect(functionalInjectedModels.length, 1);
  //     switcherRM.state = false;
  //     await tester.pumpWidget(widget);
  //     expect(functionalInjectedModels.length, 0);
  //     //
  //     streamVanillaModel.getRM;
  //     switcherRM.state = true;
  //     await tester.pumpWidget(widget);
  //     expect(functionalInjectedModels.length, 2);
  //     expect(disposeIsCalled, isTrue);
  //   },
  // );

  testWidgets(
      'should register Stream and Rebuild StateBuilder each time stream sends data with watch',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      streamVanillaModel.rebuilder(
        () {
          numberOfRebuild++;
          return Container();
        },
      ),
    );

    expect(numberOfRebuild, equals(1));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(1));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(2));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(3));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(4));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(4));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(4));
    streamVanillaModel.notify();
    await tester.pump();
    expect(numberOfRebuild, equals(5));
  });

  testWidgets('RM.injectFuture', (WidgetTester tester) async {
    await tester.pumpWidget(
      futureModel.rebuilder(
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
      futureModel.rebuilder(
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
      await tester.pumpWidget(vanillaModel.rebuilder(() => Container()));
      String? errorMessage;
      vanillaModel.setState(
        (state) => state.incrementError(),
        onError: (error) {
          errorMessage = error.message;
        },
      );
      await tester.pump();
      await tester.pump(Duration(seconds: 2));
      expect(errorMessage, 'Error message');
    },
  );
  testWidgets('Injector.interface should work Env.prod', (tester) async {
    RM.env = Env.prod;

    Widget widget = interface.rebuilder(() {
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
    Widget widget = interface.rebuilder(() {
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

  testWidgets('Injector.flavor assertions', (tester) async {
    StatesRebuilerLogger.isTestMode = true;
    final model = RM.injectFlavor({
      '1': () => 1,
      '2': () => 2,
    });

    expect(() => model.state, throwsAssertionError);
    model.dispose();
    //
    final model2 = RM.injectFlavor({
      '1': () => 1,
      '2': () => 2,
      '3': () => 3,
    });
    RM.env = '1';
    expect(() => model2.state, throwsAssertionError);
    //
    RM.env = '3';
    final model3 = RM.injectFlavor({
      '1': () => 1,
      '2': () => 2,
    });
    expect(() => model3.state, throwsAssertionError);
  });

  testWidgets('Injected.streamBuilder without error', (tester) async {
    final widget = vanillaModel.streamBuilder<int>(
      stream: (s, subscription) {
        return s?.incrementStream.call();
      },
      onError: null,
      onWaiting: () => Text('waiting ...'),
      onData: (state) {
        return Text('$state');
      },
      onDone: (state) {
        return Text('done $state');
      },
      dispose: () {},
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
    final widget = vanillaModel.streamBuilder(
      stream: (s, subscription) => s?.incrementStreamWithError(),
      onWaiting: null,
      onError: (e) => Text('${e.message}'),
      onData: (state) {
        return Text('$state');
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));

    expect(find.text('0'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    expect(find.text('Error message'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets('Injected.whenRebuilder', (tester) async {
    final widget = vanillaModel.whenRebuilder(
      initState: () => vanillaModel.setState(
        (s) => s.incrementError().then(
              (_) => Future.delayed(
                Duration(seconds: 1),
                () => VanillaModel(5),
              ),
            ),
      ),
      onIdle: () => Text('Idle'),
      onWaiting: () => Text('waiting ...'),
      onError: (e) => Text('${e.message}'),
      dispose: () => null,
      onData: () {
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
    final widget = computed.whenRebuilderOr(
      onWaiting: () => Text('waiting ...'),
      onError: (e) => Text('${e.message}'),
      initState: () => null,
      dispose: () => null,
      builder: () {
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
    vanillaModel.setState((s) => s.incrementError());
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
        isLazy: false,
      );
      final future2 = RM.injectFuture<int>(
        () async {
          final future1Value = await future1.stateAsync;
          await Future.delayed(Duration(seconds: 1));
          return future1Value * 2;
        },
        isLazy: false,
      );

      expect(future1.isWaiting, isTrue);
      expect(future2.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(future1.hasData, isTrue);
      expect(future2.isWaiting, isTrue);
      future2.setState(
        (future) => Future.delayed(Duration(seconds: 1), () => 2 * future),
        silent: true,
        shouldAwait: true,
      );
      await tester.pump(Duration(seconds: 1));
      expect(future1.state, 2);
      expect(future2.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(future1.state, 2);
      expect(future2.state, 8);

      //Ensure injected models are disposed;
      await tester.pumpWidget(future2.rebuilder(() => Container()));
    },
  );

  testWidgets(
    'Injector : should not throw when using whenRebuilderOr',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        vanillaModel.whenRebuilderOr(
          onError: (e) => Directionality(
            textDirection: TextDirection.ltr,
            child: Text(e.message),
          ),
          builder: () => Container(),
        ),
      );
      vanillaModel.setState(
        (state) => state.incrementError(),
      );
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error message'), findsOneWidget);
    },
  );

  // testWidgets(
  //   'Injector : whenRebuilderOr should not rebuild if onWaiting is not defined',
  //   (WidgetTester tester) async {
  //     int numberOfRebuilds = 0;
  //     await tester.pumpWidget(
  //       vanillaModel.whenRebuilderOr(
  //         builder: () {
  //           numberOfRebuilds++;
  //           return Container();
  //         },
  //       ),
  //     );
  //     expect(numberOfRebuilds, 1);
  //     vanillaModel.setState(
  //       (state) => state.incrementAsync(),
  //     );
  //     await tester.pump();
  //     expect(numberOfRebuilds, 1);

  //     await tester.pump(Duration(seconds: 1));
  //     expect(numberOfRebuilds, 2);
  //   },
  // );

  // testWidgets(
  //   'Injector : whenRebuilderOr should rebuild if onError is not defined',
  //   (WidgetTester tester) async {
  //     int numberOfRebuilds = 0;
  //     await tester.pumpWidget(
  //       vanillaModel.whenRebuilderOr(
  //         builder: () {
  //           numberOfRebuilds++;
  //           return Container();
  //         },
  //       ),
  //     );
  //     expect(numberOfRebuilds, 1);
  //     vanillaModel.setState(
  //       (state) => state.incrementError(),
  //       catchError: true,
  //     );
  //     await tester.pump();
  //     expect(numberOfRebuilds, 1);

  //     await tester.pump(Duration(seconds: 2));
  //     expect(numberOfRebuilds, 2);
  //   },
  // );

  // testWidgets('autoDispose dependent injected model', (tester) async {
  //   bool counter1IsDisposed = false;
  //   bool counter2IsDisposed = false;
  //   bool counter3IsDisposed = false;
  //   final counter1 = RM.inject(
  //     () => 0,
  //     onDisposed: (_) => counter1IsDisposed = true,
  //   );
  //   final counter2 = RM.inject(
  //     () => 0,
  //     onDisposed: (_) => counter2IsDisposed = true,
  //   );
  //   final counter3 = RM.inject<int>(
  //     () {
  //       return counter1.state + counter2.state;
  //     },
  //     onDisposed: (_) => counter3IsDisposed = true,
  //   );
  //   final switcher = ReactiveModel.create(true);
  //   await tester.pumpWidget(StateBuilder(
  //     observe: () => switcher,
  //     builder: (_, __) {
  //       if (switcher.state) {
  //         return counter3.rebuilder(() => Container());
  //       }
  //       return Container();
  //     },
  //   ));
  //   switcher.state = false;
  //   await tester.pump();
  //   expect(counter3IsDisposed, true);
  //   await tester.pump();
  //   expect(counter1IsDisposed, true);
  //   expect(counter2IsDisposed, true);
  // });

  // testWidgets('autoDispose dependent injected model (do not dispose counter1)',
  //     (tester) async {
  //   bool counter1IsDisposed = false;
  //   bool counter2IsDisposed = false;
  //   bool counter3IsDisposed = false;
  //   bool counter4IsDisposed = false;
  //   final counter1 = RM.inject(
  //     () => 0,
  //     onDisposed: (_) => counter1IsDisposed = true,
  //   );
  //   final counter2 = RM.inject(
  //     () => 0,
  //     onDisposed: (_) => counter2IsDisposed = true,
  //   );
  //   final counter3 = RM.inject<int>(
  //     () {
  //       return counter1.state + counter2.state;
  //     },
  //     onDisposed: (_) => counter3IsDisposed = true,
  //   );
  //   final counter4 = RM.inject(
  //     () => counter1.state,
  //     onDisposed: (_) => counter4IsDisposed = true,
  //   );
  //   final switcher = ReactiveModel.create(true);
  //   await tester.pumpWidget(StateBuilder(
  //     observe: () => switcher,
  //     builder: (_, __) {
  //       if (switcher.state) {
  //         return counter3.rebuilder(() => Container());
  //       }
  //       return Container();
  //     },
  //   ));
  //   switcher.state = false;
  //   counter4.state;
  //   await tester.pump();
  //   expect(counter3IsDisposed, true);
  //   await tester.pump();
  //   expect(counter1IsDisposed, false);
  //   expect(counter2IsDisposed, true);
  //   expect(counter4IsDisposed, false);
  // });

  // testWidgets('async computed assertion', (tester) async {
  //   //Define compute computeAsync
  //   expect(() => RM.injectComputed<int>(), throwsAssertionError);
  //   //You can not define both `compute` and `computeAsync
  //   expect(
  //     () => RM.injectComputed(compute: (_) => null, computeAsync: (_) => null),
  //     throwsAssertionError,
  //   );
  //   //When using `computeAsync` you have to define `asyncDependsOn``
  //   expect(
  //     () => RM.injectComputed(computeAsync: (_) => null),
  //     throwsAssertionError,
  //   );

  //   //Will not throw
  //   expect(RM.injectComputed(compute: (_) => null), isNotNull);
  //   expect(
  //     RM.injectComputed(computeAsync: (_) => null, asyncDependsOn: [null]),
  //     isNotNull,
  //   );
  // });
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
      isLazy: false,
      // debugPrintWhenNotifiedPreMessage: 'counter3',
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
    await tester.pumpWidget(counter3.rebuilder(() => Container()));
  });

  testWidgets('compute async works', (WidgetTester tester) async {
    vanillaModel.injectMock(() => VanillaModel(10));

    await tester.pumpWidget(
      asyncComputed.rebuilder(
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
  // group('description', () {
  testWidgets(
      'Injector : should register Stream and Rebuild StateBuilder each time stream sends data with watch',
      (WidgetTester tester) async {
    streamVanillaModel.injectStreamMock(
      () => Stream.periodic(
        Duration(seconds: 1),
        (num) => VanillaModel((num + 1) * 2),
      ).take(6),
    );
    await tester.pumpWidget(
      streamVanillaModel.rebuilder(
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
      futureModel.rebuilder(
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
      asyncComputed.rebuilder(
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
  // });

  testWidgets(
      'injected model preserve state when when created inside a build method',
      (WidgetTester tester) async {
    final counter1 = RM.inject(() => 0);
    late Injected<int> counter2;
    await tester.pumpWidget(
      counter1.rebuilder(() {
        counter2 = RM.inject(
          () => 0,
          // debugPrintWhenNotifiedPreMessage: 'counter2',
        );
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              Text('counter1: ${counter1.state}'),
              counter2.rebuilder(
                () => Text('counter2: ${counter2.state}'),
              ),
              counter2.whenRebuilderOr(
                shouldRebuild: () => true,
                builder: () => Column(
                  children: [
                    Text('whenRebuilderOr counter2: ${counter2.state}'),
                    counter2.whenRebuilder(
                      onIdle: () => Text('idle'),
                      onWaiting: () => Text('Waiting'),
                      onData: () =>
                          Text('whenRebuilder counter2: ${counter2.state}'),
                      onError: (_) => Text('Error'),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }, dispose: () {}),
    );

    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);

    //increment counter1
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 2'), findsOneWidget);

    //increment counter1
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 2'), findsOneWidget);
    expect(find.text('counter2: 2'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 2'), findsOneWidget);
    expect(find.text('counter2: 3'), findsOneWidget);
    expect(find.text('whenRebuilderOr counter2: 3'), findsOneWidget);
    expect(find.text('whenRebuilder counter2: 3'), findsOneWidget);
  });

  testWidgets('injected model preserve state (with whenRebuilderOr)',
      (WidgetTester tester) async {
    final counter1 = RM.inject(() => 0);
    late Injected<int> counter2;
    await tester.pumpWidget(
      counter1.rebuilder(
        () {
          counter2 = RM.inject(
            () => 0,
            // debugPrintWhenNotifiedPreMessage: 'counter2',
          );
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                Text('counter1: ${counter1.state}'),
                counter2.whenRebuilderOr(
                  builder: () => Column(
                    children: [
                      Text('whenRebuilderOr counter2: ${counter2.state}'),
                      counter2.whenRebuilder(
                        onIdle: () => Text('idle'),
                        onWaiting: () => Text('Waiting'),
                        onData: () =>
                            Text('whenRebuilder counter2: ${counter2.state}'),
                        onError: (_) => Text('Error'),
                      )
                    ],
                  ),
                ),
                counter2.rebuilder(
                  () => Text('counter2: ${counter2.state}'),
                ),
              ],
            ),
          );
        },
      ),
    );

    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);

    //increment counter1
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 2'), findsOneWidget);

    //increment counter1
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 2'), findsOneWidget);
    expect(find.text('counter2: 2'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 2'), findsOneWidget);
    expect(find.text('counter2: 3'), findsOneWidget);
    expect(find.text('whenRebuilderOr counter2: 3'), findsOneWidget);
    expect(find.text('whenRebuilder counter2: 3'), findsOneWidget);
  });

  testWidgets('injected model preserve state (with whenRebuilder)',
      (WidgetTester tester) async {
    final counter1 = RM.inject(() => 0);
    late Injected<int> counter2;
    await tester.pumpWidget(
      counter1.rebuilder(
        () {
          counter2 = RM.inject(
            () => 0,
            // debugPrintWhenNotifiedPreMessage: 'counter2',
          );
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                Text('counter1: ${counter1.state}'),
                counter2.whenRebuilder(
                  onIdle: () => Text('idle'),
                  onWaiting: () => Text('Waiting'),
                  onError: (_) => Text('Error'),
                  onData: () => Column(
                    children: [
                      Text('whenRebuilderOr counter2: ${counter2.state}'),
                      counter2.whenRebuilderOr(
                        builder: () =>
                            Text('whenRebuilder counter2: ${counter2.state}'),
                      )
                    ],
                  ),
                ),
                counter2.rebuilder(
                  () => Text('counter2: ${counter2.state}'),
                ),
              ],
            ),
          );
        },
      ),
    );

    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);

    //increment counter1
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 2'), findsOneWidget);

    //increment counter1
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 2'), findsOneWidget);
    expect(find.text('counter2: 2'), findsOneWidget);

    //increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 2'), findsOneWidget);
    expect(find.text('counter2: 3'), findsOneWidget);
    expect(find.text('whenRebuilderOr counter2: 3'), findsOneWidget);
    expect(find.text('whenRebuilder counter2: 3'), findsOneWidget);
  });

  testWidgets('injected model preserve state with stream',
      (WidgetTester tester) async {
    final counter1 = RM.inject(() => 0);
    late Injected<int> counter2;
    await tester.pumpWidget(
      counter1.rebuilder(
        () {
          counter2 = RM.injectStream(
            () => Stream.periodic(Duration(seconds: 1), (num) {
              return num + 1;
            }).take(3),
          );
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                Text('counter1: ${counter1.state}'),
                counter2.rebuilder(
                  () => Text('counter2: ${counter2.state}'),
                ),
              ],
            ),
          );
        },
      ),
    );

    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 1'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 2'), findsOneWidget);

    // increment counter1
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 2'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 3'), findsOneWidget);
  });

  testWidgets('injected model preserve state computed injected',
      (WidgetTester tester) async {
    final counter0 = RM.inject(() => 0);
    late Injected<int> counter1;
    late Injected<int> counter2;
    await tester.pumpWidget(
      counter0.rebuilder(
        () {
          counter1 = RM.inject(() => 0);
          counter2 = RM.inject<int>(
            () => counter1.state * 10,
            dependsOn: DependsOn({counter1}),
          );

          return Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                counter1.rebuilder(
                  () => Text('counter1: ${counter1.state}'),
                ),
                counter2.rebuilder(
                  () => Text('counter2: ${counter2.state}'),
                ),
              ],
            ),
          );
        },
      ),
    );

    expect(find.text('counter1: 0'), findsOneWidget);
    expect(find.text('counter2: 0'), findsOneWidget);

    // increment counter1
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 10'), findsOneWidget);

    // increment counter2
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 11'), findsOneWidget);

    // increment counter1
    counter0.state++;
    await tester.pump();
    expect(find.text('counter1: 1'), findsOneWidget);
    expect(find.text('counter2: 11'), findsOneWidget);
    //the dependency is not lost
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 2'), findsOneWidget);
    expect(find.text('counter2: 20'), findsOneWidget);
  });

  testWidgets('setState onDate and onError overrides global definition',
      (tester) async {
    String? data;
    String? error;
    final model = RM.inject(
      () => VanillaModel(),
      onData: (_) => data = 'Data from global',
      onError: (_, __) => error = 'Error from global',
    );

    model.setState((s) => s.increment());
    expect(data, 'Data from global');
    model.setState(
      (s) => s.increment(),
      onData: (_) => data = 'Data from setState',
    );
    expect(data, 'Data from setState');

    //
    model.setState((s) => throw Exception('error'));
    expect(error, 'Error from global');

    model.setState(
      (s) => throw Exception('error'),
      onError: (_) => error = 'Error from setState',
    );
    expect(error, 'Error from setState');
  });

  //

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

    final interface = RM.injectFlavor({
      '1': () => Future.delayed(Duration(seconds: 1), () => 1),
      '2': () => Future.delayed(Duration(seconds: 1), () => 2),
    });
    interface
        .injectFutureMock(() => Future.delayed(Duration(seconds: 1), () => 10));
    expect(interface.state, 0);
    await tester.pump(Duration(seconds: 1));
    expect(interface.state, 10);
  });

  testWidgets('rebuilder with many observers', (tester) async {
    final counter1 = RM.inject(() => 0);
    final counter2 = RM.inject(() => 10);

    final widget = [counter1, counter2].rebuilder(
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

  testWidgets('rebuilder with many observers preserve state', (tester) async {
    final counter1 = RM.inject(() => 0);
    late Injected<int> counter2;
    final widget = counter1.rebuilder(
      () {
        counter2 = RM.inject(() => 10);
        return [counter1, counter2].rebuilder(
          () => Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                Text('${counter1.state}'),
                Text('${counter2.state}'),
              ],
            ),
          ),
          initState: () {},
          dispose: () {},
          shouldRebuild: () => true,
          watch: () => [counter1.state, counter2.state],
        );
      },
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

  testWidgets('whenRebuilder with many observers preserve state',
      (tester) async {
    final counter1 = RM.inject(
      () => VanillaModel(0),
      // debugPrintWhenNotifiedPreMessage: 'counter1',
    );
    late Injected<VanillaModel> counter2;
    final widget = counter1.rebuilder(
      () {
        counter2 = RM.inject(() => VanillaModel(10));
        return Directionality(
          textDirection: TextDirection.ltr,
          child: [counter1, counter2].whenRebuilder(
            onIdle: () => Text('Idle'),
            onWaiting: () => Text('onWaiting'),
            onData: () => Column(
              children: [
                Text('${counter1.state.counter}'),
                Text('${counter2.state.counter}'),
              ],
            ),
            onError: (e) => Text('${e.message}'),
            initState: () {},
            dispose: () {},
            shouldRebuild: () => true,
          ),
        );
      },
    );

    await tester.pumpWidget(widget);
    expect(find.text('Idle'), findsOneWidget);
    //
    counter1.setState((s) => s.incrementAsync());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Idle'), findsOneWidget);

    //
    counter2.setState((s) => s.incrementAsync());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);

    //
    counter2.setState((s) => s.incrementError());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets('whenRebuilderOr with many observers preserve state',
      (tester) async {
    final counter1 = RM.inject(
      () => VanillaModel(0),
      // debugPrintWhenNotifiedPreMessage: 'counter1',
    );
    late Injected<VanillaModel> counter2;
    final widget = counter1.rebuilder(
      () {
        counter2 = RM.inject(() => VanillaModel(10));
        return Directionality(
          textDirection: TextDirection.ltr,
          child: [counter1, counter2].whenRebuilderOr(
            onWaiting: () => Text('onWaiting'),
            builder: () => Column(
              children: [
                Text('${counter1.state.counter}'),
                Text('${counter2.state.counter}'),
              ],
            ),
            onIdle: () => Text('Idle'),
            onError: (e) => Text('${e.message}'),
            initState: () {},
            dispose: () {},
            shouldRebuild: () => true,
          ),
        );
      },
    );

    await tester.pumpWidget(widget);
    expect(find.text('Idle'), findsOneWidget);
    //
    counter1.setState((s) => s.incrementAsync());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Idle'), findsOneWidget);

    //
    counter2.setState((s) => s.incrementAsync());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);

    //
    counter2.setState((s) => s.incrementError());
    await tester.pump();
    expect(find.text('onWaiting'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets(
    'Dispose non registered models',
    (tester) async {
      final switcher = ReactiveModel.create(true);
      final counter1 = RM.inject(
        () => 0,
        onDisposed: (_) {
          // print('disposed');
        },
        // debugPrintWhenNotifiedPreMessage: 'counter1',
      );
      final counter2 = RM.inject(() => 0);

      final widget = Directionality(
          textDirection: TextDirection.ltr,
          child: StateBuilder(
            observe: () => switcher,
            builder: (_, __) {
              return switcher.state
                  ? counter1.rebuilder(() => Container())
                  : Container();
            },
          ));
      await tester.pumpWidget(widget);
      counter1.state++;
      counter2.state++;
      // counter2.getRM.resetToHasData(1);

      expect(counter1.state, 1);
      expect(counter2.state, 1);
      switcher.state = !switcher.state;
      await tester.pump();
      expect(counter1.state, 0);
      // expect(counter2.state, 0);
    },
  );

  testWidgets(
    'Injected onSetState work',
    (tester) async {
      int counter1OnSetState = 0;
      String counter2OnSetState = '';
      final counter1 = RM.inject(
        () => 0,
        onSetState: On(
          () => counter1OnSetState++,
        ),
      );

      final counter2 = RM.inject(
        () => 0,
        onSetState: On.all(
          onIdle: () => counter2OnSetState += 'Idle ',
          onWaiting: () => counter2OnSetState += 'Waiting ',
          onError: (_) => counter2OnSetState += 'Error ',
          onData: () => counter2OnSetState += 'Data ',
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
      final counter = RM.inject(
        () => 0,
        onSetState: On(
          () => injectOnSetState++,
        ),
      );

      counter.setState(
        (s) => s + 1,
        onSetState: On.data(() => setStateOnSetState++),
      );
      await tester.pump();
      expect(injectOnSetState, 0);
      expect(setStateOnSetState, 1);

      counter.setState(
        (s) => s + 1,
        onSetState: On.or(or: () => setStateOnSetState++),
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
        onSetState: On(
          () => injectOnSetState++,
        ),
      );

      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => 1),
        onSetState: On.data(() {
          setStateOnSetState++;
        }),
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
        onSetState: On.data(() {
          setStateOnSetState++;
        }),
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
        onSetState: On(() {
          setStateOnSetState++;
        }),
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
        onSetState: On(
          () => injectOnSetState++,
        ),
      );

      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => 1),
        onSetState: On.error((err) {
          setStateOnSetState++;
        }),
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
        onSetState: On.error((err) {
          setStateOnSetState++;
        }),
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
        onSetState: On(() {
          setStateOnSetState++;
        }),
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
        onSetState: On(
          () => injectOnSetState++,
        ),
      );

      counter.setState(
        (s) => Future.delayed(Duration(seconds: 1), () => 1),
        onSetState: On.waiting(() {
          setStateOnSetState++;
        }),
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
        onSetState: On.waiting(() {
          setStateOnSetState++;
        }),
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
        onSetState: On(() {
          setStateOnSetState++;
        }),
      );
      await tester.pump();
      expect(injectOnSetState, 2);
      expect(setStateOnSetState, 3);
      await tester.pump(Duration(seconds: 1));
      expect(injectOnSetState, 2);
      expect(setStateOnSetState, 4);
    },
  );
}

class VanillaModel {
  VanillaModel([this.counter = 0]);
  int counter = 0;
  int numberOfDisposeCall = 0;
  void increment() {
    counter++;
  }

  Future<int> incrementAsync() async {
    await getFuture();
    counter++;
    return counter;
  }

  Future<VanillaModel> incrementAsyncImmutable() async {
    await getFuture();
    return VanillaModel(counter + 1);
  }

  Future<int> incrementError() async {
    await getFuture();
    throw Exception('Error message');
  }

  Stream<int> incrementStream() async* {
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
  }

  Stream<int> incrementStreamWithError() async* {
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
    await Future.delayed(Duration(seconds: 1));
    yield --counter;
    throw Exception('Error message');
  }

  dispose() {
    numberOfDisposeCall++;
  }

  @override
  String toString() {
    return 'VanillaModel($counter)';
  }
}

Future<int> getFuture() => Future.delayed(Duration(seconds: 1), () => 1);
Stream<int> getStream() {
  return Stream.periodic(Duration(seconds: 1), (num) {
    return num;
  }).take(3);
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
