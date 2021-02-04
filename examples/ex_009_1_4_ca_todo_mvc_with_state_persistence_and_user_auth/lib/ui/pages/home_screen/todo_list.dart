part of 'home_screen.dart';

class TodoList extends StatelessWidget {
  const TodoList();
  @override
  Widget build(BuildContext context) {
    return On.data(
      () {
        return ListView.builder(
          itemCount: todosFiltered.state.length,
          itemBuilder: (BuildContext context, int index) {
            return todos.item.inherited(
              key: Key('${todosFiltered.state[index].id}'),
              item: () {
                return todosFiltered.state[index];
              },
              builder: (_) => TodoItem(),
              debugPrintWhenNotifiedPreMessage: 'todo $index',
            );
          },
        );
      },
    ).listenTo(todosFiltered);
  }
}
