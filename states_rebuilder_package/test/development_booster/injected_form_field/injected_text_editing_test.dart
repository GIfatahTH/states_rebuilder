// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_const_constructors, body_might_complete_normally_nullable
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/scr/development_booster/injected_form_field/injected_text_editing.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  final InjectedTextEditing textEditing = RM.injectTextEditing(text: 'text');

  testWidgets(
    'WHEN an injected text editing is initialized with a non empty string'
    'THEN the the TextField is pre-filled with that string',
    (tester) async {
      final widget = MaterialApp(
        home: Material(
          child: TextField(
            controller: textEditing.controller,
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('text'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'text');
      //
    },
  );

  testWidgets(
    'Listen to the injected text editing',
    (tester) async {
      final widget = MaterialApp(
        home: Material(
          child: Column(
            children: [
              TextField(
                controller: textEditing.controller,
              ),
              OnBuilder(
                  listenTo: textEditing,
                  builder: () {
                    return Text(textEditing.text);
                  }),
              OnBuilder(
                  listenTo: textEditing,
                  builder: () {
                    return Text(textEditing.selection.end.toString());
                  }),
              OnBuilder(
                  listenTo: textEditing,
                  builder: () {
                    return Text(textEditing.composing.toString());
                  }),
            ],
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('text'), findsNWidgets(2));
      // expect(textEditing.selection.toString(),
      //     'TextSelection(baseOffset: -1, extentOffset: -1, affinity: TextAffinity.downstream, isDirectional: false)');
      // expect(textEditing.composing.toString(), 'TextRange(start: -1, end: -1)');
      expect(find.text('-1'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'new text');

      await tester.pump();
      expect(find.text('new text'), findsNWidgets(2));
      expect(find.text('8'), findsOneWidget);
      expect(textEditing.composing.toString(), 'TextRange(start: -1, end: -1)');
    },
  );

  testWidgets(
    'WHEN validator is define'
    'THEN input is validated',
    (tester) async {
      final textEditing = RM.injectTextEditing(
        validators: [
          (val) {
            if (val?.contains('@') != true) {
              return 'Must contain @';
            }
          }
        ],
      );

      final widget = MaterialApp(
        home: Material(
          child: OnBuilder(
            listenTo: textEditing,
            builder: () => TextField(
              controller: textEditing.controller,
              decoration: InputDecoration(
                errorText: textEditing.error,
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(widget);

      expect(find.text('Must contain @'), findsNothing);
      await tester.enterText(find.byType(TextField), 'new text');
      await tester.pump();
      expect(find.text('Must contain @'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'new text@');
      await tester.pump();
      expect(find.text('Must contain @'), findsNothing);
      await tester.enterText(find.byType(TextField), 'new text');
      await tester.pump();
      expect(find.text('Must contain @'), findsOneWidget);
      textEditing.error = null;
      await tester.pump();
      expect(find.text('Must contain @'), findsNothing);
    },
  );

  final InjectedForm form = RM.injectForm();
  final name = RM.injectTextEditing(
    validators: [(v) => v!.length > 3 ? null : 'Name Error'],
  );
  final email = RM.injectTextEditing(
    validators: [(v) => v!.length > 3 ? 'Email Error' : null],
  );
  testWidgets(
    'WHEN InjectedForm is used'
    'AND WHEN autovalidateMode = AutovalidateMode.disabled (the default)'
    'THEN the fields are validate manually by calling form.validate'
    'AND check form.isValid works',
    (tester) async {
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  TextField(
                    key: Key('Name'),
                    controller: name.controller,
                    decoration: InputDecoration(errorText: name.error),
                  ),
                  TextField(
                    key: Key('Email'),
                    controller: email.controller,
                    decoration: InputDecoration(errorText: email.error),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('Name Error'), findsNothing);
      expect(find.text('Email Error'), findsNothing);
      await tester.enterText(find.byKey(Key('Name')), 'na');
      await tester.enterText(find.byKey(Key('Email')), 'em');
      await tester.pump();
      expect(find.text('Name Error'), findsNothing);
      expect(find.text('Email Error'), findsNothing);
      expect(form.isValid, false);
      form.validate();
      await tester.pump();
      expect(find.text('Name Error'), findsOneWidget);
      expect(find.text('Email Error'), findsNothing);
      expect(form.isValid, false);

      //
      await tester.enterText(find.byKey(Key('Name')), 'name');
      await tester.enterText(find.byKey(Key('Email')), 'email');
      await tester.pump();
      expect(find.text('Name Error'), findsOneWidget);
      expect(find.text('Email Error'), findsNothing);
      form.validate();
      await tester.pump();
      expect(find.text('Name Error'), findsNothing);
      expect(find.text('Email Error'), findsOneWidget);
      expect(form.isValid, false);
      form.reset();
      await tester.pump();
      expect(find.text('Name Error'), findsNothing);
      expect(find.text('Email Error'), findsNothing);
      expect(form.isValid, false);
    },
  );

  testWidgets(
    'WHEN InjectedForm is used'
    'AND WHEN autovalidateMode = AutovalidateMode.always '
    'THEN the fields are validate always validated'
    'AND check form.reset works',
    (tester) async {
      final form = RM.injectForm(
        autovalidateMode: AutovalidateMode.always,
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  TextField(
                    key: Key('Name'),
                    controller: name.controller,
                    decoration: InputDecoration(errorText: name.error),
                  ),
                  TextField(
                    key: Key('Email'),
                    controller: email.controller,
                    decoration: InputDecoration(errorText: email.error),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump(); //add frame
      expect(find.text('Name Error'), findsOneWidget);
      expect(find.text('Email Error'), findsNothing);
      await tester.enterText(find.byKey(Key('Name')), 'na');
      await tester.enterText(find.byKey(Key('Email')), 'em');
      await tester.pump();
      expect(find.text('Name Error'), findsOneWidget);
      expect(find.text('Email Error'), findsNothing);

      //
      await tester.enterText(find.byKey(Key('Name')), 'name');
      await tester.enterText(find.byKey(Key('Email')), 'email');
      await tester.pump();
      expect(find.text('Name Error'), findsNothing);
      expect(find.text('Email Error'), findsOneWidget);

      form.reset();
      await tester.pump();
      expect(name.text, '');
      expect(email.text, '');
      expect(find.text('Name Error'), findsOneWidget);
      expect(find.text('Email Error'), findsNothing);
      expect(form.isValid, false);
    },
  );

  testWidgets(
    'WHEN InjectedForm is used'
    'AND WHEN autovalidateMode = AutovalidateMode.onUserInteraction '
    'THEN the fields are validate on user interaction',
    (tester) async {
      final form = RM.injectForm(
        autovalidateMode: AutovalidateMode.onUserInteraction,
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  TextField(
                    key: Key('Name'),
                    controller: name.controller,
                    decoration: InputDecoration(errorText: name.error),
                  ),
                  TextField(
                    key: Key('Email'),
                    controller: email.controller,
                    decoration: InputDecoration(errorText: email.error),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump(); //add frame
      expect(find.text('Name Error'), findsNothing);
      expect(find.text('Email Error'), findsNothing);
      await tester.enterText(find.byKey(Key('Name')), 'na');
      await tester.enterText(find.byKey(Key('Email')), 'em');
      await tester.pump();
      expect(find.text('Name Error'), findsOneWidget);
      expect(find.text('Email Error'), findsNothing);

      //
      await tester.enterText(find.byKey(Key('Name')), 'name');
      await tester.enterText(find.byKey(Key('Email')), 'email');
      await tester.pump();
      expect(find.text('Name Error'), findsNothing);
      expect(find.text('Email Error'), findsOneWidget);
      form.reset();
      await tester.pump();
      expect(find.text('Name Error'), findsNothing);
      expect(find.text('Email Error'), findsNothing);
      expect(form.isValid, false);
    },
  );

  testWidgets(
    'WHEN autoDispose is set to false'
    'THEN the injected text editing is keeps its value',
    (tester) async {
      final name = RM.injectTextEditing(
        autoDispose: false,
      );

      final switcher = true.inj();

      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return OnBuilder(
                  listenTo: switcher,
                  builder: () {
                    if (switcher.state) {
                      return Column(
                        children: [
                          TextField(
                            key: Key('Name'),
                            controller: name.controller,
                            decoration: InputDecoration(errorText: name.error),
                          ),
                          TextField(
                            key: Key('Email'),
                            controller: email.controller,
                            decoration: InputDecoration(errorText: email.error),
                          ),
                        ],
                      );
                    }
                    return Container();
                  });
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(name.text, '');
      expect(email.text, '');
      await tester.enterText(find.byKey(Key('Name')), 'name');
      await tester.enterText(find.byKey(Key('Email')), 'email');
      await tester.pump();
      expect(name.text, 'name');
      expect(email.text, 'email');
      expect(find.text('name'), findsOneWidget);
      expect(find.text('email'), findsOneWidget);
      //
      switcher.toggle();
      await tester.pump();
      switcher.toggle();
      await tester.pump();
      expect(name.text, 'name');
      expect(email.text, '');
      expect(find.text('name'), findsOneWidget);
      expect(find.text('email'), findsNothing);
    },
  );
  testWidgets(
    'WHEN autoDispose is false'
    'THEN controller is preserved'
    'CASE TextField with no form nor listeners',
    (tester) async {
      final name = RM.injectTextEditing(
        autoDispose: false,
      );
      final email = RM.injectTextEditing();

      final switcher = true.inj();

      final widget = MaterialApp(
        home: Scaffold(
          body: OnBuilder(
              listenTo: switcher,
              builder: () {
                if (switcher.state) {
                  return Column(
                    children: [
                      TextField(
                        key: Key('Name'),
                        controller: name.controller,
                        decoration: InputDecoration(errorText: name.error),
                      ),
                      TextField(
                        key: Key('Email'),
                        controller: email.controller,
                        decoration: InputDecoration(errorText: email.error),
                      ),
                    ],
                  );
                }
                return Container();
              }),
        ),
      );
      await tester.pumpWidget(widget);
      expect(name.text, '');
      expect(email.text, '');
      await tester.enterText(find.byKey(Key('Name')), 'name');
      await tester.enterText(find.byKey(Key('Email')), 'email');
      await tester.pump();
      expect(name.text, 'name');
      expect(email.text, 'email');
      expect(find.text('name'), findsOneWidget);
      expect(find.text('email'), findsOneWidget);
      //
      switcher.toggle();
      await tester.pump();
      switcher.toggle();
      await tester.pump();
      expect(name.text, 'name');
      expect(email.text, '');
      expect(find.text('name'), findsOneWidget);
      expect(find.text('email'), findsNothing);
    },
  );

  testWidgets(
    'WHEN autoDispose is true (default)'
    'AND WHEN injectedEditing controller has no widget listener'
    'THEN it is not disposed if the controller is linked to at least one textField',
    (tester) async {
      final name = RM.injectTextEditing(
        autoDispose: false,
      );

      final switcher = true.inj();

      final widget = MaterialApp(
        home: Scaffold(
          body: OnBuilder(
              listenTo: switcher,
              builder: () {
                return Column(
                  children: [
                    if (switcher.state)
                      TextField(
                        key: Key('Name'),
                        controller: name.controller,
                        decoration: InputDecoration(errorText: name.error),
                      )
                    else
                      Container(),
                    TextField(
                      controller: name.controller,
                      decoration: InputDecoration(errorText: email.error),
                    ),
                  ],
                );
              }),
        ),
      );
      await tester.pumpWidget(widget);
      expect(name.text, '');
      await tester.enterText(find.byKey(Key('Name')), 'name');
      await tester.pump();
      expect(name.text, 'name');
      expect(find.text('name'), findsNWidgets(2));
      //
      switcher.toggle();
      await tester.pump();
      expect(find.text('name'), findsNWidgets(1));

      switcher.toggle();
      await tester.pump();
      expect(name.text, 'name');
      expect(find.text('name'), findsNWidgets(2));
    },
  );

  testWidgets(
    'focusNode works',
    (tester) async {
      final name = RM.injectTextEditing(
        autoDispose: false,
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  TextField(
                    key: Key('Name'),
                    controller: name.controller,
                    focusNode: name.focusNode,
                    decoration: InputDecoration(errorText: name.error),
                  ),
                  TextField(
                    key: Key('Email'),
                    controller: email.controller,
                    focusNode: email.focusNode,
                    decoration: InputDecoration(errorText: email.error),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      email.focusNode.requestFocus();
      await tester.pumpAndSettle();
      name.focusNode.requestFocus();
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'WHEN Two form are defined with one has ListView builder'
    'THEN each form get the right associated TextFields',
    (tester) async {
      final form1 = RM.injectForm(
        autovalidateMode: AutovalidateMode.always,
      );
      final form2 = RM.injectForm(
        autovalidateMode: AutovalidateMode.always,
      );

      final textField1 = RM.injectTextEditing(
        validators: [(_) => 'TextField1 Error'],
      );
      final textField2 = RM.injectTextEditing(
        validators: [(_) => 'TextField2 Error'],
      );
      final widget = MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (_, __) {
                    return Builder(
                      builder: (_) {
                        return OnFormBuilder(
                          listenTo: form1,
                          builder: () {
                            return TextField(
                              key: Key('TextField1'),
                              controller: textField1.controller,
                              decoration: InputDecoration(
                                errorText: textField1.error,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              OnFormBuilder(
                listenTo: form2,
                builder: () => TextField(
                  key: Key('TextField2'),
                  controller: textField2.controller,
                  decoration: InputDecoration(
                    errorText: textField2.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
      expect(find.text('TextField1 Error'), findsOneWidget);
      expect(find.text('TextField2 Error'), findsOneWidget);
      //
      await tester.enterText(find.byKey(Key('TextField1')), 'Field 1');
      await tester.enterText(find.byKey(Key('TextField2')), 'Field 2');
      await tester.pump();
      expect(find.text('Field 1'), findsOneWidget);
      expect(find.text('Field 2'), findsOneWidget);
      form1.reset();
      await tester.pump();
      expect(find.text('Field 1'), findsNothing);
      expect(find.text('Field 2'), findsOneWidget);
      form2.reset();
      await tester.pump();
      expect(find.text('Field 1'), findsNothing);
      expect(find.text('Field 2'), findsNothing);
      //
      await tester.enterText(find.byKey(Key('TextField1')), 'Field 1');
      await tester.enterText(find.byKey(Key('TextField2')), 'Field 2');
      await tester.pump();
      expect(find.text('Field 1'), findsOneWidget);
      expect(find.text('Field 2'), findsOneWidget);
      form2.reset();
      await tester.pump();
      expect(find.text('Field 1'), findsOneWidget);
      expect(find.text('Field 2'), findsNothing);
      form1.reset();
      await tester.pump();
      expect(find.text('Field 1'), findsNothing);
      expect(find.text('Field 2'), findsNothing);
    },
  );

  testWidgets(
    'On.formSubmission widget and side effects work',
    (tester) async {
      final name = RM.injectTextEditing(
        validateOnLoseFocus: false,
      );
      final email = RM.injectTextEditing(
        validateOnTyping: false,
      );
      String submitMessage = '';
      String? serverError = 'Server Error';
      late void Function() refresher;
      final form = RM.injectForm(
        // autoFocusOnFirstError: false,
        submit: () async {
          await Future.delayed(Duration(seconds: 1));
          email.error = 'Email Server Error';
        },
        submissionSideEffects: SideEffects.onOrElse(
          onWaiting: () => submitMessage = 'Submitting...',
          orElse: (_) => submitMessage = 'Submitted',
        ),
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              form.rebuild.onForm(
                () {
                  return Column(
                    children: [
                      TextField(
                        key: Key('Name'),
                        controller: name.controller,
                        focusNode: name.focusNode,
                        decoration: InputDecoration(errorText: name.error),
                      ),
                      TextField(
                        key: Key('Email'),
                        controller: email.controller,
                        focusNode: email.focusNode,
                        decoration: InputDecoration(errorText: email.error),
                      ),
                      form.rebuild.onFormSubmission(
                        onSubmitting: () => Text('Submitting...'),
                        onSubmissionError: (error, ref) {
                          refresher = ref;
                          return Text(error);
                        },
                        child: ElevatedButton(
                          onPressed: () {
                            form.submit();
                          },
                          child: Text('Submit1'),
                        ),
                      ),
                    ],
                  );
                },
              ),
              OnFormSubmissionBuilder(
                listenTo: form,
                onSubmitting: () => Text('Submitting...'),
                child: ElevatedButton(
                  onPressed: () {
                    form.submit(
                      () async {
                        await Future.delayed(Duration(seconds: 1));
                        if (serverError != null) throw serverError;
                      },
                    );
                  },
                  child: Text('Submit2'),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(submitMessage, '');
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      //
      await tester.tap(find.text('Submit1'));
      await tester.pump();
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsNothing);
      expect(find.text('Submit2'), findsNothing);
      expect(submitMessage, 'Submitting...');
      expect(find.text('Submitting...'), findsNWidgets(2));

      await tester.pump(Duration(seconds: 1));
      expect(find.text('Email Server Error'), findsOneWidget);
      expect(find.text('Submit1'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      expect(submitMessage, 'Submitted');
      expect(find.text('Submitting...'), findsNothing);
      //
      await tester.tap(find.text('Submit2'));
      await tester.pump();
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsNothing);
      expect(find.text('Submit2'), findsNothing);
      expect(submitMessage, 'Submitting...');
      expect(find.text('Submitting...'), findsNWidgets(2));

      //
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Server Error'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      expect(find.text('Submitting...'), findsNothing);
      serverError = null;
      refresher();
      await tester.pump();
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsNothing);
      expect(find.text('Submit2'), findsNothing);
      expect(submitMessage, 'Submitting...');
      expect(find.text('Submitting...'), findsNWidgets(2));

      //
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Server Error'), findsNothing);
      expect(find.text('Submit1'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      expect(find.text('Submitting...'), findsNothing);
      //
      await tester.enterText(find.byKey(Key('Email')), 'text');
      await tester.pump();
      refresher();
      await tester.pump();
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsNothing);
      expect(find.text('Submit2'), findsNothing);
      expect(submitMessage, 'Submitting...');
      expect(find.text('Submitting...'), findsNWidgets(2));

      //
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Server Error'), findsNothing);
      expect(find.text('Submit1'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      expect(find.text('Submitting...'), findsNothing);
    },
  );

  testWidgets(
    'On.formSubmission widget and side effects work for OnFormFieldBuilder',
    (tester) async {
      final name = RM.injectFormField<String>(
        '',
        validateOnLoseFocus: false,
      );
      final email = RM.injectFormField<String>(
        '',
        validateOnLoseFocus: false,
      );
      String submitMessage = '';
      String? serverError = 'Server Error';
      late void Function() refresher;
      final form = RM.injectForm(
        // autoFocusOnFirstError: false,
        submit: () async {
          await Future.delayed(Duration(seconds: 1));
          email.error = 'Email Server Error';
        },

        submissionSideEffects: SideEffects.onOrElse(
          onWaiting: () => submitMessage = 'Submitting...',
          orElse: (_) => submitMessage = 'Submitted',
        ),
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              OnFormBuilder(
                listenTo: form,
                builder: () {
                  return Column(
                    children: [
                      OnFormFieldBuilder<String>(
                        listenTo: name,
                        builder: (value, onChanged) {
                          return TextFormField(
                            key: Key('Name'),
                            initialValue: value,
                            onChanged: onChanged,
                          );
                        },
                      ),
                      OnFormFieldBuilder<String>(
                        listenTo: email,
                        builder: (value, onChanged) {
                          return TextFormField(
                            key: Key('Email'),
                            initialValue: value,
                            onChanged: onChanged,
                          );
                        },
                      ),
                      form.rebuild.onFormSubmission(
                        onSubmitting: () => Text('Submitting...'),
                        onSubmissionError: (error, ref) {
                          refresher = ref;
                          return Text(error);
                        },
                        child: ElevatedButton(
                          onPressed: () {
                            form.submit();
                          },
                          child: Text('Submit1'),
                        ),
                      ),
                    ],
                  );
                },
              ),
              OnFormSubmissionBuilder(
                listenTo: form,
                onSubmitting: () => Text('Submitting...'),
                child: ElevatedButton(
                  onPressed: () {
                    form.submit(
                      () async {
                        await Future.delayed(Duration(seconds: 1));
                        if (serverError != null) throw serverError;
                      },
                    );
                  },
                  child: Text('Submit2'),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(submitMessage, '');
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      //
      await tester.tap(find.text('Submit1'));
      await tester.pump();
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsNothing);
      expect(find.text('Submit2'), findsNothing);
      expect(submitMessage, 'Submitting...');
      expect(find.text('Submitting...'), findsNWidgets(2));

      await tester.pump(Duration(seconds: 1));
      expect(find.text('Email Server Error'), findsOneWidget);
      expect(find.text('Submit1'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      expect(submitMessage, 'Submitted');
      expect(find.text('Submitting...'), findsNothing);
      //
      await tester.enterText(find.byKey(Key('Email')), 'text');
      await tester.tap(find.text('Submit2'));
      await tester.pump();
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsNothing);
      expect(find.text('Submit2'), findsNothing);
      expect(submitMessage, 'Submitting...');
      expect(find.text('Submitting...'), findsNWidgets(2));

      //
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Server Error'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      expect(find.text('Submitting...'), findsNothing);
      serverError = null;
      refresher();
      await tester.pump();
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsNothing);
      expect(find.text('Submit2'), findsNothing);
      expect(submitMessage, 'Submitting...');
      expect(find.text('Submitting...'), findsNWidgets(2));

      //
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Server Error'), findsNothing);
      expect(find.text('Submit1'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      expect(find.text('Submitting...'), findsNothing);
    },
  );

  testWidgets(
    'OnFormBuilder and OnFormSubmissionBuilder ',
    (tester) async {
      final name = RM.injectTextEditing(
        validateOnLoseFocus: false,
      );
      final email = RM.injectTextEditing(
        validateOnTyping: false,
      );
      String submitMessage = '';
      String? serverError = 'Server Error';
      late void Function() refresher;
      final form = RM.injectForm(
        // autoFocusOnFirstError: false,
        submit: () async {
          await Future.delayed(Duration(seconds: 1));
          email.error = 'Email Server Error';
        },
        // submissionSideEffects: SideEffects.onOrElse(
        //   onWaiting: () => submitMessage = 'Submitting...',
        //   orElse: (_) => submitMessage = 'Submitted',
        // ),
        submissionSideEffects: SideEffects(
          initState: () {},
          dispose: () {},
          onAfterBuild: () {},
        ),
        onSubmitting: () => submitMessage = 'Submitting...',
        onSubmitted: () => submitMessage = 'Submitted',
      );

      final widget = MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              OnFormBuilder(
                listenTo: form,
                builder: () {
                  return Column(
                    children: [
                      TextField(
                        key: Key('Name'),
                        controller: name.controller,
                        focusNode: name.focusNode,
                        decoration: InputDecoration(errorText: name.error),
                      ),
                      TextField(
                        key: Key('Email'),
                        controller: email.controller,
                        focusNode: email.focusNode,
                        decoration: InputDecoration(errorText: email.error),
                      ),
                      OnFormSubmissionBuilder(
                        listenTo: form,
                        onSubmitting: () => Text('Submitting...'),
                        onSubmissionError: (error, ref) {
                          refresher = ref;
                          return Text(error);
                        },
                        child: ElevatedButton(
                          onPressed: () {
                            form.submit();
                          },
                          child: Text('Submit1'),
                        ),
                      ),
                    ],
                  );
                },
              ),
              OnFormSubmissionBuilder(
                listenTo: form,
                onSubmitting: () => Text('Submitting...'),
                child: ElevatedButton(
                  onPressed: () {
                    form.submit(
                      () async {
                        await Future.delayed(Duration(seconds: 1));
                        if (serverError != null) throw serverError;
                      },
                    );
                  },
                  child: Text('Submit2'),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(submitMessage, '');
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      //
      await tester.tap(find.text('Submit1'));
      await tester.pump();
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsNothing);
      expect(find.text('Submit2'), findsNothing);
      expect(submitMessage, 'Submitting...');
      expect(find.text('Submitting...'), findsNWidgets(2));

      await tester.pump(Duration(seconds: 1));
      expect(find.text('Email Server Error'), findsOneWidget);
      expect(find.text('Submit1'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      expect(submitMessage, 'Submitted');
      expect(find.text('Submitting...'), findsNothing);
      //
      await tester.enterText(find.byKey(Key('Email')), 'text');
      await tester.tap(find.text('Submit2'));
      await tester.pump();
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsNothing);
      expect(find.text('Submit2'), findsNothing);
      expect(submitMessage, 'Submitting...');
      expect(find.text('Submitting...'), findsNWidgets(2));

      //
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Server Error'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      expect(find.text('Submitting...'), findsNothing);
      serverError = null;
      refresher();
      await tester.pump();
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Submit1'), findsNothing);
      expect(find.text('Submit2'), findsNothing);
      expect(submitMessage, 'Submitting...');
      expect(find.text('Submitting...'), findsNWidgets(2));

      //
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Email Server Error'), findsNothing);
      expect(find.text('Server Error'), findsNothing);
      expect(find.text('Submit1'), findsOneWidget);
      expect(find.text('Submit2'), findsOneWidget);
      expect(find.text('Submitting...'), findsNothing);
    },
  );

  testWidgets(
    'WHEN  TextField is removed'
    'THEN it will be removed from form text fields list',
    (tester) async {
      final form = RM.injectForm();
      final password = RM.injectTextEditing(text: '12');
      final confirmPassword = RM.injectTextEditing(
        validators: [
          (text) {
            if (text != password.value) {
              return 'Password do not match';
            }
          }
        ],
      );

      final isRegister = true.inj();

      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  TextField(
                    controller: password.controller,
                  ),
                  if (isRegister.state)
                    TextField(
                      controller: confirmPassword.controller,
                    ),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(form.isValid, false);
      isRegister.toggle();
      await tester.pump();
      expect(form.isValid, true);
    },
  );

  testWidgets(
    'Test controllerWithInitialText',
    (tester) async {
      final form = RM.injectForm();
      final password = RM.injectTextEditing();

      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  TextField(
                    controller: password.controllerWithInitialText('zero'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('zero'), findsOneWidget);
      password.controller.text = 'one';
      await tester.pump();
      expect(find.text('one'), findsOneWidget);
    },
  );
  testWidgets(
    'WHEN a field is autoFocused'
    'THEN the it is assigned to the form autoFocusedNode'
    'AND it is auto validated when lost focus',
    (tester) async {
      final text = RM
          .injectTextEditing(text: '', validateOnLoseFocus: true, validators: [
        (txt) {
          if (txt!.length < 3) {
            return 'not allowed';
          }
        }
      ]);
      final form = RM.injectForm();
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return Column(
                children: [
                  OnReactive(
                    () => TextField(
                      focusNode: text.focusNode,
                      controller: text.controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        errorText: text.error,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    focusNode: form.submitFocusNode,
                    onPressed: () {},
                    child: Text('Submit'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      await tester.pump();
      expect((form as InjectedFormImp).autoFocusedNode, isNotNull);
      expect(find.text('not allowed'), findsNothing);
      form.submitFocusNode.requestFocus();
      await tester.pump();
      expect(find.text('not allowed'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '1');
      await tester.pump();
      expect(find.text('not allowed'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '12');
      await tester.pump();
      expect(find.text('not allowed'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '123');
      await tester.pump();
      expect(find.text('123'), findsOneWidget);
      //
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump();
      expect(find.text('not allowed'), findsOneWidget);
      //
      form.reset();
      await tester.pump();
      expect(find.text('not allowed'), findsNothing);
      //
      form.submitFocusNode.requestFocus();
      await tester.pump();
      expect(find.text('not allowed'), findsOneWidget);
      //
      text.reset();
      await tester.pump();
      expect(find.text('not allowed'), findsNothing);
    },
  );

  testWidgets(
    'Check TextField validation and reset without form',
    (tester) async {
      final text1 =
          RM.injectTextEditing(text: 'initial text1', validateOnTyping: false);
      final text2 = RM.injectTextEditing(text: 'initial text2', validators: [
        (txt) {
          if (txt!.length < 3) return 'not allowed';
        }
      ]);
      final widget = MaterialApp(
        home: Scaffold(
          body: OnReactive(
            () => Column(
              children: [
                Text(text1.text),
                Text(text2.text),
                TextField(
                  controller: text1.controller,
                ),
                TextField(
                  controller: text2.controller,
                  decoration: InputDecoration(
                    errorText: text2.error,
                  ),
                ),
              ],
            ),
            debugPrintWhenObserverAdd: '',
          ),
        ),
      );
      await tester.pumpWidget(widget);
      expect(find.text('initial text1'), findsNWidgets(2));
      expect(find.text('initial text2'), findsNWidgets(2));
      //
      expect(text1.isValid, true);
      await tester.enterText(find.byType(TextField).first, 'new text1');
      await tester.pump();
      expect(find.text('new text1'), findsNWidgets(2));
      expect(text1.isValid, true);
      text1.reset();
      await tester.pump();
      expect(find.text('initial text1'), findsNWidgets(2));
      expect(text1.isValid, true);
      //
      expect(text2.isValid, false);
      await tester.enterText(find.byType(TextField).last, 'ne');
      await tester.pump();
      expect(find.text('ne'), findsNWidgets(2));
      expect(find.text('not allowed'), findsOneWidget);
      expect(text2.isValid, false);
      text2.reset();
      await tester.pump();
      expect(find.text('initial text1'), findsNWidgets(2));
      expect(find.text('initial text2'), findsNWidgets(2));
      expect(text2.isValid, false);
    },
  );

  testWidgets(
    'WHEN focus changes'
    'THEN InjectedForm emits notification'
    'Using OnFormBuilder'
    'issue #226',
    (tester) async {
      final field = RM.injectTextEditing();
      final widget = MaterialApp(
        home: Scaffold(
          body: OnFormBuilder(
            listenTo: form,
            builder: () {
              return TextFormField(
                controller: field.controller,
                focusNode: field.focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: field.focusNode.hasFocus ? Colors.red : null,
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      final redWidget = find.byWidgetPredicate(
        (widget) =>
            widget is InputDecorator &&
            widget.decoration.fillColor == Colors.red,
      );
      expect(redWidget, findsNothing);
      field.focusNode.requestFocus();
      await tester.pumpAndSettle();
      expect(redWidget, findsOneWidget);
      field.focusNode.unfocus();
      await tester.pumpAndSettle();
      expect(redWidget, findsNothing);
    },
  );

  testWidgets(
    'WHEN focus changes'
    'THEN InjectedForm emits notification'
    'Using OnReactive'
    'issue #226',
    (tester) async {
      final field = RM.injectTextEditing();
      final widget = MaterialApp(
        home: Scaffold(
          body: OnReactive(
            () {
              return TextFormField(
                controller: field.controller,
                focusNode: field.focusNode,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: field.focusNode.hasFocus ? Colors.red : null,
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);
      final redWidget = find.byWidgetPredicate(
        (widget) =>
            widget is InputDecorator &&
            widget.decoration.fillColor == Colors.red,
      );
      expect(redWidget, findsNothing);
      field.focusNode.requestFocus();
      await tester.pumpAndSettle();
      expect(redWidget, findsOneWidget);
      field.focusNode.unfocus();
      await tester.pumpAndSettle();
      expect(redWidget, findsNothing);
    },
  );

  testWidgets(
    'WHEN readOnly is true,'
    'THEN the TextField is selectable, clickable but not editable',
    (tester) async {
      final field = RM.injectTextEditing(
        text: '0',
        isReadOnly: true,
      );
      final widget = MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: field.controller,
            focusNode: field.focusNode,
          ),
        ),
      );
      await tester.pumpWidget(widget);
      await tester.enterText(find.byType(TextField), '1');
      expect(find.text('0'), findsOneWidget);
      await tester.pump();
      expect(find.text('0'), findsOneWidget);
      field.focusNode.unfocus();
      await tester.pump();
      //
      field.isReadOnly = false;
      await tester.enterText(find.byType(TextField), '1');
      expect(find.text('1'), findsOneWidget);
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      field.focusNode.unfocus();
      await tester.pump();
      //
      field.isReadOnly = true;
      await tester.enterText(find.byType(TextField), '2');
      expect(find.text('1'), findsOneWidget);
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN isEnable is true,'
    'THEN the TextField is selectable, clickable but not editable',
    (tester) async {
      final field = RM.injectTextEditing(
        text: '0',
        isEnabled: false,
      );
      final widget = MaterialApp(
        home: Scaffold(
          body: OnReactive(
            () {
              return TextField(
                controller: field.controller,
                focusNode: field.focusNode,
                enabled: field.isEnabled,
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(widget);

      final isEnabled = find.byWidgetPredicate(
        (widget) => widget is InputDecorator && widget.decoration.enabled,
      );
      expect(isEnabled, findsNothing);
      //
      field.isEnabled = true;
      await tester.pump();
      expect(isEnabled, findsOneWidget);
      //
      field.isEnabled = false;
      await tester.pump();
      expect(isEnabled, findsNothing);
    },
  );

  testWidgets(
    '# issue 241',
    (tester) async {
      final pwdInj = RM.injectTextEditing(autoDispose: true); // <-

      await tester.pumpWidget(
        MaterialApp(
          home: OnReactive(
            () => Scaffold(
              appBar: AppBar(
                title: Text("wow"),
              ),
              body: Center(
                child: Column(
                  children: [
                    TextField(
                      controller: pwdInj.controller,
                    ),
                    ElevatedButton(
                      child: Text("states_rebuilder test"),
                      onPressed: () {
                        pwdInj.controller.text =
                            pwdInj.controller.text + " Really?";
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
    },
  );

  testWidgets(
    'Test is dirty',
    (tester) async {
      final form = RM.injectForm();
      final email = RM.injectTextEditing();
      final password = RM.injectTextEditing();
      final widget = OnFormBuilder(
        listenTo: form,
        builder: () {
          return Column(
            children: [
              OnBuilder(
                listenToMany: [email, password, form],
                builder: () {
                  return Text('Form is dirty: ${form.isDirty}');
                },
              ),
              TextField(
                controller: email.controller,
              ),
              TextField(
                controller: password.controller,
              ),
            ],
          );
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );
      expect(email.isDirty, false);
      expect(password.isDirty, false);
      expect(form.isDirty, false);
      //
      await tester.enterText(find.byType(TextField).first, 'text');
      await tester.pump();
      expect(email.isDirty, true);
      expect(password.isDirty, false);
      expect(form.isDirty, true);
      expect(find.text('Form is dirty: true'), findsOneWidget);
      //
      form.submit(() async {});
      await tester.pump();
      expect(email.isDirty, false);
      expect(password.isDirty, false);
      expect(form.isDirty, false);
      expect(find.text('Form is dirty: false'), findsOneWidget);
      //
      await tester.enterText(find.byType(TextField).first, 'text1');
      await tester.enterText(find.byType(TextField).last, 'text');
      await tester.pump();
      expect(email.isDirty, true);
      expect(password.isDirty, true);
      expect(form.isDirty, true);
      expect(find.text('Form is dirty: true'), findsOneWidget);
      //
      await tester.enterText(find.byType(TextField).first, 'text');
      await tester.pump();
      expect(email.isDirty, false);
      expect(password.isDirty, true);
      expect(form.isDirty, true);
      expect(find.text('Form is dirty: true'), findsOneWidget);
      //
      await tester.enterText(find.byType(TextField).last, '');
      await tester.pump();
      expect(email.isDirty, false);
      expect(password.isDirty, false);
      expect(form.isDirty, false);
      expect(find.text('Form is dirty: false'), findsOneWidget);
    },
  );
}
