import 'package:flutter/material.dart';

import '../rm.dart';

typedef AddObsCallback = void Function(InjectedBaseState);

class OnReactive extends MyStatefulWidget {
  const OnReactive(
    this.builder, {
    this.initState,
    this.dispose,
    this.onSetState,
    this.shouldRebuild,
    Key? key,
  }) : super(key: key);
  final Widget Function() builder;
  final VoidCallback? initState;
  final VoidCallback? dispose;
  final void Function(SnapState<dynamic> snap)? onSetState;
  final bool Function(SnapState<dynamic> oldSnap, SnapState<dynamic> newSnap)?
      shouldRebuild;
  @override
  OnReactiveState createState() => OnReactiveState();
}

class OnReactiveState extends ExtendedState<OnReactive> {
  static AddObsCallback? addToObs;

  Set<InjectedBaseState> _obs = {};
  List<VoidCallback> _disposer = [];

  late final AddObsCallback _addToObs = (InjectedBaseState inj) {
    if (_obs.add(inj)) {
      final disposer = inj.observeForRebuild((rm) {
        if (widget.shouldRebuild?.call(rm!.oldSnapState, rm.snapState) ==
            false) {
          return;
        }
        setState(() {
          widget.onSetState?.call(rm!.snapState);
        });
      });
      _disposer.add(disposer);
    }
  };

  @override
  void initState() {
    widget.initState?.call();
    super.initState();
  }

  @override
  void dispose() {
    widget.dispose?.call();
    _disposer.forEach((disposer) => disposer());
    super.dispose();
  }

  var cachedAddToObs;
  @override
  void afterBuild() {
    OnReactiveState.addToObs = cachedAddToObs;
  }

  @override
  Widget build(BuildContext context) {
    cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = _addToObs;
    return widget.builder();
  }
}
