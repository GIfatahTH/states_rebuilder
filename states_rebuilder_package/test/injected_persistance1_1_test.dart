import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  StatesRebuilerLogger.isTestMode = true;
  testWidgets('throw if not localStorage provider is given', (tester) async {
    var counter = RM.inject<int>(
      () => 0,
      persist: () => PersistState(
        key: 'counter',
        catchPersistError: true,
      ),
    );

    expect(() async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            counter.state.toString(),
          ),
        ),
      );
    }, throwsAssertionError);
  });
}
