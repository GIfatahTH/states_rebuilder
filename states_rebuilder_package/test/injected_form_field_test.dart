import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  testWidgets(
    'Check when the field is focused and unfocused'
    'THEN the decorator get the right state',
    (tester) async {
      final form = RM.injectForm();
      final checkBox = RM.injectFormField<bool?>(null);
      bool? value;
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  OnFormFieldBuilder<bool?>(
                    listenTo: checkBox,
                    autofocus: true,
                    inputDecoration: InputDecoration(
                      hintText: 'Hint text',
                      labelText: 'Label text',
                      helperText: 'Helper text',
                    ),
                    builder: (v, onChanged) {
                      value = v;
                      return CheckboxListTile(
                        tristate: true,
                        value: v,
                        onChanged: checkBox.onChanged,
                        title: Text('Text'),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      await tester.pump();
      expect(value, null);
      expect(find.byType(InputDecorator), findsOneWidget);

      final isFocused = find.byWidgetPredicate(
        (widget) => widget is InputDecorator && widget.isFocused,
      );

      expect(isFocused, findsOneWidget);
      // expect(isCheckBoxFocused, findsOneWidget);
      expect(find.text('Label text'), findsOneWidget);
      expect(find.text('Hint text'), findsOneWidget);
      expect(find.text('Helper text'), findsOneWidget);
      //
      checkBox.focusNode.unfocus();
      await tester.pump();
      await tester.pump();
      expect(isFocused, findsNothing);
      expect(find.text('Label text'), findsOneWidget);
      expect(find.text('Hint text'), findsOneWidget);
      expect(find.text('Helper text'), findsOneWidget);
      //
      checkBox.focusNode.requestFocus();
      await tester.pump();
      expect(isFocused, findsOneWidget);
      expect(find.text('Label text'), findsOneWidget);
      expect(find.text('Hint text'), findsOneWidget);
      expect(find.text('Helper text'), findsOneWidget);
      //
      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, false);
    },
  );

  testWidgets(
    'WHEN initial value of injectedForm is null'
    'THEN the label text is displayed'
    'AND WHEN the value is set to non null'
    'THEN label and hint text '
    'THEN',
    (tester) async {
      final form = RM.injectForm();
      final checkBox = RM.injectFormField<bool?>(
        null,
        validators: [
          (value) {
            if (value == null || !value) {
              return 'You must check me';
            }
          },
        ],
      );
      bool? value;
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  OnFormFieldBuilder<bool?>(
                    listenTo: checkBox,
                    inputDecoration: InputDecoration(
                      hintText: 'Hint text',
                      labelText: 'Label text',
                      helperText: 'Helper text',
                    ),
                    builder: (v, onChanged) {
                      value = v;
                      return Checkbox(
                        tristate: true,
                        value: v,
                        onChanged: onChanged,
                      );
                    },
                  )
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(value, null);
      expect(find.byType(InputDecorator), findsOneWidget);
      final isEmptyInput = find.byWidgetPredicate(
        (widget) => widget is InputDecorator && widget.isEmpty,
      );
      final isFocused = find.byWidgetPredicate(
        (widget) => widget is InputDecorator && widget.isFocused,
      );
      expect(isEmptyInput, findsOneWidget);
      expect(isFocused, findsNothing);
      expect(find.text('Label text'), findsOneWidget);
      expect(find.text('Hint text'), findsOneWidget);
      expect(find.text('Helper text'), findsOneWidget);

      checkBox.focusNode.requestFocus();
      await tester.pump();
      expect(isEmptyInput, findsOneWidget);
      expect(isFocused, findsOneWidget);
      expect(find.text('Label text'), findsOneWidget);
      expect(find.text('Hint text'), findsOneWidget);
      expect(find.text('Helper text'), findsOneWidget);
      //
      checkBox.focusNode.unfocus();
      await tester.pump();
      expect(isEmptyInput, findsOneWidget);
      expect(isFocused, findsNothing);
      expect(find.text('Label text'), findsOneWidget);
      expect(find.text('Hint text'), findsOneWidget);
      expect(find.text('Helper text'), findsOneWidget);
      //
      checkBox.value = true;
      await tester.pump();
      expect(value, true);
      expect(isEmptyInput, findsNothing);
      expect(find.text('Label text'), findsOneWidget);
      expect(find.text('Hint text'), findsOneWidget);
      expect(find.text('Helper text'), findsOneWidget);
      //
      form.reset();
      await tester.pump();
      expect(value, null);
      expect(form.validate(), false);
      await tester.pump();
      expect(find.text('You must check me'), findsOneWidget);
      //
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(value, false);
      expect(form.validate(), false);
      //
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(value, true);
      expect(form.validate(), true);
      //Rest from the InjectedFormField (not form the form)
      checkBox.reset();
      await tester.pump();
      expect(value, null);
      expect(form.validate(), false);
      await tester.pump();
      expect(find.text('You must check me'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN autovalidateMode is always'
    'THEN the field is validated on initialization',
    (tester) async {
      final form = RM.injectForm(
        autovalidateMode: AutovalidateMode.always,
      );
      final textField = RM.injectFormField<String?>(
        null,
        validators: [
          (value) {
            if (value == null || value.isEmpty) {
              return 'Can not be empty';
            }
          },
        ],
      );
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  OnFormFieldBuilder<String?>(
                    listenTo: textField,
                    inputDecoration: InputDecoration(
                      hintText: 'Hint text',
                      labelText: 'Label text',
                      helperText: 'Helper text',
                    ),
                    builder: (value, onChanged) {
                      return TextFormField(
                        initialValue: value,
                        onChanged: onChanged,
                      );
                    },
                  )
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      await tester.pump();
      expect(find.text('Can not be empty'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'text');
      await tester.pump();
      expect(find.text('Can not be empty'), findsNothing);
    },
  );
}
