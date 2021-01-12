part of '../reactive_model.dart';

extension ReactiveModelX on List<ReactiveModel> {
  Widget listen({
    On<void>? onSetState,
    On<void>? onAfterBuild,
    required On<Widget> child,
    void Function()? initState,
    void Function()? dispose,
    void Function(_StateBuilder oldWidget)? didUpdateWidget,
    bool Function()? shouldRebuild,
    Object? Function()? watch,
    Key? key,
  }) {
    return _StateBuilder(
      rm: this,
      initState: (_, setState) {
        initState?.call();
        final disposer = <Disposer>[];
        for (var rm in this) {
          rm._initialize();
          if (onAfterBuild != null) {
            WidgetsBinding.instance?.addPostFrameCallback(
              (_) => onAfterBuild(
                isWaiting: this.any((e) => e._snapState.isWaiting),
                error: this.any((e) => e._snapState.hasError)
                    ? this.firstWhere((e) => e._snapState.hasError).error
                    : null,
                isIdle: this.any((e) => e._snapState.isIdle),
              ),
            );
          }
          disposer.add(
            rm._listenToRMForStateFulWidget((_, tag) {
              if (shouldRebuild?.call() == false) {
                return;
              }
              onSetState?.call(
                isWaiting: this.any((e) => e._snapState.isWaiting),
                error: this.any((e) => e._snapState.hasError)
                    ? this.firstWhere((e) => e._snapState.hasError).error
                    : null,
                isIdle: this.any((e) => e._snapState.isIdle),
              );

              if (child._onType == _OnType.onData && !rm._snapState.hasData) {
                return;
              }

              if (onAfterBuild != null) {
                WidgetsBinding.instance?.addPostFrameCallback(
                  (_) => onAfterBuild(
                    isWaiting: this.any((e) => e._snapState.isWaiting),
                    error: this.any((e) => e._snapState.hasError)
                        ? this.firstWhere((e) => e._snapState.hasError).error
                        : null,
                    isIdle: this.any((e) => e._snapState.isIdle),
                  ),
                );
              }
              setState();
            }),
          );
        }
        return () => disposer.forEach((e) => e());
      },
      dispose: (context) {
        dispose?.call();
        Future.microtask(
          () => forEach(
            (e) {
              if (!e.hasObservers) {
                e._clean();
              }
            },
          ),
        );
      },
      watch: watch,
      didUpdateWidget: (_, oldWidget) => didUpdateWidget?.call(oldWidget),
      builder: (_) {
        return child.call(
          isWaiting: this.any((e) => e._snapState.isWaiting),
          error: this.any((e) => e._snapState.hasError)
              ? this.firstWhere((e) => e._snapState.hasError).error
              : null,
          isIdle: this.any((e) => e._snapState.isIdle),
        )!;
      },
    );
  }

  /// {@macro injected.rebuilder}
  Widget rebuilder(
    Widget Function() builder, {
    void Function()? initState,
    void Function()? dispose,
    Object Function()? watch,
    bool Function()? shouldRebuild,
    Key? key,
  }) {
    return listen(
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? () => shouldRebuild() : null,
      watch: watch,
      child: On.data(() => builder()),
    );
  }

  /// {@macro injected.whenRebuilderOr}
  Widget whenRebuilder({
    required Widget Function() onIdle,
    required Widget Function() onWaiting,
    required Widget Function() onData,
    required Widget Function(dynamic) onError,
    void Function()? initState,
    void Function()? dispose,
    bool Function()? shouldRebuild,
    Key? key,
  }) {
    return listen(
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? () => shouldRebuild() : null,
      child: On.all(
        onIdle: onIdle,
        onWaiting: onWaiting,
        onError: onError,
        onData: onData,
      ),
    );
  }

  /// {@macro injected.whenRebuilderOr}
  Widget whenRebuilderOr({
    Widget Function()? onIdle,
    Widget Function()? onWaiting,
    Widget Function(dynamic)? onError,
    Widget Function()? onData,
    required Widget Function() builder,
    void Function()? initState,
    void Function()? dispose,
    Object Function()? watch,
    bool Function()? shouldRebuild,
    Key? key,
  }) {
    return listen(
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? () => shouldRebuild() : null,
      watch: watch,
      child: On.or(
        onIdle: onIdle,
        onWaiting: onWaiting,
        onError: onError,
        onData: onData,
        or: builder,
      ),
    );
  }
}
