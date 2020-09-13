// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../../../injected.dart';
import '../../../service/common/enums.dart';
import '../../common/enums.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyText1;
    final activeStyle = Theme.of(context)
        .textTheme
        .bodyText1
        .copyWith(color: Theme.of(context).accentColor);
    final button = _Button(
      activeStyle: activeStyle,
      defaultStyle: defaultStyle,
    );

    return appTab.rebuilder(() {
      final _isActive = appTab.state == AppTab.todos;
      return AnimatedOpacity(
        opacity: _isActive ? 1.0 : 0.0,
        duration: Duration(milliseconds: 150),
        child: _isActive ? button : IgnorePointer(child: button),
      );
    });
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key key,
    @required this.activeStyle,
    @required this.defaultStyle,
  }) : super(key: key);

  final TextStyle activeStyle;
  final TextStyle defaultStyle;

  @override
  Widget build(BuildContext context) {
    return StateBuilder<VisibilityFilter>(
        key: Key('FilterButton 2'),
        //Create and subscribe to a local ReactiveModel of type VisibilityFilter
        observe: () => RM.create(VisibilityFilter.all),
        builder: (context, activeFilterRM) {
          return PopupMenuButton<VisibilityFilter>(
            key: ArchSampleKeys.filterButton,
            tooltip: ArchSampleLocalizations.of(context).filterTodos,
            onSelected: (filter) {
              activeFilterRM.state = filter;
              todosService.setState((s) => s.activeFilter = filter);
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuItem<VisibilityFilter>>[
              PopupMenuItem<VisibilityFilter>(
                key: ArchSampleKeys.allFilter,
                value: VisibilityFilter.all,
                child: Text(
                  ArchSampleLocalizations.of(context).showAll,
                  style: activeFilterRM.state == VisibilityFilter.all
                      ? activeStyle
                      : defaultStyle,
                ),
              ),
              PopupMenuItem<VisibilityFilter>(
                key: ArchSampleKeys.activeFilter,
                value: VisibilityFilter.active,
                child: Text(
                  ArchSampleLocalizations.of(context).showActive,
                  style: activeFilterRM.state == VisibilityFilter.active
                      ? activeStyle
                      : defaultStyle,
                ),
              ),
              PopupMenuItem<VisibilityFilter>(
                key: ArchSampleKeys.completedFilter,
                value: VisibilityFilter.completed,
                child: Text(
                  ArchSampleLocalizations.of(context).showCompleted,
                  style: activeFilterRM.state == VisibilityFilter.completed
                      ? activeStyle
                      : defaultStyle,
                ),
              ),
            ],
            icon: Icon(Icons.filter_list),
          );
        });
  }
}
