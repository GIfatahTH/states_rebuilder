import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('provide i18n', (tester) async {
    final i18n = RM.injectI18N({
      Locale('en'): () => 'hello',
      Locale('fr'): () => 'salut',
    });
    final widget = TopWidget(
      injectedI18N: i18n,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(i18n.of(ctx)!),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(find.text('hello'), findsOneWidget);
    i18n.state = 'hello world';
    await tester.pump();
    expect(find.text('hello world'), findsOneWidget);
  });

  testWidgets('provide i18n with async translation', (tester) async {
    final i18n = RM.injectI18N({
      Locale('en'): () => Future.delayed(Duration(seconds: 1), () => 'hello'),
    });
    final widget = TopWidget(
      injectedI18N: i18n,
      onWaiting: () => Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Waiting...'),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(i18n.of(ctx)!),
        );
      },
    );
    await tester.pumpWidget(widget);
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
    final widget = TopWidget(
      injectedI18N: i18n,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(i18n.of(ctx)!),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(tester.takeException(), isException);
    await tester.pump(Duration(seconds: 1));
  });

  testWidgets('Top widget waits for provided futures', (tester) async {
    final widget = TopWidget(
      waiteFor: () => [
        Future.delayed(Duration(seconds: 1)),
        Future.delayed(Duration(seconds: 2)),
      ],
      onWaiting: () => Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Waiting...'),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text('Is Ready'),
        );
      },
    );
    await tester.pumpWidget(widget);
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
    final widget = TopWidget(
      injectedI18N: i18n,
      waiteFor: () => [
        Future.delayed(Duration(seconds: 2)),
      ],
      onWaiting: () => Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Waiting...'),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(i18n.of(ctx)!),
        );
      },
    );
    await tester.pumpWidget(widget);
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
    final widget = TopWidget(
      injectedI18N: i18n,
      waiteFor: () => [
        Future.delayed(Duration(seconds: 1)),
      ],
      onWaiting: () => Directionality(
        textDirection: TextDirection.ltr,
        child: Text('Waiting...'),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(i18n.of(ctx)!),
        );
      },
    );
    await tester.pumpWidget(widget);
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('appLifeCycle works', (WidgetTester tester) async {
    final BinaryMessenger defaultBinaryMessenger =
        ServicesBinding.instance!.defaultBinaryMessenger;
    AppLifecycleState? lifecycleState;
    final widget = TopWidget(
      didChangeAppLifecycleState: (state) {
        lifecycleState = state;
      },
      builder: (_) => Container(),
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
