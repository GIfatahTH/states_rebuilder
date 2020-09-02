import 'package:clean_architecture_dane_mackier_app/domain/entities/comment.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/post.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/user.dart';
import 'package:clean_architecture_dane_mackier_app/domain/value_objects/email.dart';
import 'package:clean_architecture_dane_mackier_app/service/authentication_service.dart';
import 'package:clean_architecture_dane_mackier_app/service/comments_service.dart';
import 'package:clean_architecture_dane_mackier_app/service/exceptions/fetch_exception.dart';
import 'package:clean_architecture_dane_mackier_app/service/posts_service.dart';
import 'package:clean_architecture_dane_mackier_app/ui/pages/post_page/post_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture_dane_mackier_app/injected.dart';

void main() {
  Widget postPage;
  //The post called from the homePage
  Post postFromHomePage;

  authenticationService.injectMock(() => FakeAuthenticationService());
  postsService.injectMock(() => FakePostsService());
  commentsService.injectMock(() => FakeCommentsService());
  setUp(
    () {
      postPage = MaterialApp(
        home: PostPage(
          post: postFromHomePage = postsService.state.posts[0],
        ),
      );
    },
  );

  testWidgets('display post and user info at start up', (tester) async {
    await tester.pumpWidget(postPage);
    //Expect to see the post title and body
    expect(find.text(postFromHomePage.title), findsOneWidget);
    expect(find.text(postFromHomePage.body), findsOneWidget);
    // Expect to see the user name
    expect(find.text('by FakeUserName'), findsOneWidget);
    // Expect to see likes number
    expect(find.text('Likes 0'), findsOneWidget);
    //Expect to see CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'display CircularProgressIndicator at startup then test error on NetworkErrorException',
      (tester) async {
    await tester.pumpWidget(postPage);
    //Expect to see CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    (commentsService.state as FakeCommentsService).error =
        NetworkErrorException();
    final errorMessage = NetworkErrorException().message;
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets(
      'display CircularProgressIndicator at startup then test error on CommentNotFoundException',
      (tester) async {
    await tester.pumpWidget(postPage);
    //Expect to see CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    (commentsService.state as FakeCommentsService).error =
        CommentNotFoundException(1);
    final errorMessage = CommentNotFoundException(1).message;
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets(
      'display CircularProgressIndicator at startup then comments on succuss',
      (tester) async {
    await tester.pumpWidget(postPage);
    //Expect to see CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    //Expect to see the first comment
    expect(find.text('FakeCommentName1'), findsOneWidget);
    expect(find.text('FakeCommentBody1'), findsOneWidget);
    //Expect to see the second comment
    expect(find.text('FakeCommentName2'), findsOneWidget);
    expect(find.text('FakeCommentBody2'), findsOneWidget);
    //Expect to see the third comment
    expect(find.text('FakeCommentName3'), findsOneWidget);
    expect(find.text('FakeCommentBody3'), findsOneWidget);
  });

  testWidgets('display update like value after tapping on like button',
      (tester) async {
    await tester.pumpWidget(postPage);
    //Expect to see CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // Expect to see 0 likes number
    expect(find.text('Likes 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.thumb_up));
    await tester.pump();

    // Expect to see 0 likes number
    expect(find.text('Likes 1'), findsOneWidget);
  });
}

class FakeAuthenticationService extends AuthenticationService {
  @override
  User get user => User(id: 1, name: 'FakeUserName', username: 'FakeUserName');
}

class FakeCommentsService extends CommentsService {
  var error;
  List<Comment> _comments;
  List<Comment> get comments => _comments;

  Future<void> fetchComments(int postId) async {
    await Future.delayed(Duration(seconds: 1));
    if (error != null) {
      throw error;
    }
    _comments = [
      Comment(
          id: 1,
          name: 'FakeCommentName1',
          body: 'FakeCommentBody1',
          email: Email('fake1@mail.com'),
          postId: postId),
      Comment(
          id: 2,
          name: 'FakeCommentName2',
          body: 'FakeCommentBody2',
          email: Email('fake2@mail.com'),
          postId: postId),
      Comment(
          id: 3,
          name: 'FakeCommentName3',
          body: 'FakeCommentBody3',
          email: Email('fake3@mail.com'),
          postId: postId),
    ];
  }
}

class FakePostsService extends PostsService {
  List<Post> _posts = [
    Post(id: 1, likes: 0, title: 'Post1 title', body: 'Post1 body', userId: 1),
    Post(id: 2, likes: 0, title: 'Post2 title', body: 'Post2 body', userId: 1),
    Post(id: 3, likes: 0, title: 'Post3 title', body: 'Post3 body', userId: 1),
  ];
  @override
  List<Post> get posts => _posts;

  @override
  int getPostLikes(postId) {
    return _posts.firstWhere((post) => post.id == postId).likes;
  }

  @override
  void incrementLikes(int postId) {
    _posts.firstWhere((post) => post.id == postId).incrementLikes();
  }
}
