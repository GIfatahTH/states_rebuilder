import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/injected.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todos_app_core/todos_app_core.dart';

import '../../../service/auth_state.dart';
import '../../../service/todos_state.dart';
import '../../common/enums.dart';
import '../../exceptions/error_handler.dart';

class ExtraActionsButton extends StatelessWidget {
  ExtraActionsButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateBuilder<ExtraAction>(
        key: Key('StateBuilder ExtraAction'),
        //Create a reactiveModel of type  ExtraAction and set its initialValue to ExtraAction.clearCompleted)
        observe: () => RM.create(ExtraAction.clearCompleted),
        builder: (context, extraActionRM) {
          return PopupMenuButton<ExtraAction>(
            key: ArchSampleKeys.extraActionsButton,
            onSelected: (action) {
              extraActionRM.state = action;

              if (action == ExtraAction.signOut) {
                authState.setState(
                  (authState) => AuthState.signOut(authState),
                  onError: ErrorHandler.showErrorSnackBar,
                );
                return;
              }

              todosState.setState(
                  (action == ExtraAction.toggleAllComplete)
                      ? (t) => TodosState.toggleAll(t)
                      : (t) => TodosState.clearCompleted(t),
                  onError: ErrorHandler.showErrorSnackBar);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<ExtraAction>>[
                PopupMenuItem<ExtraAction>(
                  key: ArchSampleKeys.toggleAll,
                  value: ExtraAction.toggleAllComplete,
                  child: Text(todosState.state.allComplete
                      ? ArchSampleLocalizations.of(context).markAllIncomplete
                      : ArchSampleLocalizations.of(context).markAllComplete),
                ),
                PopupMenuItem<ExtraAction>(
                  key: ArchSampleKeys.clearCompleted,
                  value: ExtraAction.clearCompleted,
                  child:
                      Text(ArchSampleLocalizations.of(context).clearCompleted),
                ),
                PopupMenuItem<ExtraAction>(
                  key: Key('signOut'),
                  value: ExtraAction.signOut,
                  child: Text('Logout'),
                ),
              ];
            },
          );
        });
  }
}
