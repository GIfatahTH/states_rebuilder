part of '../rm.dart';

/// {@template OnBuilder}
/// Explicitly listenTo one or more injected state and reinvoke its
/// onBuilder callback each time an injected state emits a notification.
///
/// For each OnBuilder widget flavor there is method like equivalent:
/// ```dart
/// //Widget-like
/// OnBuilder(
///     listenTo: counter,
///     builder: () => Text('${counter.state}'),
/// ),
///
/// //Method-like
/// counter.rebuild(
///     () => Text('{counter.state}'),
/// ),
/// //
/// //Widget-like
/// OnBuilder.data(
///     listenTo: counter,
///     builder: (data) => Text('$data')),
/// ),
///
/// //Method-like
/// counter.rebuild.onData(
///     (data) => Text(data),
/// ),
///
/// //Widget-like
/// OnBuilder.all(
///     listenTo: counter,
///     onIdle: () => Text('onIdle'),
///     onWaiting: () => Text('onWaiting'),
///     onError: (err, errorRefresh) => Text('onError'),
///     onData: (data) => Text('$data'),
///
/// )
///
/// //Method-like
/// counter.rebuild.onAll(
///     onIdle: () => Text('onIdle'),
///     onWaiting: () => Text('onWaiting'),
///     onError: (err, errorRefresh) => Text('onError'),
///     onData: (data) => Text('$data'),
/// ),
/// //
/// //Widget-like
/// OnBuilder.orElse(
///     listenTo: counter,
///     onWaiting: () => Text('onWaiting'),
///     orElse: (_) => Text('{counter.state}'),
///
/// ),
///
/// //Method-like
/// counter.rebuild.onOrElse(
///     onWaiting: () => Text('onWaiting'),
///     orElse: (_) => Text('{counter.state}'),
/// ),
/// ```
/// {@endtemplate}
class OnBuilder<T> extends MyStatefulWidget<T> {
  // OnBuilder._({
  //   required Key? key,
  //   required ReactiveModel<T>? listenTo,
  //   required this.build,
  //   required this.onStatus,
  //   // this.listenToMany,
  //   required SideEffects<T>? sideEffects,
  //   // this.shouldRebuild,
  //   // this.watch,
  //   // this.debugPrintWhenRebuild,
  // }) : super(
  //         initState: (context) => [listenTo as ReactiveModelImp<T>],
  //         sideEffects: sideEffects,
  //         shouldRebuild: onStatus != null
  //             ? (oldSnap, newSnap) {
  //                 if (onStatus != newSnap.status) {
  //                   return false;
  //                 }
  //                 return true;
  //               }
  //             : null,
  //         builder: (context, rm) => build!(rm),
  //         key: key,
  //       );

  ///{@macro OnBuilder}
  OnBuilder({
    Key? key,
    ReactiveModel<T>? listenTo,
    List<ReactiveModel>? listenToMany,
    required Widget Function() builder,
    SideEffects<T>? sideEffects,
    ShouldRebuild? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
  })  : assert(listenTo != null || listenToMany != null),
        super(
          key: key,
          observers: (_) => listenTo != null
              ? [listenTo as ReactiveModelImp]
              : listenToMany!.cast<ReactiveModelImp>(),
          builder: (_, __, ___) => builder(),
          sideEffects: sideEffects,
          shouldRebuild: shouldRebuild,
        );

  ///{@macro OnBuilder}
  OnBuilder.data({
    Key? key,
    ReactiveModel<T>? listenTo,
    List<ReactiveModel>? listenToMany,
    required Widget Function(T data) builder,
    SideEffects<T>? sideEffects,
    ShouldRebuild? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
  })  : assert(listenTo != null || listenToMany != null),
        super(
          key: key,
          observers: (_) => listenTo != null
              ? [listenTo as ReactiveModelImp]
              : listenToMany!.cast<ReactiveModelImp>(),
          builder: (_, snap, ___) => builder(snap.state),
          sideEffects: sideEffects,
          shouldRebuild: (oldSnap, newSnap) {
            if (StateStatus.hasData == newSnap.status ||
                StateStatus.isIdle == newSnap.status) {
              return shouldRebuild?.call(oldSnap, newSnap) ?? true;
            }
            return false;
          },
        );

  // {
  //   // return OnBuilder._(
  //   //   key: key,
  //   //   listenTo: listenTo,
  //   //   build: (_) => builder(_.state),
  //   //   onStatus: StateStatus.hasData,
  //   //   sideEffects: sideEffects,
  //   // );
  // }

  /// If creator is null, a ReactiveModel<void> is created and exposed
  OnBuilder.create({
    Key? key,
    @Deprecated('Use creator instead') ReactiveModel<T> Function()? create,
    T Function()? creator,
    SideEffects<T>? sideEffects,
    required Widget Function(ReactiveModel<T> rm) builder,
  }) : super(
          key: key,
          observers: (_) => [
            creator != null
                ? ReactiveModel<T>.create(
                    creator: creator,
                    initialState: null,
                    autoDisposeWhenNotUsed: true,
                  ) as ReactiveModelImp<T>
                : create != null
                    ? create() as ReactiveModelImp<T>
                    : ReactiveModel<T>.create(
                        creator: () {},
                        initialState: null,
                        autoDisposeWhenNotUsed: true,
                      ) as ReactiveModelImp<void>,
          ],
          builder: (_, __, rm) => builder(rm),
          sideEffects: sideEffects,
        );
  OnBuilder.createFuture({
    Key? key,
    required Future<T> Function() creator,
    T? initialState,
    SideEffects<T>? sideEffects,
    required Widget Function(ReactiveModel<T> rm) builder,
  }) : super(
          key: key,
          observers: (_) => [
            ReactiveModel<T>.create(
              creator: creator,
              initialState: initialState,
              autoDisposeWhenNotUsed: true,
            ) as ReactiveModelImp
          ],
          builder: (_, __, rm) => builder(rm),
          sideEffects: sideEffects,
        );
  OnBuilder.createStream({
    Key? key,
    required Stream<T> Function() creator,
    T? initialState,
    SideEffects<T>? sideEffects,
    required Widget Function(ReactiveModel<T> rm) builder,
  }) : super(
          key: key,
          observers: (_) => [
            ReactiveModel<T>.create(
              creator: creator,
              initialState: initialState,
              autoDisposeWhenNotUsed: true,
            ) as ReactiveModelImp
          ],
          builder: (_, __, rm) => builder(rm),
          sideEffects: sideEffects,
        );

