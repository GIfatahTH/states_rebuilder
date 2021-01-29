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

          if (action == ExtraAction.toggleAllComplete) {
            todos.setState((s) => s.toggleAll());
            //The todos list state is changed after toggling
            //Tell todoItem to refresh their state and re-invoke their stateOverride callback
            //Only todoItem that are changed will be notified to rebuild
            todoItem.refresh();
          } else {
            todos.setState((s) => s.clearCompleted());
          }
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuItem<ExtraAction>>[
            PopupMenuItem<ExtraAction>(
              key: Key('__toggleAll__'),
              value: ExtraAction.toggleAllComplete,
              child: Text(activeTodosCount.state != 0
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
                isDarkMode.state
                    ? i18n.of(context).switchToLightMode
                    : i18n.of(context).switchToDarkMode,
              ),
            ),
          ];
        },
      );
    });
  }
}
