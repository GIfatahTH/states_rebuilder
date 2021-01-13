import 'package:flutter/material.dart';

import 'injected.dart';
import 'ui/pages/home_page/home_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multiple counters',
      theme: ThemeData(
        //get the primarySwatch color from the Config file
        primarySwatch: config.state.primarySwatch,
      ),
      home: HomePage(),
    );
  }
}
