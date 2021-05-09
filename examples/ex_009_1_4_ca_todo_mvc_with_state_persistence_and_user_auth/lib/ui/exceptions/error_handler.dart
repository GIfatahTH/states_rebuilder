import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../service/exceptions/auth_exception.dart';
import '../../service/exceptions/fetch_todos_exception.dart';

class ErrorHandler {
  static String getErrorMessage(Object error) {
    if (error is CRUDTodosException) {
      return error.message;
    }

    if (error is AuthException) {
      return error.message;
    }
    throw (error);
  }

  static void showErrorSnackBar(dynamic error) {
    RM.scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            FittedBox(child: Text(ErrorHandler.getErrorMessage(error))),
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

  static Future<T?> showErrorDialog<T>(dynamic error) {
    return RM.navigate.toDialog<T>(
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
