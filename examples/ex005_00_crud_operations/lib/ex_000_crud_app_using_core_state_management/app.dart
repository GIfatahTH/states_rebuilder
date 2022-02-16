import 'package:flutter/material.dart';

import 'ui/todos_page.dart';

// See todos_bloc file for some DI tweak
// The code is test (see test folder)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}
