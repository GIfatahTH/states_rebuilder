import '../domain/entities/user.dart';
import 'common/input_parser.dart';
import 'interfaces/i_api.dart';

//use case : Fetch for user form input id cache the obtained user in memory
class AuthenticationService {
  AuthenticationService({IApi api}) : _api = api;
  IApi _api;
  User _fetchedUser;
  User get user => _fetchedUser;

  void login(String userIdText) async {
    //Delegate the input parsing and validation
    var userId = InputParser.parse(userIdText);

    _fetchedUser = await _api.getUserProfile(userId);

    // // TODO1 : throw unhandled exception
    // throw Exception();

    //TODO2: Instantiate a value object in a bad state.
    // Comment(
    //   id: 1,
    //   email: Email('email.com'), //Bad email
    //   name: 'Joe',
    //   body: 'comment',
    //   postId: 2,
    // );

    //TODO3: try to persist an entity is bad state.
  //   Comment(
  //     id: 1,
  //     email: Email('email@m.com'), //Bad email
  //     name: 'Joe',
  //     body: 'comment',
  //     postId: 2,
  //   )
  //     ..postId = null
  //     ..toJson();
  }
}
