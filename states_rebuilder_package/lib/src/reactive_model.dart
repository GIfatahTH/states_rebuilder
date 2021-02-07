import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'legacy/injector.dart';

part 'builders/child.dart';
part 'builders/state_builder.dart';
part 'builders/state_with_mixin_builder.dart';
part 'builders/top_widget.dart';
part 'builders/when_rebuilder.dart';
part 'builders/when_rebuilder_or.dart';
part 'injected/inherited_state.dart';
part 'injected/injected.dart';
part 'injected/injected_auth/i_auth.dart';
part 'injected/injected_auth/injected_auth.dart';
part 'injected/injected_crud/i_crud.dart';
part 'injected/injected_crud/injected_crud.dart';
part 'injected/injected_i18n/injected_i18n.dart';
part 'injected/injected_imp.dart';
part 'injected/injected_persistance/i_persistStore.dart';
part 'injected/injected_persistance/injected_persistance.dart';
part 'injected/injected_persistance/persist_state_mock.dart';
part 'injected/injected_theme/injected_theme.dart';
part 'injected/injected_x.dart';
part 'injected/object_x.dart';
part 'logger.dart';
part 'reactive_model/on.dart';
part 'reactive_model/on_combined.dart';
part 'reactive_model/reactive_model.dart';
part 'reactive_model/reactive_model_builders.dart';
part 'reactive_model/reactive_model_core.dart';
part 'reactive_model/reactive_model_imp.dart';
part 'reactive_model/reactive_model_initializer.dart';
part 'reactive_model/reactive_model_state.dart';
part 'reactive_model/reactive_model_undo_redo_state.dart';
part 'reactive_model/reactive_model_x.dart';
part 'reactive_model/rm.dart';
part 'reactive_model/rm_navigator.dart';
part 'reactive_model/rm_scaffold.dart';
part 'reactive_model/snap_state.dart';
part 'reactive_model/stateful_builder.dart';
part 'states_rebuilder.dart';

T? _getPrimitiveNullState<T>() {
  if (T == int) {
    return 0 as T;
  }
  if (T == double) {
    return 0.0 as T;
  }
  if (T == String) {
    return '' as T;
  }
  if (T == bool) {
    return false as T;
  }
  return null;
}

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
