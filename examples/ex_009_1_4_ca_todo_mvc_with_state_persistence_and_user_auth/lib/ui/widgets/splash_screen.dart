import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen([dynamic data]);
  static String routeName = '/';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
