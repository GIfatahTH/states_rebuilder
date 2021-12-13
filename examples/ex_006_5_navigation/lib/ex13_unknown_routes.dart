import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

void main() => runApp(const MyApp());

final _myDummyItems = ['Item 1', 'Item 2'];

final navigator = RM.injectNavigator(
  // TODO uncomment this for custom unknown page
  // unknownRoute: (data) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('404 page'),
  //     ),
  //     body: Center(
  //       child: Text('page "${data.uri}" is not found'),
  //     ),
  //   );
  // },
  routes: {
    '/': (data) => const HomePage(),
    '/page1/:id': (data) {
      try {
        final index = int.parse(data.pathParams['id']!);
        final item = _myDummyItems[index];
        return Page1(item: item);
      } catch (e) {
        // return unknownRoute if the extracted parameter is out of range or
        // if it can not be parsed to an integer.
        return data.unKnownRoute;
      }
    },
    // This is similar to '/page1/:id' but the parameters are extracted using
    // the BuildContext
    '/page2/:id': (data) => const Page2(),
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

class Page1 extends StatelessWidget {
  const Page1({
    Key? key,
    required this.item,
  }) : super(key: key);
  final String item;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page1'),
      ),
      body: Center(
        child: Text('This is $item'),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    late String item;
    try {
      final index = int.parse(context.routeData.pathParams['id']!);
      item = _myDummyItems[index];
    } catch (e) {
      return context.routeData.unKnownRoute;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page2'),
      ),
      body: Center(
        child: Text('This is $item'),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unknown Routes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => navigator.to('/unknownPage'),
              child: const Text('to unknownPage'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page1/1'),
              child: const Text('to /page1/1'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page1/2'),
              child: const Text('to /page1/2 (out of range)'),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            //
            ElevatedButton(
              onPressed: () => navigator.to('/page2/1'),
              child: const Text('to /page2/1'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => navigator.to('/page2/string'),
              child: const Text('to /page1/string (Non number)'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
