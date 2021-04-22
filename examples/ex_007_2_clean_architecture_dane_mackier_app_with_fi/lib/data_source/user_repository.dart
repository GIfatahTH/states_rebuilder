part of 'api.dart';

class UserRepository implements IAuth<User, int> {
  @override
  Future<void> init() async {}

  @override
  Future<User> signIn(int? userId) async {
    if (userId == null) {
      throw NullNumberException();
    }
    try {
      final response = await _client.get(
        Uri.parse('$_endpoint/users/$userId'),
      );
      //Handle not found page
      if (response.statusCode == 404) {
        throw UserNotFoundException(userId);
      }
      if (response.statusCode != 200) {
        throw NetworkErrorException();
      }

      return User.fromJson(response.body);
    } catch (e) {
      //Handle network error
      //It must throw custom errors classes defined in the service layer
      throw NetworkErrorException();
    }
  }

  @override
  Future<User> signUp(int? param) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut(int? param) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}
}
