part of '../builders.dart';

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

  ///an observable class to which you want [WhenRebuilder] to subscribe.
  ///```dart
  ///WhenRebuilderOr(
  ///  observe:()=> myModel1,
  ///  onWaiting: ()=> ...
  ///  onError: (error)=> ...
  ///  builder: (context, reactiveModel)=> ...
  ///```
  final ReactiveModel<T> Function() observe;

  ///List of observable classes to which you want this [WhenRebuilder] to subscribe.
  ///```dart
  ///WhenRebuilderOR(
  ///  observeMany:[()=> myModel1,()=> myModel2,()=> myModel3],
  ///  onWaiting: ()=> ...
  ///  onError: (error)=> ...
  ///  builder: (context, reactiveModel)=> ...
  ///)
  ///```
  final List<ReactiveModel Function()> observeMany;

  ///A tag or list of tags you want this [WhenRebuilderOr] to register with.
  ///
  ///Whenever any of the observable model to which this [WhenRebuilderOr] is subscribed emits
  ///a notifications with a list of filter tags, this [WhenRebuilderOr] will rebuild if the
  ///the filter tags list contains at least on of those tags.
  ///
  ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  ///
  ///Each [WhenRebuilderOr] has a default tag which is its [BuildContext]
  final dynamic tag;

  /// callback to be executed before notifying listeners. It the returned value is
  /// the same as the last one, the rebuild process is interrupted.
  ///
  final Object Function(ReactiveModel<T> model) watch;

  final bool Function(ReactiveModel<T>) shouldRebuild;

  ///ReactiveModel key used to control this widget from outside its [builder] method.
  final RMKey rmKey;

  ///```dart
  ///WhenRebuilderOr(
  ///  initState:(BuildContext context, ReactiveModel model)=> myModel.init([context,model]),
  ///  observe:()=> myModel1,
  ///  onWaiting: ()=> ...
  ///  onError: (error)=> ...
  ///  builder: (context, reactiveModel)=> ...
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  final void Function(BuildContext, ReactiveModel<T>) initState;

  ///```dart
  ///StateBuilderOr(
  ///  dispose:(BuildContext context, ReactiveModel model) {
  ///     myModel.dispose([context, model]);
  ///   },
  ///  observe:()=> myModel1,
  ///  onWaiting: ()=> ...
  ///  onError: (error)=> ...
  ///  builder: (context, reactiveModel)=> ...
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  final void Function(BuildContext, ReactiveModel<T>) dispose;

  ///Called whenever this widget is notified.
  final dynamic Function(BuildContext context, ReactiveModel<T> model)
      onSetState;

  ///Just like [WhenRebuilder] but you do not have to define all possible states.
  WhenRebuilderOr({
    Key key,
    this.onIdle,
    this.onWaiting,
    this.onError,
    this.onData,
    @required this.builder,
    this.observe,
    this.observeMany,
    this.tag,
    this.watch,
    this.shouldRebuild,
    this.rmKey,
    this.initState,
    this.dispose,
    this.onSetState,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateBuilder<T>(
      key: key,
      observe: observe,
      observeMany: observeMany,
      tag: tag,
      watch: watch,
      shouldRebuild: shouldRebuild ?? (_) => true,
      rmKey: rmKey,
      initState: initState,
      dispose: dispose,
      onSetState: onSetState,
      child: const Text('StatesRebuilder#|1|#'),
      builder: (context, modelRM) {
        bool isIdle = false;
        bool isWaiting = false;
        bool hasError = false;
        bool hasData = false;
        dynamic error;

        final _models = List<ReactiveModel>.from(
          (context.widget as StateBuilder)._activeRM,
        );

        assert(() {
          if (modelRM == null) {
            throw Exception(
              'Failed to cast the generic type $T with any of the provided ReactiveModel '
              'provided in observeMany list'
              'Try to explicitly dentine all generic types in observerMany List',
            );
          }
          return true;
        }());

        _models.first.whenConnectionState<bool>(
          onIdle: () => isIdle = true,
          onWaiting: () => isWaiting = true,
          onError: (dynamic err) {
            error = err;
            return hasError = true;
          },
          onData: (dynamic d) => hasData = true,
          catchError: onError != null,
        );

        for (var i = 1; i < _models.length; i++) {
          _models[i].whenConnectionState(
            onIdle: () => isIdle = true,
            onWaiting: () => isWaiting = true,
            onError: (dynamic err) {
              error = err;
              return hasError = true;
            },
            onData: (dynamic d) => hasData = true,
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
