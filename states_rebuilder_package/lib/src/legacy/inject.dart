import 'dart:async';

import 'package:states_rebuilder/src/reactive_model.dart';

import 'injector.dart';

abstract class Injectable {}

///Base class for [Inject]
class Inject<T> extends Injectable {
  Inject._(this.injected, this._name);

  final Injected<T> injected;
  String? _name;

  ///Inject a value or a model.
  factory Inject(
    T Function() creationFunction, {
    dynamic name,
    bool isLazy = true,
  }) {
    return Inject._(
      RM.inject(
        creationFunction,
        isLazy: isLazy,
        autoDisposeWhenNotUsed: false,
      ),
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
      RM.injectFuture(
        creationFutureFunction,
        isLazy: isLazy,
        initialState: initialValue,
        autoDisposeWhenNotUsed: false,
        debugPrintWhenNotifiedPreMessage: 'future',
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
      RM.injectStream(
        creationFutureFunction,
        isLazy: isLazy,
        initialState: initialValue,
        watch: watch,
        autoDisposeWhenNotUsed: false,
      ),
      name,
    );
  }

  ///Injected a map of flavor
  factory Inject.interface(
    Map<dynamic, FutureOr<T> Function()> impl, {
    dynamic name,
    bool isLazy = false,
    T? initialValue,
  }) {
    // ignore: deprecated_member_use_from_same_package
    RM.env = Injector.env;
    return Inject._(
      RM.injectFlavor(
        impl,
        isLazy: isLazy,
        initialState: initialValue,
        autoDisposeWhenNotUsed: false,
      ),
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
