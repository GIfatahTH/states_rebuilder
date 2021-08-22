import 'package:flutter/material.dart';
import 'package:states_rebuilder/src/common/logger.dart';

import '../rm.dart';

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
class OnReactive extends MyStatefulWidget {
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
  OnReactiveState createState() => OnReactiveState();
}

class OnReactiveState extends ExtendedState<OnReactive> {
  static AddObsCallback? addToObs;
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
          if (widget.shouldRebuild?.call(rm!.oldSnapState, rm.snapState) ==
              false) {
            return;
          }
          setState(() {
            assert(() {
              if (widget.debugPrintWhenRebuild != null) {
                StatesRebuilerLogger.log('REBUILD <' +
                    widget.debugPrintWhenRebuild! +
                    '>: ${inj.snapState.toString()}');
              }
              return true;
            }());
            widget.sideEffects?.onSetState?.call(rm!.snapState);
          });
        },
        clean: inj.autoDisposeWhenNotUsed ? () => inj.dispose() : null,
      );
      assert(() {
        if (widget.debugPrintWhenObserverAdd != null) {
          StatesRebuilerLogger.log(widget.debugPrintWhenObserverAdd! +
              ': ${_obs2!.length} observers : ${_obs2!.keys}');
        }
        return true;
      }());
    }
  };

  @override
  void initState() {
    assert(() {
      if (widget.debugPrintWhenRebuild != null) {
        StatesRebuilerLogger.log(
          'INITIAL BUILD <' + widget.debugPrintWhenRebuild! + '>',
        );
      }
      return true;
    }());
    removeFromContextSet = addToContextSet(context);
    widget.sideEffects?.initState?.call();
    super.initState();
  }

  @override
  void dispose() {
    widget.sideEffects?.dispose?.call();
    _obs1.values.forEach((disposer) => disposer());
    removeFromContextSet();
    super.dispose();
  }

  @override
  void afterBuild() {
    _obs1.values.forEach((disposer) => disposer());
    _obs1 = _obs2 ?? {};
    _obs2 = null;
    _obs2 = {};
    OnReactiveState.addToObs = cachedAddToObs;
    widget.sideEffects?.onAfterBuild?.call();
  }

  @override
  Widget build(BuildContext context) {
    cachedAddToObs = OnReactiveState.addToObs;
    OnReactiveState.addToObs = _addToObs;
    return widget.builder();
  }
}
