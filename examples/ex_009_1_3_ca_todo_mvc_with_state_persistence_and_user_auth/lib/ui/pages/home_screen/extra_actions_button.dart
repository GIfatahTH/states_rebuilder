import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../injected.dart';
import '../../../service/todos_state.dart';
import '../../common/enums.dart';
import '../../common/localization/localization.dart';
import '../../common/theme/theme.dart';

final _extraAction = RM.inject(
  () => ExtraAction.clearCompleted,
);

class ExtraActionsButton extends StatelessWidget {
  const ExtraActionsButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _extraAction.rebuilder(() {
      return PopupMenuButton<ExtraAction>(
        onSelected: (action) {
          _extraAction.state = action;

          if (action == ExtraAction.toggleDarkMode) {
            isDarkMode.state = !isDarkMode.state;
            return;
          }

          if (action == ExtraAction.logout) {
            user.state = authService.state.logout();
            return;
          }

          todos.setState(
            (action == ExtraAction.toggleAllComplete)
                ? (s) => s.toggleAll()
                : (s) => s.clearCompleted(),
          );
          injectedTodo.refresh();
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuItem<ExtraAction>>[
            PopupMenuItem<ExtraAction>(
              key: Key('__toggleAll__'),
              value: ExtraAction.toggleAllComplete,
              child: Text(todosStats.state.allComplete
                  ? i18n.state.markAllIncomplete
                  : i18n.state.markAllComplete),
            ),
            PopupMenuItem<ExtraAction>(
              key: Key('__toggleClearCompleted__'),
              value: ExtraAction.clearCompleted,
              child: Text(i18n.state.clearCompleted),
            ),
            PopupMenuItem<ExtraAction>(
              key: Key('__toggleDarkMode__'),
              value: ExtraAction.toggleDarkMode,
              child: Text(
                isDarkMode.state
                    ? i18n.state.switchToLightMode
                    : i18n.state.switchToDarkMode,
              ),
            ),
            PopupMenuItem<ExtraAction>(
              key: Key('__logout__'),
              value: ExtraAction.logout,
              child: Text(i18n.state.logout),
            ),
          ];
        },
      );
    });
  }
}
