import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/model_states_rebuilder.dart';

void main() {
  test("get the state and setState for non future works", () {
    final model = ValueStatesRebuilder<MyModel>(MyModel());
    expect(model.state.counter, equals(0));
    expect(model.snapshot.connectionState, equals(ConnectionState.none));
    expect(model.connectionState, equals(ConnectionState.none));
    model.setState((state) => state.increment());
    expect(model.state.counter, equals(1));
    expect(model.snapshot.connectionState, equals(ConnectionState.done));
    expect(model.connectionState, equals(ConnectionState.done));
  });

  test("get the state and setState for future works", () async {
    final model = ValueStatesRebuilder<MyModelWithFuture>(MyModelWithFuture());
    expect(model.state.counter, equals(0));
    expect(model.snapshot.connectionState, equals(ConnectionState.none));
    model.setState((state) => state.increment());
    expect(model.snapshot.connectionState, equals(ConnectionState.waiting));
    await Future.delayed(Duration(seconds: 1));
    expect(model.state.counter, equals(1));
    expect(model.snapshot.connectionState, equals(ConnectionState.done));

    model.setState((state) => state.increment());
    expect(model.snapshot.connectionState, equals(ConnectionState.waiting));
    await Future.delayed(Duration(seconds: 1));
    expect(model.state.counter, equals(2));
    expect(model.snapshot.connectionState, equals(ConnectionState.done));
  });

  test("get the state and setState with error works", () async {
    final model = ValueStatesRebuilder<MyModelWithError>(MyModelWithError());
    expect(model.state.counter, equals(0));
    expect(model.snapshot.connectionState, equals(ConnectionState.none));
    model.setState((state) => state.increment(), catchError: true);
    expect(model.snapshot.connectionState, equals(ConnectionState.waiting));
    await Future.delayed(Duration(seconds: 1));
    expect(model.snapshot.hasError, equals(true));
    expect(model.state.counter, equals(0));
    expect(model.snapshot.connectionState, equals(ConnectionState.done));
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
