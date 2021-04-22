import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/rm.dart';
import 'package:states_rebuilder/src/common/logger.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  StatesRebuilerLogger.isTestMode = true;
  testWidgets(
    'No Circular dependence even if the injected model is used in its creator',
    (tester) async {
      //Will not circle because the default null state is inferred
      expect(x.state, 0);
      // expect(() => arrayWithoutNullState.state, throwsArgumentError);
      // dynamic err;
      // try {
      //   //throw because null state is not defined
      //   arrayWithoutNullState.state;
      // } catch (e) {
      //   err = e;
      // }
      // expect(err, isA<ArgumentError>());

      //Will not circle because the default null state is defined
      expect(arrayWithNullState.state, []);
    },
  );
  testWidgets(
    'No Circular dependence even if y is called in the creator of z '
    'and z  called in the creator of y',
    (tester) async {
      //will not throw
      expect(y1.state, 0);
      expect(y2.state, 0);
    },
  );

  // testWidgets(
  //   'Circular dependence z1 depends on z2 and z2 depends on z1',
  //   (tester) async {
  //     //will not throw
  //     expect(()=>z1, throws);
  //     expect(z1.state, 0);
  //   },
  // );
}

final x = RM.inject<int>(() => x.state, initialState: 0);
final arrayWithoutNullState =
    RM.inject<List>(() => arrayWithoutNullState.state);
final arrayWithNullState =
    RM.inject<List>(() => arrayWithNullState.state, initialState: []);
//
final y1 = RM.inject<int?>(() => y2.state, initialState: 0);
final y2 = RM.inject<int?>(() => y1.state, initialState: 0);

//

final z1 = RM.inject<int>(
  () => z2.state,
  dependsOn: DependsOn({z2}),
);
final z2 = RM.inject<int>(
  () => z1.state,
  dependsOn: DependsOn({z1}),
);
