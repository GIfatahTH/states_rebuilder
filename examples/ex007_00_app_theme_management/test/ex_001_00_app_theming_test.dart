import 'package:ex007_00_app_theme_management/ex_001_00_app_theming.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
  });
}
