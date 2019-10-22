import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('Injector : should throw assertion error if models = null',
      (WidgetTester tester) async {
    expect(() {
      Injector(
        builder: (_, __) => null,
      );
    }, throwsAssertionError);
  });

  testWidgets(
      'Injector : should register viewModels and should not rebuild if context is not provided in the get method',
      (WidgetTester tester) async {
    bool isRebuilt = false;
    await tester.pumpWidget(
      Injector(
        models: [() => ViewModel()],
        builder: (context, _) {
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
    if (model.hasState) model.rebuildStates();
    await tester.pump();
    expect(isRebuilt, false);
  });

  testWidgets(
      'Injector : should register viewModels and should rebuild if context is provided in the get method',
      (WidgetTester tester) async {
    bool isRebuilt = false;
    await tester.pumpWidget(
      Injector(
        models: [() => ViewModel()],
        builder: (context, _) {
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

  testWidgets(
      'Injector : should register models and should not rebuild if the generic type of Injector is not defined',
      (WidgetTester tester) async {
    ViewModel vm;
    bool isRebuilt = false;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(
            () => ViewModel(),
          )
        ],
        builder: (_, model) {
          vm = model;
          isRebuilt = true;
          return Container();
        },
      ),
    );

    isRebuilt = false;
    await tester.pump();
    expect(Injector.get<ViewModel>().message, equals("I am injected"));
    expect(vm, isNull);
    expect(isRebuilt, isFalse);
  });

  testWidgets(
      'Injector : should register models and should  rebuild if the generic type of Injector is defined',
      (WidgetTester tester) async {
    ViewModel vm;
    bool isRebuilt = false;
    await tester.pumpWidget(
      Injector<ViewModel>(
        models: [() => ViewModel()],
        builder: (_, model) {
          vm = model;
          isRebuilt = true;
          return Container();
        },
      ),
    );

    isRebuilt = false;
    expect(vm, isNot(isNull));
    //ٌnotify to rebuild
    vm.rebuildStates();
    await tester.pump();
    expect(Injector.get<ViewModel>().message, equals("I am injected"));
    expect(isRebuilt, isTrue);
  });

  testWidgets(
      'Injector : should register value and Rebuild StateBuilder after rebuildStates is called. case primitive data',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<int>(() => 5),
        ],
        builder: (_, model) {
          return StateBuilder(
            viewModels: [Injector.getAsModel<int>()],
            builder: (_, __) {
              numberOfRebuild++;
              return Container();
            },
          );
        },
      ),
    );
    expect(numberOfRebuild, equals(1));
    expect(Injector.getAsModel<int>().state, equals(5));
    Injector.getAsModel<int>().state++;
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    expect(Injector.getAsModel<int>().state, equals(6));
  });

  testWidgets(
      'Injector : should register value and Rebuild StateBuilder with context. case primitive data',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<int>(() => 5),
        ],
        builder: (context, model) {
          Injector.getAsModel<int>(context: context);
          numberOfRebuild++;
          return Container();
        },
      ),
    );
    expect(numberOfRebuild, equals(1));
    expect(Injector.getAsModel<int>().state, equals(5));
    Injector.getAsModel<int>().state++;
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    expect(Injector.getAsModel<int>().state, equals(6));
  });

  testWidgets(
      'Injector : should register value and Rebuild StateBuilder after rebuildStates is called. case reference data',
      (WidgetTester tester) async {
    int numberOfRebuild = 0;
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<List<int>>(() => [1, 2, 3, 4]),
        ],
        builder: (_, model) {
          return StateBuilder(
            viewModels: [Injector.getAsModel<List>()],
            builder: (_, __) {
              numberOfRebuild++;
              return Container();
            },
          );
        },
      ),
    );
    expect(numberOfRebuild, equals(1));
    expect(Injector.getAsModel<List>().state.length, equals(4));
    Injector.getAsModel<List<int>>().setState((state) => state.removeLast());
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    expect(Injector.getAsModel<List>().state.length, equals(3));
  });

  testWidgets('Injector : should register Future', (WidgetTester tester) async {
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject(() => Future.delayed(Duration(seconds: 1), () => false)),
        ],
        builder: (_, model) {
          return Container();
        },
      ),
    );
    final temp = Injector.get<Future>();
    expect(temp, isA<Future<bool>>());
    expect(Injector.get<Future>(), isA<Future<bool>>());
    await tester.pump(Duration(seconds: 2));
  });

  testWidgets('Injector : should register Future and get StatesRebuilder Type',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Injector(
        inject: [
          Inject<bool>.future(
              () => Future.delayed(Duration(seconds: 1), () => false)),
        ],
        builder: (_, model) {
          return Container();
        },
      ),
    );
    final temp = Injector.getAsModel<bool>();
    expect(temp, isA<StatesRebuilder>());
    expect(Injector.getAsModel<bool>(), isA<StatesRebuilder>());
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
        builder: (_, model) {
          return StateBuilder(
            viewModels: [Injector.getAsModel<bool>()],
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
        builder: (context, model) {
          final model = Injector.getAsModel<bool>(context: context);
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
        builder: (_, model) {
          return StateBuilder(
            viewModels: [Injector.getAsModel<int>()],
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
        builder: (context, model) {
          final model = Injector.getAsModel<int>(context: context);
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
        builder: (context, model) {
          final model =
              Injector.getAsModel<int>(context: context, name: "int1");
          streamValueResult1 = model.snapshot.data;
          return streamValueResult1 < 2
              ? Builder(
                  builder: (context) {
                    Injector.getAsModel<int>(context: context, name: "int2");
                    streamValueResult2 = model.snapshot.data;
                    return Container();
                  },
                )
              : Container();
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
    ViewModel vm;
    bool isRebuilt = false;
    int rebuildCount = 0;
    await tester.pumpWidget(
      Injector<ViewModel>(
        models: [
          () => ViewModel(),
          () => Service1(),
          () => Service2(Injector.get<Service1>()),
        ],
        builder: (_, model) {
          vm = model;
          vm.rebuildStates();
          isRebuilt = true;
          rebuildCount++;
          return Container();
        },
      ),
    );

    isRebuilt = false;
    expect(vm, isNot(isNull));
    //notify to rebuild
    vm.rebuildStates();
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
    ViewModel vm;
    bool switcher = true;
    bool initStateIsCalled = false;
    bool disposeStateIsCalled = false;

    await tester.pumpWidget(
      Injector<ViewModel>(
        models: [
          () => ViewModel(),
        ],
        builder: (_, model) {
          vm = model;

          return switcher
              ? Injector(
                  models: [() => Service1()],
                  initState: (model) => initStateIsCalled = true,
                  dispose: (model) => disposeStateIsCalled = true,
                  builder: (context, model) => Container(),
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
    vm.rebuildStates();
    await tester.pump();
    expect(Injector.get<ViewModel>().message, equals("I am injected"));
    expect(() => Injector.get<Service1>(), throwsException);
    expect(initStateIsCalled, isTrue);
    expect(disposeStateIsCalled, isTrue);
  });

  testWidgets(
      'Injector : should get the last registered instance of a model registered twice',
      (WidgetTester tester) async {
    ViewModel vm;

    Service1 service1_1 = Service1();
    Service1 service1_2 = Service1();

    Service1 getService1_1;
    Service1 getService1_2;

    await tester.pumpWidget(
      Injector<ViewModel>(
        models: [
          () => ViewModel(),
          () => service1_1,
        ],
        builder: (_, model) {
          vm = model;
          getService1_1 = Injector.get<Service1>();
          return Injector(
              models: [() => service1_2],
              builder: (context, model) {
                getService1_2 = Injector.get<Service1>();
                return Container();
              });
        },
      ),
    );

    expect(vm, isNot(isNull));

    expect(getService1_1, equals(service1_1));
    expect(getService1_2, equals(service1_2));
  });

  testWidgets(
      'Injector : should register many dependent services with inject parameter',
      (WidgetTester tester) async {
    ViewModel vm;
    bool isRebuilt = false;
    int rebuildCount = 0;
    await tester.pumpWidget(
      Injector<ViewModel>(
        inject: [
          Inject(() => ViewModel()),
          Inject(() => Service1()),
          Inject<IService2>(() => Service2(Injector.get<Service1>())),
        ],
        builder: (_, model) {
          vm = model;
          vm.rebuildStates();
          isRebuilt = true;
          rebuildCount++;
          return Container();
        },
      ),
    );

    isRebuilt = false;
    expect(vm, isNot(isNull));
    //notify to rebuild
    vm.rebuildStates();
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
        builder: (_, model) {
          return Container();
        },
      ),
    );
    expect(Injector.get(name: "myInt"), equals(1));
    expect(Injector.get(name: "myInt"), isA<int>());
  });

  testWidgets(
    "'afterMounted' and 'afterRebuild' called together",
    (WidgetTester tester) async {
      int numberOfCall = 0;
      await tester.pumpWidget(
        Injector<ViewModel>(
          models: [() => ViewModel()],
          afterInitialBuild: (context, tagID) => numberOfCall++,
          afterRebuild: (context, tagID) => numberOfCall++,
          builder: (_, __) => Container(),
        ),
      );

      final vm = Injector.get<ViewModel>();

      expect(numberOfCall, 2);
      vm.rebuildStates();
      await tester.pump();
      expect(numberOfCall, 3);
      vm.rebuildStates();
      await tester.pump();
      expect(numberOfCall, 4);
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
        builder: (_, model) {
          final streamModel = Injector.getAsModel<Integer>();
          return StateBuilder(
            viewModels: [streamModel],
            builder: (_, __) {
              print(streamModel.snapshot?.data?.value);
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
        builder: (context, model) {
          final streamModel = Injector.getAsModel<Integer>(context: context);
          print(streamModel.snapshot?.data?.value);
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
        builder: (_, model) {
          return StateBuilder(
            viewModels: [Injector.getAsModel<Integer>()],
            builder: (_, __) {
              numberOfRebuild++;
              return Container();
            },
          );
        },
      ),
    );
    expect(numberOfRebuild, equals(1));
    expect(Injector.getAsModel<Integer>().state.value, equals(0));
    Injector.getAsModel<Integer>()
        .setState((state) => state.value++, watch: (state) => state.value);
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    expect(Injector.getAsModel<Integer>().state.value, equals(1));
    Injector.getAsModel<Integer>()
        .setState((state) => state.value, watch: (state) => state.value);
    await tester.pump();
    expect(numberOfRebuild, equals(2));
    expect(Injector.getAsModel<Integer>().state.value, equals(1));
  });
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

  @override
  String toString() {
    return '$value';
  }
}
