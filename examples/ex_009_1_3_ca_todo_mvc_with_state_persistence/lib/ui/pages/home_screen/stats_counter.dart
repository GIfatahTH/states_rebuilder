// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';

import '../../../injected.dart';
import '../../../ui/common/localization/localization.dart';

class StatsCounter extends StatelessWidget {
  const StatsCounter();

  @override
  Widget build(BuildContext context) {
    return todosStats.rebuilder(
      () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                i18n.state.completedTodos,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                '${todosStats.state.numCompleted}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                i18n.state.activeTodos,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                '${todosStats.state.numActive}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            )
          ],
        ),
      ),
    );
  }
}
