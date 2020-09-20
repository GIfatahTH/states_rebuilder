// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../injected.dart';
import '../../../service/common/enums.dart';
import '../../common/enums.dart';
import '../../common/localization/localization.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyText2;
    final activeStyle = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(color: Theme.of(context).accentColor);
    final button = _Button(
      activeStyle: activeStyle,
      defaultStyle: defaultStyle,
    );

    return activeTab.rebuilder(
      () {
        final _isActive = activeTab.state == AppTab.todos;
        return AnimatedOpacity(
          opacity: _isActive ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: _isActive ? button : IgnorePointer(child: button),
        );
      },
    );
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
    //This is an example of Local ReactiveModel
    return activeFilter.rebuilder(
      () {
        return PopupMenuButton<VisibilityFilter>(
          tooltip: i18n.state.filterTodos,
          onSelected: (filter) {
            activeFilter.state = filter;
          },
          itemBuilder: (BuildContext context) =>
              <PopupMenuItem<VisibilityFilter>>[
            PopupMenuItem<VisibilityFilter>(
              value: VisibilityFilter.all,
              child: Text(
                i18n.state.showAll,
                style: activeFilter.state == VisibilityFilter.all
                    ? activeStyle
                    : defaultStyle,
              ),
            ),
            PopupMenuItem<VisibilityFilter>(
              value: VisibilityFilter.active,
              child: Text(
                i18n.state.showActive,
                style: activeFilter.state == VisibilityFilter.active
                    ? activeStyle
                    : defaultStyle,
              ),
            ),
            PopupMenuItem<VisibilityFilter>(
              value: VisibilityFilter.completed,
              child: Text(
                i18n.state.showCompleted,
                style: activeFilter.state == VisibilityFilter.completed
                    ? activeStyle
                    : defaultStyle,
              ),
            ),
          ],
          icon: const Icon(Icons.filter_list),
        );
      },
    );
  }
}
