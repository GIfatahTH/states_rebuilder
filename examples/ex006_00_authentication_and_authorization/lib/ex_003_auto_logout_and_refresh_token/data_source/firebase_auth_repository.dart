import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:states_rebuilder/states_rebuilder.dart';

import '../common/extensions.dart';
import '../models/auth_exception.dart';
import '../models/token.dart';
import '../models/user.dart';

//Go to https://console.firebase.google.com/project/YOUR_PROJECT_NAME/settings/general and get `webApiKey`. This will be your `webApiKey` const.
const webApiKey = 'AIzaSyBuocqEfy6UGBNuafRTjHTtmpXwyGVsQsI'; //TODO Use yours

class FireBaseAuthRepository implements IAuth<User?, AuthParam> {
  @override
  Future<void> init() async {}

  @override
  Future<User?> signIn(AuthParam? param) async {
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
  Future<User?> signUp(AuthParam? param) async {
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
  Future<void> signOut(AuthParam? param) async {}

  Future<User?> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=$webApiKey';

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
  }

  @override
  void dispose() {}

  @override
  Future<User?>? refreshToken(User? currentUser) async {
    const url = 'https://securetoken.googleapis.com/v1/token?key=$webApiKey';
    final response = await http.post(
      Uri.parse(url),
      body: json.encode(
        {
          'grant_type': 'refresh_token',
          'refresh_token': currentUser!.token.refreshToken,
        },
      ),
    );

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
    return null;
  }
}
