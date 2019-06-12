import 'package:flutter/material.dart';

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder {
  Map<String, Map<String, VoidCallback>> _listeners =
      {}; //key holds the listener tags and the value holds the listeners
  Map<String, VoidCallback> _disposer = {};

  /// Method to add listener to the _listeners Map
  addToListeners(
      {@required String tag,
      @required VoidCallback listener,
      @required String hashCode}) {
    _listeners[tag] ??= {};
    _listeners[tag][hashCode] = listener;
  }

  removeFromListeners(
    String tag,
    String hashCode,
  ) {
    assert(() {
      if (listeners[tag] == null) {
        final _keys = listeners.keys;
        throw FlutterError(
            "ERR(removeFromListeners)01: The tag: $tag is not registered in this VM listeners.\n"
            "If you see this error, please report an issue in the repository.\n"
            "The registered tags are : $_keys");
      }
      return true;
    }());
    List<String> keys = List.from(listeners[tag].keys);
    assert(() {
      if (keys == null) {
        throw FlutterError(
            "ERR(removeFromListeners)02: The Map list referred  by '$tag' tag is empty. It should be removed from this VM listeners.\n"
            "If you see this error, please report an issue in the repository.\n");
      }
      return true;
    }());

    keys.forEach((k) {
      if (k == hashCode) {
        listeners[tag].remove(k);
        return;
      }
    });
    if (listeners[tag].isEmpty) {
      listeners.remove(tag);
      if (_disposer[tag] != null) {
        _disposer[tag]();
        _disposer.remove(tag);
      }
    }

    if (_listeners.isEmpty) {
      _disposer.forEach((k, v) {
        v();
      });
      _disposer = {};
    }
  }

  /// listeners getter
  Map<String, Map<String, VoidCallback>> get listeners => _listeners;

  String splitter = "";

  /// You call `rebuildState` inside any of your logic classes that extends `StatesRebuilder`.
  rebuildStates([List<dynamic> tags]) {
    assert(() {
      if (_listeners.isEmpty) {
        throw FlutterError(
            "ERR(rebuildStates)01: No listener is registered yet.\n"
            "You have to register at least one listener using the `StateBuilder` or StateWithMixinBuilder` widgets.\n"
            "If you are sure you have registered at least one listener and you still see this error, please report an issue in the repository.\n");
      }
      return true;
    }());
    if (tags == null) {
      _listeners.forEach((t, v) {
        v?.forEach((h, listener) {
          if (listener != null) {
            listener();
          } else {
            throw FlutterError(
                "ERR(rebuildStates)02: The listener registered with tag '$t -- $h' is null.\n"
                "If you see this error, please report an issue in the repository.\n");
          }
        });
      });
    } else {
      for (final tag in tags) {
        if (tag is String) {
          final split = tag?.split(splitter);
          if (split.length == 2) {
            final _listenerTag = _listeners[split[0]];
            if (_listenerTag == null) {
              throw FlutterError(
                  "ERR(rebuildStates)03: The tag: '${split[0]}' is not registered in this VM listeners.\n"
                  "If you see this error, please report an issue in the repository.\n");
            } else {
              final _listenerHash = _listenerTag[split.last];
              if (_listenerHash == null) {
                throw Exception(
                    "ERR(rebuildStates)04: The tag: ${split[0]} -- ${split.last}  is not registered in this VM listeners or the listener is null.\n"
                    "If you see this error, please report an issue in the repository.\n");
              } else {
                _listenerHash();
                continue;
              }
            }
          }
        }

        final listenerList = _listeners["$tag"];
        listenerList?.forEach((t, listener) {
          if (listener != null) {
            listener();
          } else {
            throw FlutterError(
                "ERR(rebuildStates)05: The listener registered with tag: '$t' is null.\n"
                "If you see this error, please report an issue in the repository.\n");
          }
        });
      }
    }
  }
}
