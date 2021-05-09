part of '../rm.dart';

///{@template dependsOn}
///Setting the [Injected] models dependencies.
///{@endtemplate}
class DependsOn<T> {
  ///Set of [Injected] models to depend on.
  final Set<Injected> injected;

  ///Callback to determine when to notify and recall the creation function
  ///of the **dependent** [Injected] models.
  final bool Function(T? previousState)? shouldNotify;

  ///time in seconds to debounce the recalculation of the state of the
  ///dependent injected model.
  final int debounceDelay;

  ///time in seconds to throttle the recalculation of the state of the
  ///dependent injected model.
  final int throttleDelay;

  ///{@macro dependsOn}
  DependsOn(
    this.injected, {
    this.shouldNotify,
    this.debounceDelay = 0,
    this.throttleDelay = 0,
  });
}
