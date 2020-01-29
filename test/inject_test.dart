import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';

void main() {
  test(
    'Inject getName works',
    () {
      //defined generic type
      expect(Inject<Model>(() => Model()).getName(), equals('Model'));
      //generic type is inferred
      expect(Inject(() => Model()).getName(), equals('Model'));
      //with provided custom name
      expect(Inject(() => Model(), name: 'customName').getName(),
          equals('customName'));
      //throws for dynamic type
      var dynamic;
      expect(() => Inject(() => dynamic).getName(), throwsAssertionError);
    },
  );

  test(
    'Inject getSingleton works default lazily',
    () {
      final singletonInject = Inject(() => Model());
      singletonInject.getName();
      expect(singletonInject.singleton, isNull);
      expect(singletonInject.getSingleton(), isNotNull);
      expect(singletonInject.getSingleton(),
          equals(singletonInject.getSingleton()));
    },
  );

  test(
    'Inject getSingleton works not lazily',
    () {
      final singletonInject = Inject(() => Model(), isLazy: false);
      singletonInject.getName();
      expect(singletonInject.singleton, isNotNull);
    },
  );

  group('Inject.future :', () {
    test(
      ' get name work when injecting future',
      () {
        //defined generic type
        expect(Inject<int>.future(() => getFuture()).getName(), equals('int'));
        //generic type is inferred
        expect(Inject.future(() => getFuture()).getName(), equals('int'));
        //with provided custom name
        expect(Inject.future(() => getFuture(), name: 'customName').getName(),
            equals('customName'));
        //throws for dynamic type
        var dynamic;
        expect(
            () => Inject.future(() => dynamic).getName(), throwsAssertionError);
      },
    );

    test(
      ' getSingleton  do not throw if use with injected future',
      () {
        final singletonInject = Inject.future(() => getFuture());
        singletonInject.getName();
        expect(singletonInject.singleton, isNull);
        expect(singletonInject.isAsyncInjected, isTrue);
        singletonInject.getSingleton();
      },
    );
  });

  group('Inject.stream :', () {
    test(
      ' get name work when injecting stream',
      () {
        //defined generic type
        expect(Inject<int>.stream(() => getStream()).getName(), equals('int'));
        //generic type is inferred
        expect(Inject.stream(() => getStream()).getName(), equals('int'));
        //with provided custom name
        expect(Inject.stream(() => getStream(), name: 'customName').getName(),
            equals('customName'));
        //throws for dynamic type
        var dynamic;
        expect(
            () => Inject.stream(() => dynamic).getName(), throwsAssertionError);
      },
    );

    test(
      ' getSingleton do not throw if use with injected future',
      () {
        final singletonInject = Inject.stream(() => getStream());
        singletonInject.getName();
        expect(singletonInject.singleton, isNull);
        expect(singletonInject.isAsyncInjected, isTrue);
        singletonInject.getSingleton();
      },
    );
  });

  //
  //ReactiveModel

  test(
    'Inject getReactiveSingleton works default lazily',
    () {
      final singletonInject = Inject(() => Model());
      singletonInject.getName();
      expect(singletonInject.reactiveSingleton, isNull);
      expect(singletonInject.getReactive(), isNotNull);
      expect(
          singletonInject.getReactive(), equals(singletonInject.getReactive()));
    },
  );

  test(
    'Inject getReactiveSingleton works not lazily',
    () {
      final singletonInject = Inject(() => Model(), isLazy: false);
      singletonInject.getName();
      expect(singletonInject.reactiveSingleton, isNotNull);
      expect(singletonInject.reactiveSingleton,
          equals(singletonInject.getReactive()));
    },
  );

  test(
    'Inject : getReactiveSingleton works Future lazily',
    () {
      final singletonInject = Inject.future(() => getFuture());
      singletonInject.getName();
      expect(singletonInject.reactiveSingleton, isNull);
      expect(singletonInject.getReactive(), isNotNull);
      expect(
          singletonInject.getReactive(), equals(singletonInject.getReactive()));
    },
  );
  test(
    'Inject : getReactiveSingleton works Future not lazily',
    () {
      final singletonInject = Inject.future(() => getFuture(), isLazy: false);
      singletonInject.getName();
      expect(singletonInject.reactiveSingleton, isNotNull);
      expect(singletonInject.reactiveSingleton,
          equals(singletonInject.getReactive()));
    },
  );

  test(
    'Inject : getReactiveSingleton works Stream lazily',
    () {
      final singletonInject = Inject.stream(() => getStream());
      singletonInject.getName();
      expect(singletonInject.reactiveSingleton, isNull);
      expect(singletonInject.getReactive(), isNotNull);
      expect(
          singletonInject.getReactive(), equals(singletonInject.getReactive()));
    },
  );
  test(
    'Inject : getReactiveSingleton works Stream not lazily',
    () {
      final singletonInject = Inject.stream(() => getStream(), isLazy: false);
      singletonInject.getName();
      expect(singletonInject.reactiveSingleton, isNotNull);
      expect(singletonInject.reactiveSingleton,
          equals(singletonInject.getReactive()));
    },
  );

  test(
    'Inject : get new reactive instance',
    () {
      final inject = Inject(() => Model());
      final modelRM0 = inject.getReactive();
      final modelRM1 = inject.getReactive(true);
      final modelRM2 = inject.getReactive(true);
      //
      expect(modelRM0 != modelRM1, isTrue);
      expect(modelRM0 != modelRM2, isTrue);
      expect(modelRM1 != modelRM2, isTrue);
      //
      expect(modelRM0.isNewReactiveInstance, isFalse);
      expect(modelRM1.isNewReactiveInstance, isTrue);
      expect(modelRM2.isNewReactiveInstance, isTrue);
      //
      expect(inject.newReactiveInstanceList.length, equals(2));
      //
      inject.removeFromReactiveNewInstanceList(modelRM0);
      expect(inject.newReactiveInstanceList.length, equals(2));
      inject.removeFromReactiveNewInstanceList(modelRM1);
      expect(inject.newReactiveInstanceList.length, equals(1));
      inject.removeFromReactiveNewInstanceList(modelRM2);
      expect(inject.newReactiveInstanceList.length, equals(0));
    },
  );

  test(
    'Inject : clear all new reactive instances',
    () {
      final inject = Inject(() => Model());
      inject.getReactive();
      inject.getReactive(true);
      inject.getReactive(true);
      //
      expect(inject.newReactiveInstanceList.length, equals(2));
      //
      inject.removeAllReactiveNewInstance();
      expect(inject.newReactiveInstanceList.length, equals(0));
    },
  );
}

class Model {}

Future<int> getFuture() => Future.delayed(Duration(seconds: 1), () => 1);
Stream<int> getStream() => Stream.periodic(Duration(seconds: 1), (num) => num);
