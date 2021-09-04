import 'package:flutter/material.dart';

import '../rm.dart';
import 'on_reactive.dart';

abstract class ReactiveStatelessWidget extends MyStatefulWidget {
  const ReactiveStatelessWidget({Key? key}) : super(key: key);

  ///Called when the widget is first inserted in the widget tree
  void didMountWidget() {}

  ///Called when the widget is  removed from the widget tree
  void didUnmountWidget() {}

  ///Called when the widget is notified to rebuild, it exposes the SnapState of
  ///the state that emits the notification
  void didNotifyWidget(SnapState<dynamic> snap) {}

  ///Condition on when to rebuild the widget, it exposes the old and the new
  ///SnapState of the the state that emits the notification.
  bool shouldRebuildWidget(
      SnapState<dynamic> oldSnap, SnapState<dynamic> currentSnap) {
    return true;
  }

  ///Called in debug mode only when an state is added to the list of listeners
  void didAddObserverForDebug(List<InjectedBaseState> observers) {}
  Widget build(BuildContext context);
  @override
  _ReactiveStatelessWidgetState createState() =>
      _ReactiveStatelessWidgetState();
}

class _ReactiveStatelessWidgetState
    extends ExtendedState<ReactiveStatelessWidget> {
  AddObsCallback? cachedAddToObs;
  late VoidCallback removeFromContextSet;
  Map<InjectedBaseState, VoidCallback> _obs1 = {};
  Map<InjectedBaseState, VoidCallback>? _obs2 = {};
  late final AddObsCallback _addToObs = (InjectedBaseState inj) {
    final value = _obs1.remove(inj);
    if (value != null) {
      _obs2![inj] = value;
      return;
    }
    if (!_obs2!.containsKey(inj)) {
      _obs2![inj] = inj.observeForRebuild(
        (rm) {
          if (widget.shouldRebuildWidget(rm!.oldSnapState, rm.snapState)) {
            setState(() {});
          }
          widget.didNotifyWidget(rm.snapState);
        },
        clean: inj.autoDisposeWhenNotUsed ? () => inj.dispose() : null,
      );
      assert(() {
        widget.didAddObserverForDebug(_obs2!.keys.toList());
        return true;
      }());
    }
  };
  @override
  void afterBuild() {
    _obs1.values.forEach((disposer) => disposer());
    _obs1 = _obs2 ?? {};
    _obs2 = null;
    _obs2 = {};
    OnReactiveState.addToObs = cachedAddToObs;
  }

  @override
  void initState() {
    super.initState();
    widget.didMountWidget();
    removeFromContextSet = addToContextSet(context);
  }

  @override
  void dispose() {
    _obs1.values.forEach((disposer) => disposer());
    removeFromContextSet();
    widget.didUnmountWidget();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = _addToObs;
    return widget.build(context);
  }
}
