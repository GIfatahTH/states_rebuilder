# clean_architecture_dane_mackier_app using global functional injection

> Don't forget to run `flutter create .` in the terminal in the project directory to create platform-specific files.


The architecture consists of something like onion layers, the innermost one is the domain layer, the middle layer is the service layer and the outer layer consists of three parts: the user interface  UI, data_source, and infrastructure. Each of the parts of the architecture is implemented using folders.

![Clean Architecture](https://github.com/GIfatahTH/repo_images/blob/master/008-Clean-Architecture.png).

Code dependencies can only point inwards. Nothing in an inner circle can know anything at all about something in an outer circle. In particular, the name of something declared in an outer circle must not be mentioned by the code in the inner circle. In particular, data_source and infrastructure must implement interfaces defined in the service layer.

```
**lib -**  
    | **- domain**  
    |        | **- entities :** (mutable or immutable objects with unique IDs.  
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


>For this kind of architecture, you have to start codding from the domain because it is totally independent of other layers. Then, go up and code the service layer and the data_source, and the infrastructure. The UI layer is the last layer to code.

>Even if you want to understand an app scaffold around this kind of architecture, start understanding the domain then the service, that the data_source and infrastructure, and end by understanding the UI part.


# Domain
## Entities
> Entities are immutable or mutable objects with unique IDs. They are the in-memory representation of the data that was retrieved from the persistence store (data_source). They must contain all the logic it controls. They should be validated just before persistence. 

> Tip: use the dart data class generation extension to generate the data class.


# service
Typically, for each entity, there is a corresponding service class with the responsibility to instantiate and keep the entity by delegating to an external service and processing the entity so that it is suitable for use cases.

Here as we will use `RM.injectAuth` for authenticating a user and `RM.injectCRUD` for posts and comments. The service layer is almost empty. It contains comment methods and thrown exception objects.

# data_source

In the data source, we will implement interfaces defined in the service layer or one of the predefined states_rebuilder interfaces. There are three!
  - `IAuth` when using `RM.injectAth`;
  - `ICRUD` when using `RM.injectCRUD`
  - `IPersistStore` when locally persisting the state.

# UI:
**file:lib/ui/main.dart**

```dart
void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      onGenerateRoute: route.Router.generateRoute,
      //As we will use states_rebuilder navigator 
      //we assign its key to the navigator key
      navigatorKey: RM.navigate.navigatorKey,
    );
  }
}
```

As `userInj` is not auto disposed, you have to dispose of it manually. One of the methods to auto Dispose of all non-disposed states is to wrap the `MaterialApp` widget with `TopWidget`.

TopWidget is used also to listen to `InjectedTheme` for dynamic themes and `InjectedI18N` for internationalization. 

```dart
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TopWidget(
      didChangeAppLifecycleState: (state) {
        // for code to be executed depending on the life cycle of the app (in Android : onResume, onPause ...).
      },
      didChangeLocales: (locales) {
        // To track system locale change
      },
      //
      injectedTheme: themes,
      //
      injectedI18N: i18n,
      builder: (context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(),
        onGenerateRoute: route.Router.generateRoute,
        navigatorKey: RM.navigate.navigatorKey,
      ),
    );
  }
}
```
## pages
I suggest dedicating a folder for each page. The folder will contain a file with the same name as an entry point to the page. It is more convenient to use (part - part of) to split widgets in a different file.

The folder may contain a file dedicated to injecting state initiate in the page.


The first page is the login page. 
**file:lib/ui/pages/login_page/login_page.dart**
```dart
//use part directive, allows us to split the page in different pages,
//while keeping them private.
part 'login_header.dart';
part 'login_injected.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //defined in login_header.dart file
        _LoginHeader(controller: controller),
        On.or( //Use of On.or
          //Display CircularProgressIndicator while waiting for logging
          onWaiting: () => CircularProgressIndicator(),
          or: () => FlatButton(
            color: Colors.white,
            child: Text(
              'Login',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              //Trigger a signIn query
              //see userInj in login_injected.dart file
              userInj.auth.signIn(
                //on sign in error, 
                // - a text with the error is displayed as defined in _LoginHeader,
                // - and a SnackBar appears as defined in login_injected.dart file
                (_) => InputParser.parse(controller.text),
              );
            },
          ),
        ).listenTo(
          userInj, //Listen to the userInj
          dispose: () => controller.dispose(),
        ),
      ],
    );
  }
}
```
**file:lib/ui/pages/login_page/login_header.dart**
```dart
part of 'login_page.dart';

class _LoginHeader extends StatelessWidget {
  final TextEditingController controller;

  _LoginHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Login', style: headerStyle),
        UIHelper.verticalSpaceMedium(),
        Text('Enter a number between 1 - 10', style: subHeaderStyle),
        LoginTextField(controller),
        On.or(//Use of On.or
          //Display an error message if login fails
          onError: (error) => Text(
            ExceptionHandler.errorMessage(error),
            style: TextStyle(color: Colors.red),
          ),
          or: () => Container(),
        ).listenTo(userInj),//Listen to userInj
      ],
    );
  }
}
```
**file:lib/ui/pages/login_page/login_injected.dart**
```dart
part of 'login_page.dart';

