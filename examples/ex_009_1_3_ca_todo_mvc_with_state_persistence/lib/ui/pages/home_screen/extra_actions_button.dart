import 'package:ex_009_1_3_ca_todo_mvc_with_state_persistence/ui/common/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../injected.dart';
import '../../../service/todos_state.dart';
import '../../common/enums.dart';
import '../../common/localization/localization.dart';
import '../../exceptions/error_handler.dart';

class ExtraActionsButton extends StatelessWidget {
  ExtraActionsButton({Key key}) : super(key: key);
  final extraAction = RM.inject(() => ExtraAction.clearCompleted);
  @override
  Widget build(BuildContext context) {
    return extraAction.rebuilder(() {
      return PopupMenuButton<ExtraAction>(
        onSelected: (action) {
          extraAction.state = action;

          if (action == ExtraAction.toggleDarkMode) {
            isDarkMode.state = !isDarkMode.state;
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
              value: ExtraAction.toggleAllComplete,
              child: Text(todosStats.state.allComplete
                  ? i18n.state.markAllIncomplete
                  : i18n.state.markAllComplete),
            ),
            PopupMenuItem<ExtraAction>(
              value: ExtraAction.clearCompleted,
              child: Text(i18n.state.clearCompleted),
            ),
            PopupMenuItem<ExtraAction>(
              value: ExtraAction.toggleDarkMode,
              child: Text(
                isDarkMode.state
                    ? i18n.state.switchToLightMode
                    : i18n.state.switchToDarkMode,
              ),
            ),
          ];
        },
      );
    });
  }
}
