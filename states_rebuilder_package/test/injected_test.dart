import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/src/builders.dart';
import 'package:states_rebuilder/src/injected.dart';

final vanillaModel = RM.inject(() => VanillaModel());
final streamVanillaModel = RM.injectStream(
  () => Stream.periodic(Duration(seconds: 1),
      (num) => num < 3 ? VanillaModel(num) : VanillaModel(3)).take(6),
  watch: (model) => model?.counter,
  initialValue: VanillaModel(0),
  isLazy: false,
  // onData: (s) => print('streamVanillaModel :: $s'),
);

final futureModel = RM.injectFuture(
  () => Future.delayed(Duration(seconds: 1), () => 10),
  initialValue: 0,
);

final interface = RM.injectFlavor({
  Env.prod: () => ModelProd(),
  Env.test: () => ModelTest(),
});

final asyncComputed = RM.injectComputed<VanillaModel>(
  asyncDependsOn: [vanillaModel],
  computeAsync: (_) async* {
    yield await Future.delayed(
      Duration(seconds: 1),
      () => vanillaModel.state,
    );
  },
  initialState: VanillaModel(0),
);

void main() {
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
    '  will  stream dispose if the injected stream is disposed',
    (tester) async {
      final switcherRM = RM.inject(() => true);

      final widget = switcherRM.rebuilder(() {
        if (switcherRM.state) {
          return streamVanillaModel.rebuilder(() => Directionality(
                textDirection: TextDirection.ltr,
                child: Text(streamVanillaModel.state.counter.toString()),
              ));
        } else {
          return Container();
        }
      });

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);

      expect(streamVanillaModel.subscription.isPaused, isFalse);
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
    'models are injected lazily and disposed automatically',
    (tester) async {
      expect(functionalInjectedModels.length, 0);
      final switcherRM = RM.create(true);
      bool disposeIsCalled = false;
      final widget = StateBuilder(
        observe: () => switcherRM,
        dispose: (_, __) => RM.disposeAll(),
        builder: (_, __) => switcherRM.state
            ? vanillaModel.rebuilder(
                () => Container(),
                dispose: () => disposeIsCalled = true,
              )
            : Container(),
      );
      await tester.pumpWidget(widget);
      expect(functionalInjectedModels.length, 1);
      switcherRM.state = false;
      await tester.pumpWidget(widget);
      expect(functionalInjectedModels.length, 0);
      //
      streamVanillaModel.getRM;
      switcherRM.state = true;
      await tester.pumpWidget(widget);
      expect(functionalInjectedModels.length, 2);
      expect(disposeIsCalled, isTrue);
    },
  );

  testWidgets(
      'Injector : should register Stream and Rebuild StateBuilder each time stream sends data with watch',
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
      String errorMessage;
      vanillaModel.setState(
        (state) => state.incrementError(),
        onError: (context, error) {
          errorMessage = error.message;
        },
      );
      await tester.pump();
      await tester.pump(Duration(seconds: 2));
      expect(errorMessage, 'Error message');
    },
  );
  testWidgets('Injector.interface should work Env.prod', (tester) async {
    Injector.env = Env.prod;

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
    Injector.env = Env.test;
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

  testWidgets('Injected.streamBuilder without error', (tester) async {
    final widget = vanillaModel.streamBuilder(
      stream: (s, subscription) => s.incrementStream(),
      onError: null,
      onWaiting: () => Text('waiting ...'),
      onData: (state) {
        return Text('${state}');
      },
      onDone: (state) {
        return Text('done ${state}');
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
    final widget = vanillaModel.streamBuilder(
      stream: (s, subscription) => s.incrementStreamWithError(),
      onWaiting: null,
      onError: (e) => Text('${e.message}'),
      onData: (state) {
        return Text('${state}');
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));

    expect(find.text('null'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    expect(find.text('Error message'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets('Injected.futureBuilder without error', (tester) async {
    final widget = vanillaModel.futureBuilder(
      future: (s, _) => s.incrementAsync().then(
            (_) => Future.delayed(
              Duration(seconds: 1),
              () => VanillaModel(5),
            ),
          ),
      onWaiting: () => Text('waiting ...'),
      onError: null,
      onData: (rm) {
        return Text('data');
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('data'), findsOneWidget);
  });

  testWidgets('Injected.futureBuilder with error', (tester) async {
    RM.debugErrorWithStackTrace = true;
    final widget = vanillaModel.futureBuilder(
      future: (s, _) => s.incrementError().then(
            (_) => Future.delayed(
              Duration(seconds: 1),
              () => VanillaModel(5),
            ),
          ),
      onWaiting: () => Text('waiting ...'),
      onError: (e) => Text('${e.message}'),
      onData: (rm) {
        return Text('data');
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('waiting ...'), findsOneWidget);
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
      initialValue: 0,
    );

    final computed = RM.injectComputed(
      compute: (s) => vanillaModel.state.counter * model2.state,
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

  testWidgets('autoDispose dependent injected model', (tester) async {
    bool counter1IsDisposed = false;
    bool counter2IsDisposed = false;
    bool counter3IsDisposed = false;
    final counter1 = RM.inject(
      () => 0,
      onDisposed: (_) => counter1IsDisposed = true,
    );
    final counter2 = RM.inject(
      () => 0,
      onDisposed: (_) => counter2IsDisposed = true,
    );
    final counter3 = RM.inject<int>(
      () {
        return counter1.state + counter2.state;
      },
      onDisposed: (_) => counter3IsDisposed = true,
    );
    final switcher = RM.create(true);
    await tester.pumpWidget(StateBuilder(
      observe: () => switcher,
      builder: (_, __) {
        if (switcher.state) {
          return counter3.rebuilder(() => Container());
        }
        return Container();
      },
    ));
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
      onDisposed: (_) => counter1IsDisposed = true,
    );
    final counter2 = RM.inject(
      () => 0,
      onDisposed: (_) => counter2IsDisposed = true,
    );
    final counter3 = RM.inject<int>(
      () {
        return counter1.state + counter2.state;
      },
      onDisposed: (_) => counter3IsDisposed = true,
    );
    final counter4 = RM.inject(
      () => counter1.state,
      onDisposed: (_) => counter4IsDisposed = true,
    );
    final switcher = RM.create(true);
    await tester.pumpWidget(StateBuilder(
      observe: () => switcher,
      builder: (_, __) {
        if (switcher.state) {
          return counter3.rebuilder(() => Container());
        }
        return Container();
      },
    ));
    switcher.state = false;
    counter4.state;
    await tester.pump();
    expect(counter3IsDisposed, true);
    await tester.pump();
    expect(counter1IsDisposed, false);
    expect(counter2IsDisposed, true);
    expect(counter4IsDisposed, false);
  });

  testWidgets('async computed assertion', (tester) async {
    //Define compute computeAsync
    expect(() => RM.injectComputed<int>(), throwsAssertionError);
    //You can not define both `compute` and `computeAsync
    expect(
      () => RM.injectComputed(compute: (_) => null, computeAsync: (_) => null),
      throwsAssertionError,
    );
    //When using `computeAsync` you have to define `asyncDependsOn``
    expect(
      () => RM.injectComputed(computeAsync: (_) => null),
      throwsAssertionError,
    );
    //asyncDependsOn can not be null
    expect(
      () => RM.injectComputed(computeAsync: (_) => null, asyncDependsOn: []),
      throwsAssertionError,
    );
    //Will not throw
    expect(RM.injectComputed(compute: (_) => null), isNotNull);
    expect(
      RM.injectComputed(computeAsync: (_) => null, asyncDependsOn: [null]),
      isNotNull,
    );
  });
  testWidgets('async computed ', (tester) async {
    final counter1 = RM.inject(() => 1);
    final counter2 = RM.inject(() => 1);

    final counter3 = RM.injectComputed(
      computeAsync: (_) async* {
        await Future.delayed(Duration(seconds: 1));
        yield counter1.state + counter2.state;
      },
      asyncDependsOn: [counter1, counter2],
      initialState: 0,
      isLazy: false,
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
  group('description', () {
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

      asyncComputed.injectComputedMock(
        computeAsync: (_) async* {
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
  });
}

class VanillaModel {
  VanillaModel([this.counter = 0]);
  int counter = 0;
  int numberOfDisposeCall = 0;
  void increment() {
    counter++;
  }

  Future<void> incrementAsync() async {
    await getFuture();
    counter++;
  }

  Future<void> incrementError() async {
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
