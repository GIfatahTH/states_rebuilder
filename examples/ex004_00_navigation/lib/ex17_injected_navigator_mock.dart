import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// If your business logic depends on InjectedNavigator, you can mock it for
// unit tests

void main() {
  runApp(const MyApp());
}

final navigator = RM.injectNavigator(
  routes: {
    '/': (data) => const HomePage(),
    '/page1': (data) => const PageWidget(title: 'Page1'),
  },
);

Future<int> methodToTest1() async {
  await Future.delayed(const Duration(seconds: 1));
  // Because this line this method can not be unit tested
  // without mocking the InjectedNavigator dependency.
  // See the corresponding test file
  navigator.back();
  return 10;
}

Future<int?> methodToTest2() async {
  final result = await navigator.to<int>('/page1');
  return result;
}

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
              onPressed: () {
                methodToTest1();
              },
              child: const Text('Invoke methodToTest1 method'),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await methodToTest2();
                print(result);
              },
              child: const Text('Invoke methodToTest2 method'),
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
