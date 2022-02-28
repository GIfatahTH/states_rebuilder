import 'package:flutter/material.dart';

import '../../blocs/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              //get UserService reactiveModel and call setState to signOut,
              authBloc.logout();
            },
          )
        ],
      ),
      body: Center(
        child: Text('Welcome ${authBloc.user.email ?? authBloc.user.uid}!'),
      ),
    );
  }
}
