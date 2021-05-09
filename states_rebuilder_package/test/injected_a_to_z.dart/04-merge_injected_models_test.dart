import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//plugin1 takes one seconds to initialized.
final plugin1 = RM.injectFuture(
  () => Future.delayed(Duration(seconds: 1), () => 'plugin1 is initialized'),
);
//plugin2 takes two seconds to initialized.
final plugin2 = RM.injectFuture(
  () => Future.delayed(Duration(seconds: 2), () => 'plugin2 is initialized'),
);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: OnCombined.all(
        onIdle: () => Text('Idle'),
        //called if at least on plugin is waiting.
        onWaiting: () => Text('Waiting'),
        //called if no plugin is waiting and at least on of them has error
        onError: (error, _) => Text('error'),
        //called if both plugins have been initialized successfully
        onData: (_) {
          //Here it is safe to use our plugins
          return Column(
            children: [
              Text(plugin1.state),
              Text(plugin2.state),
            ],
          );
        },
      ).listenTo([plugin1, plugin2]),
    );
  }
}

void main() {
  testWidgets('Initialization', (tester) async {
    await tester.pumpWidget(App());
    //At start the onWait splash screen is displayed
    expect(find.text('Waiting'), findsOneWidget);
    //
    //After one seconds
    await tester.pump(Duration(seconds: 1));
    //we still seeing the splash screen
    expect(find.text('Waiting'), findsOneWidget);
    //plugin1 is initialized successfully
    expect(plugin1.hasData, isTrue);
    //But plugin2 is still initializing
    expect(plugin2.isWaiting, isTrue);
    //
    //after an other half seconds (Total time: 1.5 seconds)
    await tester.pump(Duration(milliseconds: 500));
    //we still seeing the splash screen
    expect(find.text('Waiting'), findsOneWidget);
    //
    //after an other half seconds (Total time: 2 seconds)
    await tester.pump(Duration(milliseconds: 500));
    //Both plugins  are initialized successfully
    expect(find.text('plugin1 is initialized'), findsOneWidget);
    expect(find.text('plugin2 is initialized'), findsOneWidget);
  });
}
