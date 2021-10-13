import 'package:flutter/material.dart';
import 'top_stateless_widget.dart';
import '../common/logger.dart';

import '../rm.dart';
import 'on_reactive.dart';

typedef AddObsCallback = void Function(InjectedBaseState);

/// Use it instead of [StatelessWidget] to make the hole sub tree reactive.
///
/// Any state consumed in any widget child of the widget where the
/// [ReactiveStatelessWidget] will be registered.
///
/// The list of registered states are updated for each rebuild. And any non used
/// state will be removed from the list of subscribers.
///
/// Example:
/// ```dart
/// @immutable
/// class ViewModel {
///   // Inject a reactive state of type int.
///   // Works for all primitives, List, Map and Set
///   final counter1 = 0.inj();
///
///   // For non primitives and for more options
///   final counter2 = RM.inject<Counter>(
///     () => Counter(0),
///     // State will be redone and undone
///     undoStackLength: 8,
///     // Build-in logger
///     debugPrintWhenNotifiedPreMessage: 'counter2',
///   );
///
///   //A getter that uses the state of the injected counters
///   int get sum => counter1.state + counter2.state.value;
///
///   incrementCounter1() {
///     counter1.state++;
///   }
///
///   incrementCounter2() {
///     counter2.state = Counter(counter2.state.value + 1);
///   }
/// }
/// class CounterApp extends ReactiveStatelessWidget {
///    const CounterApp();
///
///     @override
///     Widget build(BuildContext context) {
///       return Column(
///         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
///         children: [
///           Counter1View(),
///           Counter2View(),
///           Text('🏁 Result: ${viewModel.sum}'), // Will be updated when sum changes
///         ],
///       );
///     }
///   }
///
///   // Child 1 - Plain StatelessWidget
///   class Counter1View extends StatelessWidget {
///     const Counter1View({Key? key}) : super(key: key);
///
///     @override
///     Widget build(BuildContext context) {
///       return Column(
///         children: [
///           ElevatedButton(
///             child: const Text('🏎️ Counter1 ++'),
///             onPressed: () => viewModel.incrementCounter1(),
///           ),
///           // Listen to the state from parent
///           Text('Counter1 value: ${viewModel.counter1.state}'),
///         ],
///       );
///     }
///   }
///
///   // Child 2 - Plain StatelessWidget
///   class Counter2View extends StatelessWidget {
///     const Counter2View({Key? key}) : super(key: key);
///
///     @override
///     Widget build(BuildContext context) {
///       return Column(
///         children: [
///           ElevatedButton(
///             child: const Text('🏎️ Counter2 ++'),
///             onPressed: () => viewModel.incrementCounter2(),
///           ),
///           ElevatedButton(
///             child: const Text('⏱️ Undo'),
///             onPressed: () => viewModel.counter2.undoState(),
///           ),
///           Text('Counter2 value: ${viewModel.counter2.state.value}'),
///         ],
///       );
///     }
///   }
/// ```
/// Important Notes:
/// * Child widgets that are load lazily can not register state to the parent
/// [ReactiveStateless]. For example:
///   * The Widgets rendered inside the builder method of [ListView.builder].
///   * Widgets rendered inside [SliverAppBar], [SliverList] and [SliverGrid].
/// * Never use [ReactiveStatelessWidget] above [MaterialApp]. See
/// [TopStatelessWidget]
///
/// [ReactiveStatelessWidget] offers the following hooks:
/// [ReactiveStatelessWidget.didMountWidget],
/// [ReactiveStatelessWidget.didUnmountWidget]
/// [ReactiveStatelessWidget.didAddObserverForDebug]
/// [ReactiveStatelessWidget.shouldRebuildWidget]
///
/// didNotifyWidget
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
  void _addToObs(InjectedBaseState inj) {
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
  }

  @override
  void afterBuild() {
    for (var disposer in _obs1.values) {
      disposer();
      assert(() {
        for (var inj in _obs1.keys) {
          StatesRebuilerLogger.log(
            '${inj.snapState.toStringShort()} is Removed from '
            'ReactiveStateless listeners\n',
          );
        }
        return true;
      }());
    }
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
    for (var disposer in _obs1.values) {
      disposer();
    }
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
