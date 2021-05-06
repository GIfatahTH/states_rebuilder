part of 'home_screen.dart';

///
class TodoItem extends StatelessWidget {
  const TodoItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todo = todos.item(context)!;
    return On.data(
      () => Dismissible(
        key: Key('__${todo.state.id}__'),
        onDismissed: (direction) {
          removeTodo(todo.state);
        },
        child: ListTile(
          onTap: () async {
            final shouldDelete = await RM.navigate.to(
              todos.item.reInherited(
                context: context,
                builder: (context) => DetailScreen(),
              ),
            );
            if (shouldDelete == true) {
              RM.scaffold.context = context;
              removeTodo(todo.state);
            }
          },
          leading: Checkbox(
            key: Key('__Checkbox${todo.state.id}__'),
            value: todo.state.complete,
            onChanged: (value) {
              final newTodo = todo.state.copyWith(
                complete: value,
              );
              todo.state = newTodo;
            },
          ),
          title: Text(
            todo.state.task,
            style: Theme.of(context).textTheme.headline6,
          ),
          subtitle: Text(
            todo.state.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ),
    ).listenTo(todo);
  }

  void removeTodo(Todo todo) {
    todos.crud.delete(
      where: (t) => todo.id == t.id,
    );

    RM.scaffold.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          i18n.of(RM.context!).todoDeleted(todo.task),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        action: SnackBarAction(
          label: i18n.of(RM.context!).undo,
          onPressed: () {
            todos.crud.create(todo);
          },
        ),
      ),
    );
  }
}
