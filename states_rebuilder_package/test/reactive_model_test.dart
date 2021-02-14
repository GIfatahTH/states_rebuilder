import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

import 'fake_classes/models.dart';

void main() {
  ReactiveModel<VanillaModel>? modelRM;

  setUp(() {
    // final inject = Inject(() => VanillaModel());
    // modelRM = inject.getReactive()..listenToRM((rm) {});
    modelRM = ReactiveModelImp(
        creator: (_) => VanillaModel(), nullState: VanillaModel());
  });

  tearDown(() {
    modelRM = null;
  });

  test('ReactiveModel: get the state with the right status', () {
    expect(modelRM?.state, isA<VanillaModel>());
    expect(modelRM?.snapState.data, isA<VanillaModel>());
    expect(modelRM?.connectionState, equals(ConnectionState.none));
    expect(modelRM?.hasData, isFalse);

    modelRM?.setState(null);
    expect(modelRM?.connectionState, equals(ConnectionState.done));
    expect(modelRM?.hasData, isTrue);
  });

  test(
    'ReactiveModel: throw error if error is not caught',
    () {
      //throw
      expect(
          () => modelRM?.setState((s) => s.incrementError()), throwsException);
      //do not throw
      modelRM?.setState((s) => s.incrementError(), catchError: true);
    },
  );

  test('ReactiveModel: get the error', () {
    modelRM?.setState((s) => s.incrementError(), catchError: true);

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
        catchError: true,
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
      modelRM?.subscribeToRM((rm) {
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
      modelRM?.setState((s) => s.incrementAsyncWithError(), catchError: true);
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
  test('ReactiveModel: Check default null state', () {
    var intRM = ReactiveModelImp<int>(creator: (_) => 1);
    expect(intRM.nullState, 0);
    intRM = ReactiveModelImp<int>(creator: (_) => 1, nullState: 10);
    expect(intRM.nullState, 10);
    //
    var doubleRM = ReactiveModelImp<double>(creator: (_) => 1.0);
    expect(doubleRM.nullState, 0.0);
    doubleRM = ReactiveModelImp<double>(creator: (_) => 1.0, nullState: 10.0);
    expect(doubleRM.nullState, 10.0);
    //
    var boolRM = ReactiveModelImp<bool>(creator: (_) => true);
    expect(boolRM.nullState, false);
    boolRM = ReactiveModelImp<bool>(creator: (_) => true, nullState: true);
    expect(boolRM.nullState, true);
    //
    var stringRM = ReactiveModelImp<String>(creator: (_) => 'string');
    expect(stringRM.nullState, '');
    stringRM = ReactiveModelImp<String>(
        creator: (_) => 'string', nullState: 'initString');
    expect(stringRM.nullState, 'initString');
    //
    var listRM = ReactiveModelImp<List>(creator: (_) => [1.2]);
    listRM.state;
    expect(listRM.nullState, [1.2]);
  });

//   testWidgets('call global error handler without observers', (tester) async {
//     BuildContext ctx;
//     var error;
//     final rm = RM.create(0)
//       ..onError((context, e) {
//         ctx = context;
//         error = e;
//       });
//     await tester.pumpWidget(StateBuilder(
//         observe: () => RM.create(0), builder: (_, __) => Container()));

//     rm.setState(
//       (_) {
//         throw Exception();
//       },
//       silent: true,
//       catchError: true,
//     );

//     expect(rm.hasError, isTrue);
//     expect(ctx, isNotNull);
//     expect(error, isA<Exception>());
//   });

//   testWidgets(
//       'Errors are not caught unless StatesRebuild.shouldCatchError is true',
//       (tester) async {
//     BuildContext ctx;
//     var error;
//     final rm = RM.create(0)
//       ..onError((context, e) {
//         ctx = context;
//         error = e;
//       });
//     await tester.pumpWidget(StateBuilder(
//         observe: () => RM.create(0), builder: (_, __) => Container()));
//     StatesRebuilerLogger.isTestMode = true;
//     expect(
//         () => rm.setState(
//               (_) {
//                 throw StateError('bad State');
//               },
//               silent: true,
//               catchError: true,
//             ),
//         throwsStateError);
//     StatesRebuilderConfig.shouldCatchError = true;

//     rm.setState(
//       (_) {
//         throw StateError('bad State');
//       },
//       silent: true,
//       catchError: true,
//     );
//     expect(rm.hasError, isTrue);
//     expect(ctx, isNotNull);
//     expect(error, isA<Error>());
//     StatesRebuilderConfig.shouldCatchError = false;
//     StatesRebuilerLogger.isTestMode = false;
//   });

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
      modelRM!.setState((s) {
        s.incrementError();
      }, catchError: true);
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

      modelRM!.setState((s) => s.incrementAsyncWithError(), catchError: true);
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
/**************************************** */

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

//   testWidgets(
//     'ReactiveModel: watch state mutating before notify observers, sync method',
//     (tester) async {
//       int numberOfRebuild = 0;
//       final widget = StateBuilder(
//         observeMany: [() => modelRM],
//         builder: (_, __) {
//           numberOfRebuild++;
//           return modelRM.whenConnectionState(
//             onIdle: () => _widgetBuilder('onIdle'),
//             onWaiting: () => _widgetBuilder('onWaiting'),
//             onData: (data) => _widgetBuilder('${data.counter}'),
//             onError: (error) => _widgetBuilder('${error.message}'),
//           );
//         },
//       );
//       await tester.pumpWidget(widget);
//       //isIdle
//       expect(numberOfRebuild, equals(1));
//       expect(find.text('onIdle'), findsOneWidget);

//       modelRM.setState(
//         (s) => s.increment(),
//         watch: (s) {
//           return s.counter;
//         },
//       );
//       await tester.pump();
//       //will rebuild
//       expect(numberOfRebuild, equals(2));
//       expect(find.text('1'), findsOneWidget);
//       //will not rebuild
//       modelRM.setState(
//         (s) => s.increment(),
//         watch: (s) {
//           return 1;
//         },
//       );
//       await tester.pump();
//       //
//       expect(numberOfRebuild, equals(2));
//       expect(find.text('1'), findsOneWidget);
//       modelRM.notify();
//       await tester.pump();
//       expect(numberOfRebuild, equals(3));
//     },
//   );

//   testWidgets(
//     'ReactiveModel: watch state mutating before notify observers, async method',
//     (tester) async {
//       int numberOfRebuild = 0;
//       final widget = StateBuilder(
//         observeMany: [() => modelRM],
//         builder: (_, __) {
//           numberOfRebuild++;
//           return modelRM.whenConnectionState(
//             onIdle: () => _widgetBuilder('onIdle'),
//             onWaiting: () => _widgetBuilder('onWaiting'),
//             onData: (data) => _widgetBuilder('${data.counter}'),
//             onError: (error) => _widgetBuilder('${error.message}'),
//           );
//         },
//       );
//       await tester.pumpWidget(widget);

//       expect(numberOfRebuild, equals(1));
//       expect(find.text('onIdle'), findsOneWidget);

//       modelRM.setState(
//         (s) => s.incrementAsync(),
//         watch: (s) {
//           return 0;
//         },
//       );
//       await tester.pump();
//       //will not rebuild
//       expect(numberOfRebuild, equals(1));
//       expect(find.text('onIdle'), findsOneWidget);

//       await tester.pump(Duration(seconds: 1));
//       //will not rebuild
//       expect(numberOfRebuild, equals(1));
//       expect(find.text('onIdle'), findsOneWidget);

//       //
//       modelRM.setState(
//         (s) => s.incrementAsync(),
//         watch: (s) {
//           return s.counter;
//         },
//       );
//       await tester.pump();
//       //will not rebuild
//       expect(numberOfRebuild, equals(1));
//       expect(find.text('onIdle'), findsOneWidget);

//       await tester.pump(Duration(seconds: 1));
//       //will rebuild
//       expect(numberOfRebuild, equals(2));
//       expect(find.text('2'), findsOneWidget);

//       //
//       modelRM.setState(
//         (s) => s.incrementAsync(),
//         watch: (s) {
//           return 1;
//         },
//       );
//       await tester.pump();
//       //will not rebuild
//       expect(numberOfRebuild, equals(2));
//       expect(find.text('2'), findsOneWidget);

//       await tester.pump(Duration(seconds: 1));
//       //will not rebuild
//       expect(numberOfRebuild, equals(2));
//       expect(find.text('2'), findsOneWidget);

//       //
//       modelRM.setState(
//         (s) => s.incrementAsync(),
//         watch: (s) {
//           return s.counter;
//         },
//       );
//       await tester.pump();
//       //will not rebuild
//       expect(numberOfRebuild, equals(2));
//       expect(find.text('2'), findsOneWidget);

//       await tester.pump(Duration(seconds: 1));
//       //will rebuild
//       expect(numberOfRebuild, equals(3));
//       expect(find.text('4'), findsOneWidget);
//     },
//   );

//   testWidgets(
//     'ReactiveModel: tagFilter works',
//     (tester) async {
//       final widget = StateBuilder(
//         observeMany: [() => modelRM],
//         tag: 'tag1',
//         builder: (_, __) {
//           return modelRM.whenConnectionState(
//             onIdle: () => _widgetBuilder('onIdle'),
//             onWaiting: () => _widgetBuilder('onWaiting'),
//             onData: (data) => _widgetBuilder('${data.counter}'),
//             onError: (error) => _widgetBuilder('${error.message}'),
//           );
//         },
//       );
//       await tester.pumpWidget(widget);
//       //isIdle
//       expect(find.text('onIdle'), findsOneWidget);
//       //rebuildAll
//       modelRM.setState((s) => s.increment());
//       await tester.pump();
//       expect(find.text('1'), findsOneWidget);
//       //rebuild with tag 'tag1'
//       modelRM.setState((s) => s.increment(), filterTags: ['tag1']);
//       await tester.pump();
//       expect(find.text('2'), findsOneWidget);
//       //rebuild with tag 'nonExistingTag'
//       modelRM.setState((s) => s.increment(), filterTags: ['nonExistingTag']);
//       await tester.pump();
//       expect(find.text('2'), findsOneWidget);
//     },
//   );

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

//   testWidgets(
//     'ReactiveModel : reactive singleton and reactive instances works independently',
//     (tester) async {
//       final inject = Inject(() => VanillaModel());
//       final modelRM0 = inject.getReactive();
//       final modelRM1 = inject.getReactive(true);
//       final modelRM2 = inject.getReactive(true);

//       final widget = Column(
//         children: <Widget>[
//           StateBuilder(
//             observeMany: [() => modelRM0],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM0-${modelRM0.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM1],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM2],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
//             },
//           )
//         ],
//       );

//       await tester.pumpWidget(widget);
//       //
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);

//       //mutate singleton
//       modelRM0.setState((s) => s.increment());
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);

//       //mutate reactive instance 1
//       modelRM1.setState((s) => s.increment());
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-2'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);

//       //mutate reactive instance 2
//       modelRM2.setState((s) => s.increment());
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-2'), findsOneWidget);
//       expect(find.text('modelRM2-3'), findsOneWidget);
//     },
//   );

//   testWidgets(
//     'ReactiveModel : new reactive notify reactive singleton with its state if joinSingleton = withNewReactiveInstance',
//     (tester) async {
//       final inject = Inject(
//         () => VanillaModel(),
//         joinSingleton: JoinSingleton.withNewReactiveInstance,
//       );
//       final modelRM2 = inject.getReactive(true);
//       final modelRM1 = inject.getReactive(true);
//       final modelRM0 = inject.getReactive();

//       final widget = Column(
//         children: <Widget>[
//           StateBuilder(
//             observeMany: [() => modelRM0],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM0-${modelRM0.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM1],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM2],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
//             },
//           )
//         ],
//       );

//       await tester.pumpWidget(widget);

//       //mutate reactive instance 1
//       modelRM1.setState((s) => s.increment());
//       await tester.pump();

//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);

//       //mutate reactive instance 1
//       modelRM2.setState((s) => s.increment());
//       await tester.pump();
//       expect(find.text('modelRM0-2'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-2'), findsOneWidget);
//     },
//   );

//   testWidgets(
//     'ReactiveModel : singleton holds the combined state of new instances if joinSingleton = withCombinedReactiveInstances case sync with error call',
//     (tester) async {
//       final inject = Inject(
//         () => VanillaModel(),
//         joinSingleton: JoinSingleton.withCombinedReactiveInstances,
//       );
//       final modelRM0 = inject.getReactive();
//       final modelRM1 = inject.getReactive(true);
//       final modelRM2 = inject.getReactive(true);

//       final widget = Column(
//         children: <Widget>[
//           StateBuilder(
//             observeMany: [() => modelRM0],
//             shouldRebuild: (_) => true,
//             builder: (context, _) {
//               return _widgetBuilder('modelRM0-${modelRM0.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM1],
//             shouldRebuild: (_) => true,
//             builder: (context, _) {
//               return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM2],
//             shouldRebuild: (_) => true,
//             builder: (context, _) {
//               return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
//             },
//           )
//         ],
//       );

//       await tester.pumpWidget(widget);

//       expect(modelRM0.isIdle, isTrue);
//       expect(modelRM1.isIdle, isTrue);
//       expect(modelRM2.isIdle, isTrue);

//       //mutate reactive instance 1
//       modelRM1.setState((s) => s.increment());
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.isIdle, isTrue);
//       expect(modelRM1.hasData, isTrue);
//       expect(modelRM2.isIdle, isTrue);

//       //mutate reactive instance 1
//       modelRM1.setState((s) => s.incrementError());
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.hasError, isTrue);
//       expect(modelRM1.hasError, isTrue);
//       expect(modelRM2.isIdle, isTrue);

//       //mutate reactive instance 2
//       modelRM2.setState((s) => s.incrementError());
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-1'), findsOneWidget);

//       expect(modelRM0.hasError, isTrue);
//       expect(modelRM1.hasError, isTrue);
//       expect(modelRM2.hasError, isTrue);

//       //mutate reactive instance 1
//       modelRM1.setState((s) => s.increment());
//       await tester.pump();
//       expect(find.text('modelRM0-2'), findsOneWidget);
//       expect(find.text('modelRM1-2'), findsOneWidget);
//       expect(find.text('modelRM2-1'), findsOneWidget);

//       expect(modelRM0.hasError, isTrue);
//       expect(modelRM1.hasData, isTrue);
//       expect(modelRM2.hasError, isTrue);

//       //mutate reactive instance 2
//       modelRM2.setState((s) => s.increment());
//       await tester.pump();
//       expect(find.text('modelRM0-3'), findsOneWidget);
//       expect(find.text('modelRM1-2'), findsOneWidget);
//       expect(find.text('modelRM2-3'), findsOneWidget);

//       expect(modelRM0.hasData, isTrue);
//       expect(modelRM1.hasData, isTrue);
//       expect(modelRM2.hasData, isTrue);
//     },
//   );

//   testWidgets(
//     'ReactiveModel : singleton holds the combined state of new instances if joinSingleton = withCombinedReactiveInstances case async wth error call',
//     (tester) async {
//       final inject = Inject(
//         () => VanillaModel(),
//         joinSingleton: JoinSingleton.withCombinedReactiveInstances,
//       );
//       final modelRM0 = inject.getReactive();
//       final modelRM1 = inject.getReactive(true);
//       final modelRM2 = inject.getReactive(true);

//       final widget = Column(
//         children: <Widget>[
//           StateBuilder(
//             observeMany: [() => modelRM0],
//             shouldRebuild: (_) => true,
//             builder: (context, _) {
//               return _widgetBuilder('modelRM0-${modelRM0.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM1],
//             shouldRebuild: (_) => true,
//             builder: (context, _) {
//               return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM2],
//             shouldRebuild: (_) => true,
//             builder: (context, _) {
//               return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
//             },
//           )
//         ],
//       );

//       await tester.pumpWidget(widget);

//       //mutate reactive instance 1
//       modelRM1.setState((s) => s.incrementAsyncWithError());
//       await tester.pump();
//       expect(find.text('modelRM0-0'), findsOneWidget);
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.isWaiting, isTrue);
//       expect(modelRM1.isWaiting, isTrue);
//       expect(modelRM2.isIdle, isTrue);

