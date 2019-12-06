library states_rebuilder;

/// 1- states_rebuilder uses the observer pattern.

/// [StatesRebuilder] is the observable
export 'src/states_rebuilder.dart'
    show StatesRebuilder, ObserverOfStatesRebuilder;

/// [StateBuilder] and [StateWithMixinBuilder] are the observers.
export 'src/state_builder.dart' show StateBuilder;
export 'src/state_with_mixin_builder.dart'
    show StateWithMixinBuilder, MixinWith;

/// 2- For dependency injection states_rebuilder uses the service_locator pattern

/// [Injector] register (injected) models in the [State.initState] method and
/// unregister (removed) them in the [State.dispose] methods.
export 'src/injector.dart' show Injector;

/// Models are injected with [Inject] class.
export 'src/inject.dart' show Inject, Injectable, JoinSingleton;

/// [ReactiveModel] adds a reactive environnement to the injected models.
export 'src/reactive_model.dart' show ReactiveModel;
