import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/src/state_builder.dart';

final vanillaModel = RM.inject(() => VanillaModel());
final streamVanillaModel = RM.injectStream(
  () => Stream.periodic(Duration(seconds: 1),
      (num) => num < 3 ? VanillaModel(num) : VanillaModel(3)).take(6),
  watch: (model) => model?.counter,
  initialValue: VanillaModel(0),
  isLazy: false,
  onData: (s) => print('streamVanillaModel :: $s'),
);

final futureModel = RM.injectFuture(
  () => Future.delayed(Duration(seconds: 1), () => 10),
  initialValue: 0,
);

final interface = RM.injectInterface({
  Env.prod: () => ModelProd(),
  Env.test: () => ModelTest(),
});

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
      expect(vanillaModel.rm.isWaiting, isTrue);
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      expect(vanillaModel.rm.hasError, isTrue);
    },
  );

  testWidgets(
    '  will  stream dispose if the injected stream is disposed',
    (tester) async {
      final switcherRM = RM.inject(() => true);
      ReactiveModel<VanillaModel> intRM = streamVanillaModel.rm;

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

      expect(intRM.subscription.isPaused, isFalse);
      switcherRM.state = false;

      await tester.pump();

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsNothing);
      expect(intRM.subscription, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsNothing);
    },
  );

  testWidgets(
    'models are injected lazily and disposed automatically',
    (tester) async {
      expect(InjectorState.allRegisteredModelInApp.length, 0);
      final switcherRM = RM.create(true);
      final widget = StateBuilder(
        observe: () => switcherRM,
        builder: (_, __) => switcherRM.state
            ? vanillaModel.rebuilder(() => Container())
            : Container(),
      );
      await tester.pumpWidget(widget);
      expect(InjectorState.allRegisteredModelInApp.length, 1);
      switcherRM.state = false;
      await tester.pumpWidget(widget);
      expect(InjectorState.allRegisteredModelInApp.length, 0);
      //
      streamVanillaModel.rm;
      switcherRM.state = true;
      await tester.pumpWidget(widget);
      expect(InjectorState.allRegisteredModelInApp.length, 2);
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
      final future2 = RM.injectFuture<int>(() async {
        final future1Value = await future1.stateAsync;
        await Future.delayed(Duration(seconds: 1));
        return future1Value * 2;
      });

      expect(future1.rm.isWaiting, isTrue);
      expect(future2.rm.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(future1.rm.hasData, isTrue);
      expect(future2.rm.isWaiting, isTrue);
      future2.setState(
        (future) => Future.delayed(Duration(seconds: 1), () => 2 * future),
        silent: true,
        shouldAwait: true,
      );
      await tester.pump(Duration(seconds: 1));
      expect(future1.state, 2);
      expect(future2.rm.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(future1.state, 2);
      expect(future2.state, 8);
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