//       await tester.pump(Duration(seconds: 1));
//       expect(find.text('modelRM0-0'), findsOneWidget);
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.hasError, isTrue);
//       expect(modelRM1.hasError, isTrue);
//       expect(modelRM2.isIdle, isTrue);

//       //mutate reactive instance 2
//       modelRM2.setState((s) => s.incrementAsyncWithError());
//       await tester.pump();
//       expect(find.text('modelRM0-0'), findsOneWidget);
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);

//       expect(modelRM0.isWaiting, isTrue);
//       expect(modelRM1.hasError, isTrue);
//       expect(modelRM2.isWaiting, isTrue);

//       await tester.pump(Duration(seconds: 1));
//       expect(find.text('modelRM0-0'), findsOneWidget);
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.hasError, isTrue);
//       expect(modelRM1.hasError, isTrue);
//       expect(modelRM2.hasError, isTrue);

//       //mutate reactive instance 1
//       modelRM1.setState((s) => s.incrementAsync());
//       await tester.pump();
//       expect(find.text('modelRM0-0'), findsOneWidget);
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.isWaiting, isTrue);
//       expect(modelRM1.isWaiting, isTrue);
//       expect(modelRM2.hasError, isTrue);

//       await tester.pump(Duration(seconds: 1));
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.hasError, isTrue);
//       expect(modelRM1.hasData, isTrue);
//       expect(modelRM2.hasError, isTrue);

