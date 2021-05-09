import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'fake_classes/models.dart';

void main() {
  ReactiveModel<VanillaModel>? modelRM;

  setUp(() {
    // final inject = Inject(() => VanillaModel());
    // modelRM = inject.getReactive()..listenToRM((rm) {});
    modelRM = ReactiveModel(
        creator: () => VanillaModel(), initialState: VanillaModel());
  });

  tearDown(() {
    modelRM = null;
  });

  test('ReactiveModel: get the state with the right status', () {
    expect(modelRM?.state, isA<VanillaModel>());
    expect(modelRM?.snapState.data, isA<VanillaModel>());
    expect(modelRM?.connectionState, equals(ConnectionState.none));
    expect(modelRM?.hasData, isFalse);

    modelRM?.setState((_) {});
    expect(modelRM?.connectionState, equals(ConnectionState.done));
    expect(modelRM?.hasData, isTrue);
  });

  test('ReactiveModel: get the error', () {
    modelRM?.setState(
      (s) => s.incrementError(),
    );

    expect(modelRM!.error.message, equals('Error message'));
    expect(
        (modelRM!.snapState.error as dynamic).message, equals('Error message'));
    expect(modelRM!.hasError, isTrue);
  });
  testWidgets(
    'ReactiveModel: call async method without error and notify observers',
    (tester) async {
      //isIdle
      expect(modelRM!.state.counter, 0);
      expect(modelRM!.isIdle, true);
      expect(modelRM!.stateAsync, isA<Future<VanillaModel?>>());
      expect((await modelRM!.stateAsync).counter, 0);

      modelRM!.setState((s) async {
        await s.incrementAsync();
      });
      //isWaiting
      expect(modelRM!.state.counter, 0);
      expect(modelRM!.isWaiting, true);
      expect(modelRM!.stateAsync, isA<Future<VanillaModel?>>());

      await tester.pump(Duration(seconds: 1));
      //hasData
      expect(modelRM!.state.counter, 1);
      expect(modelRM!.hasData, true);
      expect(modelRM!.stateAsync, isA<Future<VanillaModel?>>());
      expect((await modelRM!.stateAsync).counter, 1);
    },
  );

  testWidgets(
    'ReactiveModel: call async method with error and notify observers',
    (tester) async {
      //isIdle
      expect(modelRM!.state.counter, 0);
      expect(modelRM!.isIdle, true);

      modelRM!.setState(
        (s) async {
          await s.incrementAsyncWithError();
        },
      );

      //isWaiting
      expect(modelRM!.state.counter, 0);
      expect(modelRM!.isWaiting, true);
      // expect(modelRM!.stateAsync, isA<Future<VanillaModel?>>());

      await tester.pump(Duration(seconds: 1));
      //hasError
      expect(modelRM!.state.counter, 0);
      expect(modelRM!.hasError, true);
      expect(modelRM!.error.message, 'Error message');
      // expect(modelRM!.stateAsync, isA<Future<VanillaModel?>>());
      // expect((await modelRM!.stateAsync).counter, 0);

      // modelRM!.stateAsync.catchError((e) {
      //   expect(e.message, 'Error message');
      // });
    },
  );

  testWidgets(
    'ReactiveModel: whenConnectionState should work',
    (tester) async {
      dynamic message;
      modelRM?.subscribeToRM((_) {
        message = modelRM?.whenConnectionState(
          onIdle: () => 'onIdle',
          onWaiting: () => 'onWaiting',
          onData: (data) => '${data.counter}',
          onError: (error) => '${error?.message}',
        );
      });

      //isIdle
      expect(modelRM?.isIdle, true);

      modelRM?.setState((s) => s.incrementAsync());
      //isWaiting
      expect(message, 'onWaiting');

      await tester.pump(Duration(seconds: 1));
      //hasData
      expect(message, '1');

      //throw error
      modelRM?.setState(
        (s) => s.incrementAsyncWithError(),
      );
      //isWaiting
      expect(message, 'onWaiting');

      await tester.pump(Duration(seconds: 1));
      //hasError
      expect(message, 'Error message');

      //throw error
      modelRM?.setState((s) => s.incrementAsyncWithError());
      await tester.pump();
      //isWaiting
      expect(message, 'onWaiting');

      await tester.pump(Duration(seconds: 1));
      //hasError
      expect(message, 'Error message');
    },
  );
  // test('ReactiveModel: Check default null state', () {
  //   var intRM = ReactiveModel<int>(creator: () => 1);
  //   expect(intRM.initialState, 0);
  //   intRM = ReactiveModel<int>(creator: () => 1, initialState: 10);
  //   expect(intRM.initialState, 10);
  //   //
  //   var doubleRM = ReactiveModel<double>(creator: () => 1.0);
  //   expect(doubleRM.initialState, 0.0);
  //   doubleRM = ReactiveModel<double>(creator: () => 1.0, initialState: 10.0);
  //   expect(doubleRM.initialState, 10.0);
  //   //
  //   var boolRM = ReactiveModel<bool>(creator: () => true);
  //   expect(boolRM.initialState, false);
  //   boolRM = ReactiveModel<bool>(creator: () => true, initialState: true);
  //   expect(boolRM.initialState, true);
  //   //
  //   var stringRM = ReactiveModel<String>(creator: () => 'string');
  //   expect(stringRM.initialState, '');
  //   stringRM = ReactiveModel<String>(
  //       creator: () => 'string', initialState: 'initString');
  //   expect(stringRM.initialState, 'initString');
  //   //
  //   var listRM = ReactiveModel<List>(creator: () => [1.2]);
  //   listRM.state;
  //   expect(listRM.initialState, [1.2]);
  // });

  testWidgets(
    'ReactiveModel: catch sync error and notify observers',
    (tester) async {
      final widget = StateBuilder(
        observeMany: [() => modelRM!],
        shouldRebuild: (_) => true,
        builder: (_, __) {
          return _widgetBuilder(
            '${modelRM!.state.counter}',
            '${modelRM!.error?.message}',
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(find.text(('Error message')), findsNothing);
      //
      modelRM!.setState(
        (s) {
          s.incrementError();
        },
      );
      await tester.pump();
      expect(find.text(('Error message')), findsOneWidget);
    },
  );

  testWidgets(
    'ReactiveModel: call async method without error and notify observers1',
    (tester) async {
      final widget = StateBuilder(
        observeMany: [() => modelRM!],
        shouldRebuild: (_) => true,
        builder: (_, __) {
          return _widgetBuilder(
            '${modelRM!.state.counter}',
            'isWaiting=${modelRM!.isWaiting}',
            'isIdle=${modelRM!.isIdle}',
          );
        },
      );
      await tester.pumpWidget(widget);
      //isIdle
      expect(find.text('0'), findsOneWidget);
      expect(find.text('isWaiting=false'), findsOneWidget);
      expect(find.text('isIdle=true'), findsOneWidget);
      expect(modelRM!.stateAsync, isA<Future<VanillaModel>>());
      modelRM!.setState((s) async {
        await s.incrementAsync();
      });
      await tester.pump();
      //isWaiting
      expect(find.text('0'), findsOneWidget);
      expect(find.text('isWaiting=true'), findsOneWidget);
      expect(find.text('isIdle=false'), findsOneWidget);
      expect(modelRM!.stateAsync, isA<Future<VanillaModel>>());

      await tester.pump(Duration(seconds: 1));
      //hasData
      expect(find.text('1'), findsOneWidget);
      expect(find.text('isWaiting=false'), findsOneWidget);
      expect(find.text('isIdle=false'), findsOneWidget);
      expect((await modelRM!.stateAsync).counter, 1);
    },
  );

  testWidgets(
    'ReactiveModel: call async method with error and notify observers1',
    (tester) async {
      final widget = StateBuilder(
        observeMany: [() => modelRM!],
        shouldRebuild: (_) => true,
        builder: (_, __) {
          return _widgetBuilder(
            '${modelRM!.hasError ? modelRM!.error.message : modelRM!.state.counter}',
            'isWaiting=${modelRM!.isWaiting}',
            'isIdle=${modelRM!.isIdle}',
          );
        },
      );
      await tester.pumpWidget(widget);
      //isIdle
      expect(find.text('0'), findsOneWidget);
      expect(find.text('isWaiting=false'), findsOneWidget);
      expect(find.text('isIdle=true'), findsOneWidget);

      modelRM!.setState(
        (s) => s.incrementAsyncWithError(),
      );
      await tester.pump();
      //isWaiting
      expect(find.text('0'), findsOneWidget);
      expect(find.text('isWaiting=true'), findsOneWidget);
      expect(find.text('isIdle=false'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      //hasData
      expect(find.text('Error message'), findsOneWidget);
      expect(find.text('isWaiting=false'), findsOneWidget);
      expect(find.text('isIdle=false'), findsOneWidget);
      // modelRM!.stateAsync.catchError((e) {//TODO
      //   expect(e.message, 'Error message');
      // });
    },
  );

  testWidgets(
    'ReactiveModel: whenConnectionState should work',
    (tester) async {
      final widget = StateBuilder(
        observeMany: [() => modelRM!],
        shouldRebuild: (_) => true,
        key: Key('whenConnectionState'),
        builder: (_, __) {
          return modelRM!.whenConnectionState(
            onIdle: () => _widgetBuilder('onIdle'),
            onWaiting: () => _widgetBuilder('onWaiting'),
            onData: (data) => _widgetBuilder('${data.counter}'),
            onError: (error) => _widgetBuilder('${error.message}'),
          );
        },
      );
      await tester.pumpWidget(widget);
      //isIdle
      expect(find.text('onIdle'), findsOneWidget);

      modelRM!.setState((s) => s.incrementAsync());
      await tester.pump();
      //isWaiting
      expect(find.text('onWaiting'), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      //hasData
      expect(find.text('1'), findsOneWidget);

      //throw error
      modelRM!.setState((s) => s.incrementAsyncWithError());
      await tester.pump();
      //isWaiting
      expect(find.text('onWaiting'), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      //hasError
      expect(find.text('Error message'), findsOneWidget);

      //throw error
      modelRM!.setState((s) => s.incrementAsyncWithError());
      await tester.pump();
      //isWaiting
      expect(find.text('onWaiting'), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      //hasError
      expect(find.text('Error message'), findsOneWidget);
    },
  );
// /**************************************** */

  testWidgets(
    'ReactiveModel: with whenConnectionState error should be catch',
    (tester) async {
      final widget = StateBuilder(
        observeMany: [() => modelRM!],
        shouldRebuild: (_) => true,
        builder: (_, __) {
          return modelRM!.whenConnectionState(
            onIdle: () => _widgetBuilder('onIdle'),
            onWaiting: () => _widgetBuilder('onWaiting'),
            onData: (data) => _widgetBuilder('${data.counter}'),
            onError: (error) => _widgetBuilder('${error.message}'),
          );
        },
      );
      await tester.pumpWidget(widget);
      //isIdle
      expect(find.text('onIdle'), findsOneWidget);

      modelRM!.setState((s) => s.incrementError());
      await tester.pump();
      //hasError
      expect(find.text('Error message'), findsOneWidget);
      //
      modelRM!.setState((s) => s.incrementError());
      await tester.pump();
      //hasError
      expect(find.text('Error message'), findsOneWidget);
    },
  );

  testWidgets(
    'ReactiveModel: onSetState and onRebuildState work',
    (tester) async {
      final modelRM = 0.inj();

      int numberOfOnSetStateCall = 0;
      int numberOfOnRebuildStateCall = 0;
      final widget = On(() {
        return Container();
      }).listenTo(modelRM);

      await tester.pumpWidget(widget);

      //
      modelRM.setState(
        (s) => s + 1,
        onSetState: On(() {
          numberOfOnSetStateCall++;
        }),
        onRebuildState: () {
          numberOfOnRebuildStateCall++;
        },
      );
      await tester.pump();
      expect(numberOfOnSetStateCall, equals(1));
      await tester.pump();

      expect(numberOfOnRebuildStateCall, equals(1));
    },
  );

  testWidgets(
    'ReactiveModel: onData work for sync call',
    (tester) async {
      int numberOfOnDataCall = 0;
      //
      modelRM?.setState(
        (s) => s.increment(),
        onData: (data) {
          numberOfOnDataCall++;
        },
      );
      expect(numberOfOnDataCall, equals(1));
    },
  );

  testWidgets(
    'ReactiveModel: onData work for async call',
    (tester) async {
      int numberOfOnDataCall = 0;

      //
      modelRM?.setState(
        (s) => s.incrementAsync(),
        onData: (data) {
          numberOfOnDataCall++;
        },
      );
      await tester.pump();
      expect(numberOfOnDataCall, equals(0));
      await tester.pump(Duration(seconds: 1));
      expect(numberOfOnDataCall, equals(1));
    },
  );

  testWidgets(
    'ReactiveModel: onError work for sync call',
    (tester) async {
      int numberOfOnErrorCall = 0;

      //
      modelRM?.setState(
        (s) => s.incrementError(),
        onError: (data) {
          numberOfOnErrorCall++;
        },
      );
      await tester.pump();
      expect(numberOfOnErrorCall, equals(1));
    },
  );

  testWidgets(
    'ReactiveModel: onError work for async call',
    (tester) async {
      int numberOfOnErrorCall = 0;
      //
      modelRM?.setState(
        (s) => s.incrementAsyncWithError(),
        onError: (data) {
          numberOfOnErrorCall++;
        },
      );
      await tester.pump();
      expect(numberOfOnErrorCall, equals(0));
      //
      await tester.pump(Duration(seconds: 1));
      expect(numberOfOnErrorCall, equals(1));
    },
  );

  testWidgets(
    'On.waiting for listen.child parameter is for waiting and data',
    (tester) async {
      final model = 0.inj();

      int numberOfRebuild = 0;
      final widget = On.waiting(
        () {
          numberOfRebuild++;
          return Container();
        },
      ).listenTo(model);

      await tester.pumpWidget(widget);
      expect(numberOfRebuild, 1);
      //
      // model.setState(
      //   (s) => Future.delayed(Duration(seconds: 1), () => 1),
      // );
      // await tester.pump();
      // expect(numberOfRebuild, 2);
      // await tester.pump(Duration(seconds: 1));
      // expect(numberOfRebuild, 3);
    },
  );

  testWidgets(
    'ReactiveModel : inject futures get primitive initialState',
    (tester) async {
      final modelRM0 = ReactiveModel.future(
        () => Future.delayed(Duration(seconds: 1), () => 1),
        initialState: 0,
      );

      expect(modelRM0.state, 0);
      expect(modelRM0.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 1);
      expect(modelRM0.initialState, 0);
      expect(modelRM0.hasData, isTrue);
    },
  );

  testWidgets(
    'ReactiveModel : inject futures throw argument error if getting a non initialized state while waiting',
    (tester) async {
      final modelRM0 = ReactiveModel.future(
        () => Future.delayed(Duration(seconds: 1), () => VanillaModel()),
      );
      expect(modelRM0.stateAsync, isA<Future<VanillaModel>>());

      expect(() => modelRM0.state, throwsArgumentError);
      expect(modelRM0.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state.counter, 0);
      expect(modelRM0.hasData, isTrue);
      expect((await modelRM0.stateAsync).counter, 0);
    },
  );

  testWidgets(
    'ReactiveModel : inject futures with error works',
    (tester) async {
      final modelRM0 = ReactiveModel.future(
        () => getFutureWithError(),
        initialState: 10,
      );

      expect(modelRM0.state, 10);
      expect(modelRM0.isWaiting, isTrue);

      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 10);
      expect(modelRM0.hasError, isTrue);
    },
  );

  testWidgets(
    'ReactiveModel : inject futures and refresh works',
    (tester) async {
      final modelRM0 = ReactiveModel<int?>.future(
        () => Future.delayed(Duration(seconds: 1), () => 1),
        // initialState: 0,
      );

      expect(modelRM0.state, null);
      expect(modelRM0.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 1);
      expect(modelRM0.initialState, null);
      expect(modelRM0.hasData, isTrue);
      modelRM0.refresh();
      await tester.pump();
      expect(modelRM0.state, 1);
      expect(modelRM0.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 1);
      expect(modelRM0.initialState, null);
    },
  );

  testWidgets(
    'ReactiveModel : future method works',
    (tester) async {
      ReactiveModel<VanillaModel> modelRM =
          ReactiveModel.create(VanillaModel());
      String? errorMessage;
      final widget = Column(
        children: <Widget>[
          StateBuilder<VanillaModel>(
            //used to add observer so to throw FlutterError
            observe: () => modelRM,
            builder: (context, modelRM) {
              return Container();
            },
          ),
          StateBuilder<VanillaModel>(
            observe: () => modelRM..setState((m) => m.incrementAsync()),
            builder: (context, modelRM) {
              return _widgetBuilder('${modelRM?.state.counter}');
            },
          ),
          StateBuilder<VanillaModel>(
            //used to add observer so to throw FlutterError
            observe: () => modelRM,
            builder: (context, modelRM) {
              return Container();
            },
          ),
        ],
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      expect(modelRM.isWaiting, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      expect(modelRM.hasData, isTrue);
      expect(errorMessage, isNull);
    },
  );

  testWidgets(
    'ReactiveModel : future method works, case with error',
    (tester) async {
      ReactiveModel<VanillaModel> modelRM =
          ReactiveModel.create(VanillaModel());
      String? errorMessage;
      final widget = Column(
        children: <Widget>[
          StateBuilder<VanillaModel>(
            observe: () => modelRM,
            builder: (context, modelRM) {
              return Container();
            },
          ),
          StateBuilder<VanillaModel>(
            observe: () => modelRM
              ..setState((m) => m.incrementAsyncWithError())
              ..catchError((error, _) {
                errorMessage = error.message;
              }),
            builder: (context, modelRM) {
              return _widgetBuilder('${modelRM?.state.counter}');
            },
          )
        ],
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      expect(modelRM.isWaiting, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(modelRM.hasError, isTrue);
      expect(errorMessage, 'Error message');
    },
  );

  testWidgets(
    'ReactiveModel : future method works, call future from initState',
    (tester) async {
      ReactiveModel<VanillaModel> modelRM =
          ReactiveModel.create(VanillaModel());
      String? errorMessage;
      final widget = Column(
        children: <Widget>[
          StateBuilder<VanillaModel>(
            observe: () => modelRM,
            builder: (context, modelRM) {
              return Container();
            },
          ),
          StateBuilder<VanillaModel>(
            observe: () => modelRM,
            initState: (_, modelRM) async {
              modelRM!
                ..setState((m) => m.incrementAsyncWithError())
                ..catchError((error, s) {
                  errorMessage = error.message;
                });
            },
            builder: (context, modelRM) {
              return _widgetBuilder('${modelRM!.state.counter}');
            },
          )
        ],
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      expect(modelRM.isWaiting, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(modelRM.hasError, isTrue);
      expect(errorMessage, 'Error message');
    },
  );

  testWidgets(
    'Nested dependent futures ',
    (tester) async {
      final future1 = ReactiveModel.future(
          () => Future.delayed(Duration(seconds: 1), () => 2));
      final future2 = ReactiveModel.future(() async {
        final future1Value = await future1.stateAsync;
        await Future.delayed(Duration(seconds: 1));
        return future1Value * 2;
      });

      expect(future1.isWaiting, isTrue);
      expect(future2.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(future1.hasData, isTrue);
      expect(future2.isWaiting, isTrue);
      future2.setState(
        (future) => Future.delayed(Duration(seconds: 1), () => 2 * future),
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

// //   group('stream', () {
  testWidgets(
    'ReactiveModel : inject stream with data works',
    (tester) async {
      final modelRM0 = ReactiveModel.stream(
        () => getStream(),
        initialState: 0,
      );

      expect(modelRM0.state, 0);
      expect(modelRM0.isWaiting, isTrue);

      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 0);
      expect(modelRM0.hasData, isTrue);

      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 1);
      expect(modelRM0.hasData, isTrue);

      await tester.pump(Duration(seconds: 1));

      expect(modelRM0.state, 2);
      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 2);
    },
  );

  testWidgets(
    'ReactiveModel : inject stream with data and error works',
    (tester) async {
      final modelRM0 = ReactiveModel.stream(
          () => VanillaModel().incrementStreamWithError(),
          initialState: 0);

      expect(modelRM0.state, 0);
      expect(modelRM0.isWaiting, isTrue);

      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 1);
      expect(modelRM0.hasData, isTrue);

      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 2);
      expect(modelRM0.hasData, isTrue);

      await tester.pump(Duration(seconds: 1));

      expect(modelRM0.state, 1);
      expect(modelRM0.hasError, isTrue);

      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 1);

      // expect(modelRM0.isDone, isTrue);
    },
  );
  testWidgets(
    'ReactiveModel : inject stream with watching data works',
    (tester) async {
      final modelRM0 = RM.injectStream(
        () => getStream(),
        watch: (data) {
          return 0;
        },
        initialState: 0,
      );

      int numberOfRebuild = 0;
      final widget = Column(
        children: <Widget>[
          StateBuilder(
            observeMany: [() => modelRM0],
            builder: (context, _) {
              numberOfRebuild++;
              return _widgetBuilder('${modelRM0.state}-$numberOfRebuild');
            },
          )
        ],
      );

      await tester.pumpWidget(widget);

      expect(find.text('0-1'), findsOneWidget);
      expect(modelRM0.isWaiting, isTrue);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('0-2'), findsOneWidget);
      expect(modelRM0.hasData, isTrue);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('0-2'), findsOneWidget);
      expect(modelRM0.hasData, isTrue);
      //
      await tester.pump(Duration(seconds: 1));
      expect(find.text('0-2'), findsOneWidget);
      expect(modelRM0.hasData, isTrue);
    },
  );
  testWidgets(
    'issue #61: reactive stream with error and watch',
    (WidgetTester tester) async {
      int numberOfRebuild = 0;
      Stream<int> snapStream = Stream.periodic(Duration(seconds: 1), (num) {
        if (num == 0) throw Exception('Error message');
        return num + 1;
      }).take(3);

      final rmStream =
          RM.injectStream<int?>(() => snapStream, watch: (rm) => rm);
      final widget = StateBuilder(
        observeMany: [() => rmStream],
        tag: 'MyTag',
        shouldRebuild: (_) => true,
        builder: (_, rmStream) {
          numberOfRebuild++;
          return Container();
        },
      );

      await tester.pumpWidget(MaterialApp(home: widget));
      expect(numberOfRebuild, 1);
      expect(rmStream.state, null);

      await tester.pump(Duration(seconds: 1));
      expect(numberOfRebuild, 2);
      expect(rmStream.state, null);

      await tester.pump(Duration(seconds: 1));
      expect(numberOfRebuild, 3);
      expect(rmStream.state, 2);

      await tester.pump(Duration(seconds: 1));
      expect(numberOfRebuild, 4);
      expect(rmStream.state, 3);

      await tester.pump(Duration(seconds: 1));
      expect(numberOfRebuild, 5);
      expect(rmStream.state, 4);

      await tester.pump(Duration(seconds: 1));
      expect(numberOfRebuild, 5);
      expect(rmStream.state, 4);
    },
  );

  testWidgets(
    'ReactiveModel : stream method works. case stream called from observe parameter',
    (tester) async {
      ReactiveModel<VanillaModel> modelRM =
          ReactiveModel.create(VanillaModel());
      String? errorMessage;
      final widget = Column(
        children: <Widget>[
          StateBuilder<VanillaModel>(
            observe: () => modelRM
              ..setState((m) => m.incrementStreamWithError())
              ..catchError((error, s) {
                errorMessage = error.message;
              }),
            shouldRebuild: (_) => true,
            builder: (context, modelRM) {
              return _widgetBuilder('${modelRM?.state.counter}');
            },
          )
        ],
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      expect(modelRM.isWaiting, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      expect(modelRM.hasData, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);
      expect(modelRM.hasData, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      expect(modelRM.hasError, isTrue);
      expect(errorMessage, 'Error message');
    },
  );

  testWidgets(
    'ReactiveModel : stream method works. case stream called from outside',
    (tester) async {
      ReactiveModel<VanillaModel> modelRM =
          ReactiveModel.create(VanillaModel());
      String? errorMessage;
      final widget = Column(
        children: <Widget>[
          StateBuilder<VanillaModel>(
            observe: () => modelRM,
            shouldRebuild: (_) => true,
            builder: (context, modelRM) {
              return _widgetBuilder('${modelRM?.state.counter}');
            },
          )
        ],
      );

      modelRM
        ..setState((m) => m.incrementStream())
        ..catchError((error, s) {
          errorMessage = error.message;
        });
      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      expect(modelRM.isWaiting, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      expect(modelRM.hasData, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);
      expect(modelRM.hasData, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('3'), findsOneWidget);
      expect(modelRM.hasData, isTrue);
      expect(errorMessage, isNull);
    },
  );

  testWidgets(
    'ReactiveModel : stream method works. ImmutableModel',
    (tester) async {
      ReactiveModel<ImmutableModel> modelRM =
          ReactiveModel.create(ImmutableModel(0));
      String? errorMessage;
      final widget = Column(
        children: <Widget>[
          StateBuilder<ImmutableModel>(
            observe: () => modelRM,
            builder: (context, modelRM) {
              return _widgetBuilder('${modelRM?.state.counter}');
            },
          )
        ],
      );

      modelRM
        ..setState((m) => m.incrementStream())
        ..catchError((error, s) {
          errorMessage = error.message;
        });
      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      expect(modelRM.isWaiting, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      expect(modelRM.hasData, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);
      expect(modelRM.hasData, isTrue);
      expect(errorMessage, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(modelRM.hasError, isTrue);
      expect(errorMessage, 'Error message');
    },
  );

  testWidgets(
    'onSetState and onRebuildState work',
    (tester) async {
      final modelRM = 0.inj();

      int numberOfOnSetStateCall = 0;
      int numberOfOnRebuildStateCall = 0;

      String lifeCycleTracker = '';

      final widget = On(() {
        lifeCycleTracker += 'build, ';
        return Container();
      }).listenTo(modelRM);
      await tester.pumpWidget(widget);
      expect(numberOfOnSetStateCall, equals(0));
      //
      modelRM.setState(
        (_) => modelRM.state + 1,
        onSetState: On(() {
          numberOfOnSetStateCall++;
          lifeCycleTracker += 'onSetState, ';
        }),
        onRebuildState: () {
          numberOfOnRebuildStateCall++;
          lifeCycleTracker += 'onRebuildState, ';
        },
      );
      await tester.pump();
      expect(numberOfOnSetStateCall, equals(1));
      expect(numberOfOnRebuildStateCall, equals(1));
      expect(lifeCycleTracker,
          equals('build, onSetState, build, onRebuildState, '));
    },
  );

  testWidgets(
    'sync methods with and without error work',
    (tester) async {
      final modelRM = ReactiveModel.create(0);

      final widget = StateBuilder(
        observeMany: [() => modelRM],
        shouldRebuild: (_) => true,
        builder: (_, __) {
          return modelRM.whenConnectionState(
            onIdle: () => _widgetBuilder('onIdle'),
            onWaiting: () => _widgetBuilder('onWaiting'),
            onData: (data) => _widgetBuilder('$data'),
            onError: (error) => _widgetBuilder('${error.message}'),
          );
        },
      );
      await tester.pumpWidget(widget);
      //sync increment without error
      modelRM.setState((_) {
        final model = VanillaModel();
        model.increment();
        return model.counter;
      });
      await tester.pump();
      expect(find.text(('1')), findsOneWidget);

      //sync increment with error
      var error;
      await modelRM.setState(
        (_) {
          final model = VanillaModel();
          model.incrementError();
          return model.counter;
        },
        onError: (e) {
          error = e;
        },
      );
      await tester.pump();
      expect(find.text('Error message'), findsOneWidget);
      expect(error.message, equals('Error message'));
    },
  );

  testWidgets(
    'Async methods with and without error work',
    (tester) async {
      final modelRM = ReactiveModel.create(0);
      int? onData;

      final widget = StateBuilder(
        observeMany: [() => modelRM],
        shouldRebuild: (_) => true,
        builder: (_, __) {
          return modelRM.whenConnectionState(
            onIdle: () => _widgetBuilder('onIdle'),
            onWaiting: () => _widgetBuilder('onWaiting'),
            onData: (data) => _widgetBuilder('$data'),
            onError: (error) => _widgetBuilder('${error.message}'),
          );
        },
      );
      await tester.pumpWidget(widget);

      expect(find.text(('onIdle')), findsOneWidget);

      //sync increment without error
      modelRM.setState((_) async {
        final model = VanillaModel();
        await model.incrementAsync();
        return model.counter;
      }, onData: (data) {
        onData = data;
      });
      await tester.pump();
      expect(find.text(('onWaiting')), findsOneWidget);
      expect(onData, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      expect(onData, equals(1));

      //sync increment with error
      modelRM.setState(
        (_) async {
          final model = VanillaModel();
          await model.incrementAsyncWithError();
          return model.counter;
        },
      );
      await tester.pump();
      expect(find.text(('onWaiting')), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error message'), findsOneWidget);
      expect(onData, equals(1));
    },
  );

  // testWidgets(
  //   'ReactiveModel: issue #49 reset to Idle after error or data',
  //   (tester) async {
  //     final widget = StateBuilder(
  //       observeMany: [() => modelRM!],
  //       shouldRebuild: (_) => true,
  //       builder: (_, __) {
  //         return _widgetBuilder(
  //           '${modelRM.state.counter}',
  //           '${modelRM.error?.message}',
  //         );
  //       },
  //     );
  //     await tester.pumpWidget(widget);
  //     expect(find.text(('Error message')), findsNothing);
  //     //
  //     modelRM.setState((s) => s.incrementError(), );
  //     await tester.pump();
  //     expect(find.text(('Error message')), findsOneWidget);
  //     expect(modelRM.isIdle, isFalse);
  //     expect(modelRM.hasError, isTrue);
  //     expect(modelRM.hasData, isFalse);
  //     //reset to Idle
  //     modelRM.resetToIdle();
  //     modelRM.rebuildStates();
  //     await tester.pump();
  //     expect(modelRM.isIdle, isTrue);
  //     expect(modelRM.hasError, isFalse);
  //     expect(modelRM.hasData, isFalse);
  //     expect(find.text(('Error message')), findsNothing);
  //   },
  // );

//   testWidgets(
//     'ReactiveModel: reset to hasData',
//     (tester) async {
//       final widget = StateBuilder(
//         observeMany: [() => modelRM],
//         shouldRebuild: (_) => true,
//         builder: (_, __) {
//           return _widgetBuilder(
//             '${modelRM.state.counter}',
//             '${modelRM.error?.message}',
//           );
//         },
//       );
//       await tester.pumpWidget(widget);
//       expect(find.text(('Error message')), findsNothing);
//       //
//       modelRM.setState((s) => s.incrementError(), );
//       await tester.pump();
//       expect(find.text(('Error message')), findsOneWidget);
//       expect(modelRM.isIdle, isFalse);
//       expect(modelRM.hasError, isTrue);
//       expect(modelRM.hasData, isFalse);
//       //reset to Idle
//       modelRM.resetToHasData();
//       modelRM.rebuildStates();
//       await tester.pump();
//       expect(modelRM.isIdle, isFalse);
//       expect(modelRM.hasError, isFalse);
//       expect(modelRM.hasData, isTrue);
//       expect(find.text(('Error message')), findsNothing);
//     },
//   );

//   testWidgets(
//     'issue #55: should reset value to null after error',
//     (tester) async {
//       final modelRM = ReactiveModel.create(0);
//       int numberOfRebuild = 0;
//       final widget = StateBuilder(
//         observeMany: [() => modelRM],
//         shouldRebuild: (_) => true,
//         tag: 'tag1',
//         builder: (_, __) {
//           return _widgetBuilder('${++numberOfRebuild}');
//         },
//       );
//       await tester.pumpWidget(widget);
//       //one rebuild
//       expect(find.text(('1')), findsOneWidget);

//       modelRM.setState((_) => modelRM.state + 1);
//       await tester.pump();
//       //two rebuilds
//       expect(find.text(('2')), findsOneWidget);

//       modelRM.setState(
//         (_) => throw Exception(),
//         ,
//       );
//       await tester.pump();
//       //three rebuilds
//       expect(find.text(('3')), findsOneWidget);

//       modelRM.setState((_) => modelRM.state);
//       await tester.pump();
//       //four rebuilds
//       expect(find.text(('4')), findsOneWidget);
//     },
//   );

  // testWidgets(
  //   'ReactiveModel : global ReactiveModel error handling',
  //   (tester) async {
  //     ReactiveModel<VanillaModel> modelRM =
  //         ReactiveModel.create(VanillaModel());
  //     String? errorMessage;
  //     final widget = Column(
  //       children: <Widget>[
  //         StateBuilder<VanillaModel>(
  //           observe: () => modelRM
  //             ..catchError((error, s) {
  //               errorMessage = error.message;
  //             }),
  //           builder: (context, modelRM) {
  //             return _widgetBuilder('${modelRM?.state.counter}');
  //           },
  //         )
  //       ],
  //     );

  //     await tester.pumpWidget(widget);
  //     modelRM.setState((s) => s.incrementAsyncWithError());
  //     expect(find.text('0'), findsOneWidget);
  //     expect(modelRM.isWaiting, isTrue);
  //     expect(errorMessage, isNull);

  //     await tester.pump(Duration(seconds: 1));
  //     expect(find.text('0'), findsOneWidget);
  //     expect(modelRM.hasError, isTrue);
  //     expect(errorMessage, 'Error message');
  //   },
  // );

//   testWidgets(
//     'issue #78: global ReactiveModel onData',
//     (tester) async {
//       int onDataFromSetState;
//       int onDataGlobal;
//       final widget = StateBuilder(
//         observeMany: [() => modelRM],
//         builder: (_, __) {
//           return Container();
//         },
//       );
//       await tester.pumpWidget(widget);

//       modelRM.onData((data) {
//         onDataGlobal = data.counter;
//       });
//       //
//       expect(onDataFromSetState, null);
//       expect(onDataGlobal, null);
//       modelRM.setState(
//         (s) => s.increment(),
//         onData: (context, data) {
//           onDataFromSetState = data.counter;
//         },
//       );

//       await tester.pump();
//       expect(onDataFromSetState, 1);
//       expect(onDataGlobal, 1);
//     },
//   );

  testWidgets('debounce positive should work', (tester) async {
    final rm = ReactiveModel(creator: () => 0, initialState: 0);

    // rm.subscribeToRM((_,__) {});

    rm.setState(
      (s) => s + 1,
      debounceDelay: 1000,
    );
    expect(rm.state, 0);
    rm.setState(
      (s) => s + 1,
      debounceDelay: 1000,
    );
    expect(rm.state, 0);

    await tester.pump(Duration(microseconds: 500));

    rm.setState(
      (s) => s + 1,
      debounceDelay: 1000,
    );
    expect(rm.state, 0);

    await tester.pump(Duration(seconds: 1));
    expect(rm.state, 1);

    rm.setState(
      (s) => s + 1,
      debounceDelay: 1000,
    );
    expect(rm.state, 1);

    rm.setState(
      (s) => s + 1,
      debounceDelay: 1000,
    );
    expect(rm.state, 1);

    await tester.pump(Duration(seconds: 1));
    expect(rm.state, 2);
  });

  testWidgets('throttleDelay should work', (tester) async {
    final rm = ReactiveModel(creator: () => 0, initialState: 0);

    // rm.subscribeToRM((_,__) {});

    rm.setState(
      (s) => s + 1,
      throttleDelay: 1000,
    );
    expect(rm.state, 1);
    rm.setState(
      (s) => s + 1,
      throttleDelay: 1000,
    );
    expect(rm.state, 1);

    await tester.pump(Duration(microseconds: 500));

    rm.setState(
      (s) => s + 1,
      throttleDelay: 1000,
    );
    expect(rm.state, 1);

    await tester.pump(Duration(seconds: 1));
    rm.setState(
      (s) => s + 1,
      throttleDelay: 1000,
    );
    expect(rm.state, 2);

    rm.setState(
      (s) => s + 1,
      debounceDelay: 1000,
    );
    expect(rm.state, 2);

    await tester.pump(Duration(seconds: 1));
  });

  testWidgets('ReactiveModel.refresh', (tester) async {
    final rm = ReactiveModel.create(0);

    final widget = StateBuilder<int>(
      observe: () => rm,
      builder: (_, rm) {
        return Text('${rm!.state}');
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('0'), findsOneWidget);
    rm.state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await rm.refresh();

    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(rm.isIdle, isTrue);
  });

  // testWidgets('ReactiveModel.refresh stream', (tester) async {
  //   final rm = RM.create(VanillaModel()).stream(
  //         (m, _) => getStream(),
  //         initialValue: 0,
  //       );

  //   final widget = WhenRebuilderOr(
  //     observe: () => rm,
  //     onWaiting: () => Text('waiting ...'),
  //     builder: (_, rm) {
  //       return Text('${rm.state}');
  //     },
  //   );

  //   await tester.pumpWidget(MaterialApp(home: widget));

  //   expect(find.text('waiting ...'), findsOneWidget);

  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('0'), findsOneWidget);

  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('1'), findsOneWidget);
  //   rm.refresh();
  //   await tester.pump();
  //   await tester.pump(Duration(seconds: 1));

  //   expect(find.text('0'), findsOneWidget);
  //   await tester.pump(Duration(seconds: 1));
  //   expect(find.text('1'), findsOneWidget);
  // });

// //   testWidgets('ReactiveModel.refresh future', (tester) async {
// //     final rm = RM.create(VanillaModel()).future((m, _) => m.incrementAsync());

// //     final widget = WhenRebuilderOr(
// //       observe: () => rm,
// //       onWaiting: () => Text('waiting ...'),
// //       builder: (_, rm) {
// //         return Text('data');
// //       },
// //     );

// //     await tester.pumpWidget(MaterialApp(home: widget));
// //     expect(find.text('waiting ...'), findsOneWidget);
// //     await tester.pump(Duration(seconds: 1));
// //     expect(find.text('data'), findsOneWidget);

// //     rm.refresh();
// //     await tester.pump();
// //     expect(find.text('waiting ...'), findsOneWidget);
// //     await tester.pump(Duration(seconds: 1));
// //     expect(find.text('data'), findsOneWidget);
// //   });

//   testWidgets('skip waiting works', (tester) async {
//     String? result;
//     modelRM?.subscribeToRM((rm) {
//       result = rm.whenConnectionState(
//         onIdle: () => 'idle',
//         onWaiting: () => 'waiting',
//         onError: (e) => '${e.message}',
//         onData: (d) => d.counter.toString(),
//       );
//     });

//     //
//     modelRM?.setState((s) => s.incrementAsync(), skipWaiting: true);
//     await tester.pump();
//     expect(modelRM?.isIdle, true);

//     await tester.pump(Duration(seconds: 1));
//     expect(result, '1');

//     //
//     modelRM?.setState((s) => s.incrementAsync(), skipWaiting: true);
//     await tester.pump();
//     expect(result, '1');

//     await tester.pump(Duration(seconds: 1));
//     expect(result, '2');
//     //
//   });

  testWidgets('refresh a reactive model', (tester) async {
    int x = 0;
    ReactiveModel<int> rm = ReactiveModel(creator: () => x, initialState: 0);
    final widget = StateBuilder(
      observe: () => rm,
      builder: (_, __) {
        return Text(rm.state.toString());
      },
    );

    await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: widget));

    expect(find.text('0'), findsOneWidget);
    //
    x = 1;
    rm.refresh();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('do and undo state', (tester) async {
    final rm = RM.inject(() => 0, undoStackLength: 8);
    final widget = StateBuilder(
      observe: () => rm,
      builder: (_, __) {
        return Text(rm.state.toString());
      },
    );

    await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: widget));

    expect(find.text('0'), findsOneWidget);
    //
    rm.state = 1;

    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    rm.state = 2;

    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    //undo
    rm.undoState();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    rm.undoState();
    await tester.pump();
    expect(find.text('0'), findsOneWidget);

    //redo
    rm.redoState();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    rm.redoState();
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    //
    //undo
    rm.undoState();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    rm.undoState();
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    //redo
    rm.redoState();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    rm.redoState();
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    //undo
    rm.undoState();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    //redo
    rm.redoState();
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    //undo
    rm.undoState();
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    //
    rm.state = 2;
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(rm.canRedoState, false);
  });
  testWidgets(
      'onData of immutable is  called when state not changed after waiting',
      (tester) async {
    int numberOfRebuild = 0;
    int numberOfOnData = 0;
    final counter = RM.inject(
      () => 0,
      onData: (_) => numberOfOnData++,
    );
    final widget = counter.whenRebuilderOr(builder: () {
      numberOfRebuild++;
      return Container();
    });

    await tester.pumpWidget(widget);
    expect(numberOfRebuild, 1);
    expect(numberOfOnData, 0);

    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 0));
    await tester.pump();
    expect(numberOfRebuild, 2);
    expect(numberOfOnData, 0);
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, 3);
    expect(numberOfOnData, 1);
    //
    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 1));
    await tester.pump();
    expect(numberOfRebuild, 4);
    expect(numberOfOnData, 1);
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, 5);
    expect(numberOfOnData, 2);
    //
    counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 1));
    await tester.pump();
    expect(numberOfRebuild, 6);
    expect(numberOfOnData, 2);
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, 7);
    expect(numberOfOnData, 3);
  });
}

class ImmutableModel {
  final int counter;

  ImmutableModel(this.counter);

  Stream<ImmutableModel> incrementStream() async* {
    await Future.delayed(Duration(seconds: 1));
    yield ImmutableModel(counter + 1);
    await Future.delayed(Duration(seconds: 1));
    yield ImmutableModel(counter + 2);
    await Future.delayed(Duration(seconds: 1));
    yield this;
    throw Exception('Error message');
  }
}

Widget _widgetBuilder(String? text1, [String? text2, String? text3]) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Column(
      children: <Widget>[
        Text(text1 ?? ''),
        Text(text2 ?? ''),
        Text(text3 ?? ''),
      ],
    ),
  );
}

Future<int> getFuture() => Future.delayed(Duration(seconds: 1), () => 1);
Future<int> getFutureWithError() => Future.delayed(Duration(seconds: 1), () {
      throw Exception('Error message');
    });
Stream<int> getStream() {
  return Stream.periodic(Duration(seconds: 1), (num) => num).take(3);
}
