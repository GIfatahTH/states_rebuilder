part of 'home_screen.dart';

class ExtraActionsButton extends StatelessWidget {
  const ExtraActionsButton({Key? key}) : super(key: key);
  static final _extraAction = RM.inject(
    () => ExtraAction.clearCompleted,
  );
  @override
  Widget build(BuildContext context) {
    print(todosBloc.todosStats.connectionState);
    return OnReactive(
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
              authBloc.signOut();
              return;
            }

            if (action == ExtraAction.toggleAllComplete) {
              todosBloc.toggleAll();
            } else {
              todosBloc.clearCompleted();
            }
          },
          itemBuilder: (BuildContext context) {
            print(todosBloc.todosStats);
            return <PopupMenuItem<ExtraAction>>[
              if (!todosBloc.todosStats.isWaiting)
                PopupMenuItem<ExtraAction>(
                  key: Key('__toggleAll__'),
                  value: ExtraAction.toggleAllComplete,
                  child: Text(
                    todosBloc.allComplete
                        ? i18n.of(context).markAllIncomplete
                        : i18n.of(context).markAllComplete,
                  ),
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
    );
  }
}
