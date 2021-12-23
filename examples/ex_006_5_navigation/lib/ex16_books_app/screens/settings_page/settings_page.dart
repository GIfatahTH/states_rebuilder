// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:url_launcher/link.dart';

import '../../../ex16_books_app.dart';
import '../sign_in_page/sign_in_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: const Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                    child: SettingsContent(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class SettingsContent extends StatelessWidget {
  const SettingsContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ...[
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headline4,
            ),
            ElevatedButton(
              onPressed: () {
                signInBloc.signOut();
              },
              child: const Text('Sign out'),
            ),
            Link(
              uri: Uri.parse('/book/0'),
              builder: (context, followLink) => TextButton(
                onPressed: () {
                  followLink!();
                },
                child: const Text('Go directly to /book/0 (Link)'),
              ),
            ),
            TextButton(
              onPressed: () {
                navigator.to('/book/0');
              },
              child: const Text('Go directly to /book/0'),
            ),
          ].map((w) => Padding(padding: const EdgeInsets.all(8), child: w)),
          TextButton(
            onPressed: () => RM.navigate.toDialog(
              AlertDialog(
                title: const Text('Alert!'),
                content: const Text('The alert description goes here.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => RM.navigate.back('Cancel'),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => navigator.back('OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            child: const Text('Show Dialog'),
          )
        ],
      );
}
