class Counter {
  Counter({this.id, this.value});
  int id;
  int value;

  @override
  bool operator ==(Object o) {
    return o is Counter && o.id == id && o.value == value;
  }

  @override
  int get hashCode {
    return id.hashCode ^ value.hashCode;
  }
}
