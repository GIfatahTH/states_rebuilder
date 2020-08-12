import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/on_set_state_listener.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

void main() {
  test('onSetStateListener throws if child is null', () {
    expect(() => OnSetStateListener(child: null), throwsAssertionError);
  });
  testWidgets('onSetStateListener works for one reactiveModel', (tester) async {
    String _onSetState = '';
    String _onError = '';
    String _onData = '';
    String _onWaiting = '';
    final widget = Injector(
      inject: [Inject(() => Model1())],
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: OnSetStateListener<Model1>(
              observe: () => Injector.getAsReactive<Model1>(),
              tag: 'tag1',
              shouldOnInitState: true,
              onSetState: (context, reactiveModel) {
                _onSetState = 'onSetState';
              },
              onError: (context, error) {
                _onError = error.message;
              },
              onData: (context, reactiveModel) {
                _onData = 'onData';
              },
              onWaiting: () {
                _onWaiting = 'onWaiting';
              },
              child: Container()),
        );
      },
    );

    await tester.pumpWidget(widget);

    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));
    expect(_onData, equals(''));
    expect(_onWaiting, equals(''));

    // final reactiveModel1 = Injector.getAsReactive<Model1>();

    // reactiveModel1.setState((s) => s.counter++);
    // await tester.pump();
    // expect(_onSetState, equals('onSetState'));
    // expect(_onError, equals(''));
    // expect(_onData, equals('onData'));
    // expect(_onWaiting, equals(''));

    // _onSetState = '';
    // _onData = '';
    // reactiveModel1
    //     .setState((s) => s.incrementAsyncWithError(), filterTags: ['tag1']);
    // await tester.pump();
    // expect(_onSetState, equals('onSetState'));
    // expect(_onWaiting, equals('onWaiting'));
    // expect(_onError, equals(''));
    // expect(_onData, equals(''));

    // _onSetState = '';
    // await tester.pump(Duration(seconds: 1));
    // expect(_onSetState, equals('onSetState'));
    // expect(_onError, equals('error message1'));
    // expect(_onData, equals(''));
  });

  testWidgets('onSetStateListener works for two reactiveModels',
      (tester) async {
    String _onSetState = '';
    String _onError = '';
    String _onData = '';
    ReactiveModel exposedRM;
    final widget = Injector(
      inject: [
        Inject(() => Model1()),
        Inject(() => Model2()),
      ],
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: OnSetStateListener(
              observeMany: [
                () => Injector.getAsReactive<Model1>(),
                () => Injector.getAsReactive<Model2>(),
              ],
              onSetState: (context, reactiveModel) {
                _onSetState = 'onSetState';
                exposedRM = reactiveModel;
              },
              onError: (context, error) {
                _onError = error.message;
              },
              onData: (context, reactiveModel) {
                _onData = 'onData';
              },
              child: Container()),
        );
      },
    );

    await tester.pumpWidget(widget);

    final reactiveModel1 = Injector.getAsReactive<Model1>();

    expect(_onSetState, equals(''));
    expect(_onError, equals(''));
    expect(_onData, equals(''));
    //
    reactiveModel1.setState((s) => s.counter++);
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));
    expect(_onData, equals(''));
    expect(exposedRM == reactiveModel1, isTrue);

    _onSetState = '';
    _onError = '';
    _onData = '';
    reactiveModel1.setState((s) => s.incrementAsyncWithError(),
        catchError: true);
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));
    expect(_onData, equals(''));

    await tester.pump(Duration(seconds: 1));
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals('error message1'));
    expect(_onData, equals(''));

    final reactiveModel2 = Injector.getAsReactive<Model2>();
    _onSetState = '';
    _onError = '';
    _onData = '';
    reactiveModel2.setState((s) => s.counter++);
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals('error message1'));
    expect(_onData, equals(''));
    expect(exposedRM == reactiveModel2, isTrue);

    _onSetState = '';
    _onError = '';
    _onData = '';
    reactiveModel1.setState((s) => s.counter++);
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));
    expect(_onData, equals('onData'));

    _onSetState = '';
    _onError = '';
    _onData = '';
    reactiveModel2.setState((s) => s.incrementAsyncWithError());
    await tester.pump();
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals(''));
    expect(_onData, equals(''));

    await tester.pump(Duration(seconds: 1));
    expect(_onSetState, equals('onSetState'));
    expect(_onError, equals('error message2'));
    expect(_onData, equals(''));
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
            observeMany: [
              () => intRM = Injector.getAsReactive<int>(),
              () => stringRM = Injector.getAsReactive<String>(),
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
