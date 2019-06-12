import 'package:counter_app/states_rebuilder_basic_example/blocs/counter_bloc.dart';
import 'package:counter_app/states_rebuilder_basic_example/pages/first_alternative.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('Counters increments', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(Injector(
        models: [() => CounterBloc()],
        builder: (_, __) => MaterialApp(
              home: FirstAlternative(),
            )));

    // Verify that counter1 starts at 0.
    expect(find.text('0'), findsNWidgets(1));
    expect(find.text('1'), findsNWidgets(0));

    // Call increment1 and trigger a frame.
    // this is the first alternative

    Injector.get<CounterBloc>().increment1();
    await tester.pump();

    // Verify that only counter1 has incremented.
    expect(find.text('0'), findsNWidgets(0));
    expect(find.text('1'), findsNWidgets(1));
  });
}
