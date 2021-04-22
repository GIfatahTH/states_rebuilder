import 'package:clean_architecture_dane_mackier_app/domain/entities/user.dart';
import 'package:clean_architecture_dane_mackier_app/service/exceptions/fetch_exception.dart';
import 'package:clean_architecture_dane_mackier_app/ui/pages/posts_page/posts_page.dart';
import 'package:clean_architecture_dane_mackier_app/ui/pages/login_page/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../data_source/fake_api.dart';

void main() {
  final Widget postsPage = TopAppWidget(
    builder: (_) => MaterialApp(
      initialRoute: '/posts',
      routes: {
        '/posts': (_) => PostsPage(),
        '/comments': (context) {
          return Scaffold(body: Text('This is post detail page is displayed'));
        },
      },
      navigatorKey: RM.navigate.navigatorKey,
    ),
  );

  setUp(() {
    userInj.injectMock(
      () => User(id: 1, name: 'fakeName', username: 'fakeUserName'),
    );

    postsInj.injectCRUDMock(
      () => FakePostRepository(),
    );
  });
  testWidgets(
      'display CircularProgressIndicator at startup and show error dialog on NetworkErrorException',
      (tester) async {
    postsInj.injectCRUDMock(
      () => FakePostRepository(
        error: NetworkErrorException(),
      ),
    );

    await tester.pumpWidget(postsPage);

    //Expect to see a CircularProgressIndicator
    // expect(find.byType(CircularProgressIndicator), findsOneWidget);

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
    postsInj.injectCRUDMock(() => FakePostRepository(
          error: PostNotFoundException(1),
        ));

    await tester.pumpWidget(postsPage);

    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

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
    await tester.pumpWidget(postsPage);

    //Expect to see a CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(Duration(seconds: 1));

    //Expect to see 'Welcome FakeName' text
    expect(find.text('Welcome fakeName'), findsOneWidget);
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
    await tester.pumpWidget(postsPage);
    await tester.pumpAndSettle();
    // await tester.pump(Duration(seconds: 1));
    //tap on post1 to see the detail
    await tester.tap(find.text('Post1 title - 0'));
    // await until page animation transition finished
    await tester.pumpAndSettle();

    //
    //Expect to see that we are in the post detail page
    expect(find.text('This is post detail page is displayed'), findsOneWidget);

    //Simulate we are tapping on like button
    //This is the logic inside the onPressed of the like button
    postsInj.setState((s) => s.incrementLikes(1));

    //Go back to homePage
    RM.navigate.back();

    // await until page animation transition finished
    await tester.pumpAndSettle();
    await tester.pump();
    //Expect that the like number has increased by one.
    expect(find.text('Post1 title - 1'), findsOneWidget);
  });
}
