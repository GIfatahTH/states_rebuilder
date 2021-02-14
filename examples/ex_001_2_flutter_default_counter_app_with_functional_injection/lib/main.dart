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
      navigatorObservers:[
        NavigatorObserver().

      ],
      home: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text('Simplest counter app'),
                onPressed: () {
                  RM.navigate.to(
                    simpleCounter.MyHomePage(
                      title: 'Simple counter app',
                    ),
                  );
                },
              ),
              RaisedButton(
                child: Text('Simplest counter with error'),
                onPressed: () {
                  RM.navigate.to(
                    simpleCounterWithError.MyHomePage(
                      title: 'Simple counter with error',
                    ),
                  );
                },
              ),
              RaisedButton(
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

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       navigatorKey: RM.navigate.navigatorKey,
//       onGenerateRoute: RM.navigate.onGenerateRoute(
//         {
//           '/simpleCounter': (arg) => simpleCounter.MyHomePage(
//                 title: 'Simple counter app',
//               ),
//           '/simpleCounterWithError': (arg) => simpleCounterWithError.MyHomePage(
//                 title: 'Simple counter with error',
//               ),
//           '/asyncCounter': (arg) => asyncCounter.MyHomePage(
//                 title: 'async counter app',
//               ),
//         },
//         transitionsBuilder: RM.transitions.rightToLeft(),
//         unknownRoute: Scaffold(
//           appBar: AppBar(),
//           body: Center(
//             child: const Text('404'),
//           ),
//         ),
//       ),
//       home: Scaffold(
//         body: Center(
//           child: Column(
//             children: <Widget>[
//               RaisedButton(
//                 child: Text('Simplest counter app'),
//                 onPressed: () {
//                   RM.navigate.toNamed('/simpleCounter');
//                 },
//               ),
//               RaisedButton(
//                 child: Text('Simplest counter with error'),
//                 onPressed: () {
//                   RM.navigate.toNamed('/simpleCounterWithError');
//                 },
//               ),
//               RaisedButton(
//                 child: Text('async counter app'),
//                 onPressed: () {
//                   RM.navigate.toNamed('/asyncCounter');
//                 },
//               ),
//             ],
//             mainAxisAlignment: MainAxisAlignment.center,
//           ),
//         ),
//       ),
//     );
//   }
// }
