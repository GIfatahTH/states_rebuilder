import 'package:flutter/material.dart';

import '../../../ex18_books_app.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen(this.error, {Key? key}) : super(key: key);

  final String error;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString() + 'page not found'),
              TextButton(
                onPressed: () => navigator.toReplacement('/'),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      );
}
