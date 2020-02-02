import 'package:flutter/material.dart';
import 'reactive_model.dart';
import 'state_builder.dart';

class WhenRebuilder<T> extends StatelessWidget {
  ///Widget to display when the widget is first rendered and before executing any method.
  ///
  ///It has the third priority after [onWaiting] and [onError]. That is, if none of the observed [ReactiveModel]s
  ///is on the waiting nor on the error state, and if at least one of them is in the idle state this callback will
  ///be invoked.
  final Widget Function() onIdle;

  ///Widget to display when the at least on of the observed [ReactiveModel]s is in the waiting state.
  ///
  ///It has the first priority.That is, if at least one of the observed [ReactiveModel]s is in the waiting state
  /// this callback will be invoked no matter the other states are.
  final Widget Function() onWaiting;

  ///Widget to display when the at least on of the observed [ReactiveModel]s has an error.
  ///
  ///It has the second priority after [onWaiting]. That is none of the observed model is in the waiting state,
  ///and if at least one of the observed [ReactiveModel]s has error this callback will be invoked.
  final Widget Function(dynamic error) onError;

  ///Widget to display if all the observed [ReactiveModel]s has data.
  ///
  ///It has the last priority. That is if all the observed [ReactiveModel]s are not in the waiting state,
  ///have no error, and are not in the idle state, this callback will be invoked.
  final Widget Function(T data) onData;

  //List of reactiveModels to observe
  final List<ReactiveModel> models;

  final void Function(BuildContext, ReactiveModel<T>) initState;
  final void Function(BuildContext, ReactiveModel<T>) dispose;
  const WhenRebuilder({
    Key key,
    this.onIdle,
    @required this.onWaiting,
    @required this.onError,
    @required this.onData,
    @required this.models,
    this.initState,
    this.dispose,
  })  : assert(models != null && models.length != 0),
        assert(onWaiting != null),
        assert(onError != null),
        assert(onData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateBuilder<T>(
      models: models,
      initState: initState,
      dispose: dispose,
      builder: (context, firstReactiveModel) {
        bool isIdle = false;
        bool isWaiting = false;
        bool hasError = false;
        dynamic error;

        firstReactiveModel.whenConnectionState<bool>(
          onIdle: () => isIdle = true,
          onWaiting: () => isWaiting = true,
          onError: (err) {
            error = err;
            return hasError = true;
          },
          onData: (data) => true,
        );

        for (var i = 1; i < models.length; i++) {
          models[i].whenConnectionState(
            onIdle: () => isIdle = true,
            onWaiting: () => isWaiting = true,
            onError: (err) {
              error = err;
              return hasError = true;
            },
            onData: (data) => true,
          );
        }

        if (isWaiting) {
          return onWaiting();
        }
        if (hasError) {
          return onError(error);
        }

        if (isIdle) {
          if (onIdle != null) {
            return onIdle();
          }
          return Center(
            child: Text(' OnIdle Not Implemented Error '),
          );
        }

        return onData(firstReactiveModel.state);
      },
    );
  }
}
