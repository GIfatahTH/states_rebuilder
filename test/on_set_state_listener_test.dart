import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/on_set_state_listener.dart';

int count;
increment() {
  count = DateTime.now().millisecondsSinceEpoch;

  sleep(const Duration(seconds: 1));
  print('1');

  count = DateTime.now().millisecondsSinceEpoch;
  print('2');

  sleep(const Duration(seconds: 1));

  count = DateTime.now().millisecondsSinceEpoch;
  print('3');
}

void main() {
  testWidgets('onSetStateListener works for one reactiveModel', (tester) async {
    String _onSetState = '';
    String _onError = '';
    final widget = Injector(
      inject: [Inject(() => Model1())],
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: OnSetStateListener<Model1>(
              models: [Injector.getAsReactive<Model1>()],
              onSetState: (context, reactiveModel) {
                _onSetState = 'onSetState';
              },
              onError: (context, error) {
                _onError = error.message;
              },
              child: Container()),
        );
      },
    );

    await tester.pumpWidget(widget);

    expect(_onSetState, equals(''));
    expect(_onError, equals(''));

    final reactiveModel1 = Injector.getAsReactive<Model1>();

    reactiveModel1.setState((s) => s.counter++);
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));

    _onSetState = '';
    reactiveModel1.setState((s) => s.incrementAsyncWithError());
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));

    _onSetState = '';
    await tester.pump(Duration(seconds: 1));
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals('error message1'));
  });

  testWidgets('onSetStateListener works for two reactiveModels',
      (tester) async {
    String _onSetState = '';
    String _onError = '';
    final widget = Injector(
      inject: [
        Inject(() => Model1()),
        Inject(() => Model2()),
      ],
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: OnSetStateListener<Model1>(
              models: [
                Injector.getAsReactive<Model1>(),
                Injector.getAsReactive<Model2>(),
              ],
              onSetState: (context, reactiveModel) {
                _onSetState = 'onSetState';
              },
              onError: (context, error) {
                _onError = error.message;
              },
              child: Container()),
        );
      },
    );

    await tester.pumpWidget(widget);

    final reactiveModel1 = Injector.getAsReactive<Model1>();

    expect(_onSetState, equals(''));
    expect(_onError, equals(''));
    reactiveModel1.setState((s) => s.counter++);
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));

    _onSetState = '';
    _onError = '';
    reactiveModel1.setState((s) => s.incrementAsyncWithError());
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));

    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals('error message1'));

    final reactiveModel2 = Injector.getAsReactive<Model2>();
    _onSetState = '';
    _onError = '';
    reactiveModel2.setState((s) => s.counter++);
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals('error message1'));

    _onSetState = '';
    _onError = '';
    reactiveModel1.setState((s) => s.counter++);
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));

    _onSetState = '';
    _onError = '';
    reactiveModel2.setState((s) => s.incrementAsyncWithError());
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));

    await tester.pump(Duration(seconds: 1));
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals('error message2'));
  });
}

class Model1 {
  int counter = 0;
  void incrementAsync() async {
    await Future.delayed(Duration(seconds: 1));
    counter++;
  }

  void incrementAsyncWithError() async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception('error message1');
  }
}

class Model2 {
  int counter = 0;
  void incrementAsync() async {
    await Future.delayed(Duration(seconds: 1));
    counter++;
  }

  void incrementAsyncWithError() async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception('error message2');
  }
}
