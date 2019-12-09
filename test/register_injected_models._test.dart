import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/register_injected_models.dart';

void main() {
  final _allRegisteredModelInApp = InjectorState.allRegisteredModelInApp;

  //Models to register
  List<Inject> models1;

  setUp(() {
    _allRegisteredModelInApp.clear();
  });

  group("RegisterInjectedModel :", () {
    test(" should register three entries", () {
      models1 = [
        Inject<int>(() => 1),
        Inject<Service1>(() => Service1()),
        Inject<List>(() => [2, "myName"]),
      ];
      RegisterInjectedModel(
        models1,
        _allRegisteredModelInApp,
      );
      expect(_allRegisteredModelInApp.length, equals(3));
      expect(_allRegisteredModelInApp["int"][0].getName(), "int");
      expect(
          _allRegisteredModelInApp["Service1"][0].getNewInstance() is Service1,
          isTrue);
      expect(_allRegisteredModelInApp["List<dynamic>"][0].getNewInstance()[1],
          equals("myName"));
    });

    test(
        " should register the same instance of Service twice with the same key",
        () {
      models1 = [
        Inject<int>(() => 1),
        Inject<Service1>(() => Service1()),
        Inject<List<dynamic>>(() => [2, "myName"]),
      ];

      RegisterInjectedModel(models1, _allRegisteredModelInApp);

      models1 = [
        Inject<Service1>(() => Service1()),
      ];

      RegisterInjectedModel(
        models1,
        _allRegisteredModelInApp,
      );

      expect(_allRegisteredModelInApp.length, equals(3));
      expect(_allRegisteredModelInApp["Service1"].length, equals(2));
      expect(
          _allRegisteredModelInApp["Service1"][0] ==
              _allRegisteredModelInApp["Service1"][1],
          isTrue);
    });
  });

  group("unRegisterInjectedModel : ", () {
    test("should remove Models from _allRegisteredModelInApp ", () {
      final num1 = Inject(() => 1);
      final service1 = Inject(() => Service1());

      final modelRegisterer =
          RegisterInjectedModel([num1, service1], _allRegisteredModelInApp);

      expect(_allRegisteredModelInApp.length, equals(2));

      modelRegisterer.unRegisterInjectedModels(false);

      expect(_allRegisteredModelInApp.length, equals(0));
    });

    test(
        "should remove Models from _allRegisteredModelInApp case of Service Registers twice",
        () {
      final num1 = Inject(() => 1);
      final service1_1 = Inject(() => Service1());
      final service1_2 = Inject(() => service1_1.getSingleton());

      final modelRegisterer1 =
          RegisterInjectedModel([service1_1], _allRegisteredModelInApp);

      final modelRegisterer2 =
          RegisterInjectedModel([num1, service1_2], _allRegisteredModelInApp);

      expect(_allRegisteredModelInApp.length, equals(2));
      expect(_allRegisteredModelInApp['Service1'].length, equals(2));
      modelRegisterer2.unRegisterInjectedModels(false);
      expect(_allRegisteredModelInApp.length, equals(1));
      expect(_allRegisteredModelInApp['Service1'].length, equals(1));

      modelRegisterer1.unRegisterInjectedModels(false);

      expect(_allRegisteredModelInApp.length, equals(0));
    });

    test("should remove Models and clean if of type asyncType ", () {
      final service1 = Inject(() => Service1());
      bool isCleaned = false;
      final modelRegisterer =
          RegisterInjectedModel([service1], _allRegisteredModelInApp);

      expect(_allRegisteredModelInApp.length, equals(1));

      final model = service1.getReactiveSingleton();
      model.cleaner(() => isCleaned = true);

      modelRegisterer.unRegisterInjectedModels(false);

      expect(_allRegisteredModelInApp.length, equals(0));
      expect(isCleaned, isTrue);
    });
  });

  test("should throw if getting unRegistered instance", () {
    expect(() => Injector.get<int>(), throwsException);
    expect(Injector.get<int>(silent: true), isNull);
  });

  group("Injector.get<T>()", () {
    test("should get registered instance", () {
      final num1 = Inject<int>(() => 1);
      final service1 = Inject<Service1>(() => Service1());
      final list1 = Inject<List<dynamic>>(() => [2, "myName"]);
      models1 = [
        num1,
        service1,
        list1,
      ];

      RegisterInjectedModel(models1, _allRegisteredModelInApp);

      expect(Injector.get<int>(), equals(1));
      expect(Injector.get<Service1>(), equals(service1.getSingleton()));
      expect(Injector.get<List<dynamic>>(), equals(list1.getSingleton()));
    });
  });

  test("should dispose instances ", () {
    final num1 = Inject(() => 1);
    final service1 = Inject(() => Service1());

    final models = [num1, service1];
    final modelRegisterer =
        RegisterInjectedModel(models, _allRegisteredModelInApp);

    modelRegisterer.unRegisterInjectedModels(true);

    expect(isDisposed, isTrue);
  });

  test("should dispose instances and clean _allRegisteredModelInApp", () {
    final num1 = Inject(() => 1);
    final service1 = Inject(() => Service1());

    final models = [num1, service1];
    final modelRegisterer =
        RegisterInjectedModel(models, _allRegisteredModelInApp);

    modelRegisterer.unRegisterInjectedModels(true);

    expect(_allRegisteredModelInApp.length == 0, isTrue);

    expect(isDisposed, isTrue);
  });
}

bool isDisposed = false;

class Service1 {
  dispose() {
    isDisposed = true;
  }
}
