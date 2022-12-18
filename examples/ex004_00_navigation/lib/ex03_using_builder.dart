import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// In this example, show the use of the InjectedNavigator.builder method to wrap
// the app inside the body of the scaffold and the appBar that used a fixed
// navigation menu

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
  // Use CupertinoPage instead of the default MaterialPage
  shouldUseCupertinoPage: true,

  // You can ignore all unknown routes and just display the last known route
  // (TODO uncomment the next line and try with web and enter some unknown routes)
  // ignoreUnknownRoutes: true,
  builder: (routerOutlet) {
    return const AppScaffold();
  },
  routes: {
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

class AppScaffold extends StatelessWidget {
  const AppScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final location = context.routeData.location;
    return Scaffold(
      appBar: AppBar(
        leading: IgnorePointer(
          ignoring: !navigator.canPop,
          child: BackButton(
            onPressed: () => navigator.back(),
            color: navigator.canPop
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
        title: Row(
          children: [
            TextButton(
              onPressed: () => navigator.toAndRemoveUntil(
                '/books/0',
                untilRouteName: '/books',
              ),
              child: Text(
                'Book 1',
                style: location == '/books/0'
                    ? const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
            ),
            TextButton(
              onPressed: () => navigator.toAndRemoveUntil(
                '/books/1',
                untilRouteName: '/books',
              ),
              child: Text(
                'Book 2',
                style: location == '/books/1'
                    ? const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
            ),
            TextButton(
              onPressed: () => navigator.setRouteStack(
                (pages) {
                  if (pages.length < 2) {
                    return pages.to('/books/2');
                  }
                  return pages.toReplacement('/books/2');
                },
              ),
              child: Text(
                'Book 3',
                style: location == '/books/2'
                    ? const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
            ),
            TextButton(
              onPressed: () => navigator.toAndRemoveUntil(
                '/books/3',
                untilRouteName: '/books',
              ),
              child: const Text(
                'Unknown book',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: context.routerOutlet,
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
    return ListView(
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.title, style: Theme.of(context).textTheme.headline6),
          Text(book.author, style: Theme.of(context).textTheme.subtitle1),
        ],
      ),
    );
  }
}
