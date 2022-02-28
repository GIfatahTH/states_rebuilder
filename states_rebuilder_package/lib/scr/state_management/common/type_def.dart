part of '../rm.dart';

/// Signature of callbacks that have no arguments and return no data.
typedef AsyncVoidCallback = Future<void> Function();

typedef ObserveReactiveModel = void Function(ReactiveModelImp);
typedef ObserveTopWidget = void Function(
  ReactiveModelImp,
  bool Function(BuildContext) onObserverAdded,
  void Function(List<Locale>? locales)? didChangeLocales,
);
typedef StateInterceptor<T> = SnapState<T>? Function(
    SnapState<T> currentSnap, SnapState<T> nextSnap);

typedef ShouldRebuild = bool Function(SnapState<dynamic>, SnapState<dynamic>);
typedef OnError = Widget Function(dynamic error, void Function() refreshError);
typedef OnWaiting = Widget Function();
typedef OnIdle = Widget Function();
typedef OnData<T> = Widget Function(T data);
