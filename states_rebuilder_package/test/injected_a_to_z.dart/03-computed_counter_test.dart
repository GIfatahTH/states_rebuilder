import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

final counter1 = RM.inject(
  () => 10,
  // debugPrintWhenNotifiedPreMessage: 'counter1',
);
final counter2 = RM.inject(() => 10);

//use to test the number of computed method call
int numberOfComputeCall = 0;
//
final computedCounter = RM.inject<String>(
  () {
    numberOfComputeCall++;
    //Return the first digit
    return '${counter1.state + counter2.state}'[0];
  },
  //-- Optionally
  //
  //initial value
  initialState: '0',
  dependsOn: DependsOn<String>({counter1, counter2},
      shouldNotify: (String? state) =>
          int.parse(state?.isNotEmpty == true ? state! : '0') < 5 &&
          counter1.state < 50),
  //when compute function will be invoked.
  //from the value of 5 the compute function will not be invoked
  //also if counter1.state > the compute function will not be invoked
  // shouldCompute: (String? state) =>
  //     int.parse(state?.isNotEmpty == true ? state! : '0') < 5 &&
  //     counter1.state < 50,

  // onData: (int state) => print('data $state'),
  // onWaiting: () => print('waiting'),
  // onError: (e, s) => print('error : $e'),
  // onDispose: (int state) => print('disposed'),

  // debugPrintWhenNotifiedPreMessage: 'computedCounter',
);

//Used to test the number of rebuild call
int numberOfCounter1Rebuild = 0;
int numberOfCounter2Rebuild = 0;
int numberOfComputedRebuild = 0;

class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          On.data(
            () {
              numberOfCounter1Rebuild++;
              return Text('counter1 : ${counter1.state}');
            },
          ).listenTo(counter1),

          //you can use this
          // counter2.rebuilder(() {
          //   numberOfCounter2Rebuild++;
          //   return Text('counter2 : ${counter2.state}');
          // }),
          //
          //Or you can use StateBuilder,

          // StateBuilder(
          //   observe: () => counter2,
          //   builder: (context, counter2RM) {
          //     numberOfCounter2Rebuild++;
          //     return Text('counter2 : ${counter2.state}');
          //   },
          // ),
          On.data(() {
            numberOfCounter2Rebuild++;
            return Text('counter2 : ${counter2.state}');
          }).listenTo(counter2),
          On.data(() {
            numberOfComputedRebuild++;
            return Text('computedCounter : ${computedCounter.state}');
          }).listenTo(computedCounter),
        ],
      ),
    );
  }
}

void main() {
  setUp(() {
    numberOfComputeCall = 0;
    numberOfCounter1Rebuild = 0;
    numberOfCounter2Rebuild = 0;
    numberOfComputedRebuild = 0;
  });
  //counters can be tested without mocking

  testWidgets('initial build', (tester) async {
    await tester.pumpWidget(CounterApp());
    expect(find.text('counter1 : 10'), findsOneWidget);
    expect(find.text('counter2 : 10'), findsOneWidget);
    expect(find.text('computedCounter : 2'), findsOneWidget);

    //
    //the compute method is called once
    expect(numberOfComputeCall, 1);
    //initial rebuild
    expect(numberOfCounter1Rebuild, 1);
    expect(numberOfCounter2Rebuild, 1);
    expect(numberOfComputedRebuild, 1);
  });

  testWidgets('increment counter1 => computedCounter is incremented',
      (tester) async {
    await tester.pumpWidget(CounterApp());
    counter1.state = counter1.state + 10;
    await tester.pump();

    expect(find.text('counter1 : 20'), findsOneWidget);
    expect(find.text('counter2 : 10'), findsOneWidget);
    expect(find.text('computedCounter : 3'), findsOneWidget);

    //
    //the compute method is called twice
    expect(numberOfComputeCall, 2);
    //counter 1 is rebuilt
    expect(numberOfCounter1Rebuild, 2);
    //counter 2 is not rebuilt
    expect(numberOfCounter2Rebuild, 1);
    //computedCounter is rebuilt
    expect(numberOfComputedRebuild, 2);
  });

  testWidgets('increment counter2 => computedCounter is incremented',
      (tester) async {
    await tester.pumpWidget(CounterApp());
    counter2.state = counter2.state + 10;
    await tester.pump();

    expect(find.text('counter1 : 10'), findsOneWidget);
    expect(find.text('counter2 : 20'), findsOneWidget);
    expect(find.text('computedCounter : 3'), findsOneWidget);

    //
    //the compute method is called for the the second time
    // expect(numberOfComputeCall, 2); //TODO Fixme
    //counter 1 is not rebuilt
    expect(numberOfCounter1Rebuild, 1);
    //counter 2 is  rebuild
    expect(numberOfCounter2Rebuild, 2);
    //computedCounter is rebuilt
    expect(numberOfComputedRebuild, 2);
  });

  testWidgets(
      'computedCounter will not rebuild if the competed result is not changed',
      (tester) async {
    await tester.pumpWidget(CounterApp());

    // initial rebuild
    expect(find.text('counter1 : 10'), findsOneWidget);
    expect(find.text('counter2 : 10'), findsOneWidget);
    expect(find.text('computedCounter : 2'), findsOneWidget);

    counter1.state++;

    await tester.pump();

    expect(find.text('counter1 : 11'), findsOneWidget);
    expect(find.text('counter2 : 10'), findsOneWidget);
    // 11 + 10 = 21, the computed first digit is 2.
    expect(find.text('computedCounter : 2'), findsOneWidget);

    //
    //the compute method is called for the the second time
    expect(numberOfComputeCall, 2);
    //counter 1 is not rebuilt
    expect(numberOfCounter1Rebuild, 2);
    //counter 2 is  rebuild
    expect(numberOfCounter2Rebuild, 1);
    //Although the computed method is invoked twice, the computedCounter is not rebuilt rebuild,
    //because the its value does not change
    expect(numberOfComputedRebuild, 1);
  });

  testWidgets('compute will not be invoked if shouldCompute is false',
      (tester) async {
    await tester.pumpWidget(CounterApp());

    // initial rebuild
    expect(find.text('counter1 : 10'), findsOneWidget);
    expect(find.text('counter2 : 10'), findsOneWidget);
    expect(find.text('computedCounter : 2'), findsOneWidget);

    counter1.state = 50;

    await tester.pump();

    expect(find.text('counter1 : 50'), findsOneWidget);
    expect(find.text('counter2 : 10'), findsOneWidget);
    // counter 1 is not <50 => shouldCompute is false
    expect(find.text('computedCounter : 2'), findsOneWidget);

    //
    //the compute method is called for the the second time
    expect(numberOfComputeCall, 1);
    //counter 1 is not rebuilt
    expect(numberOfCounter1Rebuild, 2);
    //counter 2 is  rebuild
    expect(numberOfCounter2Rebuild, 1);
    //Although the computed method is invoked twice, the computedCounter is not rebuilt rebuild,
    //because the its value does not change
    expect(numberOfComputedRebuild, 1);
  });
}
