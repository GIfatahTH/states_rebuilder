part of '../rm.dart';

///An extension of List<Injected>

class _InjectedListXBuilder {
  final List<ReactiveModel<dynamic>> injects;

  _InjectedListXBuilder(this.injects);

  /// {@macro injected.rebuild.call}
  Widget call(
    Widget Function(dynamic data) builder, {
    void Function()? initState,
    void Function()? dispose,
    Object Function()? watch,
    bool Function()? shouldRebuild,
    Key? key,
  }) {
    return OnCombined.data(
      (_) => builder(_),
    ).listenTo<dynamic>(
      injects,
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? () => shouldRebuild() : null,
      watch: watch,
    );
  }

  /// {@macro injected.rebuild.onAll}
  Widget onAll({
    required Widget Function() onIdle,
    required Widget Function() onWaiting,
    required Widget Function(dynamic data) onData,
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
      onData: (_) => onData(_),
    ).listenTo<dynamic>(
      injects,
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? () => shouldRebuild() : null,
    );
  }

  /// {@macro injected.rebuild.onOr}
  Widget onOrElse({
    Widget Function()? onIdle,
    Widget Function()? onWaiting,
    Widget Function(dynamic)? onError,
    Widget Function(dynamic data)? onData,
    required Widget Function(dynamic data) orElse,
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
      onData: onData == null ? null : (_) => onData(_),
      or: (_) => orElse(_),
    ).listenTo<dynamic>(
      injects,
      initState: initState != null ? () => initState() : null,
      dispose: dispose != null ? () => dispose() : null,
      shouldRebuild: shouldRebuild != null ? () => shouldRebuild() : null,
      watch: watch,
    );
  }
}

extension InjectedListX on List<ReactiveModel<dynamic>> {
  _InjectedListXBuilder get rebuild => _InjectedListXBuilder(this);

  /// ### rebuilder is deprecated. Use rebuilder instead
  /// {@macro injected.rebuilder}
  @Deprecated('Use builder instead')
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

  ///  rebuilder is deprecated. Use rebuild.onAll instead
  /// {@macro injected.whenRebuilder}
  @Deprecated('Use rebuild.onAll instead')
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

  /// ### rebuilder is deprecated. Use rebuild.onOr instead
  /// {@macro injected.whenRebuilderOr}
  @Deprecated('Use rebuild.onOr instead')
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
