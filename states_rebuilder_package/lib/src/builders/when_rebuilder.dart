part of '../reactive_model.dart';

///a combination of [StateBuilder] widget and [ReactiveModel.whenConnectionState] method.
///It Exhaustively switch over all the possible statuses of [ReactiveModel.connectionState]
class WhenRebuilder<T> extends StatefulWidget {
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

  ///List of observable classes to which you want this [WhenRebuilder] to subscribe.
  ///```dart
  ///WhenRebuilder(
  ///  models:[myModel1, myModel2, myModel3],
  ///  onIdle: ()=> ...
  ///  onWaiting: ()=> ...
  ///  onError: (error)=> ...
  ///  onData: (data)=> ...
  ///)
  ///```
  ///
  ///For the sake of performance consider using [observe] or [observeMany] instead.

  ///an observable class to which you want [WhenRebuilder] to subscribe.
  ///```dart
  ///WhenRebuilder(
  ///  observe:()=> myModel1,
  ///  onIdle: ()=> ...
  ///  onWaiting: ()=> ...
  ///  onError: (error)=> ...
  ///  onData: (data)=> ...
  ///)
  ///```
  final ReactiveModel<T> Function()? observe;

  ///List of observable classes to which you want this [WhenRebuilder] to subscribe.
  ///```dart
  ///WhenRebuilder(
  ///  observeMany:[()=> myModel1,()=> myModel2,()=> myModel3],
  ///  onIdle: ()=> ...
  ///  onWaiting: ()=> ...
  ///  onError: (error)=> ...
  ///  onData: (data)=> ...
  ///)
  ///```
  final List<ReactiveModel Function()>? observeMany;

  // ///A tag or list of tags you want this [WhenRebuilder] to register with.
  // ///
  // ///Whenever any of the observable model to which this [WhenRebuilder] is subscribed emits
  // ///a notifications with a list of filter tags, this [WhenRebuilder] will rebuild if the
  // ///the filter tags list contains at least on of those tags.
  // ///
  // ///It can be String (for small projects) or enum member (enums are preferred for big projects).
  // ///
  // ///Each [WhenRebuilder] has a default tag which is its [BuildContext]
  // final dynamic tag;

  final bool Function(ReactiveModel<T>)? shouldRebuild;

  ///```dart
  ///WhenRebuilder(
  ///  initState:(BuildContext context, ReactiveModel model)=> myModel.init([context,model]),
  ///  observe:()=> myModel1,
  ///  onIdle: ()=> ...
  ///  onWaiting: ()=> ...
  ///  onError: (error)=> ...
  ///  onData: (data)=> ...
  ///)
  ///```
  ///Called when this object is inserted into the tree.
  final void Function(BuildContext, ReactiveModel<T>)? initState;

  ///```dart
  ///StateBuilder(
  ///  dispose:(BuildContext context, ReactiveModel model) {
  ///     myModel.dispose([context, model]);
  ///   },
  ///  observe:()=> myModel1,
  ///  onIdle: ()=> ...
  ///  onWaiting: ()=> ...
  ///  onError: (error)=> ...
  ///  onData: (data)=> ...
  ///)
  ///```
  ///Called when this object is removed from the tree permanently.
  final void Function(BuildContext, ReactiveModel<T>)? dispose;

  ///Called whenever this widget is notified.
  final dynamic Function(BuildContext context, ReactiveModel<T> model)?
      onSetState;

  ///Called whenever the widget configuration changes.
  final void Function(BuildContext, ReactiveModel<T>, WhenRebuilder<T>)?
      didUpdateWidget;

  ///a combination of [StateBuilder] widget and [ReactiveModel.whenConnectionState] method.
  ///It Exhaustively switch over all the possible statuses of [ReactiveModel.connectionState]
  WhenRebuilder({
    Key? key,
    required this.onIdle,
    required this.onWaiting,
    required this.onError,
    required this.onData,
    this.observe,
    this.observeMany,
    this.shouldRebuild,
    this.initState,
    this.dispose,
    this.onSetState,
    this.didUpdateWidget,
  }) : super(key: key);

  @override
  _WhenRebuilderState<T> createState() => _WhenRebuilderState<T>();
}

class _WhenRebuilderState<T> extends State<WhenRebuilder<T>> {
  final List<ReactiveModel> _models = [];
  late ReactiveModel<T> rm;

  late Widget _widget;
  @override
  void initState() {
    super.initState();
    if (widget.observe != null) {
      _models.add(widget.observe!());
    }
    if (widget.observeMany != null) {
      _models.addAll(widget.observeMany!.map((e) => e()));
    }
    if (_models.isEmpty) {
      throw ArgumentError('You have to observe a model by defining '
          'either observe or observeMany parameters');
    }

    //setting the exposed rm
    if (widget.observe != null) {
      //1- rm is the model of the observer
      rm = _models.first as ReactiveModel<T>;
    } else if (widget.observeMany != null && widget.observeMany!.isNotEmpty) {
      if (T != dynamic && T != Object) {
        //Ensure T is not dynamic or Object
        //2- RM is the first model of observeMany that is of type T
        final r = _models.firstWhereOrNull((e) => e is ReactiveModel<T>);
        rm = r as ReactiveModel<T>;
      } else {
        //3- take the first model of observeMany
        rm = _models.first as ReactiveModel<T>;
        _models.forEach((m) {
          m.subscribeToRM((r) {
            //4- the model is that is emitting a notification
            rm = r as ReactiveModel<T>;
          });
        });
      }
    }

    _widget = OnCombined.all(
      onIdle: widget.onIdle,
      onWaiting: widget.onWaiting,
      onError: (err, _) => widget.onError(err),
      onData: widget.onData,
    ).listenTo<T>(
      _models,
      onSetState: OnCombined((_) => widget.onSetState?.call(context, rm)),
      shouldRebuild: () => widget.shouldRebuild?.call(rm) ?? true,
      initState: () => widget.initState?.call(context, rm),
      dispose: () => widget.dispose?.call(context, rm),
    );
  }

  @override
  void didUpdateWidget(covariant WhenRebuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.didUpdateWidget?.call(context, rm, oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _widget;
  }
}
