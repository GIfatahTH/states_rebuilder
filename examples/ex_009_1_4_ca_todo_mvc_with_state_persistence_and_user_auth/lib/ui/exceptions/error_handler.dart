import '../../service/exceptions/auth_exception.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domain/exceptions/validation_exception.dart';
import '../../service/exceptions/persistance_exception.dart';

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
    if (error is AuthException) {
      return error.message;
    }
    // return '$error';
    throw (error);
  }

  static void showErrorSnackBar(dynamic error) {
    RM.scaffoldShow.snackBar(
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

  static Future<T> showErrorDialog<T>(dynamic error) {
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
