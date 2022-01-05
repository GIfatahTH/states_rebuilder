import 'package:ex_006_5_navigation/ex02_imperative_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Test navigation logic',
    (tester) async {
      await tester.pumpWidget(const BooksApp());
      expect(find.byType(BooksListScreen), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(navigator.routeData.location, '/books');
      //
      await tester.tap(find.text('Ursula K. Le Guin'));
      await tester.pumpAndSettle();
      expect(find.byType(BooksListScreen), findsNothing);
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Ursula K. Le Guin'), findsOneWidget);
      expect(find.text('Left Hand of Darkness'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/0');
      expect(navigator.routeData.uri.path, '/books/0');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(BooksListScreen), findsOneWidget);
      expect(navigator.routeData.location, '/books');
      expect(navigator.routeData.uri.path, '/books');
      //
      await tester.tap(find.text('Ada Palmer'));
      await tester.pumpAndSettle();
      expect(find.byType(BooksListScreen), findsNothing);
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Ada Palmer'), findsOneWidget);
      expect(find.text('Too Like the Lightning'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/1');
      expect(navigator.routeData.uri.path, '/books/1');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(BooksListScreen), findsOneWidget);
      expect(navigator.routeData.location, '/books');
      expect(navigator.routeData.uri.path, '/books');
      //
      await tester.tap(find.text('Octavia E. Butler'));
      await tester.pumpAndSettle();
      expect(find.byType(BooksListScreen), findsNothing);
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Octavia E. Butler'), findsOneWidget);
      expect(find.text('Kindred'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/2');
      expect(navigator.routeData.uri.path, '/books/2');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(BooksListScreen), findsOneWidget);
      expect(navigator.routeData.location, '/books');
      expect(navigator.routeData.uri.path, '/books');
      //
    },
  );

  testWidgets(
    'Test deep link',
    (tester) async {
      await tester.pumpWidget(const BooksApp());
      expect(find.byType(BooksListScreen), findsOneWidget);
      navigator.deepLinkTest('/books/0');
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Ursula K. Le Guin'), findsOneWidget);
      expect(find.text('Left Hand of Darkness'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/0');
      //
      navigator.deepLinkTest('/books/1');
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Ada Palmer'), findsOneWidget);
      expect(find.text('Too Like the Lightning'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/1');
      //
      navigator.deepLinkTest('/books/2');
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Octavia E. Butler'), findsOneWidget);
      expect(find.text('Kindred'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/2');
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Ada Palmer'), findsOneWidget);
      expect(find.text('Too Like the Lightning'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/1');
      //
      navigator.back();
      await tester.pumpAndSettle();
      navigator.deepLinkTest('/books/0');
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Ursula K. Le Guin'), findsOneWidget);
      expect(find.text('Left Hand of Darkness'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/0');
      //
      navigator.deepLinkTest('/books/3');
      await tester.pumpAndSettle();
      expect(find.text('/books/3 not found'), findsOneWidget);
    },
  );
}
