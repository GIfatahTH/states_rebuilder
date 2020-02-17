# clean_architecture_dane_mackier_app

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

We want the "user" once connected to be available in all the widget tree. For this reason, we should inject it to the topmost widget before the `MaterialApp` widget.
The UI layer never instantiates anything from the domain layer, rather it must delegate to objects in the service layer. In our case, we will inject the `AuthenticationService` because it is responsible for instantiating the `user`.

```dart
void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //NOTE1 : The order doesn't matter.
        //NOTE2: // Register with interface.
        Inject<IApi>(() => Api()), 
        //NOTE3: AuthenticationService is will be available globally
        Inject(() => AuthenticationService(api: Injector.get())),
      ],
      builder: (context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(),
        initialRoute: 'login',
        //See Dane's tutorial.
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
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StateBuilder<AuthenticationService>(
      //NOTE1: getting the registered reactiveModel and subscribe to StateBuilder
      models: [Injector.getAsReactive<AuthenticationService>()],
      //Note2: disposing TextEditingController to free resources.
      dispose: (_, __) => controller.dispose(),
      builder: (_, authServiceRM) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //LoginHeader is a reusable and app independent widget. It is placed in the widgets folder.
            LoginHeader(
              //NOTE3: ErrorHandler is a class method used to center error handling.
              //NOTE4: errorMessage returns a string description of the thrown error if there is one.
              //NOTE4: because we are handling error we must catch them is setState method.
              validationMessage: ErrorHandler.errorMessage(authServiceRM.error),
              controller: controller,
            ),
            //NOTE5: if authServiceRM ReactiveModel if it is waiting.
            authServiceRM.isWaiting
                ? CircularProgressIndicator()
                : FlatButton(
                    color: Colors.white,
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      //NOTE6: call setState method
                      authServiceRM.setState(
                        (state) => state.login(controller.text),
                        //NOTE7: catchError
                        catchError: true,
                        //NOTE8: Check if user is logged (authServiceRM has data) and navigate to home page
                        onData: (context, authServiceRM) {
                          Navigator.pushNamed(context, '/');
                          //We can use pushReplacementNamed without problem because 
                          //AuthenticationService is injected globally before MaterialApp
                        },
                      );
                    },
                  )
          ],
        );
      },
    );
  }
}
```
The second page is the home page. 
**folder:lib/ui/pages/home_page**   
The ``home_page`` folder will have the home_page.dart file and `postlist_item.dart` to display a post item.

**file:lib/ui/pages/home_page/home_page.dart.**
```dart
class HomePage extends StatelessWidget {
  //NOTE1: In the login page we instantiated the user and navigated to this page.
  //NOTE1: We use Injector.get to access AuthenticationService and get user.
  final user = Injector.get<AuthenticationService>().user;
  @override
  Widget build(BuildContext context) {
    return Injector(
        //NOTE2: Inject PostsService
        inject: [Inject(() => PostsService(api: Injector.get()))],
        builder: (context) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: StateBuilder<PostsService>(
              models: [Injector.getAsReactive<PostsService>()],
              initState: (_, postsServiceRM) {
                //NOTE3: get the list of post from the user id
                postsServiceRM.setState(
                  (state) => state.getPostsForUser(user.id),
                  //NOTE3: Delegate error handling to the ErrorHandler to show an alertDialog
                  onError: ErrorHandler.showErrorDialog,
                );
              },
              builder: (_, postsService) {
                //NOTE4: isIdle is unreachable status because the setState is called from the initState

                //NOTE4: check if waiting
                if (postsService.isWaiting) {
                  return Center(child: CircularProgressIndicator());
                }

                //NOTE4: hasData and hasError (posts=[] so no problem to display empty posts)
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

  //List of posts
  Widget getPostsUi(List<Post> posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) => PostListItem(
          post: posts[index],
          onTap: () {
            //Navigate to poste detail
            Navigator.pushNamed(context, 'post',
                arguments: posts[index]);
            //If you use pushReplacementNamed, PostsService will be unregistered and 
            //You can not get it using Injector.get or Injector.getAsReactive.
            //If you want keep PostsService you have to reinject it. See not bellow.
          },
        ),
      );
}
```
NOTE: to reinject the `PostsService` model :
in the `router.dart `file replace
```dart
case 'post':
 var post = settings.arguments as Post;
 return MaterialPageRoute(builder: (_) => PostPage(post: post));
```
by
```dart
case 'post':
 var post = settings.arguments as Post;
 return MaterialPageRoute(builder: (_) => Injector(
      reinject: [Injector.getAsReactive<PostsService>()],
      builder: (context) {
        return PostPage(post: post));
      },
    );
```
Now the same instance of `PostsService` will be available in the post page.

**file:lib/ui/pages/post_page**   
the folder post_page contains three files: the post_page.dart file, the like_button.dart and the comments.dart

**file:lib/ui/pages/post_page/post_page.dart**

```dart
class PostPage extends StatelessWidget {
  PostPage({this.post});
  final Post post;
  //NOTE1: Get the logged user
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
            //NOTE2: Display user name
            Text(
              'by ${user.name}',
              style: TextStyle(fontSize: 9.0),
            ),
            UIHelper.verticalSpaceMedium(),
            Text(post.body),
            //NOTE3: like button widget (like_button.dart)
            LikeButton(
              postId: post.id,
            ),
            //NOTE3: Comments widget (comments.dart)
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
      //NOTE1: Inject CommentsService
      inject: [Inject(() => CommentsService(api: Injector.get()))],
      builder: (context) {

        return StateBuilder(
          models: [Injector.getAsReactive<CommentsService>()],
          //NOTE2: fetch comments in the init state
          initState: (_, commentsServiceRM) => commentsServiceRM.setState(
            (state) => state.fetchComments(postId),
            //NOTE3: Delegate to ErrorHandler class to show an alert dialog
            onError: ErrorHandler.showErrorDialog,
          ),
          builder: (_, commentsServiceRM) {
            //NOTE4 use whenConnectionState
            return commentsServiceRM.whenConnectionState(
              onIdle: () =>
                  Container(), //Not reachable because setState is called form initState
              onWaiting: () => Center(child: CircularProgressIndicator()),
              onData: (state) => Expanded(
                child: ListView(
                  children: state.comments
                      .map((comment) => CommentItem(comment))
                      .toList(),
                ),
              ),
              //NOTE4: Display empty container on error. An AlertDialog should be displayed
              onError: (_) => Container(),
            );
          },
        );
      },
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
    //NOTE1: get reactiveModel of PostsService
    final postsServiceRM = Injector.getAsReactive<PostsService>();

    return Row(
      children: <Widget>[
        StateBuilder(
          models: [postsServiceRM],
          builder: (context, snapshot) {
            //NOTE2: Optimizing rebuild. Only Text is rebuild
            return Text('Likes ${postsServiceRM.state.getPostLikes(postId)}');
          },
        ),
        MaterialButton(
          color: Colors.white,
          child: Icon(Icons.thumb_up),
          onPressed: () {
            //NOTE3: incrementLikes is a synchronous method so we do not expect errors
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(errorMessage(error)),
        );
      },
    );
  }

  //Display an snackBar with the error message
  static void showSnackBar(BuildContext context, dynamic error) {
    if (error == null) {
      return;
    }
    Scaffold.of(context).showSnackBar(
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


