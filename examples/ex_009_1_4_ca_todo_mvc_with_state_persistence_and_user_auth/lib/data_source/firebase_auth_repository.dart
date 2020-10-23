import 'dart:convert';

import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/common/extensions.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/value_object/token.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/service/exceptions/auth_exception.dart';
import 'package:http/http.dart' as http;

import 'my_project_data.dart' as myProjectData; //TODO Delete this.
import '../domain/entities/user.dart';
import '../service/interfaces/i_auth_repository.dart';

//Go to https://console.firebase.google.com/project/YOUR_PROJECT_NAME/settings/general and get `webApiKey`. This will be your `webApiKey` const.
const webApiKey = myProjectData.webApiKey; //TODO Use yours

class FireBaseAuth implements IAuthRepository {
  @override
  Future<User> login(String email, String password) {
    return _authenticate(email, password, 'verifyPassword');
  }

  @override
  Future<User> signUp(String email, String password) {
    return _authenticate(email, password, 'signupNewUser');
  }

  @override
  Future<void> logout() async {
    //
  }

  Future<User> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=$webApiKey';
    try {
      var response = await http.post(
        url,
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
        throw AuthException(responseData['error']['message']);
      }

      return User(
          userId: responseData['localId'],
          email: email,
          token: Token(
            token: responseData['idToken'],
            expiryDate: DateTimeX.current.add(
              Duration(
                seconds: int.parse(
                  responseData['expiresIn'],
                ),
              ),
            ),
          ));
    } catch (error) {
      throw error;
    }
  }
}
