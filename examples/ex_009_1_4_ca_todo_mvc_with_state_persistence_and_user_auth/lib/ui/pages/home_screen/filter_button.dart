// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

part of 'home_screen.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyText2;
    final activeStyle = Theme.of(context)
        .textTheme
        .bodyText2!
        .copyWith(color: Theme.of(context).colorScheme.secondary);
    final button = _Button(
      activeStyle: activeStyle,
      defaultStyle: defaultStyle!,
    );

    return OnTabPageViewBuilder(
      listenTo: HomeScreen.appTab,
      builder: (index) {
        return AnimatedOpacity(
          opacity: index == 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: index == 0 ? button : IgnorePointer(child: button),
        );
      },
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key? key,
    required this.activeStyle,
    required this.defaultStyle,
  }) : super(key: key);

  final TextStyle activeStyle;
  final TextStyle defaultStyle;

  @override
  Widget build(BuildContext context) {
    //This is an example of Local ReactiveModel
    return PopupMenuButton<VisibilityFilter>(
      tooltip: i18n.of(context).filterTodos,
      onSelected: (filter) {
        todosBloc.activeFilter.state = filter;
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<VisibilityFilter>>[
        PopupMenuItem<VisibilityFilter>(
          key: Key('__Filter_All__'),
          value: VisibilityFilter.all,
          child: Text(
            i18n.of(context).showAll,
            style: todosBloc.activeFilter.state == VisibilityFilter.all
                ? activeStyle
                : defaultStyle,
          ),
        ),
        PopupMenuItem<VisibilityFilter>(
          key: Key('__Filter_Active__'),
          value: VisibilityFilter.active,
          child: Text(
            i18n.of(context).showActive,
            style: todosBloc.activeFilter.state == VisibilityFilter.active
                ? activeStyle
                : defaultStyle,
          ),
        ),
        PopupMenuItem<VisibilityFilter>(
          key: Key('__Filter_Completed__'),
          value: VisibilityFilter.completed,
          child: Text(
            i18n.of(context).showCompleted,
            style: todosBloc.activeFilter.state == VisibilityFilter.completed
                ? activeStyle
                : defaultStyle,
          ),
        ),
      ],
      icon: const Icon(Icons.filter_list),
    );
  }
}
