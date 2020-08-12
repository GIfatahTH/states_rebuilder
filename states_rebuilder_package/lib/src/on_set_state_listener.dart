import 'package:flutter/material.dart';

import 'reactive_model.dart';
import 'reactive_model_imp.dart';
import 'state_builder.dart';
import 'states_rebuilder.dart';
import 'when_connection_state.dart';
import 'when_rebuilder_or.dart';

///One of the four observer widgets in states_rebuilder.
///
///It is useful to handle side effects.
///
///See [StateBuilder], [WhenRebuilder] and [WhenRebuilderOr].
class OnSetStateListener<T> extends StatelessWidget {
  ///List of [ReactiveModel]s to observe
  // final List<ReactiveModel> models;TODO

  ///an observable to which you want [OnSetStateListener] to subscribe to.
  final StatesRebuilder<T> Function() observe;

  ///List of observables to which you want [OnSetStateListener] to subscribe to.
  final List<StatesRebuilder Function()> observeMany;

  ///Callback to execute when any of the observed models emits a notification.
  ///[OnSetStateListener] will not rebuild.
  final void Function(BuildContext context, ReactiveModel reactiveModel) onSetState;

  final void Function(BuildContext, ReactiveModel<T>) onRebuildState;

  ///Callback to execute when any of the observed models emits a notification with error.
  final void Function(BuildContext context, dynamic error) onError;

  ///Callback to called if all the observed [ReactiveModel]s has data.
  final void Function(BuildContext context, ReactiveModel reactiveMode) onData;

  ///Callback to execute when any of the observed models is the waiting state.
  final void Function() onWaiting;

  ///A tag or list of tags you want this [OnSetStateListener] to register with.
  ///
  ///Whenever any of the observable model to which this [OnSetStateListener] is subscribed emits
  ///a notifications with a list of filter tags, this [OnSetStateListener] will rebuild if the
  ///the filter tags list contains at least on of those tags.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  ///
  ///Each [OnSetStateListener] has a default tag which is its [BuildContext]
  final dynamic tag;

  ///A function that returns a one instance variable or a list of
  ///them. The rebuild process will be triggered if at least one of
  ///the return variable changes.
  ///
  ///Return variable must be either a primitive variable, a List, a Map or a Set.
  ///
  ///To use a custom type, you should override the `toString` method to reflect
  ///a unique identity of each instance.
  ///
  ///If it is not defined all listener will be notified when a new state is available.
  final Object Function(ReactiveModel<T> model) watch;

  ///Wether to execute [onSetState], [onWaiting], [onError], and/or [onData] in the [State.initState]
  ///
  ///The default value is false.
  final bool shouldOnInitState;

  ///Child widget to render
  final Widget child;

  ///One of the four observer widgets in states_rebuilder.
  ///
  ///It is useful to handle side effects.
  ///
  ///See [StateBuilder], [WhenRebuilder] and [WhenRebuilderOr].
  const OnSetStateListener({
    Key key,
    this.observe,
    this.observeMany,
    this.onSetState,
    this.onRebuildState,
    this.onError,
    this.onData,
    this.onWaiting,
    this.watch,
    this.tag,
    this.shouldOnInitState = false,
    @required this.child,
  })  : assert(child != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return StateBuilder<T>(
      observe: observe,
      observeMany: observeMany,
      tag: tag,
      onSetState: _onSetState,
      onRebuildState: onRebuildState,
      activeRM: [],
      initState: (context, rm) {
        final _models = (context.widget as StateBuilder).activeRM.cast<ReactiveModelImp>();
        if (onError != null) {
          for (var reactiveModel in _models) {
            reactiveModel.inject.onSetStateListenerNumber++;
          }
        }
        if (shouldOnInitState) {
          _onSetState(context, rm);
        }
      },
      dispose: (context, __) {
        if (onError != null) {
          final _models = (context.widget as StateBuilder).activeRM.cast<ReactiveModel>();
          for (ReactiveModel reactiveModel in _models) {
            (reactiveModel as ReactiveModelImp).inject.onSetStateListenerNumber--;
          }
        }
      },
      watch: watch,
      child: child,
      builderWithChild: (_, __, child) => child,
    );
  }

  void _onSetState(BuildContext context, ReactiveModel<T> rm) {
    if (onSetState != null) {
      onSetState(context, rm);
    }
    final _models = (context.widget as StateBuilder).activeRM.cast<ReactiveModel>();

    bool _isIdle = false;
    bool _isWaiting = false;
    bool _hasError = false;
    dynamic error;

    for (var reactiveModel in _models) {
      if (reactiveModel.isWaiting) {
        _isWaiting = true;
      }
      if (reactiveModel.hasError) {
        _hasError = true;
        error = reactiveModel.error;
      }

      if (reactiveModel.isIdle) {
        _isIdle = true;
      }
    }

    if (_isWaiting) {
      onWaiting?.call();
      return;
    }

    if (_hasError) {
      onError?.call(context, error);
      return;
    }
    if (_isIdle) {
      return;
    }

    onData?.call(context, rm);
  }
}
