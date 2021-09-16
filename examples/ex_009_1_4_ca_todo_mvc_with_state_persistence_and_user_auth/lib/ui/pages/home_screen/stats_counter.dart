part of 'home_screen.dart';

class StatsCounter extends StatelessWidget {
  const StatsCounter();

  @override
  Widget build(BuildContext context) {
    return OnReactive(
      () => Center(
        child: todosBloc.todosStats.isWaiting
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      i18n.of(context).completedTodos,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      '${todosBloc.numCompleted}',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      i18n.of(context).activeTodos,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      '${todosBloc.numActive}',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
