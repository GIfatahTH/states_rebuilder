import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

late InjectedNavigator navigator;

final Map<String, Widget Function(RouteData)> routes = {
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
};
void main() {
  final dashboard = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Dashboard' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(Dash),
    'text': find.byType(Dash),
  };
  final about = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'About' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(About),
    'text': find.text('About Page'),
  };
  final support = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Support' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(Support),
    'text': find.text('Support Page'),
  };
  void checkMainMenu(Map<String, Finder>? finder) {
    for (var f in [dashboard, about, support]) {
      if (f == finder) {
        expect(f['menu'], findsOneWidget);
        expect(f['page'], findsOneWidget);
        expect(f['text'], findsOneWidget);
      } else {
        expect(f['menu'], findsNothing);
        expect(f['page'], findsNothing);
        expect(f['text'], findsNothing);
      }
    }
  }

  final home = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Home' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(DashHome),
    'text': find.text('DashHome'),
  };
  final invoices = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Invoices' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(Invoices),
    'text': find.byType(Invoices),
  };
  final team = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Team' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(Team),
    'text': find.text('Team Page'),
  };
  void checkSubMenu1(Map<String, Finder>? finder) {
    for (var f in [home, invoices, team]) {
      if (f == finder) {
        expect(f['menu'], findsOneWidget);
        expect(f['page'], findsOneWidget);
        expect(f['text'], findsOneWidget);
      } else {
        expect(f['menu'], findsNothing);
        expect(f['page'], findsNothing);
        expect(f['text'], findsNothing);
      }
    }
  }

  final daily = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Daily' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(DailyInvoices),
    'text': find.text('Daily Invoices'),
  };
  final weekly = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Weekly' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(WeeklyInvoices),
    'text': find.text('Weekly Invoices'),
  };
  final monthly = {
    'menu': find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == 'Monthly' &&
          widget.style?.fontWeight == FontWeight.bold,
    ),
    'page': find.byType(MonthlyInvoices),
    'text': find.text('Monthly Invoices'),
  };

  void checkSubMenu2(Map<String, Finder>? finder) {
    for (var f in [daily, weekly, monthly]) {
      if (f == finder) {
        expect(f['menu'], findsOneWidget);
        expect(f['page'], findsOneWidget);
        expect(f['text'], findsOneWidget);
      } else {
        expect(f['menu'], findsNothing);
        expect(f['page'], findsNothing);
        expect(f['text'], findsNothing);
      }
    }
  }

  testWidgets(
    'initial known location',
    (tester) async {
      navigator = RM.injectNavigator(
        initialLocation: '/dashboard/invoices/weekly',
        builder: (_) => const Home(),
        transitionsBuilder: RM.transitions.none(),
        routes: routes,
      );
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(weekly);
    },
  );
  testWidgets(
    'initial unknown location1',
    (tester) async {
      navigator = RM.injectNavigator(
        initialLocation: '/dashboard/invoices/weekly454',
        builder: (_) => const Home(),
        transitionsBuilder: RM.transitions.none(),
        routes: routes,
      );
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      expect(weekly['menu'], findsOneWidget);
      expect(weekly['page'], findsNothing);
      expect(
        find.text('/dashboard/invoices/weekly454 not found'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'initial unknown location2',
    (tester) async {
      navigator = RM.injectNavigator(
        initialLocation: '/dashboard/invoices/weekly/1',
        builder: (_) => const Home(),
        transitionsBuilder: RM.transitions.none(),
        routes: routes,
      );
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      expect(weekly['menu'], findsOneWidget);
      expect(weekly['page'], findsNothing);
      expect(
        find.text('/dashboard/invoices/weekly/1 not found'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'redirect to /dashboard/invoices/weekly',
    (tester) async {
      final Map<String, Widget Function(RouteData)> routes = {
        '/': (data) => data.redirectTo('/dashboard'),
        '/dashboard': (data) => RouteWidget(
              builder: (_) => const Dash(),
              routes: {
                '/': (data) => const DashHome(),
                '/invoices': (data) => RouteWidget(
                      builder: (_) => const Invoices(),
                      routes: {
                        '/': (data) =>
                            data.redirectTo('/dashboard/invoices/weekly'),
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
      };
      navigator = RM.injectNavigator(
        builder: (_) => const Home(),
        transitionsBuilder: RM.transitions.none(),
        routes: routes,
      );
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      //
      navigator.to('/dashboard/invoices');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(weekly);
    },
  );

  testWidgets(
    'redirect to /about',
    (tester) async {
      final Map<String, Widget Function(RouteData)> routes = {
        '/': (data) => data.redirectTo('/dashboard'),
        '/dashboard': (data) => RouteWidget(
              builder: (_) => const Dash(),
              routes: {
                '/': (data) => const DashHome(),
                '/invoices': (data) => RouteWidget(
                      builder: (_) => const Invoices(),
                      routes: {
                        '/': (data) => data.redirectTo('/about'),
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
      };
      navigator = RM.injectNavigator(
        builder: (_) => const Home(),
        transitionsBuilder: RM.transitions.none(),
        routes: routes,
      );
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      //
      navigator.to('/dashboard/invoices');
      await tester.pumpAndSettle();
      checkMainMenu(about);
      checkSubMenu1(null);
      checkSubMenu2(null);
    },
  );

  testWidgets(
    'redirect to unknown /about/404 ',
    (tester) async {
      final Map<String, Widget Function(RouteData)> routes = {
        '/': (data) => data.redirectTo('/dashboard'),
        '/dashboard': (data) => RouteWidget(
              builder: (_) => const Dash(),
              routes: {
                '/': (data) => const DashHome(),
                '/invoices': (data) => RouteWidget(
                      builder: (_) => const Invoices(),
                      routes: {
                        '/': (data) => data.redirectTo('/about/404'),
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
      };
      navigator = RM.injectNavigator(
        builder: (_) => const Home(),
        transitionsBuilder: RM.transitions.none(),
        routes: routes,
      );
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      //
      navigator.to('/dashboard/invoices');
      await tester.pumpAndSettle();
      expect(about['menu'], findsOneWidget);
      expect(about['page'], findsNothing);
      expect(find.text('/about/404 not found'), findsOneWidget);
    },
  );

  testWidgets(
    'redirect to unknown /dashboard from weekly ',
    (tester) async {
      final Map<String, Widget Function(RouteData)> routes = {
        '/': (data) => data.redirectTo('/dashboard'),
        '/dashboard': (data) => RouteWidget(
              builder: (_) => const Dash(),
              routes: {
                '/': (data) => const DashHome(),
                '/invoices': (data) => RouteWidget(
                      builder: (_) => const Invoices(),
                      routes: {
                        '/': (data) => data.redirectTo('/daily'),
                        '/daily': (data) => const DailyInvoices(),
                        '/weekly': (data) => data.redirectTo('/dashboard'),
                        '/monthly': (data) => const MonthlyInvoices(),
                      },
                    ),
                '/team': (data) => const Team(),
              },
            ),
        '/about': (data) => const About(),
        '/support': (data) => const Support(),
      };
      navigator = RM.injectNavigator(
        builder: (_) => const Home(),
        transitionsBuilder: RM.transitions.none(),
        routes: routes,
      );
      await tester.pumpWidget(const MyApp());
      checkMainMenu(dashboard);
      checkSubMenu1(home);
      //
      navigator.to('/dashboard/invoices');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(invoices);
      checkSubMenu2(daily);
      //
      navigator.to('weekly');
      await tester.pumpAndSettle();
      checkMainMenu(dashboard);
      checkSubMenu1(home);
    },
  );
}

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
