import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// The same as example ex04_to_deeply1 but written using RouteWidget
void main() {
  runApp(const MyApp());
}

final navigator = RM.injectNavigator(
  routes: {
    '/': (data) => const HomePage(),
    '/page1': (data) => RouteWidget(
          routes: {
            '/': (data) => const PageWidget(title: 'Page1'),
            '/page11': (data) => RouteWidget(
                  routes: {
                    '/': (data) => const PageWidget(title: 'Page1/Page11'),
                    '/page111': (data) => const PageWidget(
                          title: 'Page1/Page11/Page111',
                        ),
                    '/page111/page1111': (data) => const PageWidget(
                          title: 'Page1/Page11/Page111/Page1111',
                        ),
                  },
                ),
          },
        )
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

class PageWidget extends StatelessWidget {
  const PageWidget({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title),
      ),
    );
  }
}