  ///{@macro OnBuilder}
  OnBuilder.all({
    Key? key,
    ReactiveModel<T>? listenTo,
    List<ReactiveModel>? listenToMany,
    OnIdle? onIdle,
    required OnWaiting onWaiting,
    required OnError onError,
    required OnData<T> onData,
    SideEffects<T>? sideEffects,
    ShouldRebuild? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
  })  : assert(listenTo != null || listenToMany != null),
        super(
          key: key,
          observers: (_) => listenTo != null
              ? [listenTo as ReactiveModelImp]
              : listenToMany!.cast<ReactiveModelImp>(),
          builder: (_, snap, ___) {
            return snap.onAll<Widget>(
              onIdle: onIdle,
              onWaiting: onWaiting,
              onError: onError,
              onData: (_) => onData(_),
            );
          },
          sideEffects: sideEffects,
          shouldRebuild: shouldRebuild,
        );

  ///{@macro OnBuilder}
  OnBuilder.orElse({
    Key? key,
    ReactiveModel<T>? listenTo,
    List<ReactiveModel>? listenToMany,
    Widget Function()? onIdle,
    Widget Function()? onWaiting,
    Widget Function(dynamic error, void Function() refreshError)? onError,
    Widget Function(T data)? onData,
    required Widget Function(T data) orElse,
    SideEffects<T>? sideEffects,
    ShouldRebuild? shouldRebuild,
    Object? Function()? watch,
    String? debugPrintWhenRebuild,
  })  : assert(listenTo != null || listenToMany != null),
        super(
          key: key,
          observers: (_) => listenTo != null
              ? [listenTo as ReactiveModelImp]
              : listenToMany!.cast<ReactiveModelImp>(),
          builder: (_, snap, ___) {
            return snap.onOrElse<Widget>(
              onIdle: onIdle,
              onWaiting: onWaiting,
              onError: onError,
              onData: onData != null ? (_) => onData(_) : null,
              orElse: (_) => orElse(_),
            );
          },
          sideEffects: sideEffects,
          shouldRebuild: shouldRebuild,
        );
  // final Widget Function(ReactiveModelImp rm)? build;
  // final StateStatus? onStatus;

  factory OnBuilder.bindingObserver({
    Key? key,
    ReactiveModel<T>? listenTo,
    required Widget Function() builder,
    // this.listenToMany,
    SideEffects<T>? sideEffects,
    ShouldRebuild? shouldRebuild,
    // this.watch,
    // this.debugPrintWhenRebuild,
    void Function(BuildContext context, AppLifecycleState state)?
        didChangeAppLifecycleState,
    void Function(BuildContext context, List<Locale>? locale)? didChangeLocales,
  }) {
    return OnBuilderBindingObserver<T>(
      listenTo: listenTo,
      builder: builder,
      sideEffects: sideEffects,
      shouldRebuild: shouldRebuild,
      didChangeAppLifecycleState: didChangeAppLifecycleState,
      didChangeLocales: didChangeLocales,
    );
  }
}

class OnBuilderBindingObserver<T> extends OnBuilder<T> {
  OnBuilderBindingObserver({
    Key? key,
    ReactiveModel<T>? listenTo,
    required Widget Function() builder,
    // this.listenToMany,
    SideEffects<T>? sideEffects,
    ShouldRebuild? shouldRebuild,
    this.didChangeAppLifecycleState,
    this.didChangeLocales,
  }) : super(
          listenTo: listenTo ?? ReactiveModel.create(creator: () => null),
          key: key,
          builder: builder,
          sideEffects: sideEffects,
          shouldRebuild: shouldRebuild,
        );

  ///Called when the system puts the app in the background or returns the app to the foreground.
  ///
  ///The third parameter depends on the mixin used. It is a TickerProvider for tickerProviderStateMixin
  final void Function(BuildContext context, AppLifecycleState state)?
      didChangeAppLifecycleState;

  ///Called when the system tells the app that the user's locale has changed.
  ///For example, if the user changes the system language settings.
  ///* Required parameters:
  ///   * [BuildContext] (positional parameter): the [BuildContext]
  ///   * [List<Locale>] (positional parameter): List of system Locales as defined in
  /// the system language settings
  final void Function(BuildContext context, List<Locale>? locale)?
      didChangeLocales;
  @override
  _OnBuilderBindingObserverState<T> createState() =>
      _OnBuilderBindingObserverState<T>();
}

class _OnBuilderBindingObserverState<T> extends _MyStatefulWidgetState<T>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    (widget as OnBuilderBindingObserver)
        .didChangeAppLifecycleState
        ?.call(context, state);
  }

  @override
  void didChangeLocales(List<Locale>? locale) {
    (widget as OnBuilderBindingObserver)
        .didChangeLocales
        ?.call(context, locale);
  }
}
