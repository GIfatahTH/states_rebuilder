import 'package:clean_architecture_dane_mackier_app/domain/entities/post.dart';
import 'package:clean_architecture_dane_mackier_app/domain/entities/user.dart';
import 'package:clean_architecture_dane_mackier_app/service/exceptions/fetch_exception.dart';
import 'package:clean_architecture_dane_mackier_app/ui/pages/login_page/login_page.dart';
import 'package:clean_architecture_dane_mackier_app/ui/pages/posts_page/posts_page.dart';
import 'package:clean_architecture_dane_mackier_app/ui/pages/comments_page/comments_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../data_source/fake_api.dart';

void main() {
  setUp(() {
    userInj.injectMock(
      () => User(id: 1, name: 'fakeName', username: 'fakeUserName'),
    );
    postsInj.injectMock(
      () => [
        Post(id: 1, title: 'Post1 title', body: 'Post1 body', userId: 1),
        Post(id: 2, title: 'Post2 title', body: 'Post2 body', userId: 1),
        Post(id: 3, title: 'Post3 title', body: 'Post3 body', userId: 1),
      ],
    );
    commentsInj.injectCRUDMock(() => FakeCommentRepository());
  });

  late Post postFromHomePage;
  Widget postPage = TopAppWidget(
    builder: (_) => MaterialApp(
      home: CommentsPage(
        post: postFromHomePage = postsInj.state[0],
      ),
      navigatorKey: RM.navigate.navigatorKey,
    ),
  );

  testWidgets('display post and user info at start up', (tester) async {
    await tester.pumpWidget(postPage);
    //Expect to see the post title and body
    expect(find.text(postFromHomePage.title), findsOneWidget);
    expect(find.text(postFromHomePage.body), findsOneWidget);
    // Expect to see the user name
    expect(find.text('by fakeName'), findsOneWidget);
    // Expect to see likes number
    expect(find.text('Likes 0'), findsOneWidget);
    //Expect to see CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets(
      'display CircularProgressIndicator at startup then test error on NetworkErrorException',
      (tester) async {
    commentsInj.injectCRUDMock(
      () => FakeCommentRepository(
        error: NetworkErrorException(),
      ),
    );

    await tester.pumpWidget(postPage);
    //Expect to see CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final errorMessage = NetworkErrorException().message;
    await tester.pumpAndSettle();

    expect(find.text(errorMessage), findsNWidgets(2));
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets(
      'display CircularProgressIndicator at startup then test error on CommentNotFoundException',
      (tester) async {
    commentsInj.injectCRUDMock(
      () => FakeCommentRepository(error: CommentNotFoundException(1)),
    );

    await tester.pumpWidget(postPage);
    //Expect to see CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final errorMessage = CommentNotFoundException(1).message;
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(errorMessage), findsNWidgets(2));
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
