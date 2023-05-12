part of '../rm.dart';

/// Possible state status
enum StateStatus {
  /// A fresh state before mutation
  isIdle,

  /// Waiting for async task to resolve
  isWaiting,

  /// has valid data
  hasData,

  /// has error
  hasError,
}

///Snap representation of the state
@immutable
class SnapState<T> {
  /// The  snap status [StateStatus]
  final StateStatus status;

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
  final SnapError? snapError;

  /// The old SnapState
  final SnapState<T>? oldSnapState;

  /// A name used for debugging
  final String _debugName;
  final Object? Function(T?)? _toDebugString;
  final String _infoMessage;
  final bool _isImmutable;
  const SnapState._({
    required this.status,
    required this.data,
    required this.snapError,
    required this.oldSnapState,
    required String debugName,
    required Object? Function(T?)? toDebugString,
    required String infoMessage,
    required bool isImmutable,
  })  : _infoMessage = infoMessage,
        _isImmutable = isImmutable,
        _debugName = debugName,
        _toDebugString = toDebugString;

  /// Create a SnapState in idle state
  const SnapState.none({
    this.data,
    String debugName = '',
    Object? Function(T?)? toDebugString,
    String infoMessage = '',
  })  : status = StateStatus.isIdle,
        oldSnapState = null,
        snapError = null,
        _infoMessage = infoMessage,
        _isImmutable = true,
        _debugName = debugName,
        _toDebugString = toDebugString;

  /// The state
  T get state {
    if (data is T) return data as T;
    final status = isWaiting ? 'isWaiting' : 'hasError';
    if (hasError) {
      StatesRebuilerLogger.log(
        '',
        snapError!.error,
      );
      print(this);
      StatesRebuilerLogger.log(
        '',
        'IF [${type()}] IS A REPOSITORY AND YOU ARE TESTING THE APP THINK OF MOCKING IT',
      );
      StatesRebuilerLogger.log(
        '',
        'OR, TRY DEFINING THE INITIAL STATE OR HANDLE THE ERROR STATUS',
        StackTrace.current,
      );
    } else if (isWaiting) {
      StatesRebuilerLogger.log(
        '',
        'The state is waiting and it is not initialized yet',
      );
      StatesRebuilerLogger.log(
        '',
        'OTHERWISE, TRY DEFINING THE INITIAL STATE OR HANDLE THE WAITING STATUS',
        StackTrace.current,
      );
    }

    throw ArgumentError('''
$data is not of type $T. $this.\n
TRY define an initialState or Handle $status status.
''');
  }

  /// Wether the state is in the idle status
  bool get isIdle => status == StateStatus.isIdle;

  /// Wether the state is in the waiting status
  bool get isWaiting => status == StateStatus.isWaiting;

  /// Wether the state is in the data status
  bool get hasData => status == StateStatus.hasData;

  /// Wether the state is in the error status
  bool get hasError => status == StateStatus.hasError;

  /// The type of the state
  // TODO test me
  Type type() => T;

  /// Copy the state to a new state in the idle status
  SnapState<T> copyToIsIdle({Object? data, String? infoMessage}) {
    return copyWith(
      status: StateStatus.isIdle,
      data: data is T ? data : this.data,
      infoMessage: infoMessage,
      isImmutable: data is T,
    );
  }

  /// Copy the state to a new state in the waiting status
  SnapState<T> copyToIsWaiting([String? infoMessage]) {
    return copyWith(
      status: StateStatus.isWaiting,
      infoMessage: infoMessage,
    );
  }

  /// Copy the state to a new state in the data status
  SnapState<T> copyToHasData(Object? data) {
    return copyWith(
      status: StateStatus.hasData,
      data: data is T ? data : this.data,
      infoMessage: '',
      isImmutable: data is T,
    );
  }

  SnapState<T> _copyToHasError(SnapError error) {
    return copyWith(
      status: StateStatus.hasError,
      error: error,
      infoMessage: '',
    );
  }

  /// Copy the state to a new state in the error status
  SnapState<T> copyToHasError(
    dynamic error, {
    StackTrace? stackTrace,
    VoidCallback? refresher,
  }) {
    return copyWith(
      status: StateStatus.hasError,
      error: SnapError(
        error: error,
        stackTrace: stackTrace,
        refresher: refresher ?? () {},
      ),
      infoMessage: '',
    );
  }

