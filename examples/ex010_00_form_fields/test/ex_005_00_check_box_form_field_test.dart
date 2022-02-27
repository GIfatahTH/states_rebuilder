import 'package:ex010_00_form_fields/ex_005_00_check_box_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Finder emailTextField;
  late Finder passwordTextField;
  late Finder activeLoginButton;
  setUp(
    () {
      emailTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == "Email Address",
      );

      passwordTextField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == "Password",
      );

      //active login button is that with a non null onPressed parameter
      activeLoginButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && widget.onPressed != null,
      );
    },
  );

  testWidgets('email validation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
  });
}
