import 'package:ex_006_5_navigation/ex02_imperative_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

late InjectedNavigator navigator;

final Map<String, Widget Function(RouteData)> routes = {
  '/': (data) => data.redirectTo('/books'),
  '/books': (data) => BooksListScreen(books: books),
  '/books/:id': (data) {
    try {
      final String bookId = data.pathParams['id'] as String;
      final Book book = books[int.parse(bookId)];
      return BookDetailsScreen(book: book);
    } catch (e) {
      return data.unKnownRoute;
    }
  },
};

class BooksApp extends StatelessWidget {
  const BooksApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routeInformationParser: navigator.routeInformationParser,
      routerDelegate: navigator.routerDelegate,
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;

  const BooksListScreen({
    Key? key,
    required this.books,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () {
                final bookId = books.indexOf(book);
                navigator.to('/books/$bookId');
              },
            )
        ],
      ),
    );
  }
}

void main() {
  testWidgets(
    'Initial known location',
    (tester) async {
      navigator = RM.injectNavigator(
        initialLocation: '/books/2',
        routes: routes,
      );
      await tester.pumpWidget(const BooksApp());
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
    },
  );

  testWidgets(
    'Initial unknown location',
    (tester) async {
      navigator = RM.injectNavigator(
        initialLocation: '/books/404',
        routes: routes,
      );
      await tester.pumpWidget(const BooksApp());
      expect(find.text('/books/404 not found'), findsOneWidget);
      //
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(BooksListScreen), findsOneWidget);
      expect(navigator.routeData.location, '/books');
      expect(navigator.routeData.uri.path, '/books');
    },
  );

  testWidgets(
    'Initial unknown location with ignore unknown routes',
    (tester) async {
      navigator = RM.injectNavigator(
        initialLocation: '/books/404',
        ignoreUnknownRoutes: true,
        routes: routes,
      );
      await tester.pumpWidget(const BooksApp());
      expect(find.text('/books/404 not found'), findsOneWidget);
      //
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(BooksListScreen), findsOneWidget);
      expect(navigator.routeData.location, '/books');
      expect(navigator.routeData.uri.path, '/books');
      //
      navigator.deepLinkTest('/books/404');
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.byType(BooksListScreen), findsOneWidget);
      expect(navigator.routeData.location, '/books');
      expect(navigator.routeData.uri.path, '/books');
    },
  );
}
