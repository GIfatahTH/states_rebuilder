part of '../rm.dart';

///An extension of List<Injected>

extension InjectedListX on List<InjectedBaseState<dynamic>> {
  /// {@macro injected.rebuilder}
  Widget rebuilder(
    Widget Function() builder, {
    void Function()? initState,
    void Function()? dispose,
    Object Function()? watch,
    bool Function()? shouldRebuild,
    Key? key,
  }) {
    return OnCombined.data(
      (_) => builder(),
    ).listenTo<dynamic>(
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

  ///{@macro inherited}
  Widget inherited({
    Key? key,
    required Widget Function(BuildContext) builder,
  }) {
    assert(this is List<Injected<dynamic>>);
    final self = this as List<Injected<dynamic>>;
    final lastWidget =
        self[length - 1].inherited(builder: (ctx) => builder(ctx));
    if (length == 1) {
      return lastWidget;
    }

    Widget? widget;
    for (var i = length - 2; i >= 0; i--) {
      var temp = widget ?? lastWidget;
      widget = self[i].inherited(builder: (ctx) => temp);
    }
    return widget!;
  }
}
