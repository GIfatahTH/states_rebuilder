import 'dart:async';

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
      @required String hashcode}) {
    _listeners[tag] ??= {};
    _listeners[tag][hashcode] = listener;
  }

  removeFromListeners(
    String tag,
    String hashcode,
  ) {
    assert(() {
      if (listeners[tag] == null) {
        final _keys = listeners.keys;
        throw FlutterError(
            "ERR(removeFromListeners)01: The tag: $tag is not registered in this VM listeners.\n"
            "If you see this error, please report an issue in the repo.\n"
            "The registered tags are : $_keys");
      }
      return true;
    }());
    List<String> keys = List.from(listeners[tag].keys);
    assert(() {
      if (keys == null) {
        throw FlutterError(
            "ERR(removeFromListeners)02: The Map list referred  by '$tag' tag is empty. It should be removed from this VM listeners.\n"
            "If you see this error, please report an issue in the repo.\n");
      }
      return true;
    }());

    keys.forEach((k) {
      if (k == hashcode) {
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

  String spliter = "";

  /// You call `rebuildState` inside any of your logic classes that extends `StatesRebuilder`.
  rebuildStates([List<dynamic> tags]) {
    assert(() {
      if (_listeners.isEmpty) {
        throw FlutterError(
            "ERR(rebuildStates)01: No listener is registered yet.\n"
            "You have to register at least one listener using the `StateBuilder` or StateWithMixinBuilder` widgets.\n"
            "If you are sure you have registered at least one listener and you still see this error, please report an issue in the repo.\n");
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
                "If you see this error, please report an issue in the repo.\n");
          }
        });
      });
    } else {
      for (final tag in tags) {
        if (tag is String) {
          final split = tag?.split(spliter);
          if (split.length == 2) {
            final _listenerTag = _listeners[split[0]];
            if (_listenerTag == null) {
              throw FlutterError(
                  "ERR(rebuildStates)03: The tag: '${split[0]}' is not registered in this VM listeners.\n"
                  "If you see this error, please report an issue in the repo.\n");
            } else {
              final _listenerHash = _listenerTag[split.last];
              if (_listenerHash == null) {
                throw Exception(
                    "ERR(rebuildStates)04: The tag: ${split[0]} -- ${split.last}  is not registered in this VM listeners or the listener is null.\n"
                    "If you see this error, please report an issue in the repo.\n");
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
                "If you see this error, please report an issue in the repo.\n");
          }
        });
      }
    }
  }

  rebuildFromStreams<T>({
    List<Stream<T>> streams,
    List<StreamController<T>> controllers,
    List<T> initialData,
    @required List<dynamic> tags,
    List<StreamTransformer> transforms,
    void Function(AsyncSnapshot<T>) snapshotMerged,
    void Function(AsyncSnapshot<T>) snapshotCombined,
    void Function(List<AsyncSnapshot<T>>) snapshots,
    Object Function(List<AsyncSnapshot<T>>) combine,
  }) {
    List<StreamSubscription<T>> _subscription = [];
    List<AsyncSnapshot<T>> _summary = [];
    if (streams == null || streams.isEmpty) {
      if (controllers != null && controllers.isNotEmpty) {
        streams = [];
        controllers.forEach((c) => streams.add(c.stream));
      } else {
        throw FlutterError(
            "ERR(rebuildFromStreams)01: You have to define controller or streams");
      }
    }
    final streamLength = streams.length;
    int _summaryLength;
    if (transforms != null && transforms.isNotEmpty && streams != null) {
      streams.asMap().forEach((k, e) {
        if (transforms.length == streamLength || transforms.length == 1) {
          streams[k] = streams[k].transform(transforms.length == streamLength
              ? transforms[k]
              : transforms[0]);
        } else {
          throw FlutterError(
              "ERR(rebuildFromStreams)02: transform length is different from the stream or controller length.\n"
              "You can provide one transformer to be applied to all the streams");
        }
      });
    }
    bool hasData() => !_summary.any((e) => e.hasData == false);
    inner(int index, [bool rebuild = true]) {
      if (snapshotCombined != null) {
        AsyncSnapshot<T> snapshot;
        if (!hasData()) {
          if (_summary[index].hasError) {
            snapshot = AsyncSnapshot<T>.withError(
                ConnectionState.active, _summary[index].error);
          } else {
            final _snapshot = _summary.firstWhere(
              (e) {
                return !e.hasData;
              },
            );
            snapshot = AsyncSnapshot<T>.withError(
                ConnectionState.active, _snapshot.error);
          }
        } else {
          snapshot = AsyncSnapshot<T>.withData(
              ConnectionState.active,
              combine != null && _summaryLength == streamLength
                  ? combine(_summary)
                  : _summary[index].data);
        }
        snapshotCombined(snapshot);
      }

      if (snapshots != null && _summaryLength == streamLength)
        snapshots(_summary);
      if (snapshotMerged != null) snapshotMerged(_summary[index]);
      if (tags != null) {
        if (tags.length == streamLength || tags.length == 1) {
          if (_listeners.isNotEmpty && rebuild) {
            rebuildStates(
                tags.length == streams.length ? [tags[index]] : tags[0]);
          }
        } else {
          throw FlutterError(
              "ERR(rebuildFromStreams)03: tag length is different from the stream or controller length.\n"
              "You can provide one tag to be applied to all the streams");
        }
      }
    }

    if (streams != null) {
      streams.asMap().forEach((k, s) {
        _summary.add(
          AsyncSnapshot<T>.withData(ConnectionState.none,
              initialData == null ? null : initialData[k]),
        );
        _subscription.add(s.listen((data) {
          _summary[k] = AsyncSnapshot<T>.withData(ConnectionState.active, data);
          inner(k);
        }, onError: (error) {
          _summary[k] =
              AsyncSnapshot<T>.withError(ConnectionState.active, error);
          inner(k);
        }, onDone: () {
          _summary[k] = _summary[k].inState(ConnectionState.done);
          inner(k);
        }, cancelOnError: false));
        _summary[k] = _summary[k].inState(ConnectionState.waiting);
        _summaryLength = _summary?.length;
        inner(k, false);

        if (tags != null) {
          _disposer["${tags[k]}"] = () {
            _subscription[k].cancel();
            _subscription[k] = null;
          };
        } else {
          _disposer["Defautsubscritpn$hashCode"] = () {
            _subscription[k].cancel();
            _subscription[k] = null;
          };
        }
      });
    }
  }
}
