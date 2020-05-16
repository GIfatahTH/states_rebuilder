import 'package:flutter/material.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/domain/exceptions/validation_exception.dart';
import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/service/exceptions/persistance_exception.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return null;
    }
    if (error is ValidationException) {
      return error.message;
    }

    if (error is PersistanceException) {
      return error.message;
    }

    throw (error);
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }
}
