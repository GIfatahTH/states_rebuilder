part of '../rm.dart';

///{@template OnBuilder}
///Explicitly listenTo one or more injected state and reinvoke its
///onBuilder callback each time an injected state emits a notification.
///
///For each OnBuilder widget flavor there is method like equivalent:
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
class OnBuilder<T> extends StatelessWidget {
  ///{@macro OnBuilder}
  OnBuilder({
    Key? key,
    this.listenTo,
    this.listenToMany,
    required Widget Function() builder,
    this.sideEffects,
    this.shouldRebuild,
    this.watch,
    this.debugPrintWhenRebuild,
  }) : super(key: key) {
    onBuilder = _On(orElse: (_) => builder());
  }

  OnBuilder.data({
    Key? key,
    this.listenTo,
    this.listenToMany,
    required Widget Function(T data) builder,
    this.sideEffects,
    this.shouldRebuild,
    this.watch,
    this.debugPrintWhenRebuild,
  }) : super(key: key) {
    onBuilder = _On.data(builder);
  }

  OnBuilder.all({
    Key? key,
    this.listenTo,
    this.listenToMany,
    Widget Function()? onIdle,
    required Widget Function() onWaiting,
    required Widget Function(dynamic error, void Function() refreshError)
        onError,
    required Widget Function(T data) onData,
    this.sideEffects,
    this.shouldRebuild,
    this.watch,
    this.debugPrintWhenRebuild,
  }) : super(key: key) {
    onBuilder = _On(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      orElse: onData,
    );
  }

  OnBuilder.orElse({
    Key? key,
    this.listenTo,
    this.listenToMany,
    Widget Function()? onIdle,
    Widget Function()? onWaiting,
    Widget Function(dynamic error, void Function() refreshError)? onError,
    Widget Function(T data)? onData,
    required Widget Function(T data) orElse,
    this.sideEffects,
    this.shouldRebuild,
    this.watch,
    this.debugPrintWhenRebuild,
  }) : super(key: key) {
    onBuilder = _On(
      onIdle: onIdle,
      onWaiting: onWaiting,
      onError: onError,
      onData: onData,
      orElse: orElse,
    );
  }

  ///State to listen to.
  ///
  ///If you want to listen to many injected state and react to a combined state
  ///of the use `listenToMany` parameter.
  final InjectedBaseState<T>? listenTo;

  ///List of states to listenTo
  final List<InjectedBaseState<dynamic>>? listenToMany;

  ///The part of the widget to rebuild on state notification.
  ///
  ///If you listen to many injected state, onBuilder will be invoked in response
  ///to a state that is combined from all injected State.
  late final _On<T> onBuilder;

  ///Side effects to invoke.
  final SideEffects<T>? sideEffects;

  ///Whether to rebuild the widget after state notification.
  final bool Function(SnapState<T> oldSnap, SnapState<T> newSnap)?
      shouldRebuild;

  ///Part of the state to watch, onRebuild will not be invoked unless the watched
  ///param changes.
  final Object? Function()? watch;

  ///Debug print informative message on state notification.
  final String? debugPrintWhenRebuild;

  @override
  Widget build(BuildContext context) {
    if (listenToMany != null) {
      assert(listenTo == null);
      final on = onBuilder.isOnDataOnly
          ? OnCombined<T, Widget>.data(onBuilder.orElse)
          : OnCombined<T, Widget>.or(
              onIdle: onBuilder.onIdle,
              onWaiting: onBuilder.onWaiting,
              onError: onBuilder.onError,
              onData:
                  onBuilder.onData != null ? (_) => onBuilder.onData!(_) : null,
              or: onBuilder.orElse,
            );
      return on.listenTo<T>(
        listenToMany!,
        initState: sideEffects?.initState,
        dispose: sideEffects?.dispose,
        onSetState: sideEffects?.onSetState != null
            ? OnCombined(
                (_) =>
                    sideEffects!.onSetState!(on._combinedSnap as SnapState<T>),
              )
            : null,
        onAfterBuild: sideEffects?.onAfterBuild != null
            ? OnCombined((_) => sideEffects!.onAfterBuild!())
            : null,
        shouldRebuild: shouldRebuild != null
            ? () => shouldRebuild!(
                  on._notifiedInject!.oldSnapState as SnapState<T>,
                  on._notifiedInject!.snapState as SnapState<T>,
                )
            : null,
        key: key,
      );
    }
    assert(listenTo != null);
    final on = onBuilder.isOnDataOnly
        ? On.data(() => onBuilder.orElse(listenTo!.state))
        : On.or(
            onIdle: onBuilder.onIdle,
            onWaiting: onBuilder.onWaiting,
            onError: onBuilder.onError,
            onData: onBuilder.onData != null
                ? () => onBuilder.onData!(listenTo!.state)
                : null,
            or: () => onBuilder.orElse(listenTo!.state),
          );
    return on.listenTo(
      listenTo!,
      initState: sideEffects?.initState,
      dispose: sideEffects?.dispose,
      onSetState: sideEffects?.onSetState != null
          ? On(() => sideEffects!.onSetState!(listenTo!.snapState))
          : null,
      onAfterBuild: sideEffects?.onAfterBuild != null
          ? On(() => sideEffects?.onAfterBuild!())
          : null,
      shouldRebuild: shouldRebuild != null
          ? (snap) =>
              shouldRebuild!(listenTo!.oldSnapState, listenTo!.snapState)
          : null,
      key: key,
    );
  }
}

