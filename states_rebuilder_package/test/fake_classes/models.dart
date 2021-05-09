class VanillaModel {
  VanillaModel([this.counter = 0]);
  int counter = 0;
  int numberOfDisposeCall = 0;
  void increment() {
    counter++;
  }

  void incrementError() {
    throw Exception('Error message');
  }

  Future<int> incrementAsync() async {
    await getFuture();
    counter++;
    return counter;
  }

  Future<VanillaModel> incrementAsyncImmutable() async {
    await getFuture();
    return VanillaModel(counter + 1);
  }

  Future<int> incrementAsyncWithError() async {
    await getFuture();
    throw Exception('Error message');
  }

  Stream<int> incrementStream() async* {
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
  }

  Stream<int> incrementStreamWithError() async* {
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
    await Future.delayed(Duration(seconds: 1));
    yield ++counter;
    await Future.delayed(Duration(seconds: 1));
    yield --counter;
    throw Exception('Error message');
  }

  dispose() {
    numberOfDisposeCall++;
  }

  @override
  String toString() {
    return 'VanillaModel($counter)';
  }
}

Future<int> getFuture() => Future.delayed(Duration(seconds: 1), () => 1);
Stream<int> getStream() {
  return Stream.periodic(Duration(seconds: 1), (num) {
    return num;
  }).take(3);
}

// class StatesRebuilderModel extends StatesRebuilder {
//   int counter = 0;
//   int numberOfDisposeCall = 0;
//   void increment() {
//     counter++;
//   }

//   dispose() {
//     numberOfDisposeCall++;
//   }
// }
