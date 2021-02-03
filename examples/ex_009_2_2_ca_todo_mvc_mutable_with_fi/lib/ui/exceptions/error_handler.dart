import 'package:flutter/material.dart';
import 'package:clean_architecture_todo_mvc/domain/exceptions/validation_exception.dart';
import 'package:clean_architecture_todo_mvc/service/exceptions/persistance_exception.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is ValidationException) {
      return error.message;
    }

    if (error is PersistanceException) {
      return error.message;
    }

    throw (error);
  }

  static void showErrorSnackBar(dynamic error) {
    RM.scaffold.snackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Text(ErrorHandler.getErrorMessage(error)),
            Spacer(),
            Icon(
              Icons.error_outline,
              color: Colors.yellow,
            )
          ],
        ),
      ),
    );
  }

  static void showErrorDialog(BuildContext context, dynamic error) {
    RM.navigate.toDialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.yellow,
            ),
            Text(ErrorHandler.getErrorMessage(error)),
          ],
        ),
      ),
    );
  }
}
