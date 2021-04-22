import '../rm.dart';

extension IntX on int {
  Injected<int> inj() {
    return ReactiveModel(creator: () => this, initialState: 0);
  }
}

extension DoubleX on double {
  Injected<double> inj() {
    return ReactiveModel(creator: () => this, initialState: 0.0);
  }
}

extension StringX on String {
  Injected<String> inj() {
    return ReactiveModel(creator: () => this, initialState: '');
  }
}

extension BoolX on bool {
  Injected<bool> inj() {
    return ReactiveModel(creator: () => this, initialState: false);
  }
}

extension ListX<T> on List<T> {
  Injected<List<T>> inj() {
    return ReactiveModel(creator: () => this, initialState: <T>[]);
  }
}

extension SetX<T> on Set<T> {
  Injected<Set<T>> inj() {
    return ReactiveModel(creator: () => this, initialState: <T>{});
  }
}

extension MapX<T, D> on Map<T, D> {
  Injected<Map<T, D>> inj() {
    return ReactiveModel(creator: () => this, initialState: <T, D>{});
  }
}
