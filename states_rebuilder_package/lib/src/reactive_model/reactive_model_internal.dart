part of '../reactive_model.dart';

abstract class ReactiveModelInternal<T> extends ReactiveModel<T> {
  ReactiveModelInternal._(Inject<T> inject) : super._(inject);

  ///Error stackTrace
  StackTrace get stackTrace => _stackTrace;

  ///Number of [Injected.futureBuilder] and [Injected.streamBuilder] listening to this RM
  int numberOfFutureAndStreamBuilder = 0;

  ///Wether [setState] is called with a defined onError callback.
  List<bool> get setStateHasOnErrorCallback => _setStateHasOnErrorCallback;

  //Called internally to use isInjectedModel
  Disposer listenToRMInternal(
    void Function(ReactiveModel<T> rm) fn, {
    bool listenToOnDataOnly = true,
    bool isInjectedModel = false,
  }) =>
      _listenToRM(
        fn,
        listenToOnDataOnly: listenToOnDataOnly,
        isInjectedModel: isInjectedModel,
      );
}