final userInj = RM.injectAuth<User, int>(
  () => UserRepository(),//The defined user Repo
  unsignedUser: UnSignedUser(), //
  onSigned: (_) {
    //When successfully signed in, navigate to posts page
    RM.navigate.toNamed(('/posts'));
  },
  //on login faiure shwo snackBar
  onSetState: On.error(ExceptionHandler.showSnackBar),
);
```

The second page is the posts page. 
**folder:lib/ui/pages/posts_page**   


**file:lib/ui/pages/posts_page/posts_injected.dart.**
`postsInj` is first used in the page. So it is injected here.


```dart
part of 'posts_page.dart';

final postsInj = RM.injectCRUD(
  // The defined repo that extends ICRUD
  () => PostRepository(),
  //The default param. It is the id of the user
  //It will be use to fetch posts
  param: () => userInj.state.id,
  //read posts once it is initialized
  readOnInitialization: true,
  onSetState: On.error(
    (err) => ExceptionHandler.showErrorDialog(err),
  ),
);

//It is a good practice to use extension on the injected state
//here List<Post> to add custom methods
extension PostsX on List<Post> {
  int getPostLikes(postId) {
    return firstWhere((post) => post.id == postId).likes;
  }

  void incrementLikes(int postId) {
    firstWhere((post) => post.id == postId).incrementLikes();
  }
}
```

**file:lib/ui/pages/posts_page/posts_page.dart.**

```dart
part 'posts_injected.dart';
part 'postlist_item.dart';

class PostsPage extends StatelessWidget {
  //the signed user
  final user = userInj.state;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      //User On.or
      body: On.or(
        onWaiting: () => Center(child: CircularProgressIndicator()),
        or: () {
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
                child: Text('Here are all your posts', style: subHeaderStyle),
              ),
              UIHelper.verticalSpaceSmall(),
              Expanded(child: getPostsUi(postsInj.state)),
            ],
          );
        },
      ).listenTo(postsInj),//Listen to postsInj
    );
  }

  Widget getPostsUi(List<Post> posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) => _PostListItem(
          post: posts[index],
        ),
      );
}
```
**file:lib/ui/pages/posts_page/posts_page.dart.**

```dart
part of 'posts_page.dart';

class _PostListItem extends StatelessWidget {
  final Post post;
  const _PostListItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        RM.navigate.toNamed('/comments', arguments: post);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                blurRadius: 3.0,
                offset: Offset(0.0, 2.0),
                color: Color.fromARGB(80, 0, 0, 0),
              )
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${post.title} - ${post.likes.toString()}',
              maxLines: 2,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.0),
            ),
            Text(
              post.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }
}
```
**file:lib/ui/pages/comments_page**   
the folder post_page contains three files: the post_page.dart file, the like_button.dart and the comments.dart

**file:lib/ui/pages/comments_page/comments_injected.dart**

```dart
final commentsInj = RM.injectCRUD(
  () => CommentRepository(),
  //We could use readOnInitialization, to read on initialization
  //We used another approach for the ske of demonstration 
  //See initState bellow in comments.dart page
  // readOnInitialization: true,
);
```


**file:lib/ui/pages/comments_page/comments_page.dart**

```dart
//All sub page widgets are part of this top page widget
part 'comment_item.dart';
part 'comments.dart';
part 'comments_injected.dart';
part 'like_button.dart';

class CommentsPage extends StatelessWidget {
  CommentsPage({required this.post});
  final Post post;
  final user = userInj.state;

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
            _LikeButton(
              postId: post.id,
            ),
            _Comments(post.id)
          ],
        ),
      ),
    );
  }
}
```

**file:lib/ui/pages/comments_page/comments.dart**

```dart
/part of 'comments_page.dart';

class _Comments extends StatelessWidget {
  final int postId;
  _Comments(this.postId);

  @override
  Widget build(BuildContext context) {
    return On.all(
      onIdle: () => Container(),
      onWaiting: () => Center(child: CircularProgressIndicator()),
      onError: (err) => Center(
        child: Text('${err.message}'),
      ),
      onData: () {
        return Expanded(
          child: ListView(
            children: commentsInj.state
                .map((comment) => _CommentItem(comment))
                .toList(),
          ),
        );
      },
    ).listenTo(
      commentsInj,
      //Here we read for  commentsInj
      initState: () => commentsInj.crud.read(param: (_) => postId),
      onSetState: On.error(ExceptionHandler.showErrorDialog),
    );
  }
}
```

## Testing
Using reference injection simplifies testing:

```dart
void main() {
  //Inject a fake user repository.
  //It will be used instead of the real repository
  userInj.injectAuthMock(() => FakeUserRepository());

  Finder loginBtn = find.byType(FlatButton);
  Finder loginTextField = find.byType(TextField);

  //Isolate the login page to test it
  final Widget loginPage = TopWidget(
    builder: (_) => MaterialApp(
      initialRoute: 'login',
      routes: {
        '/posts': (_) => Text('This is the HomePage'),
        '/': (_) => LoginPage(),
      },
      navigatorKey: RM.navigate.navigatorKey,
    ),
  );

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
    expect(userInj.hasData, isTrue);
    expect(userInj.state.id, equals(1));

    //await page animation to finish
    await tester.pumpAndSettle();
    expect(find.text('This is the HomePage'), findsOneWidget);
    RM.navigate.back();
    await tester.pumpAndSettle();

    //enter 2,
    await tester.enterText(loginTextField, '2');

    await tester.tap(loginBtn);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(userInj.hasData, isTrue);
    expect(userInj.state.id, equals(2));

    //await page animation to finish
    await tester.pumpAndSettle();
    expect(find.text('This is the HomePage'), findsOneWidget);
  });
}
```

see the test folder for all other tests