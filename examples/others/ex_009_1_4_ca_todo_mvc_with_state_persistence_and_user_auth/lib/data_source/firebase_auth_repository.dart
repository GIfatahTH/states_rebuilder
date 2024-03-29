// ignore_for_file: body_might_complete_normally_nullable

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:states_rebuilder/states_rebuilder.dart';

import '../blocs/exceptions/auth_exception.dart';
import '../domain/common/extensions.dart';
import '../domain/entities/user.dart';
import '../domain/value_object/token.dart';
import 'my_project_data.dart' as myProjectData;

//Go to https://console.firebase.google.com/project/YOUR_PROJECT_NAME/settings/general and get `webApiKey`. This will be your `webApiKey` const.
const webApiKey = myProjectData.webApiKey; //TODO Use yours

class FireBaseAuth implements IAuth<User?, UserParam> {
  @override
  Future<void> init() async {}

  @override
  Future<User?> signIn(UserParam? param) async {
    if (param == null) {
      return null;
    }
    return _authenticate(
      param.email,
      param.password,
      'verifyPassword',
    );
  }

  @override
  Future<User?> signUp(UserParam? param) async {
    if (param == null) {
      return null;
    }
    return _authenticate(
      param.email,
      param.password,
      'signupNewUser',
    );
  }

  @override
  Future<void> signOut(UserParam? param) async {}

  Future<User?> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=$webApiKey';
    try {
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        if (responseData['error']['message'] == 'INVALID_EMAIL') {
          throw EmailException.invalidEmail();
        }

        if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
          throw EmailException.emailNotFound();
        }
        if (responseData['error']['message'] == 'EMAIL_EXISTS') {
          throw EmailException.emailExists();
        }

        if (responseData['error']['message'] == 'INVALID_PASSWORD') {
          throw PasswordException.invalidPassword();
        }

        if (responseData['error']['message'] == 'WEAK_PASSWORD') {
          throw PasswordException.weakPassword();
        }

        throw AuthException(responseData['error']['message']);
      }

      return User(
        userId: responseData['localId'],
        email: email,
        token: Token(
          token: responseData['idToken'],
          refreshToken: responseData['refreshToken'],
          expiryDate: DateTimeX.current.add(
            Duration(
              seconds: int.parse(
                responseData['expiresIn'],
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      throw error;
    }
  }

  @override
  void dispose() {}

  @override
  Future<User?>? refreshToken(User? currentUser) async {
    final url = 'https://securetoken.googleapis.com/v1/token?key=$webApiKey';
    final response = await http.post(
      Uri.parse(url),
      body: json.encode(
        {
          'grant_type': 'refresh_token',
          'refresh_token': currentUser!.token.refreshToken,
        },
      ),
    );
    print('response $response');
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      return currentUser.copyWith(
        token: currentUser.token.copyWith(
          token: responseData['id_token'],
          refreshToken: responseData['refresh_token'],
          expiryDate: DateTimeX.current.add(
            Duration(
              seconds: int.parse(responseData['expires_in']),
            ),
          ),
        ),
      );
    }
  }
}
