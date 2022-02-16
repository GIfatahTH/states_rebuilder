import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/blocs/sign_form_bloc.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);
  static final routeName = '/AuthPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: OnReactive(
          () => AuthFormWidget(),
        ),
      ),
    );
  }
}

class AuthFormWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _i18n = i18n.of(context);
    return OnFormBuilder(
      listenTo: signFormBloc.form,
      builder: () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            key: Key('__EmailField__'),
            controller: signFormBloc.email.controller,
            focusNode: signFormBloc.email.focusNode,
            decoration: InputDecoration(
              icon: Icon(Icons.email),
              labelText: _i18n.email,
              errorText: signFormBloc.email.error,
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onSubmitted: (_) {
              signFormBloc.password.focusNode.requestFocus();
            },
          ),
          TextField(
            key: Key('__PasswordField__'),
            controller: signFormBloc.password.controller,
            focusNode: signFormBloc.password.focusNode,
            decoration: InputDecoration(
              icon: Icon(Icons.lock),
              labelText: _i18n.password,
              errorText: signFormBloc.password.error,
            ),
            obscureText: true,
            autocorrect: false,
            onSubmitted: (_) {
              if (signFormBloc.isRegister.state) {
                signFormBloc.confirmPassword.focusNode.requestFocus();
              } else {
                signFormBloc.form.submitFocusNode.requestFocus();
              }
            },
          ),
          if (signFormBloc.isRegister.state)
            TextField(
              key: Key('__ConfirmPasswordField__'),
              controller: signFormBloc.confirmPassword.controller,
              focusNode: signFormBloc.confirmPassword.focusNode,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: _i18n.confirmPassword,
                errorText: signFormBloc.confirmPassword.error,
              ),
              obscureText: true,
              autocorrect: false,
              onSubmitted: (_) {
                signFormBloc.form.submitFocusNode.requestFocus();
              },
            ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Checkbox(
                value: signFormBloc.isRegister.state,
                onChanged: (value) {
                  signFormBloc.isRegister.state = value!;
                },
              ),
              Text(_i18n.doNotHaveAnAccount)
            ],
          ),
          OnFormSubmissionBuilder(
            listenTo: signFormBloc.form,
            onSubmitting: () => const Center(
              child: CircularProgressIndicator(),
            ),
            child: ElevatedButton(
              focusNode: signFormBloc.form.submitFocusNode,
              child: signFormBloc.isRegister.state
                  ? Text(_i18n.signUp)
                  : Text(_i18n.signIn),
              onPressed: () {
                signFormBloc.form.submit();
              },
            ),
          ),
        ],
      ),
    );
  }
}
