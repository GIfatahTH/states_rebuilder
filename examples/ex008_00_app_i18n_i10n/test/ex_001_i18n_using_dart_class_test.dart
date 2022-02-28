// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ex008_00_app_i18n_i10n/ex_001_i18n_using_dart_class/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('__', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
  });
}
