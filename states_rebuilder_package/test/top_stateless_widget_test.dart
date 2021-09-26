import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

late Widget Function(BuildContext context) _builder;
late Widget? _onWaiting;
late Widget? Function(dynamic error, void Function() refresh)? _onError;
late List<Future>? _ensureInitialization;
void main() {
  setUp(() {
    _builder = (_) => Container();
    _onWaiting = null;
    _onError = null;
    _ensureInitialization = null;
  });
  testWidgets(
    'throw if waiteFore is defined without onWaiting',
    (tester) async {
      _ensureInitialization = [Future.value(0)];
      await tester.pumpWidget(_TopAppWidget1());
      expect(tester.takeException(), isException);
    },
  );

  testWidgets(
    'provide i18n',
    (tester) async {
      final i18n = RM.injectI18N({
        Locale('en'): () => 'hello',
        Locale('fr'): () => 'salut',
      });
      _builder = (ctx) {
        return MaterialApp(
          locale: i18n.locale,
          home: Builder(
            builder: (context) {
              return Text(
                i18n.of(context),
              );
            },
          ),
        );
      };

      await tester.pumpWidget(_TopAppWidget1());
      expect(find.text('hello'), findsOneWidget);
      i18n.state = 'hello world';
      await tester.pump();
      expect(find.text('hello world'), findsOneWidget);
    },
  );

  testWidgets('provide i18n with async translation', (tester) async {
    final i18n = RM.injectI18N({
      Locale('en'): () => Future.delayed(Duration(seconds: 1), () => 'hello'),
    });

    _builder = (ctx) {
      return MaterialApp(
        locale: i18n.locale,
        home: Builder(
          builder: (context) {
            return Text(
              i18n.of(context),
            );
          },
        ),
      );
    };
    _onWaiting = Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Waiting...'),
    );

    await tester.pumpWidget(_TopAppWidget1());
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets(
      'Throw if i18n is provided with async translation '
      'and without defining onWaiting', (tester) async {
    final i18n = RM.injectI18N({
      Locale('en'): () => Future.delayed(Duration(seconds: 1), () => 'hello'),
    });
    _builder = (ctx) {
      return MaterialApp(
        locale: i18n.locale,
        home: Builder(
          builder: (context) {
            return Text(
              i18n.of(context),
            );
          },
        ),
      );
    };

    await tester.pumpWidget(_TopAppWidget1());
    expect(tester.takeException(), isException);
    await tester.pump(Duration(seconds: 1));
  });

  testWidgets('Top widget waits for provided futures', (tester) async {
    _builder = (ctx) {
      return MaterialApp(
        home: Text('Is Ready'),
      );
    };
    _onWaiting = Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Waiting...'),
    );
    _ensureInitialization = [
      Future.delayed(Duration(seconds: 1)),
      Future.delayed(Duration(seconds: 2)),
    ];

    await tester.pumpWidget(_TopAppWidget1());
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));

    expect(find.text('Is Ready'), findsOneWidget);
  });

  testWidgets('async i18n 1 s with waitFor 2s', (tester) async {
    final i18n = RM.injectI18N({
      Locale('en'): () => Future.delayed(Duration(seconds: 1), () => 'hello'),
    });

    _builder = (ctx) {
      return MaterialApp(
        locale: i18n.locale,
        home: Builder(builder: (context) {
          return Text(i18n.of(context));
        }),
      );
    };
    _onWaiting = Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Waiting...'),
    );
    _ensureInitialization = [
      Future.delayed(Duration(seconds: 2)),
      i18n.stateAsync,
    ];

    await tester.pumpWidget(_TopAppWidget1());
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('async i18n 2 s with waitFor 1s', (tester) async {
    final i18n = RM.injectI18N({
      Locale('en'): () => Future.delayed(Duration(seconds: 2), () => 'hello'),
    });

    _builder = (ctx) {
      return MaterialApp(
        locale: i18n.locale,
        home: Builder(builder: (context) {
          return Text(i18n.of(context));
        }),
      );
    };
    _onWaiting = Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Waiting...'),
    );
    _ensureInitialization = [
      Future.delayed(Duration(seconds: 2)),
      // i18n.stateAsync,
    ];

    await tester.pumpWidget(_TopAppWidget1());

    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('TopAppWidget error', (tester) async {
    bool shouldThrow = true;
    void Function()? refresh;
    final widget = TopAppWidget(
      ensureInitialization: () => [
        Future.delayed(Duration(seconds: 1),
            () => shouldThrow ? throw Exception('Error') : 1),
        Future.delayed(Duration(seconds: 2), () => 2),
      ],
      onWaiting: () => Directionality(
        textDirection: TextDirection.rtl,
        child: Text('Waiting...'),
      ),
      onError: (err, refresher) {
        refresh = refresher;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Text('Error'),
        );
      },
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Text('Data'),
      ),
    );

    await tester.pumpWidget(widget);
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Error'), findsOneWidget);
    shouldThrow = false;
    refresh!();
    await tester.pump();
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Data'), findsOneWidget);
  });
}

class _TopAppWidget1 extends TopStatelessWidget {
  const _TopAppWidget1({Key? key}) : super(key: key);

  @override
  List<Future>? ensureInitialization() {
    return _ensureInitialization;
  }

  @override
  Widget? onWaiting() {
    return _onWaiting;
  }

  @override
  Widget? onError(error, void Function() refresh) {
    return _onError?.call(error, refresh);
  }

  @override
  Widget build(BuildContext context) {
    return _builder(context);
  }
}
