import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter1 {}

class Counter2 {
  Counter1 counter;
  Counter2([this.counter]);
}

void main() {
  testWidgets('Injector : should infer type', (WidgetTester tester) async {
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(() => Counter2(Injector.get())),
          Inject(() => Counter1()),
        ],
        builder: (_) => Container(),
      ),
    );
    final Counter2 counter = Injector.get();
    expect(counter, isA<Counter2>());
  });
  testWidgets('Injector : should throw assertion error if inject = null',
      (WidgetTester tester) async {
    expect(() {
      Injector(
        builder: (_) => null,
      );
    }, throwsAssertionError);
  });

  testWidgets(
      'Injector : should register models and should not rebuild if context is not provided in the get method',
      (WidgetTester tester) async {
    bool isRebuilt = false;
    await tester.pumpWidget(
      Injector(
        inject: [Inject(() => ViewModel())],
        builder: (context) {
          isRebuilt = true;
          return Container();
        },
      ),
    );

    isRebuilt = false;
    await tester.pump();
    expect(Injector.get<ViewModel>().message, equals("I am injected"));
    expect(isRebuilt, isFalse);
    final model = Injector.get<ViewModel>();
    if (model.hasObservers) model.rebuildStates();
    await tester.pump();
    expect(isRebuilt, false);
  });

  testWidgets(
      'Injector : should register models and should rebuild if context is provided in the get method',
      (WidgetTester tester) async {
    bool isRebuilt = false;
    await tester.pumpWidget(
      Injector(
        inject: [Inject(() => ViewModel())],
        builder: (context) {
          Injector.get<ViewModel>(context: context);
          isRebuilt = true;
          return Container();
        },
      ),
    );

    isRebuilt = false;
    await tester.pump();
    expect(Injector.get<ViewModel>().message, equals("I am injected"));
    expect(isRebuilt, isFalse);
    Injector.get<ViewModel>().rebuildStates();
    await tester.pump();
    expect(isRebuilt, true);
  });

  testWidgets('Injector : should getAsReactive asNewReactiveInstance',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<Integer>(() => Integer(5)),
        ],
        builder: (_) {
          return Container();
        },
      ),
    );
    final instance0 = Injector.getAsReactive<Integer>();
    final instance1 =
        Injector.getAsReactive<Integer>(asNewReactiveInstance: true);
    final instance2 =
        Injector.getAsReactive<Integer>(asNewReactiveInstance: true);
    expect(instance0.state.value, equals(5));
    expect(instance1.state.value, equals(5));
    expect(instance2.state.value, equals(5));
    instance0.state.value++;
    await tester.pump();
    expect(instance0.state.value, equals(6));
    expect(instance1.state.value, equals(6));
    expect(instance2.state.value, equals(6));
    expect(instance0.hashCode != instance1.hashCode, isTrue);
    expect(instance2.hashCode != instance1.hashCode, isTrue);
  });

  testWidgets(
      'Injector : should setState with future in the initState not throw',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<Integer>(() => Integer(5)),
        ],
        builder: (_) {
          final model = Injector.getAsReactive<Integer>();
          return StateBuilder(
            models: [model],
            initState: (_, __) =>
                model.setState((state) => state.incrementAsync()),
            builder: (_, __) {
              return Container();
            },
          );
        },
      ),
    );

    await tester.pump(Duration(seconds: 2));
  });

  // testWidgets(TODO
  //     'Injector : should register value and Rebuild StateBuilder with context. case primitive data',
  //     (WidgetTester tester) async {
  //   int numberOfRebuild = 0;
  //   await tester.pumpWidget(
  //     Injector(
  //       inject: [
  //         Inject<int>(() => 5),
  //       ],
  //       builder: (context) {
  //         return Builder(
  //           builder: (context) {
  //             Injector.getAsReactive<int>(context: context);
  //             numberOfRebuild++;
  //             return Container();
  //           },
  //         );
  //       },
  //     ),
  //   );
  //   expect(numberOfRebuild, equals(1));
  //   expect(Injector.getAsReactive<int>().state, equals(5));
  //   Injector.getAsReactive<int>().state++;
  //   await tester.pump();
  //   expect(numberOfRebuild, equals(2));
  //   expect(Injector.getAsReactive<int>().state, equals(6));
  // });

  testWidgets(
      'Injector : should register value and Rebuild StateBuilder after rebuildStates is called. case reference data',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<List<int>>(() => [1, 2, 3, 4]),
        ],
        builder: (_) {
          return StateBuilder(
            models: [Injector.getAsReactive<List<int>>()],
            builder: (_, __) {
              numberOfRebuild++;
              return Container();
            },
          );
        },
      ),
    );
    expect(numberOfRebuild, equals(1));
    expect(Injector.getAsReactive<List<int>>().state.length, equals(4));
    Injector.getAsReactive<List<int>>().setState((state) => state.removeLast());
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    expect(Injector.getAsReactive<List<int>>().state.length, equals(3));
  });
  testWidgets('Injector : should register Future', (WidgetTester tester) async {
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(() => Future.delayed(Duration(seconds: 1), () => false)),
        ],
        builder: (_) {
          return Container();
        },
      ),
    );
    final temp = Injector.get<Future<bool>>();
    expect(temp, isA<Future<bool>>());
    expect(Injector.get<Future<bool>>(), isA<Future<bool>>());
    await tester.pump(Duration(seconds: 2));
  });

  testWidgets(
      'Injector : should throw if get method is used with stream or future injection',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<bool>.future(
              () => Future.delayed(Duration(seconds: 1), () => false)),
        ],
        builder: (_) {
          return Container();
        },
      ),
    );
    expect(() => Injector.get<bool>(), throwsException);
  });

  testWidgets(
      'Injector : should throw if get method with context is used with non reactive model',
      (WidgetTester tester) async {
    BuildContext _context;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(() => 1),
        ],
        builder: (context) {
          _context = context;
          return Container();
        },
      ),
    );
    expect(() => Injector.get<int>(context: _context), throwsException);
  });

  testWidgets(
      'Injector : should throw if get method with context and name at the same time',
      (WidgetTester tester) async {
    BuildContext _context;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(() => ViewModel(), name: 'myName'),
        ],
        builder: (context) {
          _context = context;
          return Container();
        },
      ),
    );
    expect(
      () => Injector.get<ViewModel>(context: _context, name: 'myName'),
      throwsException,
    );

    expect(
      () =>
          Injector.getAsReactive<ViewModel>(context: _context, name: 'myName'),
      throwsException,
    );
  });

  testWidgets(
      'Injector : should throw getting new instance with context defined',
      (WidgetTester tester) async {
    BuildContext _context;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(() => ViewModel()),
        ],
        builder: (context) {
          _context = context;
          return Container();
        },
      ),
    );
    expect(
      () => Injector.getAsReactive<ViewModel>(
          context: _context, asNewReactiveInstance: true),
      throwsException,
    );
  });

  testWidgets('Injector : should register Future and get StatesRebuilder Type',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<bool>.future(
              () => Future.delayed(Duration(seconds: 1), () => false)),
        ],
        builder: (_) {
          return Container();
        },
      ),
    );
    final temp = Injector.getAsReactive<bool>();
    expect(temp, isA<StatesRebuilder>());
    expect(Injector.getAsReactive<bool>(), isA<StatesRebuilder>());
    await tester.pump(Duration(seconds: 2));
  });

  testWidgets(
      'Injector : should register Future and Rebuild StateBuilder after future is completed',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<bool>.future(
              () => Future.delayed(Duration(seconds: 1), () => false)),
        ],
        builder: (_) {
          return StateBuilder(
            models: [Injector.getAsReactive<bool>()],
            builder: (_, __) {
              numberOfRebuild++;
              return Container();
            },
          );
        },
      ),
    );
    expect(numberOfRebuild, equals(1));
    await tester.pump(Duration(seconds: 2));
    expect(numberOfRebuild, equals(2));
  });

  testWidgets(
      'Injector : should register Future and Rebuild StateBuilder after future is completed using context',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    bool futureValueResult;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<bool>.future(
              () => Future.delayed(Duration(seconds: 1), () => false),
              initialValue: true),
        ],
        builder: (context) {
          final model = Injector.getAsReactive<bool>(context: context);
          futureValueResult = model.snapshot.data;
          numberOfRebuild++;
          return Container();
        },
      ),
    );
    expect(numberOfRebuild, equals(1));
    expect(futureValueResult, equals(true));
    await tester.pump(Duration(seconds: 2));
    expect(numberOfRebuild, equals(2));
    expect(futureValueResult, equals(false));
  });

  testWidgets(
      'Injector : should register Stream and Rebuild StateBuilder each time stream sends data',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<int>.stream(() =>
              Stream.periodic(Duration(seconds: 1), (num) => num).take(5)),
        ],
        builder: (_) {
          return StateBuilder(
            models: [Injector.getAsReactive<int>()],
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
    expect(numberOfRebuild, equals(2));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(3));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(4));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(5));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(6));
    await tester.pump(Duration(seconds: 1));
    expect(numberOfRebuild, equals(6));
  });

  testWidgets(
      'Injector : should register Stream and Rebuild StateBuilder each time stream sends data using context',
      (WidgetTester tester) async {
    int streamValueResult = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<int>.stream(() =>
              Stream.periodic(Duration(seconds: 1), (num) => num).take(5)),
        ],
        builder: (context) {
          final model = Injector.getAsReactive<int>(context: context);
          streamValueResult = model.snapshot.data;
          return Container();
        },
      ),
    );
    expect(streamValueResult, equals(null));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult, equals(0));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult, equals(1));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult, equals(2));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult, equals(3));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult, equals(4));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult, equals(4));
  });

  testWidgets(
      'Injector : should register Stream and Rebuild StateBuilder each time stream sends data using context. Case widget is removed from the tree after 1',
      (WidgetTester tester) async {
    int streamValueResult1 = 0;
    int streamValueResult2 = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<int>.stream(
              () => Stream.periodic(Duration(seconds: 1), (num) => num).take(5),
              initialValue: 0,
              name: "int1"),
          Inject<int>.stream(
              () => Stream.periodic(Duration(seconds: 1), (num) => num).take(5),
              initialValue: 0,
              name: "int2"),
        ],
        builder: (context) {
          return StateBuilder(
            models: [Injector.getAsReactive<int>(name: "int1")],
            builder: (BuildContext context, model) {
              streamValueResult1 = model.snapshot.data;
              return streamValueResult1 < 2
                  ? StateBuilder(
                      models: [Injector.getAsReactive<int>(name: "int2")],
                      builder: (BuildContext context, _) {
                        streamValueResult2 = model.snapshot.data;
                        return Container();
                      },
                    )
                  : Container();
            },
          );
        },
      ),
    );
    expect(streamValueResult1, equals(0));
    expect(streamValueResult2, equals(0));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult1, equals(0));
    expect(streamValueResult1, equals(0));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult1, equals(1));
    expect(streamValueResult2, equals(1));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult1, equals(2));
    expect(streamValueResult2, equals(1));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult1, equals(3));
    expect(streamValueResult2, equals(1));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult1, equals(4));
    expect(streamValueResult2, equals(1));
    await tester.pump(Duration(seconds: 1));
    expect(streamValueResult1, equals(4));
    expect(streamValueResult2, equals(1));
  });

  testWidgets('Injector : should register many dependent services',
      (WidgetTester tester) async {
    ReactiveModel<ViewModel> vm;
    bool isRebuilt = false;
    int rebuildCount = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(() => ViewModel()),
          Inject(() => Service1()),
          Inject(() => Service2(Injector.get())),
        ],
        builder: (context) {
          vm = Injector.getAsReactive<ViewModel>(context: context);
          isRebuilt = true;
          rebuildCount++;
          return Container();
        },
      ),
    );

    isRebuilt = false;
    //notify to rebuild
    vm.setState((_) {});
    await tester.pump();
    expect(Injector.get<ViewModel>().message, equals("I am injected"));
    expect(Injector.get<Service1>().message, equals("I am Service1"));
    expect(Injector.get<Service2>().service1.message, equals("I am Service1"));
    expect(isRebuilt, isTrue);
    expect(
        rebuildCount,
        equals(
            2)); //Two rebuild : one after initState and one after rebuildStates()
  });

  testWidgets(
      'Injector : should unregister models injected by the disposed Injector',
      (WidgetTester tester) async {
    ReactiveModel<ViewModel> vm;

    bool switcher = true;
    bool initStateIsCalled = false;
    bool disposeStateIsCalled = false;

    await tester.pumpWidget(
      Injector(
        inject: [Inject(() => ViewModel())],
        builder: (context) {
          vm = Injector.getAsReactive<ViewModel>(context: context);
          return switcher
              ? Injector(
                  inject: [Inject(() => Service1())],
                  initState: () => initStateIsCalled = true,
                  dispose: () => disposeStateIsCalled = true,
                  builder: (context) => Container(),
                )
              : Container();
        },
      ),
    );

    expect(vm, isNot(isNull));

    expect(Injector.get<ViewModel>().message, equals("I am injected"));
    expect(Injector.get<Service1>().message, equals("I am Service1"));
    expect(initStateIsCalled, isTrue);
    expect(disposeStateIsCalled, isFalse);

    switcher = false;
    vm.setState((_) {});
    await tester.pump();
    expect(Injector.get<ViewModel>().message, equals("I am injected"));
    expect(() => Injector.get<Service1>(), throwsException);
    expect(initStateIsCalled, isTrue);
    expect(disposeStateIsCalled, isTrue);
  });

  testWidgets(
      'Injector : should get the last registered instance of a model registered twice',
      (WidgetTester tester) async {
    ReactiveModel<ViewModel> vm;

    Service1 service1_1 = Service1();
    Service1 service1_2 = Service1();

    Service1 getService1_1;
    Service1 getService1_2;

    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(() => ViewModel()),
          Inject(() => service1_1),
        ],
        builder: (context) {
          vm = Injector.getAsReactive<ViewModel>(context: context);

          getService1_1 = Injector.get<Service1>();
          return Injector(
              inject: [
                Inject(() => service1_2),
              ],
              builder: (context) {
                getService1_2 = Injector.get<Service1>();
                return Container();
              });
        },
      ),
    );

    expect(vm, isNot(isNull));

    expect(getService1_1, equals(service1_1));
    expect(getService1_2, equals(service1_1));
  });

  testWidgets(
      'Injector : should register many dependent services with inject parameter',
      (WidgetTester tester) async {
    ReactiveModel<ViewModel> vm;
    bool isRebuilt = false;
    int rebuildCount = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(() => ViewModel()),
          Inject(() => Service1()),
          Inject<IService2>(() => Service2(Injector.get())),
        ],
        builder: (context) {
          vm = Injector.getAsReactive<ViewModel>(context: context);

          isRebuilt = true;
          rebuildCount++;
          return Container();
        },
      ),
    );

    isRebuilt = false;
    expect(vm, isNot(isNull));
    //notify to rebuild
    vm.setState((_) {});
    await tester.pump();
    expect(Injector.get<ViewModel>().message, equals("I am injected"));
    expect(Injector.get<Service1>().message, equals("I am Service1"));
    expect(Injector.get<IService2>().service1.message, equals("I am Service1"));
    expect(Injector.get<IService2>(), isA<IService2>());
    expect(isRebuilt, isTrue);
    expect(
        rebuildCount,
        equals(
            2)); //Two rebuild : one after initState and one after rebuildStates()
  });

  testWidgets('Injector : should register with custom name',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(() => 1, name: "myInt"),
          Inject(() => [1, 2], name: "myList"),
          Inject(() => "Hollo World", name: "mySting"),
        ],
        builder: (_) {
          return Container();
        },
      ),
    );
    expect(Injector.get(name: "myInt"), equals(1));
    expect(Injector.get(name: "myInt"), isA<int>());
  });

  testWidgets(
    " should afterInitialBuild work",
    (WidgetTester tester) async {
      int numberOfCall = 0;
      ReactiveModel vm;
      await tester.pumpWidget(
        Injector(
          inject: [Inject(() => ViewModel())],
          builder: (context) {
            return Injector(
              inject: [Inject(() => 1)],
              afterInitialBuild: (context) => numberOfCall++,
              builder: (_) {
                vm = Injector.getAsReactive<ViewModel>(context: context);
                return Container();
              },
            );
          },
        ),
      );

      expect(numberOfCall, 1);
      vm.setState((_) {});
      await tester.pump();
      expect(numberOfCall, 1);
    },
  );

  testWidgets(
      'Injector : should register Stream and Rebuild StateBuilder each time stream sends data with watch',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<Integer>.stream(
              () => Stream.periodic(Duration(seconds: 1),
                  (num) => num < 3 ? Integer(num) : Integer(3)).take(6),
              watch: (model) => model.value),
        ],
        builder: (_) {
          final streamModel = Injector.getAsReactive<Integer>();
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
  });

  testWidgets(
      'Injector : should register Stream and Rebuild (using context) each time stream sends data with watch, toString is overridden',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<Integer>.stream(
              () => Stream.periodic(Duration(seconds: 1),
                  (num) => num < 3 ? Integer(num) : Integer(3)).take(6),
              watch: (model) => model),
        ],
        builder: (context) {
          Injector.getAsReactive<Integer>(context: context);
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
  });

  testWidgets(
      'Injector : should register value and Rebuild StateBuilder after rebuildStates is called. using watch',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<Integer>(() => Integer(0)),
        ],
        builder: (_) {
          return StateBuilder(
            models: [Injector.getAsReactive<Integer>()],
            builder: (_, __) {
              numberOfRebuild++;
              return Container();
            },
          );
        },
      ),
    );
    expect(numberOfRebuild, equals(1));
    expect(Injector.getAsReactive<Integer>().state.value, equals(0));
    Injector.getAsReactive<Integer>()
        .setState((state) => state.value++, watch: (state) => state.value);
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    expect(Injector.getAsReactive<Integer>().state.value, equals(1));
    Injector.getAsReactive<Integer>()
        .setState((state) => state.value, watch: (state) => state.value);
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    expect(Injector.getAsReactive<Integer>().state.value, equals(1));
  });

  testWidgets(
    'Injector : should call onSetState with StateBuilder',
    (WidgetTester tester) async {
      int numberOfRebuild = 0;
      List<String> _rebuildTracker = [];
      await tester.pumpWidget(
        Injector(
          inject: [
            Inject<Integer>(() => Integer(0)),
          ],
          builder: (_) {
            return StateBuilder(
              models: [Injector.getAsReactive<Integer>()],
              builder: (_, __) {
                numberOfRebuild++;
                _rebuildTracker.add("build");
                return Container();
              },
            );
          },
        ),
      );
      expect(numberOfRebuild, equals(1));
      expect(Injector.getAsReactive<Integer>().state.value, equals(0));
      Injector.getAsReactive<Integer>().setState(
        (state) => state.value++,
        onSetState: (context) => _rebuildTracker.add("onSetState"),
      );
      await tester.pump();
      expect(numberOfRebuild, equals(2));
      expect(Injector.getAsReactive<Integer>().state.value, equals(1));
      expect(_rebuildTracker, ["build", "onSetState", "build"]);
    },
  );

  testWidgets(
    'Injector : should call onRebuildState work',
    (WidgetTester tester) async {
      int numberOfRebuild = 0;
      List<String> _rebuildTracker = [];
      await tester.pumpWidget(
        Injector(
          inject: [
            Inject<Integer>(() => Integer(0)),
          ],
          builder: (_) {
            return StateBuilder(
              models: [Injector.getAsReactive<Integer>()],
              builder: (_, __) {
                numberOfRebuild++;
                _rebuildTracker.add("build");
                return Container();
              },
            );
          },
        ),
      );
      expect(numberOfRebuild, equals(1));
      expect(Injector.getAsReactive<Integer>().state.value, equals(0));
      Injector.getAsReactive<Integer>().setState(
        (state) => state.value++,
        onRebuildState: (context) => _rebuildTracker.add("onSetState"),
      );
      await tester.pump();
      expect(numberOfRebuild, equals(2));
      expect(Injector.getAsReactive<Integer>().state.value, equals(1));
      expect(_rebuildTracker, ["build", "build", "onSetState"]);
    },
  );

  testWidgets('Injector : should call onSetState with context',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    List<String> _rebuildTracker = [];
    await tester.pumpWidget(
      Injector(
          inject: [
            Inject<Integer>(() => Integer(0)),
          ],
          builder: (context) {
            Injector.getAsReactive<Integer>(context: context);
            numberOfRebuild++;
            _rebuildTracker.add("build");
            return Container();
          }),
    );
    expect(numberOfRebuild, equals(1));
    expect(Injector.getAsReactive<Integer>().state.value, equals(0));
    Injector.getAsReactive<Integer>().setState((state) => state.value++,
        onSetState: (context) => _rebuildTracker.add("afterBuild"));
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    expect(Injector.getAsReactive<Integer>().state.value, equals(1));
    expect(_rebuildTracker, ["build", "afterBuild", "build"]);
  });

  testWidgets('Injector : should onRebuildState work with context',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    List<String> _rebuildTracker = [];
    await tester.pumpWidget(
      Injector(
          inject: [
            Inject<Integer>(() => Integer(0)),
          ],
          builder: (context) {
            Injector.getAsReactive<Integer>(context: context);
            numberOfRebuild++;
            _rebuildTracker.add("build");
            return Container();
          }),
    );
    expect(numberOfRebuild, equals(1));
    expect(Injector.getAsReactive<Integer>().state.value, equals(0));
    Injector.getAsReactive<Integer>().setState(
      (state) => state.value++,
      onRebuildState: (context) => _rebuildTracker.add("onSetState"),
    );
    await tester.pump();
    expect(numberOfRebuild, equals(2));

    expect(Injector.getAsReactive<Integer>().state.value, equals(1));
    expect(_rebuildTracker, ["build", "build", "onSetState"]);
  });

  testWidgets(
      'Injector : Should "onSetState" and "onRebuildState" with StateBuilder work',
      (WidgetTester tester) async {
    List<String> _rebuildTracker = [];
    await tester.pumpWidget(
      Injector(
          inject: [
            Inject<Integer>(() => Integer(0)),
          ],
          builder: (context) {
            return StateBuilder(
              models: [Injector.getAsReactive<Integer>()],
              onSetState: (context, model) {
                _rebuildTracker.add("onSetState");
              },
              onRebuildState: (context, model) {
                _rebuildTracker.add("onRebuildState");
              },
              builder: (context, model) {
                _rebuildTracker.add("build");
                return Container();
              },
            );
          }),
    );
    expect(Injector.getAsReactive<Integer>().state.value, equals(0));
    Injector.getAsReactive<Integer>().setState((state) => state.value++);
    await tester.pump();

    expect(Injector.getAsReactive<Integer>().state.value, equals(1));
    expect(_rebuildTracker, ["build", "onSetState", "build", 'onRebuildState']);
  });

  testWidgets(
      'should register new ReactiveModel with generic StateBuilder with add ane dispose in registeredNewModels ',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    ReactiveModel<Integer> integerModel;
    bool switcher = true;
    await tester.pumpWidget(
      Injector(
          inject: [
            Inject<Integer>(() => Integer(0)),
          ],
          builder: (context) {
            integerModel = Injector.getAsReactive<Integer>(context: context);
            numberOfRebuild++;
            return switcher
                ? StateBuilder<Integer>(builder: (context, model) {
                    return Container();
                  })
                : Container();
          }),
    );
    // expect(inject.getReactiveSingleton().registeredReactiveInstance.length, 1);
    expect(numberOfRebuild, equals(1));

    switcher = false;
    integerModel.setState((_) {});
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    // expect(inject.getReactiveSingleton().registeredReactiveInstance.length, 0);
  });

  testWidgets('should wireSingletonWith work, default case (false)',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    ReactiveModel<Integer> integerModelFromInsideStateBuilder;
    await tester.pumpWidget(
      Injector(
          inject: [
            Inject<Integer>(() => Integer(0)),
          ],
          builder: (context) {
            Injector.getAsReactive<Integer>(context: context);
            numberOfRebuild++;
            return StateBuilder<Integer>(
              builder: (context, model) {
                integerModelFromInsideStateBuilder = model;
                return Container();
              },
            );
          }),
    );
    expect(numberOfRebuild, equals(1));

    integerModelFromInsideStateBuilder.setState((_) {});
    await tester.pump();
    expect(numberOfRebuild, equals(1));
  });

  testWidgets('should wireSingletonWith work,  (true)',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    ReactiveModel<Integer> integerModelFromInsideStateBuilder;
    await tester.pumpWidget(
      Injector(
          inject: [
            Inject<Integer>(
              () => Integer(0),
              joinSingleton: JoinSingleton.withCombinedReactiveInstances,
            ),
          ],
          builder: (context) {
            Injector.getAsReactive<Integer>(context: context);
            numberOfRebuild++;
            return StateBuilder<Integer>(builder: (context, model) {
              integerModelFromInsideStateBuilder = model;
              return Container();
            });
          }),
    );
    expect(numberOfRebuild, equals(1));

    integerModelFromInsideStateBuilder.setState((_) {});
    await tester.pump();
    expect(numberOfRebuild, equals(2));
  });

  testWidgets(
    'should wireSingletonWith work,  case newReactiveInstanceAndMerge',
    (WidgetTester tester) async {
      int numberOfRebuild = 0;
      ReactiveModel<Integer> integerModelFromInsideStateBuilder;
      Inject<Integer> inject;
      await tester.pumpWidget(
        Injector(
            inject: [
              inject = Inject<Integer>(
                () => Integer(0),
                joinSingleton: JoinSingleton.withCombinedReactiveInstances,
              ),
            ],
            builder: (context) {
              numberOfRebuild++;
              return StateBuilder<Integer>(
                builder: (context, model) {
                  integerModelFromInsideStateBuilder = model;
                  return Container();
                },
              );
            }),
      );
      expect(inject.reactiveSingleton, isNull);
      expect(numberOfRebuild, equals(1));
      integerModelFromInsideStateBuilder.setState((_) {});
      await tester.pump();
      expect(numberOfRebuild, equals(1));
      expect(inject.reactiveSingleton, isNull);
    },
  );
  testWidgets(
    'should notifyAllReactiveInstances work',
    (WidgetTester tester) async {
      int numberOfRebuild = 0;
      int numberOfRebuild1 = 0;
      int numberOfRebuild2 = 0;
      ReactiveModel<Integer> integerModelFromInsideStateBuilder;
      await tester.pumpWidget(
        Injector(
            inject: [Inject<Integer>(() => Integer(0))],
            builder: (context) {
              numberOfRebuild++;
              return Column(
                children: <Widget>[
                  StateBuilder<Integer>(
                    builder: (context, model) {
                      numberOfRebuild1++;
                      integerModelFromInsideStateBuilder = model;
                      return Container();
                    },
                  ),
                  StateBuilder<Integer>(
                    builder: (context, model) {
                      numberOfRebuild2++;
                      return Container();
                    },
                  ),
                ],
              );
            }),
      );

      expect(numberOfRebuild, equals(1));
      expect(numberOfRebuild1, equals(1));
      expect(numberOfRebuild2, equals(1));
      integerModelFromInsideStateBuilder.setState((_) {},
          notifyAllReactiveInstances: true);
      await tester.pump();
      expect(numberOfRebuild, equals(1));
      expect(numberOfRebuild1, equals(2));
      expect(numberOfRebuild2, equals(2));
    },
  );

  testWidgets(
    'should wireSingletonWith from Inject work,  case newReactiveInstanceAndMerge',
    (WidgetTester tester) async {
      ReactiveModel<Integer> integerModelFromInsideStateBuilder;
      ReactiveModel<Integer> integerModelFromInsideStateBuilder1;
      ReactiveModel<Integer> integerModelFromInsideStateBuilder2;
      await tester.pumpWidget(
        Injector(
            inject: [
              Inject<Integer>(
                () => Integer(0),
                joinSingleton: JoinSingleton.withCombinedReactiveInstances,
              ),
            ],
            builder: (context) {
              return Column(
                children: <Widget>[
                  Builder(
                    builder: (context) {
                      integerModelFromInsideStateBuilder =
                          Injector.getAsReactive<Integer>(context: context);
                      return Container();
                    },
                  ),
                  StateBuilder<Integer>(
                    builder: (context, model) {
                      integerModelFromInsideStateBuilder1 = model;
                      return Container();
                    },
                  ),
                  StateBuilder<Integer>(
                    builder: (context, model) {
                      integerModelFromInsideStateBuilder2 = model;
                      return Container();
                    },
                  ),
                ],
              );
            }),
      );

      expect(integerModelFromInsideStateBuilder.hasError, isFalse);
      expect(integerModelFromInsideStateBuilder1.hasError, isFalse);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);
      integerModelFromInsideStateBuilder1.setState(
        (_) {
          throw Exception();
        },
        catchError: true,
      );
      await tester.pump();

      expect(integerModelFromInsideStateBuilder.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder1.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);

      integerModelFromInsideStateBuilder2.setState((_) {});
      await tester.pump();

      expect(integerModelFromInsideStateBuilder.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder1.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);
    },
  );

  testWidgets(
    'should wireSingletonWith from Inject work,  case newReactiveInstance',
    (WidgetTester tester) async {
      ReactiveModel<Integer> integerModelFromInsideStateBuilder;
      ReactiveModel<Integer> integerModelFromInsideStateBuilder1;
      ReactiveModel<Integer> integerModelFromInsideStateBuilder2;
      await tester.pumpWidget(
        Injector(
            inject: [
              Inject<Integer>(
                () => Integer(0),
                joinSingleton: JoinSingleton.withNewReactiveInstance,
              ),
            ],
            builder: (context) {
              return Column(
                children: <Widget>[
                  Builder(
                    builder: (context) {
                      integerModelFromInsideStateBuilder =
                          Injector.getAsReactive<Integer>(context: context);
                      return Container();
                    },
                  ),
                  StateBuilder<Integer>(
                    builder: (context, model) {
                      integerModelFromInsideStateBuilder1 = model;
                      return Container();
                    },
                  ),
                  StateBuilder<Integer>(
                    builder: (context, model) {
                      integerModelFromInsideStateBuilder2 = model;
                      return Container();
                    },
                  ),
                ],
              );
            }),
      );

      expect(integerModelFromInsideStateBuilder.hasError, isFalse);
      expect(integerModelFromInsideStateBuilder1.hasError, isFalse);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);
      integerModelFromInsideStateBuilder1.setState(
        (_) {
          throw Exception();
        },
        catchError: true,
      );
      await tester.pump();

      expect(integerModelFromInsideStateBuilder.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder1.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);

      integerModelFromInsideStateBuilder2.setState((_) {});
      await tester.pump();

      expect(integerModelFromInsideStateBuilder.hasError, isFalse);
      expect(integerModelFromInsideStateBuilder1.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);
    },
  );
  testWidgets(
    'should wireSingletonWith from setState work,  case newReactiveInstanceAndMerge',
    (WidgetTester tester) async {
      ReactiveModel<Integer> integerModelFromInsideStateBuilder;
      ReactiveModel<Integer> integerModelFromInsideStateBuilder1;
      ReactiveModel<Integer> integerModelFromInsideStateBuilder2;
      await tester.pumpWidget(
        Injector(
            inject: [
              Inject<Integer>(
                () => Integer(0),
              ),
            ],
            builder: (context) {
              return Column(
                children: <Widget>[
                  Builder(
                    builder: (context) {
                      integerModelFromInsideStateBuilder =
                          Injector.getAsReactive<Integer>(context: context);
                      return Container();
                    },
                  ),
                  StateBuilder<Integer>(
                    builder: (context, model) {
                      integerModelFromInsideStateBuilder1 = model;
                      return Container();
                    },
                  ),
                  StateBuilder<Integer>(
                    builder: (context, model) {
                      integerModelFromInsideStateBuilder2 = model;
                      return Container();
                    },
                  ),
                ],
              );
            }),
      );

      expect(integerModelFromInsideStateBuilder.hasError, isFalse);
      expect(integerModelFromInsideStateBuilder1.hasError, isFalse);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);
      integerModelFromInsideStateBuilder1.setState(
        (_) {
          throw Exception();
        },
        catchError: true,
        joinSingletonWith: JoinSingleton.withCombinedReactiveInstances,
      );
      await tester.pump();

      expect(integerModelFromInsideStateBuilder.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder1.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);

      integerModelFromInsideStateBuilder2.setState(
        (_) {},
        joinSingletonWith: JoinSingleton.withCombinedReactiveInstances,
      );
      await tester.pump();

      expect(integerModelFromInsideStateBuilder.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder1.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);
    },
  );

  testWidgets(
    'should wireSingletonWith from setState work,  case newReactiveInstance',
    (WidgetTester tester) async {
      ReactiveModel<Integer> integerModelFromInsideStateBuilder;
      ReactiveModel<Integer> integerModelFromInsideStateBuilder1;
      ReactiveModel<Integer> integerModelFromInsideStateBuilder2;
      await tester.pumpWidget(
        Injector(
            inject: [
              Inject<Integer>(
                () => Integer(0),
              ),
            ],
            builder: (context) {
              return Column(
                children: <Widget>[
                  Builder(
                    builder: (context) {
                      integerModelFromInsideStateBuilder =
                          Injector.getAsReactive<Integer>(context: context);
                      return Container();
                    },
                  ),
                  StateBuilder<Integer>(
                    builder: (context, model) {
                      integerModelFromInsideStateBuilder1 = model;
                      return Container();
                    },
                  ),
                  StateBuilder<Integer>(
                    builder: (context, model) {
                      integerModelFromInsideStateBuilder2 = model;
                      return Container();
                    },
                  ),
                ],
              );
            }),
      );

      expect(integerModelFromInsideStateBuilder.hasError, isFalse);
      expect(integerModelFromInsideStateBuilder1.hasError, isFalse);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);
      integerModelFromInsideStateBuilder1.setState(
        (_) {
          throw Exception();
        },
        catchError: true,
        joinSingletonWith: JoinSingleton.withNewReactiveInstance,
      );
      await tester.pump();

      expect(integerModelFromInsideStateBuilder.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder1.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);

      integerModelFromInsideStateBuilder2.setState(
        (_) {},
        joinSingletonWith: JoinSingleton.withNewReactiveInstance,
      );
      await tester.pump();

      expect(integerModelFromInsideStateBuilder.hasError, isFalse);
      expect(integerModelFromInsideStateBuilder1.hasError, isTrue);
      expect(integerModelFromInsideStateBuilder2.hasError, isFalse);
    },
  );

  testWidgets(
    'should call onSetState and onRebuildState with both context and StateBuilder',
    (WidgetTester tester) async {
      ReactiveModel model1;
      List<String> _rebuildTracker = [];
      await tester.pumpWidget(
        Injector(
          inject: [
            Inject<Integer>(() => Integer(0)),
          ],
          builder: (context) {
            model1 = Injector.getAsReactive<Integer>(context: context);

            _rebuildTracker.add('rebuildFromBuilder');
            return StateBuilder(
                models: [model1],
                builder: (_, __) {
                  _rebuildTracker.add('rebuildFromStateBuilder');

                  return Container();
                });
          },
        ),
      );
      model1.setState(
        (_) {},
        onSetState: (_) => _rebuildTracker.add('onSetState'),
        onRebuildState: (_) => _rebuildTracker.add('onRebuildState'),
      );
      await tester.pump();
      expect(_rebuildTracker, [
        'rebuildFromBuilder',
        'rebuildFromStateBuilder',
        'onSetState',
        'rebuildFromBuilder',
        'rebuildFromStateBuilder',
        'onRebuildState'
      ]);
    },
  );

  testWidgets(
    'should after rebuild inheritedWidget returns the same reactiveSingleton. Do not throw',
    (WidgetTester tester) async {
      StatesRebuilder vm = ViewModel();

      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Injector(
                inject: [
                  Inject<Integer>(() => Integer(0)),
                ],
                builder: (context) {
                  Injector.getAsReactive<Integer>(context: context);
                  return Container();
                });
          },
        ),
      );
      vm.rebuildStates();
      await tester.pump();
    },
  );

  testWidgets(
    'should throw after navigation',
    (WidgetTester tester) async {
      BuildContext _context;

      await tester.pumpWidget(
        MaterialApp(
          home: Injector(
            inject: [
              Inject(() => ViewModel()),
            ],
            builder: (context) {
              _context = context;

              return Container();
            },
          ),
        ),
      );

      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) => Builder(
            builder: (context) {
              _context = context;

              return Container();
            },
          ),
        ),
      );
      await tester.pump();
      expect(
        () => Injector.get<ViewModel>(context: _context),
        throwsException,
      );

      expect(
        () => Injector.getAsReactive<ViewModel>(context: _context),
        throwsException,
      );
    },
  );

  testWidgets(
    'should models from InheritedWidget and service locator be equal after navigation, Case navigation with Injector',
    (WidgetTester tester) async {
      BuildContext _context;
      ReactiveModel<Integer> model1;
      ReactiveModel<Integer> model2;

      await tester.pumpWidget(
        MaterialApp(
          home: Injector(
            inject: [
              Inject<Integer>(() => Integer(0)),
            ],
            builder: (context) {
              _context = context;

              model1 = Injector.getAsReactive<Integer>(context: context);

              return Container();
            },
          ),
        ),
      );

      Navigator.push(
        _context,
        MaterialPageRoute(
          builder: (context) => Injector(
            reinject: [model1],
            builder: (context) {
              model2 = Injector.getAsReactive<Integer>(context: context);

              return Container();
            },
          ),
        ),
      );
      await tester.pump();

      expect(model1 == model2, isTrue);
      model1.setState((_) {});
      await tester.pump();
      expect(model1 == model2, isTrue);
      model2.setState((_) {});
      await tester.pump();
    },
  );

  testWidgets(
    'should models from InheritedWidget and service locator be equal after navigation, Case navigation with StateBuilder',
    (WidgetTester tester) async {
      BuildContext _context;
      ReactiveModel<Integer> model1;
      ReactiveModel<Integer> model2;
      await tester.pumpWidget(
        MaterialApp(
          home: Injector(
            inject: [
              Inject<Integer>(() => Integer(0)),
            ],
            builder: (context) {
              _context = context;
              model1 = Injector.getAsReactive<Integer>(context: context);
              return Container();
            },
          ),
        ),
      );

      Navigator.push(
          _context,
          MaterialPageRoute(
              builder: (context) => StateBuilder(
                    models: [model1],
                    builder: (context, _) {
                      model2 = Injector.getAsReactive<Integer>();
                      return Container();
                    },
                  )));
      await tester.pump();

      expect(model1 == model2, isTrue);
      model1.setState((_) {});
      await tester.pump();
      expect(model1 == model2, isTrue);
      model2.setState((_) {});
      await tester.pump();
    },
  );

  testWidgets(
    'should reinject works even when the first inject is disposed',
    (WidgetTester tester) async {
      ReactiveModel<Integer> model1;
      ReactiveModel<Integer> model2;
      bool isTrue = true;
      int numberOFRebuild1 = 0;
      int numberOFRebuild2 = 0;

      final vm = ViewModel();
      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                if (isTrue)
                  Injector(
                    inject: [
                      Inject<Integer>(() => Integer(0)),
                    ],
                    builder: (context) {
                      model1 =
                          Injector.getAsReactive<Integer>(context: context);
                      numberOFRebuild1++;
                      return Container();
                    },
                  )
                else
                  Container(),
                Builder(
                  builder: (_) {
                    return Injector(
                      reinject: [model1],
                      builder: (context) {
                        model2 =
                            Injector.getAsReactive<Integer>(context: context);
                        numberOFRebuild2++;
                        return Container();
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      );

      expect(model1.hashCode, equals(model1.hashCode));
      expect(numberOFRebuild1, equals(1));
      expect(numberOFRebuild2, equals(1));
      isTrue = false;
      vm.rebuildStates();
      await tester.pump();
      expect(model1.hashCode, equals(model1.hashCode));
      expect(numberOFRebuild1, equals(1));
      expect(numberOFRebuild2, equals(2));
      model2.setState((_) {});
      await tester.pump();
      expect(model1.hashCode, equals(model1.hashCode));
      expect(numberOFRebuild1, equals(1));
      expect(numberOFRebuild2, equals(3));
    },
  );

  testWidgets(
    'should onSetState get the right context with getAsReactive',
    (WidgetTester tester) async {
      ReactiveModel<Integer> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      final vm = ViewModel();
      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<Integer>(() => Integer(0)),
                  ],
                  builder: (context) {
                    model1 = Injector.getAsReactive<Integer>(context: context);
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
                          Injector.getAsReactive<Integer>(context: context);
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
      );

      model1.setState((state) {}, onSetState: (context) {
        context0 = context;
      });
      await tester.pump();
      expect(context0 == context2, isTrue);
      isTrue = false;
      vm.rebuildStates();
      model1.setState((state) {}, onSetState: (context) {
        context0 = context;
      });
      await tester.pump();
      expect(context0 == context1, isTrue);
    },
  );

  testWidgets(
    'should onRebuildState get the right context with getAsReactive',
    (WidgetTester tester) async {
      ReactiveModel<Integer> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      final vm = ViewModel();
      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<Integer>(() => Integer(0)),
                  ],
                  builder: (context) {
                    model1 = Injector.getAsReactive<Integer>(context: context);
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
                          Injector.getAsReactive<Integer>(context: context);
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
      );

      model1.setState((state) {}, onRebuildState: (context) {
        context0 = context;
      });
      await tester.pump();
      expect(context0.hashCode == context2.hashCode, isTrue);

      isTrue = false;
      vm.rebuildStates();
      model1.setState((state) {}, onRebuildState: (context) {
        context0 = context;
      });
      await tester.pump();
      expect(context0.hashCode == context1.hashCode, equals(true));
    },
  );

  testWidgets(
    'should onRebuildState get the right context with StateBuilder : case StateBuilder before getAsReactive',
    (WidgetTester tester) async {
      ReactiveModel<Integer> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      final vm = ViewModel();
      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<Integer>(() => Integer(0)),
                  ],
                  builder: (context) {
                    return StateBuilder(
                      models: [Injector.getAsReactive<Integer>()],
                      builder: (context, model) {
                        model1 = model;
                        context1 = context;
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
                          Injector.getAsReactive<Integer>(context: context);
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
      );

      model1.setState((state) {}, onRebuildState: (context) {
        context0 = context;
      });
      await tester.pump();
      expect(context0.hashCode == context1.hashCode, isTrue);

      isTrue = false;
      vm.rebuildStates();
      model1.setState((state) {}, onRebuildState: (context) {
        context0 = context;
      });
      await tester.pump();
      expect(context0.hashCode == context1.hashCode, equals(true));
    },
  );

  testWidgets(
    'should onRebuildState get the right context with StateBuilder : case StateBuilder after getAsReactive',
    (WidgetTester tester) async {
      ReactiveModel<Integer> model1;
      bool isTrue = true;
      BuildContext context0;
      BuildContext context1;
      BuildContext context2;
      final vm = ViewModel();
      await tester.pumpWidget(
        StateBuilder(
          models: [vm],
          builder: (_, __) {
            return Column(
              children: <Widget>[
                Injector(
                  inject: [
                    Inject<Integer>(() => Integer(0)),
                  ],
                  builder: (context) {
                    model1 = Injector.getAsReactive<Integer>(context: context);
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
                            models: [Injector.getAsReactive<Integer>()],
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
        ),
      );

      model1.setState((state) {}, onRebuildState: (context) {
        context0 = context;
      });
      await tester.pump();
      expect(context0.hashCode == context2.hashCode, isTrue);

      isTrue = false;
      vm.rebuildStates();
      model1.setState((state) {}, onRebuildState: (context) {
        context0 = context;
      });
      await tester.pump();
      expect(
          context0.hashCode == context1.hashCode, equals(false)); //TODO to fix
    },
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Injector.getAsReactive<Integer>(context: context);
    Injector.getAsReactive<Service1>(context: context);
    return Container();
  }
}

class ViewModel extends StatesRebuilder {
  String message = "I am injected";
}

class Service1 {
  String message = "I am Service1";
}

class Service2 implements IService2 {
  Service2(this.service1);

  @override
  Service1 service1;
}

abstract class IService2 {
  Service1 service1;
}

class Integer {
  int value = 0;
  Integer(this.value);
  incrementAsync() async {
    await Future.delayed(Duration(seconds: 1));
    value++;
  }

  @override
  String toString() {
    return '$value';
  }
}
