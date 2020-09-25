import 'dart:convert';

import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/common/extensions.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/domain/value_object/token.dart';
import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/service/exceptions/auth_exception.dart';
import 'package:http/http.dart' as http;

import '../domain/entities/user.dart';
import '../service/interfaces/i_auth_repository.dart';
import 'constants.dart';

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

  // Future<User> _authenticate(
  //     String email, String password, String urlSegment) async {
  //   await Future.delayed(Duration(seconds: 2));
  //   return User(
  //     userId: '__user1__',
  //     email: email,
  //     token: Token(
  //       token: '____token___',
  //       expiryDate: DateTime.now().add(Duration(seconds: 120)),
  //     ),
  //   );
  // }
}
