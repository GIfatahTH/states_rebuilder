import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() {
  runApp(const MyApp());
}

final navigator = RM.injectNavigator(
  routes: {
    '/': (data) => data.redirectTo('/home'),
    '/home': (data) => const HomePage(),
    '/redirect-page': (data) => const RedirectPage(),
    //
    // All routes bellow redirect to the same page ('/redirect-page')
    // From page '/redirect-page' we can know the route that has redirected to it.
    '/page1': (data) => data.redirectTo('/redirect-page'),
    '/page1/:id': (data) => data.redirectTo('/redirect-page'),
    '/page2': (data) => RouteWidget(
          routes: {
            '/': (data) => data.redirectTo('/redirect-page'),
          },
        ),
    '/page3': (data) => const PageWidget(title: '/page3'),
    '/page3/:id': (data) {
      final id = data.pathParams['id'];
      return PageWidget(title: '/page3/$id');
    },
    '/page4': (data) => const PageWidget(title: '/page4'),
  },
  onNavigate: (data) {
    final location = data.location;
    if (location == '/page3') {
      return data.redirectTo('/redirect-page');
    }
    if (location == '/page3/10') {
      return data.redirectTo('/redirect-page');
    }
    if (location == '/page4' && data.queryParams['q'] == 'NaN') {
      return data.redirectTo('/redirect-page');
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
      appBar: AppBar(title: const Text('Redirection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => navigator.to('/page1'),
              child: const Text('to /page1'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page1/5'),
              child: const Text('to /page1/5'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page2'),
              child: const Text('to /page2'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page3'),
              child: const Text('to /page3'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page3/5'),
              child: const Text('to /page3/5'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page3/10'),
              child: const Text('to /page3/10'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page4?q=ok'),
              child: const Text('to /page4?q=ok'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page4?q=NaN'),
              child: const Text('to /page4?q=NaN'),
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

class RedirectPage extends StatelessWidget {
  const RedirectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract information about the route that has redirected to this page.
    //
    // It may redirected here because the user is not signed. After signing the
    // user we can navigate to the route that we are redirected from.
    final redirectedFrom = context.routeData.redirectedFrom?.location;
    final pathParams = context.routeData.redirectedFrom?.pathParams;
    final queryParams = context.routeData.redirectedFrom?.queryParams;
    final uri = context.routeData.redirectedFrom?.uri;
    const textStyle = TextStyle(fontSize: 20);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redirect Page'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Redirected From: $redirectedFrom', style: textStyle),
            Text('Path parameters : $pathParams', style: textStyle),
            Text('Query parameters : $queryParams', style: textStyle),
            Text('Full uri: $uri', style: textStyle),
          ],
        ),
      ),
    );
  }
}
