import 'package:flutter/material.dart';

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder {
  Map<String, Map<String, VoidCallback>> _listeners =
      {}; //key holds the listener tags and the value holds the listeners

  /// Method to add listener to the _listeners Map
  addToListeners(
      {@required String tag,
      @required VoidCallback listener,
      @required String hashcode}) {
    _listeners[tag] ??= {};
    _listeners[tag][hashcode] = listener;
  }

  removeFromListeners(String tag, String hashcode) {
    List<String> keys = List.from(listeners[tag]?.keys);
    if (keys == null) return;
    keys.forEach((k) {
      if (k == hashcode) {
        listeners[tag].remove(k);

        return;
      }
    });
    if (listeners[tag].isEmpty) {
      listeners.remove(tag);
    }
  }

  /// listeners getter
  Map<String, Map<String, VoidCallback>> get listeners => _listeners;

  String spliter = "";

  /// You call `rebuildState` inside any of your logic classes that extends `StatesRebuilder`.
  rebuildStates([List<dynamic> tags]) {
    if (tags == null) {
      _listeners.forEach((_, v) {
        v?.forEach((__, listener) {
          if (listener != null) listener();
        });
      });
    } else {
      for (final tag in tags) {
        if (tag is String) {
          final split = tag?.split(spliter);
          if (split.length > 1 && _listeners[split[0]] != null) {
            _listeners[split[0]][split.last]();
            continue;
          }
        }

        final listenerList = _listeners["$tag"];
        listenerList?.forEach((_, listener) {
          if (listener != null) listener();
        });
      }
    }
  }
}
