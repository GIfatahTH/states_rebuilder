import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import './pages/simple_counter.dart' as simpleCounter;
import './pages/simple_counter_with_error.dart' as simpleCounterWithError;
import './pages/async_counter_app.dart' as asyncCounter;

void main() {
  RM.navigate.transitionsBuilder = RM.transitions.leftToRight(
    duration: Duration(milliseconds: 500),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: RM.navigate.navigatorKey,
      home: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              ElevatedButton(
                child: Text('Simplest counter app'),
                onPressed: () {
                  RM.navigate.to(
                    simpleCounter.MyHomePage(
                      title: 'Simple counter app',
                    ),
                  );
                },
              ),
              ElevatedButton(
                child: Text('Simplest counter with error'),
                onPressed: () {
                  RM.navigate.to(
                    simpleCounterWithError.MyHomePage(
                      title: 'Simple counter with error',
                    ),
                  );
                },
              ),
              ElevatedButton(
                child: Text('async counter app'),
                onPressed: () {
                  RM.navigate.to(
                    asyncCounter.MyHomePage(
                      title: 'async counter app',
                    ),
                  );
                },
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }
}

