import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'injected_tab_example_1.dart';
import 'injected_tab_example_2.dart';
import 'injected_tab_example_3.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: RM.navigate.navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Working with scrollable view'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => RM.navigate.to(PageViewOnly()),
                child: Text('Page View only'),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => RM.navigate.to(TabViewOnly()),
                child: Text('Tab View only'),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => RM.navigate.to(MixPageAndTabView()),
                child: Text('Mixed Page and Tab view'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
