import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// The same as example ex04_to_deeply1 ad ex05_to_deeply2 but written using
// RouteWidget and with static helper methods.

void main() {
  runApp(const MyApp());
}

final navigator = RM.injectNavigator(
  routes: {
    '/': (data) => const HomePage(),
    Page1.routeName: Page1.routeBuilder,
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routeInformationParser: navigator.routeInformationParser,
      routerDelegate: navigator.routerDelegate,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => navigator.to(
                '/page1/page11/page111/page1111',
              ),
              child: const Text('Navigate using "to"'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.toDeeply(
                '/page1/page11/page111/page1111',
              ),
              child: const Text('Navigate using "toDeeply"'),
            ),
          ],
        ),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  static const routeName = '/page1';

  static Widget routeBuilder(RouteData data) => RouteWidget(
        routes: {
          '/': (data) => const Page1._(),
          Page11.routeName: Page11.routeBuilder,
        },
      );

  const Page1._({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page1')),
      body: const Center(
        child: Text('Page1'),
      ),
    );
  }
}

class Page11 extends StatelessWidget {
  static const routeName = '/page11';

  static Widget routeBuilder(RouteData data) => RouteWidget(
        routes: {
          '/': (data) => const Page11._(),
          Page111.routeName: (data) => const Page111(),
          Page1111.routeName: (data) => const Page1111(),
        },
      );

  const Page11._({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page1/Page11')),
      body: const Center(
        child: Text('Page1/Page11'),
      ),
    );
  }
}

class Page111 extends StatelessWidget {
  static const routeName = '/page111';

  const Page111({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page1/Page11/Page111')),
      body: const Center(
        child: Text('Page1/Page11/Page111'),
      ),
    );
  }
}

class Page1111 extends StatelessWidget {
  static const routeName = '/page111/page1111';

  const Page1111({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page1/Page11/Page111/Page1111')),
      body: const Center(
        child: Text('Page1/Page11/Page111/Page1111'),
      ),
    );
  }
}
