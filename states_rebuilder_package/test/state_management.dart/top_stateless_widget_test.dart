import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/scr/state_management/rm.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

late Widget Function(BuildContext context) _builder;
late Widget? _onWaiting;
late Widget? Function(dynamic error, void Function() refresh)? _onError;
late List<Future> Function()? _ensureInitialization;
late void Function(AppLifecycleState state)? _didChangeAppLifecycleState;

void main() {
  setUp(() {
    _builder = (_) => Container();
    _onWaiting = null;
    _onError = null;
    _ensureInitialization = null;
    _didChangeAppLifecycleState = null;
  });
  testWidgets(
    'throw if waiteFore is defined without onWaiting',
    (tester) async {
      _ensureInitialization = () => [Future.value(0)];
      await tester.pumpWidget(const _TopAppWidget1());
      expect(tester.takeException(), isException);
    },
  );

  testWidgets(
    'provide i18n',
    (tester) async {
      // final i18n = RM.injectI18N({
      //   const Locale('en'): () => 'hello',
      //   const Locale('fr'): () => 'salut',
      // });

      final i18n =
          CustomInjected<bool>(creator: () => true, useInheritedWidget: true);
      _builder = (ctx) {
        i18n.state;
        return MaterialApp(
          home: Builder(
            builder: (context) {
              return Text(
                i18n.of(context).toString(),
              );
            },
          ),
        );
      };

      await tester.pumpWidget(const _TopAppWidget1());
      expect(find.text('true'), findsOneWidget);
      i18n.toggle();
      await tester.pump();
      expect(find.text('false'), findsOneWidget);
    },
  );

  // testWidgets(//TODO
  //   'WHEN trying to get the app language using of(context)'
  //   'in the builder of TopReactiveStateless'
  //   'Then throw an exception hinting to use Builder',
  //   (tester) async {
  //     // final i18n = RM.injectI18N({
  //     //   const Locale('en'): () => 'hello',
  //     //   const Locale('fr'): () => 'salut',
  //     // });
  //     final i18n =
  //         CustomInjected(creator: () => true, useInheritedWidget: true);
  //     _builder = (ctx) {
  //       i18n.state;
  //       return MaterialApp(
  //         // locale: i18n.locale,
  //         home: Text(
  //           i18n.of(ctx).toString(),
  //         ),
  //       );
  //     };

  //     await tester.pumpWidget(const _TopAppWidget1());
  //     expect(
  //         tester.takeException(), contains('use a Builder to get a context'));
  //   },
  // );

  // testWidgets(
  //   'WHEN trying to get the app language using of(context)'
  //   'without using TopReactiveStateless widget'
  //   'Then throw an exception hinting to use TopReactiveStateless',
  //   (tester) async {
  //     final i18n = RM.injectI18N({
  //       const Locale('en'): () => 'hello',
  //       const Locale('fr'): () => 'salut',
  //     });
  //     final widget = Builder(
  //       // injectedI18N: i18n,
  //       builder: (ctx) {
  //         return Directionality(
  //           textDirection: TextDirection.ltr,
  //           child: Text(i18n.of(ctx)),
  //         );
  //       },
  //     );
  //     await tester.pumpWidget(widget);
  //     expect(tester.takeException(),
  //         contains('Make sure to use [TopReactiveStateless] '));
  //   },
  // );

  testWidgets('provide i18n with async translation', (tester) async {
    // final i18n = RM.injectI18N({
    //   const Locale('en'): () =>
    //       Future.delayed(const Duration(seconds: 1), () => 'hello'),
    // });
    final i18n = CustomInjected<String>(
        creator: () =>
            Future.delayed(const Duration(seconds: 1), () => 'hello'),
        useInheritedWidget: true);
    _builder = (ctx) {
      i18n.snapState;
      return MaterialApp(
        // locale: i18n.locale,
        home: Builder(
          builder: (context) {
            return Text(
              i18n.of(context),
            );
          },
        ),
      );
    };
    _onWaiting = const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Waiting...'),
    );

    await tester.pumpWidget(const _TopAppWidget1());
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);
  });

  // testWidgets(//TODO
  //     'Throw if i18n is provided with async translation '
  //     'and without defining onWaiting', (tester) async {
  //   final i18n = RM.injectI18N({
  //     const Locale('en'): () =>
  //         Future.delayed(const Duration(seconds: 1), () => 'hello'),
  //   });
  //   _builder = (ctx) {
  //     return MaterialApp(
  //       locale: i18n.locale,
  //       home: Builder(
  //         builder: (context) {
  //           return Text(
  //             i18n.of(context),
  //           );
  //         },
  //       ),
  //     );
  //   };

  //   await tester.pumpWidget(const _TopAppWidget1());
  //   expect(tester.takeException(), isException);
  //   await tester.pump(const Duration(seconds: 1));
  // });

  testWidgets('Top widget waits for provided futures', (tester) async {
    _builder = (ctx) {
      return const MaterialApp(
        home: Text('Is Ready'),
      );
    };
    _onWaiting = const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Waiting...'),
    );
    _ensureInitialization = () => [
          Future.delayed(const Duration(seconds: 1)),
          Future.delayed(const Duration(seconds: 2)),
        ];

    await tester.pumpWidget(const _TopAppWidget1());
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Is Ready'), findsOneWidget);
  });

  testWidgets('async i18n 1 s with waitFor 2s', (tester) async {
    // final i18n = RM.injectI18N({
    //   const Locale('en'): () =>
    //       Future.delayed(const Duration(seconds: 1), () => 'hello'),
    // });
    final i18n = CustomInjected<String>(
        creator: () =>
            Future.delayed(const Duration(seconds: 1), () => 'hello'),
        useInheritedWidget: true);

    _builder = (ctx) {
      i18n.snapState;
      return MaterialApp(
        // locale: i18n.locale,
        home: Builder(builder: (context) {
          return Text(i18n.of(context));
        }),
      );
    };
    _onWaiting = const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Waiting...'),
    );
    _ensureInitialization = () => [
          Future.delayed(const Duration(seconds: 2)),
          i18n.stateAsync,
        ];

    await tester.pumpWidget(const _TopAppWidget1());
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('async i18n 2 s with waitFor 1s', (tester) async {
    // final i18n = RM.injectI18N({
    //   const Locale('en'): () =>
    //       Future.delayed(const Duration(seconds: 2), () => 'hello'),
    // });
    final i18n = CustomInjected<String>(
        creator: () =>
            Future.delayed(const Duration(seconds: 2), () => 'hello'),
        useInheritedWidget: true);

    _builder = (ctx) {
      i18n.snapState;

      return MaterialApp(
        // locale: i18n.locale,
        home: Builder(builder: (context) {
          return Text(i18n.of(context));
        }),
      );
    };
    _onWaiting = const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Waiting...'),
    );
    _ensureInitialization = () => [
          Future.delayed(const Duration(seconds: 2)),
          // i18n.stateAsync,
        ];

    await tester.pumpWidget(const _TopAppWidget1());

    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('TopAppWidget error', (tester) async {
    bool shouldThrow = true;
    void Function()? refresh;
    _builder = (ctx) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Text('Data'),
      );
    };
    _onWaiting = const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Waiting...'),
    );
    _ensureInitialization = () => [
          Future.delayed(const Duration(seconds: 1),
              () => shouldThrow ? throw Exception('Error') : 1),
          Future.delayed(const Duration(seconds: 2), () => 2),
        ];
    _onError = (err, refresher) {
      refresh = refresher;
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Text('Error'),
      );
    };

    await tester.pumpWidget(const _TopAppWidget1());
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Error'), findsOneWidget);
    shouldThrow = false;
    refresh!();
    await tester.pump();
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Data'), findsOneWidget);
  });

  testWidgets('TopAppWidget error when errorScreen is not defined',
      (tester) async {
    _builder = (ctx) {
      return const Directionality(
        textDirection: TextDirection.rtl,
        child: Text('Data'),
      );
    };
    _onWaiting = const Directionality(
      textDirection: TextDirection.ltr,
      child: Text('Waiting...'),
    );
    _ensureInitialization = () => [
          Future.delayed(
            const Duration(seconds: 1),
            () => throw Exception('Error'),
          ),
        ];

    await tester.pumpWidget(const _TopAppWidget1());
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isException);
  });
  testWidgets(
    'TopStatelessWidget register to a ReactiveModel',
    (tester) async {
      final model = CustomInjected<bool>(
        creator: () => true,
      );
      _builder = (_) => Directionality(
            textDirection: TextDirection.ltr,
            child: Text(model.state.toString()),
          );
      await tester.pumpWidget(const _TopAppWidget1());
      expect(find.text('true'), findsOneWidget);
      model.toggle();
      await tester.pump();
      expect(find.text('false'), findsOneWidget);

      // final theme = RM.injectTheme(lightThemes: {
      //   'basic': ThemeData.light(),
      // }, darkThemes: {
      //   'basic': ThemeData.dark(),
      // });
      // late Brightness brightness;
      // _builder = (context) {
      //   return MaterialApp(
      //     theme: theme.lightTheme,
      //     darkTheme: theme.darkTheme,
      //     themeMode: theme.themeMode,
      //     home: () {
      //       return Builder(
      //         builder: (context) {
      //           brightness = Theme.of(context).brightness;
      //           return Container();
      //         },
      //       );
      //     }(),
      //   );
      // };
      // await tester.pumpWidget(const _TopAppWidget1());
      // expect(brightness, Brightness.light);
      // //
      // theme.toggle();
      // await tester.pumpAndSettle();
      // expect(brightness, Brightness.dark);
    },
  );
  testWidgets('appLifeCycle works', (WidgetTester tester) async {
    final TestDefaultBinaryMessenger defaultBinaryMessenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    AppLifecycleState? lifecycleState;

    _didChangeAppLifecycleState = (state) {
      lifecycleState = state;
    };
    await tester.pumpWidget(const _TopAppWidget2());

    expect(lifecycleState, isNull);

    ByteData? message =
        const StringCodec().encodeMessage('AppLifecycleState.paused');
    await defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle', message, (_) {});
    await tester.pump();
    expect(lifecycleState, AppLifecycleState.paused);

    message = const StringCodec().encodeMessage('AppLifecycleState.resumed');
    await defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle', message, (_) {});
    expect(lifecycleState, AppLifecycleState.resumed);

    message = const StringCodec().encodeMessage('AppLifecycleState.inactive');
    await defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle', message, (_) {});
    expect(lifecycleState, AppLifecycleState.inactive);

    message = const StringCodec().encodeMessage('AppLifecycleState.detached');
    await defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle', message, (_) {});
    expect(lifecycleState, AppLifecycleState.detached);
  });
}

