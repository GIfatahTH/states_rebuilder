import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domain/exceptions/validation_exception.dart';
import '../../service/exceptions/fetch_exception.dart';
import '../../service/exceptions/input_exception.dart';

class ErrorHandler {
  //go through all custom errors and return the corresponding error message
  static String errorMessage(dynamic error) {
    if (error == null) {
      return null;
    }
    if (error is ValidationException) {
      return error.message;
    }

    if (error is NotNumberException) {
      return error.message;
    }
    if (error is NotInRangeException) {
      return error.message;
    }
    if (error is NetworkErrorException) {
      return error.message;
    }

    if (error is UserNotFoundException) {
      return error.message;
    }

    if (error is PostNotFoundException) {
      return error.message;
    }

    if (error is CommentNotFoundException) {
      return error.message;
    }
    // throw unexpected error.
    throw error;
  }

  //Display an AlertDialog with the error message
  static void showErrorDialog(dynamic error) {
    if (error == null) {
      return;
    }
    //Flutter Way
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       content: Text(errorMessage(error)),
    //     );
    //   },
    // );

    RM.navigate.toDialog(
      AlertDialog(
        content: Text(errorMessage(error)),
      ),
    );
  }

  //Display an snackBar with the error message
  static void showSnackBar(dynamic error) {
    if (error == null) {
      return;
    }
    RM.scaffold.showSnackBar(
      SnackBar(
        content: Text('${errorMessage(error)}'),
      ),
    );
  }
}
