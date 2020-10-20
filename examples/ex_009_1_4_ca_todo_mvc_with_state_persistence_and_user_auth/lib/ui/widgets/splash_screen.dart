import 'package:flutter/material.dart';

import '../../injected.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen([dynamic data]);
  static String routeName = '/';
  @override
  Widget build(BuildContext context) {
    user.state;
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
