import 'package:states_rebuilder/src/inject.dart';

class RegisterInjectedModel {
  List<Inject> _modelRegisteredByThis = [];
  final List<Inject> _models;
  final Map<String, List<Inject>> _allRegisteredModelInApp;

  RegisterInjectedModel(this._models, this._allRegisteredModelInApp) {
    registerInjectedModels();
  }

  registerInjectedModels() {
    if (_models == null || _models.isEmpty) return;
    _models.forEach(
      (model) {
        _modelRegisteredByThis.add(model);
        if (_allRegisteredModelInApp[model.getName()] == null) {
          _allRegisteredModelInApp[model.getName()] = [model];
        } else {
          _allRegisteredModelInApp[model.getName()].add(model);
        }
      },
    );
  }

  unRegisterInjectedModels(
    bool disposeModels,
  ) {
    if (disposeModels) {
      _modelRegisteredByThis.forEach((model) {
        try {
          model.getSingleton()?.dispose();
        } catch (e) {}
      });
    }

    _modelRegisteredByThis.forEach((model) {
      final name = model.getName();

      bool isRemoved = _allRegisteredModelInApp[name]?.remove(model);
      if (isRemoved) {
        if (model.isAsyncType) {
          model.getModelSingleton().removeObserver(tag: null, observer: null);
        } else if (model.isStatesRebuilder) {
          model.getSingleton().removeObserver(tag: null);
        }
      }

      if (_allRegisteredModelInApp[name].isEmpty) {
        _allRegisteredModelInApp.remove(name);
      }
    });
  }
}
