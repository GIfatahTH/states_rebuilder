import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/common/logger.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  StatesRebuilerLogger.isTestMode = true;
  // testWidgets('throw if not localStorage provider is given', (tester) async {
  //   final rm = RM.inject<int>(
  //     () => 0,
  //     persist: () => PersistState(
  //       key: 'counter',
  //       catchPersistError: true,
  //     ),
  //   );
  //   expect(
  //     () {
  //       try {
  //         return rm.state;
  //       } catch (e) {}
  //     },
  //     throwsAssertionError,
  //   );
  // });

  testWidgets(
    'test toString',
    (tester) async {
      final store = await RM.storageInitializerMock();
      expect(store.toString(), '{}');
    },
  );
}
