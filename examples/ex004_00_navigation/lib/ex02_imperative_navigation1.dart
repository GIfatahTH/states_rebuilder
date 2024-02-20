import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// In this example, we will combine declarative and imperative navigation.
// We will remove a hidden page from route stack

void main() {
  runApp(const MyApp());
}

final navigator = RM.injectNavigator(
  initialLocation: '/page1/page11',
  routes: {
    '/': (data) => const PageWidget(title: 'Home page'),
    '/page1': (data) => const PageWidget(title: 'Page1'),
    '/page1/page11': (data) => const Page11(title: 'Page11'),
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.light(useMaterial3: false),
      title: 'Books App',
      routeInformationParser: navigator.routeInformationParser,
      routerDelegate: navigator.routerDelegate,
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

class Page11 extends StatelessWidget {
  const Page11({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        // Before tapping on this button, try navigating back to see that "page1"
        // exists.
        //
        // Now restart the app and tap on this button and navigate back and notice
        // that page1 is removed behind the scene.
        child: ElevatedButton(
          onPressed: () => navigator.setRouteStack(
            (pages) {
              return pages.where((p) => p.name != '/page1').toList();
            },
          ),
          child: const Text('Remove "/page1"'),
        ),
      ),
    );
  }
}
