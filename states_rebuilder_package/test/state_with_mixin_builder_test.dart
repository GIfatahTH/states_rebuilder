import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

void main() {
  late Model model;
  setUp(() {
    model = Model();
  });

  testWidgets(
    "StateWithMixinBuilder throws if no builder or builderWithChild ",
    (WidgetTester tester) async {
      expect(
          () => StateWithMixinBuilder(
              mixinWith: MixinWith.tickerProviderStateMixin,
              observe: () => model),
          throwsAssertionError);
    },
  );

  testWidgets(
    "StateWithMixinBuilder throws if builderWithChild is defined without child parameter",
    (WidgetTester tester) async {
      expect(
          () => StateWithMixinBuilder(
                mixinWith: MixinWith.tickerProviderStateMixin,
                observe: () => model,
                builderWithChild: (_, rm, child) => child,
              ),
          throwsAssertionError);
    },
  );

  testWidgets(
    "StateWithMixinBuilder should mixin with singleTickerProviderStateMixin ",
    (WidgetTester tester) async {
      var ticker;
      Widget widget = StateWithMixinBuilder(
        observe: () => model,
        mixinWith: MixinWith.singleTickerProviderStateMixin,
        initState: (context, rm, tick) {
          ticker = tick;
        },
        dispose: (_, __, ___) {},
        builder: (_, __) => Container(),
      );

      await tester.pumpWidget(widget);

      expect(ticker, isA<SingleTickerProviderStateMixin>());
    },
  );

  testWidgets(
    "StateWithMixinBuilder should mixin with singleTickerProviderStateMixin with generic type ",
    (WidgetTester tester) async {
      var ticker;
      Widget widget =
          StateWithMixinBuilder<SingleTickerProviderStateMixin, dynamic>(
        observe: () => model,
        mixinWith: MixinWith.singleTickerProviderStateMixin,
        initState: (context, rm, tick) {
          ticker = tick;
        },
        dispose: (_, __, ___) {},
        builder: (_, __) => Container(),
      );

      await tester.pumpWidget(widget);

      expect(ticker, isA<SingleTickerProviderStateMixin>());
    },
  );
  testWidgets(
    "StateWithMixinBuilder.singleTickerProvider should  work ",
    (WidgetTester tester) async {
      var ticker;
      Widget widget = StateWithMixinBuilder.singleTickerProvider<Model>(
        observe: () => model,
        initState: (context, ReactiveModel<Model>? rm,
            SingleTickerProviderStateMixin? tick) {
          ticker = tick;
        },
        dispose: (context, ReactiveModel<Model>? rm,
            SingleTickerProviderStateMixin? tick) {},
        builder: (context, ReactiveModel<Model>? rm) => Container(),
        didChangeDependencies: (context, ReactiveModel<Model>? rm,
            SingleTickerProviderStateMixin? ticker) {},
        didUpdateWidget:
            (context, old, SingleTickerProviderStateMixin? ticker) {},
        afterInitialBuild: (context, ReactiveModel<Model>? rm) {},
        afterRebuild: (context, ReactiveModel<Model>? rm) {},
      );

      await tester.pumpWidget(widget);

      expect(ticker, isA<SingleTickerProviderStateMixin>());
    },
  );
  testWidgets(
    "StateWithMixinBuilder should mixin with TickerProviderStateMixin ",
    (WidgetTester tester) async {
      var ticker;
      Widget widget = StateWithMixinBuilder(
        observe: () => model,
        mixinWith: MixinWith.tickerProviderStateMixin,
        initState: (context, rm, tick) {
          ticker = tick;
        },
        dispose: (_, __, ___) {},
        builder: (_, __) => Container(),
      );

      await tester.pumpWidget(widget);

      expect(ticker, isA<TickerProviderStateMixin>());
    },
  );

  testWidgets(
    "StateWithMixinBuilder should mixin with TickerProviderStateMixin with generic type ",
    (WidgetTester tester) async {
      var ticker;
      Widget widget = StateWithMixinBuilder<TickerProviderStateMixin, dynamic>(
        observe: () => model,
        mixinWith: MixinWith.tickerProviderStateMixin,
        initState: (context, rm, tick) {
          ticker = tick;
        },
        dispose: (_, __, ___) {},
        builder: (_, __) => Container(),
      );

      await tester.pumpWidget(widget);

      expect(ticker, isA<TickerProviderStateMixin>());
    },
  );

  testWidgets(
    "StateWithMixinBuilder.tickerProvider should  work ",
    (WidgetTester tester) async {
      var ticker;
      Widget widget = StateWithMixinBuilder.tickerProvider<Model>(
        observe: () => model,
        initState: (context, ReactiveModel<Model>? rm,
            TickerProviderStateMixin? tick) {
          ticker = tick;
        },
        dispose: (context, ReactiveModel<Model>? rm,
            TickerProviderStateMixin? tick) {},
        builder: (context, ReactiveModel<Model>? rm) => Container(),
        didChangeDependencies: (context, ReactiveModel<Model>? rm,
            TickerProviderStateMixin? ticker) {},
        didUpdateWidget: (context, old, TickerProviderStateMixin? ticker) {},
        afterInitialBuild: (context, ReactiveModel<Model>? rm) {},
        afterRebuild: (context, ReactiveModel<Model>? rm) {},
      );

      await tester.pumpWidget(widget);

      expect(ticker, isA<TickerProviderStateMixin>());
    },
  );

  testWidgets(
    "StateWithMixinBuilder should mixin with automaticKeepAliveClientMixin ",
    (WidgetTester tester) async {
      var ticker;
      Widget widget = StateWithMixinBuilder(
        observe: () => model,
        mixinWith: MixinWith.automaticKeepAliveClientMixin,
        initState: (context, rm, tick) {
          ticker = tick;
        },
        builder: (_, __) => Container(),
      );

      await tester.pumpWidget(widget);

      expect(ticker, isA<AutomaticKeepAliveClientMixin>());
    },
  );

  testWidgets(
    "StateWithMixinBuilder should mixin with automaticKeepAliveClientMixin with generic type ",
    (WidgetTester tester) async {
      var ticker;
      Widget widget =
          StateWithMixinBuilder<AutomaticKeepAliveClientMixin, dynamic>(
        observe: () => model,
        mixinWith: MixinWith.automaticKeepAliveClientMixin,
        initState: (context, rm, tick) {
          ticker = tick;
        },
        builder: (_, __) => Container(),
      );

      await tester.pumpWidget(widget);

      expect(ticker, isA<AutomaticKeepAliveClientMixin>());
    },
  );

  testWidgets(
    "StateWithMixinBuilder.automaticKeepAlive should  work ",
    (WidgetTester tester) async {
      Widget widget = StateWithMixinBuilder.automaticKeepAlive<Model>(
        observe: () => model,
        initState: (context, ReactiveModel<Model>? rm) {},
        dispose: (context, ReactiveModel<Model>? rm) {},
        builder: (context, ReactiveModel<Model>? rm) => Container(),
        didChangeDependencies: (context, ReactiveModel<Model>? rm) {},
        didUpdateWidget: (context,
            StateWithMixinBuilder<AutomaticKeepAliveClientMixin, Model> old) {},
        afterInitialBuild: (context, ReactiveModel<Model>? rm) {},
        afterRebuild: (context, ReactiveModel<Model>? rm) {},
      );

      await tester.pumpWidget(widget);
    },
  );

  testWidgets(
    "StateWithMixinBuilder should mixin with widgetsBindingObserver ",
    (WidgetTester tester) async {
      var ticker;
      Widget widget = StateWithMixinBuilder(
        observe: () => model,
        mixinWith: MixinWith.widgetsBindingObserver,
        initState: (context, rm, tick) {
          ticker = tick;
        },
        builder: (_, __) => Container(),
      );

      await tester.pumpWidget(widget);

      expect(ticker, isA<WidgetsBindingObserver>());
    },
  );

  testWidgets(
    "StateWithMixinBuilder should mixin with widgetsBindingObserver with generic type",
    (WidgetTester tester) async {
      var ticker;
      Widget widget = StateWithMixinBuilder<WidgetsBindingObserver, dynamic>(
        observe: () => model,
        mixinWith: MixinWith.widgetsBindingObserver,
        initState: (context, rm, tick) {
          ticker = tick;
        },
        builder: (_, __) => Container(),
      );

      await tester.pumpWidget(widget);

      expect(ticker, isA<WidgetsBindingObserver>());
    },
  );

  testWidgets(
    "StateWithMixinBuilder.widgetsBindingObserver should  work ",
    (WidgetTester tester) async {
      Widget widget = StateWithMixinBuilder.widgetsBindingObserver<Model>(
          observe: () => model,
          initState: (context, ReactiveModel<Model>? rm) {},
          dispose: (context, ReactiveModel<Model>? rm) {},
          builder: (context, ReactiveModel<Model>? rm) => Container(),
          didChangeDependencies: (context, ReactiveModel<Model>? rm) {},
          didUpdateWidget: (context,
              StateWithMixinBuilder<WidgetsBindingObserver, Model> old) {},
          afterInitialBuild: (context, ReactiveModel<Model>? rm) {},
          afterRebuild: (context, ReactiveModel<Model>? rm) {},
          didChangeAppLifecycleState: (context, state) {
            // print(state);
          },
          didChangeLocales: (context, locals) {
            // print(locals);
          });

      await tester.pumpWidget(widget);
    },
  );

  testWidgets(
    'StateWithMixinBuilder should call dispose, didChangeDependencies and didUpdateWidget ',
    (tester) async {
      bool switcher = true;
      int numberOfAfterInitialBuilds = 0;
      int numberOfDidChangeDependencies = 0;
      int numberOfDidUpdateWidget = 0;
      int numberAfterRebuild = 0;
      int numberOfDispose = 0;
      var ticker;
      final widget = StateBuilder(
        observe: () => model,
        tag: ['mainTag'],
        builder: (ctx, _) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                if (switcher) {
                  return StateWithMixinBuilder(
                    mixinWith: MixinWith.tickerProviderStateMixin,
                    afterInitialBuild: (_, __) {
                      numberOfAfterInitialBuilds++;
                    },
                    dispose: (_, __, tick) {
                      numberOfDispose++;
                      ticker = tick;
                    },
                    didChangeDependencies: (_, ___, __) {
                      numberOfDidChangeDependencies++;
                    },
                    didUpdateWidget: (_, __, ___) {
                      numberOfDidUpdateWidget++;
                    },
                    afterRebuild: (_, __) {
                      numberAfterRebuild++;
                    },
                    observe: () => model,
                    tag: 'childTag',
                    builder: (context, _) {
                      return Text('${model.counter}');
                    },
                  );
                }
                return Text('false');
              },
            ),
          );
        },
      );

      await tester.pumpWidget(widget);

      expect(numberOfAfterInitialBuilds, equals(1));
      expect(numberOfDidChangeDependencies, equals(1));
      expect(numberOfDidUpdateWidget, equals(0));

      expect(numberAfterRebuild, equals(0));
      expect(numberOfDispose, equals(0));

      model.rebuildStates(['mainTag']);
      await tester.pump();

      // expect(numberOfAfterInitialBuilds, equals(1));
      // expect(numberOfDidChangeDependencies, equals(1));
      // expect(numberOfDidUpdateWidget, equals(1));
      // expect(numberAfterRebuild, equals(1));
      // expect(numberOfDispose, equals(0));

      // switcher = false;
      // model.rebuildStates(['mainTag']);
      // await tester.pump();

      // expect(numberOfAfterInitialBuilds, equals(1));
      // expect(numberOfDidChangeDependencies, equals(1));
      // expect(numberOfDidUpdateWidget, equals(1));
      // expect(numberAfterRebuild, equals(2));
      // expect(numberOfDispose, equals(1));

      // expect(ticker, isA<TickerProviderStateMixin>());
    },
  );

  testWidgets(
    'StateWithMixinBuilder should buildWithChild works',
    (tester) async {
      final widget = StateWithMixinBuilder(
        mixinWith: MixinWith.singleTickerProviderStateMixin,
        observe: () => model,
        initState: (_, ___, __) => null,
        dispose: (_, __, ___) => null,
        builderWithChild: (ctx, rm, child) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: <Widget>[
                Text('${model.counter}'),
                child,
              ],
            ),
          );
        },
        child: Text('${model.counter}'),
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsNWidgets(2));
      //
      model.increment();
      model.rebuildStates();
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'StateWithMixinBuilder should buildWithChild works',
    (tester) async {
      final widget = StateWithMixinBuilder(
        mixinWith: MixinWith.tickerProviderStateMixin,
        observe: () => model,
        initState: (_, ___, __) => null,
        dispose: (_, __, ___) => null,
        builderWithChild: (ctx, rm, child) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: <Widget>[
                Text('${model.counter}'),
                child,
              ],
            ),
          );
        },
        child: Text('${model.counter}'),
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsNWidgets(2));
      //
      model.increment();
      model.rebuildStates();
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    "StateWithMixinBuilder throws id dispose or initState are null with singleTickerProviderStateMixin",
    (WidgetTester tester) async {
      Widget widget = StateWithMixinBuilder(
        mixinWith: MixinWith.singleTickerProviderStateMixin,
        observe: () => model,
        builder: (_, __) => Container(),
      );

      await tester.pumpWidget(widget);
      expect(tester.takeException(), isAssertionError);
    },
  );
  testWidgets(
    "StateWithMixinBuilder throws id dispose or initState are null with tickerProviderStateMixin",
    (WidgetTester tester) async {
      Widget widget = StateWithMixinBuilder(
        mixinWith: MixinWith.tickerProviderStateMixin,
        initState: (_, ___, __) => null,
        observe: () => model,
        builder: (_, __) => Container(),
      );

      await tester.pumpWidget(widget);
      expect(tester.takeException(), isAssertionError);
    },
  );

  testWidgets(
      "StateWithMixinBuilder should automaticKeepAliveClientMixin work ",
      (WidgetTester tester) async {
    int numberOfKeepAliveRebuild = 0;
    int numberOfNonKeepAliveRebuild = 0;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.builder(
        addSemanticIndexes: false,
        itemCount: 50,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return StateWithMixinBuilder(
              mixinWith: MixinWith.automaticKeepAliveClientMixin,
              builder: (_, __) {
                numberOfKeepAliveRebuild++;
                return Container(
                  height: 44.0,
                  child: Text('KeepAlive'),
                );
              },
            );
          } else if (index == 1) {
            return Builder(
              builder: (_) {
                numberOfNonKeepAliveRebuild++;
                return Container(
                  height: 44.0,
                  child: Text('NonKeepAlive'),
                );
              },
            );
          } else {
            return Container(
              height: 44.0,
              child: Text('Container $index'),
            );
          }
        },
      ),
    ));

    expect(find.text('KeepAlive'), findsOneWidget);
    expect(numberOfKeepAliveRebuild, equals(1));
    expect(find.text('NonKeepAlive'), findsOneWidget);
    expect(numberOfNonKeepAliveRebuild, equals(1));
    expect(find.text('Container 2'), findsOneWidget);
    expect(find.text('Container 3'), findsOneWidget);

    await tester.drag(
        find.byType(ListView), const Offset(0.0, -1000.0)); // move to bottom
    await tester.pump();

    expect(find.text('KeepAlive'), findsNothing);
    expect(numberOfKeepAliveRebuild, equals(1));
    expect(find.text('NonKeepAlive'), findsNothing);
    expect(numberOfNonKeepAliveRebuild, equals(1));
    expect(find.text('Container 2'), findsNothing);
    expect(find.text('Container 3'), findsNothing);

    await tester.drag(
        find.byType(ListView), const Offset(0.0, 1000.0)); // move to bottom
    await tester.pump();

    expect(find.text('KeepAlive'), findsOneWidget);
    expect(numberOfKeepAliveRebuild, equals(1));
    expect(find.text('NonKeepAlive'), findsOneWidget);
    expect(numberOfNonKeepAliveRebuild, equals(2));
    expect(find.text('Container 2'), findsOneWidget);
    expect(find.text('Container 3'), findsOneWidget);
  });

  testWidgets('StateWithMixinBuilder didChangeLocales works',
      (WidgetTester tester) async {
    List<Locale>? locales;

    final widget = StateWithMixinBuilder(
      mixinWith: MixinWith.widgetsBindingObserver,
      didChangeLocales: (context, ls) {
        locales = ls;
      },
      builder: (_, __) => Container(),
    );
    await tester.pumpWidget(widget);
    expect(locales, null);
    await tester.binding.setLocale('en', 'BR');
    expect(locales, [Locale('en', 'BR')]);
  });

  testWidgets(
    'StateWithMixinBuilder should buildWithChild works',
    (tester) async {
      final widget = StateWithMixinBuilder(
        mixinWith: MixinWith.singleTickerProviderStateMixin,
        didUpdateWidget: (_, __, ___) {},
        initState: (_, __, ___) {},
        dispose: (_, __, ___) {},
        builderWithChild: (ctx, rm, child) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: <Widget>[
                Text('${model.counter}'),
                child,
              ],
            ),
          );
        },
        child: Text('${model.counter}'),
      );

      await tester.pumpWidget(widget);
      expect(find.text('0'), findsNWidgets(2));
    },
  );

  testWidgets('StateWithMixinBuilder appLifeCycle works',
      (WidgetTester tester) async {
    final BinaryMessenger defaultBinaryMessenger =
        ServicesBinding.instance!.defaultBinaryMessenger;
    AppLifecycleState? lifecycleState;
    final widget = StateWithMixinBuilder(
      mixinWith: MixinWith.widgetsBindingObserver,
      didChangeAppLifecycleState: (context, state) {
        lifecycleState = state;
      },
      builder: (_, __) => Container(),
    );

    await tester.pumpWidget(widget);

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

class Model extends StatesRebuilder<Model> {
  int counter = 0;
  int numberOfDisposeCall = 0;
  void increment() {
    counter++;
  }

  dispose() {
    numberOfDisposeCall++;
  }
}
