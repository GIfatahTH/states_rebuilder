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
    assert(this.length > 1, 'You have one Injected model');
    return StateBuilder(
      key: key,
      observeMany: this.map((e) => () => e.getRM).toList(),
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
    return WhenRebuilder(
      key: key,
      observeMany: this.map((e) => () => e.getRM).toList(),
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild: shouldRebuild == null ? null : (_) => shouldRebuild(),
      didUpdateWidget: (_, reactiveModel, old) {
        final models = (reactiveModel as ReactiveModelInternal)?.activeRM;
        assert(models.length == this.length);
        models.asMap().forEach(
          (i, rm) {
            if (this[i]._rm?.hasObservers != true) {
              final injected = _functionalInjectedModels[rm.inject.getName()];
              injected._cloneTo(this[i]);
            }
          },
        );
        //clean it
        (reactiveModel as ReactiveModelInternal)?.activeRM = null;
      },
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: (_) => onData(),
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
    return WhenRebuilderOr(
      key: key,
      observeMany: this.map((e) => () => e.getRM).toList(),
      initState: initState == null ? null : (_, rm) => initState(),
      dispose: dispose == null ? null : (_, rm) => dispose(),
      shouldRebuild: shouldRebuild == null ? null : (_) => shouldRebuild(),
      didUpdateWidget: (_, reactiveModel, old) {
        final models = (reactiveModel as ReactiveModelInternal)?.activeRM;
        assert(models.length == this.length);
        models.asMap().forEach(
          (i, rm) {
            if (this[i]._rm?.hasObservers != true) {
              final injected = _functionalInjectedModels[rm.inject.getName()];
              injected._cloneTo(this[i]);
            }
          },
        );
        //clean it
        (reactiveModel as ReactiveModelInternal)?.activeRM = null;
      },
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData == null ? null : (_) => onData(),
      builder: (_, __) => builder(),
    );
  }
}
