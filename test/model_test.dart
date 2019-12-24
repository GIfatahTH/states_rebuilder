import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';

void main() {
  test('Model name is The type of the generic type', () {
    final model = Inject<IService>(() => Service());

    expect(model.getName(), equals('IService'));
  });

  test('Model name the type of the function if no generic type', () {
    final model = Inject(() => Service());

    expect(model.getName(), equals('Service'));
  });

  test('Model name is the custom name', () {
    final model = Inject(() => Service(), name: 'MyService');
    expect(model.getName(), equals('MyService'));
  });

  test('Model name is int', () {
    final model = Inject(() => 1);
    expect(model.getName(), equals('int'));
  });

  test('getSingleton return the same instance', () {
    final model = Inject(() => Service(), name: 'MyService');
    final instance1 = model.getSingleton();
    final instance2 = model.getSingleton();
    expect(instance1.hashCode == instance2.hashCode, isTrue);
  });
}

class IService {}

class Service implements IService {}
