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
      'Injector : should register models and should not rebuild if the generic type of Injector is not defined',
      (WidgetTester tester) async {
    ViewModel vm;
    bool isRebuilt = false;
    await tester.pumpWidget(
      Injector(
        models: [() => ViewModel()],
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
    expect(Injector.get<Service1>(), isNull); //Service1 is unregistered
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
          Inject(() => 1, "myInt"),
          Inject(() => [1, 2], "myList"),
          Inject(() => "Hollo World", "mySting"),
        ],
        builder: (_, model) {
          return Container();
        },
      ),
    );
    expect(Injector.get("myInt"), equals(1));
    expect(Injector.get("myInt"), isA<int>());
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
