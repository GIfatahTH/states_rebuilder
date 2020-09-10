# clean_architecture_dane_mackier_app

> Don't forget to run `flutter create .` in the terminal in the project directory to create platform-specific files.

>This is readme version 1, after finishing it take a look to [readme version 2](README_v2.md) to see more features of states_rebuilder notably how easy and straightforward unit testing of widgets and logic classes it is.


The architecture consists of something like onion layers, the innermost one is the domain layer, the middle layer is the service layer and the outer layer consists of three parts: the user interface  UI, data_source and infrastructure. Each of the parts of the architecture is implemented using folders.

![Clean Architecture](https://github.com/GIfatahTH/repo_images/blob/master/008-Clean-Architecture.png).

Code dependencies can only point inwards. Nothing in an inner circle can know anything at all about something in an outer circle. In particular, the name of something declared in an outer circle must not be mentioned by the code in the inner circle. In particular data_source and infrastructure must implement interfaces defined in the service layer.

```
**lib -**  
    | **- domain**  
    |        | **- entities :** (mutable objects with unique IDs.  
    |        |              They are the in-memory representation of   
    |        |              the data that was retrieved from the persistence   
    |        |              store (data_source))  
    |        |   
    |        | **- value objects :** (immutable objects which have value equality   
    |        |                      and self-validation but no IDs)  
    |        |   
    |        | **- exceptions :** (all custom exceptions classes that can be   
    |        |                      thrown from the domain)  
    |        |  
    |        | **- common :** (common utilities shared inside the domain)  
    |   
    | **- service**  
    |        | **- interfaces :** (interfaces that should any external service implements)  
    |        |   
    |        | **- exceptions :** (all custom exceptions classes that can be thrown   
    |        |                    from the service, infrastructure and data_source)  
    |        |   
    |        | **- common :**(common utilities shared inside the service)   
    |        |   
    |        | **- use case classes  
    |  
    | **-data_source** : (implements interfaces and throws exception defined in   
    |        |                the service layer. It is used to fetch and persist data  
    |        |                and instantiate entities and value objects)  
    |  
    | **-infrastructure** : (implements interfaces and throws exception defined in   
    |        |                the service layer. It is used to call third party libraries   
    |        |                to communicate with the underplaying infrastructure framework for
    |        |               example making a call or sending a message or email, using GPS.... )  
    |         
    | **UI**  
    |        | **- pages** :(collection of pages the UI has).  
    |        |   
    |        | **- widgets**: (small and reusable widgets that should be app independent. 
    |        |                 If you use a widget from external libraries, put it in this folder
    |        |                 and adapt its interface, 
    |        |   
    |        | **- exceptions :** (Handle exceptions)  
    |        |   
    |        | **- common :**(common utilities shared inside the ui)  
```   

For more detail on the implemented clean architecture read [this article](https://medium.com/flutter-community/clean-architecture-with-states-rebuilder-has-never-been-cleaner-6c9b91c3b9b6#a588)


>For this kind of architectures, you have to start codding from the domain because it is totally independent from other layers. Then, go up and code the service layer and the data_source and the infrastructure. The UI layer is the last layer to code.

>Even if you want to understand an app scaffold around this kind of architecture, start understanding the domain then the service, that the data_source and infrastructure and end by understanding the UI part.

# Domain
## Entities
> Entities are mutable objects with unique IDs. They are the in-memory representation of the data that was retrieved from the persistence store (data_source). They must contain all the logic it controls. They should be validate just before persistance.

There are three entities: User, Post, and Comment.
### User entity :
**file:lib/domain/entities/user.dart**
```dart
class User {
  int id;
  String name;
  String username;

  //Typically called form service layer to create a new user
  User({this.id, this.name, this.username});

  //Typically called from the data_source layer after getting data from an external source.
  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
  }

  //Typically called from service or data_source layer just before persisting data.
  //It is the appropriate time to check data validity before persistence.
  Map<String, dynamic> toJson() {
    //validate
    _validation();
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    return data;
  }

  _validation() {
    if (name == null) {
      //NullNameException is defined in the exception folder of the domain
      throw NullNameException();
    }
  }
}
```
### Post entity
**file:lib/domain/entities/post.dart**
```dart
class Post {
  int id;
  int userId;
  String title;
  String body;
  int likes;

  Post({this.id, this.userId, this.title, this.body, this.likes});

  Post.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    title = json['title'];
    body = json['body'];
    likes = 0;
  }

  Map<String, dynamic> toJson() {
    _validation();
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['id'] = this.id;
    data['title'] = this.title;
    data['body'] = this.body;
    data['likes'] = this.likes;
    return data;
  }

  //Entities should contain all the logic that it controls
  incrementLikes() {
    likes++;
  }

  _validation() {
    if (userId == null) {
      throw ValidationException('User id can not be undefined');
    }
  }
}
```

### Comment entity
**file:lib/domain/entities/comment.dart**
```dart
class Comment {
  int id;
  int postId;
  String name;
  //Email is a value object
  Email email;
  String body;

  Comment({this.id, this.postId, this.name, this.email, this.body});

  Comment.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    id = json['id'];
    name = json['name'];
    email = Email(json['email']);
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    _validation();
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email.email;
    data['body'] = this.body;
    return data;
  }

  _validation() {
    if (postId == null) {
      throw ValidationException('No post is associated with this comment');
    }
  }
}
```

## value object
>value objects are Immutable objects which have value equality and self-validation but no IDs.

There is one value object. In a real app, it is preferred to have as many as possible of value objects
**file:lib/domain/value_objects/email.dart**
```dart
//value objects are immutable
@immutable
class Email {
  Email(this.email) {
    if (!email.contains('@')) {
      //Validation at the time of construction
      throw ValidationException('Your email must contain "@"');
    }
  }

  final String  email;
}
```

## exceptions
**file:lib/domain/exceptions/validation_exception.dart**
```dart
class ValidationException extends Error {
  ValidationException(this.message);
  final String message;
}
```

# service
Typically, for each entity, there is a corresponding service class with the responsibility to instantiate and keep the entity by delegating to an external service and processing the entity so that it is suitable for use cases.
**file:lib/service/authentication_service.dart**
```dart
import '../domain/entities/user.dart';
import 'common/input_parser.dart';
import 'interfaces/i_api.dart';

//Responsibility: Fetch for user form input id cache the obtained user in memory
class AuthenticationService {
  AuthenticationService({IApi api}) : _api = api;
  IApi _api;
  User _fetchedUser;
  User get user => _fetchedUser;

  void login(String userIdText) async {
    //Delegate the input parsing and validation
    var userId = InputParser.parse(userIdText);

    _fetchedUser = await _api.getUserProfile(userId);

    
    //// TODO1 : throw unhandled exception
    // throw Exception();

    ////TODO2: Instantiate a value object in a bad state.
    // Comment(
    //   id: 1,
    //   email: Email('email.com'), //Bad email
    //   name: 'Joe',
    //   body: 'comment',
    //   postId: 2,
    // );

    ////TODO3: try to persist an entity is bad state.
    // Comment(
    //   id: 1,
    //   email: Email('email@m.com'), //good email
    //   name: 'Joe',
    //   body: 'comment',
    //   postId: 2,
    // )
    //   ..postId = null// bad state
    //   ..toJson();
  }
}
```

**file:lib/service/posts_service.dart**
```dart
import '../domain/entities/post.dart';
import 'interfaces/i_api.dart';


//Responsibility: Fetch posts by user ID, cache the obtained post list in memory and encapsulation of the logic of posts like.
class PostsService {
  PostsService({IApi api}) : _api = api;
  IApi _api;
  List<Post> _posts;
  List<Post> get posts => _posts;

  void getPostsForUser(int userId) async {
    _posts = await _api.getPostsForUser(userId);
  }

  //Encapsulation of the logic of getting post likes.
  int getPostLikes(postId) {
    return _posts.firstWhere((post) => post.id == postId).likes;
  }

  //Encapsulation of the logic of incrementing the like of a post.
  void incrementLikes(int postId) {
    _posts.firstWhere((post) => post.id == postId).incrementLikes();
  }
}
```

**file:lib/service/comments_service.dart**
```dart
//Responsibility : Fetch comments by post ID, cache the obtained comment list in memory
class CommentsService {
  IApi _api;
  CommentsService({IApi api}) : _api = api;

  List<Comment> _comments;
  List<Comment> get comments => _comments;

  Future<void> fetchComments(int postId) async {
    _comments = await _api.getCommentsForPost(postId);
  }
}
```

## interfaces
**file:lib/service/interfaces/i_api.dart**

```dart
abstract class IApi {
  Future<User> getUserProfile(int userId);
  Future<List<Post>> getPostsForUser(int userId);
  Future<List<Comment>> getCommentsForPost(int postId);
}
```
## common
**file:lib/common/input_parser.dart**
```dart
class InputParser {
  static int parse(String userIdText) {
    var userId = int.tryParse(userIdText);
    if (userId == null) {
      throw NotNumberException();
    }
    return userId;
  }
}
```

## exceptions
**file:lib/exceptions/input_exception.dart**
```dart
class NotNumberException extends Error {
  final message = 'The entered value is not a number';
}
```

**file:lib/exceptions/fetch_exception.dart**
```dart
class NetworkErrorException extends Error {
  final message = 'A NetWork problem';
}

class UserNotFoundException extends Error {
  UserNotFoundException(this._userID);
  final int _userID;
  String get message => 'No user find with this number $_userID';
}

class PostNotFoundException extends Error {
  PostNotFoundException(this._userID);
  final int _userID;
  String get message => 'No post fount of user with id:  $_userID';
}

class CommentNotFoundException extends Error {
  CommentNotFoundException(this._postID);
  final int _postID;
  String get message => 'No comment fount of post with id:  $_postID';
}
```

# data_source
**file:lib/data_source/api.dart**
```dart
//Implement the IApi class form the interface folder of the service layer.
//Errors must be catches and custom error defined in the service layer must be thrown instead.
class Api implements IApi {
  static const endpoint = 'https://jsonplaceholder.typicode.com';

  var client = new http.Client();

  Future<User> getUserProfile(int userId) async {
    var response;
    try {
      response = await client.get('$endpoint/users/$userId');
    } catch (e) {
      //Handle network error
      //It must throw custom errors classes defined in the service layer
      throw NetworkErrorException();
    }

    //Handle not found page
    if (response.statusCode == 404) {
      throw UserNotFoundException(userId);
    }
    if (response.statusCode != 200) {
      throw NetworkErrorException();
    }

    return User.fromJson(json.decode(response.body));
  }

  Future<List<Post>> getPostsForUser(int userId) async {
    var posts = List<Post>();
    var response;
    try {
      response = await client.get('$endpoint/posts?userId=$userId');
    } catch (e) {
      throw NetworkErrorException();
    }
    if (response.statusCode == 404) {
      throw PostNotFoundException(userId);
    }

    if (response.statusCode != 200) {
      throw NetworkErrorException();
    }

    var parsed = json.decode(response.body) as List<dynamic>;

    for (var post in parsed) {
      posts.add(Post.fromJson(post));
    }

    return posts;
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    var comments = List<Comment>();

    var response;
    try {
      response = await client.get('$endpoint/comments?postId=$postId');
    } catch (e) {
      throw NetworkErrorException();
    }
    if (response.statusCode == 404) {
      throw CommentNotFoundException(postId);
    }

    if (response.statusCode != 200) {
      throw NetworkErrorException();
    }

    var parsed = json.decode(response.body) as List<dynamic>;

    for (var comment in parsed) {
      comments.add(Comment.fromJson(comment));
    }

    return comments;
  }
}
```

# infrastructure
No need in this example. It can have external libraries that deal with platform-specific tasks such as check for network connection, use GPS, use email service ....


# UI:
**file:lib/ui/main.dart**


# UI:
**file:lib/ui/main.dart**

We want the "user" once connected to be available in all the widget tree. For this reason, we should inject it to the topmost widget before the `MaterialApp` widget.
The UI layer never instantiates anything from the domain layer, rather it must delegate to objects in the service layer. In our case, we will inject the `AuthenticationService` because it is responsible for instantiating the `user`.

```dart
void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //Registration of the implementation (Api) by an interface (IApi)
        //Implementation can easily changes
        Inject<IApi>(() => Api()), 
        Inject(() => AuthenticationService(api: Injector.get())),
      ],
      builder: (context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(),
        initialRoute: 'login',
        onGenerateRoute: Router.generateRoute,
      ),
    );
  }
}
```
## pages
I suggest dedicating a folder for each page that contains dart files linked to the page. The entry file will be the will have the same name as the folder name.This improves readability because all related files are in the same place. Compare it with the case where you put all files in the widgets folder. Widgets folder should contain only small, reusable, and app independent widgets.

The first page is the login page. 
**file:lib/ui/pages/login_page/login_page.dart**

```dart
class _LoginBody extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LoginHeader(controller: controller),
        //Use of WhenRebuilderOr
        //
        WhenRebuilderOr<AuthenticationService>(
          observe: () => ReactiveModel<AuthenticationService>(),
          onWaiting: () => CircularProgressIndicator(),
          dispose: (_, __) => controller.dispose(),
          builder: (_, authServiceRM) {
            //builder will be called in all states except of isWaiting state which has its own callback.
            //Even in hasError state this builder is called.
            return FlatButton(
              color: Colors.white,
              child: Text(
                'Login',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                authServiceRM.setState(
                  (state) => state.login(controller.text),
                  onError: ErrorHandler.showSnackBar,
                  onData: (context, authServiceRM) {
                    Navigator.pushNamed(context, '/');
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
```
The second page is the home page. 
**folder:lib/ui/pages/home_page**   
The `home_page` folder will have the home_page.dart file and `postlist_item.dart` to display a post item.

**file:lib/ui/pages/home_page/home_page.dart.**
```dart
class HomePage extends StatelessWidget {
  final user = Injector.get<AuthenticationService>().user;
  @override
  Widget build(BuildContext context) {
    return Injector(
        inject: [Inject(() => PostsService(api: Injector.get()))],
        builder: (context) {
          return Scaffold(
            backgroundColor: backgroundColor,
            //use of WhenRebuilderOr
            body: WhenRebuilderOr<PostsService>(
              observe: () => ReactiveModel<PostsService>(),
              initState: (_, postsServiceRM) {
                postsServiceRM.setState(
                  (state) => state.getPostsForUser(user.id),
                  onError: ErrorHandler.showErrorDialog,
                );
              },
              onWaiting: () => Center(child: CircularProgressIndicator()),
              builder: (_, postsService) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIHelper.verticalSpaceLarge(),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        'Welcome ${user.name}',
                        style: headerStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text('Here are all your posts',
                          style: subHeaderStyle),
                    ),
                    UIHelper.verticalSpaceSmall(),
                    Expanded(child: getPostsUi(postsService.state.posts)),
                  ],
                );
              },
            ),
          );
        });
  }

  Widget getPostsUi(List<Post> posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) => PostListItem(
          post: posts[index],
          onTap: () {
            Navigator.pushNamed(context, 'post', arguments: posts[index]);
          },
        ),
      );
}
```

**file:lib/ui/pages/post_page**   
the folder post_page contains three files: the post_page.dart file, the like_button.dart and the comments.dart

**file:lib/ui/pages/post_page/post_page.dart**

```dart
class PostPage extends StatelessWidget {
  PostPage({this.post});
  final Post post;
  final user = Injector.get<AuthenticationService>().user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            UIHelper.verticalSpaceLarge(),
            Text(post.title, style: headerStyle),
            Text(
              'by ${user.name}',
              style: TextStyle(fontSize: 9.0),
            ),
            UIHelper.verticalSpaceMedium(),
            Text(post.body),
            LikeButton(
              postId: post.id,
            ),
            Comments(post.id)
          ],
        ),
      ),
    );
  }
}
```

**file:lib/ui/pages/post_page/comments.dart**

```dart
class Comments extends StatelessWidget {
  final int postId;
  Comments(this.postId);

  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [Inject(() => CommentsService(api: Injector.get()))],
      builder: (context) {
        //Use of WhenRebuilder
        return WhenRebuilder<CommentsService>(
          observe: () => ReactiveModel<CommentsService>(),
          initState: (_, commentsServiceRM) => commentsServiceRM.setState(
            (state) => state.fetchComments(postId),
            onError: ErrorHandler.showErrorDialog,
          ),
          //If using WhenRebuilderOR and do not define error callback the app will break on error
          onIdle: () => Container(),
          onWaiting: () => Center(child: CircularProgressIndicator()),
          onError: (_) => Container(),
          onData: (commentsService ) {
            return Expanded(
              child: ListView(
                children: commentsService.comments
                    .map((comment) => CommentItem(comment))
                    .toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class CommentItem extends StatelessWidget {
  final Comment comment;
  const CommentItem(this.comment);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: commentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            comment.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          UIHelper.verticalSpaceSmall(),
          Text(comment.body),
        ],
      ),
    );
  }
}
```

**file:lib/ui/pages/post_page/like_button.dart**

```dart
class LikeButton extends StatelessWidget {
  LikeButton({
    @required this.postId,
  });
  final int postId;

  @override
  Widget build(BuildContext context) {
    final postsServiceRM = ReactiveModel<PostsService>();

    return Row(
      children: <Widget>[
        StateBuilder(
          observe: () => postsServiceRM,
          builder: (context, snapshot) {
            return Text('Likes ${postsServiceRM.state.getPostLikes(postId)}');
          },
        ),
        MaterialButton(
          color: Colors.white,
          child: Icon(Icons.thumb_up),
          onPressed: () {
            postsServiceRM.setState((state) => state.incrementLikes(postId));
          },
        )
      ],
    );
  }
}
```

## exceptions
Here we will handle errors thrown from inner layers.

there is one class:
**file:lib/ui/exceptions/error_handler.dart**
```dart
class ErrorHandler {
  //go through all custom errors and return the corresponding error message
  static String errorMessage(dynamic error) {
    if (error == null) {
      return null;
    }
    if (error is ValidationException) {
      return error.message;
    }

    if (error is NotNumberException) {
      return error.message;
    }

    if (error is NetworkErrorException) {
      return error.message;
    }

    if (error is UserNotFoundException) {
      return error.message;
    }

    if (error is PostNotFoundException) {
      return error.message;
    }

    if (error is CommentNotFoundException) {
      return error.message;
    }
    // throw unexpected error.
    throw error;
  }

  //Display an AlertDialog with the error message
  static void showErrorDialog(BuildContext context, dynamic error) {
    if (error == null) {
      return;
    }
    //Flutter Way
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       content: Text(errorMessage(error)),
    //     );
    //   },
    // );

    //Without BuildContext
    RM.navigate.toDialog(
      AlertDialog(
        content: Text(errorMessage(error)),
      ),
    );
  }

  //Display an snackBar with the error message
  static void showSnackBar(BuildContext context, dynamic error) {
    if (error == null) {
      return;
    }
    //Flutter way
    // Scaffold.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('${errorMessage(error)}'),
    //   ),
    // );

    //Without BuildContext
    RM.scaffoldShow.snackBar(
      SnackBar(
        content: Text('${errorMessage(error)}'),
      ),
    );
  }
}
```
## widgets
Widgets folder contains **login_header.dart** which is reusable, app independent widget.

## common
common folder contains  **app_colors.dart**, **text_styles.dart** and **ui_helpers.dart**



# test

testing app build using states_rebuilder is the best time you spend in coding your app.

## service
testing services is straightforward. 
example:

```dart
void main() {
  test('login', () async {
    //Instantiating AuthenticationService using FakeApi
    final authService = AuthenticationService(api: FakeApi());

    //calling the login method
    await authService.login('1');
    
    //expectation
    expect(authService.user.name, equals('Fake User Name'));
  });
}
```
See the other service class in the test folder

## UI
Even for the UI, testing it is  such a simple and amazing thing

Let's see how to test the `loginPage` view

The first thing to do to test `loginPage` the is to isolate it from all of its dependencies by faking them

`loginPage` depends on:
 1. `AuthenticationService`, the backend logic of the `loginPage` page
 2. `HomePage`: the page to navigate to from `loginPage` page.

So we will define a fake class for `AuthenticationService`

```dart
class FakeAuthenticationService extends AuthenticationService {
  //variable defined to set the expected errors
  dynamic error;

  User _fetchedUser;

  @override
  User get user => _fetchedUser;

  @override
  Future<void> login(String userIdText) async {
    var userId = InputParser.parse(userIdText);

    await Future.delayed(Duration(seconds: 1));

    if (error != null) {
      //if error is defined it will be thrown
      //We will define the error in the test
      throw error;
    }

    // end with a fake User
    _fetchedUser = User(id: userId, name: 'fakeName', username: 'fakeUserName');
  }
}
```

Let's start the test:

```dart
void main() {
  //helper variable
  Widget loginPage;
  Finder loginBtn = find.byType(FlatButton);
  Finder loginTextField = find.byType(TextField);

  setUp(() {
    //We set Injector.enableTestMode  to true so that Injector will use our Fake classes instead of real ones
    Injector.enableTestMode = true;
    loginPage = Injector(
      inject: [
        //It is important to resister fake class with the type of real classes
        Inject<AuthenticationService>(() => FakeAuthenticationService())
      ],
      //Whenever Injector.get<AuthenticationService>() is called inside the app it will return the FakeAuthenticationService. 
      builder: (_) => MaterialApp(
        initialRoute: 'login',
        routes: {
          //Here how we faked the HomePage.
          //This is one benefit of named routing. 
          '/': (_) => Text('This is the HomePage'),
          'login': (_) => LoginPage(),
        },
      ),
    );
  });
  
  //tests
  ..
}
```
At this stage the `LoginPage` is isolated by faking its dependencies.

## First test: 
**After the app is started and when the user tap on the button without entering any text or if he entered a non number text we expect the app to display a red text telling the use that non number values are not allowed.**

```dart
  testWidgets('display "The entered value is not a number" message',
      (tester) async {
    await tester.pumpWidget(loginPage);
    //The error message
    final String errorMessage = NotNumberException().message;
    // before tap, no error message
    expect(find.text(errorMessage), findsNothing);

    await tester.tap(loginBtn);
    await tester.pump();
    //after tap, error message appears
    expect(find.text(errorMessage), findsOneWidget);

    //enter non number string,
    await tester.enterText(loginTextField, '1m');

    await tester.tap(loginBtn);
    await tester.pump();
    //after tap, error message appears
    expect(find.text(notNumberError), findsOneWidget);
  });
  ```
## Second test: 
**If the user enter a number less than 1 or greater the 10, a red error text should appear under the textField**

```dart
  testWidgets('display "The entered value is not between 1 and 10" message',
      (tester) async {
    await tester.pumpWidget(loginPage);
    final String notInRangeError = NotInRangeException().message;
    // before tap, no error message
    expect(find.text(notInRangeError), findsNothing);

    //enter -1,
    await tester.enterText(loginTextField, '-1');

    await tester.tap(loginBtn);
    await tester.pump();
    expect(find.text(notInRangeError), findsOneWidget);

    //enter 11
    await tester.enterText(loginTextField, '11');

    await tester.tap(loginBtn);
    await tester.pump();
    //after tap, error message appears
    expect(find.text(notInRangeError), findsOneWidget);
  });
  ```

## Third test: 
**If the user enters an accepted number, a CircularProgressBarIndictor should appear, we assume there is a network error, than a red text error should appear under the TextField and a SnackBar containing the error message **

```dart
  testWidgets(
      'display "A NetWork problem" after showing CircularProgressBarIndictor',
      (tester) async {
    await tester.pumpWidget(loginPage);
    final String networkErrorException = NetworkErrorException().message;
    // before tap, no error message
    expect(find.text(networkErrorException), findsNothing);

    //enter 1,
    await tester.enterText(loginTextField, '1');

    //set to throw networkErrorException error
    (Injector.get<AuthenticationService>() as FakeAuthenticationService).error =
        NetworkErrorException();

    await tester.tap(loginBtn);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    //expect find on in the snackBar and one under TextField
    expect(find.text(networkErrorException), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
  });
  ```

## fourth test: 
**If the user enters an accepted number, a CircularProgressBarIndictor should appear, we assume there is a user not found error, than a red text error should appear under the TextField and a SnackBar containing the error message **

```dart
  testWidgets(
      'display "No user find with this number" after showing CircularProgressBarIndictor',
      (tester) async {
    await tester.pumpWidget(loginPage);
    final String userNotFoundException = UserNotFoundException(1).message;
    // before tap, no error message
    expect(find.text(userNotFoundException), findsNothing);

    //enter 1,
    await tester.enterText(loginTextField, '1');

    //set fake to throw userNotFoundException error
    (Injector.get<AuthenticationService>() as FakeAuthenticationService).error =
        UserNotFoundException(1);

    await tester.tap(loginBtn);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    //expect find on in the snackBar and one under TextField
    expect(find.text(userNotFoundException), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
  });
  ```

## the last test: 
**If the user enters an accepted number, a CircularProgressBarIndictor should appear, we assume there  is no error and user is logged in. we should navigate to homePage **

```dart
  testWidgets(
      'show CircularProgressBarIndictor and navigate to homePage after successful login',
      (tester) async {
    await tester.pumpWidget(loginPage);

    //enter 1,
    await tester.enterText(loginTextField, '1');

    await tester.tap(loginBtn);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    //expect the reactive model has data
    expect(ReactiveModel<AuthenticationService>().hasData, isTrue);

    //expect the user id is obtained
    expect(ReactiveModel<AuthenticationService>().state.user.id, equals(1));

    //await page animation to finish
    await tester.pump(Duration(seconds: 1));

    //expect home page is displayed
    expect(find.text('This is the HomePage'), findsOneWidget);
  });
```

This is how testing a widget view looks like. We are sure 100% that the `LoginPage` works as intended, without even know form where data are obtained and what HomePage will do with the logged user information.

See test folder to take a hint how the other pages are tested.

The principle is simple, just try to isolate your page by faking dependencies. 

>With states_rebuilder domain and service classes are pure dart classes so that their testing is the easiest thing in the testing world. In the other facade, UI view are easily isolated and wih flutter testing toolkit, testing UI is an amazing time.