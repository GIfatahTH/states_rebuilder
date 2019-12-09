import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/states_rebuilder.dart';

class RegisterInjectedModel {
  RegisterInjectedModel(this._injects, this._allRegisteredModelInApp) {
    registerInjectedModels();
  }
  final List<Inject> modelRegisteredByThis = <Inject>[];
  final List<Inject> _injects;
  final Map<String, List<Inject>> _allRegisteredModelInApp;

  void registerInjectedModels() {
    if (_injects == null || _injects.isEmpty) {
      return;
    }

    for (final Inject inject in _injects) {
      final String name = inject.getName();
      final List<Inject<dynamic>> injectedModels =
          _allRegisteredModelInApp[name];
      if (injectedModels == null) {
        _allRegisteredModelInApp[name] = <Inject<dynamic>>[inject];
        modelRegisteredByThis.add(inject);
      } else {
        _allRegisteredModelInApp[name].add(injectedModels.first);
        modelRegisteredByThis.add(injectedModels.first);
      }
    }
  }

  void unRegisterInjectedModels(
    bool disposeModels,
  ) {
    for (final Inject inject in modelRegisteredByThis) {
      final String name = inject.getName();
      final List<Inject<dynamic>> injectedModels =
          _allRegisteredModelInApp[name];

      final bool isRemoved = injectedModels?.remove(inject);
      if (isRemoved && injectedModels.length <= 1) {
        if (disposeModels) {
          try {
            inject.getSingleton()?.dispose();
          } catch (e) {}
        }

        if (inject.isReactiveModel) {
          inject
              .getReactiveSingleton()
              .removeObserver(tag: null, observer: null);
        } else if (inject.isStatesRebuilder) {
          (inject.getSingleton() as StatesRebuilder)
              .removeObserver(tag: null, observer: null);
        }
      }

      if (_allRegisteredModelInApp[name].isEmpty) {
        _allRegisteredModelInApp.remove(name);
      }
    }
  }
}
