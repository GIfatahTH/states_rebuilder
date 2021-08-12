import 'package:flutter/material.dart';

import '../rm.dart';

typedef AddObsCallback = void Function(InjectedBaseState);

class OnObs extends MyStatefulWidget {
  const OnObs(this.builder, {Key? key}) : super(key: key);
  final Widget Function() builder;
  @override
  OnObsState createState() => OnObsState();
}

class OnObsState extends ExtendedState<OnObs> {
  static AddObsCallback? addToObs;

  Set<InjectedBaseState> _obs = {};
  List<VoidCallback> _disposer = [];

  late final AddObsCallback addToObs1 = (InjectedBaseState inj) {
    if (_obs.add(inj)) {
      final disposer = inj.observeForRebuild((rm) {
        setState(() {});
      });
      _disposer.add(disposer);
    }
  };

  @override
  void dispose() {
    _disposer.forEach((disposer) => disposer());
    super.dispose();
  }

  var cachedAddToObs;
  @override
  void afterBuild() {
    OnObsState.addToObs = cachedAddToObs;
  }

  @override
  Widget build(BuildContext context) {
    cachedAddToObs = OnObsState.addToObs;
    OnObsState.addToObs = addToObs1;
    return widget.builder();
  }
}
