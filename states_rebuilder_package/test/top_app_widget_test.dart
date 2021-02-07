import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/reactive_model.dart';

void main() { 
  testWidgets(
    'throw if waiteFore is defined without onWaiting',
    (tester) async {
      expect(
          () => TopAppWidget(
                waiteFor: () => [Future.value(0)],
                builder: (_) {
                  return Container();
                },
              ),
          throwsAssertionError);
    },
  );
}
