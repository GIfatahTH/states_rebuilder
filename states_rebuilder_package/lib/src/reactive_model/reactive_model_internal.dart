part of '../reactive_model.dart';

///ReactiveModel used internally
abstract class ReactiveModelInternal<T> extends ReactiveModel<T> {
  ReactiveModelInternal._(Inject<T> inject) : super._(inject) {
    cleaner(() {
      activeRM = null;
    });
  }

  ///Error stackTrace
  StackTrace get stackTrace => _stackTrace;

  ///Number of [Injected.futureBuilder] and [Injected.streamBuilder] and [Injected.inherited] listening to this RM
  int numberOfFutureAndStreamBuilder = 0;

  ///Wether [setState] is called with a defined onError callback.
  List<bool> get setStateHasOnErrorCallback => _setStateHasOnErrorCallback;

  ///Called internally to use isInjectedModel
  Disposer listenToRMInternal(
    void Function(ReactiveModel<T> rm) fn, {
    bool listenToOnDataOnly = true,
    bool isInjectedModel = false,
    String debugListener,
  }) =>
      _listenToRM(
        fn,
        listenToOnDataOnly: listenToOnDataOnly,
        isInjectedModel: isInjectedModel,
        debugListener: debugListener,
      );

  ///set on exposing a reactive model in a widget listener
  ///It holds all reactive models the widget listen to.
  ///Used in WhenRebuilder, WhenRebuilderOr and didUpdateWidget of
  ///StateRebuilderListX.
  List<ReactiveModel<dynamic>> activeRM;

  final List<Injected<dynamic>> inheritedInjected = [];
}
