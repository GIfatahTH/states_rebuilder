# clean_architecture_dane_mackier_app using global functional injection

> Don't forget to run `flutter create .` in the terminal in the project directory to create platform-specific files.

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

## Testing
Using reference injection simplifies testing:

```dart
void main() {
  Widget loginPage;
  Finder loginBtn = find.byType(FlatButton);
  Finder loginTextField = find.byType(TextField);

  setUp(() {
    authenticationService.injectMock(() => FakeAuthenticationService());
    loginPage = MaterialApp(
      initialRoute: 'login',
      routes: {
        '/': (_) => Text('This is the HomePage'),
        'login': (_) => LoginPage(),
      },
    );
  });

  testWidgets('display "The entered value is not a number" message',
      (tester) async {
    await tester.pumpWidget(loginPage);
    final String notNumberError = NotNumberException().message;
    // before tap, no error message
    expect(find.text(notNumberError), findsNothing);

    await tester.tap(loginBtn);
    await tester.pump();
    //after tap, error message appears
    expect(find.text(notNumberError), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);

    //enter non number string,
    await tester.enterText(loginTextField, '1m');

    await tester.tap(loginBtn);
    await tester.pump();
    //after tap, error message appears
    expect(find.text(notNumberError), findsNWidgets(2));
    expect(find.byType(SnackBar), findsOneWidget);
  });
```

see test folder fro all other tests