import 'package:clean_architecture_multi_counter_realtime_firebase/data_source/counter_fake_repository.dart';
import 'package:clean_architecture_multi_counter_realtime_firebase/injected.dart';
import 'package:clean_architecture_multi_counter_realtime_firebase/my_app.dart';
import 'package:clean_architecture_multi_counter_realtime_firebase/ui/common/config.dart';
import 'package:clean_architecture_multi_counter_realtime_firebase/ui/pages/home_page/counter_list_tile.dart';
import 'package:clean_architecture_multi_counter_realtime_firebase/ui/widgets/counter_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    config.injectMock(() => DevConfig());
    counterRepository.injectMock(() => CounterFakeRepository());
  });

  testWidgets(
      'Display one counter at startup and remove it on drag and create new one',
      (tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    //expect to find one counter in the list
    expect(find.byType(CounterListTile), findsOneWidget);
    //expect to see counter id
    expect(find.text('1000000000001'), findsOneWidget);

    //remove the counter
    await tester.drag(find.text('1000000000001'), Offset(-1000, 0));
    await tester.pump();
    await tester.pump(Duration(seconds: 1));
    await tester.pump(Duration(seconds: 1));
    await tester.pump();

    expect(find.text('You have no counter yet, please add a Counter.'),
        findsOneWidget);
    //Add counter
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1000000000002'), findsOneWidget);

    //Add an other counter
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1000000000002'), findsOneWidget);
    expect(find.text('1000000000003'), findsOneWidget);
  });

  testWidgets('Increment and decrement counter', (tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    //expect to find one counter in the list
    expect(find.byType(CounterListTile), findsOneWidget);
    //expect to see counter id
    expect(find.text('1000000000001'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    //Increment
    await tester.tap(find.byWidgetPredicate((widget) {
      return widget is CounterActionButton && widget.iconData == Icons.add;
    }));

    await tester.pump(Duration(seconds: 1));
    expect(find.text('1000000000001'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    //Decrement
    await tester.tap(find.byWidgetPredicate((widget) {
      return widget is CounterActionButton && widget.iconData == Icons.remove;
    }));

    await tester.pump(Duration(seconds: 1));
    expect(find.text('1000000000001'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
