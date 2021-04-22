import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../common.dart';

void main() {
  testWidgets(
    'Nullable sync state',
    (tester) async {
      final counter = RM.inject<int?>(() => null);
      expect(counter.state, null);
      counter.state = 0;
      expect(counter.state, 0);
      counter.state = null;
      expect(counter.state, null);
    },
  );

  testWidgets(
    'Nullable async state (Future)',
    (tester) async {
      final counter = RM.injectFuture<int?>(() => future(null));
      expect(counter.state, null);
      expect(counter.isWaiting, true);
      await tester.pump(Duration(seconds: 1));
      expect(counter.state, null);
      expect(counter.hasData, true);

      counter.state = 0;
      expect(counter.state, 0);
      counter.state = null;
      expect(counter.state, null);
    },
  );
}
