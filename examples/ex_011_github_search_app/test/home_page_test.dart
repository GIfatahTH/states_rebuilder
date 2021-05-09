import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_search_app/injected.dart';
import 'package:github_search_app/main.dart';
import 'package:github_search_app/ui/pages/home/github_search_result_tile.dart';

import 'fake_github_search_repository.dart';

void main() {
  isTestMode = true;
  setUp(() {
    gitHubSearchRepository.injectMock(
      () => FakeGitHubSearchRepository(),
    );
  });

  testWidgets(
    'initial build',
    (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();
      expect(find.byKey(Key('__Container__')), findsOneWidget);
    },
  );

  testWidgets(
    'search is works',
    (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'D');
      expect(find.byKey(Key('__Container__')), findsOneWidget);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.byType(GitHubUserSearchResultTile), findsNWidgets(2));
      //
      await tester.enterText(find.byType(TextField), 'Di');
      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.byType(GitHubUserSearchResultTile), findsNWidgets(1));
    },
  );

  testWidgets(
    'search is debounced',
    (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byType(RaisedButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'J');
      expect(find.byKey(Key('__Container__')), findsOneWidget);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(Duration(milliseconds: 1500));
      expect(find.byType(GitHubUserSearchResultTile), findsNWidgets(3));
      //
      await tester.enterText(find.byType(TextField), 'Ja');
      await tester.pump(Duration(milliseconds: 400));
      expect(find.byType(GitHubUserSearchResultTile), findsNWidgets(3));
      await tester.enterText(find.byType(TextField), 'Jan');
      await tester.pump(Duration(milliseconds: 400));
      expect(find.byType(GitHubUserSearchResultTile), findsNWidgets(3));
      await tester.enterText(find.byType(TextField), 'Jani');
      await tester.pump(Duration(milliseconds: 400));
      expect(find.byType(GitHubUserSearchResultTile), findsNWidgets(3));
      await tester.enterText(find.byType(TextField), 'Janin');
      await tester.pump(Duration(milliseconds: 500));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(Duration(seconds: 1));
      expect(find.byType(GitHubUserSearchResultTile), findsNWidgets(2));
      //
    },
  );
}
