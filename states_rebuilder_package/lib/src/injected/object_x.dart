part of '../reactive_model.dart';

extension ObjectX on Object {
  Injected<T> inj<T>() {
    return RM.inject<T>(() => this as T, initialState: this as T);
  }
}

extension IntX on int {
  Injected<int> inj() {
    return RM.inject(() => this, initialState: 0);
  }
}

extension DoubleX on double {
  Injected<double> inj() {
    return RM.inject(() => this, initialState: 0.0);
  }
}

extension StringX on String {
  Injected<String> inj() {
    return RM.inject(() => this, initialState: '');
  }
}

extension BoolX on bool {
  Injected<bool> inj() {
    return RM.inject(() => this, initialState: false);
  }
}

extension ListX<T> on List<T> {
  Injected<List<T>> inj() {
    return RM.inject(() => this, initialState: <T>[]);
  }
}

extension SetX<T> on Set<T> {
  Injected<Set<T>> inj() {
    return RM.inject(() => this, initialState: <T>{});
  }
}

extension MapX<T, D> on Map<T, D> {
  Injected<Map<T, D>> inj() {
    return RM.inject(() => this, initialState: <T, D>{});
  }
}
