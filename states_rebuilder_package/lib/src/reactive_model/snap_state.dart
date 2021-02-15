part of '../reactive_model.dart';

///    with a [Future].
@immutable
class SnapState<T> {
  /// Creates an [SnapState] with the specified [connectionState],
  /// and optionally either [data] or [error] with an optional [stackTrace]
  /// (but not both data and error).
  const SnapState._(
    this._connectionState,
    this.data,
    this.error,
    this.stackTrace,
    this.onErrorRefresher, [
    this.isImmutable = true,
    this._infoMessage,
  ])  : assert(stackTrace == null || error != null),
        assert(error == null || onErrorRefresher != null);

  /// Creates an [SnapState] in [ConnectionState.none] with null data and error.
  const SnapState._nothing(String _infoMessage)
      : this._(
          ConnectionState.none,
          null,
          null,
          null,
          null,
          true,
          _infoMessage,
        );

  /// Creates an [SnapState] in [ConnectionState.waiting] with null data and error.
  const SnapState._waiting(T? data)
      : this._(ConnectionState.waiting, data, null, null, null);

  /// Creates an [SnapState] in the specified [state] and with the specified [data].
  const SnapState._withData(ConnectionState state, T data, bool isImmutable)
      : this._(state, data, null, null, null, isImmutable);

  /// Creates an [SnapState] in the specified [state] with the specified [error]
  /// and a [stackTrace].
  ///
  /// If no [stackTrace] is explicitly specified, [StackTrace.empty] will be used instead.
  const SnapState._withError(
    ConnectionState state,
    T? data,
    dynamic error,
    void Function() onErrorRefresher, [
    StackTrace stackTrace = StackTrace.empty,
  ]) : this._(state, data, error, stackTrace, onErrorRefresher);

  /// Current state of connection to the asynchronous computation.
  final ConnectionState _connectionState;

  /// The latest data received by the asynchronous computation.
  ///
  /// If this is non-null, [hasData] will be true.
  ///
  /// If [error] is not null, this will be null. See [hasError].
  ///
  /// If the asynchronous computation has never returned a value, this may be
  /// set to an initial data value specified by the relevant widget. See
  /// [FutureBuilder.initialData] and [StreamBuilder.initialData].
  final T? data;

  final bool isImmutable;

  /// The latest error object received by the asynchronous computation.
  ///
  /// If this is non-null, [hasError] will be true.
  ///
  /// If [data] is not null, this will be null.
  final dynamic error;

  /// The latest stack trace object received by the asynchronous computation.
  ///
  /// This will not be null iff [error] is not null. Consequently, [stackTrace]
  /// will be non-null when [hasError] is true.
  ///
  /// However, even when not null, [stackTrace] might be empty. The stack trace
  /// is empty when there is an error but no stack trace has been provided.
  final StackTrace? stackTrace;

  final void Function()? onErrorRefresher;

  final String? _infoMessage;

  SnapState<T> copyWith({
    ConnectionState? connectionState,
    T? data,
    dynamic error,
    StackTrace? stackTrace,
    void Function()? onErrorRefresher,
    bool resetError = false,
  }) =>
      SnapState<T>._(
        connectionState ?? _connectionState,
        data ?? this.data,
        resetError ? null : error ?? this.error,
        resetError ? null : stackTrace ?? this.stackTrace,
        resetError ? null : onErrorRefresher ?? this.onErrorRefresher,
        isImmutable,
        null,
      );

  /// Returns whether this snapshot contains a non-null [data] value.
  bool get hasData =>
      !hasError &&
      (_connectionState == ConnectionState.done ||
          _connectionState == ConnectionState.active);

  /// Returns whether this snapshot contains a non-null [error] value.
  bool get hasError => error != null;

  ///Where the reactive state is in the initial state
  ///
  ///It is a shortcut of : this.connectionState == ConnectionState.none
  bool get isIdle => _connectionState == ConnectionState.none;

  ///Where the reactive state is in the waiting for an asynchronous task to resolve
  ///
  ///It is a shortcut of : this.connectionState == ConnectionState.waiting
  bool get isWaiting => _connectionState == ConnectionState.waiting;

  @override
  String toString() {
    var status = '';
    if (isIdle && data == null) {
      status = '$_infoMessage';
    } else if (isIdle) {
      status = 'isIdle : $data';
    } else if (isWaiting) {
      status = 'isWaiting : $data';
    } else if (hasError) {
      status = 'hasError: $error';
    } else if (hasData) {
      status = 'hasData: $data';
    }
    return '$status';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is SnapState<T> &&
        o.isWaiting == isWaiting &&
        deepEquality.equals(o.data, data) &&
        o.error == error;
  }

  @override
  int get hashCode {
    return _connectionState.hashCode ^ data.hashCode ^ error.hashCode;
  }

  String toShortString<T>(T d) {
    var status = '';
    if (isIdle && data == null) {
      status = '$_infoMessage';
    } else if (isIdle) {
      status = 'isIdle : ${d ?? data}';
    } else if (isWaiting) {
      status = 'isWaiting: ${d ?? data}';
    } else if (hasError) {
      status = 'hasError: $error';
    } else if (hasData) {
      status = 'hasData: ${d ?? data}';
    }
    return '$status';
  }

  static log<T>(
    SnapState<T> snapState,
    SnapState<T> nextSnapState, {
    String Function(SnapState<T> snap)? state,
    String preMessage = '',
  }) {
    return (preMessage.isNotEmpty ? '[${preMessage}] : ' : '') +
        '${snapState.toShortString(state?.call(snapState))} ==> '
            '${nextSnapState.toShortString(state?.call(nextSnapState))}';
  }
}

final deepEquality = const DeepCollectionEquality();

//Used in tests
SnapState<T> createSnapState<T>(
  ConnectionState connectionState,
  T data,
  dynamic error, {
  StackTrace? stackTrace,
  void Function()? onErrorRefresher,
}) =>
    SnapState<T>._(
      connectionState,
      data,
      error,
      stackTrace,
      onErrorRefresher,
    );
