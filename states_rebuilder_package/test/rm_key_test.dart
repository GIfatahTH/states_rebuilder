import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/src/rm_key.dart';
import 'package:states_rebuilder/src/state_builder.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';
import 'package:states_rebuilder/src/when_connection_state.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  ModelSR model;
  ReactiveModel<Model> modelRM;

  setUp(() {
    model = ModelSR();
    final inject = Inject(() => Model());
    modelRM = inject.getReactive();
  });

  testWidgets(
    'StateBuilder should get the right exposed model',
    (tester) async {
      bool switcher = true;

      ReactiveModel<int> intRM = ReactiveModel.create(0);
      ReactiveModel<String> stringRM = ReactiveModel.create('');
      ReactiveModel rmFromInitState;
      ReactiveModel rmFromDispose;
      RMKey<String> rmKey;
      final widget = StateBuilder(
        observe: () => model,
        tag: ['mainTag'],
        builder: (ctx, _) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                rmKey = RMKey();
                if (switcher) {
                  return StateBuilder(
                    observeMany: [() => stringRM, () => intRM],
                    rmKey: rmKey,
                    initState: (_, rm) {
                      rmFromInitState = rm;
                    },
                    dispose: (_, rm) {
                      rmFromDispose = rm;
                    },
                    builder: (context, _) {
                      return Text('${model.counter}');
                    },
                  );
                }
                return Text('false');
              },
            ),
          );
        },
      );

      await tester.pumpWidget(widget);
      rmKey.value = '';
      expect(rmFromInitState, equals(stringRM));
      expect(rmKey.hasObservers, isTrue);
      expect(rmKey.observers().length, 1);
      rmKey.setValue(() => '1');
      await tester.pump();
      bool isCleaned = false;
      rmKey.cleaner(() {
        isCleaned = true;
      });
      switcher = false;
      model.rebuildStates(['mainTag']);
      rmKey.rebuildStates();
      await tester.pump();
      expect(rmFromDispose, equals(stringRM));
      expect(isCleaned, isTrue);
    },
  );

  testWidgets(
    'ReactiveModel : ReactiveModel.stream works',
    (tester) async {
      RMKey<int> modelRM0 = RMKey();

      final widget = Column(
        children: <Widget>[
          StateBuilder(
            observe: () => RM.stream(getStream(), initialValue: 0),
            rmKey: modelRM0,
            builder: (context, _) {
              return _widgetBuilder('${modelRM0.state}');
            },
          )
        ],
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      expect(modelRM0.isWaiting, isTrue);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(modelRM0.hasData, isTrue);
      expect(modelRM0.isA<Stream<int>>(), isTrue);
      expect(RM.notified.isA<Stream<int>>(), isTrue);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsOneWidget);
      expect(modelRM0.hasData, isTrue);

      await tester.pump(Duration(seconds: 1));

      expect(find.text('2'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsOneWidget);
      modelRM0.subscription.cancel();
      modelRM0.unsubscribe(null);
      expect(modelRM0.isStreamDone, isNull);
    },
  );

  testWidgets(
    "StateBuilder creates and expose new reactive instance",
    (WidgetTester tester) async {
      RMKey<int> reactiveModel1 = RMKey();
      RMKey<int> reactiveModel2 = RMKey();
      final widget = Injector(
        inject: [Inject(() => 2)],
        builder: (_) {
          return Column(
            children: <Widget>[
              StateBuilder<int>(
                rmKey: reactiveModel1,
                builder: (_, rm) {
                  return Container();
                },
              ),
              StateBuilder<int>(
                rmKey: reactiveModel2,
                builder: (_, rm) {
                  return Container();
                },
              ),
            ],
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(reactiveModel1, isA<ReactiveModel<int>>());
      expect(reactiveModel2, isA<ReactiveModel<int>>());
      expect(reactiveModel1 != reactiveModel2, isTrue);
    },
  );

  testWidgets(
      "StateBuilder should work with ReactiveModel.create when widget is updated",
      (WidgetTester tester) async {
    RMKey<int> modelRM1 = RMKey();
    RMKey<int> modelRM2;

    final widget = Builder(
      builder: (context) {
        return MaterialApp(
          home: Column(
            children: <Widget>[
              StateBuilder(
                  observe: () => ReactiveModel.create(0),
                  rmKey: modelRM1,
                  builder: (_, __) {
                    return Column(
                      children: <Widget>[
                        Text('modelRM1-${modelRM1.value}'),
                        Builder(
                          builder: (context) {
                            modelRM2 = RMKey();
                            return StateBuilder<int>(
                                observe: () => ReactiveModel.create(0),
                                rmKey: modelRM2,
                                builder: (_, rm) {
                                  return Text('modelRM2-${modelRM2.value}');
                                });
                          },
                        ),
                      ],
                    );
                  }),
            ],
          ),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(find.text('modelRM1-0'), findsOneWidget);
    expect(find.text('modelRM2-0'), findsOneWidget);
    //
    modelRM2.value = 1;
    await tester.pump();
    expect(find.text('modelRM1-0'), findsOneWidget);
    expect(find.text('modelRM2-1'), findsOneWidget);
    expect(modelRM2.hasData, isTrue);

    modelRM1.value = 1;
    await tester.pump();
    expect(find.text('modelRM1-1'), findsOneWidget);
    expect(find.text('modelRM2-1'), findsOneWidget);
    expect(modelRM2.hasData, isTrue);

    modelRM2.value++;
    await tester.pump();
    expect(find.text('modelRM1-1'), findsOneWidget);
    expect(find.text('modelRM2-2'), findsOneWidget);
  });

  testWidgets("StateBuilder should work with RMKey, Key subscription first",
      (WidgetTester tester) async {
    RMKey<int> rmKey = RMKey();

    final widget = Builder(
      builder: (context) {
        return MaterialApp(
          home: Column(
            children: <Widget>[
              StateBuilder(
                  observe: () => ReactiveModel.create(0),
                  rmKey: rmKey,
                  builder: (_, rm) {
                    return Column(
                      children: <Widget>[Text('modelRM1-${rmKey.value}')],
                    );
                  }),
              Builder(
                builder: (context) {
                  return StateBuilder<int>(
                      observe: () => rmKey,
                      builder: (_, rm) {
                        return Text('modelRM2-${rm.value}');
                      });
                },
              ),
            ],
          ),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(find.text('modelRM1-0'), findsOneWidget);
    expect(find.text('modelRM2-0'), findsOneWidget);
    //
    rmKey.setValue(() => 1);
    await tester.pump();
    expect(find.text('modelRM1-1'), findsOneWidget);
    expect(find.text('modelRM2-1'), findsOneWidget);
    expect(rmKey.hasData, isTrue);

    rmKey.setValue(() => 2);
    await tester.pump();
    expect(find.text('modelRM1-2'), findsOneWidget);
    expect(find.text('modelRM2-2'), findsOneWidget);
    expect(rmKey.hasData, isTrue);
    rmKey.refresh();
    await tester.pump();
    expect(find.text('modelRM1-0'), findsOneWidget);
    expect(find.text('modelRM2-0'), findsOneWidget);
  });

  testWidgets("StateBuilder should work with RMKey, Key subscription last",
      (WidgetTester tester) async {
    RMKey<int> rmKey = RMKey();

    final widget = Builder(
      builder: (context) {
        return MaterialApp(
          home: Column(
            children: <Widget>[
              StateBuilder(
                  observe: () => rmKey,
                  builder: (_, rm) {
                    return Column(
                      children: <Widget>[Text('modelRM1-${rm.value}')],
                    );
                  }),
              Builder(
                builder: (context) {
                  return StateBuilder<int>(
                      observe: () => ReactiveModel.create(0),
                      rmKey: rmKey,
                      builder: (_, rm) {
                        return Text('modelRM2-${rm.value}');
                      });
                },
              ),
            ],
          ),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(find.text('modelRM1-null'), findsOneWidget);
    expect(find.text('modelRM2-0'), findsOneWidget);
    await tester.pump();
    expect(find.text('modelRM1-0'), findsOneWidget);
    expect(find.text('modelRM2-0'), findsOneWidget);

    rmKey.setValue(() => 1);
    await tester.pump();
    expect(find.text('modelRM1-1'), findsOneWidget);
    expect(find.text('modelRM2-1'), findsOneWidget);
    expect(rmKey.hasData, isTrue);

    rmKey.setValue(() => 2);
    await tester.pump();
    expect(find.text('modelRM1-2'), findsOneWidget);
    expect(find.text('modelRM2-2'), findsOneWidget);
    expect(rmKey.hasData, isTrue);
    rmKey.refresh();
    await tester.pump();
    expect(find.text('modelRM1-0'), findsOneWidget);
    expect(find.text('modelRM2-0'), findsOneWidget);
  });

  testWidgets(
    'ReactiveModel: call async method with error and notify observers',
    (tester) async {
      final rmKey = RMKey<Model>();
      final widget = StateBuilder(
        models: [modelRM],
        rmKey: rmKey,
        builder: (_, __) {
          return WhenRebuilder(
            observe: () => rmKey,
            onIdle: () => Text('onIdle'),
            onWaiting: () => Text('onWaiting'),
            onError: (e) => Text(e.message),
            onData: (d) => Text(d.counter),
          );
        },
      );
      await tester.pumpWidget(MaterialApp(home: widget));
      //isIdle
      expect(find.text('onIdle'), findsOneWidget);
      expect(rmKey.isIdle, isTrue);
      expect(rmKey.isNewReactiveInstance, false);

      rmKey.setState((s) => s.incrementAsyncError(), catchError: true);
      //isWaiting
      await tester.pump();
      expect(find.text('onWaiting'), findsOneWidget);
      expect(RM.notified.isWaiting, isTrue);
      expect(rmKey.isWaiting, isTrue);

      //hasError
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Error message'), findsOneWidget);
      expect(rmKey.error.message, 'Error message');
      expect(rmKey.hasError, isTrue);
      expect(RM.notified.hasError, isTrue);
    },
  );

  testWidgets(
    'ReactiveModel: whenConnectionState should work',
    (tester) async {
      final rmKey = RMKey<Model>();

      final widget = WhenRebuilder(
        observe: () => modelRM,
        rmKey: rmKey,
        onIdle: () => _widgetBuilder('onIdle'),
        onWaiting: () => _widgetBuilder('onWaiting'),
        onData: (data) => _widgetBuilder('${data.counter}'),
        onError: (error) => _widgetBuilder('${error.message}'),
      );
      await tester.pumpWidget(widget);
      //isIdle
      expect(find.text('onIdle'), findsOneWidget);

      rmKey.setState((s) => s.incrementAsync());
      await tester.pump();
      //isWaiting
      expect(find.text('onWaiting'), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      //hasData
      expect(find.text('1'), findsOneWidget);

      //throw error
      rmKey.setState((s) => s.incrementAsyncError());
      await tester.pump();
      //isWaiting
      expect(find.text('onWaiting'), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      //hasError
      expect(find.text('Error message'), findsOneWidget);

      //throw error
      rmKey.setState((s) => s.incrementAsyncError());
      await tester.pump();
      //isWaiting
      expect(find.text('onWaiting'), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      //hasError
      expect(find.text('Error message'), findsOneWidget);
    },
  );

  testWidgets(
    'ReactiveModel : new reactive notify reactive singleton with its state if joinSingleton = withNewReactiveInstance',
    (tester) async {
      final inject = Inject(
        () => Model(),
        joinSingleton: JoinSingleton.withNewReactiveInstance,
      );
      final modelRM2 = RMKey();
      final modelRM1 = RMKey();
      final modelRM0 = RMKey();
      final widget = Column(
        children: <Widget>[
          StateBuilder(
            models: [inject.getReactive()],
            rmKey: modelRM0,
            builder: (context, _) {
              return _widgetBuilder('modelRM0-${modelRM0.state.counter}');
            },
          ),
          StateBuilder(
            models: [inject.getReactive(true)],
            rmKey: modelRM1,
            builder: (context, _) {
              return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
            },
          ),
          StateBuilder(
            models: [inject.getReactive(true)],
            rmKey: modelRM2,
            builder: (context, _) {
              return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
            },
          )
        ],
      );

      await tester.pumpWidget(widget);

      //mutate reactive instance 1
      modelRM1.setState((s) => s.increment());
      await tester.pump();

      expect(find.text('modelRM0-1'), findsOneWidget);
      expect(find.text('modelRM1-1'), findsOneWidget);
      expect(find.text('modelRM2-0'), findsOneWidget);

      //mutate reactive instance 1
      modelRM2.setState((s) => s.increment());
      await tester.pump();
      expect(find.text('modelRM0-2'), findsOneWidget);
      expect(find.text('modelRM1-1'), findsOneWidget);
      expect(find.text('modelRM2-2'), findsOneWidget);
    },
  );

  testWidgets(
    'ReactiveModel: reset to hasData',
    (tester) async {
      RMKey rmKey = RMKey();
      final widget = StateBuilder(
        models: [modelRM],
        rmKey: rmKey,
        builder: (_, __) {
          return _widgetBuilder(
            '${rmKey.state.counter}',
            '${rmKey.error?.message}',
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(find.text(('Error message')), findsNothing);
      //
      rmKey.setState((s) => s.incrementError(), catchError: true);
      await tester.pump();
      expect(find.text(('Error message')), findsOneWidget);
      expect(rmKey.isIdle, isFalse);
      expect(rmKey.hasError, isTrue);
      expect(rmKey.hasData, isFalse);
      //reset to Idle
      rmKey.resetToHasData();
      rmKey.rebuildStates();
      await tester.pump();
      expect(rmKey.isIdle, isFalse);
      expect(rmKey.hasError, isFalse);
      expect(rmKey.hasData, isTrue);
      expect(find.text(('Error message')), findsNothing);
    },
  );

  testWidgets(
    'ReactiveModel: issue #49 reset to Idle after error or data',
    (tester) async {
      RMKey rmKey = RMKey();

      final widget = StateBuilder(
        models: [modelRM],
        rmKey: rmKey,
        builder: (_, __) {
          return _widgetBuilder(
            '${rmKey.state.counter}',
            '${rmKey.error?.message}',
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(find.text(('Error message')), findsNothing);
      expect(rmKey.connectionState, ConnectionState.none);

      //
      rmKey.setState((s) => s.incrementError(), catchError: true);
      await tester.pump();
      expect(find.text(('Error message')), findsOneWidget);
      expect(rmKey.isIdle, isFalse);
      expect(rmKey.connectionState, ConnectionState.done);
      expect(rmKey.hasData, isFalse);
      //reset to Idle
      rmKey.resetToIdle();
      rmKey.rebuildStates();
      await tester.pump();
      expect(rmKey.isIdle, isTrue);
      expect(rmKey.hasError, isFalse);
      expect(rmKey.hasData, isFalse);
      expect(find.text(('Error message')), findsNothing);
    },
  );

  testWidgets(
    'seeds works',
    (tester) async {
      RMKey rmKey = RMKey();
      ReactiveModel<int> modelRM1;

      final widget = Column(
        children: <Widget>[
          StateBuilder(
            observe: () => ReactiveModel.create(0),
            rmKey: rmKey,
            builder: (context, __) {
              return _widgetBuilder('model0-${rmKey.value}');
            },
          ),
          StateBuilder(
            observe: () => rmKey.asNew('seed1'),
            builder: (context, rm) {
              modelRM1 = rm;
              return _widgetBuilder('model1-${modelRM1.value}');
            },
          )
        ],
      );
      await tester.pumpWidget(widget);
      rmKey.setValue(() => rmKey.value + 1);
      await tester.pump();
      expect(find.text(('model0-1')), findsOneWidget);
      expect(find.text(('model1-0')), findsOneWidget);
      //
      rmKey.setValue(() => rmKey.value + 1, seeds: ['seed1']);
      await tester.pump();
      expect(find.text(('model0-2')), findsOneWidget);
      expect(find.text(('model1-2')), findsOneWidget);
      //
      modelRM1.setValue(() {
        return modelRM1.value + 1;
      });
      await tester.pump();
      expect(find.text(('model0-2')), findsOneWidget);
      expect(find.text(('model1-3')), findsOneWidget);
      //
      modelRM1.setValue(
        () {
          return modelRM1.value + 1;
        },
        notifyAllReactiveInstances: true,
      );
      await tester.pump();
      expect(find.text(('model0-4')), findsOneWidget);
      expect(find.text(('model1-4')), findsOneWidget);
    },
  );

  testWidgets(
    'ReactiveModel : join singleton to new reactive from setState with data send using joinSingletonToNewData',
    (tester) async {
      final inject = Inject(() => Model());
      RMKey modelRM0 = RMKey();
      final modelRM1 = RMKey();
      final modelRM2 = RMKey();

      final widget = Column(
        children: <Widget>[
          StateBuilder(
            models: [inject.getReactive()],
            rmKey: modelRM0,
            builder: (context, _) {
              return _widgetBuilder(
                  'modelRM0-${modelRM0.joinSingletonToNewData}');
            },
          ),
          StateBuilder(
            models: [inject.getReactive(true)],
            rmKey: modelRM1,
            builder: (context, _) {
              return _widgetBuilder('modelRM1-${modelRM1.state.counter}');
            },
          ),
          StateBuilder(
            models: [inject.getReactive(true)],
            rmKey: modelRM2,
            builder: (context, _) {
              return _widgetBuilder('modelRM2-${modelRM2.state.counter}');
            },
          )
        ],
      );

      await tester.pumpWidget(widget);

      //mutate reactive instance 1
      modelRM1.setState((s) => s.increment(),
          joinSingleton: true,
          catchError: true,
          joinSingletonToNewData: () => 'modelRM1-${modelRM1.state.counter}');
      await tester.pump();
      expect(find.text('modelRM0-modelRM1-1'), findsOneWidget);
      expect(find.text('modelRM1-1'), findsOneWidget);
      expect(find.text('modelRM2-0'), findsOneWidget);

      //mutate reactive instance 2
      modelRM2.setState((s) => s.increment(),
          joinSingleton: true,
          catchError: true,
          joinSingletonToNewData: () => 'modelRM2-${modelRM1.state.counter}');
      await tester.pump();
      expect(find.text('modelRM0-modelRM2-2'), findsOneWidget);
      expect(find.text('modelRM1-1'), findsOneWidget);
      expect(find.text('modelRM2-2'), findsOneWidget);
    },
  );

  testWidgets(
    'testing toString override',
    (tester) async {
      final modelRM = RMKey<Model>()
        ..rm = ReactiveModel.create(Model())
        ..subscribe((_) {});

      //
      expect(modelRM.toString(), contains('<Model> RM'));
      expect(modelRM.toString(), contains(' | isIdle'));
      //
      modelRM.setState((s) => s.incrementAsync());

      expect(modelRM.toString(), contains(' | isWaiting'));
      await tester.pump(Duration(seconds: 1));
      expect(
          modelRM.toString(), contains(" | hasData : (Instance of 'Model')"));

      //
      modelRM.setState((s) => s.incrementAsyncError());
      await tester.pump(Duration(seconds: 1));
      expect(modelRM.toString(),
          contains(' | hasError : (Exception: Error message)'));

      //
      expect('${modelRM.asNew('seed1')}',
          contains('<Model> RM (new seed: "seed1")'));
      expect('${modelRM.asNew('seed1')}', contains(' | isIdle'));

      final intStream = ReactiveModel.stream(getStream());
      expect(intStream.toString(), contains('Stream of <int> RM'));
      expect(intStream.toString(), contains('| isWaiting'));
      await tester.pump(Duration(seconds: 3));
      expect(intStream.toString(), contains('| hasData : (2)'));

      final intFuture = ReactiveModel.future(getFuture()).asNew();
      expect(intFuture.toString(),
          contains('Future of <int> RM (new seed: "defaultReactiveSeed")'));
      expect(intFuture.toString(), contains('| isWaiting'));
      await tester.pump(Duration(seconds: 3));
      expect(intFuture.toString(), contains('| hasData : (1)'));
    },
  );

  testWidgets("Nested StateBuilder ", (WidgetTester tester) async {
    RMKey<int> modelRM1 = RMKey(0);
    RMKey<int> modelRM2 = RMKey(0);

    final widget = Builder(
      builder: (context) {
        return MaterialApp(
          home: Column(
            children: <Widget>[
              StateBuilder(
                  observe: () => ReactiveModel.create(0),
                  rmKey: modelRM1,
                  builder: (_, __) {
                    return Column(
                      children: <Widget>[
                        Text('modelRM1-${modelRM1.value}'),
                        Builder(
                          builder: (context) {
                            return StateBuilder<int>(
                                observe: () => ReactiveModel.create(0),
                                rmKey: modelRM2,
                                builder: (_, rm) {
                                  return Text('modelRM2-${modelRM2.value}');
                                });
                          },
                        ),
                      ],
                    );
                  }),
            ],
          ),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(find.text('modelRM1-0'), findsOneWidget);
    expect(find.text('modelRM2-0'), findsOneWidget);
    //
    modelRM2.setValue(() => 1);
    await tester.pump();
    expect(find.text('modelRM1-0'), findsOneWidget);
    expect(find.text('modelRM2-1'), findsOneWidget);
    expect(modelRM2.hasData, isTrue);

    modelRM1.setValue(() => 1);
    await tester.pump();
    expect(find.text('modelRM1-1'), findsOneWidget);
    expect(find.text('modelRM2-1'), findsOneWidget);
    expect(modelRM2.hasData, isTrue);

    modelRM2.setValue(() => modelRM2.value + 1);
    await tester.pump();
    expect(find.text('modelRM1-1'), findsOneWidget);
    expect(find.text('modelRM2-2'), findsOneWidget);
  });

  testWidgets('refresh future', (tester) async {
    RMKey rmKey = RMKey();
    final widget = WhenRebuilderOr(
      observe: () => RM.future(Model().incrementAsync()),
      rmKey: rmKey,
      onWaiting: () => Text('waiting...'),
      builder: (_, rm) {
        return Text(rm.value.toString());
      },
    );
    await tester.pumpWidget(MaterialApp(home: widget));

    expect(find.text('waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
    rmKey.refresh();
    await tester.pump();
    expect(find.text('waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets(
    'ReactiveModel : future method works',
    (tester) async {
      RMKey<Model> modelRM = RMKey();
      String errorMessage;
      final widget = Column(
        children: <Widget>[
          StateBuilder<Model>(
            observe: () => RM.create(Model()),
            rmKey: modelRM,
            builder: (context, modelRM) {
              return _widgetBuilder('${modelRM.state.counter}');
            },
          )
        ],
      );
      await tester.pumpWidget(widget);
      modelRM.future((m) => m.incrementAsync()).onError((context, error) {
        errorMessage = error.message;
      });
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
    'ReactiveModel : stream method works',
    (tester) async {
      RMKey<Model> modelRM = RMKey();
      String errorMessage;
      final widget = Column(
        children: <Widget>[
          StateBuilder<Model>(
            observe: () => RM.create(Model()),
            rmKey: modelRM,
            builder: (context, modelRM) {
              return _widgetBuilder('${modelRM.state.counter}');
            },
          )
        ],
      );
      await tester.pumpWidget(widget);
      modelRM.stream((m) => m.incrementStream()).onError((context, error) {
        errorMessage = error.message;
      });
      expect(find.text('0'), findsOneWidget);
      expect(modelRM.isIdle, isTrue);
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
    'ReactiveModel : global ReactiveModel error handling',
    (tester) async {
      RMKey<Model> modelRM = RMKey();
      String errorMessage;
      final widget = Column(
        children: <Widget>[
          StateBuilder<Model>(
            observe: () => RM.create(Model()),
            rmKey: modelRM,
            builder: (context, modelRM) {
              return _widgetBuilder('${modelRM.state.counter}');
            },
          )
        ],
      );
      await tester.pumpWidget(widget);
      modelRM.onError((context, error) {
        errorMessage = error.message;
      });
      modelRM.setState((s) => s.incrementAsyncError());
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
    'global ReactiveModel onData',
    (tester) async {
      RMKey<Model> modelRM = RMKey();

      int onDataFromSetState;
      int onDataGlobal;
      final widget = StateBuilder(
        observe: () => RM.create(Model()),
        rmKey: modelRM,
        builder: (_, __) {
          return Container();
        },
      );
      await tester.pumpWidget(widget);

      modelRM.onData((data) {
        onDataGlobal = data.counter;
      });
      //
      expect(onDataFromSetState, null);
      expect(onDataGlobal, null);
      modelRM.setState(
        (s) => s.increment(),
        onData: (context, data) {
          onDataFromSetState = data.counter;
        },
      );

      await tester.pump();
      expect(onDataFromSetState, 1);
      expect(onDataGlobal, 1);
    },
  );
}

class ModelSR extends StatesRebuilder {
  int counter = 0;
  int numberOfDisposeCall = 0;
  void increment() {
    counter++;
  }

  dispose() {
    numberOfDisposeCall++;
  }
}

class Model {
  int counter = 0;

  void increment() {
    counter++;
  }

  void incrementError() {
    throw Exception('Error message');
  }

  incrementAsync() async {
    await getFuture();
    counter++;
    return counter;
  }

  void incrementAsyncError() async {
    await getFuture();
    throw Exception('Error message');
  }

  Stream<int> incrementStream() async* {
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
    await Future.delayed(Duration(seconds: 1));
    yield --counter;
    throw Exception('Error message');
  }
}

Widget _widgetBuilder(String text1, [String text2, String text3]) {
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
Future<int> getFutureWithError() => Future.delayed(
    Duration(seconds: 1), () => throw Exception('Error message'));
Stream<int> getStream() =>
    Stream.periodic(Duration(seconds: 1), (num) => num).take(3);
