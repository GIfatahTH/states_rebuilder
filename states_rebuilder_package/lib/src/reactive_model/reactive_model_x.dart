part of '../reactive_model.dart';

extension ReactiveModelX on List<ReactiveModel<dynamic>> {
  // ///Listen to a list [Injected] states and register:
  // ///{@macro listen}
  // ///
  // ///onSetState, child and onAfterBuild parameters receives a
  // ///[OnCombined] object.
  // Widget listen<T>({
  //   OnCombined<T, void>? onSetState,
  //   OnCombined<T, void>? onAfterBuild,
  //   required OnCombined<T, Widget> child,
  //   void Function()? initState,
  //   void Function()? dispose,
  //   void Function(_StateBuilder<T> oldWidget)? didUpdateWidget,
  //   bool Function()? shouldRebuild,
  //   Object? Function()? watch,
  //   Key? key,
  // }) {
  //   return _StateBuilder<T>(
  //     rm: this,
  //     initState: (_, setState, exposedRM) {
  //       initState?.call();
  //       final disposer = <Disposer>[];

  //       for (var rm in this) {
  //         rm._initialize();
  //         disposer.add(
  //           rm._listenToRMForStateFulWidget((_, tag) {
  //             if (shouldRebuild?.call() == false) {
  //               return;
  //             }
  //             onSetState?.call(
  //                 _getCombinedSnap(this), (exposedRM ?? rm)._state);

  //             if (child._hasOnDataOnly && !rm._snapState.hasData) {
  //               return;
  //             }

  //             if (onAfterBuild != null) {
  //               WidgetsBinding.instance?.addPostFrameCallback(
  //                 (_) {
  //                   onAfterBuild.call(
  //                       _getCombinedSnap(this), (exposedRM ?? rm)._state);
  //                 },
  //               );
  //             }
  //             setState(rm);
  //           }),
  //         );
  //       }
  //       if (onAfterBuild != null) {
  //         WidgetsBinding.instance?.addPostFrameCallback(
  //           (_) {
  //             onAfterBuild.call(
  //               _getCombinedSnap(this),
  //               (exposedRM ?? this.first)._state,
  //             );
  //           },
  //         );
  //       }
  //       return () => disposer.forEach((e) => e());
  //     },
  //     dispose: (context) {
  //       dispose?.call();
  //       Future.microtask(
  //         () => forEach(
  //           (e) {
  //             if (!e.hasObservers) {
  //               e._clean();
  //             }
  //           },
  //         ),
  //       );
  //     },
  //     watch: watch,
  //     didUpdateWidget: (_, oldWidget) => didUpdateWidget?.call(oldWidget),
  //     builder: (_, rm) {
  //       return child.call(_getCombinedSnap(this), rm!._state)!;
  //     },
  //   );
  // }

  // SnapState _getCombinedSnap(List<ReactiveModel> rms) {
  //   SnapState? snapWaiting;
  //   SnapState? snapError;
  //   SnapState? snapIdle;
  //   for (var e in this) {
  //     if (e._snapState.isWaiting) {
  //       snapWaiting = e._snapState;
  //       break;
  //     }
  //     if (e._snapState.hasError) {
  //       snapError = e._snapState;
  //     }
  //     if (e._snapState.isIdle) {
  //       snapIdle = e._snapState;
  //     }
  //   }
  //   return snapWaiting ??
  //       snapError ??
  //       snapIdle ??
  //       SnapState._withData(ConnectionState.done, 'data', true);
  // }

  /// {@macro injected.rebuilder}
  Widget rebuilder(
    Widget Function() builder, {
    void Function()? initState,
    void Function()? dispose,
    Object Function()? watch,
    bool Function()? shouldRebuild,
    Key? key,
  }) {
    return OnCombined.data((_) => builder()).listenTo<dynamic>(
      this,
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? () => shouldRebuild() : null,
      watch: watch,
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
    return OnCombined.all(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: (err, _) => onError(err),
      onData: (_) => onData(),
    ).listenTo<dynamic>(
      this,
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? () => shouldRebuild() : null,
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
    return OnCombined.or(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError != null ? (err, _) => onError(err) : null,
      onData: onData == null ? null : (_) => onData(),
      or: (_) => builder(),
    ).listenTo<dynamic>(
      this,
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? () => shouldRebuild() : null,
      watch: watch,
    );
  }
}
