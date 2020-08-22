# clean_architecture_dane_mackier_app using global functional injection

This is the same example as example 7-1 rewritten to use global functional injection instead of injection with Injector.

Regarding the clean architecture I use, the `domain`, `service`, `data_source` layers remain untouched.

In the UI I removed any Injector related staff and replace it with what I called reference injection.

## file: lib/injected.dart

```dart
//first inject the Api which implements of IApi interface.
final _api = RM.inject(
  () => Api(),
);

final authenticationService = RM.inject(
  () => AuthenticationService(api: _api.state),
);

final postsService = RM.inject(
  () => PostsService(api: _api.state),
);

final commentsService = RM.inject(
  () => CommentsService(api: _api.state),
);
```

Here is what we can do with `RM.inject` static method.

```dart
Injected<T> RM.inject<T>(
  //the creation Function
  T Function() creationFunction, 
  {
    //Injected models are automatically cleaned when they no longer listened to.
    //You can set autoClean to false if you want to preserve your model state.
    bool autoClean = true, 
    //Execute side effect when the model emits notification with data
    //onDate exposes the current state (data)
    void Function(T state) onData, 
    //Execute side effect when the model emits notification with an error
    void Function(dynamic, StackTrace) onError, 
    //Execute side effect when the model is waiting for an async task
    void Function() onWaiting, 
    //Although injected models are automatically cleaned you can do further cleaning
    //with onDisposed method
    void Function(T state) onDisposed
  })
```
To listen to an injected model, you can use rebuilder, `whenRebuilder`, or `whenRebuilderOR` methods:

example:

## file: lib\ui\pages\post_page\like_button.dart
```dart
  postsService.rebuilder(
    (s) => Text('Likes ${s.getPostLikes(postId)}'),
  ),
```

## file: lib\ui\pages\post_page\comments.dart
```dart
  commentsService.whenRebuilder(
   initState: (_) => commentsService.setState(
     (state) => state.fetchComments(postId),
     onError: ErrorHandler.showErrorDialog,
   ),
   onIdle: () => Container(),
   onWaiting: () => Center(child: CircularProgressIndicator()),
   onError: (_) => Container(),
   onData: (commentsService) {
     return Expanded(
       child: ListView(
         children: commentsService.comments
             .map((comment) => CommentItem(comment))
             .toList(),
       ),
     );
   },
 );
```

## file: lib\ui\pages\login_page\login_page.dart
```dart
 authenticationService.whenRebuilderOr(
   onWaiting: () => CircularProgressIndicator(),
   dispose: (_) => controller.dispose(),
   builder: (authService) {
     return FlatButton(
       color: Colors.white,
       child: Text(
         'Login',
         style: TextStyle(color: Colors.black),
       ),
       onPressed: () {
         authenticationService.setState(
           (s) => s.login(controller.text),
           onError: ErrorHandler.showSnackBar,
           onData: (context, authServiceRM) {
             Navigator.pushNamed(context, '/');
           },
         );
       },
     );
   },
 ),
```

to notify an injected model you use `setState` or state setter:

```dart
onPressed: () {
  authenticationService.setState(
    (s) => s.login(controller.text),
    onError: ErrorHandler.showSnackBar,
    onData: (context, authServiceRM) {
      Navigator.pushNamed(context, '/');
    },
  );
},
```

Using reference injection simplifies testing:

```dart
  setUp(() {
    //Inject a fake service
    authenticationService.injectMock = () => FakeAuthenticationService();
    postsService.injectMock = () => FakePostsService();
    homePage = MaterialApp(
      routes: {
        '/': (_) => HomePage(),
        'post': (context) {
          postsPageContext = context;
          return Scaffold(body: Text('This is post detail page is displayed'));
        },
      },
    );
  });

  testWidgets(
      'display CircularProgressIndicator at startup and show error dialog on NetworkErrorException',
      (tester) async {
    await tester.pumpWidget(homePage);

    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    //set PostsService to throw NetworkErrorException
    (postsService.state as FakePostsService).error = NetworkErrorException();
    final String errorMessage = NetworkErrorException().message;

    await tester.pump(Duration(seconds: 1));
    // Expect to see AlertDialog
    expect(find.byType(AlertDialog), findsOneWidget);
    //Expect to see 'A NetWork problem' message
    expect(find.text(errorMessage), findsOneWidget);

    await tester.pumpAndSettle();
  });
```