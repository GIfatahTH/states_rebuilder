// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/src/injected/injected_text_editing/injected_text_editing.dart';
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
      expect((form as InjectedFormImp).autoFocusedNode, checkBox.focusNode);
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

  testWidgets(
    'WHEN readOnly is true,'
    'THEN the field is selectable, clickable but not editable',
    (tester) async {
      final field = RM.injectFormField(
        true,
        isReadOnly: true,
      );
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormFieldBuilder<bool>(
            listenTo: field,
            builder: (value, onChanged) {
              return Checkbox(value: value, onChanged: onChanged);
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      final isChecked = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      );
      //
      expect(isChecked, findsOneWidget);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(isChecked, findsOneWidget);
      //
      field.isReadOnly = false;
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(isChecked, findsNothing);
      //
      field.isReadOnly = true;
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(isChecked, findsNothing);
    },
  );

  testWidgets(
    'WHEN enabled is false,'
    'THEN the field is disabled',
    (tester) async {
      final field = RM.injectFormField(
        true,
        isEnabled: false,
      );
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormFieldBuilder<bool>(
            listenTo: field,
            builder: (value, onChanged) {
              return Checkbox(value: value, onChanged: onChanged);
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      final isChecked = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      );
      final isEnabled = find.byWidgetPredicate(
        (widget) => widget is InputDecorator && widget.decoration.enabled,
      );
      //
      expect(isEnabled, findsNothing);
      expect(isChecked, findsOneWidget);
      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.pump();
      expect(isChecked, findsOneWidget);
      //
      field.isEnabled = true;
      await tester.pump();
      expect(isEnabled, findsOneWidget);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(isChecked, findsNothing);
      //
      field.isEnabled = false;
      await tester.pump();
      expect(isEnabled, findsNothing);
      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.pump();
      expect(isChecked, findsNothing);
    },
  );

  testWidgets(
    'WHEN enabled is false,'
    'THEN the field is not focusable',
    (tester) async {
      final field = RM.injectFormField(
        true,
        isEnabled: false,
      );
      final focusNode1 = FocusNode();
      final focusNode2 = FocusNode();
      final widget = MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextField(
                autofocus: true,
                focusNode: focusNode1,
              ),
              OnFormFieldBuilder<bool>(
                listenTo: field,
                builder: (value, onChanged) {
                  return CheckboxListTile(
                    value: value,
                    onChanged: onChanged,
                    title: Text(''),
                  );
                },
              ),
              TextField(
                focusNode: focusNode2,
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(focusNode1.hasFocus, true);
      expect(focusNode2.hasFocus, false);

      focusNode1.nextFocus();
      await tester.pump();
      expect(focusNode1.hasFocus, false);
      expect(focusNode2.hasFocus, true);
      //
      focusNode1.requestFocus();
      await tester.pump();
      expect(focusNode1.hasFocus, true);
      expect(focusNode2.hasFocus, false);
      field.isEnabled = true;
      //
      focusNode1.nextFocus();
      await tester.pump();
      expect(focusNode1.hasFocus, false);
      expect(focusNode2.hasFocus, false);
    },
  );

  testWidgets(
    'WHEN isEnabledRM of the form is defined'
    'THEN all form child  isEnable will be overridden',
    (tester) async {
      final form = RM.injectForm();
      final text = RM.injectTextEditing();
      final check = RM.injectFormField(true);
      final isEnabled = RM.inject<bool?>(() => false);
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            isEnabledRM: isEnabled,
            builder: () {
              return Column(
                children: [
                  TextField(
                    controller: text.controller,
                    enabled: text.isEnabled,
                    readOnly: text.isReadOnly,
                  ),
                  OnFormFieldBuilder<bool>(
                    listenTo: check,
                    builder: (val, onChanged) {
                      return CheckboxListTile(
                        value: val,
                        onChanged: onChanged,
                        title: Text(''),
                      );
                    },
                  )
                ],
              );
            },
          ),
        ),
      );
      final _isEnabled = find.byWidgetPredicate(
        (widget) => widget is InputDecorator && widget.decoration.enabled,
      );

      await tester.pumpWidget(widget);
      expect(_isEnabled, findsNWidgets(0));
      expect(text.isEnabled, false);
      isEnabled.state = true;
      await tester.pump();
      expect(_isEnabled, findsNWidgets(2));
      expect(text.isEnabled, true);
      //
      isEnabled.state = false;
      await tester.pump();
      expect(_isEnabled, findsNWidgets(0));
      expect(text.isEnabled, false);
      //
      isEnabled.state = null;
      await tester.pump();
      expect(_isEnabled, findsNWidgets(2));
      expect(text.isEnabled, true);
    },
  );

  testWidgets(
    'WHEN isReadOnlyRM of the form is defined'
    'THEN all form child  isEnable will be overridden',
    (tester) async {
      final form = RM.injectForm();
      final text = RM.injectTextEditing();
      final check = RM.injectFormField(true);
      final isReadOnly = RM.inject<bool?>(() => true);
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            isReadOnlyRM: isReadOnly,
            builder: () {
              return Column(
                children: [
                  TextField(
                    controller: text.controller,
                    enabled: text.isEnabled,
                    readOnly: text.isReadOnly,
                  ),
                  OnFormFieldBuilder<bool>(
                    listenTo: check,
                    builder: (val, onChanged) {
                      return CheckboxListTile(
                        value: val,
                        onChanged: onChanged,
                        title: Text(''),
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

      expect(text.isReadOnly, true);
      expect(check.isReadOnly, true);
      isReadOnly.state = false;
      await tester.pump();
      expect(text.isReadOnly, false);
      expect(check.isReadOnly, false);
    },
  );

  testWidgets(
    'disable input fields when form is submitting',
    (tester) async {
      final text = RM.injectTextEditing();
      final check = RM.injectFormField(true);
      final isEnabled = RM.inject<bool?>(() => true);
      final form = RM.injectForm(
        submissionSideEffects: SideEffects.onOrElse(
          onWaiting: () => isEnabled.state = false,
          orElse: (_) => isEnabled.state = true,
        ),
        submit: () => Future.delayed(1.seconds),
      );
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            isEnabledRM: isEnabled,
            builder: () {
              return Column(
                children: [
                  TextField(
                    controller: text.controller,
                    enabled: text.isEnabled,
                    readOnly: text.isReadOnly,
                  ),
                  OnFormFieldBuilder<bool>(
                    listenTo: check,
                    builder: (val, onChanged) {
                      return CheckboxListTile(
                        value: val,
                        onChanged: onChanged,
                        title: Text(''),
                      );
                    },
                  )
                ],
              );
            },
          ),
        ),
      );
      final _isEnabled = find.byWidgetPredicate(
        (widget) => widget is InputDecorator && widget.decoration.enabled,
      );

      await tester.pumpWidget(widget);
      expect(_isEnabled, findsNWidgets(2));
      expect(text.isEnabled, true);
      expect(check.isEnabled, true);
      //
      form.submit();
      await tester.pump();
      expect(_isEnabled, findsNWidgets(0));
      expect(text.isEnabled, false);
      expect(check.isEnabled, false);
      await tester.pump(500.milliseconds);
      expect(_isEnabled, findsNWidgets(0));
      expect(text.isEnabled, false);
      expect(check.isEnabled, false);
      await tester.pump(500.milliseconds);
      expect(_isEnabled, findsNWidgets(2));
      expect(text.isEnabled, true);
      expect(check.isEnabled, true);
    },
  );

  testWidgets(
    'readOnly input fields when form is submitting'
    'Case nested OnFormBuilder',
    (tester) async {
      final text = RM.injectTextEditing();
      final check = RM.injectFormField(true);
      final isReadOnly = RM.inject<bool?>(() => false);
      final form = RM.injectForm(
        submissionSideEffects: SideEffects.onOrElse(
          onWaiting: () => isReadOnly.state = true,
          orElse: (_) => isReadOnly.state = false,
        ),
        submit: () => Future.delayed(1.seconds),
      );
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  TextField(
                    controller: text.controller,
                    enabled: text.isEnabled,
                    readOnly: text.isReadOnly,
                  ),
                  OnFormBuilder(
                      listenTo: form,
                      isReadOnlyRM: isReadOnly,
                      builder: () {
                        return OnFormFieldBuilder<bool>(
                          listenTo: check,
                          builder: (val, onChanged) {
                            return CheckboxListTile(
                              value: val,
                              onChanged: onChanged,
                              title: Text(''),
                            );
                          },
                        );
                      })
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(text.isReadOnly, false);
      expect(check.isReadOnly, false);
      //
      form.submit();
      await tester.pump();
      expect(text.isReadOnly, false);
      expect(check.isReadOnly, true);
      await tester.pump(500.milliseconds);
      expect(text.isReadOnly, false);
      expect(check.isReadOnly, true);
      await tester.pump(500.milliseconds);
      expect(text.isReadOnly, false);
      expect(check.isReadOnly, false);
    },
  );
  testWidgets(
    'issue 238',
    (tester) async {
      final isCheckedField = RM.injectFormField(false, autoDispose: false);

      final widget = MaterialApp(
        navigatorKey: RM.navigate.navigatorKey,
        onGenerateRoute: RM.navigate.onGenerateRoute(
          {
            '/': (_) => Scaffold(
                  body: OnFormFieldBuilder<bool>(
                    listenTo: isCheckedField,
                    builder: (val, onChanged) {
                      return Checkbox(value: val, onChanged: onChanged);
                    },
                  ),
                ),
            '/other': (_) => Text('other: ${isCheckedField.state}'),
          },
        ),
      );

      await tester.pumpWidget(widget);
      final isChecked = find.byWidgetPredicate(
        (widget) => widget is Checkbox && widget.value == true,
      );
      expect(isChecked, findsNothing);
      //
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(isChecked, findsOneWidget);
      //
      RM.navigate.toReplacementNamed('/other');
      await tester.pumpAndSettle();
      expect(find.text('other: true'), findsOneWidget);
      //
      RM.navigate.toReplacementNamed('/');
      await tester.pumpAndSettle();
      expect(isChecked, findsOneWidget);
    },
  );
}
