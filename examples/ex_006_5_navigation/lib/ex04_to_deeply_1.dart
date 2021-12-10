import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  runApp(const MyApp());
}

final navigator = RM.injectNavigator(
  builder: (routerOutlet) {
    return Builder(
      builder: (context) {
        return Scaffold(
          body: routerOutlet,
          floatingActionButton: FloatingActionButton(
            onPressed: () => navigator.toAndRemoveUntil('/'),
            child: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.secondary,
            ),
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
        );
      },
    );
  },
  routes: {
    '/': (data) => const HomePage(),
    '/page1': (data) => const PageWidget(title: 'Page1'),
    '/page1/page11': (data) => const PageWidget(title: 'Page1/Page11'),
    '/page1/page11/page111': (data) => const PageWidget(
          title: 'Page1/Page11/Page111',
        ),
    '/page1/page11/page111/page1111': (data) => const PageWidget(
          title: 'Page1/Page11/Page111/Page1111',
        ),
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