//       //mutate reactive instance 2
//       modelRM2.setState((s) => s.incrementAsync());
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-1'), findsOneWidget);
//       expect(modelRM0.isWaiting, isTrue);
//       expect(modelRM1.hasData, isTrue);
//       expect(modelRM2.isWaiting, isTrue);

//       await tester.pump(Duration(seconds: 1));
//       expect(find.text('modelRM0-2'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-2'), findsOneWidget);
//       expect(modelRM0.hasData, isTrue);
//       expect(modelRM1.hasData, isTrue);
//       expect(modelRM2.hasData, isTrue);
//     },
//   );

//   testWidgets(
//     'ReactiveModel : join singleton to new reactive from setState',
//     (tester) async {
//       final inject = Inject(() => VanillaModel());
//       final modelRM0 = inject.getReactive();
//       final modelRM1 = inject.getReactive(true);
//       final modelRM2 = inject.getReactive(true);

//       final widget = Column(
//         children: <Widget>[
//           StateBuilder(
//             observeMany: [() => modelRM0],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM0-${modelRM0.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM1],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM2],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
//             },
//           )
//         ],
//       );

//       await tester.pumpWidget(widget);

//       //mutate reactive instance 1
//       modelRM1.setState(
//         (s) => s.incrementError(),
//         joinSingleton: true,
//         catchError: true,
//       );
//       await tester.pump();
//       expect(find.text('modelRM0-0'), findsOneWidget);
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.hasError, isTrue);
//       expect(modelRM1.hasError, isTrue);
//       expect(modelRM2.isIdle, isTrue);

//       //mutate reactive instance 2
//       modelRM2.setState(
//         (s) => s.incrementError(),
//         joinSingleton: true,
//         catchError: true,
//       );
//       await tester.pump();
//       expect(find.text('modelRM0-0'), findsOneWidget);
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.hasError, isTrue);
//       expect(modelRM1.hasError, isTrue);
//       expect(modelRM2.hasError, isTrue);

//       //mutate reactive instance 1
//       modelRM1.setState((s) => s.increment(), joinSingleton: true);
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.hasData, isTrue);
//       expect(modelRM1.hasData, isTrue);
//       expect(modelRM2.hasError, isTrue);

//       //mutate reactive instance 2
//       modelRM2.setState((s) => s.increment(), joinSingleton: true);
//       await tester.pump();
//       expect(find.text('modelRM0-2'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-2'), findsOneWidget);
//       expect(modelRM0.hasData, isTrue);
//       expect(modelRM1.hasData, isTrue);
//       expect(modelRM2.hasData, isTrue);
//     },
//   );

//   testWidgets(
//     'ReactiveModel : notify all reactive instances to new reactive from setState',
//     (tester) async {
//       final inject = Inject(() => VanillaModel());
//       final modelRM0 = inject.getReactive();
//       final modelRM1 = inject.getReactive(true);
//       final modelRM2 = inject.getReactive(true);

//       final widget = Column(
//         children: <Widget>[
//           StateBuilder(
//             observeMany: [() => modelRM0],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM0-${modelRM0.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM1],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM2],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
//             },
//           )
//         ],
//       );

//       await tester.pumpWidget(widget);

//       //mutate reactive instance 0
//       modelRM0.setState(
//         (s) => s.incrementError(),
//         notifyAllReactiveInstances: true,
//         catchError: true,
//       );
//       await tester.pump();
//       expect(find.text('modelRM0-0'), findsOneWidget);
//       expect(find.text('modelRM1-0'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);
//       expect(modelRM0.hasError, isTrue);
//       expect(modelRM1.isIdle, isTrue);
//       expect(modelRM2.isIdle, isTrue);

//       //mutate reactive instance 0
//       modelRM0.setState(
//         (s) => s.increment(),
//         notifyAllReactiveInstances: true,
//         catchError: true,
//       );
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-1'), findsOneWidget);
//       expect(modelRM0.hasData, isTrue);
//       expect(modelRM1.isIdle, isTrue);
//       expect(modelRM2.isIdle, isTrue);

//       //mutate reactive instance 1
//       modelRM2.setState(
//         (s) => s.incrementError(),
//         notifyAllReactiveInstances: true,
//         catchError: true,
//       );
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-1'), findsOneWidget);
//       expect(modelRM0.hasData, isTrue);
//       expect(modelRM1.isIdle, isTrue);
//       expect(modelRM2.hasError, isTrue);

//       //mutate reactive instance 0
//       modelRM2.setState(
//         (s) => s.increment(),
//         notifyAllReactiveInstances: true,
//       );
//       await tester.pump();
//       expect(find.text('modelRM0-2'), findsOneWidget);
//       expect(find.text('modelRM1-2'), findsOneWidget);
//       expect(find.text('modelRM2-2'), findsOneWidget);
//       expect(modelRM0.hasData, isTrue);
//       expect(modelRM1.isIdle, isTrue);
//       expect(modelRM2.hasData, isTrue);
//     },
//   );

//   testWidgets(
//     'ReactiveModel : join singleton to new reactive from setState with data send using joinSingletonToNewData',
//     (tester) async {
//       final inject = Inject(() => VanillaModel());
//       final modelRM0 = inject.getReactive();
//       final modelRM1 = inject.getReactive(true);
//       final modelRM2 = inject.getReactive(true);

//       final widget = Column(
//         children: <Widget>[
//           StateBuilder(
//             observeMany: [() => modelRM0],
//             builder: (context, _) {
//               return _widgetBuilder(
//                   'modelRM0-${modelRM0.joinSingletonToNewData}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM1],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM2],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
//             },
//           )
//         ],
//       );

//       await tester.pumpWidget(widget);

//       //mutate reactive instance 1
//       modelRM1.setState((s) => s.increment(),
//           joinSingleton: true,
//           catchError: true,
//           joinSingletonToNewData: () => 'modelRM1-${modelRM1.state.counter}');
//       await tester.pump();
//       expect(find.text('modelRM0-modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);

//       //mutate reactive instance 2
//       modelRM2.setState((s) => s.increment(),
//           joinSingleton: true,
//           catchError: true,
//           joinSingletonToNewData: () => 'modelRM2-${modelRM1.state.counter}');
//       await tester.pump();
//       expect(find.text('modelRM0-modelRM2-2'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-2'), findsOneWidget);
//     },
//   );

