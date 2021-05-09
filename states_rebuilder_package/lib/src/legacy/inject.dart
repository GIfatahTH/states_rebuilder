import 'dart:async';

import '../rm.dart';

import 'injector.dart';

abstract class Injectable {}

///Base class for [Inject]
class Inject<T> extends Injectable {
  Inject._(this.injected, this._name);

  final ReactiveModel<T> injected;
  String? _name;

  ///Inject a value or a model.
  factory Inject(
    T Function() creationFunction, {
    dynamic name,
    bool isLazy = true,
  }) {
    return Inject._(
      ReactiveModel(creator: creationFunction),
      name,
    );
  }

  factory Inject.future(
    Future<T> Function() creationFutureFunction, {
    dynamic name,
    bool isLazy = false,
    T? initialValue,
  }) {
    return Inject._(
      ReactiveModel.future(
        creationFutureFunction,
        initialState: initialValue,
      ),
      name,
    );
  }

  factory Inject.stream(
    Stream<T> Function() creationFutureFunction, {
    dynamic name,
    bool isLazy = false,
    T? initialValue,
    Object? Function(T?)? watch,
  }) {
    return Inject._(
      ReactiveModel.stream(
        creationFutureFunction,
        initialState: initialValue,
      ),
      name,
    );
  }

  ///Injected a map of flavor
  factory Inject.interface(
    Map<dynamic, FutureOr<T> Function()> impl, {
    dynamic name,
    // bool isLazy = false,
    T? initialValue,
  }) {
    // ignore: deprecated_member_use_from_same_package
    RM.env = Injector.env;
    return Inject._(
      ReactiveModel(creator: () {
        return RM
            .injectFlavor(
              impl,
              isLazy: false,
              initialState: initialValue,
              autoDisposeWhenNotUsed: false,
            )
            .state;
      }),
      name,
    );
  }

  String getName() {
    assert(T != dynamic);
    assert(T != Object);
    return _name ??= '$T';
  }

  bool isGlobal = false;
}
