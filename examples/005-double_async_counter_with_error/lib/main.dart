import 'package:flutter/material.dart';

import 'counter_page_1.dart' as page1;
import 'counter_page_2.dart' as page2;
import 'counter_page_3.dart' as page3;

void main() => runApp(MaterialApp(home: MainApp()));

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          child: Text('Double counter (polluted environnement)'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => page1.App(),
              ),
            );
          },
        ),
        RaisedButton(
          child: Text('Double counter (using Tag)'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => page2.App(),
              ),
            );
          },
        ),
        RaisedButton(
          child: Text('Double counter (New reactive environnement)'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => page3.App(),
              ),
            );
          },
        ),
      ],
    );
  }
}
