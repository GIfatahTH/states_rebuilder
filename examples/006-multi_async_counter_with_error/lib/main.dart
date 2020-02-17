import 'package:flutter/material.dart';

import 'counter_grid_page1.dart' as page1;
import 'counter_grid_page2.dart' as page2;

void main() => runApp(MaterialApp(home: MainApp()));

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          child: Text('Counter Grid (polluted environnement)'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => page1.CounterGridPage1(),
              ),
            );
          },
        ),
        RaisedButton(
          child: Text('Counter Grid (using new reactive Environment'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => page2.CounterGridPage2(),
              ),
            );
          },
        ),
      ],
    );
  }
}
