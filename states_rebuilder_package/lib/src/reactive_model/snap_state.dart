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
    this._infoMessage,
    this.isDone = false,
    this.isActive = true,
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
          _infoMessage,
        );

  // /// Creates an [SnapState] in [ConnectionState.waiting] with null data and error.
  // const SnapState._waiting(T? data)
  //     : this._(ConnectionState.waiting, data, null, null, null);

  /// Creates an [SnapState] in the specified [state] and with the specified [data].
  const SnapState._withData(ConnectionState state, T data)
      : this._(state, data, null, null, null);

  /// Creates an [SnapState] in the specified [state] with the specified [error]
  /// and a [stackTrace].
  ///
  /// If no [stackTrace] is explicitly specified, [StackTrace.empty] will be used instead.
  // const SnapState._withError(
  //   ConnectionState state,
  //   T? data,
  //   dynamic error,
  //   void Function() onErrorRefresher, [
  //   StackTrace stackTrace = StackTrace.empty,
  // ]) : this._(state, data, error, stackTrace, onErrorRefresher);

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

  SnapState<T> _copyWith({
    ConnectionState? connectionState,
    T? data,
    dynamic error,
    StackTrace? stackTrace,
    void Function()? onErrorRefresher,
    bool resetError = false,
    String? infoMessage,
    bool isDone = false,
    bool? isActive,
  }) =>
      SnapState<T>._(
        connectionState ?? _connectionState,
        data ?? this.data,
        resetError ? null : error ?? this.error,
        resetError ? null : stackTrace ?? this.stackTrace,
        resetError ? null : onErrorRefresher ?? this.onErrorRefresher,
        infoMessage ?? _infoMessage,
        isDone,
        isActive ?? this.isActive,
      );

  SnapState<T> copyTo({
    bool? isWaiting,
    bool? isIdle,
    bool? isActive,
    T? data,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (isWaiting != null) {
      return _copyToIsWaiting();
    }
    if (error != null) {
      return _copyToHasError(error, () {}, stackTrace: stackTrace);
    }
    if (isIdle != null) {
      return _copyToIsIdle();
    }
    if (isActive != null) {
      return _copyWith(isActive: isActive);
    }

    return _copyToHasData(data);
  }

  SnapState<T> _copyToIsWaiting({T? data, String? infoMessage}) {
    return _copyWith(
      connectionState: ConnectionState.waiting,
      data: data,
      infoMessage: infoMessage,
      resetError: true,
    );
  }

  SnapState<T> copyToIsWaiting() {
    return _copyWith(
      connectionState: ConnectionState.waiting,
      resetError: true,
    );
  }

  SnapState<T> copyToIsDone() {
    return _copyWith(
      isDone: true,
    );
  }

  SnapState<T> copyToHasError(
    dynamic error, {
    StackTrace? stackTrace,
  }) {
    return _copyWith(
      connectionState: ConnectionState.done,
      error: error,
      onErrorRefresher: () {},
      stackTrace: stackTrace,
    );
  }

  SnapState<T> _copyToHasError(
    dynamic error,
    void Function()? onErrorRefresher, {
    StackTrace? stackTrace,
    String? infoMessage,
  }) {
    return _copyWith(
      connectionState: ConnectionState.done,
      error: error,
      onErrorRefresher: onErrorRefresher,
      stackTrace: stackTrace,
      infoMessage: infoMessage,
    );
  }

  SnapState<T> copyToHasData(T? data) {
    return _copyWith(
      connectionState: ConnectionState.done,
      data: data,
      resetError: true,
    );
  }

  SnapState<T> _copyToHasData(T? data, {String? infoMessage}) {
    return _copyWith(
      connectionState: ConnectionState.done,
      data: data,
      resetError: true,
      infoMessage: infoMessage,
    );
  }

  SnapState<T> copyToIsIdle() {
    return _copyWith(
      connectionState: ConnectionState.none,
      resetError: true,
    );
  }

  SnapState<T> _copyToIsIdle({
    T? data,
    String? infoMessage,
  }) {
    return _copyWith(
      connectionState: ConnectionState.none,
      data: data,
      resetError: true,
      infoMessage: infoMessage,
    );
  }

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

  bool get isReady => data != null;

  final bool isDone;
  final bool isActive;

  @override
  String toString() {
    var status = '';
    if (isIdle && data == null) {
      status = '$_infoMessage';
    } else if (isIdle) {
      status = 'isIdle : $data';
    } else if (isWaiting) {
      status = 'isWaiting ($_infoMessage) : $data';
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
    if (isIdle && _infoMessage?.isNotEmpty == true) {
      status = '$_infoMessage';
    } else if (isIdle) {
      status = 'isIdle : ${d ?? data}';
    } else if (isWaiting) {
      status = 'isWaiting ($_infoMessage): ${d ?? data}';
    } else if (hasError) {
      status = 'hasError: $error';
    } else if (hasData) {
      status = 'hasData: ${d ?? data}';
    }
    return '$status';
  }

  static _Log<T> log<T>(
    SnapState<T> snapState,
    SnapState<T> nextSnapState, {
    String Function(T? s)? stateToString,
    bool Function(dynamic err)? debugWhen,
  }) {
    if (nextSnapState.hasError && debugWhen != null) {
      debugger(when: (debugWhen(nextSnapState.error)));
    }
    final log = _Log<T>(snapState, nextSnapState, stateToString);
    return log;
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

class _Log<T> {
  final SnapState<T> snapState;
  final SnapState<T> nextSnapState;
  String Function(T? s)? stateToString;

  _Log(this.snapState, this.nextSnapState, this.stateToString);

  void print([String preMessage = '']) => debugPrint(
        (preMessage.isNotEmpty ? '[${preMessage}] : ' : '') + toString(),
      );

  @override
  String toString() {
    if (snapState.isIdle &&
        snapState.data == null &&
        snapState._infoMessage?.isNotEmpty == false &&
        nextSnapState.isWaiting) {
      return _Log<T>(
        SnapState<T>._nothing(initMessage),
        nextSnapState,
        stateToString,
      ).toString();
    }
    return '${snapState.toShortString(stateToString?.call(snapState.data))} ==> '
        '${nextSnapState.toShortString(stateToString?.call(nextSnapState.data))}';
  }
}

extension SnapStateX<T> on SnapState<T> {
  void print() => debugPrint('$this');
}

class MiddleSnapState<T> {
  final SnapState<T> currentSnap;
  final SnapState<T> nextSnap;
  // final T? currentState;
  // final T? nextState;
  MiddleSnapState(this.currentSnap, this.nextSnap);
  // : currentState = currentSnap.data,
  //   nextState = nextSnap.data;

  bool get isValid => nextSnap.data != null && currentSnap.data != null;

  String log({
    String Function(T? s)? stateToString,
    String preMessage = '',
  }) {
    if (currentSnap.isIdle &&
        currentSnap.data == null &&
        currentSnap._infoMessage?.isNotEmpty == false &&
        nextSnap.isWaiting) {
      return MiddleSnapState<T>(
        SnapState<T>._nothing(initMessage),
        nextSnap,
      ).log(
        stateToString: stateToString,
      );
    }
    return (preMessage.isNotEmpty ? '<$preMessage>' : '<$T>') +
        ' : '
            '${currentSnap.toShortString(stateToString?.call(currentSnap.data))} ==> '
            '${nextSnap.toShortString(stateToString?.call(nextSnap.data))}';
  }

  String print({
    String Function(T? s)? stateToString,
    String preMessage = '',
  }) {
    final l = log(
      stateToString: stateToString,
      preMessage: preMessage,
    );
    debugPrint(l);

    return l;
  }

  String toString() {
    return '<$T> : $currentSnap => $nextSnap';
  }
}
