import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/legacy/inject.dart';
import 'package:states_rebuilder/src/legacy/injector.dart';
import 'package:states_rebuilder/src/rm.dart';

import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets('Injecting simple primitive', (tester) async {
    final widget = Injector(
      inject: [Inject(() => 0)],
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: StateBuilder(
            observe: () => RM.get<int>(),
            builder: (context, rm) {
              return Text(rm!.state.toString());
            },
          ),
        );
      },
    );

    await tester.pumpWidget(widget);
    expect(find.text('0'), findsOneWidget);
    RM.get<int>().state++;
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Injecting future', (tester) async {
    final widget = Injector(
      inject: [
        Inject.future(
          () => Future.delayed(Duration(seconds: 1), () => 1),
          initialValue: 0,
        ),
      ],
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: WhenRebuilderOr(
            observe: () => RM.get<int>(),
            onWaiting: () => Text('Waiting...'),
            builder: (context, rm) {
              return Text(rm.state.toString());
            },
          ),
        );
      },
    );

    await tester.pumpWidget(widget);
    expect(find.text('Waiting...'), findsOneWidget);
    await tester.pump(Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);
  });
}
