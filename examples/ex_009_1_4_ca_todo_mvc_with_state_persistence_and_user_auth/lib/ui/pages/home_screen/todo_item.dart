part of 'home_screen.dart';

///
class TodoItem extends StatelessWidget {
  const TodoItem({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todo = todosBloc.todosRM.item(context)!;
    return OnReactive(
      () => Dismissible(
        key: Key('__${todo.state.id}__'),
        onDismissed: (direction) {
          todosBloc.removeTodo(todo.state);
        },
        child: ListTile(
          onTap: () async {
            final shouldDelete = await RM.navigate.to(
              todosBloc.todosRM.item.reInherited(
                context: context,
                builder: (context) => DetailScreen(),
              ),
            );
            if (shouldDelete == true) {
              RM.scaffold.context = context;
              todosBloc.removeTodo(todo.state);
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
    );
  }
}
