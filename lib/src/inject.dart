import 'dart:async';
import 'package:states_rebuilder/src/model_states_rebuilder.dart';

abstract class Injectable {}

class Inject<T> implements Injectable {
  /// The Creation Function.
  T Function() _creationFunction;

  /// The creation Function. It must return a Future.
  Future<T> Function() _creationFutureFunction;

  /// The creation Function. It must return a Stream.
  Stream<T> Function() _creationStreamFunction;

  /// The initial value.
  T initialValue;

  /// True if the injected model is instantiated lazily; that is at the time of the first use with [getAsModel] and [get].
  ///
  /// False if the injected model is instantiated at the time of the injection.
  ///
  ///Default value is `true`.
  bool isLazy;

  ///A function that returns a single model instance variable or a list of
  ///them. The rebuild process will be triggered if at least one of
  ///the return variable changes.
  ///
  ///Return variable must be either a primitive variable, a List, a Map or a Set.
  ///
  ///To use a custom type, you should override the `toString` method to reflect
  ///a unique identity of each instance.
  ///
  ///If it is not defined all listener will be notified when a new state is available.
  dynamic Function(T) watch;

  /// List of [StateBuilder]'s tags to be notified to rebuild.
  List tags;

  ///The custom name to be used instead of the type to get the injected instance.
  dynamic name;

  bool _isFutureType = false;
  bool _isStreamType = false;
  bool get isAsyncType => _isFutureType || _isStreamType;

  String _name; // cache for name
  T _singleton; // vanilla instance cache
  ModelStatesRebuilder<T> _asyncSingleton; // reactive instance cache

  ///Inject a value or a model
  Inject(this._creationFunction, {this.name, this.isLazy = true}) {
    if (name != null) _name = name.toString();
  }

  ///Inject a Future
  Inject.future(
    this._creationFutureFunction, {
    this.name,
    this.initialValue,
    this.isLazy = true,
    this.tags,
  }) {
    if (name != null) _name = name.toString();
    _isFutureType = true;
  }

  ///Inject a Stream
  Inject.stream(
    this._creationStreamFunction, {
    this.name,
    this.initialValue,
    this.isLazy = true,
    this.watch,
    this.tags,
  }) {
    if (name != null) _name = name.toString();
    _isStreamType = true;
  }

  String getName() {
    if (_name == null) {
      if ('$T' == "dynamic") {
        _name = _creationFunction.runtimeType
            .toString()
            .replaceAll("() => ", "")
            .replaceAll(RegExp(r'<.*>'), "");
      } else {
        _name = '$T'.replaceAll(RegExp(r'<.*>'), "");
      }
    }
    if (!isLazy) {
      getSingleton();
    }
    return _name;
  }

  T getSingleton() {
    if (_singleton == null) {
      _singleton = _creationFunction();
    }
    return _singleton;
  }

  T getInstance() {
    return _creationFunction();
  }

  ModelStatesRebuilder<T> getModelSingleton() {
    if (_asyncSingleton == null) {
      if (_isFutureType) {
        _asyncSingleton = StreamStatesRebuilder<T>(
          _creationFutureFunction().asStream(),
          initialValue,
          watch,
          tags,
        );
      } else if (_isStreamType) {
        _asyncSingleton = StreamStatesRebuilder<T>(
          _creationStreamFunction(),
          initialValue,
          watch,
          tags,
        );
      } else {
        _asyncSingleton = ValueStatesRebuilder<T>(getSingleton());
      }
    }
    return _asyncSingleton;
  }

  ModelStatesRebuilder<T> getModelInstance() {
    if (_isFutureType) {
      return StreamStatesRebuilder<T>(
        _creationFutureFunction().asStream(),
        initialValue,
        watch,
        tags,
      );
    } else if (_isStreamType) {
      return StreamStatesRebuilder<T>(
          _creationStreamFunction(), initialValue, watch, tags);
    } else {
      return ValueStatesRebuilder<T>(getInstance());
    }
  }
}
