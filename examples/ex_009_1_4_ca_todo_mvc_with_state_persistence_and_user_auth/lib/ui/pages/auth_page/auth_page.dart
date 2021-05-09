import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/service/exceptions/auth_exception.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/common/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../data_source/firebase_auth_repository.dart';
import '../../../domain/common/extensions.dart';
import '../../../domain/entities/user.dart';
import '../../../ui/exceptions/error_handler.dart';

part 'injected_user.dart';

final _email = RM.injectTextEditing(
  validator: (email) {
    if (!_emailRegExp.hasMatch(email!)) {
      return i18n.state.enterValidEmail;
    }
  },
);
final _password = RM.injectTextEditing(
  validateOnTyping: true,
  validator: (password) {
    if (!_passwordRegExp.hasMatch(password!)) {
      return i18n.state.enterValidPassword;
    }
  },
);

final _confirmPassword = RM.injectTextEditing(
  validateOnTyping: true,
  validator: (value) {
    if (_password.text != value) {
      return 'Passwords do not match';
    }
  },
);
final _isRegister = false.inj();

final _form = RM.injectForm(
  submit: () async {
    if (_isRegister.state) {
      await user.auth.signUp(
        (_) => UserParam(email: _email.text, password: _password.text),
      );
    } else {
      await user.auth.signIn(
        (_) => UserParam(
          email: _email.text,
          password: _password.text,
        ),
      );
    }
    //After server validation
    switch (user.error.runtimeType) {
      case EmailException:
        _email.error = user.error.message;
        break;
      case PasswordException:
        _password.error = user.error.message;
        break;
      default:
    }
  },
);

final RegExp _passwordRegExp = RegExp(
  r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
);
final RegExp _emailRegExp = RegExp(
  r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
);

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);
  static final routeName = '/AuthPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: On(
          () => AuthFormWidget(),
        ).listenTo(_isRegister),
      ),
    );
  }
}

class AuthFormWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _i18n = i18n.of(context);
    return On.form(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            key: Key('__EmailField__'),
            controller: _email.controller,
            focusNode: _email.focusNode,
            decoration: InputDecoration(
              icon: Icon(Icons.email),
              labelText: _i18n.email,
              errorText: _email.error,
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onSubmitted: (_) {
              _password.focusNode.requestFocus();
            },
          ),
          TextField(
            key: Key('__PasswordField__'),
            controller: _password.controller,
            focusNode: _password.focusNode,
            decoration: InputDecoration(
              icon: Icon(Icons.lock),
              labelText: _i18n.password,
              errorText: _password.error,
            ),
            obscureText: true,
            autocorrect: false,
            onSubmitted: (_) {
              if (_isRegister.state) {
                _confirmPassword.focusNode.requestFocus();
              } else {
                _form.submitFocusNode.requestFocus();
              }
            },
          ),
          if (_isRegister.state)
            TextField(
              key: Key('__ConfirmPasswordField__'),
              controller: _confirmPassword.controller,
              focusNode: _confirmPassword.focusNode,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: _i18n.confirmPassword,
                errorText: _confirmPassword.error,
              ),
              obscureText: true,
              autocorrect: false,
              onSubmitted: (_) {
                _form.submitFocusNode.requestFocus();
              },
            ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Checkbox(
                value: _isRegister.state,
                onChanged: (value) {
                  _isRegister.state = value!;
                },
              ),
              Text(_i18n.doNotHaveAnAccount)
            ],
          ),
          On.formSubmission(
            onSubmitting: () => const Center(
              child: CircularProgressIndicator(),
            ),
            child: ElevatedButton(
              focusNode: _form.submitFocusNode,
              child:
                  _isRegister.state ? Text(_i18n.signUp) : Text(_i18n.signIn),
              onPressed: _form.submit,
            ),
          ).listenTo(_form),
        ],
      ),
    ).listenTo(_form);
  }
}
