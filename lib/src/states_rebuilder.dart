import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'common.dart';

abstract class ListenerOfStatesRebuilder {
  bool update([void Function(BuildContext) onRebuildCallBack]);
}

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder implements Subject {
  //key holds the observer tags and the value holds the observers
  //_observers = {"tag" : [ observer]}
  LinkedHashMap<String, List<ListenerOfStatesRebuilder>> _observers =
      LinkedHashMap();

  List<VoidCallback> _cleanerVoidCallBackList = [];

  ///Define a function to be called each time a tag is removed
  Function(String) statesRebuilderCleaner;

  /// observers getter
  Map<String, List<ListenerOfStatesRebuilder>> observers() => _observers;

  ///Check whether the model has observing states
  bool get hasState => _observers.isNotEmpty;

  ///Map of custom listeners to be called when rebuildStates is called
  LinkedHashMap<BuildContext, bool Function([void Function(BuildContext)])>
      customListener = LinkedHashMap();

  /// You call `rebuildState` inside any of your logic classes that extends `StatesRebuilder`.
  @override
  void rebuildStates(
      [List<dynamic> tags, void Function(BuildContext) onRebuildCallBack]) {
    assert(() {
      if (!hasState && customListener.isEmpty) {
        throw Exception("ERR(rebuildStates)01: No observer is registered yet.\n"
            "You have to register at least one observer using the `StateBuilder` or StateWithMixinBuilder` widgets.\n"
            "If you are sure you have registered at least one observer and you still see this error, please report an issue in the repository.\n");
      }
      return true;
    }());

    bool _onRebuildCallBackIsCalled = false;
    if (tags == null) {
      final _keys = _observers.keys.toList()?.reversed;

      for (final key in _keys) {
        final observerList = _observers[key];
        if (observerList != null) {
          for (ListenerOfStatesRebuilder observer in observerList) {
            if (onRebuildCallBack != null &&
                _onRebuildCallBackIsCalled == false) {
              _onRebuildCallBackIsCalled =
                  observer?.update(onRebuildCallBack) == true;
            } else {
              observer?.update();
            }
          }
        }
      }

      LinkedHashMap<BuildContext, bool Function([void Function(BuildContext)])>
          _customListener =
          Map<BuildContext, bool Function([void Function(BuildContext)])>.from(
              customListener);

      _customListener.forEach(
          (BuildContext ctx, bool Function([void Function(BuildContext)]) fn) {
        if (onRebuildCallBack != null && _onRebuildCallBackIsCalled == false) {
          _onRebuildCallBackIsCalled = fn(onRebuildCallBack);
        } else {
          fn();
        }
      });

      return;
    }

    for (final dynamic tag in tags) {
      final List<ListenerOfStatesRebuilder> observerList = _observers["$tag"];
      if (observerList != null) {
        for (ListenerOfStatesRebuilder observer in observerList) {
          if (onRebuildCallBack != null &&
              _onRebuildCallBackIsCalled == false) {
            _onRebuildCallBackIsCalled = observer?.update(onRebuildCallBack);
          } else {
            observer?.update();
          }
        }
      }
    }
  }

  /// Method to add observer
  @override
  void addObserver({
    @required String tag,
    @required ListenerOfStatesRebuilder observer,
  }) {
    if (tag == null || observer == null) return;
    _observers[tag] =
        _observers[tag] == null ? [observer] : [observer, ..._observers[tag]];
  }

  ///Method to remove observer
  @override
  void removeObserver({
    @required String tag,
    @required ListenerOfStatesRebuilder observer,
  }) {
    if (tag != null) {
      assert(() {
        if (_observers[tag] == null) {
          final _keys = _observers.keys;
          throw Exception(
              "ERR(removeFromObservers)01: The tag: $tag is not registered in this VM observers.\n"
              "If you see this error, please report an issue in the repository.\n"
              "The registered tags are : $_keys");
        }
        return true;
      }());

      _observers[tag].remove(observer);
      if (_observers[tag].isEmpty) {
        if (statesRebuilderCleaner != null) statesRebuilderCleaner(tag);
        _observers.remove(tag);

        if (_observers.isEmpty) {
          if (statesRebuilderCleaner != null) statesRebuilderCleaner(null);
          statesRebuilderCleaner = null;
          if (customListener.isEmpty) {
            _cleanerVoidCallBackList?.forEach((VoidCallback voidCallBack) {
              if (voidCallBack != null) {
                voidCallBack();
              }
            });
            _cleanerVoidCallBackList.clear();
          }
        }
      }
    } else {
      _cleanerVoidCallBackList?.forEach((VoidCallback voidCallBack) {
        if (voidCallBack != null) {
          voidCallBack();
        }
      });
      _cleanerVoidCallBackList.clear();
    }
  }

  ///Add a callback to be executed when all listeners are removed
  void cleaner(VoidCallback voidCallback) {
    _cleanerVoidCallBackList.add(voidCallback);
  }
}
