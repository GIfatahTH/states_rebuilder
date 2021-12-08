import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  runApp(const MyApp());
}

final navigator = RM.injectNavigator(
  routes: {
    '/': (data) => data.redirectTo('/home'),
    '/home': (data) => const HomePage(),
    // page1 redirect to itself
    '/page1': (data) => data.redirectTo('/page1'),
    // page2 redirect to page3 and page3 redirect back to page2
    '/page2': (data) => data.redirectTo('/page3'),
    '/page3': (data) => data.redirectTo('/page2'),
    // /page4 route is redirect form onNavigate callback to page5
    // and page5 redirect locally to page4
    '/page4': (data) => const PageWidget(title: 'Never Reached Page'),
    '/page5': (data) => data.redirectTo('/page4'),
  },
  onNavigate: (data) {
    final location = data.location;
    if (location == '/page4') {
      return data.redirectTo('/page5');
    }
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
      appBar: AppBar(title: const Text('Cyclic Redirection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => navigator.to('/page1'),
              child: const Text('to page1'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page2'),
              child: const Text('to page2'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page3'),
              child: const Text('to page3'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page4'),
              child: const Text('to page4'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page5'),
              child: const Text('to page5'),
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
