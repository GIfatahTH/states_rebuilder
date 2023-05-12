import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// Nested route show case

void main() => runApp(const MyApp());

final navigator = RM.injectNavigator(
  // initialLocation: '/dashboard/invoices/weekly',
  builder: (_) => const Home(),
  // transitionsBuilder: RM.transitions.none(),
  transitionsBuilder: (_, animation, __, child) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  },
  transitionDuration: 1.seconds,
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
  onNavigateBack: (data) {
    if (data == null) {
      RM.navigate.toDialog(
        AlertDialog(
          content: const Text('Exit the app'),
          actions: [
            TextButton(
              onPressed: () => RM.navigate.back(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => RM.navigate.forceBack(),
              child: const Text('Yest'),
            ),
          ],
        ),
        postponeToNextFrame: true,
      );
    }
    return null;
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
