import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/common/logger.dart';

import '../rm.dart';
import 'reactive_state_less_widget.dart';

typedef AddObsCallback = void Function(InjectedBaseState);

///{@template OnReactive}
///First choice widget to listen to an injected state.
///
///It explicitly register injected state consumed in its child widget tree.
///
///Example:
///
/// ```dart
/// final counter1 = RM.inject(()=> 0) // Or just use extension: 0.inj()
/// final counter2 = 0.inj();
/// int get sum => counter1.state + counter2.state;
///
/// //In the widget tree:
/// Column(
///     children: [
///         OnReactive( // Will listen to counter1
///             ()=> Text('${counter1.state}');
///         ),
///         OnReactive( // Will listen to counter2
///             ()=> Text('${counter2.state}');
///         ),
///         OnReactive(// Will listen to both counter1 and counter2
///             ()=> Text('$sum');
///         )
///     ]
/// )
/// ```
/// {@endtemplate}
class OnReactive extends ReactiveStatelessWidget {
  ///{@macro OnReactive}
  const OnReactive(
    this.builder, {
    this.shouldRebuild,
    this.sideEffects,
    this.debugPrintWhenRebuild,
    this.debugPrintWhenObserverAdd,
    Key? key,
  }) : super(key: key);

  ///Widget tree to rebuild when any of subscribed state emits notification.
  final Widget Function() builder;

  ///Side effects to be invoked
  final SideEffects? sideEffects;

  ///Whether to rebuild the widget after a state emits notification.
  ///
  ///If the OnReactive listens to many states, the exposed snapState is
  ///that of the state that emits the notification
  final bool Function(SnapState<dynamic> oldSnap, SnapState<dynamic> newSnap)?
      shouldRebuild;

  ///Debug print an informative message when the widget is rebuild with
  ///the name of the state that has emitted the notification.
  final String? debugPrintWhenRebuild;

  ///Debug print an informative message when a state is added to the
  ///list of subscription.
  final String? debugPrintWhenObserverAdd;

  @override
  void didMountWidget() {
    assert(() {
      if (debugPrintWhenRebuild != null) {
        StatesRebuilerLogger.log(
          'INITIAL BUILD <' + debugPrintWhenRebuild! + '>',
        );
      }
      return true;
    }());
    sideEffects?.initState?.call();
  }

  @override
  void didUnmountWidget() {
    sideEffects?.dispose?.call();
  }

  @override
  void didNotifyWidget(SnapState snap) {
    sideEffects?.onSetState?.call(snap);
    if (sideEffects?.onSetState != null) {
      WidgetsBinding.instance?.addPostFrameCallback(
        (_) => sideEffects?.onAfterBuild?.call(),
      );
    }
    assert(() {
      if (debugPrintWhenRebuild != null) {
        StatesRebuilerLogger.log(
            'REBUILD <' + debugPrintWhenRebuild! + '>: $snap');
      }
      return true;
    }());
  }

  @override
  bool shouldRebuildWidget(SnapState oldSnap, SnapState newSnap) {
    return shouldRebuild?.call(oldSnap, newSnap) ?? true;
  }

  @override
  void didAddObserverForDebug(obs) {
    if (debugPrintWhenObserverAdd != null) {
      StatesRebuilerLogger.log(
          debugPrintWhenObserverAdd! + ': ${obs.length} observers : $obs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return builder();
  }
}

class OnReactiveState {
  static AddObsCallback? addToObs;
}
