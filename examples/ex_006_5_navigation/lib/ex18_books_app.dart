import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'ex16_books_app/data_source/library.dart';
import 'ex16_books_app/screens/author_details_page/author_details_page.dart';
import 'ex16_books_app/screens/author_page/author_page.dart';
import 'ex16_books_app/screens/book_details_page/book_details_page.dart';
import 'ex16_books_app/screens/book_store_scaffold.dart';
import 'ex16_books_app/screens/books_page/books_page.dart';
import 'ex16_books_app/screens/error_page/error_page.dart';
import 'ex16_books_app/screens/settings_page/settings_page.dart';
import 'ex16_books_app/screens/sign_in_page/sign_in_bloc.dart';
import 'ex16_books_app/screens/sign_in_page/sign_in_page.dart';

// The flutter example book app rewritten using states_rebuilder

Widget fadeTransitionBuilder(context, animation, secondaryAnimation, child) {
  var curveTween = CurveTween(curve: Curves.easeIn);
  return FadeTransition(
    opacity: animation.drive(curveTween),
    child: child,
  );
}

final navigator = RM.injectNavigator(
    transitionsBuilder: fadeTransitionBuilder,
    routes: {
      '/signin': (_) => const SignInScreen(),
      '/': (data) {
        return RouteWidget(
          builder: (_) => const BookstoreScaffold(),
          routes: {
            '/': (data) => data.redirectTo('/books'),
            '/books': (data) => data.redirectTo('/books/popular'),
            '/books/:kind(new|all|popular)': (data) => const BooksScreen(),
            '/authors': (data) => const AuthorsScreen(),
            '/settings': (data) => const SettingsScreen(),
          },
        );
      },
      '/book/:bookId': (data) {
        try {
          final bookId = data.pathParams['bookId']!;
          final selectedBook = libraryInstance.allBooks
              .firstWhereOrNull((b) => b.id.toString() == bookId);
          return BookDetailsScreen(book: selectedBook!);
        } catch (e) {
          return data.unKnownRoute;
        }
      },
      '/author/:authorId': (data) {
        try {
          final authorId = data.pathParams['authorId']!;
          final selectedAuthor = libraryInstance.allAuthors.firstWhereOrNull(
            (a) => a.id.toString() == authorId,
          );
          return AuthorDetailsScreen(author: selectedAuthor!);
        } catch (e) {
          return data.unKnownRoute;
        }
      },
    },
    unknownRoute: (data) => ErrorScreen(data.location),
    onNavigate: (routeData) {
      final signedIn = signInBloc.isSignedIn;
      final signingIn = routeData.location == '/signin';

      // Go to /signin if the user is not signed in
      if (!signedIn && !signingIn) {
        return routeData.redirectTo('/signin');
      }
      // Go to /books if the user is signed in and tries to go to /signin.
      else if (signedIn && signingIn) {
        return routeData.redirectTo('/books');
      }
    });

class App extends TopStatelessWidget {
  const App({Key? key}) : super(key: key);
  @override
  void didUnmountWidget() {
    signInBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: navigator.routeInformationParser,
      routerDelegate: navigator.routerDelegate,
    );
  }
}

void main() => runApp(const App());
