import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'Circular dependence as the injected model depends on itself',
    (tester) async {
      //Will not circle because the default null state is inferred
      expect(x.state, 0);
      dynamic err;
      try {
        //throw because null state is not defined
        arrayWithoutNullState.state;
      } catch (e) {
        err = e;
      }
      expect(err, isA<ArgumentError>());

      //Will not circle because the default null state is defined
      expect(arrayWithNullState.state, []);
    },
  );
  testWidgets(
    'Circular dependence as y depends on z and z depends on y',
    (tester) async {
      //will not throw
      expect(y.state, 0);
    },
  );
}

final x = RM.inject<int>(() => x.state);
final arrayWithoutNullState =
    RM.inject<List>(() => arrayWithoutNullState.state);
final arrayWithNullState =
    RM.inject<List>(() => arrayWithNullState.state, initialState: []);
//
final y = RM.inject<int>(() => z.state);
final z = RM.inject<int>(() => y.state);
