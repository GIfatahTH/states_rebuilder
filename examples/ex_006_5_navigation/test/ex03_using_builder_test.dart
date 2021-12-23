import 'package:ex_006_5_navigation/ex03_using_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final backButtonTransparent = find.byWidgetPredicate(
    (widget) => widget is BackButton && widget.color == Colors.transparent,
  );

  final book1Bold = find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data == 'Book 1' &&
        widget.style?.fontWeight == FontWeight.bold,
  );
  final book2Bold = find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data == 'Book 2' &&
        widget.style?.fontWeight == FontWeight.bold,
  );
  final book3Bold = find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data == 'Book 3' &&
        widget.style?.fontWeight == FontWeight.bold,
  );
  testWidgets(
    'Test navigation logic',
    (tester) async {
      await tester.pumpWidget(const BooksApp());

      expect(find.byType(ListTile), findsNWidgets(3));
      expect(backButtonTransparent, findsOneWidget);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsNothing);
      //
      await tester.tap(find.text('Ursula K. Le Guin'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsOneWidget);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsNothing);
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(backButtonTransparent, findsOneWidget);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsNothing);
      //
      await tester.tap(find.text('Ada Palmer'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsOneWidget);
      expect(book3Bold, findsNothing);
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(backButtonTransparent, findsOneWidget);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsNothing);
      //
      await tester.tap(find.text('Book 1'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Ursula K. Le Guin'), findsOneWidget);
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsOneWidget);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsNothing);
      //
      await tester.tap(find.text('Book 2'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Ada Palmer'), findsOneWidget);
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsOneWidget);
      expect(book3Bold, findsNothing);
      //
      await tester.tap(find.text('Book 3'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Octavia E. Butler'), findsOneWidget);
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsOneWidget);
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(backButtonTransparent, findsOneWidget);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsNothing);
      //
      await tester.tap(find.text('Book 3'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Octavia E. Butler'), findsOneWidget);
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsOneWidget);
      //
      await tester.tap(find.text('Unknown book'));
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsNothing);
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsNothing);
      expect(find.text('/books/3 not found'), findsOneWidget);
      expect(navigator.routeData.location, '/books/3');
      //
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(backButtonTransparent, findsOneWidget);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsNothing);
      expect(navigator.routeData.location, '/books');
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
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsOneWidget);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsNothing);
      //
      navigator.deepLinkTest('/books/1');
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Ada Palmer'), findsOneWidget);
      expect(find.text('Too Like the Lightning'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/1');
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsOneWidget);
      expect(book3Bold, findsNothing);
      //
      navigator.deepLinkTest('/books/2');
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Octavia E. Butler'), findsOneWidget);
      expect(find.text('Kindred'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/2');
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsOneWidget);
      //
      navigator.deepLinkTest('/books/3');
      await tester.pumpAndSettle();
      expect(find.text('/books/3 not found'), findsOneWidget);
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsNothing);
      //
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Octavia E. Butler'), findsOneWidget);
      expect(find.text('Kindred'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/2');
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsNothing);
      expect(book3Bold, findsOneWidget);
      //
      navigator.back();
      await tester.pumpAndSettle();
      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Ada Palmer'), findsOneWidget);
      expect(find.text('Too Like the Lightning'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(navigator.routeData.location, '/books/1');
      expect(backButtonTransparent, findsNothing);
      expect(book1Bold, findsNothing);
      expect(book2Bold, findsOneWidget);
      expect(book3Bold, findsNothing);
      //
    },
  );
}