class _TopAppWidget1 extends TopStatelessWidget {
  const _TopAppWidget1({Key? key}) : super(key: key);

  @override
  List<Future>? ensureInitialization() {
    return _ensureInitialization?.call();
  }

  @override
  Widget? splashScreen() {
    return _onWaiting;
  }

  @override
  Widget? errorScreen(error, void Function() refresh) {
    return _onError?.call(error, refresh);
  }

  @override
  Widget build(BuildContext context) {
    return _builder(context);
  }
}

class _TopAppWidget2 extends TopStatelessWidget {
  const _TopAppWidget2({Key? key}) : super(key: key);
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _didChangeAppLifecycleState?.call(state);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CustomInjected<T> extends InjectedImp<T> {
  CustomInjected({
    required Object Function() creator,
    this.useInheritedWidget = false,
  }) : super(
          autoDisposeWhenNotUsed: true,
          creator: creator,
          debugPrintWhenNotifiedPreMessageGlobal: null,
          dependsOn: null,
          initialState: null,
          sideEffectsGlobal: null,
          stateInterceptor: null,
          toDebugString: null,
          watch: null,
        );
  final bool useInheritedWidget;

  bool onTopObserverAdded(_) {
    return useInheritedWidget;
  }

  @override
  SnapState<T> get snapState {
    TopStatelessWidget.addToObs?.call(this, onTopObserverAdded, null);
    return super.snapState;
  }
}