//   testWidgets(
//       'ReactiveModel : throws if setState is called on async injected models',
//       (tester) async {
//     final inject = Inject.future(() => getFuture());
//     final modelRM0 = inject.getReactive();
//     expect(() => modelRM0.setState(null), throwsException);
//     await tester.pump(Duration(seconds: 1));
//   });

  testWidgets(
    'ReactiveModel : inject futures get primitive nullState',
    (tester) async {
      final modelRM0 = ReactiveModelImp.future(
        () => Future.delayed(Duration(seconds: 1), () => 1),
        // nullState: 0,
      );

      expect(modelRM0.state, 0);
      expect(modelRM0.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 1);
      expect(modelRM0.nullState, 0);
      expect(modelRM0.hasData, isTrue);
    },
  );

  testWidgets(
    'ReactiveModel : inject futures throw argument error if getting a non initialized state while waiting',
    (tester) async {
      final modelRM0 = ReactiveModelImp.future(
        () => Future.delayed(Duration(seconds: 1), () => VanillaModel()),
      );
      expect(modelRM0.stateAsync, isA<Future<VanillaModel>>());

      expect(() => modelRM0.state, throwsArgumentError);
      expect(modelRM0.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state.counter, 0);
      expect(modelRM0.nullState.counter, 0);
      expect(modelRM0.hasData, isTrue);
      expect((await modelRM0.stateAsync).counter, 0);
    },
  );

  testWidgets(
    'ReactiveModel : inject futures with error works',
    (tester) async {
      final modelRM0 = ReactiveModelImp.future(
        () => getFutureWithError(),
        nullState: 10,
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
      final modelRM0 = ReactiveModelImp.future(
        () => Future.delayed(Duration(seconds: 1), () => 1),
        // nullState: 0,
      );

      expect(modelRM0.state, 0);
      expect(modelRM0.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 1);
      expect(modelRM0.nullState, 0);
      expect(modelRM0.hasData, isTrue);
      modelRM0.refresh();
      await tester.pump();
      expect(modelRM0.state, 0);
      expect(modelRM0.isWaiting, isTrue);
      await tester.pump(Duration(seconds: 1));
      expect(modelRM0.state, 1);
      expect(modelRM0.nullState, 0);
    },
  );

//   group('future', () {
//     testWidgets(
//       'ReactiveModel : inject futures with tag filter works ',
//       (tester) async {
//         final inject = Inject.future(() => getFuture(), filterTags: ['tag1']);
//         final modelRM0 = inject.getReactive();

//         final widget = Column(
//           children: <Widget>[
//             StateBuilder(
//               observeMany: [() => modelRM0],
//               tag: 'tag1',
//               builder: (context, _) {
//                 return _widgetBuilder('tag1-${modelRM0.state}');
//               },
//             ),
//             StateBuilder(
//               observeMany: [() => modelRM0],
//               builder: (context, _) {
//                 return _widgetBuilder('${modelRM0.state}');
//               },
//             )
//           ],
//         );

//         await tester.pumpWidget(widget);

//         expect(find.text('tag1-null'), findsOneWidget);
//         expect(find.text('null'), findsOneWidget);
//         expect(modelRM0.isWaiting, isTrue);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('tag1-1'), findsOneWidget);
//         expect(find.text('null'), findsOneWidget);
//         expect(modelRM0.hasData, isTrue);
//       },
//     );

//     testWidgets(
//       'ReactiveModel : ReactiveModel.future works',
//       (tester) async {
//         final rmKey = RMKey<int>(0);
//         final widget = Column(
//           children: <Widget>[
//             StateBuilder<int>(
//               observe: () => RM.future(getFuture(), initialValue: 0),
//               rmKey: rmKey,
//               builder: (context, _) {
//                 return Container();
//               },
//             ),
//             StateBuilder(
//               observe: () => rmKey,
//               builder: (_, rm) {
//                 return Text(rm.state.toString());
//               },
//             ),
//           ],
//         );

//         await tester.pumpWidget(MaterialApp(home: widget));
//         expect(find.text('0'), findsOneWidget);
//         expect(rmKey.isWaiting, isTrue);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(rmKey.hasData, isTrue);
//       },
//     );

//     testWidgets(
//       'ReactiveModel : future method works',
//       (tester) async {
//         ReactiveModel<VanillaModel> modelRM = RM.create(VanillaModel());
//         String errorMessage;
//         final widget = Column(
//           children: <Widget>[
//             StateBuilder<VanillaModel>(
//               //used to add observer so to throw FlutterError
//               observe: () => modelRM,
//               builder: (context, modelRM) {
//                 return Container();
//               },
//             ),
//             StateBuilder<VanillaModel>(
//               observe: () => modelRM
//                 ..setState((m) => m.incrementAsync())
//                 ..onError((context, error) {
//                   errorMessage = error.message;
//                 }),
//               builder: (context, modelRM) {
//                 return _widgetBuilder('${modelRM.state.counter}');
//               },
//             ),
//             StateBuilder<VanillaModel>(
//               //used to add observer so to throw FlutterError
//               observe: () => modelRM,
//               builder: (context, modelRM) {
//                 return Container();
//               },
//             ),
//           ],
//         );

//         await tester.pumpWidget(widget);
//         expect(find.text('0'), findsOneWidget);
//         expect(modelRM.isWaiting, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(modelRM.hasData, isTrue);
//         expect(errorMessage, isNull);
//       },
//     );

//     testWidgets(
//       'ReactiveModel : future method works, case with error',
//       (tester) async {
//         ReactiveModel<VanillaModel> modelRM = RM.create(VanillaModel());
//         String errorMessage;
//         final widget = Column(
//           children: <Widget>[
//             StateBuilder<VanillaModel>(
//               observe: () => modelRM,
//               builder: (context, modelRM) {
//                 return Container();
//               },
//             ),
//             StateBuilder<VanillaModel>(
//               observe: () => modelRM
//                 ..setState((m) => m.incrementAsyncWithError())
//                 ..onError((context, error) {
//                   errorMessage = error.message;
//                 }),
//               builder: (context, modelRM) {
//                 return _widgetBuilder('${modelRM.state.counter}');
//               },
//             )
//           ],
//         );

//         await tester.pumpWidget(widget);
//         expect(find.text('0'), findsOneWidget);
//         expect(modelRM.isWaiting, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('0'), findsOneWidget);
//         expect(modelRM.hasError, isTrue);
//         expect(errorMessage, 'Error message');
//       },
//     );

//     testWidgets(
//       'ReactiveModel : future method works, call future from initState',
//       (tester) async {
//         ReactiveModel<VanillaModel> modelRM = RM.create(VanillaModel());
//         String errorMessage;
//         final widget = Column(
//           children: <Widget>[
//             StateBuilder<VanillaModel>(
//               observe: () => modelRM,
//               builder: (context, modelRM) {
//                 return Container();
//               },
//             ),
//             StateBuilder<VanillaModel>(
//               observe: () => modelRM,
//               initState: (_, modelRM) => modelRM
//                 ..setState((m) => m.incrementAsyncWithError())
//                 ..onError((context, error) {
//                   errorMessage = error.message;
//                 }),
//               builder: (context, modelRM) {
//                 return _widgetBuilder('${modelRM.state.counter}');
//               },
//             )
//           ],
//         );

//         await tester.pumpWidget(widget);
//         expect(find.text('0'), findsOneWidget);
//         expect(modelRM.isWaiting, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('0'), findsOneWidget);
//         expect(modelRM.hasError, isTrue);
//         expect(errorMessage, 'Error message');
//       },
//     );

//     testWidgets(
//       'Nested dependent futures ',
//       (tester) async {
//         final future1 =
//             RM.future(Future.delayed(Duration(seconds: 1), () => 2));
//         final inject = Inject.future(() async {
//           final future1Value = await future1.stateAsync;
//           await Future.delayed(Duration(seconds: 1));
//           return future1Value * 2;
//         });
//         final future2 = inject.getReactive();
//         expect(future1.isWaiting, isTrue);
//         expect(future2.isWaiting, isTrue);
//         await tester.pump(Duration(seconds: 1));
//         expect(future1.hasData, isTrue);
//         expect(future2.isWaiting, isTrue);
//         future2.setState(
//           (future) => Future.delayed(Duration(seconds: 1), () => 2 * future),
//           silent: true,
//           shouldAwait: true,
//         );
//         await tester.pump(Duration(seconds: 1));
//         expect(future1.state, 2);
//         expect(future2.isWaiting, isTrue);
//         await tester.pump(Duration(seconds: 1));
//         expect(future1.state, 2);
//         expect(future2.state, 8);
//       },
//     );
//   });
//   group('stream', () {
  testWidgets(
    'ReactiveModel : inject stream with data works',
    (tester) async {
      final modelRM0 = ReactiveModelImp.stream((_) => getStream());

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
      final modelRM0 = ReactiveModelImp.stream(
          (_) => VanillaModel().incrementStreamWithError(),
          nullState: 0);

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

      expect(modelRM0.isDone, isTrue);
    },
  );
//     testWidgets(
//       'ReactiveModel : inject stream with watching data works',
//       (tester) async {
//         final inject = Inject.stream(() => getStream(), watch: (data) {
//           return 0;
//         });
//         final modelRM0 = inject.getReactive();
//         int numberOfRebuild = 0;
//         final widget = Column(
//           children: <Widget>[
//             StateBuilder(
//               observeMany: [() => modelRM0],
//               builder: (context, _) {
//                 numberOfRebuild++;
//                 return _widgetBuilder('${modelRM0.state}-$numberOfRebuild');
//               },
//             )
//           ],
//         );

//         await tester.pumpWidget(widget);

//         expect(find.text('null-1'), findsOneWidget);
//         expect(modelRM0.isWaiting, isTrue);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('null-1'), findsOneWidget);
//         expect(modelRM0.hasData, isTrue);

//         // await tester.pump(Duration(seconds: 1));
//         // expect(find.text('null-1'), findsOneWidget);
//         // expect(modelRM0.hasData, isTrue);

//         // await tester.pump(Duration(seconds: 1));
//         // expect(find.text('null-1'), findsOneWidget);
//       },
//     );
//     testWidgets(
//       'issue #61: reactive stream with error and watch',
//       (WidgetTester tester) async {
//         int numberOfRebuild = 0;
//         Stream<int> snapStream = Stream.periodic(Duration(seconds: 1), (num) {
//           if (num == 0) throw Exception('Error message');
//           return num + 1;
//         }).take(3);

//         final rmStream = ReactiveModel.stream(snapStream,
//             watch: (rm) => rm, initialValue: 0);
//         final widget = Injector(
//           inject: [Inject(() => 'n')],
//           builder: (_) {
//             return StateBuilder(
//               observeMany: [() => rmStream],
//               tag: 'MyTag',
//               shouldRebuild: (_) => true,
//               builder: (_, rmStream) {
//                 numberOfRebuild++;
//                 return Container();
//               },
//             );
//           },
//         );

//         await tester.pumpWidget(MaterialApp(home: widget));
//         expect(numberOfRebuild, 1);
//         expect(rmStream.state, 0);

//         await tester.pump(Duration(seconds: 1));
//         expect(numberOfRebuild, 2);
//         expect(rmStream.state, 0);

//         await tester.pump(Duration(seconds: 1));
//         expect(numberOfRebuild, 3);
//         expect(rmStream.state, 2);

//         await tester.pump(Duration(seconds: 1));
//         expect(numberOfRebuild, 4);
//         expect(rmStream.state, 3);

//         await tester.pump(Duration(seconds: 1));
//         expect(numberOfRebuild, 5);
//         expect(rmStream.state, 4);

//         await tester.pump(Duration(seconds: 1));
//         expect(numberOfRebuild, 5);
//         expect(rmStream.state, 4);
//       },
//     );

//     testWidgets(
//       'ReactiveModel : stream method works. case stream called from observe parameter',
//       (tester) async {
//         ReactiveModel<VanillaModel> modelRM = RM.create(VanillaModel());
//         String errorMessage;
//         final widget = Column(
//           children: <Widget>[
//             StateBuilder<VanillaModel>(
//               observe: () => modelRM
//                 ..setState((m) => m.incrementStream())
//                 ..onError((context, error) {
//                   errorMessage = error.message;
//                 }),
//               builder: (context, modelRM) {
//                 return _widgetBuilder('${modelRM.state.counter}');
//               },
//             )
//           ],
//         );

//         await tester.pumpWidget(widget);
//         expect(find.text('0'), findsOneWidget);
//         expect(modelRM.isWaiting, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(modelRM.hasData, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('2'), findsOneWidget);
//         expect(modelRM.hasData, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(modelRM.hasError, isTrue);
//         expect(errorMessage, 'Error message');
//       },
//     );

//     testWidgets(
//       'ReactiveModel : stream method works. case stream called from outside',
//       (tester) async {
//         ReactiveModel<VanillaModel> modelRM = RM.create(VanillaModel());
//         String errorMessage;
//         final widget = Column(
//           children: <Widget>[
//             StateBuilder<VanillaModel>(
//               observe: () => modelRM,
//               builder: (context, modelRM) {
//                 return _widgetBuilder('${modelRM.state.counter}');
//               },
//             )
//           ],
//         );

//         modelRM
//           ..setState((m) => m.incrementStream())
//           ..onError((context, error) {
//             errorMessage = error.message;
//           });
//         await tester.pumpWidget(widget);
//         expect(find.text('0'), findsOneWidget);
//         expect(modelRM.isWaiting, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(modelRM.hasData, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('2'), findsOneWidget);
//         expect(modelRM.hasData, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(modelRM.hasError, isTrue);
//         expect(errorMessage, 'Error message');
//       },
//     );

//     testWidgets(
//       'ReactiveModel : stream method works with new ReactiveModel',
//       (tester) async {
//         ReactiveModel<VanillaModel> modelRM = RM.create(VanillaModel());
//         ReactiveModel<VanillaModel> newModelRM = modelRM.asNew('newRM');
//         String errorMessage;
//         final widget = Column(
//           children: <Widget>[
//             StateBuilder<VanillaModel>(
//               observeMany: [() => modelRM, () => newModelRM],
//               builder: (context, modelRM) {
//                 return _widgetBuilder('${modelRM.state.counter}');
//               },
//             )
//           ],
//         );

//         newModelRM
//           ..setState((m) => m.incrementStream())
//           ..onError((context, error) {
//             errorMessage = error.message;
//           });
//         await tester.pumpWidget(widget);
//         expect(find.text('0'), findsOneWidget);
//         expect(modelRM.isIdle, isTrue);
//         expect(newModelRM.isWaiting, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(modelRM.isIdle, isTrue);
//         expect(newModelRM.hasData, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('2'), findsOneWidget);
//         expect(newModelRM.hasData, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(modelRM.isIdle, isTrue);
//         expect(newModelRM.hasError, isTrue);
//         expect(errorMessage, 'Error message');
//       },
//     );
//     testWidgets(
//       'ReactiveModel : stream method works. ImmutableModel',
//       (tester) async {
//         ReactiveModel<ImmutableModel> modelRM = RM.create(ImmutableModel(0));
//         String errorMessage;
//         final widget = Column(
//           children: <Widget>[
//             StateBuilder<ImmutableModel>(
//               observe: () => modelRM,
//               builder: (context, modelRM) {
//                 return _widgetBuilder('${modelRM.state.counter}');
//               },
//             )
//           ],
//         );

//         modelRM
//           ..setState((m) => m.incrementStream())
//           ..onError((context, error) {
//             errorMessage = error.message;
//           });
//         await tester.pumpWidget(widget);
//         expect(find.text('0'), findsOneWidget);
//         expect(modelRM.isWaiting, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(modelRM.hasData, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('2'), findsOneWidget);
//         expect(modelRM.hasData, isTrue);
//         expect(errorMessage, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('0'), findsOneWidget);
//         expect(modelRM.hasError, isTrue);
//         expect(errorMessage, 'Error message');
//       },
//     );

//     testWidgets(
//       'Injector  will  stream dispose if ',
//       (tester) async {
//         ReactiveModel<VanillaModel> modelRM = RM.create(VanillaModel());
//         final rmKey = RMKey(true);
//         final widget = StateBuilder(
//             observe: () => RM.create(true),
//             rmKey: rmKey,
//             tag: 'tag1',
//             builder: (context, switcherRM) {
//               if (switcherRM.state) {
//                 return StateBuilder<VanillaModel>(
//                   observe: () => modelRM,
//                   builder: (context, modelRM) {
//                     return _widgetBuilder('${modelRM.state.counter}');
//                   },
//                 );
//               } else {
//                 return Container();
//               }
//             });
//         final streamRM = modelRM..setState((m) => m.incrementStream());

//         await tester.pumpWidget(widget);
//         expect(find.text('0'), findsOneWidget);
//         expect(streamRM.isA<VanillaModel>(), isTrue);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(streamRM.subscription.isPaused, isFalse);

//         rmKey.state = false;
//         await tester.pump();

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsNothing);
//         expect(streamRM.subscription, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('2'), findsNothing);
//       },
//     );
//   });

