import 'dart:async';

import 'package:flutter/material.dart';

import '../states_rebuilder.dart';

///A class to handle streams
///It allows you to control the rebuild of many widgets from single subscription StreamController.
///
///You can listen to many streams, merge them and combine them.
///
///Streaming<T, S> : T is the type of the streams and S is the type of the result of the combination of streams.
class Streaming<T, S> {
  ///List of streams
  // List<Stream<T>> streams;
  List<Stream<T>> _streams;

  ///List of controllers
  List<StreamController<T>> _controllers;

  ///List of initialData
  ///The order of the List is the same as in controller or stream list
  List<T> _initialData;

  ///List of transforms
  ///The order of the List is the same as in controller or stream list
  List<StreamTransformer> _transforms;

  /// The merged snapshot of all the streams
  AsyncSnapshot<T> get snapshotMerged => _snapshotMerged;
  AsyncSnapshot<T> _snapshotMerged;

  /// The combined snapshot. the combination function is given in `combine` closure.
  AsyncSnapshot<S> get snapshotCombined => _snapshotCombined;
  AsyncSnapshot<S> _snapshotCombined;

  ///List of snapshots in the same order as in streams list
  List<AsyncSnapshot<T>> get snapshots => _snapshots;
  List<AsyncSnapshot<T>> _snapshots;

  ///The combination function.
  S Function(List<AsyncSnapshot<T>>) combineFn;

  List<StreamSubscription<T>> _subscription = [];
  List<AsyncSnapshot<T>> _summary = [];

  Map<String, VoidCallback> _listeners = {};

  Streaming(
      {List<Stream<T>> streams,
      List<StreamController<T>> controllers,
      List<T> initialData,
      List<StreamTransformer> transforms,
      this.combineFn}) {
    _streams = streams;
    _controllers = controllers;
    _initialData = initialData;
    _transforms = transforms;

    if (_streams == null || _streams.isEmpty) {
      if (_controllers != null && _controllers.isNotEmpty) {
        _streams = [];
        _controllers.forEach((c) => _streams.add(c.stream));
      } else {
        throw FlutterError(
            "ERR(Streamer)01: You have to define controllers or streams");
      }
    }
    int streamLength = _streams.length;

    if (_transforms != null && _transforms.isNotEmpty && _streams != null) {
      _streams.asMap().forEach((k, e) {
        if (_transforms.length == streamLength || _transforms.length == 1) {
          _streams[k] = _streams[k].transform(_transforms.length == streamLength
              ? _transforms[k]
              : _transforms[0]);
        } else {
          throw FlutterError(
              "ERR(Streaming)02: transform length is different from the stream or controller length.\n"
              "You can provide one transformer to be applied to all the streams");
        }
      });
    }

    if (_initialData != null &&
        _initialData.length != 1 &&
        _initialData.length != streamLength) {
      throw FlutterError(
          "ERR(Streaming)03: initialData length is different from the stream or controller length.\n"
          "You can provide one initialData to be applied to all the streams");
    }

    if (_streams != null) {
      _streams.asMap().forEach((k, s) {
        _summary.add(
          AsyncSnapshot<T>.withData(
              ConnectionState.none,
              _initialData == null
                  ? null
                  : _initialData.length == 1
                      ? _initialData[0]
                      : _initialData[k]),
        );
        _subscription.add(s.listen((data) {
          _summary[k] = AsyncSnapshot<T>.withData(ConnectionState.active, data);
          _inner(k);
        }, onError: (error) {
          _summary[k] =
              AsyncSnapshot<T>.withError(ConnectionState.active, error);
          _inner(k);
        }, onDone: () {
          _summary[k] = _summary[k].inState(ConnectionState.done);
          if (_controllers == null || !_controllers[k].isClosed) {
            _inner(k);
          }
        }, cancelOnError: false));
        _summary[k] = _summary[k].inState(ConnectionState.waiting);
        _inner(k, false);
      });
    }
  }

  bool get _hasData => _summary.every((e) => e.hasData);

  _inner(int index, [bool rebuild = true]) {
    if (!_hasData) {
      if (_summary[index].hasError) {
        _snapshotCombined = AsyncSnapshot<S>.withError(
            ConnectionState.active, _summary[index].error);
      } else {
        final _snapshot = _summary.firstWhere(
          (e) {
            return !e.hasData;
          },
        );
        _snapshotCombined =
            AsyncSnapshot<S>.withError(ConnectionState.active, _snapshot.error);
      }
    } else {
      _snapshotCombined = AsyncSnapshot<S>.withData(
          ConnectionState.active,
          combineFn != null && _summary.length == _streams.length
              ? combineFn(_summary)
              : null);
    }

    _snapshots = _summary;
    _snapshotMerged = _summary[index];

    if (rebuild) {
      _listeners.forEach((k, v) {
        if (v != null) v();
      });
    }
  }

  ///Add listeners to be notified when the stream is resolved.
  addListener(StatesRebuilder viewModel, [List tag]) {
    final key = "$viewModel${viewModel.hashCode}";
    _listeners[key] = () => viewModel.rebuildStates(tag);

    _subscription?.forEach((_subscript) {
      _subscript?.resume();
    });

    viewModel.cleaner(() {
      _listeners.remove(key);

      if (_listeners.isEmpty) {
        _subscription.forEach((_subscript) {
          _subscript.pause();
        });
      }
    });
  }

  ///Cancel subscriptions
  cancel() {
    _subscription?.forEach((_subscript) {
      _subscript?.cancel();
    });
  }
}
