import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence_user_auth/ui/injected/injected_todo.dart';

import '../../injected/injected_user.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../common/enums.dart';
import '../../common/localization/localization.dart';
import '../../common/theme/theme.dart';

final _extraAction = RM.inject(
  () => ExtraAction.clearCompleted,
);
bool _switcher = false;

class ExtraActionsButton extends StatelessWidget {
  const ExtraActionsButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _extraAction.rebuilder(() {
      return PopupMenuButton<ExtraAction>(
        onSelected: (action) {
          _extraAction.state = action;

          if (action == ExtraAction.toggleDarkMode) {
            // isDarkMode.state = !isDarkMode.state;
            isDark.toggle();
            return;
          }

          if (action == ExtraAction.logout) {
            user.auth.signOut();
            return;
          }

          if (action == ExtraAction.toggleAllComplete) {
            _switcher = !_switcher;
            if (_switcher) {
              isDark.state = 'super';
            } else {
              isDark.state = 'default';
            }
            // todos.setState((s) => s.toggleAll());
            // todoItem.refresh();
          } else {
            isDark.themeMode = ThemeMode.system;
            // todos.setState((s) => s.clearCompleted());
          }
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuItem<ExtraAction>>[
            PopupMenuItem<ExtraAction>(
              key: Key('__toggleAll__'),
              value: ExtraAction.toggleAllComplete,
              child: Text(todosStats.state.allComplete
                  ? i18n.of(context).markAllIncomplete
                  : i18n.of(context).markAllComplete),
            ),
            PopupMenuItem<ExtraAction>(
              key: Key('__toggleClearCompleted__'),
              value: ExtraAction.clearCompleted,
              child: Text(i18n.of(context).clearCompleted),
            ),
            PopupMenuItem<ExtraAction>(
              key: Key('__toggleDarkMode__'),
              value: ExtraAction.toggleDarkMode,
              child: Text(
                isDark.isDarkTheme
                    ? i18n.of(context).switchToLightMode
                    : i18n.of(context).switchToDarkMode,
              ),
            ),
            PopupMenuItem<ExtraAction>(
              key: Key('__logout__'),
              value: ExtraAction.logout,
              child: Text(i18n.of(context).logout),
            ),
          ];
        },
      );
    });
  }
}
