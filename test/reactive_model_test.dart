import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

void main() {
  test("get the state and setState for non async works", () {
    final reactiveModel =
        ReactiveStatesRebuilder<MyModel>(Inject(() => MyModel()));
    expect(reactiveModel.state, isA<MyModel>());

    expect(reactiveModel.state.counter, equals(0));
    expect(
        reactiveModel.snapshot.connectionState, equals(ConnectionState.none));
    expect(reactiveModel.connectionState, equals(ConnectionState.none));
    expect(reactiveModel.hasData, isFalse);
    expect(reactiveModel.hasError, isFalse);
    reactiveModel.setState((state) => state.increment());
    expect(reactiveModel.state.counter, equals(1));
    expect(
        reactiveModel.snapshot.connectionState, equals(ConnectionState.done));
    expect(reactiveModel.connectionState, equals(ConnectionState.done));
    expect(reactiveModel.hasData, isTrue);
  });

  test("get the state and setState for future works", () async {
    final reactiveModel = ReactiveStatesRebuilder<MyModelWithFuture>(
        Inject(() => MyModelWithFuture()));
    expect(reactiveModel.state.counter, equals(0));
    expect(
        reactiveModel.snapshot.connectionState, equals(ConnectionState.none));
    reactiveModel.setState((state) => state.increment());
    expect(reactiveModel.snapshot.connectionState,
        equals(ConnectionState.waiting));
    await Future.delayed(Duration(seconds: 1));
    expect(reactiveModel.state.counter, equals(1));
    expect(
        reactiveModel.snapshot.connectionState, equals(ConnectionState.done));

    reactiveModel.setState((state) => state.increment());
    expect(reactiveModel.snapshot.connectionState,
        equals(ConnectionState.waiting));
    await Future.delayed(Duration(seconds: 1));
    expect(reactiveModel.state.counter, equals(2));
    expect(
        reactiveModel.snapshot.connectionState, equals(ConnectionState.done));
  });

  test("get the state and setState with error works", () async {
    final reactiveModel = ReactiveStatesRebuilder<MyModelWithError>(
        Inject(() => MyModelWithError()));
    expect(reactiveModel.state.counter, equals(0));
    expect(
        reactiveModel.snapshot.connectionState, equals(ConnectionState.none));
    reactiveModel.setState((state) => state.increment(), catchError: true);
    expect(reactiveModel.snapshot.connectionState,
        equals(ConnectionState.waiting));
    await Future.delayed(Duration(seconds: 1));
    expect(reactiveModel.snapshot.hasError, equals(true));
    expect(reactiveModel.state.counter, equals(0));
    expect(
        reactiveModel.snapshot.connectionState, equals(ConnectionState.done));
  });

  test(
      "get newReactiveInstance with reference to the reactiveSingletonInstance (wireNewWithSingleton=false)",
      () {
    final myModelSingleton = MyModel();
    final reactiveModel =
        ReactiveStatesRebuilder<MyModel>(Inject(() => myModelSingleton));
    final myModelNewInstance = MyModel();
    final newReactiveInstance = ReactiveStatesRebuilder<MyModel>(
        Inject(() => myModelNewInstance)
          ..newReactiveInstanceList.add(reactiveModel));

    expect(newReactiveInstance.connectionState, ConnectionState.none);
    expect(newReactiveInstance.hasData, isFalse);
    expect(newReactiveInstance.hasError, isFalse);
    newReactiveInstance.setState((state) => state.increment());
    expect(newReactiveInstance.state.counter, equals(1));
    expect(reactiveModel.state.counter, equals(0));
  });

  test(
      "get newReactiveInstance with reference to the reactiveSingletonInstance (wireNewWithSingleton=true)",
      () {
    final myModelSingleton = MyModel();

    final reactiveModel =
        ReactiveStatesRebuilder<MyModel>(Inject(() => myModelSingleton))
          ..addCustomObserver(() => true);
    final newReactiveInstance1 = ReactiveStatesRebuilder<MyModel>(
        Inject(() => myModelSingleton)
          ..newReactiveInstanceList.add(reactiveModel))
      ..addCustomObserver(() => true);
    final newReactiveInstance2 = ReactiveStatesRebuilder<MyModel>(
        Inject(() => myModelSingleton,
            joinSingleton: JoinSingleton.withCombinedReactiveInstances)
          ..newReactiveInstanceList.add(reactiveModel))
      ..addCustomObserver(() => true);
    newReactiveInstance1.setState((state) => state.increment());
    expect(newReactiveInstance1.state.counter, equals(1));
    expect(newReactiveInstance2.state.counter, equals(1));
    expect(reactiveModel.state.counter, equals(1));
  });
}

class MyModel {
  int counter = 0;
  increment() {
    counter++;
  }
}

class MyModelWithFuture {
  int counter = 0;
  increment() async {
    await Future.delayed(Duration(seconds: 1));
    counter++;
  }
}

class MyModelWithError {
  int counter = 0;
  increment() async {
    await Future.delayed(Duration(seconds: 1));
    throw CustomError("This is an Error");
  }
}

class CustomError extends Error {
  final message;
  CustomError(this.message);
}
