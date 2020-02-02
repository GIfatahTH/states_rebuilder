import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/on_set_state_listener.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

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

  testWidgets('onSetStateListener works for two Future reactiveModels',
      (tester) async {
    String _onSetState = '';
    ReactiveModel intRM;
    ReactiveModel stringRM;
    final widget = Injector(
      inject: [
        Inject.future(() => Future.delayed(Duration(seconds: 1), () => 10)),
        Inject.future(() => Future.delayed(Duration(seconds: 2), () => '10')),
      ],
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: OnSetStateListener(
            models: [
              intRM = Injector.getAsReactive<int>(),
              stringRM = Injector.getAsReactive<String>(),
            ],
            onSetState: (context, _) {
              _onSetState = 'onSetState';
            },
            onError: (context, error) {},
            child: Container(),
          ),
        );
      },
    );

    await tester.pumpWidget(widget);

    expect(_onSetState, equals(''));
    expect(intRM.isWaiting, isTrue);
    expect(stringRM.isWaiting, isTrue);

    await tester.pump(Duration(seconds: 1));
    expect(_onSetState, equals('onSetState'));
    expect(intRM.hasData, isTrue);
    expect(stringRM.isWaiting, isTrue);

    _onSetState = '';
    await tester.pump(Duration(seconds: 2));
    expect(_onSetState, equals('onSetState'));
    expect(intRM.hasData, isTrue);
    expect(stringRM.hasData, isTrue);
  });
}

class Model1 {
  int counter = 0;
  Future incrementAsync() async {
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
  Future incrementAsync() async {
    await Future.delayed(Duration(seconds: 2));
    counter++;
  }

  void incrementAsyncWithError() async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception('error message2');
  }
}
