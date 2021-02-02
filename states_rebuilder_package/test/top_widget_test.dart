import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('StateWithMixinBuilder appLifeCycle works',
      (WidgetTester tester) async {
    final BinaryMessenger defaultBinaryMessenger =
        ServicesBinding.instance!.defaultBinaryMessenger;
    AppLifecycleState? lifecycleState;
    final widget = TopWidget(
      didChangeAppLifecycleState: (state) {
        lifecycleState = state;
      },
      didChangeLocales: (state) {
        // print(state);
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
