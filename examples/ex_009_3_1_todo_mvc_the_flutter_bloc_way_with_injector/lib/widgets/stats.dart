// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todo_mvc_the_flutter_bloc_way/blocs/stats/stats_state.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../bloc_library_keys.dart';
import 'loading_indicator.dart';

class Stats extends StatelessWidget {
  Stats({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateBuilder<StatsState>(
      observe: () => RM.get<StatsState>(),
      builder: (BuildContext context, statsStateRM) {
        if (statsStateRM.state is StatsLoading) {
          return LoadingIndicator(key: BlocLibraryKeys.statsLoadingIndicator);
        } else if (statsStateRM.state is StatsLoaded) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    ArchSampleLocalizations.of(context).completedTodos,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    '${(statsStateRM.state as StatsLoaded).numCompleted}',
                    key: ArchSampleKeys.statsNumCompleted,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    ArchSampleLocalizations.of(context).activeTodos,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    '${(statsStateRM.state as StatsLoaded).numActive}',
                    key: ArchSampleKeys.statsNumActive,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                )
              ],
            ),
          );
        } else {
          return Container(key: BlocLibraryKeys.emptyStatsContainer);
        }
      },
    );
  }
}
