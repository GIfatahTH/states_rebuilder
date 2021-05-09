import '../rm.dart';

extension IntX on int {
  InjectedBase<int> inj() {
    return ReactiveModel(creator: () => this, initialState: 0);
  }
}

extension DoubleX on double {
  InjectedBase<double> inj() {
    return ReactiveModel(creator: () => this, initialState: 0.0);
  }
}

extension StringX on String {
  InjectedBase<String> inj() {
    return ReactiveModel(creator: () => this, initialState: '');
  }
}

extension BoolX on bool {
  InjectedBase<bool> inj() {
    return ReactiveModel(creator: () => this, initialState: false);
  }
}

extension ListX<T> on List<T> {
  InjectedBase<List<T>> inj() {
    return ReactiveModel(creator: () => this, initialState: <T>[]);
  }
}

extension SetX<T> on Set<T> {
  InjectedBase<Set<T>> inj() {
    return ReactiveModel(creator: () => this, initialState: <T>{});
  }
}

extension MapX<T, D> on Map<T, D> {
  InjectedBase<Map<T, D>> inj() {
    return ReactiveModel(creator: () => this, initialState: <T, D>{});
  }
}
