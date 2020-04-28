import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/src/state_builder.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';
import 'package:states_rebuilder/src/states_rebuilder_debug.dart';
import 'package:states_rebuilder/src/when_rebuilder_or.dart';

void main() {
  test(
    'Injector throw  builder is not defined',
    () {
      expect(
          () => Injector(
                inject: [Inject(() => 1)],
                builder: null,
              ),
          throwsAssertionError);
    },
  );

  testWidgets(
    'Injector throw if one of the injected model is null',
    (tester) async {
      await tester.pumpWidget(Injector(
        inject: [null],
        builder: (_) {
          return Container();
        },
      ));
      expect(tester.takeException(), isAssertionError);
    },
  );

  testWidgets('Injector throw when getting not registered model',
      (tester) async {
    final widget = Injector(
      inject: [Inject(() => Model())],
      builder: (context) {
        return Container();
      },
    );
    await tester.pumpWidget(widget);
    expect(() => Injector.get<int>(), throwsException);
  });

  testWidgets(
      'Injector not throw when getting not registered model if Injector.get silent is set to true',
      (tester) async {
    final widget = Injector(
      inject: [Inject(() => Model())],
      builder: (context) {
        return Container();
      },
    );
    await tester.pumpWidget(widget);
    expect(Injector.get<int>(silent: true), isNull);
  });

  testWidgets(
    'Injector get inject model works',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model())],
        builder: (context) {
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(Injector.get<Model>(), isA<Model>());
      expect(Injector.get<Model>(), equals(Injector.get<Model>()));
    },
  );

  testWidgets(
    'Injecting the same model twice should through',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model())],
        builder: (context) {
          return Injector(
            inject: [Inject(() => Model())],
            builder: (context) {
              return Container();
            },
          );
        },
      );
      await tester.pumpWidget(widget);
      // expect(tester.takeException(), isException);
    },
  );

  testWidgets(
    'Injecting the same model twice error is ignored if Injector.testModel is true',
    (tester) async {
      Model model1;
      Model model2;

      Injector.enableTestMode = true;
      final widget = Injector(
        inject: [Inject(() => Model())],
        builder: (context) {
          model1 = Injector.get<Model>();
          return Injector(
            inject: [Inject(() => Model())],
            builder: (context) {
              model2 = Injector.get<Model>();
              return Container();
            },
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(model1, isA<Model>());
      expect(model2 == model1, isTrue);
      Injector.enableTestMode = false;
    },
  );

  testWidgets(
    'Injector get inject model works for injected future',
    (tester) async {
      final widget = Injector(
        inject: [Inject.future(() => getFuture(), initialValue: 0)],
        builder: (context) {
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(Injector.get<int>(), isA<int>());
      expect(Injector.get<int>(), equals(Injector.get<int>()));
      await tester.pump(Duration(seconds: 1));
    },
  );

  testWidgets(
    'Injector throw if getting non-StatesRebuilder model with context',
    (tester) async {
      BuildContext context;
      final widget = Injector(
        inject: [Inject(() => 2)],
        builder: (ctx) {
          context = ctx;
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(() => Injector.get<int>(context: context), throwsException);
    },
  );

  testWidgets(
    'Injector throw if getting model with context and name',
    (tester) async {
      BuildContext context;
      final widget = Injector(
        inject: [Inject(() => Model(), name: 'name')],
        builder: (ctx) {
          context = ctx;
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(() => Injector.get<Model>(context: context, name: 'name'),
          throwsException);
    },
  );

  testWidgets(
    'Injector get a StatesRebuilder model with context and subscribe to it',
    (tester) async {
      Model model;
      final widget = Injector(
        inject: [Inject(() => Model())],
        builder: (ctx) {
          model = Injector.get<Model>(context: ctx);
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text(model.counter.toString()),
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(model.observers().length, equals(1));
      expect(find.text('0'), findsOneWidget);
      //
      model.increment();
      model.rebuildStates();
      await tester.pump();
      expect(model.observers().length, equals(1));
      expect(find.text('1'), findsOneWidget);
      //
      // model.rebuildStates();
      // await tester.pump();
      // expect(model.observers().values.toList()[0].length, equals(1));
    },
  );

  testWidgets(
    'Injector get with context throws if context in not available',
    (tester) async {
      BuildContext context;
      final widget = Builder(
        builder: (ctx) {
          return Injector(
            inject: [Inject(() => Model())],
            builder: (_) {
              context = ctx;
              return Container();
            },
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(() => Injector.get<Model>(context: context), throwsException);
    },
  );

  testWidgets(
    'Injector remove model when disposed',
    (tester) async {
      Model model = Model();
      bool switcher = true;
      final widget = StateBuilder(
          models: [model],
          tag: 'tag1',
          builder: (context, __) {
            if (switcher) {
              return Injector(
                inject: [Inject(() => model)],
                builder: (ctx) {
                  model = Injector.get<Model>(context: ctx);
                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(model.counter.toString()),
                  );
                },
              );
            } else {
              return Container();
            }
          });
      await tester.pumpWidget(widget);
      expect(model.observers().length, equals(3));
      expect(Injector.get<Model>(), equals(model));
      expect(find.text('0'), findsOneWidget);
      //
      switcher = false;
      model.rebuildStates();
      await tester.pump();
      expect(find.text('0'), findsNothing);
      expect(Injector.get<Model>(silent: true), isNull);
    },
  );

  testWidgets(
    'Injector : disposeModels works',
    (tester) async {
      bool switcher = true;
      final modelStatesBuilder = Model();
      Model modelInjector;
      final widget = StateBuilder(
        models: [modelStatesBuilder],
        builder: (_, __) {
          if (switcher) {
            return Injector(
              inject: [
                Inject(() => Model()),
                Inject(() => ModelWithoutDispose()),
              ],
              disposeModels: true,
              builder: (_) {
                modelInjector = Injector.get<Model>();
                return Container();
              },
            );
          }
          return Container();
        },
      );

      await tester.pumpWidget(widget);
      expect(modelInjector.numberOfDisposeCall, equals(0));
      //
      switcher = false;
      modelStatesBuilder.rebuildStates();
      await tester.pump();
      expect(modelInjector.numberOfDisposeCall, equals(1));
    },
  );

  testWidgets(
    'Injector : reinject with StatesBuilder model works',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model())],
        disposeModels: true,
        builder: (_) {
          return Injector(
            reinject: [Injector.get<Model>()],
            disposeModels: true,
            builder: (_) {
              return Container();
            },
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(InjectorState.allRegisteredModelInApp.length, equals(1));
      expect(InjectorState.allRegisteredModelInApp.values.toList()[0].length,
          equals(2));
    },
  );

  testWidgets(
    'Injector : reinject with StatesBuilder and navigation model works',
    (tester) async {
      BuildContext contextBeforeRoute;
      BuildContext contextAfterRoute;
      final widget = MaterialApp(
        home: Injector(
          inject: [Inject(() => Model())],
          disposeModels: true,
          builder: (ctx) {
            contextBeforeRoute = ctx;
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      expect(Injector.get<Model>(context: contextBeforeRoute), isA<Model>());

      //
      Navigator.push(
        contextBeforeRoute,
        MaterialPageRoute(
          builder: (ctx) {
            contextAfterRoute = ctx;
            return Injector(
              reinject: [Injector.get<Model>()],
              disposeModels: true,
              builder: (ctx) {
                contextAfterRoute = ctx;
                return Container();
              },
            );
          },
        ),
      );
      await tester.pump();
      final modelAfterRoute = IN.get<Model>(context: contextAfterRoute);
      expect(modelAfterRoute, isA<Model>());
      //
      Navigator.pop(contextAfterRoute);
      await tester.pump();
      expect(Injector.get<Model>(context: contextBeforeRoute), isA<Model>());
      expect(modelAfterRoute.numberOfDisposeCall, equals(0));
    },
  );

  testWidgets(
    'Injector : throws if reinject non injected instance',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model())],
        disposeModels: true,
        builder: (_) {
          return Injector(
            reinject: [Model()],
            disposeModels: true,
            builder: (_) {
              return Container();
            },
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(tester.takeException(), isException);
    },
  );

  testWidgets(
    'Injector : throws if reinject on existing model',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => Model())],
        disposeModels: true,
        builder: (_) {
          return Injector(
            reinject: [ModelWithoutDispose()],
            disposeModels: true,
            builder: (_) {
              return Container();
            },
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(tester.takeException(), isException);
    },
  );

  testWidgets(
    'Injector : widget lifeCycle (initState, dispose, afterInitialBuild) work',
    (tester) async {
      bool switcher = true;
      final modelStatesBuilder = Model();
      String lifeCycleTracker = '';
      final widget = StateBuilder(
        models: [modelStatesBuilder],
        builder: (_, __) {
          if (switcher) {
            return Injector(
              inject: [Inject(() => Model())],
              initState: () => lifeCycleTracker += 'initState, ',
              dispose: () => lifeCycleTracker += 'dispose, ',
              afterInitialBuild: (context) =>
                  lifeCycleTracker += 'afterInitialBuild, ',
              builder: (_) {
                lifeCycleTracker += 'builder, ';
                return Container();
              },
            );
          }
          return Container();
        },
      );

      await tester.pumpWidget(widget);
      expect(
          lifeCycleTracker, equals('initState, builder, afterInitialBuild, '));

      modelStatesBuilder.rebuildStates();
      await tester.pump();
      expect(lifeCycleTracker,
          equals('initState, builder, afterInitialBuild, builder, '));
      switcher = false;
      modelStatesBuilder.rebuildStates();
      await tester.pump();
      expect(lifeCycleTracker,
          equals('initState, builder, afterInitialBuild, builder, dispose, '));
    },
  );

  testWidgets('Injector throws if inject or reinject parameter are not defined',
      (tester) async {
    expect(() => Injector(builder: (_) => Container()), throwsAssertionError);
  });

  //
  //ReactiveModel

  testWidgets('Injector throw when getting as reactive not registered model',
      (tester) async {
    final widget = Injector(
      inject: [Inject(() => Model())],
      builder: (context) {
        return Container();
      },
    );
    await tester.pumpWidget(widget);
    expect(() => Injector.getAsReactive<int>(), throwsException);
  });

  testWidgets('Injector throw when getting as reactive of StatesRebuilder type',
      (tester) async {
    final widget = Injector(
      inject: [Inject(() => Model())],
      builder: (context) {
        return Container();
      },
    );
    await tester.pumpWidget(widget);
    expect(() => Injector.getAsReactive<Model>(), throwsException);
  });

  testWidgets(
      'Injector not throw when getting as reactive not registered model if Injector.get silent is set to true',
      (tester) async {
    final widget = Injector(
      inject: [Inject(() => Model())],
      builder: (context) {
        return Container();
      },
    );
    await tester.pumpWidget(widget);
    expect(Injector.getAsReactive<int>(silent: true), isNull);
  });

  testWidgets(
    'Injector getAsReactive of an inject model works',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (context) {
          return Container();
        },
      );
      await tester.pumpWidget(widget);

      expect(Injector.getAsReactive<VanillaModel>(),
          isA<ReactiveModel<VanillaModel>>());
      expect(
          Injector.getAsReactive<VanillaModel>().observers().length, equals(1));
      expect(Injector.getAsReactive<VanillaModel>(),
          equals(Injector.getAsReactive<VanillaModel>()));
    },
  );

  testWidgets(
    'Injector getAsReactive of inject model works for injected future',
    (tester) async {
      final widget = Injector(
        inject: [Inject.future(() => getFuture())],
        builder: (context) {
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(Injector.getAsReactive<int>(), isA<ReactiveModel<int>>());
      expect(
          Injector.getAsReactive<int>(), equals(Injector.getAsReactive<int>()));
      await tester.pump(Duration(seconds: 1));
    },
  );
  testWidgets(
    'Injector getAsReactive of inject model works for injected stream',
    (tester) async {
      final widget = Injector(
        inject: [Inject.stream(() => getStream())],
        builder: (context) {
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(Injector.getAsReactive<int>(), isA<ReactiveModel<int>>());
      expect(
          Injector.getAsReactive<int>(), equals(Injector.getAsReactive<int>()));
      await tester.pump(Duration(seconds: 3));
    },
  );

  testWidgets(
    'Injector throw if getting as reactive model with context and name',
    (tester) async {
      BuildContext context;
      final widget = Injector(
        inject: [Inject(() => VanillaModel(), name: 'name')],
        builder: (ctx) {
          context = ctx;
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(
          () => Injector.getAsReactive<VanillaModel>(
              context: context, name: 'name'),
          throwsException);
    },
  );

  testWidgets(
    'Injector get a reactive model with context and subscribe to it',
    (tester) async {
      ReactiveModel<VanillaModel> model;
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (ctx) {
          model = RM.get<VanillaModel>(context: ctx);
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text(model.state.counter.toString()),
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(model.observers().length, equals(1));
      expect(find.text('0'), findsOneWidget);
      //
      model.setState((s) => s.increment());
      await tester.pump();
      expect(model.observers().length, equals(1));
      expect(find.text('1'), findsOneWidget);
      //
      model.setState(null);
      await tester.pump();
      expect(model.observers().values.toList()[0].length, equals(1));
    },
  );

  testWidgets(
    'Injector get as reactive with context throws if context in not available',
    (tester) async {
      BuildContext context;
      final widget = Builder(
        builder: (ctx) {
          return Injector(
            inject: [Inject(() => VanillaModel())],
            builder: (_) {
              context = ctx;
              return Container();
            },
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(() => Injector.getAsReactive<VanillaModel>(context: context),
          throwsException);
    },
  );

  testWidgets(
    'Injector : reinject with ReactiveModel model works',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        disposeModels: true,
        builder: (_) {
          return Injector(
            reinject: [Injector.getAsReactive<VanillaModel>()],
            disposeModels: true,
            builder: (_) {
              return Container();
            },
          );
        },
      );

      await tester.pumpWidget(widget);
      expect(InjectorState.allRegisteredModelInApp.length, equals(1));
      expect(InjectorState.allRegisteredModelInApp.values.toList()[0].length,
          equals(2));
    },
  );

  testWidgets(
    'Injector : reinject with StatesBuilder and navigation model works using shortcuts',
    (tester) async {
      BuildContext contextBeforeRoute;
      BuildContext contextAfterRoute;
      final widget = MaterialApp(
        home: Injector(
          inject: [Inject(() => VanillaModel())],
          disposeModels: true,
          builder: (ctx) {
            contextBeforeRoute = ctx;
            return Container();
          },
        ),
      );

      await tester.pumpWidget(widget);
      expect(RM.get<VanillaModel>(context: contextBeforeRoute),
          isA<ReactiveModel<VanillaModel>>());

      expect(IN.get<VanillaModel>(), isA<VanillaModel>());

      //
      Navigator.push(
        contextBeforeRoute,
        MaterialPageRoute(
          builder: (ctx) {
            contextAfterRoute = ctx;
            return Injector(
              reinject: [RM.get<VanillaModel>()],
              disposeModels: true,
              builder: (ctx) {
                contextAfterRoute = ctx;
                return Container();
              },
            );
          },
        ),
      );
      await tester.pump();
      final modelAfterRoute = RM.get<VanillaModel>(context: contextAfterRoute);
      expect(modelAfterRoute, isA<ReactiveModel<VanillaModel>>());
      //
      Navigator.pop(contextAfterRoute);
      await tester.pump();
      expect(RM.get<VanillaModel>(context: contextBeforeRoute),
          isA<ReactiveModel<VanillaModel>>());
      expect(modelAfterRoute.state.numberOfDisposeCall, equals(0));
    },
  );

  testWidgets(
    'Injector : throws if reinject new reactive instance instance',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        disposeModels: true,
        builder: (_) {
          return Injector(
            reinject: [
              Injector.getAsReactive<VanillaModel>().inject.getReactive(true)
            ], //Todo getAs new Reactive
            disposeModels: true,
            builder: (_) {
              return Container();
            },
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(tester.takeException(), isException);
    },
  );

  testWidgets(
    'setState with no observer will throw',
    (tester) async {
      ReactiveModel modelRM;
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (context) {
          return StateBuilder(
              models: [],
              initState: (_, __) {
                modelRM = Injector.getAsReactive<VanillaModel>();
              },
              builder: (context, snapshot) {
                return Column(
                  children: <Widget>[
                    Container(),
                  ],
                );
              });
        },
      );

      await tester.pumpWidget(widget);
      // modelRM.setState((s) => s.incrementAsync());
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
    },
  );

  testWidgets(
    'should not throw if async method is called from initState',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (context) {
          return StateBuilder<VanillaModel>(
              models: [Injector.getAsReactive<VanillaModel>()],
              initState: (_, modelRM) {
                modelRM.setState(
                  (s) => s.incrementError(),
                  catchError: true,
                );
              },
              builder: (context, snapshot) {
                return Column(
                  children: <Widget>[
                    Container(),
                  ],
                );
              });
        },
      );
      await tester.pumpWidget(widget);
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
    },
  );

  testWidgets(
    'Injector getAsReactive as new instance of an inject model works',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (context) {
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(
        Injector.getAsReactive<VanillaModel>().inject.getReactive(true),
        isA<ReactiveModel<VanillaModel>>(),
      );
      final modelRM1 =
          Injector.getAsReactive<VanillaModel>().inject.getReactive(true);
      final modelRM2 =
          Injector.getAsReactive<VanillaModel>().inject.getReactive(true);

      expect(modelRM1 != modelRM2, isTrue);
    },
  );

  testWidgets(
    'Injector  will not dispose stream if the injector is not disposed',
    (tester) async {
      Model model = Model();
      bool switcher = true;
      ReactiveModel<int> intRM;
      final widget = Injector(
          inject: [Inject.stream(() => getStream())],
          builder: (context) {
            return StateBuilder(
                models: [model],
                tag: 'tag1',
                builder: (context, __) {
                  if (switcher) {
                    return StateBuilder(
                      models: [Injector.getAsReactive<int>()],
                      builder: (ctx, intRM$) {
                        intRM = intRM$;

                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(intRM$.state.toString()),
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                });
          });
      await tester.pumpWidget(widget);
      expect(find.text('null'), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(intRM.subscription.isPaused, isFalse);
      switcher = false;
      model.rebuildStates();
      await tester.pump();

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsNothing);
      expect(intRM.subscription, isNotNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsNothing);
    },
  );

  testWidgets(
    'Injector  will  stream dispose if the injector is disposed',
    (tester) async {
      Model model = Model();
      bool switcher = true;
      ReactiveModel<int> intRM;
      final widget = StateBuilder(
          models: [model],
          tag: 'tag1',
          builder: (context, __) {
            if (switcher) {
              return Injector(
                inject: [Inject.stream(() => getStream())],
                builder: (ctx) {
                  intRM = Injector.getAsReactive<int>(context: ctx);
                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(intRM.state.toString()),
                  );
                },
              );
            } else {
              return Container();
            }
          });

      await tester.pumpWidget(widget);
      expect(find.text('null'), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(intRM.subscription.isPaused, isFalse);
      switcher = false;
      model.rebuildStates();
      await tester.pump();

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsNothing);
      expect(intRM.subscription, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsNothing);
    },
  );

  testWidgets(
    'Injector: Fix Bug. models are injected lazily',
    (tester) async {
      Inject<Model> inject;
      final widget = Injector(
        inject: [inject = Inject(() => Model())],
        builder: (_) => Container(),
      );

      await tester.pumpWidget(widget);
      expect(inject.singleton, isNull);
      Injector.get<Model>();
      expect(inject.singleton, isNotNull);
    },
  );

  testWidgets(
      'Injector : should Injector.get work for model injected with Inject.Future',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<bool>.future(
            () => Future.delayed(
              Duration(seconds: 1),
              () => false,
            ),
            initialValue: true,
            isLazy: false,
          ),
        ],
        builder: (ctx) {
          return Container();
        },
      ),
    );
    expect(Injector.get<bool>(), isTrue);
    await tester.pump(Duration(seconds: 2));
    expect(Injector.get<bool>(), isFalse);
  });

  testWidgets(
      'Injector : should register Stream and Rebuild StateBuilder each time stream sends data with watch',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<VanillaModel>.stream(
            () => Stream.periodic(Duration(seconds: 1),
                (num) => num < 3 ? VanillaModel(num) : VanillaModel(3)).take(6),
            initialValue: VanillaModel(0),
            watch: (model) {
              return model?.counter;
            },
          ),
        ],
        builder: (_) {
          final streamModel = Injector.getAsReactive<VanillaModel>();
          return StateBuilder(
            models: [streamModel],
            builder: (_, __) {
              numberOfRebuild++;
              return Container();
            },
          );
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

  testWidgets('should register new ReactiveModel with generic StateBuilder ',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    ReactiveModel<VanillaModel> integerModel;
    bool switcher = true;
    Inject inject;
    await tester.pumpWidget(
      Injector(
          inject: [
            inject = Inject<VanillaModel>(() => VanillaModel(0)),
          ],
          builder: (context) {
            integerModel =
                Injector.getAsReactive<VanillaModel>(context: context);
            numberOfRebuild++;
            return switcher
                ? StateBuilder<VanillaModel>(
                    builder: (context, model) {
                      return Container();
                    },
                  )
                : Container();
          }),
    );
    expect(inject.newReactiveInstanceList.length, 1);
    expect(numberOfRebuild, equals(1));

    switcher = false;
    integerModel.setState(null);
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    expect(inject.newReactiveInstanceList.length, 0);
  });

  testWidgets(
    'Injector : should not throw when onError is defined',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        Injector(
          inject: [
            Inject<VanillaModel>(() => VanillaModel(0)),
          ],
          builder: (context) {
            Injector.getAsReactive<VanillaModel>(context: context);
            return Container();
          },
        ),
      );
      String errorMessage;
      RM.getSetState<VanillaModel>(
        (state) => state.incrementError(),
        onError: (context, error) {
          errorMessage = error.message;
        },
      );
      await tester.pump();
      await tester.pump(Duration(seconds: 2));
      expect(errorMessage, 'error message');
    },
  );

  testWidgets(
    'When a parent of injector rebuild the injector child tree will rebuild',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      int numberOFRebuild1 = 0;

      final vm = Model();
      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<VanillaModel>(() => VanillaModel(0)),
                  ],
                  builder: (context) {
                    model1 =
                        Injector.getAsReactive<VanillaModel>(context: context);
                    numberOFRebuild1++;
                    return Container();
                  },
                )
              ],
            );
          },
        ),
      );

      expect(numberOFRebuild1, equals(1));
      vm.rebuildStates();
      await tester.pump();
      expect(numberOFRebuild1, equals(2));
      model1.setState(null);
      await tester.pump();
      expect(numberOFRebuild1, equals(3));
    },
  );

  testWidgets(
    'should onSetState get the right context obtained by two getAsReactive',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      ScaffoldState scaffoldState;
      final vm = Model();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBuilder(
              models: [vm],
              builder: (_, __) {
                return Column(
                  children: <Widget>[
                    Injector(
                      inject: [
                        Inject<VanillaModel>(() => VanillaModel(0)),
                      ],
                      builder: (context) {
                        model1 = Injector.getAsReactive<VanillaModel>(
                            context: context);
                        context1 = context;
                        return Container();
                      },
                    ),
                    if (isTrue)
                      Builder(
                        builder: (_) {
                          return Injector(
                            reinject: [model1],
                            builder: (context) {
                              Injector.getAsReactive<VanillaModel>(
                                  context: context);
                              context2 = context;
                              return Container();
                            },
                          );
                        },
                      )
                    else
                      Container(),
                  ],
                );
              },
            ),
          ),
        ),
      );

      model1.setState(null, onSetState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();
      expect(context2, equals(context0));
      expect(scaffoldState, isNotNull);
      expect(context2.hashCode > context1.hashCode, isTrue);

      isTrue = false;
      vm.rebuildStates();
      await tester.pump();

      model1.setState(null, onSetState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });

      await tester.pump();

      expect(context1, equals(context0));
      expect(scaffoldState, isNotNull);
    },
  );

  testWidgets(
    'should onRebuildState get the right context with getAsReactive',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      ScaffoldState scaffoldState;
      final vm = Model();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBuilder(
              models: [vm],
              builder: (_, __) {
                return Column(
                  children: <Widget>[
                    Injector(
                      inject: [
                        Inject<VanillaModel>(() => VanillaModel(0)),
                      ],
                      builder: (context) {
                        model1 = Injector.getAsReactive<VanillaModel>(
                            context: context);
                        context1 = context;
                        return Container();
                      },
                    ),
                    if (isTrue)
                      Builder(
                        builder: (_) {
                          return Injector(
                            reinject: [model1],
                            builder: (context) {
                              Injector.getAsReactive<VanillaModel>(
                                  context: context);
                              context2 = context;
                              return Container();
                            },
                          );
                        },
                      )
                    else
                      Container(),
                  ],
                );
              },
            ),
          ),
        ),
      );

      model1.setState(null, onRebuildState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();
      expect(context2, equals(context0));
      expect(scaffoldState, isNotNull);
      expect(context2.hashCode > context1.hashCode, isTrue);

      isTrue = false;
      vm.rebuildStates();

      await tester.pump();
      RM.getSetState<VanillaModel>(null, onRebuildState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });

      await tester.pump();

      expect(context1, equals(context0));
      expect(scaffoldState, isNotNull);
    },
  );
  testWidgets(
    'should onSetState get the right context with StateBuilder : case StateBuilder before getAsReactive',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      ScaffoldState scaffoldState;
      final vm = Model();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBuilder(
              models: [vm],
              builder: (_, __) {
                return Column(
                  children: <Widget>[
                    Injector(
                      inject: [
                        Inject<VanillaModel>(() => VanillaModel(0)),
                      ],
                      builder: (context) {
                        return StateBuilder(
                          models: [Injector.getAsReactive<VanillaModel>()],
                          builder: (context, model) {
                            context1 = context;
                            model1 = model;
                            return Container();
                          },
                        );
                      },
                    ),
                    if (isTrue)
                      Builder(
                        builder: (_) {
                          return Injector(
                            reinject: [model1],
                            builder: (context) {
                              Injector.getAsReactive<VanillaModel>(
                                  context: context);
                              context2 = context;
                              return Container();
                            },
                          );
                        },
                      )
                    else
                      Container(),
                  ],
                );
              },
            ),
          ),
        ),
      );

      model1.setState(null, onSetState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();
      expect(context2, equals(context0));
      expect(scaffoldState, isNotNull);
      expect(context2.hashCode > context1.hashCode, isTrue);

      isTrue = false;
      vm.rebuildStates();

      await tester.pump();
      model1.setState(null, onSetState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();

      expect(context1, equals(context0));
      expect(scaffoldState, isNotNull);
    },
  );

  testWidgets(
    'should onRebuildState get the right context with StateBuilder : case StateBuilder before getAsReactive',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      ScaffoldState scaffoldState;
      final vm = Model();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBuilder(
              models: [vm],
              builder: (_, __) {
                return Column(
                  children: <Widget>[
                    Injector(
                      inject: [
                        Inject<VanillaModel>(() => VanillaModel(0)),
                      ],
                      builder: (context) {
                        return StateBuilder(
                          models: [Injector.getAsReactive<VanillaModel>()],
                          builder: (context, model) {
                            context1 = context;
                            model1 = model;
                            return Container();
                          },
                        );
                      },
                    ),
                    if (isTrue)
                      Builder(
                        builder: (_) {
                          return Injector(
                            reinject: [model1],
                            builder: (context) {
                              Injector.getAsReactive<VanillaModel>(
                                  context: context);
                              context2 = context;
                              return Container();
                            },
                          );
                        },
                      )
                    else
                      Container(),
                  ],
                );
              },
            ),
          ),
        ),
      );

      model1.setState(null, onRebuildState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();
      expect(context2, equals(context0));
      expect(scaffoldState, isNotNull);
      expect(context2.hashCode > context1.hashCode, isTrue);

      isTrue = false;
      vm.rebuildStates();

      await tester.pump();
      model1.setState(null, onRebuildState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();

      expect(context1, equals(context0));
      expect(scaffoldState, isNotNull);
    },
  );

  testWidgets(
    'should onSetState get the right context with StateBuilder : case StateBuilder after getAsReactive',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      ScaffoldState scaffoldState;
      final vm = Model();
      await tester.pumpWidget(
        MaterialApp(
            home: Scaffold(
                body: StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<VanillaModel>(() => VanillaModel(0)),
                  ],
                  builder: (context) {
                    model1 =
                        Injector.getAsReactive<VanillaModel>(context: context);
                    context1 = context;
                    return Container();
                  },
                ),
                if (isTrue)
                  Builder(
                    builder: (_) {
                      return Injector(
                        reinject: [model1],
                        builder: (context) {
                          return StateBuilder(
                            models: [Injector.getAsReactive<VanillaModel>()],
                            builder: (context, model) {
                              context2 = context;
                              return Container();
                            },
                          );
                        },
                      );
                    },
                  )
                else
                  Container(),
              ],
            );
          },
        ))),
      );

      model1.setState(null, onSetState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();
      expect(context2, equals(context0));
      expect(scaffoldState, isNotNull);

      isTrue = false;
      vm.rebuildStates();

      await tester.pump();
      model1.setState(null, onSetState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();

      expect(context1, equals(context0));
      expect(scaffoldState, isNotNull);
    },
  );

  testWidgets(
    'should onRebuildState get the right context with StateBuilder : case StateBuilder after getAsReactive',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      ScaffoldState scaffoldState;
      final vm = Model();
      await tester.pumpWidget(
        MaterialApp(
            home: Scaffold(
                body: StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<VanillaModel>(() => VanillaModel(0)),
                  ],
                  builder: (context) {
                    model1 =
                        Injector.getAsReactive<VanillaModel>(context: context);
                    context1 = context;
                    return Container();
                  },
                ),
                if (isTrue)
                  Builder(
                    builder: (_) {
                      return Injector(
                        reinject: [model1],
                        builder: (context) {
                          return StateBuilder(
                            models: [Injector.getAsReactive<VanillaModel>()],
                            builder: (context, model) {
                              context2 = context;
                              return Container();
                            },
                          );
                        },
                      );
                    },
                  )
                else
                  Container(),
              ],
            );
          },
        ))),
      );

      model1.setState(null, onRebuildState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();
      expect(context2, equals(context0));
      expect(scaffoldState, isNotNull);

      isTrue = false;
      vm.rebuildStates();

      await tester.pump();
      model1.setState(null, onRebuildState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();

      expect(context1, equals(context0));
      expect(scaffoldState, isNotNull);
    },
  );

  testWidgets(
    'should onSetState get the right context with StateBuilder : case two StateBuilders',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      ScaffoldState scaffoldState;
      final vm = Model();
      await tester.pumpWidget(
        MaterialApp(
            home: Scaffold(
                body: StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<VanillaModel>(() => VanillaModel(0)),
                  ],
                  builder: (context) {
                    return StateBuilder(
                        models: [model1 = RM.get<VanillaModel>()],
                        builder: (context, _) {
                          context1 = context;
                          return Container();
                        });
                  },
                ),
                if (isTrue)
                  Builder(
                    builder: (_) {
                      return Injector(
                        reinject: [model1],
                        builder: (context) {
                          return StateBuilder(
                            models: [Injector.getAsReactive<VanillaModel>()],
                            builder: (context, model) {
                              context2 = context;
                              return Container();
                            },
                          );
                        },
                      );
                    },
                  )
                else
                  Container(),
              ],
            );
          },
        ))),
      );

      model1.setState(null, onSetState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();
      expect(context2, equals(context0));
      expect(scaffoldState, isNotNull);

      isTrue = false;
      vm.rebuildStates();

      await tester.pump();
      model1.setState(null, onSetState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();

      expect(context1, equals(context0));
      expect(scaffoldState, isNotNull);
    },
  );

  testWidgets(
    'should onRebuildState get the right context with StateBuilder : case two StateBuilders',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      ScaffoldState scaffoldState;
      final vm = Model();
      await tester.pumpWidget(
        MaterialApp(
            home: Scaffold(
                body: StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<VanillaModel>(() => VanillaModel(0)),
                  ],
                  builder: (context) {
                    return StateBuilder(
                        models: [model1 = RM.get<VanillaModel>()],
                        builder: (context, _) {
                          context1 = context;
                          return Container();
                        });
                  },
                ),
                if (isTrue)
                  Builder(
                    builder: (_) {
                      return Injector(
                        reinject: [model1],
                        builder: (context) {
                          return StateBuilder(
                            models: [Injector.getAsReactive<VanillaModel>()],
                            builder: (context, model) {
                              context2 = context;
                              return Container();
                            },
                          );
                        },
                      );
                    },
                  )
                else
                  Container(),
              ],
            );
          },
        ))),
      );

      model1.setState(null, onRebuildState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();
      expect(context2, equals(context0));
      expect(scaffoldState, isNotNull);

      isTrue = false;
      vm.rebuildStates();

      await tester.pump();
      model1.setState(null, onRebuildState: (context) {
        context0 = context;
        scaffoldState = Scaffold.of(context);
      });
      await tester.pump();

      expect(context1, equals(context0));
      expect(scaffoldState, isNotNull);
    },
  );

  testWidgets(
    'OnSetState in StateBuilder is overrides onSetState in setState',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      bool onSetStateFromStateBuilder = false;
      bool onSetStateFromSetState = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Injector(
              inject: [
                Inject<VanillaModel>(() => VanillaModel(0)),
              ],
              builder: (context) {
                return StateBuilder(
                    models: [model1 = RM.get<VanillaModel>()],
                    onSetState: (_, __) {
                      onSetStateFromStateBuilder = true;
                    },
                    builder: (context, _) {
                      return Container();
                    });
              },
            ),
          ),
        ),
      );
      model1.setState(null, onSetState: (context) {
        onSetStateFromSetState = true;
      });
      expect(onSetStateFromStateBuilder, isTrue);
      expect(onSetStateFromSetState, isFalse);
    },
  );

  testWidgets(
    'should StatesRebuilderDebug.printObservers works',
    (tester) async {
      Model model;
      final widget = Injector(
        inject: [Inject(() => Model())],
        builder: (ctx) {
          model = Injector.get<Model>(context: ctx);
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Text(model.counter.toString()),
          );
        },
      );
      await tester.pumpWidget(widget);
      final text = StatesRebuilderDebug.printInjectedModel();
      expect(text, contains('Number of registered models : 1'));
      expect(text, contains('Model : [Inject<Model>('));
    },
  );

  testWidgets('Injector.interface should work Env.prod', (tester) async {
    Injector.env = Env.prod;
    ReactiveModel<IModelInterface> model;
    Widget widget = Injector(
      inject: [
        Inject.interface({
          Env.prod: () => ModelProd(),
          Env.test: () => ModelTest(),
        })
      ],
      builder: (context) {
        model = Injector.getAsReactive<IModelInterface>(context: context);
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(model.state.counter.toString()),
        );
      },
    );

    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);

    model.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Injector.interface should work Env.test', (tester) async {
    Injector.env = Env.test;
    ReactiveModel<IModelInterface> model;
    Widget widget = Injector(
      inject: [
        Inject.interface({
          Env.prod: () => ModelProd(),
          Env.test: () => ModelTest(),
        })
      ],
      builder: (context) {
        model = Injector.getAsReactive<IModelInterface>(context: context);
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(model.state.counter.toString()),
        );
      },
    );

    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);

    model.setState((s) => s.increment());
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets(
      'avoid throwing if Injector is deactivated be reinserted before dispose',
      (tester) async {
    final model = Model();
    final widget = StateBuilder(
      models: [model],
      builder: (_, __) {
        return Injector(
          key: UniqueKey(),
          inject: [Inject(() => VanillaModel())],
          builder: (_) {
            return Container();
          },
        );
      },
    );

    await tester.pumpWidget(widget);
    final vanillaModel1 = Injector.get<VanillaModel>();

    model.rebuildStates();
    await tester.pump();
    final vanillaModel2 = Injector.get<VanillaModel>();

    expect(vanillaModel1.hashCode == vanillaModel2.hashCode, isTrue);

    model.rebuildStates();
    await tester.pump();
  });

  testWidgets('issue #47 reinjectOn vanilla dart class', (tester) async {
    final rm = ReactiveModel.create(0);
    Widget widget = Injector(
      inject: [
        Inject<String>.previous(
          (previous) {
            return 'counter is ${rm.value}';
          },
          initialValue: '0',
        )
      ],
      reinjectOn: [rm],
      builder: (context) {
        String value = RM.get<String>(context: context).value;
        return Text(value);
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('counter is 0'), findsOneWidget);
    int hashCodeRM = ReactiveModel<String>().hashCode;
    //
    rm.setValue(() => 1);
    await tester.pump();
    expect(find.text('counter is 1'), findsOneWidget);
    expect(ReactiveModel<String>().hashCode, hashCodeRM);
    // //
    // rm.setValue(() => 2);
    // await tester.pump();
    // expect(find.text('counter is 2'), findsOneWidget);
    // //
    // ReactiveModel<String>().setValue(() => 'modified counter is 2');
    // await tester.pump();
    // expect(ReactiveModel<String>().hasData, isTrue);
    // //
    // rm.setValue(() => 3);
    // await tester.pump();
    // expect(find.text('counter is 3'), findsOneWidget);
  });

  testWidgets('issue #47 reinjectOn: stream', (tester) async {
    final rm = ReactiveModel.create(0);
    Widget widget = Injector(
      inject: [
        Inject.stream(() => getStream().map((s) => 'stream ${rm.value} : $s'),
            initialValue: 'stream ${rm.value} : null')
      ],
      reinjectOn: [rm],
      builder: (context) {
        return StateBuilder(
            models: [rm],
            builder: (context, __) {
              String value = ReactiveModel<String>(context: context).value;
              return Text(value);
            });
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('stream 0 : null'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 0 : 0'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 0 : 1'), findsOneWidget);
    //
    rm.setValue(() => 1);
    await tester.pump();
    expect(find.text('stream 0 : null'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 1 : 0'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 1 : 1'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 1 : 2'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 1 : 2'), findsOneWidget);
    //
    rm.setValue(() => 2);
    await tester.pump();
    expect(find.text('stream 0 : null'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 2 : 0'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 2 : 1'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 2 : 2'), findsOneWidget);
  });

  testWidgets('issue #47 reinjectOn: future', (tester) async {
    final rm = ReactiveModel.create(0);
    Widget widget = Injector(
      inject: [
        Inject.future(
            () => Future.delayed(
                Duration(seconds: 2), () => 'future ${rm.value}'),
            initialValue: 'future null')
      ],
      reinjectOn: [rm],
      builder: (context) {
        return StateBuilder(
            models: [rm],
            builder: (context, __) {
              String value = ReactiveModel<String>(context: context).value;
              return Text(value);
            });
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('future null'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future null'), findsOneWidget);
    //
    rm.setValue(() => 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future null'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future 1'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future 1'), findsOneWidget);
    //
    rm.setValue(() => 2);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future null'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future 2'), findsOneWidget);
  });

  testWidgets(
      'issue72: rapidly pushing to second page while it is popping to the first page',
      (tester) async {
    BuildContext firstCtx;
    BuildContext secondCtx;
    Widget firstPage() => Builder(
          builder: (context) {
            firstCtx = context;
            return Text('First page');
          },
        );
    Widget secondPage() => Injector(
          inject: [Inject(() => VanillaModel())],
          builder: (context) {
            secondCtx = context;
            return Text('Second page');
          },
        );
    await tester.pumpWidget(MaterialApp(home: firstPage()));
    expect(find.text('First page'), findsOneWidget);
    // Navigate to the second page:
    Navigator.of(firstCtx).push(
      MaterialPageRoute(
        builder: (ctx) {
          return secondPage();
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Second page'), findsOneWidget);
    //pop to the first Page,
    Navigator.of(secondCtx).pop();
    await tester.pump();
    expect(find.text('First page'), findsOneWidget);
    //rapidly push to the second page.
    Navigator.of(firstCtx).push(
      MaterialPageRoute(
        builder: (ctx) {
          return secondPage();
        },
      ),
    );
    await tester.pump();
  });

  testWidgets('ReactiveModel.getFuture', (tester) async {
    final widget = Injector(
      inject: [Inject(() => VanillaModel())],
      builder: (_) {
        return WhenRebuilderOr(
          models: [RM.getFuture<VanillaModel, void>((m) => m.incrementAsync())],
          onWaiting: () => Text('waiting ...'),
          builder: (_, rm) {
            return Text('data');
          },
        );
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('data'), findsOneWidget);
  });

  testWidgets('ReactiveModel.getStream', (tester) async {
    final widget = Injector(
      inject: [Inject(() => VanillaModel())],
      builder: (_) {
        return WhenRebuilderOr(
          models: [
            RM.getStream<VanillaModel, void>(
              (m) => m._getStream(),
              initialValue: 0,
            )
          ],
          onWaiting: () => Text('waiting ...'),
          builder: (_, rm) {
            return Text('${rm.value}');
          },
        );
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));

    expect(find.text('waiting ...'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('0'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    expect(find.text('2'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('ReactiveModel.getFuture; Nested future case', (tester) async {
    final widget = Injector(
      inject: [Inject(() => VanillaModel())],
      builder: (_) {
        return WhenRebuilderOr(
          models: [
            RM.getFuture<VanillaModel, int>((m) => m.incrementAsync().then(
                  (_) => Future.delayed(
                    Duration(seconds: 1),
                    () => 5,
                  ),
                ))
          ],
          onWaiting: () => Text('waiting ...'),
          builder: (_, rm) {
            return Text('data');
          },
        );
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('waiting ...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('data'), findsOneWidget);
  });

  group('', () {
    testWidgets('Injector appLifeCycle works', (WidgetTester tester) async {
      final BinaryMessenger defaultBinaryMessenger =
          ServicesBinding.instance.defaultBinaryMessenger;
      AppLifecycleState lifecycleState;
      final widget = Injector(
        inject: [Inject(() => Model())],
        appLifeCycle: (state) {
          lifecycleState = state;
        },
        builder: (_) => Container(),
      );

      await tester.pumpWidget(widget);

      expect(lifecycleState, isNull);
      ByteData message =
          const StringCodec().encodeMessage('AppLifecycleState.paused');
      await defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle', message, (_) {});
      await tester.pump();
      expect(lifecycleState, AppLifecycleState.paused);

      message = const StringCodec().encodeMessage('AppLifecycleState.resumed');
      await defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle', message, (_) {});
      expect(lifecycleState, AppLifecycleState.resumed);

      message = const StringCodec().encodeMessage('AppLifecycleState.inactive');
      await defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle', message, (_) {});
      expect(lifecycleState, AppLifecycleState.inactive);

      message = const StringCodec().encodeMessage('AppLifecycleState.detached');
      await defaultBinaryMessenger.handlePlatformMessage(
          'flutter/lifecycle', message, (_) {});
      //TODO It should be detached for the 1.14.7 update
      // expect(lifecycleState, AppLifecycleState.detached);
    });
  });
}

class Model extends StatesRebuilder {
  int counter = 0;
  int numberOfDisposeCall = 0;
  void increment() {
    counter++;
  }

  dispose() {
    numberOfDisposeCall++;
  }
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

  void incrementError() async {
    await getFuture();
    throw Exception('error message');
  }

  Stream<int> _getStream() => getStream();

  dispose() {
    numberOfDisposeCall++;
  }
}

class ModelWithoutDispose extends StatesRebuilder {
  int counter = 0;
  int numberOfDisposeCall = 0;
  void increment() {
    counter++;
  }
}

Future<int> getFuture() => Future.delayed(Duration(seconds: 1), () => 1);
Stream<int> getStream() => Stream.periodic(Duration(seconds: 1), (num) {
      return num;
    }).take(3);

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
