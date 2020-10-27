part of '../injected.dart';

abstract class InjectedBaseCommon<T> {
  Inject<T> _inject;
  ReactiveModel<T> _rm;
  T _state;
  T _initialStoredState;
  //used internally so not to call state and _resolveInject (as in toString)
  T _oldState;

  PersistState<T> _persist;

  String _name;

  final Set<Injected> _dependsOn = {};

  //clean models that depend on this
  void Function() _clearDependence;
  int _numberODependence = 0;

  dynamic Function() _cashedMockCreationFunction;
  bool _isRegistered = false;
  bool _persistHasError = false;

  Inject<T> _setAndGetInject(Inject<T> inject) {
    _inject = inject;
    _rm = _inject?.getReactive();
    return _inject;
  }

  T _setAndGetModelState() {
    return _state = _inject?.getSingleton();
  }

  Set<Injected> _setAndGetDependsOn([Set<Injected> dependsOn = const {}]) {
    _dependsOn.clear();
    _dependsOn.addAll(dependsOn);
    return _dependsOn;
  }

  void _addToDependsOn(Injected injected) {
    if (injected._dependsOn.add(this as Injected) == true) {
      assert(
        !_dependsOn.contains(injected),
        '$runtimeType depends on ${Injected._activeInjected.runtimeType} and '
        '${Injected._activeInjected.runtimeType} depends on $runtimeType',
      );
      _nonInjectedModels.remove(_name);
      _numberODependence++;
    }
  }

  void _setClearDependence([void Function() clearDependence]) {
    _clearDependence = clearDependence ??
        (_dependsOn.isEmpty
            ? null
            : () {
                for (var depend in _dependsOn) {
                  depend._numberODependence--;
                  if (depend._rm?.hasObservers != true &&
                      depend._numberODependence < 1) {
                    depend.dispose();
                  }
                }
              });
  }

  void _resetInjected() {
    _rm = null;
    _inject = null;
    _state = null;
    _clearDependence = null;
    _numberODependence = 0;
    _isRegistered = false;
    _dependsOn.clear();
    _initialStoredState = null;
    _persistHasError = false;
    _oldState = null;
    _persist = null;
  }
}

final Map<String, Injected<dynamic>> _functionalInjectedModels =
    <String, Injected<dynamic>>{};

final Map<String, Injected<dynamic>> _nonInjectedModels =
    <String, Injected<dynamic>>{};

void _addToFunctionalInjectedModels(String name, Injected<dynamic> inj) {
  _functionalInjectedModels[name] = inj;
  _nonInjectedModels.remove(name);
}

void _addToNonInjectedModels(String name, Injected<dynamic> inj) {
  _nonInjectedModels[name] = inj;
}

///
Map<String, Injected<dynamic>> get functionalInjectedModels =>
    _functionalInjectedModels;

///Dispose and clean all injected model
void cleanInjector() {
  Map<String, Injected<dynamic>>.from(_functionalInjectedModels).forEach(
    (key, injected) {
      _unregisterFunctionalInjectedModel(injected);
    },
  );
  assert(_functionalInjectedModels.isEmpty);
}

void _unregisterFunctionalInjectedModel(Injected<dynamic> injected) {
  _functionalInjectedModels.remove(injected._name);

  if (injected?._inject == null) {
    return;
  }
  injected._rm?.unsubscribe();
  injected._inject
    ..removeAllReactiveNewInstance()
    ..cleanInject();
  injected._dispose();

  if (_functionalInjectedModels.isEmpty) {
    _nonInjectedModels.forEach((key, inj) {
      if (inj._autoDisposeWhenNotUsed) {
        inj._resetInjected();
      }
    });
    _nonInjectedModels.clear();
  }
}
