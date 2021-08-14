import 'package:flutter/material.dart';

import '../rm.dart';

typedef AddObsCallback = void Function(InjectedBaseState);

class OnReactive extends MyStatefulWidget {
  const OnReactive(
    this.builder, {
    // this.initState,
    // this.dispose,
    // this.onSetState,
    this.shouldRebuild,
    this.sideEffects,
    Key? key,
  }) : super(key: key);
  final Widget Function() builder;
  final SideEffects? sideEffects;
  // final VoidCallback? initState;
  // final VoidCallback? dispose;
  // final void Function(SnapState<dynamic> snap)? onSetState;
  final bool Function(SnapState<dynamic> oldSnap, SnapState<dynamic> newSnap)?
      shouldRebuild;
  @override
  OnReactiveState createState() => OnReactiveState();
}

class OnReactiveState extends ExtendedState<OnReactive> {
  static AddObsCallback? addToObs;
  AddObsCallback? cachedAddToObs;

  Set<InjectedBaseState> _obs = {};
  List<VoidCallback> _disposer = [];
  Widget? _widget;

  late final AddObsCallback _addToObs = (InjectedBaseState inj) {
    if (_obs.add(inj)) {
      final disposer = inj.observeForRebuild(
        (rm) {
          if (widget.shouldRebuild?.call(rm!.oldSnapState, rm.snapState) ==
              false) {
            return;
          }
          setState(() {
            _widget = null;
            widget.sideEffects?.onSetState?.call(rm!.snapState);
          });
        },
        clean: () => inj.dispose(),
      );
      _disposer.add(disposer);
    }
  };

  @override
  void initState() {
    widget.sideEffects?.initState?.call();
    super.initState();
  }

  @override
  void dispose() {
    widget.sideEffects?.dispose?.call();
    _disposer.forEach((disposer) => disposer());
    super.dispose();
  }

  @override
  void afterBuild() {
    OnReactiveState.addToObs = cachedAddToObs;
    widget.sideEffects?.onAfterBuild?.call();
  }

  @override
  void reassemble() {
    _widget = null;
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = _addToObs;
    return _widget ??= widget.builder();
  }
}
