import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'Circular dependence as the injected model depends on itself',
    (tester) async {
      expect(() => x.state, throwsAssertionError);
    },
  );
  testWidgets(
    'Circular dependence as y depends on z and z depends on y',
    (tester) async {
      expect(() => y.state, throwsAssertionError);
    },
  );
}

final x = RM.inject<int>(() => x.state);
//
final y = RM.inject<int>(() => z.state);
final z = RM.inject<int>(() => y.state);
