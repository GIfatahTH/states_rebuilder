import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/common/logger.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() async {
  StatesRebuilerLogger.isTestMode = true;
  testWidgets('throw if not localStorage provider is given', (tester) async {
    expect(
      () {
        RM.inject<int>(
          () => 0,
          persist: () => PersistState(
            key: 'counter',
            catchPersistError: true,
          ),
        );
      },
      throwsAssertionError,
    );
  });

  testWidgets(
    'test toString',
    (tester) async {
      final store = await RM.storageInitializerMock();
      expect(store.toString(), '{}');
    },
  );
}