//   group('ReactiveModel setValue :', () {
//     testWidgets(
//       'tagFilter works',
//       (tester) async {
//         final modelRM = RM.create(0);

//         final widget = StateBuilder(
//           observeMany: [() => modelRM],
//           tag: 'tag1',
//           builder: (_, __) {
//             return _widgetBuilder('${modelRM.state}');
//           },
//         );
//         await tester.pumpWidget(widget);
//         modelRM.setState((_) => modelRM.state + 1);
//         await tester.pump();
//         expect(find.text(('1')), findsOneWidget);

//         await tester.pumpWidget(widget);
//         modelRM.setState((_) => modelRM.state + 1, filterTags: ['tag1']);
//         await tester.pump();
//         expect(find.text(('2')), findsOneWidget);
//         await tester.pumpWidget(widget);
//         modelRM
//             .setState((_) => modelRM.state + 1, filterTags: ['nonExistingTag']);
//         await tester.pump();
//         expect(find.text(('2')), findsOneWidget);
//       },
//     );

//     testWidgets(
//       'if the value does not changed do not rebuild',
//       (tester) async {
//         final modelRM = ReactiveModel.create(0);
//         int numberOfRebuild = 0;
//         final widget = StateBuilder(
//           observeMany: [() => modelRM],
//           tag: 'tag1',
//           builder: (_, __) {
//             return _widgetBuilder('${++numberOfRebuild}');
//           },
//         );
//         await tester.pumpWidget(widget);
//         expect(find.text(('1')), findsOneWidget);

//         modelRM.setState((_) => modelRM.state);
//         await tester.pump();
//         expect(find.text(('1')), findsOneWidget);

//         modelRM.setState((_) => modelRM.state + 1);
//         await tester.pump();
//         expect(find.text(('2')), findsOneWidget);
//       },
//     );

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

//     testWidgets(
//       'sync methods with and without error work',
//       (tester) async {
//         final modelRM = ReactiveModel.create(0);

//         final widget = StateBuilder(
//           observeMany: [() => modelRM],
//           shouldRebuild: (_) => true,
//           builder: (_, __) {
//             return modelRM.whenConnectionState(
//               onIdle: () => _widgetBuilder('onIdle'),
//               onWaiting: () => _widgetBuilder('onWaiting'),
//               onData: (data) => _widgetBuilder('$data'),
//               onError: (error) => _widgetBuilder('${error.message}'),
//             );
//           },
//         );
//         await tester.pumpWidget(widget);
//         //sync increment without error
//         modelRM.setState((_) {
//           final model = VanillaModel();
//           model.increment();
//           return model.counter;
//         });
//         await tester.pump();
//         expect(find.text(('1')), findsOneWidget);

//         //sync increment with error
//         var error;
//         await modelRM.setState(
//           (_) {
//             final model = VanillaModel();
//             model.incrementError();
//             return model.counter;
//           },
//           onError: (_, e) {
//             error = e;
//           },
//           catchError: true,
//         );
//         await tester.pump();
//         expect(find.text('Error message'), findsOneWidget);
//         expect(error.message, equals('Error message'));
//       },
//     );

