import 'dart:async';

import 'package:flutter/material.dart';
import 'package:states_rebuilder/scr/state_management/rm.dart';

import '../../blocs/auth_bloc.dart';
import '../../common/extensions.dart';

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
            onPressed: authBloc.logout,
          )
        ],
      ),
      body: Center(
        child: OnBuilder.createStream(
          creator: () => Stream.periodic(const Duration(seconds: 1), (_) => _),
          builder: (_) {
            if (!authBloc.isUserAuthenticated) return const SizedBox.shrink();
            final expireTime = authBloc.user.token.expiryDate!
                .difference(DateTimeX.current)
                .inSeconds;
            return DefaultTextStyle(
              style: Theme.of(context).textTheme.headlineSmall!,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Text('Welcome ${authBloc.user.email}'),
                  Text('Token is: ${authBloc.user.token.token}'),
                  if (expireTime == 0)
                    const Text('Refreshing token')
                  else
                    Text('Token expires in $expireTime seconds'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      authBloc().auth.refreshToken();
                    },
                    child: const Text('Refresh the token'),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
