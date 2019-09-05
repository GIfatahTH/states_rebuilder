import 'states_rebuilder.dart';

abstract class _IObservable {
  void rebuildStates();

  void addObserver(StatesRebuilder observer, [List tag]);

  void removeObserver(
    StatesRebuilder observer,
  );
}

class Observable implements _IObservable {
  Map<String, void Function()> _observers = {};
  @override
  void addObserver(StatesRebuilder observer, [List tag]) {
    _observers["${observer.runtimeType}"] =
        () => observer.rebuildStates(tag == null || tag.isEmpty ? null : tag);
    observer.cleaner(() {
      _observers.remove("${observer.runtimeType}");
    });
  }

  @override
  void removeObserver(StatesRebuilder observer) {
    _observers.remove("${observer.runtimeType}");
  }

  @override
  void rebuildStates() {
    _observers.values.forEach((fn) {
      if (fn != null) fn();
    });
  }
}