  /// {@macro injected.rebuild.onOr}
  R onOrElse<R>({
    R Function()? onIdle,
    R Function()? onWaiting,
    R Function(dynamic error, VoidCallback refreshError)? onError,
    R Function(T data)? onData,
    required R Function(T data) orElse,
  }) {
    if (isIdle && onIdle != null) {
      return onIdle();
    }
    if (isWaiting && onWaiting != null) {
      return onWaiting();
    }
    if (hasError && onError != null) {
      return onError(snapError!.error, snapError!.refresher);
    }
    if (hasData && onData != null) {
      return onData(data as T);
    }
    return orElse(data as T);
  }

  /// {@macro injected.rebuild.onAll}
  R onAll<R>({
    R Function()? onIdle,
    required R Function()? onWaiting,
    required R Function(dynamic error, VoidCallback refreshError)? onError,
    required R Function(T data) onData,
  }) {
    return onOrElse<R>(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      orElse: onData,
    );
  }

  /// Copy the state
  SnapState<T> copyWith({
    StateStatus? status,
    T? data,
    SnapError? error,
    String? infoMessage,
    String? debugName,
    SnapState<T>? oldSnapState,
    bool? isImmutable,
  }) {
    final s = SnapState<T>._(
      status: status ?? this.status,
      data: isImmutable == true ? data : data ?? this.data,
      snapError: error ??
          (status == null || status == StateStatus.isWaiting
              ? this.snapError
              : null),
      oldSnapState: (status != null || data != null || error != null)
          ? oldSnapState ?? this
          : this.oldSnapState,
      debugName: debugName ?? _debugName,
      toDebugString: _toDebugString,
      infoMessage: infoMessage ?? _infoMessage,
      isImmutable: isImmutable ?? _isImmutable,
    );
    // assert(_infoMessage == kRefreshMessage ||
    //     infoMessage == kRefreshMessage ||
    //     infoMessage == kDisposeMessage ||
    //     _infoMessage == kInitMessage ||
    //     s.status != s.oldSnapState?.status ||
    //     s != s.oldSnapState);
    return s;
  }

  @override
  String toString() {
    if (_debugName.isNotEmpty) {
      return 'SnapState<$T>[$_debugName](${_toShortString(data)})';
    }
    return 'SnapState<$T>(${_toShortString(data)})';
  }

  String toStringShort() {
    if (_debugName.isNotEmpty) {
      return 'SnapState<$T>[$_debugName]())';
    }
    return 'SnapState<$T>()';
  }

  String _toShortString<D>(D d) {
    var status = '';
    if (isIdle && _infoMessage.isNotEmpty) {
      status = _infoMessage;
    } else if (isIdle) {
      status = 'isIdle : ${d ?? data}';
    } else if (isWaiting) {
      status = 'isWaiting ($_infoMessage): ${d ?? data}';
    } else if (hasError) {
      status = 'hasError: ${snapError!.error}';
    } else if (hasData) {
      status = 'hasData: ${d ?? data}';
    }
    return status;
  }

  void debugPrint({
    String? debugName,
  }) {
    debugName ??= _debugName;
    final isMutable = hasData && _isImmutable == false;
    final str = (debugName.isNotEmpty ? '<$debugName>' : '<$T>') +
        ' ' +
        (isMutable ? '[Mutable]' : '') +
        ': '
            '${oldSnapState?._toShortString(_toDebugString?.call(oldSnapState?.data))} ==> '
            '${_toShortString(_toDebugString?.call(data))}';

    StatesRebuilerLogger.log(str);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SnapState<T> &&
        other.isWaiting == isWaiting &&
        other.snapError?.error == snapError?.error &&
        // (o._infoMessage != kRecomputing || o.isIdle == isIdle) &&
        // o._infoMessage == _infoMessage &&
        deepEquality.equals(other.data, data);
  }

  @override
  int get hashCode {
    return status.hashCode ^ data.hashCode ^ snapError.hashCode;
  }
}

@immutable

/// The error representation
class SnapError {
  /// The error
  final dynamic error;

  /// The latest stack trace object .
  final StackTrace? stackTrace;

  /// callback use to reinvoke the last computation that causes the error
  final VoidCallback refresher;

  /// The error representation
  const SnapError({
    required this.error,
    this.stackTrace,
    required this.refresher,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SnapError && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}
