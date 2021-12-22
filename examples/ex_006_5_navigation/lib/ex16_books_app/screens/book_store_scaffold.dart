// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import '../../ex16_books_app.dart';

enum ScaffoldTab { books, authors, settings }

class BookstoreScaffold extends StatelessWidget {
  const BookstoreScaffold({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int index = () {
      final location = navigator.routeData.location;
      if (location.startsWith('/settings')) {
        return 2;
      }
      if (location.startsWith('/authors')) {
        return 1;
      }
      return 0;
    }();
    return Scaffold(
      body: AdaptiveNavigationScaffold(
        selectedIndex: index,
        body: context.routerOutlet,
        onDestinationSelected: (idx) {
          switch (ScaffoldTab.values[idx]) {
            case ScaffoldTab.books:
              navigator.to('/books');
              break;
            case ScaffoldTab.authors:
              navigator.to('/authors');
              break;
            case ScaffoldTab.settings:
              navigator.to('/settings');
              break;
          }
        },
        destinations: const [
          AdaptiveScaffoldDestination(
            title: 'Books',
            icon: Icons.book,
          ),
          AdaptiveScaffoldDestination(
            title: 'Authors',
            icon: Icons.person,
          ),
          AdaptiveScaffoldDestination(
            title: 'Settings',
            icon: Icons.settings,
          ),
        ],
      ),
    );
  }
}
