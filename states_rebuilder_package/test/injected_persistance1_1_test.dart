import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/common/logger.dart';

void main() async {
  StatesRebuilerLogger.isTestMode = true;
  testWidgets('throw if not localStorage provider is given', (tester) async {
    // var counter = RM.inject<int>(
    //   () => 0,
    //   persist: () => PersistState(
    //     key: 'counter',
    //     catchPersistError: true,
    //   ),
    // );

    // expect(
    //   () {
    //     try {
    //       counter.state;
    //     } catch (e) {}
    //   },
    //   throwsAssertionError,
    // );
  });
}
