import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:ex_006_5_navigation/ex18_books_app.dart';
import 'package:ex_006_5_navigation/ex16_books_app/screens/author_details_page/author_details_page.dart';
import 'package:ex_006_5_navigation/ex16_books_app/screens/author_page/author_page.dart';
import 'package:ex_006_5_navigation/ex16_books_app/screens/book_details_page/book_details_page.dart';
import 'package:ex_006_5_navigation/ex16_books_app/screens/book_store_scaffold.dart';
import 'package:ex_006_5_navigation/ex16_books_app/screens/books_page/books_page.dart';
import 'package:ex_006_5_navigation/ex16_books_app/screens/error_page/error_page.dart';
import 'package:ex_006_5_navigation/ex16_books_app/screens/settings_page/settings_page.dart';
import 'package:ex_006_5_navigation/ex16_books_app/screens/sign_in_page/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final booksIcon = find.byWidgetPredicate((widget) =>
      widget is AdaptiveNavigationScaffold && widget.selectedIndex == 0);
  final authorsIcon = find.byWidgetPredicate((widget) =>
      widget is AdaptiveNavigationScaffold && widget.selectedIndex == 1);
  final settingsIcon = find.byWidgetPredicate((widget) =>
      widget is AdaptiveNavigationScaffold && widget.selectedIndex == 2);

  void checkMainMenu(Finder? finder) {
    for (var f in [booksIcon, authorsIcon, settingsIcon]) {
      if (f == finder) {
        expect(f, findsOneWidget);
      } else {
        expect(f, findsNothing);
      }
    }
  }

  final popularIcon = find.byWidgetPredicate(
      (widget) => widget is TabBar && widget.controller!.index == 0);
  final newIcon = find.byWidgetPredicate(
      (widget) => widget is TabBar && widget.controller!.index == 1);
  final allIcon = find.byWidgetPredicate(
      (widget) => widget is TabBar && widget.controller!.index == 2);

  void checkTabsMenu(Finder? finder) {
    for (var f in [popularIcon, newIcon, allIcon]) {
      if (f == finder) {
        expect(f, findsOneWidget);
      } else {
        expect(f, findsNothing);
      }
    }
  }

  testWidgets(
    'WHEN app starts SignInScreen is displayed '
    'And WHEN user signs in, app is routed to BooksScreen'
    'AND popular books are displayed',
    (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(SignInScreen), findsOneWidget);
      checkMainMenu(null);
      checkTabsMenu(null);
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.byType(BookstoreScaffold), findsOneWidget);
      expect(find.byType(BooksScreen), findsOneWidget);
      checkMainMenu(booksIcon);
      checkTabsMenu(popularIcon);
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Kindred'), findsOneWidget);
    },
  );
  testWidgets(
    'Test main menu navigation',
    (tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.byType(BookstoreScaffold), findsOneWidget);
      expect(find.byType(BooksScreen), findsOneWidget);
      checkMainMenu(booksIcon);
      checkTabsMenu(popularIcon);
      expect(navigator.pageStack.length, 1);
      expect(navigator.pageStack.first.getSubPages.length, 1);
      //
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.byType(BookstoreScaffold), findsOneWidget);
      expect(find.byType(AuthorsScreen), findsOneWidget);
      checkMainMenu(authorsIcon);
      checkTabsMenu(null);
      expect(find.byType(ListTile), findsNWidgets(3));
      //
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(BookstoreScaffold), findsOneWidget);
      expect(find.byType(SettingsScreen), findsOneWidget);
      checkMainMenu(settingsIcon);
      checkTabsMenu(null);
      //
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      checkMainMenu(authorsIcon);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      checkMainMenu(settingsIcon);
      await tester.tap(find.byIcon(Icons.person));
      await tester.pump();
      checkMainMenu(authorsIcon);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      checkMainMenu(settingsIcon);
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      expect(navigator.pageStack.length, 1);
      expect(navigator.pageStack.first.getSubPages.length, 8);
    },
  );
  testWidgets(
    'WHEN user sign out '
    'THEN the app navigate to SignInScreen',
    (tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(popularIcon);
      expect(navigator.pageStack.last.name, '/books/popular');
      //
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      checkMainMenu(settingsIcon);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(navigator.pageStack.last.name, '/signin');
      expect(find.byType(SignInScreen), findsOneWidget);
      //
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(popularIcon);
      expect(navigator.pageStack.length, 1);
      expect(navigator.pageStack.last.name, '/books/popular');
    },
  );

  testWidgets(
    'Test TabBar menu navigation',
    (tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(popularIcon);
      expect(navigator.pageStack.last.name, '/books/popular');
      //
      await tester.tap(find.byIcon(Icons.new_releases));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(newIcon);
      expect(navigator.pageStack.last.name, '/books/new', skip: true);
      expect(navigator.routeData.location, '/books/new');
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Ada Palmer'), findsOneWidget);
      //
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(allIcon);
      expect(navigator.pageStack.last.name, '/books/all', skip: true);
      expect(navigator.routeData.location, '/books/all');
      expect(find.byType(ListTile), findsNWidgets(4));
    },
  );

  testWidgets(
    'Test get book detail',
    (tester) async {
      await tester.pumpWidget(const App());
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(popularIcon);
      expect(navigator.pageStack.last.name, '/books/popular');
      //
      await tester.tap(find.text('Left Hand of Darkness'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      checkMainMenu(null);
      checkTabsMenu(null);
      expect(navigator.pageStack.last.name, '/book/0');
      expect(find.text('Left Hand of Darkness'), findsNWidgets(2));
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(popularIcon);
      expect(navigator.pageStack.last.name, '/books/popular');
      //
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(allIcon);
      expect(navigator.routeData.location, '/books/all');
      //
      await tester.tap(find.text('The Lathe of Heaven'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      checkMainMenu(null);
      checkTabsMenu(null);
      expect(navigator.pageStack.last.name, '/book/3');
      expect(find.text('The Lathe of Heaven'), findsNWidgets(2));
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(allIcon);
      expect(navigator.routeData.location, '/books/all');
      //
      await tester.tap(find.byIcon(Icons.new_releases));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(newIcon);
      expect(navigator.routeData.location, '/books/new');
      //
      await tester.tap(find.text('Too Like the Lightning'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      checkMainMenu(null);
      checkTabsMenu(null);
      expect(navigator.pageStack.last.name, '/book/1');
      expect(find.text('Too Like the Lightning'), findsNWidgets(2));
      //
      await tester.tap(find.text('View author (navigator.toPageless)'));
      await tester.pumpAndSettle();
      expect(find.byType(AuthorDetailsScreen), findsOneWidget);
      checkMainMenu(null);
      checkTabsMenu(null);
      expect(navigator.pageStack.last.name, '/book/1');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View author (navigator.to)'));
      await tester.pumpAndSettle();
      expect(find.byType(AuthorDetailsScreen), findsOneWidget);
      checkMainMenu(null);
      checkTabsMenu(null);
      expect(navigator.pageStack.last.name, '/author/1');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View author (Link)'));
      await tester.pumpAndSettle();
      // await tester.pumpAndSettle(const Duration(milliseconds: 1000));
      // // expect(find.byType(AuthorDetailsScreen), findsOneWidget);
      // checkMainMenu(null);
      // checkTabsMenu(null);
      // expect(navigator.pageStack.last.name, '/author/1');
    },
  );

  testWidgets(
    'Test deep links',
    (tester) async {
      await tester.pumpWidget(const App());
      navigator.deepLinkTest('/books/popular');
      await tester.pumpAndSettle();
      checkMainMenu(null);
      checkTabsMenu(null);
      expect(navigator.pageStack.last.name, '/signin');
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(popularIcon);
      expect(navigator.pageStack.last.name, '/books/popular');
      //
      navigator.deepLinkTest('/books/popular');
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(popularIcon);
      expect(navigator.pageStack.last.name, '/books/popular');
      //
      navigator.deepLinkTest('/books/new4');
      await tester.pumpAndSettle();
      expect(find.byType(ErrorScreen), findsOneWidget);
      checkTabsMenu(null);
      expect(navigator.pageStack.last.name, '/books/new4');

      //
      navigator.deepLinkTest('/books/popular');
      await tester.pumpAndSettle();
      checkMainMenu(booksIcon);
      checkTabsMenu(popularIcon);
      expect(navigator.pageStack.last.name, '/books/popular');
      //
      navigator.deepLinkTest('/books/new/404');
      await tester.pumpAndSettle();
      expect(find.byType(ErrorScreen), findsOneWidget);
      checkTabsMenu(null);
      expect(navigator.pageStack.last.name, '/books/new/404');
    },
  );
}
