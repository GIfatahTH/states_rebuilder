class Inject<T> {
  final T Function() creationFunction;
  final String _name;
  T _singleton;

  Inject(this.creationFunction, [this._name]);

  String getName() {
    String name;
    if (_name != null) {
      name = _name;
    } else if ('$T' == "dynamic") {
      name = getSingleton().runtimeType.toString();
    } else {
      name = '$T';
    }
    return name.replaceAll(RegExp(r'<.*>'), "");
  }

  T getSingleton() {
    if (_singleton == null) {
      _singleton = creationFunction();
    }
    return _singleton;
  }

  T getInstance() {
    return creationFunction();
  }
}
