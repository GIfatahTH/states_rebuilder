import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

/*
* Organize the code to separate the business logic from the UI logic.
*/
void main() {
  runApp(const MyApp());
}

// Here lays all the business logic related to MyHomePage.
// This class can be named MyHomePageBloC, MyHomePageLogic or MyHomePageController
//
// This class is easily unit tested
@immutable
class MyHomePageViewModel {
  final _counter = RM.inject(() => 0);
  int get counter => _counter.state;
  void increment() {
    _counter.state++;
  }
}

// As this is a global state, and MyHomePageViewModel is immutable,
// it is safe to instantiate it globally.
final myHomePageViewModel = MyHomePageViewModel();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// No logic inside MyHomePage
class MyHomePage extends ReactiveStatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${myHomePageViewModel.counter}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: myHomePageViewModel.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
