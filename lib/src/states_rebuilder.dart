import 'package:flutter/material.dart';

import 'common.dart';

///Your logics classes extend `StatesRebuilder` to create your own business logic BloC (alternatively called ViewModel or Model).
class StatesRebuilder {
  Map<String, Map<String, VoidCallback>> _listeners =
      {}; //key holds the listener tags and the value holds the listeners
  Map<String, VoidCallback> _disposer = {};

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

  /// listeners getter
  static Map<String, Map<String, VoidCallback>> listeners(
          StatesRebuilder viewModel) =>
      viewModel._listeners;

  /// Method to add listener to the _listeners Map
  static addToListeners(
      {@required StatesRebuilder viewModel,
      @required String tag,
      @required VoidCallback listener,
      @required String hashCode}) {
    viewModel._listeners[tag] ??= {};
    viewModel._listeners[tag][hashCode] = listener;
  }

  static removeFromListeners(
    StatesRebuilder viewModel,
    String tag,
    String hashCode,
  ) {
    if (listeners(viewModel) != null) {
      final _listeners = listeners(viewModel);
      assert(() {
        if (_listeners[tag] == null) {
          final _keys = _listeners.keys;
          throw FlutterError(
              "ERR(removeFromListeners)01: The tag: $tag is not registered in this VM listeners.\n"
              "If you see this error, please report an issue in the repository.\n"
              "The registered tags are : $_keys");
        }
        return true;
      }());
      List<String> keys = List.from(viewModel._listeners[tag].keys);
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
          viewModel._listeners[tag].remove(k);
          return;
        }
      });
      print(viewModel._listeners);
      if (viewModel._listeners[tag].isEmpty) {
        viewModel._listeners.remove(tag);
        if (viewModel._disposer[tag] != null) {
          viewModel._disposer[tag]();
          viewModel._disposer.remove(tag);
        }
      }

      if (viewModel._listeners.isEmpty) {
        viewModel._disposer.forEach((k, v) {
          v();
        });
        viewModel._disposer = {};
      }
    }
  }
}
