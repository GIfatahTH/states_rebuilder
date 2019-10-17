import 'dart:async';
import 'package:states_rebuilder/src/model_states_rebuilder.dart';

abstract class Injectable {}

class Inject<T> implements Injectable {
  /// Creation Function
  T Function() _creationFunction;

  /// Creation Function. It mast return a Future
  Future<T> Function() _creationFutureFunction;

  /// Creation Function. It mast return a Stream
  Stream<T> Function() _creationStreamFunction;

  ///Initial value
  T initialValue;

  bool _isFutureType = false;
  bool _isStreamType = false;
  bool isLazy;

  bool get isAsyncType => _isFutureType || _isStreamType;

  String _name;
  T _singleton;
  ModelStatesRebuilder<T> _asyncSingleton;

  ///Inject a value or a model
  Inject(this._creationFunction, {dynamic name, this.isLazy = true}) {
    if (name != null) _name = name.toString();
  }

  ///Inject a Future
  Inject.future(this._creationFutureFunction,
      {dynamic name, this.initialValue, this.isLazy = true}) {
    if (name != null) _name = name.toString();
    _isFutureType = true;
  }

  ///Inject a Stream
  Inject.stream(this._creationStreamFunction,
      {dynamic name, this.initialValue, this.isLazy = true}) {
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
            _creationFutureFunction().asStream(), initialValue);
      } else if (_isStreamType) {
        _asyncSingleton =
            StreamStatesRebuilder<T>(_creationStreamFunction(), initialValue);
      } else {
        _asyncSingleton = ValueStatesRebuilder<T>(getSingleton());
      }
    }
    return _asyncSingleton;
  }

  ModelStatesRebuilder<T> getModelInstance() {
    if (_isFutureType) {
      return StreamStatesRebuilder<T>(
          _creationFutureFunction().asStream(), initialValue);
    } else if (_isStreamType) {
      return StreamStatesRebuilder<T>(_creationStreamFunction(), initialValue);
    } else {
      return ValueStatesRebuilder<T>(getInstance());
    }
  }
}
