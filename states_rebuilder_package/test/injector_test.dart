import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/src/builders.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';
import 'package:states_rebuilder/src/states_rebuilder_debug.dart';

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
    expect(IN.get<int>(silent: true), isNull);
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
      expect(Injector.get<Model>(), equals(IN.get<Model>(name: Model)));
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
    'Injector remove model when disposed',
    (tester) async {
      Model model = Model();
      bool switcher = true;
      final widget = StateBuilder(
          observeMany: [() => model],
          tag: 'tag1',
          builder: (context, __) {
            if (switcher) {
              return Injector(
                inject: [Inject(() => model)],
                builder: (ctx) {
                  model = Injector.get<Model>();
                  return StateBuilder(
                      observe: () => model,
                      builder: (context, __) {
                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(model.counter.toString()),
                        );
                      });
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
        observeMany: [() => modelStatesBuilder],
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
    'Injector : widget lifeCycle (initState, dispose, afterInitialBuild) work',
    (tester) async {
      bool switcher = true;
      final modelStatesBuilder = Model();
      String lifeCycleTracker = '';
      final widget = StateBuilder(
        observeMany: [() => modelStatesBuilder],
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

  testWidgets('Injector throws if inject  parameter are not defined',
      (tester) async {
    expect(() => Injector(inject: null, builder: (_) => Container()),
        throwsAssertionError);
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
          Injector.getAsReactive<VanillaModel>().observers().length, equals(0));
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
    'setState with no observer will throw',
    (tester) async {
      ReactiveModel modelRM;
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (context) {
          return StateBuilder(
              observeMany: [],
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
      expect(() => modelRM.setState((s) => s.increment()), throwsException);
    },
  );

  testWidgets(
    'should not throw if async method is called from initState',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (context) {
          return StateBuilder<VanillaModel>(
              observeMany: [() => Injector.getAsReactive<VanillaModel>()],
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
      expect(RM.get<VanillaModel>().isWaiting, isTrue);
      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      expect(RM.get<VanillaModel>().hasError, isTrue);
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
        (Injector.getAsReactive<VanillaModel>()
                as ReactiveModelImp<VanillaModel>)
            .inject
            .getReactive(true),
        isA<ReactiveModel<VanillaModel>>(),
      );
      final modelRM1 = (Injector.getAsReactive<VanillaModel>()
              as ReactiveModelImp<VanillaModel>)
          .inject
          .getReactive(true);
      final modelRM2 = (Injector.getAsReactive<VanillaModel>()
              as ReactiveModelImp<VanillaModel>)
          .inject
          .getReactive(true);

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
                observeMany: [() => model],
                tag: 'tag1',
                builder: (context, __) {
                  if (switcher) {
                    return StateBuilder(
                      observeMany: [() => Injector.getAsReactive<int>()],
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
      print(Injector.getAsReactive<int>());
      await tester.pump(Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(intRM.subscription.isPaused, isFalse);
      switcher = false;
      model.rebuildStates();
      await tester.pump();
      print(Injector.getAsReactive<int>());

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
          observeMany: [() => model],
          tag: 'tag1',
          builder: (context, __) {
            if (switcher) {
              return Injector(
                inject: [Inject.stream(() => getStream())],
                builder: (ctx) {
                  intRM = Injector.getAsReactive<int>();
                  return StateBuilder(
                      observe: () => intRM,
                      builder: (context, __) {
                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(intRM.state.toString()),
                        );
                      });
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
      IN.get<Model>();
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
            observeMany: [() => streamModel],
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
            integerModel = Injector.getAsReactive<VanillaModel>();
            return StateBuilder(
                observe: () => integerModel,
                builder: (context, __) {
                  numberOfRebuild++;
                  return switcher
                      ? StateBuilder<VanillaModel>(
                          builder: (context, model) {
                            return Container();
                          },
                        )
                      : Container();
                });
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
            return StateBuilder(
                observeMany: [() => RM.get<VanillaModel>()],
                builder: (_, __) {
                  return Container();
                });
          },
        ),
      );
      String errorMessage;
      RM.get<VanillaModel>().setState(
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
          observeMany: [() => vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<VanillaModel>(() => VanillaModel(0)),
                  ],
                  builder: (context) {
                    model1 = Injector.getAsReactive<VanillaModel>();
                    return StateBuilder(
                        observe: () => model1,
                        builder: (context, __) {
                          numberOFRebuild1++;
                          return Container();
                        });
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
    'should onSetState get the right context with StateBuilder : case two StateBuilders',
    (WidgetTester tester) async {
      ReactiveModel<VanillaModel> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      final vm = Model();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StateBuilder(
              observeMany: [() => vm],
              builder: (_, __) {
                return Column(
                  children: <Widget>[
                    Injector(
                      inject: [
                        Inject<VanillaModel>(() => VanillaModel(0)),
                      ],
                      builder: (context) {
                        return StateBuilder(
                          observeMany: [() => model1 = RM.get<VanillaModel>()],
                          builder: (context, _) {
                            context1 = context;
                            return Container();
                          },
                        );
                      },
                    ),
                    if (isTrue)
                      Builder(
                        builder: (_) {
                          return StateBuilder(
                            observeMany: [
                              () => Injector.getAsReactive<VanillaModel>()
                            ],
                            builder: (context, model) {
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
      });
      await tester.pump();
      expect(context2, equals(context0));
      expect(RM.scaffold, isNotNull);

      isTrue = false;
      vm.rebuildStates();

      await tester.pump();
      model1.setState(null, onSetState: (context) {
        context0 = context;
      });
      await tester.pump();

      expect(context1, equals(context0));
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
          observeMany: [() => vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<VanillaModel>(() => VanillaModel(0)),
                  ],
                  builder: (context) {
                    return StateBuilder(
                        observeMany: [() => model1 = RM.get<VanillaModel>()],
                        builder: (context, _) {
                          context1 = context;
                          return Container();
                        });
                  },
                ),
                if (isTrue)
                  Builder(
                    builder: (_) {
                      return StateBuilder(
                        observeMany: [
                          () => Injector.getAsReactive<VanillaModel>()
                        ],
                        builder: (context, model) {
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
                    observeMany: [() => model1 = RM.get<VanillaModel>()],
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
          model = Injector.get<Model>();
          return StateBuilder(
              observe: () => model,
              builder: (context, __) {
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(model.counter.toString()),
                );
              });
        },
      );
      await tester.pumpWidget(widget);
      final text = StatesRebuilderDebug.printInjectedModel();
      expect(text, contains('Number of registered models : 1'));
      expect(text, contains('Model : [InjectImp<Model>('));
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
        model = Injector.getAsReactive<IModelInterface>();
        return StateBuilder(
            observe: () => model,
            builder: (context, __) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Text(model.state.counter.toString()),
              );
            });
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
        model = Injector.getAsReactive<IModelInterface>();
        return StateBuilder(
            observe: () => model,
            builder: (context, __) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Text(model.state.counter.toString()),
              );
            });
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
      observeMany: [() => model],
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

    expect(vanillaModel1.hashCode == vanillaModel2.hashCode, isFalse);

    model.rebuildStates();
    await tester.pump();
  });

  testWidgets('issue #47 reinjectOn vanilla dart class', (tester) async {
    final rm = ReactiveModel.create(0);
    Widget widget = Injector(
      inject: [
        Inject<String>.previous(
          (previous) {
            return 'counter is ${rm.state}';
          },
          initialValue: '0',
        )
      ],
      reinjectOn: [rm],
      builder: (context) {
        return StateBuilder(
            observe: () => ReactiveModel<String>(),
            builder: (context, __) {
              String value = RM.get<String>().state;
              return Text(value);
            });
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('counter is 0'), findsOneWidget);
    int hashCodeRM = ReactiveModel<String>().hashCode;
    //
    rm.setState((_) => 1);
    await tester.pump();
    expect(find.text('counter is 1'), findsOneWidget);
    expect(ReactiveModel<String>().hashCode, hashCodeRM);
    //
    rm.setState((_) => 2);
    await tester.pump();
    expect(find.text('counter is 2'), findsOneWidget);
    //
    ReactiveModel<String>().setState((_) => 'modified counter is 2');
    await tester.pump();
    expect(ReactiveModel<String>().hasData, isTrue);
    //
    rm.setState((_) => 3);
    await tester.pump();
    expect(find.text('counter is 3'), findsOneWidget);
  });

  testWidgets('issue #47 reinjectOn: stream', (tester) async {
    final rm = ReactiveModel.create(0);
    Widget widget = Injector(
      inject: [
        Inject.stream(() => getStream().map((s) => 'stream ${rm.state} : $s'),
            initialValue: 'stream ${rm.state} : null')
      ],
      reinjectOn: [rm],
      builder: (context) {
        return StateBuilder(
            observeMany: [() => rm],
            builder: (context, __) {
              return StateBuilder(
                  observe: () => ReactiveModel<String>(),
                  builder: (context, __) {
                    String value = ReactiveModel<String>().state;

                    return Text(value);
                  });
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
    rm.setState((_) => 1);
    await tester.pump();
    expect(find.text('stream 0 : 1'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 1 : 0'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 1 : 1'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 1 : 2'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('stream 1 : 2'), findsOneWidget);
    //
    rm.setState((_) => 2);
    await tester.pump();
    expect(find.text('stream 1 : 2'), findsOneWidget);
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
                Duration(seconds: 2), () => 'future ${rm.state}'),
            initialValue: 'future null')
      ],
      reinjectOn: [rm],
      builder: (context) {
        return StateBuilder(
            observeMany: [() => rm],
            builder: (context, __) {
              return StateBuilder(
                  observe: () => ReactiveModel<String>(),
                  builder: (context, __) {
                    String value = ReactiveModel<String>().state;
                    return Text(value);
                  });
            });
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('future null'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future null'), findsOneWidget);
    //
    rm.setState((_) => 1);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future null'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future 1'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future 1'), findsOneWidget);
    //
    rm.setState((_) => 2);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future 1'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('future 2'), findsOneWidget);
  });

  testWidgets(
      'issue72: rapidly pushing to second page while it is popping to the first page',
      (tester) async {
    BuildContext firstCtx;
    BuildContext secondCtx;
    Widget firstPage() => StateBuilder(
          observe: () => RM.create(0),
          builder: (context, _) {
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
    RM.navigator.push(
      MaterialPageRoute(
        builder: (ctx) {
          return secondPage();
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Second page'), findsOneWidget);
    //pop to the first Page,
    RM.navigator.pop();
    await tester.pump();
    expect(find.text('First page'), findsOneWidget);
    //rapidly push to the second page.
    RM.navigator.push(
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
          observeMany: [
            () => RM
                .get<VanillaModel>()
                .future<void>((m, _) => m.incrementAsync())
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
    expect(find.text('data'), findsOneWidget);
  });

  testWidgets('ReactiveModel.getStream', (tester) async {
    final widget = Injector(
      inject: [Inject(() => VanillaModel())],
      builder: (_) {
        return WhenRebuilderOr(
          observe: () => RM.get<VanillaModel>().stream(
                (m, _) => m._getStream(),
              ),
          onWaiting: () => Text('waiting ...'),
          builder: (_, rm) {
            return Text('${rm.state}');
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

  testWidgets('ReactiveModel.getStream should get the default initialValue',
      (tester) async {
    final intRM = RM.create<int>(2);
    final widget = Injector(
      inject: [Inject(() => VanillaModel())],
      builder: (_) {
        return WhenRebuilderOr(
          observeMany: [
            () => intRM.stream<int>(
                  (m, _) => getStream(),
                  initialValue: 2,
                )
          ],
          builder: (_, rm) {
            return Text('${rm.state}');
          },
        );
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('2'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('ReactiveModel.getFuture; Nested future case', (tester) async {
    final widget = Injector(
      inject: [Inject(() => VanillaModel())],
      builder: (_) {
        return WhenRebuilderOr(
          observeMany: [
            () => RM.get<VanillaModel>().future<VanillaModel>(
                  (m, _) => m.incrementAsync().then(
                        (_) => Future.delayed(
                          Duration(seconds: 1),
                          () => VanillaModel(5),
                        ),
                      ),
                )
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

  testWidgets('Side effects without context', (tester) async {
    final widget = MaterialApp(
        home: Scaffold(
      body: Injector(
          inject: [Inject(() => 1)], builder: (context) => Container()),
    ));
    await tester.pumpWidget(widget);
    expect(RM.navigator, isNotNull);
    expect(RM.scaffold, isNotNull);
    RM.show((context) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('')));
    });
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Side effects without context using context subscription',
      (tester) async {
    final widget = MaterialApp(
      home: Injector(
        inject: [Inject(() => 0)],
        builder: (
          context,
        ) {
          return Scaffold(
            body: Builder(builder: (context) {
              RM.get<int>(context: context);
              return Container();
            }),
          );
        },
      ),
    );
    await tester.pumpWidget(widget);
    expect(RM.navigator, isNotNull);
    expect(RM.scaffold, isNotNull);
    RM.show((context) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('')));
    });
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets(
    'dispose the last StateBuilder will not clean Injector',
    (tester) async {
      bool switcher = true;
      final widget = Injector(
        inject: [Inject.stream(() => getStream(), name: 'int')],
        builder: (context) {
          return Builder(
            builder: (context) {
              RM.get<int>(context: context);
              if (switcher) {
                return StateBuilder(
                  observeMany: [() => Injector.getAsReactive<int>(name: 'int')],
                  builder: (ctx, intRM$) {
                    return Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(intRM$.state.toString()),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(RM.get<int>(name: 'int'), isNotNull);
      switcher = false;
      await tester.pump(Duration(seconds: 1));
      // expect(RM.get<int>(), isNotNull);
    },
  );

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
      expect(lifecycleState, AppLifecycleState.detached);
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
