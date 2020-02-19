import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../domain/entities/user.dart';
import '../../../service/user_service.dart';

class HomePage extends StatelessWidget {
  final userServiceRM = Injector.getAsReactive<UserService>();
  User get user => userServiceRM.state.user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              userServiceRM.setState((s) => s.signOut());
            },
          )
        ],
      ),
      body: Center(child: Text('Welcome ${user.email ?? user.uid}!')),
    );
  }
}
