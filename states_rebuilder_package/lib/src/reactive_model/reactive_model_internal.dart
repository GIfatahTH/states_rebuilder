part of '../reactive_model.dart';

abstract class ReactiveModelInt<T> extends ReactiveModel<T> {
  ReactiveModelInt._(Inject<T> inject) : super._(inject);

  ///Error stackTrace
  StackTrace get stackTrace => _stackTrace;

  ///Number of [Injected.futureBuilder] and [Injected.streamBuilder] listening to this RM
  int numberOfFutureAndStreamBuilder = 0;

  ///Wether [setState] is called with a defined onError callback.
  bool get setStateHasOnErrorCallback => _setStateHasOnErrorCallback;
}