//     testWidgets(
//       'seeds works',
//       (tester) async {
//         final modelRM0 = ReactiveModel.create(0);
//         final modelRM1 = modelRM0.asNew('seed1');
//         final widget = Column(
//           children: <Widget>[
//             StateBuilder(
//               observeMany: [() => modelRM0],
//               builder: (_, __) {
//                 return _widgetBuilder('model0-${modelRM0.state}');
//               },
//             ),
//             StateBuilder(
//               observeMany: [() => modelRM1],
//               builder: (_, __) {
//                 return _widgetBuilder('model1-${modelRM1.state}');
//               },
//             )
//           ],
//         );
//         await tester.pumpWidget(widget);
//         modelRM0.setState((_) => modelRM0.state + 1);
//         await tester.pump();
//         expect(find.text(('model0-1')), findsOneWidget);
//         expect(find.text(('model1-0')), findsOneWidget);
//         //
//         modelRM0.setState((_) => modelRM0.state + 1, seeds: ['seed1']);
//         await tester.pump();
//         expect(find.text(('model0-2')), findsOneWidget);
//         expect(find.text(('model1-2')), findsOneWidget);
//         //
//         modelRM1.setState((_) {
//           return modelRM1.state + 1;
//         });
//         await tester.pump();
//         expect(find.text(('model0-2')), findsOneWidget);
//         expect(find.text(('model1-3')), findsOneWidget);
//         //
//         modelRM1.setState(
//           (_) {
//             return modelRM1.state + 1;
//           },
//           notifyAllReactiveInstances: true,
//         );
//         await tester.pump();
//         expect(find.text(('model0-4')), findsOneWidget);
//         expect(find.text(('model1-4')), findsOneWidget);
//       },
//     );

//     testWidgets(
//       'Async methods with and without error work',
//       (tester) async {
//         final modelRM = ReactiveModel.create(0);
//         int onData;

//         final widget = StateBuilder(
//           observeMany: [() => modelRM],
//           shouldRebuild: (_) => true,
//           builder: (_, __) {
//             return modelRM.whenConnectionState(
//               onIdle: () => _widgetBuilder('onIdle'),
//               onWaiting: () => _widgetBuilder('onWaiting'),
//               onData: (data) => _widgetBuilder('$data'),
//               onError: (error) => _widgetBuilder('${error.message}'),
//             );
//           },
//         );
//         await tester.pumpWidget(widget);
//         expect(modelRM.isA<int>(), isTrue);

//         expect(find.text(('onIdle')), findsOneWidget);

//         //sync increment without error
//         modelRM.setState((_) async {
//           final model = VanillaModel();
//           await model.incrementAsync();
//           return model.counter;
//         }, onData: (context, data) {
//           onData = data;
//         });
//         await tester.pump();
//         expect(find.text(('onWaiting')), findsOneWidget);
//         expect(onData, isNull);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('1'), findsOneWidget);
//         expect(onData, equals(1));

//         //sync increment with error
//         modelRM.setState(
//           (_) async {
//             final model = VanillaModel();
//             await model.incrementAsyncWithError();
//             return model.counter;
//           },
//           catchError: true,
//         );
//         await tester.pump();
//         expect(find.text(('onWaiting')), findsOneWidget);

//         await tester.pump(Duration(seconds: 1));
//         expect(find.text('Error message'), findsOneWidget);
//         expect(onData, equals(1));
//       },
//     );

//     testWidgets(
//       'ReactiveModel : join singleton to new reactive from setValue',
//       (tester) async {
//         final inject = Inject(() => VanillaModel());
//         final modelRM0 = inject.getReactive();
//         final modelRM1 = inject.getReactive(true);
//         final modelRM2 = inject.getReactive(true);

//         final widget = Column(
//           children: <Widget>[
//             StateBuilder(
//               observeMany: [() => modelRM0],
//               builder: (context, _) {
//                 return _widgetBuilder('modelRM0-${modelRM0.state.counter}');
//               },
//             ),
//             StateBuilder(
//               observeMany: [() => modelRM1],
//               builder: (context, _) {
//                 return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
//               },
//             ),
//             StateBuilder(
//               observeMany: [() => modelRM2],
//               builder: (context, _) {
//                 return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
//               },
//             )
//           ],
//         );

//         await tester.pumpWidget(widget);

//         //mutate reactive instance 1
//         modelRM1.setState(
//           (_) => modelRM1.state..incrementError(),
//           joinSingleton: true,
//           catchError: true,
//         );
//         await tester.pump();
//         expect(find.text('modelRM0-0'), findsOneWidget);
//         expect(find.text('modelRM1-0'), findsOneWidget);
//         expect(find.text('modelRM2-0'), findsOneWidget);
//         expect(modelRM0.hasError, isTrue);
//         expect(modelRM1.hasError, isTrue);
//         expect(modelRM2.isIdle, isTrue);

//         //mutate reactive instance 2
//         modelRM2.setState(
//           (_) => modelRM2.state..incrementError(),
//           joinSingleton: true,
//           catchError: true,
//         );
//         await tester.pump();
//         expect(find.text('modelRM0-0'), findsOneWidget);
//         expect(find.text('modelRM1-0'), findsOneWidget);
//         expect(find.text('modelRM2-0'), findsOneWidget);
//         expect(modelRM0.hasError, isTrue);
//         expect(modelRM1.hasError, isTrue);
//         expect(modelRM2.hasError, isTrue);

//         //mutate reactive instance 1
//         modelRM1.setState((_) {
//           modelRM1.state.increment();
//           return VanillaModel()..counter = modelRM1.state.counter;
//         }, joinSingleton: true);
//         await tester.pump();
//         expect(find.text('modelRM0-1'), findsOneWidget);
//         expect(find.text('modelRM1-1'), findsOneWidget);
//         expect(find.text('modelRM2-0'), findsOneWidget);
//         expect(modelRM0.hasData, isTrue);
//         expect(modelRM1.hasData, isTrue);
//         expect(modelRM2.hasError, isTrue);

//         //mutate reactive instance 2
//         modelRM2.setState((_) {
//           modelRM2.state.increment();
//           return VanillaModel()..counter = modelRM2.state.counter;
//         }, joinSingleton: true);
//         await tester.pump();
//         expect(find.text('modelRM0-2'), findsOneWidget);
//         expect(find.text('modelRM1-1'), findsOneWidget);
//         expect(find.text('modelRM2-2'), findsOneWidget);
//         expect(modelRM0.hasData, isTrue);
//         expect(modelRM1.hasData, isTrue);
//         expect(modelRM2.hasData, isTrue);
//       },
//     );
//   });

//   test(
//       'ReactiveModel: get new reactive model with the same seed returns the same instance',
//       () {
//     //get new reactive instance with the default seed
//     final modelNewRM1 = modelRM.asNew();

//     expect(modelNewRM1, isA<ReactiveModel>());
//     expect(modelRM != modelNewRM1, isTrue);
//     ////get another new reactive instance with the default seed
//     final modelNewRM2 = modelRM.asNew();
//     expect(modelNewRM2, isA<ReactiveModel>());
//     expect(modelNewRM2 == modelNewRM1, isTrue);

//     //get new reactive instance with the custom seed
//     final modelNewRM3 = modelRM.asNew(Seeds.seed1);

//     expect(modelNewRM3, isA<ReactiveModel>());
//     expect(modelNewRM3 != modelNewRM1, isTrue);
//     ////get another new reactive instance with the default seed
//     final modelNewRM4 = modelRM.asNew(Seeds.seed1);
//     expect(modelNewRM4, isA<ReactiveModel>());
//     expect(modelNewRM4 == modelNewRM3, isTrue);
//   });

//   test('ReactiveModel: get new reactive instance always return', () {
//     final modelNewRM1 = modelRM.asNew();
//     final modelNewRM2 = modelNewRM1.asNew();
//     expect(modelNewRM1 == modelNewRM2, isTrue);
//   });

//   test('ReactiveModel: ReactiveModel.create works ', () {
//     final _modelRM = ReactiveModel.create(1)..listenToRM((rm) {});
//     expect(_modelRM, isA<ReactiveModel>());
//     _modelRM.setState((_) => _modelRM.state + 1);
//     expect(_modelRM.state, equals(2));
//   });

//   testWidgets(
//     'ReactiveModel : reactive singleton and reactive instances work with seed',
//     (tester) async {
//       final inject = Inject(() => VanillaModel());
//       final modelRM0 = inject.getReactive();
//       final modelRM1 = modelRM0.asNew(Seeds.seed1);
//       final modelRM2 = modelRM1.asNew(Seeds.seed2);

