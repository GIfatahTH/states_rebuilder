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
    this.watch,
    @required this.child,
  })  : assert(child != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return StateBuilder<T>(
      models: models,
      onSetState: (context, rm) {
        if (onSetState != null) {
          onSetState(context, rm);
        }

        if (onError != null) {
          for (var reactiveModel in models) {
            print(reactiveModel.snapshot);
            if (reactiveModel.hasError) {
              onError(context, reactiveModel.error);
            }
          }
        }
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
