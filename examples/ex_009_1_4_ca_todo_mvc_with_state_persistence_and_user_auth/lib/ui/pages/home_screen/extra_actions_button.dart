part of 'home_screen.dart';

final _extraAction = RM.inject(
  () => ExtraAction.clearCompleted,
);

class ExtraActionsButton extends StatelessWidget {
  const ExtraActionsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return On.data(
      () {
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
              todos.state.toggleAll();
            } else {
              todos.state.clearCompleted();
            }
          },
          itemBuilder: (BuildContext context) {
            return <PopupMenuItem<ExtraAction>>[
              if (todosStats.hasData)
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
      },
    ).listenTo(_extraAction);
  }
}
