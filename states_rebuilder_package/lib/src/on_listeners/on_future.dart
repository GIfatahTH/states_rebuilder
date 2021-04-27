part of '../rm.dart';

class OnFuture<F> {
  final Widget Function()? _onWaiting;
  final Widget Function(dynamic err, void Function() refresh)? _onError;
  final Widget Function(F data, void Function() refresh) _onData;
  OnFuture({
    required Widget Function()? onWaiting,
    required Widget Function(dynamic err, void Function() refresh)? onError,
    required Widget Function(F data, void Function() refresh) onData,
  })   : _onWaiting = onWaiting,
        _onError = onError,
        _onData = onData;
}