class SideEffects<T> {
  final void Function()? initState;
  final void Function()? dispose;
  final void Function(SnapState<T>)? onSetState;
  final void Function()? onAfterBuild;
  SideEffects({
    this.initState,
    this.dispose,
    this.onSetState,
    this.onAfterBuild,
  });
}

class _On<T> {
  final Widget Function()? onIdle;
  final Widget Function()? onWaiting;
  final Widget Function(dynamic err, VoidCallback refresh)? onError;
  final Widget Function(T data)? onData;
  final Widget Function(T data) orElse;
  final bool isOnDataOnly;
  _On({
    this.onIdle,
    this.onWaiting,
    this.onError,
    this.onData,
    this.isOnDataOnly = false,
    required this.orElse,
  });
  factory _On.data(Widget Function(T data) onData) {
    return _On(
      isOnDataOnly: true,
      orElse: onData,
    );
  }
}

class OnFutureBuilder<T> extends StatefulWidget {
  const OnFutureBuilder({
    Key? key,
    required this.future,
    required this.onWaiting,
    required this.onError,
    required this.onData,
  }) : super(key: key);
  final Future<T> Function() future;
  final Widget Function() onWaiting;
  final Widget Function(dynamic err, VoidCallback refresh) onError;
  final Widget Function(T data, VoidCallback refresh) onData;

  @override
  _OnFutureBuilderState<T> createState() => _OnFutureBuilderState<T>();
}

class _OnFutureBuilderState<T> extends State<OnFutureBuilder<T>> {
  T? data;
  bool isWaiting = true;
  dynamic err;
  StreamSubscription<T>? _subscription;
  void _init() {
    _subscription = widget.future().asStream().listen(
      (d) {
        setState(
          () {
            data = d;
            isWaiting = false;
            err = null;
          },
        );
      },
      onError: (e, s) {
        setState(() {
          isWaiting = false;
          err = e;
        });
      },
    );
    isWaiting = true;
    err = null;
  }

  void _refresh() {
    setState(() {
      _subscription?.cancel();
      _subscription = null;
      _init();
    });
  }

  @override
  initState() {
    _init();
    super.initState();
  }

  @override
  dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isWaiting) {
      return widget.onWaiting();
    }
    if (err != null) {
      return widget.onError(
        err,
        _refresh,
      );
    }

    return widget.onData(data as T, _refresh);
  }
}

class OnStreamBuilder<T> extends StatefulWidget {
  const OnStreamBuilder({
    Key? key,
    required this.stream,
    required this.onWaiting,
    required this.onError,
    required this.onData,
    this.onDone,
  }) : super(key: key);
  final Stream<T> Function() stream;
  final Widget Function() onWaiting;
  final Widget Function(dynamic err, VoidCallback refreshErr) onError;
  final Widget Function(T data) onData;
  final Widget Function(T data)? onDone;

  @override
  _OnStreamBuilderState<T> createState() => _OnStreamBuilderState<T>();
}

class _OnStreamBuilderState<T> extends State<OnStreamBuilder<T>> {
  T? data;
  bool isWaiting = true;
  bool isDone = false;
  dynamic err;
  StreamSubscription<T>? _subscription;
  void _init() {
    if (_subscription != null) {
      return null;
    }
    _subscription = widget.stream().listen(
      (d) {
        setState(
          () {
            data = d;
            isWaiting = false;
            err = null;
          },
        );
      },
      onError: (e, s) {
        setState(() {
          isWaiting = false;
          err = e;
        });
      },
      onDone: () {
        setState(() {
          isDone = true;
        });
      },
    );
    isWaiting = true;
    isDone = false;
    err = null;
  }

  @override
  initState() {
    _init();
    super.initState();
  }

  @override
  dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isWaiting) {
      return widget.onWaiting();
    }
    if (err != null) {
      return widget.onError(
        err,
        () {
          setState(() {
            _subscription?.cancel();
            _subscription = null;
            _init();
          });
        },
      );
    }
    if (isDone && widget.onDone != null) {
      return widget.onDone!(data as T);
    }
    return widget.onData(data as T);
  }
}
