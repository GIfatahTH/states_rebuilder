import 'package:flutter/material.dart';

import '../rm.dart';

/// Extension on ReactiveModel<bool>
extension ReactiveModelBool on ReactiveModel<bool> {
  /// Toggle the state and notify listeners
  void toggle() {
    state = !state;
  }
}

/// Extension on ReactiveModel
extension ReactiveModeX<T> on ReactiveModel<T> {
  /// listen to the state
  _Rebuild<T> get rebuild => _Rebuild<T>(this, null);
}

/// Extension on List<ReactiveModel>

extension ReactiveModeListX on List<ReactiveModel> {
  /// listen to the list of states
  _Rebuild get rebuild => _Rebuild(null, this);
}

class _Rebuild<T> {
  final ReactiveModel<T>? _injected;
  final List<ReactiveModel>? _injectedList;
  _Rebuild(this._injected, this._injectedList);

  /// {@template injected.rebuild.call}
  ///Listen to the reactive (injected) model and invoke the [builder] whenever the
  ///injected model is notified with any kind of state status (isWaiting,
  ///hasData, hasError).
  ///
  /// * Required parameters:
  ///     * [builder] (positional parameter) is called each time the
  /// injected model emits a notification with any kind of status flag.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * [watch] : callback to be executed before notifying listeners.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  ///    * [onSetState] :For side effects before rebuilding the widget tree.
  ///    * [onAfterBuild] :For side effects after rebuilding the widget tree.
  ///    * [debugPrintWhenRebuild] : Print state transition log.
  /// {@endtemplate}
  Widget call(
    Widget Function() builder, {
    SideEffects<T>? sideEffects,
    bool Function(SnapState<T>, SnapState<T>)? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    return OnBuilder<T>(
      listenTo: _injected,
      listenToMany: _injectedList,
      sideEffects: sideEffects,
      shouldRebuild: shouldRebuild != null
          ? (old, current) => shouldRebuild(
                old as SnapState<T>,
                current as SnapState<T>,
              )
          : null,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      watch: watch,
      builder: builder,
    );
  }

  /// {@template injected.rebuild.onData}
  ///Listen to the reactive (injected) model and invoke the [builder] whenever the
  ///injected model is notified with hasData flag.
  ///
  /// * Required parameters:
  ///     * [builder] (positional parameter) is called each time the
  /// injected model emits a notification with hasData status flag.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * [watch] : callback to be executed before notifying listeners.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  ///    * [onSetState] :For side effects before rebuilding the widget tree.
  ///    * [onAfterBuild] :For side effects after rebuilding the widget tree.
  ///    * [debugPrintWhenRebuild] : Print state transition log.
  /// {@endtemplate}
  Widget onData(
    Widget Function(T data) builder, {
    SideEffects<T>? sideEffects,
    Object? Function()? watch,
    bool Function(SnapState<T>, SnapState<T>)? shouldRebuild,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    return OnBuilder.data(
      listenTo: _injected,
      listenToMany: _injectedList,
      sideEffects: sideEffects,
      shouldRebuild: shouldRebuild != null
          ? (old, current) => shouldRebuild(
                old as SnapState<T>,
                current as SnapState<T>,
              )
          : null,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      watch: watch,
      builder: builder,
    );
  }

  /// {@template injected.rebuild.onAll}
  ///Listen to the injected Model and rebuild when it emits a notification.
  ///
  /// * Required parameters:
  ///     * [onIdle] : callback to be executed when injected model is in its
  /// initial state.
  ///     * [onWaiting] : callback to be executed when injected model is in
  /// waiting state.
  ///     * [onError] : callback to be executed when injected model has error.
  ///     * [onData] : callback to be executed when injected model has data.
  /// * Optional parameters:
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///    * [onSetState] :For side effects before rebuilding the widget tree.
  ///    * [onAfterBuild] :For side effects after rebuilding the widget tree.
  ///    * [debugPrintWhenRebuild] : Print state transition log.
  /// {@endtemplate}
  Widget onAll({
    Widget Function()? onIdle,
    required Widget Function() onWaiting,
    required Widget Function(dynamic err, void Function() refreshError) onError,
    required Widget Function(T data) onData,
    SideEffects<T>? sideEffects,
    Object? Function()? watch,
    bool Function(SnapState<T>, SnapState<T>)? shouldRebuild,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    return OnBuilder.all(
      listenTo: _injected,
      listenToMany: _injectedList,
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
      sideEffects: sideEffects,
      shouldRebuild: shouldRebuild != null
          ? (old, current) => shouldRebuild(
                old as SnapState<T>,
                current as SnapState<T>,
              )
          : null,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      watch: watch,
    );
  }

  /// {@template injected.rebuild.onOr}
  ///Listen to the injected Model and rebuild when it emits a notification.
  ///
  /// * Required parameters:
  ///     * [builder] Default callback (called in replacement of any non
  /// defined optional parameters [onIdle], [onWaiting], [onError] and
  /// [onData]).
  /// * Optional parameters:
  ///     * [onIdle] : callback to be executed when injected model is in its
  /// initial state.
  ///     * [onWaiting] : callback to be executed when injected model is in
  /// waiting state.
  ///     * [onError] : callback to be executed when injected model has error.
  ///     * [onData] : callback to be executed when injected model has data.
  ///     * [initState] : callback to be executed when the widget is first
  /// inserted into the widget tree.
  ///     * [dispose] : callback to be executed when the widget is removed from
  /// the widget tree.
  ///     * [shouldRebuild] : Callback to determine whether this StateBuilder
  /// will rebuild or not.
  ///     * [watch] : callback to be executed before notifying listeners.
  /// It the returned value is the same as the last one, the rebuild process
  /// is interrupted.
  ///    * [onSetState] :For side effects before rebuilding the widget tree.
  ///    * [onAfterBuild] :For side effects after rebuilding the widget tree.
  ///    * [debugPrintWhenRebuild] : Print state transition log.
  /// {@endtemplate}
  Widget onOrElse({
    Widget Function()? onIdle,
    Widget Function()? onWaiting,
    Widget Function(dynamic err, void Function() refreshError)? onError,
    Widget Function(T data)? onData,
    required Widget Function(T data) orElse,
    SideEffects<T>? sideEffects,
    Object? Function()? watch,
    bool Function(SnapState<T>, SnapState<T>)? shouldRebuild,
    String? debugPrintWhenRebuild,
    Key? key,
  }) {
    return OnBuilder.orElse(
      listenTo: _injected,
      listenToMany: _injectedList,
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
      orElse: orElse,
      sideEffects: sideEffects,
      shouldRebuild: shouldRebuild != null
          ? (old, current) => shouldRebuild(
                old as SnapState<T>,
                current as SnapState<T>,
              )
          : null,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
      watch: watch,
    );
  }
}