//       final widget = Column(
//         children: <Widget>[
//           StateBuilder(
//             observeMany: [() => modelRM0],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM0-${modelRM0.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM1],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
//             },
//           ),
//           StateBuilder(
//             observeMany: [() => modelRM2],
//             builder: (context, _) {
//               return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
//             },
//           )
//         ],
//       );

//       await tester.pumpWidget(widget);

//       //
//       modelRM0.setState((s) => s.increment(), seeds: [Seeds.seed1]);
//       await tester.pump();
//       expect(find.text('modelRM0-1'), findsOneWidget);
//       expect(find.text('modelRM1-1'), findsOneWidget);
//       expect(find.text('modelRM2-0'), findsOneWidget);

//       //
//       modelRM0.setState((s) => s.increment(),
//           seeds: [Seeds.seed1, Seeds.seed2, 'nonExistingSeed']);
//       await tester.pump();
//       expect(find.text('modelRM0-2'), findsOneWidget);
//       expect(find.text('modelRM1-2'), findsOneWidget);
//       expect(find.text('modelRM2-2'), findsOneWidget);

//       //
//       modelRM0.setState((s) => s.increment(), notifyAllReactiveInstances: true);
//       await tester.pump();
//       expect(find.text('modelRM0-3'), findsOneWidget);
//       expect(find.text('modelRM1-3'), findsOneWidget);
//       expect(find.text('modelRM2-3'), findsOneWidget);
//     },
//   );

//   test('ReactiveStatesRebuilder throws if inject is null ', () {
//     expect(() => ReactiveModelImp(null), throwsAssertionError);
//   });

//   testWidgets(
//     'ReactiveModel: issue #49 reset to Idle after error or data',
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
//       modelRM.setState((s) => s.incrementError(), catchError: true);
//       await tester.pump();
//       expect(find.text(('Error message')), findsOneWidget);
//       expect(modelRM.isIdle, isFalse);
//       expect(modelRM.hasError, isTrue);
//       expect(modelRM.hasData, isFalse);
//       //reset to Idle
//       modelRM.resetToIdle();
//       modelRM.rebuildStates();
//       await tester.pump();
//       expect(modelRM.isIdle, isTrue);
//       expect(modelRM.hasError, isFalse);
//       expect(modelRM.hasData, isFalse);
//       expect(find.text(('Error message')), findsNothing);
//     },
//   );

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
//       modelRM.setState((s) => s.incrementError(), catchError: true);
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
//         catchError: true,
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

//   testWidgets(
//     'testing toString override',
//     (tester) async {
//       final modelRM = ReactiveModel.create(VanillaModel())..listenToRM((rm) {});
//       //
//       expect(modelRM.toString(), contains('RM<VanillaModel>'));
//       expect(modelRM.toString(), contains('RM<VanillaModel>-[isIdle] |'));
//       //
//       modelRM.setState((s) => s.incrementAsync());

//       expect(modelRM.toString(), contains('RM<VanillaModel>-[isWaiting]'));
//       await tester.pump(Duration(seconds: 1));
//       expect(modelRM.toString(), contains(" | state: (Counter(1))"));

//       //
//       modelRM.setState((s) => s.incrementAsyncWithError(), catchError: true);
//       await tester.pump(Duration(seconds: 1));
//       expect(modelRM.toString(), contains('RM<VanillaModel>-[hasError] '));

//       //

//       expect('${modelRM.asNew('seed1')}',
//           contains('(seed: "seed1") new RM<VanillaModel>'));
//       expect(
//           '${modelRM.asNew('seed1')}',
//           contains(
//               'new RM<VanillaModel>-[isIdle] | Observers(0 widgets, 0 models) |'));

//       final intStream = ReactiveModel.stream(getStream());
//       expect(intStream.toString(), contains('RM<Stream<int>>'));
//       expect(intStream.toString(), contains('RM<Stream<int>>-[isWaiting] '));
//       await tester.pump(Duration(seconds: 3));
//       expect(intStream.toString(), contains('RM<Stream<int>>-[hasData] '));

//       // final intFuture = ReactiveModel.future(getFuture()).asNew();
//       // expect(intFuture.toString(),
//       //     contains('Future of <int> RM (new seed: "defaultReactiveSeed")'));
//       // expect(intFuture.toString(), contains('| isWaiting'));
//       // await tester.pump(Duration(seconds: 3));
//       // expect(intFuture.toString(), contains('| hasData : (1)'));
//     },
//   );

//   testWidgets(
//     'ReactiveModel : global ReactiveModel error handling',
//     (tester) async {
//       ReactiveModel<VanillaModel> modelRM = RM.create(VanillaModel());
//       String errorMessage;
//       final widget = Column(
//         children: <Widget>[
//           StateBuilder<VanillaModel>(
//             observe: () => modelRM
//               ..onError((context, error) {
//                 errorMessage = error.message;
//               }),
//             builder: (context, modelRM) {
//               return _widgetBuilder('${modelRM.state.counter}');
//             },
//           )
//         ],
//       );

//       await tester.pumpWidget(widget);
//       modelRM.setState((s) => s.incrementAsyncWithError());
//       expect(find.text('0'), findsOneWidget);
//       expect(modelRM.isWaiting, isTrue);
//       expect(errorMessage, isNull);

//       await tester.pump(Duration(seconds: 1));
//       expect(find.text('0'), findsOneWidget);
//       expect(modelRM.hasError, isTrue);
//       expect(errorMessage, 'Error message');
//     },
//   );

//   testWidgets(
//     'ReactiveModel : error from setState is prioritized on the  global ReactiveModel error',
//     (tester) async {
//       ReactiveModel<VanillaModel> modelRM = RM.create(VanillaModel());
//       String globalErrorMessage;
//       String setStateErrorMessage;
//       final widget = Column(
//         children: <Widget>[
//           StateBuilder<VanillaModel>(
//             observe: () => modelRM
//               ..onError((context, error) {
//                 globalErrorMessage = error.message;
//               }),
//             builder: (context, modelRM) {
//               return _widgetBuilder('${modelRM.state.counter}');
//             },
//           )
//         ],
//       );

//       await tester.pumpWidget(widget);
//       modelRM.setState(
//         (s) => s.incrementAsyncWithError(),
//         onError: (_, error) {
//           setStateErrorMessage = error.message;
//         },
//       );
//       expect(find.text('0'), findsOneWidget);
//       expect(modelRM.isWaiting, isTrue);

//       await tester.pump(Duration(seconds: 1));
//       expect(find.text('0'), findsOneWidget);
//       expect(modelRM.hasError, isTrue);
//       expect(setStateErrorMessage, 'Error message');
//       expect(globalErrorMessage, isNull);
//     },
//   );

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

