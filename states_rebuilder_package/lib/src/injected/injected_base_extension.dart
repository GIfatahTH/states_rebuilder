part of '../injected.dart';

extension StateRebuilderListX on List<Injected> {
  /// {@macro injected.rebuilder}
  Widget rebuilder(
    Widget Function() builder, {
    void Function() initState,
    void Function() dispose,
    Object Function() watch,
    bool Function() shouldRebuild,
    Key key,
  }) {
    assert(length > 1, 'You have one Injected model');
    return StateBuilder<dynamic>(
      key: key,
      observeMany: map((e) => () => e.getRM).toList(),
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild: shouldRebuild == null ? null : (_) => shouldRebuild(),
      watch: watch == null ? null : (_) => watch(),
      didUpdateWidget: (context, reactiveModel, __) {
        final models = (reactiveModel as ReactiveModelInternal)?.activeRM;
        assert(models.length == this.length);
        models.asMap().forEach((i, rm) {
          if (this[i]._rm?.hasObservers != true) {
            final injected = _functionalInjectedModels[rm.inject.getName()];
            injected._cloneTo(this[i]);
          }
        });
      },
      builder: (context, rm) => builder(),
    );
  }

  /// {@macro injected.whenRebuilder}
  Widget whenRebuilder({
    @required Widget Function() onIdle,
    @required Widget Function() onWaiting,
    @required Widget Function() onData,
    @required Widget Function(dynamic) onError,
    void Function() initState,
    void Function() dispose,
    bool Function() shouldRebuild,
    Key key,
  }) {
    return WhenRebuilder<dynamic>(
      key: key,
      observeMany: map((e) => () => e.getRM).toList(),
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild: shouldRebuild == null ? null : (_) => shouldRebuild(),
      didUpdateWidget: (_, reactiveModel, old) {
        final models = (reactiveModel as ReactiveModelInternal)?.activeRM;
        assert(models.length == length);
        models.asMap().forEach(
          (i, rm) {
            if (this[i]._rm?.hasObservers != true) {
              _functionalInjectedModels[rm.inject.getName()]?._cloneTo(this[i]);
            }
          },
        );
        //clean it
        (reactiveModel as ReactiveModelInternal)?.activeRM = null;
      },
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: (dynamic _) => onData(),
    );
  }

  /// {@macro injected.whenRebuilderOr}
  Widget whenRebuilderOr({
    Widget Function() onIdle,
    Widget Function() onWaiting,
    Widget Function(dynamic) onError,
    Widget Function() onData,
    @required Widget Function() builder,
    void Function() initState,
    void Function() dispose,
    bool Function() shouldRebuild,
    Key key,
  }) {
    return WhenRebuilderOr<dynamic>(
      key: key,
      observeMany: map((e) => () => e.getRM).toList(),
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild: shouldRebuild == null ? null : (_) => shouldRebuild(),
      didUpdateWidget: (_, reactiveModel, old) {
        final models = (reactiveModel as ReactiveModelInternal)?.activeRM;
        assert(models.length == length);
        models.asMap().forEach(
          (i, rm) {
            if (this[i]._rm?.hasObservers != true) {
              _functionalInjectedModels[rm.inject.getName()]?._cloneTo(this[i]);
            }
          },
        );
        //clean it
        (reactiveModel as ReactiveModelInternal)?.activeRM = null;
      },
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData == null ? null : (dynamic _) => onData(),
      builder: (_, __) => builder(),
    );
  }

  Widget listen({
    @required When<Widget> rebuild,
    When<dynamic> onSetState,
    When<dynamic> onRebuildState,
    void Function() initState,
    void Function() dispose,
    Object Function() watch,
    bool Function() shouldRebuild,
    Key key,
  }) {
    AsyncSnapshot _stateStatus;
    return StateBuilder<dynamic>(
      key: key,
      observeMany: map((e) => () => e.getRM).toList(),
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild: (rm) {
        if (shouldRebuild != null) {
          return shouldRebuild();
        }
        if (rebuild._whenType == _WhenType.onData) {
          return _stateStatus.hasData ||
              _stateStatus.connectionState == ConnectionState.none;
        }
        // if (rebuild._whenType == _WhenType.onWaiting) {
        //   return stateStatus.connectionState == ConnectionState.waiting ||
        //       stateStatus.connectionState == ConnectionState.none;
        // }
        // if (rebuild._whenType == _WhenType.onError) {
        //   return stateStatus.hasError ||
        //       stateStatus.connectionState == ConnectionState.none;
        // }
        return true;
      },
      watch: watch == null ? null : (_) => watch(),
      didUpdateWidget: (_, reactiveModel, old) {
        final models = (reactiveModel as ReactiveModelInternal)?.activeRM;
        assert(models.length == length);
        models.asMap().forEach(
          (i, rm) {
            if (this[i]._rm?.hasObservers != true) {
              _functionalInjectedModels[rm.inject.getName()]?._cloneTo(this[i]);
            }
          },
        );
        //clean it
        (reactiveModel as ReactiveModelInternal)?.activeRM = null;
      },
      onSetState: (context, rm) {
        _stateStatus = _getStateStatus();
        if (onSetState == null) {
          return;
        }
        if (_stateStatus.connectionState == ConnectionState.none) {
          onSetState.onIdle?.call();
          return;
        }
        if (_stateStatus.connectionState == ConnectionState.waiting) {
          onSetState.onWaiting?.call();
          return;
        }
        if (_stateStatus.hasError) {
          onSetState.onError?.call(_stateStatus.error);
          return;
        }
        onSetState.onData?.call();
      },
      onRebuildState: (context, rm) {
        if (onRebuildState == null) {
          return;
        }
        if (_stateStatus.connectionState == ConnectionState.none) {
          onRebuildState.onIdle?.call();
          return;
        }
        if (_stateStatus.connectionState == ConnectionState.waiting) {
          onRebuildState.onWaiting?.call();
          return;
        }
        if (_stateStatus.hasError) {
          onRebuildState.onError?.call(_stateStatus.error);
          return;
        }
        onRebuildState.onData?.call();
      },
      builder: (context, rm) {
        if (rebuild._whenType == _WhenType.onWaiting ||
            rebuild._whenType == _WhenType.onError) {
          throw Exception('use When.data or When.always or when.or, when.all');
        }
        _stateStatus ??= _getStateStatus();

        if (_stateStatus.connectionState == ConnectionState.none) {
          return rebuild.onIdle?.call() ?? rebuild.onData?.call();
        }
        if (_stateStatus.connectionState == ConnectionState.waiting) {
          return rebuild.onWaiting?.call() ?? rebuild.onData?.call();
        }
        if (_stateStatus.hasError) {
          return rebuild.onError?.call(_stateStatus.error) ??
              rebuild.onData?.call();
        }
        return rebuild.onData?.call();
      },
    );
  }

  AsyncSnapshot _getStateStatus() {
    bool isIdle = false;
    bool isWaiting = false;
    dynamic error;
    dynamic data;

    for (var m in this) {
      m.getRM.whenConnectionState(
        onIdle: () => isIdle = true,
        onWaiting: () => isWaiting = true,
        onError: (e) => error = e,
        onData: (d) => data = d,
      );
    }
    if (isWaiting) {
      return AsyncSnapshot.withData(ConnectionState.waiting, null);
    }
    if (error != null) {
      return AsyncSnapshot.withError(ConnectionState.done, error);
    }

    if (isIdle) {
      return AsyncSnapshot.withData(ConnectionState.none, null);
    }
    return AsyncSnapshot.withData(ConnectionState.done, data);
  }
}
