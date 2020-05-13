library states_rebuilder;

import 'package:flutter/widgets.dart';

import 'src/inject.dart';
import 'src/injector.dart';
import 'src/reactive_model.dart';
import 'src/state_builder.dart';
import 'src/state_with_mixin_builder.dart';
import 'src/states_rebuilder.dart';

/// Models are injected with [Inject] class.
export 'src/inject.dart' show Inject, Injectable, JoinSingleton;

/// 2- For dependency injection states_rebuilder uses the service_locator pattern

/// [Injector] register (injected) models in the [State.initState] method and
/// unregister (removed) them in the [State.dispose] methods.
export 'src/injector.dart' show Injector, IN;
export 'src/on_set_state_listener.dart';
export 'src/on_set_state_listener.dart' show OnSetStateListener;

/// [ReactiveModel] adds a reactive environnement to the injected models.
export 'src/reactive_model.dart' show ReactiveModel, RM;
export 'src/rm_key.dart' show RMKey;

/// [StateBuilder] and [StateWithMixinBuilder] are the observers.
export 'src/state_builder.dart' show StateBuilder;
export 'src/state_with_mixin_builder.dart'
    show StateWithMixinBuilder, MixinWith;

/// 1- states_rebuilder uses the observer pattern.

/// [StatesRebuilder] is the observable
export 'src/states_rebuilder.dart'
    show StatesRebuilder, ObserverOfStatesRebuilder;

///Debugging prints
export 'src/states_rebuilder_debug.dart';
export 'src/when_connection_state.dart';
export 'src/when_connection_state.dart' show WhenRebuilder;
export 'src/when_rebuilder_or.dart' show WhenRebuilderOr;
