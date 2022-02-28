import 'package:ex005_00_crud_operations/ex_003_infinite_scroll_list/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });
}
