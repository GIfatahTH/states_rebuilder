import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

//Create a reactiveModel.
//Its sole purpose is the rebuild the whole list.
final model = ReactiveModel.create('');
//variable to count the number of whole list rebuild
//Use in Tests
int numberOfWHoleListRebuild = 0;

final counters = [0, 10, 100, 1000]; //can be fetched from a backend service

class Counters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Use StateBuilder to register to model
    return StateBuilder(
        observe: () => model,
        builder: (_, __) {
          //onEach rebuild increment numberOfWHoleListRebuild
          numberOfWHoleListRebuild++;
          return Directionality(
            textDirection: TextDirection.ltr,
            //The listView builder
            child: ListView.builder(
              itemCount: counters.length,
              itemBuilder: (ctx, index) {
                return CounterItem(index: index);
              },
            ),
          );
        });
  }
}

class CounterItem extends StatelessWidget {
  final int index;
  //create an Injected model for each item.
  final Injected<int> counter;

  CounterItem({Key? key, required this.index})
      //This will be called whenever any of the parent widget rebuilds.
      : counter = RM.inject(() => counters[index]),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          //Key use in tests
          key: Key('button-$index'),
          child: On.data(
            () => Text('${counter.state}'),
          ).listenTo(counter),
          onPressed: () => counter.state++,
        )
      ],
    );
  }
}

void main() {
  setUp(() {
    //reset to zero before each test
    numberOfWHoleListRebuild = 0;
  });
  testWidgets('Initial build', (tester) async {
    await tester.pumpWidget(Counters());
    //Expect to see 4 RaisedButtons
    expect(find.byType(ElevatedButton), findsNWidgets(4));
    //Here is the details:
    expect(find.text('0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);
    //
    //The first build
    expect(numberOfWHoleListRebuild, equals(1));
  });

  testWidgets('Should increment counter of index 1', (tester) async {
    await tester.pumpWidget(Counters());

    //Tap on the button that has '10' as text
    await tester.tap(find.byKey(Key('button-1')));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('11'), findsOneWidget); //the changes
    expect(find.text('100'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);
  });

  testWidgets(
      'Should increment counter of index 2 and keep state after parent rebuild',
      (tester) async {
    await tester.pumpWidget(Counters());

    //Tap on the button that has '100' as text
    await tester.tap(find.byKey(Key('button-2')));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('101'), findsOneWidget); //Here the change
    expect(find.text('1000'), findsOneWidget);
    //
    expect(numberOfWHoleListRebuild, equals(1));

    //Rebuild the whole list
    model.notify();
    await tester.pump();

    //Indeed the whole list is rebuilt
    expect(numberOfWHoleListRebuild, equals(2));

    //The state is reserved
    expect(find.text('0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('101'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);

    //Tap on the button that has '1000' as text
    await tester.tap(find.byKey(Key('button-3')));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('101'), findsOneWidget);
    expect(find.text('1001'), findsOneWidget);
  });
}
