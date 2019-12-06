import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Counter1 {}

class Counter2 {
  Counter1 counter;
  Counter2([this.counter]);
}

void main() {
  testWidgets(
    'should getName with dynamic, generic type and custom name',
    (WidgetTester tester) async {
      Inject<dynamic> inject1;
      Inject<dynamic> inject2;
      await tester.pumpWidget(
        Injector(
          inject: [
            inject1 = Inject<Counter2>(() => Counter2()),
            inject2 = Inject<Counter2>(() => Counter2(), name: "Counter3"),
          ],
          builder: (_) => Container(),
        ),
      );
      expect(inject1.getName(), 'Counter2');
      expect(inject2.getName(), 'Counter3');
    },
  );

  testWidgets(
    'should default register lazily',
    (WidgetTester tester) async {
      Inject<dynamic> inject1;
      await tester.pumpWidget(
        Injector(
          inject: [
            inject1 = Inject<Counter1>(() => Counter1()),
          ],
          builder: (_) => Container(),
        ),
      );
      expect(inject1.singleton, null);
    },
  );

  testWidgets(
    'should default register and instantiate if isLazy is false',
    (WidgetTester tester) async {
      Inject<dynamic> inject1;
      await tester.pumpWidget(
        Injector(
          inject: [
            inject1 = Inject<Counter1>(() => Counter1(), isLazy: false),
          ],
          builder: (_) => Container(),
        ),
      );
      expect(inject1.singleton, isA<Counter1>());
    },
  );

  testWidgets(
    'should getSingleton work',
    (WidgetTester tester) async {
      Inject<dynamic> inject1;
      await tester.pumpWidget(
        Injector(
          inject: [
            inject1 = Inject<Counter1>(() => Counter1()),
          ],
          builder: (_) => Container(),
        ),
      );
      expect(inject1.singleton, isNull);
      expect(inject1.getSingleton(), isA<Counter1>());
      expect(inject1.singleton, isA<Counter1>());
      int hashCode1 = inject1.getSingleton().hashCode;
      int hashCode2 = inject1.getSingleton().hashCode;
      expect(hashCode1 == hashCode2, isTrue);
    },
  );

  testWidgets(
    'should getInstance work',
    (WidgetTester tester) async {
      Inject<dynamic> inject1;
      await tester.pumpWidget(
        Injector(
          inject: [
            inject1 = Inject<Counter1>(() => Counter1()),
          ],
          builder: (_) => Container(),
        ),
      );
      expect(inject1.singleton, isNull);
      expect(inject1.getNewInstance(), isA<Counter1>());
      expect(inject1.singleton, isNull);
      int hashCode1 = inject1.getNewInstance().hashCode;
      int hashCode2 = inject1.getNewInstance().hashCode;
      expect(hashCode1 == hashCode2, isFalse);
    },
  );

  testWidgets(
    'should getReactiveSingleton work for Stream a',
    (WidgetTester tester) async {
      Inject<dynamic> injectStream;
      await tester.pumpWidget(
        Injector(
          inject: [
            injectStream = Inject<int>.stream(
                () => Stream.periodic(Duration(seconds: 1), (num) => num)),
          ],
          builder: (_) => Container(),
        ),
      );
      expect(injectStream.reactiveSingleton, isNull);
      expect(injectStream.getReactiveSingleton(),
          isA<StreamStatesRebuilder<int>>());
      expect(injectStream.reactiveSingleton, isA<StreamStatesRebuilder<int>>());
      int hashCode1 = injectStream.getReactiveSingleton().hashCode;
      int hashCode2 = injectStream.getReactiveSingleton().hashCode;
      expect(hashCode1 == hashCode2, isTrue);
    },
  );

  testWidgets(
    'should getReactiveSingleton work for  Future',
    (WidgetTester tester) async {
      Inject<dynamic> injectFuture;
      await tester.pumpWidget(
        Injector(
          inject: [
            injectFuture =
                Inject<int>.future(() => Future.delayed(Duration(seconds: 1))),
          ],
          builder: (_) => Container(),
        ),
      );
      expect(injectFuture.reactiveSingleton, isNull);
      expect(injectFuture.getReactiveSingleton(),
          isA<StreamStatesRebuilder<int>>());
      expect(injectFuture.reactiveSingleton, isA<StreamStatesRebuilder<int>>());
      int hashCode1 = injectFuture.getReactiveSingleton().hashCode;
      int hashCode2 = injectFuture.getReactiveSingleton().hashCode;
      expect(hashCode1 == hashCode2, isTrue);

      await tester.pump(Duration(seconds: 1));
    },
  );

  testWidgets(
    'should getReactiveSingleton work for ReactiveStatesRebuilder',
    (WidgetTester tester) async {
      Inject<dynamic> inject1;
      await tester.pumpWidget(
        Injector(
          inject: [
            inject1 = Inject<Counter1>(() => Counter1()),
          ],
          builder: (_) => Container(),
        ),
      );
      expect(inject1.reactiveSingleton, isNull);
      expect(inject1.getReactiveSingleton(),
          isA<ReactiveStatesRebuilder<Counter1>>());
      expect(
          inject1.reactiveSingleton, isA<ReactiveStatesRebuilder<Counter1>>());
      int hashCode1 = inject1.getReactiveSingleton().hashCode;
      int hashCode2 = inject1.getReactiveSingleton().hashCode;
      expect(hashCode1 == hashCode2, isTrue);
    },
  );

  testWidgets(
    'should getReactiveInstance work, the state remains the same',
    (WidgetTester tester) async {
      Inject<dynamic> inject1;
      await tester.pumpWidget(
        Injector(
          inject: [
            inject1 = Inject<Counter1>(() => Counter1()),
          ],
          builder: (_) => Container(),
        ),
      );
      int hashCode1 = inject1.getReactiveSingleton().hashCode;
      int hashCode2 = inject1.getReactiveNewInstance().hashCode;
      expect(hashCode1 == hashCode2, isFalse);

      hashCode1 = inject1.getReactiveSingleton().state.hashCode;
      hashCode2 = inject1.getReactiveNewInstance().state.hashCode;
      expect(hashCode1 == hashCode2, isTrue);
    },
  );

  testWidgets(
    'should getReactiveInstance work, resetStateStatus case',
    (WidgetTester tester) async {
      Inject<dynamic> inject1;
      await tester.pumpWidget(
        Injector(
          inject: [
            inject1 = Inject<Counter1>(() => Counter1(),
                initialCustomStateStatus: "MyInitialStateStatues"),
          ],
          builder: (_) => Container(),
        ),
      );
      expect(inject1.getReactiveSingleton().customStateStatus,
          "MyInitialStateStatues");

      inject1.getReactiveSingleton().customStateStatus =
          "MyModifiedStateStatus";
      expect(inject1.getReactiveSingleton().customStateStatus,
          "MyModifiedStateStatus");

      expect(inject1.getReactiveNewInstance().customStateStatus,
          "MyInitialStateStatues");
      expect(inject1.getReactiveNewInstance(true).customStateStatus,
          "MyModifiedStateStatus");
    },
  );
}
