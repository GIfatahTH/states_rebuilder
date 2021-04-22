import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/legacy/inject.dart';
import 'package:states_rebuilder/src/legacy/injector.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'fake_classes/models.dart';

void main() {
  testWidgets('Injector throw when getting not registered model',
      (tester) async {
    final widget = Injector(
      inject: [Inject(() => VanillaModel())],
      builder: (context) {
        return Container();
      },
    );
    await tester.pumpWidget(widget);
    expect(() => Injector.get<int>(), throwsException);
  });

  testWidgets(
    'Injector get inject model works',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (context) {
          return Container();
        },
      );
      await tester.pumpWidget(widget);
      expect(Injector.get<VanillaModel>(), isA<VanillaModel>());
      expect(Injector.get<VanillaModel>(),
          equals(IN.get<VanillaModel>(name: VanillaModel)));
    },
  );

  testWidgets(
    'Injecting the same model twice should through',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (context) {
          return Injector(
            inject: [Inject(() => VanillaModel())],
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
      VanillaModel? model1;
      VanillaModel? model2;

      Injector.enableTestMode = true;
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (context) {
          model1 = Injector.get<VanillaModel>();
          return Injector(
            inject: [Inject(() => VanillaModel())],
            builder: (context) {
              model2 = Injector.get<VanillaModel>();
              return Container();
            },
          );
        },
      );
      await tester.pumpWidget(widget);
      expect(model1, isA<VanillaModel>());
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
      var model = ReactiveModel.create(VanillaModel());
      bool switcher = true;
      final widget = StateBuilder(
          observeMany: [() => model],
          tag: 'tag1',
          builder: (context, __) {
            if (switcher) {
              return Injector(
                inject: [Inject(() => model)],
                builder: (ctx) {
                  model = Injector.get<ReactiveModel<VanillaModel>>();
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
            } else {
              return Container();
            }
          });
      await tester.pumpWidget(widget);
      expect(model.observerLength, equals(2));
      expect(Injector.get<ReactiveModel<VanillaModel>>(), equals(model));
      expect(find.text('0'), findsOneWidget);
      //
      switcher = false;
      model.notify();
      await tester.pump();
      expect(find.text('0'), findsNothing);
      expect(model.observerLength, equals(1));

      // expect(Injector.get<Model>(silent: true), isNull);
    },
  );

  testWidgets(
    'Injector : widget lifeCycle (initState, dispose, afterInitialBuild) work',
    (tester) async {
      bool switcher = true;
      var model = ReactiveModel.create(VanillaModel());
      String lifeCycleTracker = '';
      final widget = StateBuilder(
        observeMany: [() => model],
        builder: (_, __) {
          if (switcher) {
            return Injector(
              inject: [Inject(() => VanillaModel())],
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

      model.notify();
      await tester.pump();
      expect(lifeCycleTracker,
          equals('initState, builder, afterInitialBuild, builder, '));
      switcher = false;
      model.notify();
      await tester.pump();
      expect(lifeCycleTracker,
          equals('initState, builder, afterInitialBuild, builder, dispose, '));
    },
  );

  //
  //ReactiveModel

  testWidgets('Injector throw when getting as reactive not registered model',
      (tester) async {
    final widget = Injector(
      inject: [Inject(() => VanillaModel())],
      builder: (context) {
        return Container();
      },
    );
    await tester.pumpWidget(widget);
    expect(() => Injector.getAsReactive<int>(), throwsException);
  });

  // testWidgets('Injector throw when getting as reactive of StatesRebuilder type',
  //     (tester) async {
  //   final widget = Injector(
  //     inject: [Inject(() => VanillaModel())],
  //     builder: (context) {
  //       return Container();
  //     },
  //   );
  //   await tester.pumpWidget(widget);
  //   expect(() => Injector.getAsReactive<VanillaModel>(), throwsException);
  // });

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
      expect(Injector.getAsReactive<VanillaModel>().observerLength, equals(0));
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
    'should not throw if async method is called from initState',
    (tester) async {
      final widget = Injector(
        inject: [Inject(() => VanillaModel())],
        builder: (context) {
          return StateBuilder<VanillaModel>(
              observeMany: [() => Injector.getAsReactive<VanillaModel>()],
              initState: (_, modelRM) {
                modelRM?.setState(
                  (s) => s.incrementAsyncWithError(),
                  /*catchError: true*/
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
    'Injector  will not dispose stream if the injector is not disposed',
    (tester) async {
      var model = ReactiveModel.create(VanillaModel());
      bool switcher = true;
      ReactiveModel<int>? intRM;
      final widget = Injector(
          inject: [
            Inject.stream(
              () => getStream(),
              initialValue: 0,
            )
          ],
          builder: (context) {
            return StateBuilder(
                observeMany: [() => model],
                tag: 'tag1',
                builder: (context, __) {
                  if (switcher) {
                    return StateBuilder<int>(
                      observeMany: [() => Injector.getAsReactive<int>()],
                      builder: (ctx, intRM$) {
                        intRM = intRM$;

                        return Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(intRM$!.state.toString()),
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                });
          });
      await tester.pumpWidget(widget);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('0'), findsOneWidget);
      expect(intRM!.subscription?.isPaused, isFalse);
      switcher = false;
      model.notify();
      await tester.pump();

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsNothing);
      expect(intRM!.subscription, isNotNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsNothing);
    },
  );

  testWidgets(
    'Injector  will  stream dispose if the injector is disposed',
    (tester) async {
      var model = ReactiveModel.create(VanillaModel());

      bool switcher = true;
      late ReactiveModel<int?> intRM;
      final widget = StateBuilder(
          observeMany: [() => model],
          tag: 'tag1',
          builder: (context, __) {
            if (switcher) {
              return Injector(
                inject: [Inject<int?>.stream(() => getStream())],
                builder: (ctx) {
                  intRM = Injector.getAsReactive<int?>();
                  return StateBuilder(
                    observe: () => intRM,
                    builder: (context, __) {
                      return Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(intRM.state.toString()),
                      );
                    },
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
      expect(intRM.subscription?.isPaused, isFalse);
      switcher = false;
      model.notify();
      await tester.pump();

      await tester.pump(Duration(seconds: 1));
      expect(find.text('1'), findsNothing);
      expect(intRM.subscription, isNull);

      await tester.pump(Duration(seconds: 1));
      expect(find.text('2'), findsNothing);
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

  // testWidgets(
  //     'Injector : should register Stream and Rebuild StateBuilder each time stream sends data with watch',
  //     (WidgetTester tester) async {
  //   int numberOfRebuild = 0;
  //   await tester.pumpWidget(
  //     Injector(
  //       inject: [
  //         Inject<VanillaModel>.stream(
  //           () => Stream.periodic(Duration(seconds: 1),
  //               (num) => num < 3 ? VanillaModel(num) : VanillaModel(3)).take(6),
  //           initialValue: VanillaModel(0),
  //           watch: (model) {
  //             return model?.counter;
  //           },
  //         ),
  //       ],
  //       builder: (_) {
  //         final streamModel = Injector.getAsReactive<VanillaModel>();
  //         return StateBuilder(
  //           observeMany: [() => streamModel],
  //           builder: (_, __) {
  //             numberOfRebuild++;
  //             return Container();
  //           },
  //         );
  //       },
  //     ),
  //   );
  //   expect(numberOfRebuild, equals(1));
  //   await tester.pump(Duration(seconds: 1));
  //   expect(numberOfRebuild, equals(1));
  //   await tester.pump(Duration(seconds: 1));
  //   expect(numberOfRebuild, equals(2));
  //   await tester.pump(Duration(seconds: 1));
  //   expect(numberOfRebuild, equals(3));
  //   await tester.pump(Duration(seconds: 1));
  //   expect(numberOfRebuild, equals(4));
  //   await tester.pump(Duration(seconds: 1));
  //   expect(numberOfRebuild, equals(4));
  //   await tester.pump(Duration(seconds: 1));
  //   expect(numberOfRebuild, equals(4));
  // });

  testWidgets(
    'When a parent of injector rebuild the injector child tree will rebuild',
    (WidgetTester tester) async {
      late ReactiveModel<VanillaModel> model1;
      int numberOFRebuild1 = 0;

      final vm = ReactiveModel.create(VanillaModel());
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
      vm.notify();
      await tester.pump();
      expect(numberOFRebuild1, equals(1));
      model1.setState((_) {});
      await tester.pump();
      expect(numberOFRebuild1, equals(2));
    },
  );

  testWidgets('Injector.interface should work Env.prod', (tester) async {
    Injector.env = Env.prod;
    late ReactiveModel<IModelInterface> model;
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
    late ReactiveModel<IModelInterface> model;
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
    final model = ReactiveModel.create(VanillaModel());
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
    model.notify();
    await tester.pump();
    final vanillaModel2 = Injector.get<VanillaModel>();

    expect(vanillaModel1.hashCode == vanillaModel2.hashCode, isFalse);

    model.notify();
    await tester.pump();
  });

  testWidgets('issue #47 reinjectOn vanilla dart class', (tester) async {
    final rm = ReactiveModel.create(0);
    Widget widget = Injector(
      inject: [
        Inject<String>(
          () {
            return 'counter is ${rm.state}';
          },
        )
      ],
      reinjectOn: [rm],
      builder: (context) {
        return StateBuilder(
            observe: () => RM.get<String>(),
            builder: (context, __) {
              String value = RM.get<String>().state;
              return Text(value);
            });
      },
    );

    await tester.pumpWidget(MaterialApp(home: widget));
    expect(find.text('counter is 0'), findsOneWidget);
    int hashCodeRM = RM.get<String>().hashCode;
    //
    rm.setState((_) => 1);
    await tester.pump();
    expect(find.text('counter is 1'), findsOneWidget);
    expect(RM.get<String>().hashCode, hashCodeRM);
    //
    rm.setState((_) => 2);
    await tester.pump();
    expect(find.text('counter is 2'), findsOneWidget);
    //
    RM.get<String>().setState((_) => 'modified counter is 2');
    await tester.pump();
    expect(RM.get<String>().hasData, isTrue);
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
                  observe: () => RM.get<String>(),
                  builder: (context, __) {
                    String value = RM.get<String>().state;

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
                  observe: () => RM.get<String>(),
                  builder: (context, __) {
                    String value = RM.get<String>().state;
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
    Widget firstPage() => StateBuilder(
          observe: () => ReactiveModel.create(0),
          builder: (context, _) {
            return Text('First page');
          },
        );
    Widget secondPage() => Injector(
          inject: [Inject(() => VanillaModel())],
          builder: (context) {
            return Text('Second page');
          },
        );
    await tester.pumpWidget(MaterialApp(home: firstPage()));
    expect(find.text('First page'), findsOneWidget);
    // Navigate to the second page:
    Navigator.of(RM.context!).push(
      MaterialPageRoute(
        builder: (ctx) {
          return secondPage();
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Second page'), findsOneWidget);
    //pop to the first Page,
    Navigator.of(RM.context!).pop();
    await tester.pump();
    expect(find.text('First page'), findsOneWidget);
    //rapidly push to the second page.
    Navigator.of(RM.context!).push(
      MaterialPageRoute(
        builder: (ctx) {
          return secondPage();
        },
      ),
    );
    await tester.pump();
  });

  testWidgets('Injector appLifeCycle works', (WidgetTester tester) async {
    final BinaryMessenger defaultBinaryMessenger =
        ServicesBinding.instance!.defaultBinaryMessenger;
    AppLifecycleState? lifecycleState;
    final widget = Injector(
      inject: [Inject(() => VanillaModel())],
      appLifeCycle: (state) {
        lifecycleState = state;
      },
      builder: (_) => Container(),
    );

    await tester.pumpWidget(widget);

    expect(lifecycleState, isNull);
    ByteData? message =
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
