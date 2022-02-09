import '../rm.dart';

extension IntX on int {
  ReactiveModel<int> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<int>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }

  Duration get seconds => Duration(seconds: this);
  Duration get milliseconds => Duration(milliseconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
}

extension DoubleX on double {
  ReactiveModel<double> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<double>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

extension StringX on String {
  ReactiveModel<String> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<String>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

extension BoolX on bool {
  ReactiveModel<bool> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<bool>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

extension ListX<T> on List<T> {
  ReactiveModel<List<T>> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<List<T>>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

extension SetX<T> on Set<T> {
  ReactiveModel<Set<T>> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<Set<T>>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

extension MapX<T, D> on Map<T, D> {
  ReactiveModel<Map<T, D>> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<Map<T, D>>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

extension NullX on Null {
  ReactiveModel<T?> inj<T>({bool autoDisposeWhenNotUsed = true}) {
    assert(T != dynamic);
    assert(T != Object);
    assert(T != typeDef<Object?>());
    // assert(null is T, '$T is not nullable type. User $T?');
    return ReactiveModel<T?>.create(
      creator: () => this,
      initialState: null,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

extension TypeX<T> on T {
  ReactiveModel<T> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<T>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}
