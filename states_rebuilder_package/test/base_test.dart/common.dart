Stream<int> stream(int num, [dynamic error]) async* {
  for (var i = 0; i < num; i++) {
    await Future.delayed(Duration(seconds: 1));
    if (i + 1 == num) {
      if (error != null) {
        throw error;
      }
    }
    yield i + 1;
  }
}

Future<T> future<T>(T r, [dynamic error]) {
  return Future.delayed(Duration(seconds: 1), () {
    if (error != null) {
      throw error;
    }
    return r;
  });
}
