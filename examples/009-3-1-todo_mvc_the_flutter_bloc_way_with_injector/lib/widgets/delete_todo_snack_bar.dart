import 'package:flutter/material.dart';
import 'package:todo_mvc_the_flutter_bloc_way/models/models.dart';
import 'package:todos_app_core/todos_app_core.dart';

class DeleteTodoSnackBar extends SnackBar {
  final ArchSampleLocalizations localizations;

  DeleteTodoSnackBar({
    Key key,
    @required Todo todo,
    @required VoidCallback onUndo,
    @required this.localizations,
  }) : super(
          key: key,
          content: Text(
            localizations.todoDeleted(todo.task),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: localizations.undo,
            onPressed: onUndo,
          ),
        );
}
