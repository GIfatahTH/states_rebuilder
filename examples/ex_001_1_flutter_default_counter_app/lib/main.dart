import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import './pages/simple_counter.dart' as simpleCounter;
import './pages/simple_counter_with_error.dart' as simpleCounterWithError;
import './pages/async_counter_app.dart' as asyncCounter;

void main() => runApp(MyApp());

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
        body: Builder(
          builder: (context) {
            return Center(
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    child: Text('Simplest counter app'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => simpleCounter.MyHomePage(
                            title: 'Simple counter app',
                          ),
                        ),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text('Simplest counter with error'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              simpleCounterWithError.MyHomePage(
                            title: 'Simple counter with error',
                          ),
                        ),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text('async counter app'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => asyncCounter.MyHomePage(
                            title: 'async counter app',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
