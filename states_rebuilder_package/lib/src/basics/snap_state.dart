part of '../rm.dart';

///Snap representation of the state
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
    this._infoMessage = '',
    this.isDone = false,
    this.isActive = true,
    this._isImmutable,
    this._debugPrintWhenNotifiedPreMessage,
  ])  : assert(stackTrace == null || error != null),
        assert(error == null || onErrorRefresher != null);

  /// Creates an [SnapState] in [ConnectionState.none] with null data and error.
  const SnapState._nothing(
    T? initialState,
    String _infoMessage,
    String? debugPrintWhenNotifiedPreMessage,
  ) : this._(
          ConnectionState.none,
          initialState,
          null,
          null,
          null,
          _infoMessage,
          false,
          true,
          null,
          debugPrintWhenNotifiedPreMessage,
        );
  const SnapState.none()
      : this._(
          ConnectionState.none,
          null,
          null,
          null,
          null,
          '',
        );
  const SnapState.data([T? data])
      : this._(
          ConnectionState.done,
          data,
          null,
          null,
          null,
          '',
        );
  factory SnapState.error(dynamic err, [StackTrace? s]) => SnapState._(
        ConnectionState.done,
        null,
        err,
        s,
        () {},
        '',
      );
  const SnapState.waiting()
      : this._(
          ConnectionState.waiting,
          null,
          null,
          null,
          null,
          '',
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

  final String _infoMessage;

  final bool? _isImmutable;
  final String? _debugPrintWhenNotifiedPreMessage;
  bool get _isNullable => null is T;
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
    bool? isImmutable,
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
        isImmutable ?? _isImmutable,
        _debugPrintWhenNotifiedPreMessage,
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
      infoMessage: infoMessage ?? '',
      resetError: true,
    );
  }

  SnapState<T> copyToIsWaiting() {
    return _copyWith(
      connectionState: ConnectionState.waiting,
      resetError: true,
      infoMessage: '',
    );
  }

  SnapState<T> copyToIsDone() {
    return _copyWith(
      isDone: true,
      infoMessage: '',
    );
  }

  SnapState<T> copyToHasError(
    dynamic error, {
    StackTrace? stackTrace,
    void Function()? onErrorRefresher,
    T? data,
    bool enableNull = false,
  }) {
    return _copyToHasError(
      error,
      onErrorRefresher ?? () {},
      stackTrace: stackTrace,
      infoMessage: '',
      data: data,
      enableNull: enableNull,
    );
  }

  SnapState<T> _copyToHasError(
    dynamic error,
    void Function()? onErrorRefresher, {
    StackTrace? stackTrace,
    String? infoMessage,
    T? data,
    bool enableNull = false,
  }) {
    return SnapState<T>._(
      ConnectionState.done,
      enableNull ? data : data ?? this.data,
      error,
      stackTrace,
      onErrorRefresher,
      infoMessage ?? '',
      false,
      isActive,
      _isImmutable,
      _debugPrintWhenNotifiedPreMessage,
    );
  }

  SnapState<T> copyToHasData(T? data) {
    return _copyWith(
      connectionState: ConnectionState.done,
      data: data,
      resetError: true,
      infoMessage: '',
    );
  }

  SnapState<T> _copyToHasData(dynamic data, {String? infoMessage}) {
    final isImmutable = _isNullable || data is T;
    // return _copyWith(
    //   connectionState: ConnectionState.done,
    //   data: isImmutable ? data : this.data,
    //   resetError: true,
    //   infoMessage: infoMessage ?? '',
    //   isImmutable: isImmutable,
    // );
    return SnapState<T>._(
      ConnectionState.done,
      isImmutable ? data : this.data,
      null,
      null,
      null,
      infoMessage ?? '',
      false,
      this.isActive,
      isImmutable,
      _debugPrintWhenNotifiedPreMessage,
    );
  }

  SnapState<T> copyToIsIdle() {
    return _copyWith(
      connectionState: ConnectionState.none,
      resetError: true,
      infoMessage: '',
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
      infoMessage: infoMessage ?? '',
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
  Type type() => T;
  @override
  String toString() {
    if (_debugPrintWhenNotifiedPreMessage != null) {
      return 'SnapState<$T>[$_debugPrintWhenNotifiedPreMessage](${toShortString(data)})';
    }
    return 'SnapState<$T>(${toShortString(data)})';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is SnapState<T> &&
        o.isWaiting == isWaiting &&
        o.error == error &&
        // (o._infoMessage != kRecomputing || o.isIdle == isIdle) &&
        // o._infoMessage == _infoMessage &&
        deepEquality.equals(o.data, data);
  }

  @override
  int get hashCode {
    return _connectionState.hashCode ^ data.hashCode ^ error.hashCode;
  }

  String toShortString<T>(T d) {
    var status = '';
    if (isIdle && _infoMessage.isNotEmpty) {
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
}

class SkipSnapState<T> extends SnapState<T> {
  SkipSnapState() : super._nothing(null, '', '');
}

extension SnapStateX<T> on SnapState<T> {
  SnapState<T> copyWith({
    ConnectionState? connectionState,
    T? data,
    dynamic error,
    StackTrace? stackTrace,
    void Function()? onErrorRefresher,
    bool resetError = false,
    String? infoMessage,
    bool isDone = false,
    bool? isActive,
    bool? isImmutable,
  }) {
    return SnapState<T>._(
      connectionState ?? _connectionState,
      data ?? this.data,
      resetError ? null : error ?? this.error,
      resetError ? null : stackTrace ?? this.stackTrace,
      resetError ? null : onErrorRefresher ?? this.onErrorRefresher,
      infoMessage ?? _infoMessage,
      isDone,
      isActive ?? this.isActive,
      isImmutable ?? _isImmutable,
      _debugPrintWhenNotifiedPreMessage,
    );
  }
}

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
        currentSnap._infoMessage.isEmpty &&
        nextSnap.isWaiting) {
      return MiddleSnapState<T>(
        SnapState<T>._nothing(
          null,
          kInitMessage,
          nextSnap._debugPrintWhenNotifiedPreMessage,
        ),
        nextSnap,
      ).log(
        stateToString: stateToString,
      );
    }
    final isMutable = nextSnap.hasData && nextSnap._isImmutable == false;
    return (preMessage.isNotEmpty ? '<$preMessage>' : '<$T>') +
        ' ' +
        (isMutable ? '[Mutable]' : '') +
        ': '
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
