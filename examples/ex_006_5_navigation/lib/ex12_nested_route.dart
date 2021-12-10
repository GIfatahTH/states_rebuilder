import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(const MyApp());

final navigator = RM.injectNavigator(
  builder: (route) {
    return HomeScreen(route);
  },
  routes: {
    '/': (data) => data.redirectTo('/books'),
    '/books': (data) => RouteWidget(
          builder: (_) {
            return const BooksScreen();
          },
          routes: {
            '/': (data) {
              return const BooksHomeScreen();
            },
            '/authors': (data) {
              return const BookAuthorsScreen();
            },
            '/genres': (data) {
              return const BookGenresScreen();
            },
          },
        ),
    '/articles': (data) => RouteWidget(
          builder: (route) {
            return const ArticlesScreen();
          },
          routes: {
            '/': (data) => const ArticlesHomeScreen(),
            '/authors': (data) => const ArticleAuthorsScreen(),
            '/genres': (data) => const ArticleGenresScreen(),
          },
        ),
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: navigator.routeInformationParser,
      routerDelegate: navigator.routerDelegate,
    );
  }
}

class MenuButton extends ReactiveStatelessWidget {
  const MenuButton({
    Key? key,
    required this.to,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final String to;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => navigator.to(to),
      style: ButtonStyle(
        backgroundColor: navigator.routeData.location.startsWith(to)
            ? MaterialStateProperty.all<Color>(Colors.green)
            : MaterialStateProperty.all<Color>(Colors.blue),
      ),
      child: child,
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Widget c;

  const HomeScreen(this.c, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: navigator.canPop
            ? BackButton(
                onPressed: () => navigator.back(),
              )
            : const SizedBox.shrink(),
        title: const Text('Home'),
      ),
      body: Row(
        children: [
          Container(
            color: Colors.blue[300],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const [
                MenuButton(
                  to: '/books',
                  child: Text('Books'),
                ),
                SizedBox(height: 16.0),
                MenuButton(
                  to: '/articles',
                  child: Text('Articles'),
                ),
              ],
            ),
          ),
          Container(width: 1, color: Colors.blue),
          Expanded(child: context.routerOutlet),
        ],
      ),
    );
  }
}

class BooksScreen extends StatelessWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: Row(
        children: [
          Container(
            color: Colors.blue[300],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const [
                MenuButton(
                  to: '/books/authors',
                  child: Text('Book Authors'),
                ),
                SizedBox(height: 16.0),
                MenuButton(
                  to: '/books/genres',
                  child: Text('Book Genres'),
                ),
              ],
            ),
          ),
          Container(width: 1, color: Colors.blue),
          Expanded(child: context.routerOutlet),
        ],
      ),
    );
  }
}

class BooksHomeScreen extends StatelessWidget {
  const BooksHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books Home'),
      ),
    );
  }
}

class BookAuthorsScreen extends StatelessWidget {
  const BookAuthorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Authors'),
      ),
    );
  }
}

class BookGenresScreen extends StatelessWidget {
  const BookGenresScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Genres'),
      ),
    );
  }
}

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: Row(
        children: [
          Container(
            color: Colors.blue[300],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: const [
                MenuButton(
                  to: '/articles/authors',
                  child: Text('Article Authors'),
                ),
                SizedBox(height: 16.0),
                MenuButton(
                  to: '/articles/genres',
                  child: Text('Article Genres'),
                ),
              ],
            ),
          ),
          Container(width: 1, color: Colors.blue),
          Expanded(child: context.routerOutlet),
        ],
      ),
    );
  }
}

class ArticlesHomeScreen extends StatelessWidget {
  const ArticlesHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles Home'),
      ),
    );
  }
}

class ArticleAuthorsScreen extends StatelessWidget {
  const ArticleAuthorsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Authors'),
      ),
    );
  }
}

class ArticleGenresScreen extends StatelessWidget {
  const ArticleGenresScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Genres'),
      ),
    );
  }
}
