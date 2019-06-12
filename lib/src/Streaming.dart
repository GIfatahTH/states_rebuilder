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
  List<Stream<T>> streams;

  ///List of controllers
  List<StreamController<T>> controllers;

  ///List of initialData
  ///The order of the List is the same as in controller or stream list
  List<T> initialData;

  ///List of transforms
  ///The order of the List is the same as in controller or stream list
  List<StreamTransformer> transforms;

  /// The merged snapshot of all the streams
  AsyncSnapshot<T> snapshotMerged;

  /// The combined snapshot. the combination function is given in `combine` closure.
  AsyncSnapshot<S> snapshotCombined;

  ///List of snapshots in the same order as in streams list
  List<AsyncSnapshot<T>> snapshots;

  ///The combination function.
  S Function(List<AsyncSnapshot<T>>) combineFn;

  List<StreamSubscription<T>> _subscription = [];
  List<AsyncSnapshot<T>> _summary = [];

  Map<String, VoidCallback> _listeners = {};

  Streaming(
      {this.streams,
      this.controllers,
      this.initialData,
      this.transforms,
      this.combineFn}) {
    if (streams == null || streams.isEmpty) {
      if (controllers != null && controllers.isNotEmpty) {
        streams = [];
        controllers.forEach((c) => streams.add(c.stream));
      } else {
        throw FlutterError(
            "ERR(Streamer)01: You have to define controllers or streams");
      }
    }
    int streamLength = streams.length;

    if (transforms != null && transforms.isNotEmpty && streams != null) {
      streams.asMap().forEach((k, e) {
        if (transforms.length == streamLength || transforms.length == 1) {
          streams[k] = streams[k].transform(transforms.length == streamLength
              ? transforms[k]
              : transforms[0]);
        } else {
          throw FlutterError(
              "ERR(Streaming)02: transform length is different from the stream or controller length.\n"
              "You can provide one transformer to be applied to all the streams");
        }
      });
    }

    if (initialData != null &&
        initialData.length != 1 &&
        initialData.length != streamLength) {
      throw FlutterError(
          "ERR(Streaming)03: initialData length is different from the stream or controller length.\n"
          "You can provide one initialData to be applied to all the streams");
    }

    if (streams != null) {
      streams.asMap().forEach((k, s) {
        _summary.add(
          AsyncSnapshot<T>.withData(
              ConnectionState.none,
              initialData == null
                  ? null
                  : initialData.length == 1 ? initialData[0] : initialData[k]),
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
          if (!controllers[k].isClosed) inner(k);
        }, cancelOnError: false));
        _summary[k] = _summary[k].inState(ConnectionState.waiting);
        inner(k, false);
      });
    }
  }

  bool get hasData => _summary.every((e) => e.hasData);

  inner(int index, [bool rebuild = true]) {
    if (!hasData) {
      if (_summary[index].hasError) {
        snapshotCombined = AsyncSnapshot<S>.withError(
            ConnectionState.active, _summary[index].error);
      } else {
        final _snapshot = _summary.firstWhere(
          (e) {
            return !e.hasData;
          },
        );
        snapshotCombined =
            AsyncSnapshot<S>.withError(ConnectionState.active, _snapshot.error);
      }
    } else {
      snapshotCombined = AsyncSnapshot<S>.withData(
          ConnectionState.active,
          combineFn != null && _summary.length == streams.length
              ? combineFn(_summary)
              : null);
    }

    snapshots = _summary;
    snapshotMerged = _summary[index];

    if (rebuild) {
      _listeners.forEach((k, v) {
        if (v != null) v();
      });
    }
  }

  ///Add listeners to be notified when the stream is resolved.
  addListener(StatesRebuilder viewModel, [List tag]) {
    _listeners["$viewModel"] = tag == null
        ? () => viewModel.rebuildStates()
        : () => viewModel.rebuildStates(tag);
  }

  ///Cancel subscriptions
  dispose() {
    _subscription.forEach((_subscript) {
      _subscript.cancel();
      _subscript = null;
    });
  }
}
