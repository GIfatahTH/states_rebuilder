import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/inject.dart';
import 'package:states_rebuilder/src/injector.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

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
      var temp;
      expect(() => Inject(() => temp).getName(), throwsAssertionError);
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
        expect(singletonInject is InjectFuture, isTrue);
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
        expect(singletonInject is InjectStream, isTrue);
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
      final ReactiveModel<Model> modelRM0 = inject.getReactive();
      final ReactiveModel<Model> modelRM1 = inject.getReactive(true);
      final ReactiveModel<Model> modelRM2 = inject.getReactive(true);
      //
      expect(modelRM0 != modelRM1, isTrue);
      expect(modelRM0 != modelRM2, isTrue);
      expect(modelRM1 != modelRM2, isTrue);
      //
      expect(modelRM0 is ReactiveModelImp, isTrue);
      expect(modelRM1 is ReactiveModelImpNew, isTrue);
      expect(modelRM2 is ReactiveModelImpNew, isTrue);
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

  test('should throw if Injector.env is null', () {
    expect(
      () => Inject<IInterface>.interface({'prod': () => ImplProd()}),
      throwsAssertionError,
    );
  });

  test(
    'should throw if Injector.env is not a recognize env',
    () {
      Injector.env = 'nonExisting';
      expect(
        () => Inject<IInterface>.interface({'prod': () => ImplProd()}),
        throwsAssertionError,
      );
    },
  );

  test(
    'Inject.interface getName works',
    () {
      Injector.env = 'prod';
      final inject1 = Inject<IInterface>.interface({
        'prod': () => ImplProd(),
        'dev': () => ImplDev(),
        'test': () => ImplTest(),
      });
      //defined generic type
      expect(inject1.getName(), equals('IInterface'));
      //
      //generic type is inferred
      final inject2 = Inject.interface({
        'prod': () => ImplProd(),
        'dev': () => ImplDev(),
        'test': () => ImplTest(),
      });
      expect(inject2.getName(), equals('IInterface'));

      //
      //with provided custom name
      final inject3 = Inject.interface(
        {
          'prod': () => ImplProd(),
          'dev': () => ImplDev(),
          'test': () => ImplTest(),
        },
        name: 'customName',
      );
      expect(inject3.getName(), equals('customName'));

      //
      //throws if Object or dynamic
      final inject4 = Inject.interface({
        'prod': () => ImplProd(),
        'dev': () => ImplDev(),
        'test': () => '',
      });
      expect(() => inject4.getName(), throwsAssertionError);
    },
  );

  test(
    'Inject.interface works default lazily',
    () {
      Injector.env = 'prod';
      final inject1 = Inject<IInterface>.interface({
        'prod': () => ImplProd(),
        'dev': () => ImplDev(),
        'test': () => ImplTest(),
      });
      //defined generic type
      expect(inject1.getName(), equals('IInterface'));

      inject1.getName();
      expect(inject1.singleton, isNull);
      expect(inject1.getSingleton(), isNotNull);
      expect(inject1.getSingleton(), equals(inject1.getSingleton()));
    },
  );

  test(
    'Inject.interface works works not lazily',
    () {
      Injector.env = 'prod';
      final inject1 = Inject<IInterface>.interface(
        {
          'prod': () => ImplProd(),
          'dev': () => ImplDev(),
          'test': () => ImplTest(),
        },
        isLazy: false,
      );
      //defined generic type
      expect(inject1.getName(), equals('IInterface'));

      inject1.getName();
      expect(inject1.singleton, isNotNull);
    },
  );

  test(
    'Inject.interface throws if inconsistent map length',
    () {
      Injector.env = 'prod';
      Inject<IInterface>.interface(
        {
          'prod': () => ImplProd(),
          'dev': () => ImplDev(),
          'test': () => ImplTest(),
        },
        isLazy: false,
      );

      expect(
        () => Inject<IInterface>.interface(
          {
            'prod': () => ImplProd(),
            'dev': () => ImplDev(),
          },
        ),
        throwsAssertionError,
      );
    },
  );

  test(
    'Inject.interface works with futures',
    () {
      Injector.env = 'prod';
      final inject1 = Inject<IInterface>.interface(
        {
          'prod': () async =>
              Future.delayed(Duration(seconds: 1), () => ImplProd()),
          'dev': () => Future.delayed(Duration(seconds: 1), () => ImplDev()),
          'test': () => ImplTest(),
        },
      );
      //defined generic type
      expect(inject1.getName(), equals('IInterface'));

      expect(inject1 is InjectFuture, isTrue);
    },
  );
}

class Model {}

Future<int> getFuture() => Future.delayed(Duration(seconds: 1), () => 1);
Stream<int> getStream() => Stream.periodic(Duration(seconds: 1), (num) => num);

class IInterface {}

class ImplProd extends IInterface {}

class ImplDev extends IInterface {}

class ImplTest extends IInterface {}
