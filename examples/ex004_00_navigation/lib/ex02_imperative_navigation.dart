import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// The same example as the last one using imperative navigation
void main() {
  runApp(const BooksApp());
}

List<Book> books = [
  Book('Left Hand of Darkness', 'Ursula K. Le Guin'),
  Book('Too Like the Lightning', 'Ada Palmer'),
  Book('Kindred', 'Octavia E. Butler'),
];

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

final navigator = RM.injectNavigator(
  shouldUseCupertinoPage: true,
  // You can try defining the initialLocation the app must land on when
  // first started (TODO: Uncomment the next line and restart the app)
  //
  // initialLocation: '/books/2',
  routes: {
    '/': (data) => data.redirectTo('/books'),
    '/books': (data) => BooksListScreen(books: books),
    '/books/:id': (data) {
      // As deep link may be out of boundary
      // id may be not an integer or it may be greater than the books length
      try {
        final String bookId = data.pathParams['id'] as String;
        final Book book = books[int.parse(bookId)];
        return BookDetailsScreen(book: book);
      } catch (e) {
        // Display the default unKnownRoute screen if the deep link is out of
        // boundary
        return data.unKnownRoute;
      }
    },
  },
);

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

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  const BookDetailsScreen({
    required this.book,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: Theme.of(context).textTheme.headline6),
            Text(book.author, style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}
