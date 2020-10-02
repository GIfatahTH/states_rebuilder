import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class StateLess extends StatelessWidget {
  const StateLess();
  @override
  Widget build(BuildContext context) {
    print('Stateless widget');
    return Container();
  }
}

// *********************************

class StateFul extends StatefulWidget {
  const StateFul();
  @override
  _StateFulState createState() => _StateFulState();
}

class _StateFulState extends State<StateFul> {
  @override
  Widget build(BuildContext context) {
    print('Stateful widget');

    return Container();
  }
}

bool _hasKey = false;
final counter = RM.inject(() => 0);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return counter.rebuilder(
      () => MaterialApp(
        key: _hasKey ? UniqueKey() : null,
        home: Scaffold(
          body: Column(
            children: [
              const StateLess(),
              const StateFul(),
            ],
          ),
        ),
        navigatorKey: RM.navigate.navigatorKey,
      ),
    );
  }
}

void main() {
  testWidgets('without key', (tester) async {
    _hasKey = false;
    await tester.pumpWidget(App());
    print('*' * 10);
    counter.state++;
    await tester.pump();
  });
  testWidgets('with key', (tester) async {
    _hasKey = true;
    await tester.pumpWidget(App());
    print('*' * 10);
    counter.state++;
    await tester.pump();
  });
}
