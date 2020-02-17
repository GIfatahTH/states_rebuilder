import 'package:flutter/material.dart';
import 'reactive_model.dart';
import 'state_builder.dart';

class OnSetStateListener<T> extends StatelessWidget {
  ///List of [ReactiveModel]s to observe
  final List<ReactiveModel> models;

  ///Callback to execute when any of the observed models emits a notification.
  ///[OnSetStateListener] will not rebuild.
  final void Function(BuildContext context, ReactiveModel reactiveModel)
      onSetState;

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

  final Widget child;
  const OnSetStateListener({
    Key key,
    this.models,
    this.onSetState,
    this.onError,
    this.onData,
    this.onWaiting,
    this.watch,
    this.tag,
    @required this.child,
  })  : assert(child != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return StateBuilder<T>(
      models: models,
      tag: tag,
      onSetState: (context, rm) {
        if (onSetState != null) {
          onSetState(context, rm);
        }

        bool _isIdle = false;
        bool _isWaiting = false;
        bool _hasError = false;
        dynamic error;

        for (var reactiveModel in models) {
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
      },
      initState: (_, __) {
        if (onError != null) {
          for (var reactiveModel in models) {
            reactiveModel.inject.onSetStateListenerNumber++;
          }
        }
      },
      dispose: (_, __) {
        if (onError != null) {
          for (var reactiveModel in models) {
            reactiveModel.inject.onSetStateListenerNumber--;
          }
        }
      },
      watch: watch,
      child: child,
      builderWithChild: (_, __, child) => child,
    );
  }
}
