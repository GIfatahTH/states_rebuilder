import 'package:flutter/material.dart';
import '../states_rebuilder.dart';
import 'reactive_model.dart';
import 'state_builder.dart';
import 'when_connection_state.dart';

///Just like [WhenRebuilder] but you do not have to define all possible states.
class WhenRebuilderOr<T> extends StatelessWidget {
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

  ///Widget to display if all the observed [ReactiveModel]s has data or as the default case if any
  ///of the [onIdle], [onWaiting] or [onError] is not defined
  ///
  ///It has the last priority. That is if all the observed [ReactiveModel]s are not in the waiting state,
  ///have no error, and are not in the idle state, this callback will be invoked.
  ///
  final Widget Function(BuildContext context, ReactiveModel<T> model) builder;

  //List of reactiveModels to observe
  final List<ReactiveModel> models;
  final StatesRebuilder Function() observe;
  final List<StatesRebuilder Function()> observeMany;

  ///A tag or list of tags you want this [WhenRebuilderOR] to register with.
  ///
  ///Whenever any of the observable model to which this [WhenRebuilderOR] is subscribed emits
  ///a notifications with a list of filter tags, this [WhenRebuilderOR] will rebuild if the
  ///the filter tags list contains at least on of those tags.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  ///
  ///Each [WhenRebuilderOR] has a default tag which is its [BuildContext]
  final dynamic tag;

  final void Function(BuildContext, ReactiveModel<T>) initState;
  final void Function(BuildContext, ReactiveModel<T>) dispose;
  final void Function(BuildContext, ReactiveModel<T>) onSetState;

  const WhenRebuilderOr({
    Key key,
    this.onIdle,
    this.onWaiting,
    this.onError,
    this.onData,
    @required this.builder,
    this.models,
    this.observe,
    this.observeMany,
    this.tag,
    this.initState,
    this.dispose,
    this.onSetState,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateBuilder<T>(
      models: models,
      observe: observe,
      observeMany: observeMany,
      tag: tag,
      initState: initState,
      dispose: dispose,
      onSetState: onSetState,
      builder: (context, modelRM) {
        bool isIdle = false;
        bool isWaiting = false;
        bool hasError = false;
        bool hasData = false;
        dynamic error;

        final _models =
            (context.widget as StateBuilder).activeRM.cast<ReactiveModel>();
        _models.first.whenConnectionState<bool>(
          onIdle: () => isIdle = true,
          onWaiting: () => isWaiting = true,
          onError: (err) {
            error = err;
            return hasError = true;
          },
          onData: (d) => hasData = true,
          catchError: onError != null,
        );

        for (var i = 1; i < _models.length; i++) {
          _models[i].whenConnectionState(
            onIdle: () => isIdle = true,
            onWaiting: () => isWaiting = true,
            onError: (err) {
              error = err;
              return hasError = true;
            },
            onData: (d) => hasData = true,
            catchError: onError != null,
          );
        }

        if (onWaiting != null && isWaiting) {
          return onWaiting();
        }
        if (hasError && onError != null) {
          return onError(error);
        }

        if (onIdle != null && isIdle) {
          return onIdle();
        }

        if (onData != null && hasData) {
          return onData(modelRM.state);
        }
        return builder(context, modelRM);
      },
    );
  }
}
