import 'package:clean_architecture_dane_mackier_app/domain/entities/post.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/user.dart';
import 'package:clean_architecture_dane_mackier_app/service/authentication_service.dart';
import 'package:clean_architecture_dane_mackier_app/service/exceptions/fetch_exception.dart';
import 'package:clean_architecture_dane_mackier_app/service/posts_service.dart';
import 'package:clean_architecture_dane_mackier_app/ui/pages/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_dane_mackier_app/injected.dart';

void main() {
  Widget homePage;
  BuildContext postsPageContext;

  authenticationService.injectMock(() => FakeAuthenticationService());
  postsService.injectMock(() => FakePostsService());
  setUp(() {
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

  testWidgets(
      'display CircularProgressIndicator at startup and show error dialog on PostNotFoundException',
      (tester) async {
    await tester.pumpWidget(homePage);

    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    //Set PostsService to throw NetworkErrorException
    (postsService.state as FakePostsService).error = PostNotFoundException(1);
    final String errorMessage = PostNotFoundException(1).message;

    await tester.pump(Duration(seconds: 1));
    //Expect to see AlertDialog
    expect(find.byType(AlertDialog), findsOneWidget);
    //Expect to see 'A NetWork problem' message
    expect(find.text(errorMessage), findsOneWidget);
    //
    await tester.pumpAndSettle();
  });

  testWidgets(
      'display CircularProgressIndicator at startup and user info and posts after success',
      (tester) async {
    await tester.pumpWidget(homePage);

    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    //Expect to see 'Welcome FakeName' text
    expect(find.text('Welcome FakeName'), findsOneWidget);
    //
    //Expect to see post1 title, number of likes and body texts
    expect(find.text('Post1 title - 0'), findsOneWidget);
    expect(find.text('Post1 body'), findsOneWidget);
    //
    //Expect to see post2 title, number of likes and body texts
    expect(find.text('Post2 title - 0'), findsOneWidget);
    expect(find.text('Post2 body'), findsOneWidget);
    //
    //Expect to see post3 title, number of likes and body texts
    expect(find.text('Post3 title - 0'), findsOneWidget);
    expect(find.text('Post3 body'), findsOneWidget);

    //
    await tester.pumpAndSettle();
  });

  testWidgets('Navigate to post detail and increment likes after pop back ',
      (tester) async {
    await tester.pumpWidget(homePage);

    await tester.pump(Duration(seconds: 1));
    //tap on post1 to see the detail
    await tester.tap(find.text('Post1 title - 0'));
    // await until page animation transition finished
    await tester.pumpAndSettle();

    //
    //Expect to see that we are in the post detail page
    expect(find.text('This is post detail page is displayed'), findsOneWidget);

    //Simulate we are tapping on like button
    //This is the logic inside the onPressed of the like button
    postsService.setState((s) => s.incrementLikes(1));

    //Go back to homePage
    Navigator.pop(postsPageContext);

    // await until page animation transition finished
    await tester.pumpAndSettle();
    await tester.pump();
    //Expect that the like number has increased by one.
    expect(find.text('Post1 title - 1'), findsOneWidget);
  });
}

class FakeAuthenticationService extends AuthenticationService {
  @override
  User get user => User(id: 1, name: 'FakeName', username: 'FakeUserName');
}

class FakePostsService extends PostsService {
  List<Post> _posts = [];
  @override
  List<Post> get posts => _posts;

  var error;

  @override
  Future<void> getPostsForUser(int userId) async {
    await Future.delayed(Duration(seconds: 1));

    if (error != null) {
      throw error;
    }

    _posts = [
      Post(
          id: 1,
          likes: 0,
          title: 'Post1 title',
          body: 'Post1 body',
          userId: userId),
      Post(
          id: 2,
          likes: 0,
          title: 'Post2 title',
          body: 'Post2 body',
          userId: userId),
      Post(
          id: 3,
          likes: 0,
          title: 'Post3 title',
          body: 'Post3 body',
          userId: userId),
    ];
  }

  @override
  int getPostLikes(postId) {
    return _posts.firstWhere((post) => post.id == postId).likes;
  }

  @override
  void incrementLikes(int postId) {
    _posts.firstWhere((post) => post.id == postId).incrementLikes();
  }
}
