// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_mvc_the_flutter_bloc_way/models/models.dart';
import 'package:todos_app_core/todos_app_core.dart';

class TabSelector extends StatelessWidget {
  final AppTab activeTab;
  final Function(AppTab) onTabSelected;

  TabSelector({
    Key key,
    @required this.activeTab,
    @required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      key: ArchSampleKeys.tabs,
      currentIndex: AppTab.values.indexOf(activeTab),
      onTap: (index) => onTabSelected(AppTab.values[index]),
      items: AppTab.values.map((tab) {
        return BottomNavigationBarItem(
          icon: Icon(
            tab == AppTab.todos ? Icons.list : Icons.show_chart,
            key: tab == AppTab.todos
                ? ArchSampleKeys.todoTab
                : ArchSampleKeys.statsTab,
          ),
          title: Text(tab == AppTab.stats
              ? ArchSampleLocalizations.of(context).stats
              : ArchSampleLocalizations.of(context).todos),
        );
      }).toList(),
    );
  }
}