//   test('listen to RM and unsubscribe', () {
//     final rm = RM.create(0);
//     int data;
//     final unsubscribe = rm.listenToRM((rm) {
//       data = rm.state;
//     });
//     expect(data, isNull);
//     expect(rm.observers().length, 0);
//     rm.state++;
//     expect(data, 1);
//     unsubscribe();
//     expect(rm.observers().length, 0);
//   });

  testWidgets('debounce positive should work', (tester) async {
    final rm = ReactiveModelImp(creator: (_) => 0, nullState: 0);

    rm.subscribeToRM((rm) {});

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
    final rm = ReactiveModelImp(creator: (_) => 0, nullState: 0);

    rm.subscribeToRM((rm) {});

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

//   testWidgets('ReactiveModel.refresh', (tester) async {
//     final rm = RM.create(0);

//     final widget = StateBuilder<int>(
//       observe: () => rm,
//       builder: (_, rm) {
//         return Text('${rm.state}');
//       },
//     );

//     await tester.pumpWidget(MaterialApp(home: widget));
//     expect(find.text('0'), findsOneWidget);
//     rm.state++;
//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);
//     await rm.refresh();

//     await tester.pump();
//     expect(find.text('0'), findsOneWidget);
//     expect(rm.isIdle, isTrue);
//   });

//   testWidgets('ReactiveModel.refresh stream', (tester) async {
//     final rm = RM.create(VanillaModel()).stream(
//           (m, _) => getStream(),
//           initialValue: 0,
//         );

//     final widget = WhenRebuilderOr(
//       observe: () => rm,
//       onWaiting: () => Text('waiting ...'),
//       builder: (_, rm) {
//         return Text('${rm.state}');
//       },
//     );

//     await tester.pumpWidget(MaterialApp(home: widget));

//     expect(find.text('waiting ...'), findsOneWidget);

//     await tester.pump(Duration(seconds: 1));
//     expect(find.text('0'), findsOneWidget);

//     await tester.pump(Duration(seconds: 1));
//     expect(find.text('1'), findsOneWidget);
//     rm.refresh();
//     await tester.pump();
//     await tester.pump(Duration(seconds: 1));

//     expect(find.text('0'), findsOneWidget);
//     await tester.pump(Duration(seconds: 1));
//     expect(find.text('1'), findsOneWidget);
//   });

//   testWidgets('ReactiveModel.refresh future', (tester) async {
//     final rm = RM.create(VanillaModel()).future((m, _) => m.incrementAsync());

//     final widget = WhenRebuilderOr(
//       observe: () => rm,
//       onWaiting: () => Text('waiting ...'),
//       builder: (_, rm) {
//         return Text('data');
//       },
//     );

//     await tester.pumpWidget(MaterialApp(home: widget));
//     expect(find.text('waiting ...'), findsOneWidget);
//     await tester.pump(Duration(seconds: 1));
//     expect(find.text('data'), findsOneWidget);

//     rm.refresh();
//     await tester.pump();
//     expect(find.text('waiting ...'), findsOneWidget);
//     await tester.pump(Duration(seconds: 1));
//     expect(find.text('data'), findsOneWidget);
//   });

//   testWidgets('subscription using context', (tester) async {
//     ReactiveModel<VanillaModel> rm;
//     final widget = Injector(
//         inject: [Inject(() => VanillaModel())],
//         builder: (context) {
//           rm = RM.get<VanillaModel>(context: context);
//           return Text(rm.state.counter.toString());
//         });

//     await tester.pumpWidget(
//         Directionality(textDirection: TextDirection.ltr, child: widget));

//     expect(find.text('0'), findsOneWidget);
//     //
//     rm.setState((s) => s.increment());
//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);
//     //
//   });

//   testWidgets(
//       'automatically remove context from subscription set if it is not mounted',
//       (tester) async {
//     ReactiveModel<VanillaModel> rm;
//     ReactiveModel<bool> switcherRM = RM.create(true);
//     final widget = Injector(
//         inject: [Inject(() => VanillaModel())],
//         builder: (context) {
//           return StateBuilder(
//             observe: () => switcherRM,
//             builder: (_, __) {
//               return Column(
//                 children: <Widget>[
//                   if (switcherRM.state)
//                     Builder(builder: (
//                       context,
//                     ) {
//                       rm = RM.get<VanillaModel>(context: context);
//                       return Text(rm.state.counter.toString());
//                     }),
//                   if (!switcherRM.state) Text('NAN'),
//                 ],
//               );
//             },
//           );
//         });

//     await tester.pumpWidget(
//         Directionality(textDirection: TextDirection.ltr, child: widget));

//     expect(find.text('0'), findsOneWidget);
//     //
//     rm.setState((s) => s.increment());
//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);
//     //
//     switcherRM.state = false;
//     await tester.pump();
//     expect(find.text('NAN'), findsOneWidget);
//     await tester.pump();
//     expect(() => rm.setState((s) => s.increment()), throwsException);
//   });

//   testWidgets('whenConnection state with context subscription works',
//       (tester) async {
//     ReactiveModel<VanillaModel> rm;
//     final widget = Injector(
//       inject: [Inject(() => VanillaModel())],
//       builder: (context) {
//         rm = RM.get<VanillaModel>(context: context);
//         return rm.whenConnectionState(
//           onIdle: () => Text('idle'),
//           onWaiting: () => Text('waiting'),
//           onError: (e) => Text('${e.message}'),
//           onData: (d) => Text(d.counter.toString()),
//         );
//       },
//     );

//     await tester.pumpWidget(
//         Directionality(textDirection: TextDirection.ltr, child: widget));

//     expect(find.text('idle'), findsOneWidget);
//     //
//     rm.setState((s) => s.incrementAsyncWithError());
//     await tester.pump();
//     expect(find.text('waiting'), findsOneWidget);
//     await tester.pump(Duration(seconds: 1));
//     expect(find.text('Error message'), findsOneWidget);
//     //
//     rm.setState((s) => s.incrementAsync());
//     await tester.pump();
//     expect(find.text('waiting'), findsOneWidget);
//     await tester.pump(Duration(seconds: 1));
//     expect(find.text('1'), findsOneWidget);
//     //
//   });

  testWidgets('skip waiting works', (tester) async {
    String? result;
    modelRM?.subscribeToRM((rm) {
      result = rm.whenConnectionState(
        onIdle: () => 'idle',
        onWaiting: () => 'waiting',
        onError: (e) => '${e.message}',
        onData: (d) => d.counter.toString(),
      );
    });

    //
    modelRM?.setState((s) => s.incrementAsync(), skipWaiting: true);
    await tester.pump();
    expect(modelRM?.isIdle, true);

    await tester.pump(Duration(seconds: 1));
    expect(result, '1');

    //
    modelRM?.setState((s) => s.incrementAsync(), skipWaiting: true);
    await tester.pump();
    expect(result, '1');

    await tester.pump(Duration(seconds: 1));
    expect(result, '2');
    //
  });

//   testWidgets('refresh a reactive model', (tester) async {
//     int x = 0;
//     ReactiveModel<int> rm = RM.createFromCallback(() => x);
//     final widget = StateBuilder(
//       observe: () => rm,
//       builder: (_, __) {
//         return Text(rm.state.toString());
//       },
//     );

//     await tester.pumpWidget(
//         Directionality(textDirection: TextDirection.ltr, child: widget));

//     expect(find.text('0'), findsOneWidget);
//     //
//     x = 1;
//     rm.refresh();
//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);
//   });

//   testWidgets('do and undo state', (tester) async {
//     ReactiveModel<int> rm = RM.create(0)..undoStackLength = 8;
//     final widget = StateBuilder(
//       observe: () => rm,
//       builder: (_, __) {
//         return Text(rm.state.toString());
//       },
//     );

//     await tester.pumpWidget(
//         Directionality(textDirection: TextDirection.ltr, child: widget));

//     expect(find.text('0'), findsOneWidget);
//     //
//     rm.state = 1;

//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);

//     rm.state = 2;

//     await tester.pump();
//     expect(find.text('2'), findsOneWidget);
//     //undo
//     rm.undoState();
//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);

//     rm.undoState();
//     await tester.pump();
//     expect(find.text('0'), findsOneWidget);

//     //redo
//     rm.redoState();
//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);

//     rm.redoState();
//     await tester.pump();
//     expect(find.text('2'), findsOneWidget);

//     //
//     //undo
//     rm.undoState();
//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);

//     rm.undoState();
//     await tester.pump();
//     expect(find.text('0'), findsOneWidget);
//     //redo
//     rm.redoState();
//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);
//     rm.redoState();
//     await tester.pump();
//     expect(find.text('2'), findsOneWidget);
//     //undo
//     rm.undoState();
//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);
//     //redo
//     rm.redoState();
//     await tester.pump();
//     expect(find.text('2'), findsOneWidget);
//     //undo
//     rm.undoState();
//     await tester.pump();
//     expect(find.text('1'), findsOneWidget);
//     //
//     rm.state = 2;
//     await tester.pump();
//     expect(find.text('2'), findsOneWidget);
//     expect(rm.canRedoState, false);
//   });
//   testWidgets(
//       'onData of immutable is  called when state not changed after waiting',
//       (tester) async {
//     int numberOfRebuild = 0;
//     int numberOfOnData = 0;
//     final counter = RM.inject(
//       () => 0,
//       onData: (_) => numberOfOnData++,
//     );
//     final widget = counter.whenRebuilderOr(builder: () {
//       numberOfRebuild++;
//       return Container();
//     });

//     await tester.pumpWidget(widget);
//     expect(numberOfRebuild, 1);
//     expect(numberOfOnData, 0);

//     counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 0));
//     await tester.pump();
//     expect(numberOfRebuild, 2);
//     expect(numberOfOnData, 0);
//     await tester.pump(Duration(seconds: 1));
//     expect(numberOfRebuild, 3);
//     expect(numberOfOnData, 1);
//     //
//     counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 1));
//     await tester.pump();
//     expect(numberOfRebuild, 4);
//     expect(numberOfOnData, 1);
//     await tester.pump(Duration(seconds: 1));
//     expect(numberOfRebuild, 5);
//     expect(numberOfOnData, 2);
//     //
//     counter.setState((s) => Future.delayed(Duration(seconds: 1), () => 1));
//     await tester.pump();
//     expect(numberOfRebuild, 6);
//     expect(numberOfOnData, 2);
//     await tester.pump(Duration(seconds: 1));
//     expect(numberOfRebuild, 7);
//     expect(numberOfOnData, 3);
//   });
}

// class ImmutableModel {
//   final int counter;

//   ImmutableModel(this.counter);

//   Stream<ImmutableModel> incrementStream() async* {
//     await Future.delayed(Duration(seconds: 1));
//     yield ImmutableModel(counter + 1);
//     await Future.delayed(Duration(seconds: 1));
//     yield ImmutableModel(counter + 2);
//     await Future.delayed(Duration(seconds: 1));
//     yield this;
//     throw Exception('Error message');
//   }
// }

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

// enum Seeds { seed1, seed2 }
