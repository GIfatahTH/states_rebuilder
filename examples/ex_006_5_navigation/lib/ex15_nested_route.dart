import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(const MyApp());

final navigator = RM.injectNavigator(
  // initialLocation: '/dashboard/invoices/1/2/3',
  builder: (_) => const Home(),
  transitionsBuilder: RM.transitions.none(),
  // transitionsBuilder: (_, animation, __, child) {
  //   return ScaleTransition(
  //     scale: animation,
  //     child: child,
  //   );
  // },
  // transitionDuration: 1.seconds,
  // shouldUseCupertinoPage: true,
  routes: {
    '/': (data) => data.redirectTo('/dashboard'),
    '/dashboard': (data) => RouteWidget(
          builder: (_) => const Dash(),
          routes: {
            '/': (data) => const DashHome(),
            '/invoices': (data) => RouteWidget(
                  builder: (_) => const Invoices(),
                  routes: {
                    '/': (data) => data.redirectTo('/daily'),
                    // '/': (data) => data.redirectTo('/dashboard/invoices/daily'),
                    // '/': (data) => data.redirectTo('/about'),
                    '/daily': (data) => const DailyInvoices(),
                    '/weekly': (data) => const WeeklyInvoices(),
                    // '/weekly': (data) => data.redirectTo('/dashboard'),
                    '/monthly': (data) => const MonthlyInvoices(),
                  },
                ),
            '/team': (data) => const Team(),
          },
        ),
    '/about': (data) => const About(),
    '/support': (data) => const Support(),
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

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            NavLink(title: 'Dashboard', to: '/dashboard'),
            NavLink(title: 'About', to: '/about'),
            NavLink(title: 'Support', to: '/support'),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: context.routerOutlet,
    );
  }
}

class Dash extends StatelessWidget {
  const Dash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            NavLink(title: 'Home', to: '/dashboard', exact: true),
            NavLink(title: 'Invoices', to: '/dashboard/invoices'),
            NavLink(title: 'Team', to: '/dashboard/team'),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: context.routerOutlet,
    );
  }
}

class DashHome extends StatelessWidget {
  const DashHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'DashHome',
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}

class Invoices extends StatelessWidget {
  const Invoices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Card(
          child: Column(
            children: const [
              NavLink(title: 'Daily', to: '/dashboard/invoices/daily'),
              NavLink(title: 'Weekly', to: '/dashboard/invoices/weekly'),
              NavLink(title: 'Monthly', to: '/dashboard/invoices/monthly'),
            ],
          ),
        ),
        Expanded(child: context.routerOutlet),
      ],
    );
  }
}

