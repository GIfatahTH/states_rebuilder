part of '../rm.dart';

enum StateStatus { isIdle, isWaiting, hasData, hasError }

@immutable
class SnapState<T> {
  final StateStatus status;
  final T? data;
  final SnapError? snapError;
  final SnapState<T>? oldSnapState;
  final String debugName;
  final Object? Function(T?)? toDebugString;
  final String _infoMessage;
  final bool _isImmutable;
  const SnapState._({
    required this.status,
    required this.data,
    required this.snapError,
    required this.oldSnapState,
    required this.debugName,
    required this.toDebugString,
    required String infoMessage,
    required bool isImmutable,
  })  : _infoMessage = infoMessage,
        _isImmutable = isImmutable;
  const SnapState.none({
    this.data,
    this.debugName = '',
    this.toDebugString,
    String infoMessage = '',
  })  : status = StateStatus.isIdle,
        oldSnapState = null,
        snapError = null,
        _infoMessage = infoMessage,
        _isImmutable = true;

  T get state {
    if (data is T) return data as T;
    final status = isWaiting ? 'isWaiting' : 'hasError';
    throw ArgumentError('''
$data is not of type $T. $this.\n
TRY define an initalState or Handle $status status.
''');
  }

  bool get isIdle => status == StateStatus.isIdle;
  bool get isWaiting => status == StateStatus.isWaiting;
  bool get hasData => status == StateStatus.hasData;
  bool get hasError => status == StateStatus.hasError;
  // TODO test me
  Type type() => T;
  SnapState<T> copyToIsIdle({Object? data, String? infoMessage}) {
    return copyWith(
      status: StateStatus.isIdle,
      data: data is T ? data : this.data,
      infoMessage: infoMessage,
    );
  }

  SnapState<T> copyToIsWaiting([String? infoMessage]) {
    return copyWith(
      status: StateStatus.isWaiting,
      infoMessage: infoMessage,
    );
  }

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
      snapError: status == StateStatus.hasData ? null : (error ?? snapError),
      oldSnapState: (status != null || data != null || error != null)
          ? oldSnapState ?? this
          : this.oldSnapState,
      debugName: debugName ?? this.debugName,
      toDebugString: toDebugString,
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
    if (debugName.isNotEmpty) {
      return 'SnapState<$T>[$debugName](${_toShortString(data)})';
    }
    return 'SnapState<$T>(${_toShortString(data)})';
  }

  String toStringShort() {
    if (debugName.isNotEmpty) {
      return 'SnapState<$T>[$debugName]())';
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
    debugName ??= this.debugName;
    final isMutable = hasData && _isImmutable == false;
    final str = (debugName.isNotEmpty ? '<$debugName>' : '<$T>') +
        ' ' +
        (isMutable ? '[Mutable]' : '') +
        ': '
            '${oldSnapState?._toShortString(toDebugString?.call(oldSnapState?.data))} ==> '
            '${_toShortString(toDebugString?.call(data))}';

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
class SnapError {
  final dynamic error;
  final StackTrace? stackTrace;
  final VoidCallback refresher;
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
