import '../rm.dart';

/// Extension on int
extension IntX on int {
  /// create a [ReactiveModel] state
  ReactiveModel<int> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<int>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }

  /// Duration on seconds
  Duration get seconds => Duration(seconds: this);

  /// Duration on milliseconds
  Duration get milliseconds => Duration(milliseconds: this);

  /// Duration on minutes
  Duration get minutes => Duration(minutes: this);

  /// Duration on hours
  Duration get hours => Duration(hours: this);
}

/// Extension on double
extension DoubleX on double {
  /// create a [ReactiveModel] state
  ReactiveModel<double> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<double>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

/// Extension on String
extension StringX on String {
  /// create a [ReactiveModel] state
  ReactiveModel<String> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<String>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

/// Extension on bool
extension BoolX on bool {
  /// create a [ReactiveModel] state
  ReactiveModel<bool> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<bool>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

/// Extension on List<T>
extension ListX<T> on List<T> {
  /// create a [ReactiveModel] state
  ReactiveModel<List<T>> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<List<T>>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

/// Extension on Set
extension SetX<T> on Set<T> {
  /// create a [ReactiveModel] state
  ReactiveModel<Set<T>> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<Set<T>>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

/// Extension on Map
extension MapX<T, D> on Map<T, D> {
  /// create a [ReactiveModel] state
  ReactiveModel<Map<T, D>> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<Map<T, D>>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}

/// Extension on Null
extension NullX on Null {
  /// create a [ReactiveModel] state
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

/// Extension on type
extension TypeX<T> on T {
  /// create a [ReactiveModel] state
  ReactiveModel<T> inj({bool autoDisposeWhenNotUsed = true}) {
    return ReactiveModel<T>.create(
      creator: () => this,
      initialState: this,
      autoDisposeWhenNotUsed: autoDisposeWhenNotUsed,
    );
  }
}
