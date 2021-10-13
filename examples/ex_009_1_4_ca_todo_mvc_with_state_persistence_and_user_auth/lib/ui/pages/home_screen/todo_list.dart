part of 'home_screen.dart';

class TodoList extends StatelessWidget {
  const TodoList();
  @override
  Widget build(BuildContext context) {
    return OnReactive(
      () {
        return ListView.builder(
          itemCount: todosBloc.todosFiltered.state.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index <= todosBloc.todosFiltered.state.length - 1) {
              return todosBloc.todosRM.item.inherited(
                key: Key('${todosBloc.todosFiltered.state[index].id}'),
                item: () {
                  return todosBloc.todosFiltered.state[index];
                },
                builder: (_) => TodoItem(),
                debugPrintWhenNotifiedPreMessage: 'todo $index',
              );
            } else {
              //Add CircularProgressIndicator on bottom of the list
              //while waiting for adding one item
              return todosBloc.todosFiltered.onOrElse(
                onWaiting: () => Center(child: CircularProgressIndicator()),
                orElse: (_) => Container(),
              );
            }
          },
        );
      },
    );
  }
}
