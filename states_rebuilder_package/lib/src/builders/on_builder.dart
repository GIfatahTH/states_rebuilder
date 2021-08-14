part of '../rm.dart';

class OnBuilder<T> extends StatelessWidget {
  OnBuilder({
    Key? key,
    this.listenTo,
    this.listenToMany,
    required this.onBuilder,
    this.sideEffects,
    this.shouldRebuild,
    this.watch,
    this.debugPrintWhenRebuild,
  }) : super(key: key);

  final InjectedBaseState<T>? listenTo;
  final List<InjectedBaseState<dynamic>>? listenToMany;
  final On<Widget> onBuilder;
  final SideEffects<T>? sideEffects;
  final Function(SnapState<T> oldSnap, SnapState<T> newSnap)? shouldRebuild;
  final Object? Function()? watch;
  final String? debugPrintWhenRebuild;

  @override
  Widget build(BuildContext context) {
    if (listenToMany != null) {
      assert(listenTo == null);
      final on = OnCombined.or(
        onIdle: onBuilder._onIdle,
        onWaiting: onBuilder._onWaiting,
        onError: onBuilder._onError,
        or: (_) => onBuilder._onData!(),
      );
      return on.listenTo(
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

    return onBuilder.listenTo(
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

class OnAnimationBuilder extends StatelessWidget {
  const OnAnimationBuilder({
    Key? key,
    required this.listenTo,
    required this.builder,
    this.onInitialized,
  }) : super(key: key);
  final InjectedAnimation listenTo;
  final Widget Function(Animate) builder;
  final void Function()? onInitialized;
  @override
  Widget build(BuildContext context) {
    return On.animation(builder).listenTo(
      listenTo,
      onInitialized: onInitialized,
    );
  }
}

class OnCRUDBuilder extends StatelessWidget {
  const OnCRUDBuilder({
    Key? key,
    required this.listenTo,
    this.onWaiting,
    this.onError,
    required this.onResult,
    this.dispose,
    this.onSetState,
    this.debugPrintWhenRebuild,
  }) : super(key: key);
  final InjectedCRUD listenTo;
  final Widget Function()? onWaiting;
  final Widget Function(dynamic, void Function())? onError;
  final Widget Function(dynamic) onResult;
  final Function()? dispose;
  final On<void>? onSetState;
  final String? debugPrintWhenRebuild;
  @override
  Widget build(BuildContext context) {
    return On.crud(
      onWaiting: onWaiting,
      onError: onError,
      onResult: onResult,
    ).listenTo(
      listenTo,
      onSetState: onSetState,
      dispose: dispose,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }
}

class OnAuthBuilder extends StatelessWidget {
  const OnAuthBuilder({
    Key? key,
    required this.listenTo,
    required this.onUnsigned,
    required this.onSigned,
    this.onInitialWaiting,
    this.useRouteNavigation = false,
    this.onWaiting,
    this.dispose,
    this.onSetState,
    this.debugPrintWhenRebuild,
  }) : super(key: key);
  final InjectedAuth listenTo;
  final Widget Function()? onInitialWaiting;
  final Widget Function()? onWaiting;
  final Widget Function() onUnsigned;
  final Widget Function() onSigned;
  final bool useRouteNavigation;
  final void Function()? dispose;
  final On<void>? onSetState;
  final String? debugPrintWhenRebuild;
  @override
  Widget build(BuildContext context) {
    return On.auth(
      onInitialWaiting: onInitialWaiting,
      onWaiting: onWaiting,
      onUnsigned: onUnsigned,
      onSigned: onSigned,
    ).listenTo(
      listenTo,
      useRouteNavigation: useRouteNavigation,
      onSetState: onSetState,
      dispose: dispose,
      key: key,
      debugPrintWhenRebuild: debugPrintWhenRebuild,
    );
  }
}

class OnScrollBuilder extends StatelessWidget {
  const OnScrollBuilder({
    Key? key,
    required this.listenTo,
    required this.builder,
  }) : super(key: key);
  final InjectedScrolling listenTo;
  final Widget Function(InjectedScrolling) builder;
  @override
  Widget build(BuildContext context) {
    return On.scroll(builder).listenTo(
      listenTo,
      key: key,
    );
  }
}

class OnFormBuilder extends StatelessWidget {
  const OnFormBuilder({
    Key? key,
    required this.listenTo,
    required this.builder,
  }) : super(key: key);
  final InjectedForm listenTo;
  final Widget Function() builder;
  @override
  Widget build(BuildContext context) {
    return On.form(builder).listenTo(
      listenTo,
      key: key,
    );
  }
}

class OnFormSubmissionBuilder extends StatelessWidget {
  const OnFormSubmissionBuilder({
    Key? key,
    required this.listenTo,
    required this.onSubmitting,
    this.onSubmissionError,
    required this.child,
  }) : super(key: key);
  final InjectedForm listenTo;
  final Widget Function() onSubmitting;
  final Widget Function(dynamic error, VoidCallback onRefresh)?
      onSubmissionError;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return On.formSubmission(
      onSubmitting: onSubmitting,
      onSubmissionError: onSubmissionError,
      child: child,
    ).listenTo(
      listenTo,
      key: key,
    );
  }
}

class OnTabBuilder extends StatelessWidget {
  const OnTabBuilder({
    Key? key,
    required this.listenTo,
    required this.builder,
  }) : super(key: key);
  final InjectedTab listenTo;
  final Widget Function() builder;
  @override
  Widget build(BuildContext context) {
    return On.tab(builder).listenTo(
      listenTo,
      key: key,
    );
  }
}
