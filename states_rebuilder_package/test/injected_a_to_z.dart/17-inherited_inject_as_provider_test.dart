import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final counter1 = RM.inject<int>(() => 10);
final counter2 = RM.inject<int>(() => 20);
final counter3 =
    RM.injectFuture<int>(() => Future.delayed(Duration(seconds: 1), () => 30));

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return counter1.inherited(
    //   builder: (context) => counter2.inherited(
    //     builder: (context) => counter3.inherited(
    //       builder: (context) => _MyHomePage(),
    //       // debugPrintWhenNotifiedPreMessage: 'counter3',
    //     ),
    //     // debugPrintWhenNotifiedPreMessage: 'counter2',
    //   ),
    //   // debugPrintWhenNotifiedPreMessage: 'counter1',
    // );

    return [counter1, counter2, counter3].inherited(
      builder: (context) => _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Text('counter1: ${counter1.of(context)}'),
            Text('counter2: ${counter2.of(context)}'),
            if (counter3(context)?.isWaiting == false)
              Text('counter3: ${counter3.of(context)}')
            else
              CircularProgressIndicator(),
          ],
        ));
  }
}

void main() {
  testWidgets('should get the right state without been mixed with type',
      (tester) async {
    await tester.pumpWidget(_App());
    //initial build
    expect(find.text('counter1: 10'), findsOneWidget);
    expect(find.text('counter2: 20'), findsOneWidget);
    //counter3 is waiting
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('counter3: 30'), findsNothing);
    //after one second
    await tester.pump(Duration(seconds: 1));
    expect(find.text('counter3: 30'), findsOneWidget);
    //
    //increment the first counter
    counter1.state++;
    await tester.pump();
    expect(find.text('counter1: 11'), findsOneWidget); // change here
    expect(find.text('counter2: 20'), findsOneWidget);
    expect(find.text('counter3: 30'), findsOneWidget);
    //
    //increment the second counter
    counter2.state++;
    await tester.pump();
    expect(find.text('counter1: 11'), findsOneWidget);
    expect(find.text('counter2: 21'), findsOneWidget); // change here
    expect(find.text('counter3: 30'), findsOneWidget);
    //
    //increment the third counter
    counter3.state++;
    await tester.pump();
    expect(find.text('counter1: 11'), findsOneWidget);
    expect(find.text('counter2: 21'), findsOneWidget);
    expect(find.text('counter3: 31'), findsOneWidget); // change here
  });
}
