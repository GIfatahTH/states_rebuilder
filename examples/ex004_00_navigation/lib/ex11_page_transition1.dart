import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// Show case on how to custom page transition animation
void main() {
  runApp(const MyApp());
}

final navigator = RM.injectNavigator(
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return ScaleTransition(
      scale: animation,
      child: Transform.rotate(
        angle: 1 - animation.value,
        child: child,
      ),
    );
  },
  transitionDuration: const Duration(milliseconds: 1000),
  builder: (routerOutlet) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: routerOutlet,
    );
  },
  routes: {
    '/': (data) => const HomePage(),
    '/page1': (data) => const PageWidget(title: 'Page1'),
    '/page2': (data) => const PageWidget(title: 'Page2'),
    '/page3': (data) {
      return RouteWidget(
        builder: (_) {
          return const PageWidget(title: 'Page3');
        },
        transitionsBuilder: RM.transitions.leftToRight(
          duration: const Duration(milliseconds: 400),
        ),
      );
    },
    '/page4': (data) => RouteWidget(
          builder: (_) {
            return const PageWidget(title: 'Page4');
          },
          transitionsBuilder: RM.transitions.none(),
        ),
    '/page5': (data) => RouteWidget(
          transitionsBuilder: RM.transitions.upToBottom(),
          builder: (_) {
            return const Page5Home();
          },
          routes: {
            '/': (data) => Container(
                  color: Colors.red,
                ),
            '/page51': (data) => Container(
                  color: Colors.green,
                ),
          },
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
              onPressed: () => navigator.to('/page1'),
              child: const Text('to page1 (rotation + scaling)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page2'),
              child: const Text('to page2 (rotation + scaling)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page3'),
              child: const Text('to page3 (slide left to right)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page4'),
              child: const Text('to page4 (no animation)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page5'),
              child: const Text('to page5 (Nested Route: up to bottom)'),
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

class Page5Home extends ReactiveStatelessWidget {
  const Page5Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final location = context.routeData.location;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
            onPressed: () => navigator.back(),
            color: Theme.of(context).colorScheme.primary),
        title: Row(
          children: [
            TextButton(
              onPressed: () => navigator.to('/page5'),
              child: Text(
                '/Page5',
                style: location == '/page5'
                    ? const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
            ),
            TextButton(
              onPressed: () => navigator.to('/page5/page51'),
              child: Text(
                '/Page5/page51',
                style: location == '/page5/page51'
                    ? const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      )
                    : null,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: context.routerOutlet,
    );
  }
}