class Team extends StatelessWidget {
  const Team({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Center(
        child: Text(
          'Team Page',
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}

class About extends StatelessWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Text(
          'About Page',
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}

class Support extends StatelessWidget {
  const Support({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Center(
        child: Text(
          'Support Page',
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}

class DailyInvoices extends StatelessWidget {
  const DailyInvoices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      child: Center(
        child: Text(
          'Daily Invoices',
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}

class WeeklyInvoices extends StatelessWidget {
  const WeeklyInvoices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      child: Center(
        child: Text(
          'Weekly Invoices',
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}

class MonthlyInvoices extends StatelessWidget {
  const MonthlyInvoices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      child: Center(
        child: Text(
          'Monthly Invoices',
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}

class NavLink extends StatelessWidget {
  const NavLink({
    Key? key,
    required this.title,
    required this.to,
    this.exact = false,
  }) : super(key: key);
  final String title;
  final String to;
  final bool exact;
  @override
  Widget build(BuildContext context) {
    final location = navigator.routeData.location;
    final isActive = exact ? location == to : location.startsWith(to);
    return TextButton(
      onPressed: () => navigator.to(to),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : null,
          decoration: isActive ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}


// final navigator = RM.injectNavigator(
//   builder: (route) {
//     return HomeScreen(route);
//   },
//   routes: {
//     '/': (data) => data.redirectTo('/books'),
//     '/books': (data) => RouteWidget(
//           builder: (_) {
//             return const BooksScreen();
//           },
//           routes: {
//             '/': (data) {
//               return const BooksHomeScreen();
//             },
//             '/authors': (data) {
//               return const BookAuthorsScreen();
//             },
//             '/genres': (data) {
//               return const BookGenresScreen();
//             },
//           },
//         ),
//     '/articles': (data) => RouteWidget(
//           builder: (route) {
//             return const ArticlesScreen();
//           },
//           routes: {
//             '/': (data) => const ArticlesHomeScreen(),
//             '/authors': (data) => const ArticleAuthorsScreen(),
//             '/genres': (data) => const ArticleGenresScreen(),
//           },
//         ),
//   },
// );

// class MenuButton extends ReactiveStatelessWidget {
//   const MenuButton({
//     Key? key,
//     required this.to,
//     required this.child,
//   }) : super(key: key);

//   final Widget child;
//   final String to;

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () => navigator.to(to),
//       style: ButtonStyle(
//         backgroundColor: navigator.routeData.location.startsWith(to)
//             ? MaterialStateProperty.all<Color>(Colors.green)
//             : MaterialStateProperty.all<Color>(Colors.blue),
//       ),
//       child: child,
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   final Widget c;

//   const HomeScreen(this.c, {Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: navigator.canPop
//             ? BackButton(
//                 onPressed: () => navigator.back(),
//               )
//             : const SizedBox.shrink(),
//         title: const Text('Home'),
//       ),
//       body: Row(
//         children: [
//           Container(
//             color: Colors.blue[300],
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: const [
//                 MenuButton(
//                   to: '/books',
//                   child: Text('Books'),
//                 ),
//                 SizedBox(height: 16.0),
//                 MenuButton(
//                   to: '/articles',
//                   child: Text('Articles'),
//                 ),
//               ],
//             ),
//           ),
//           Container(width: 1, color: Colors.blue),
//           Expanded(child: context.routerOutlet),
//         ],
//       ),
//     );
//   }
// }

// class BooksScreen extends StatelessWidget {
//   const BooksScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Books'),
//       ),
//       body: Row(
//         children: [
//           Container(
//             color: Colors.blue[300],
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: const [
//                 MenuButton(
//                   to: '/books/authors',
//                   child: Text('Book Authors'),
//                 ),
//                 SizedBox(height: 16.0),
//                 MenuButton(
//                   to: '/books/genres',
//                   child: Text('Book Genres'),
//                 ),
//               ],
//             ),
//           ),
//           Container(width: 1, color: Colors.blue),
//           Expanded(child: context.routerOutlet),
//         ],
//       ),
//     );
//   }
// }

// class BooksHomeScreen extends StatelessWidget {
//   const BooksHomeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Books Home'),
//       ),
//     );
//   }
// }

// class BookAuthorsScreen extends StatelessWidget {
//   const BookAuthorsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Book Authors'),
//       ),
//     );
//   }
// }

// class BookGenresScreen extends StatelessWidget {
//   const BookGenresScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Book Genres'),
//       ),
//     );
//   }
// }

// class ArticlesScreen extends StatelessWidget {
//   const ArticlesScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Articles'),
//       ),
//       body: Row(
//         children: [
//           Container(
//             color: Colors.blue[300],
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: const [
//                 MenuButton(
//                   to: '/articles/authors',
//                   child: Text('Article Authors'),
//                 ),
//                 SizedBox(height: 16.0),
//                 MenuButton(
//                   to: '/articles/genres',
//                   child: Text('Article Genres'),
//                 ),
//               ],
//             ),
//           ),
//           Container(width: 1, color: Colors.blue),
//           Expanded(child: context.routerOutlet),
//         ],
//       ),
//     );
//   }
// }

// class ArticlesHomeScreen extends StatelessWidget {
//   const ArticlesHomeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Articles Home'),
//       ),
//     );
//   }
// }

// class ArticleAuthorsScreen extends StatelessWidget {
//   const ArticleAuthorsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Article Authors'),
//       ),
//     );
//   }
// }

// class ArticleGenresScreen extends StatelessWidget {
//   const ArticleGenresScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Article Genres'),
//       ),
//     );
//   }
// }
