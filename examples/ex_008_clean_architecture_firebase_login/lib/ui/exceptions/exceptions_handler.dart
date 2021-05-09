import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../domain/exceptions/Validation_exception.dart';
import '../../service/exceptions/sign_in_out_exception.dart';

class ExceptionsHandler {
  static ErrorMessage errorMessage(dynamic error) {
    if (error == null) {
      return ErrorMessage();
    }
    if (error is SignInException) {
      return ErrorMessage(message: error.message!, title: error.title);
    }

    if (error is ValidationException) {
      return ErrorMessage(message: error.message);
    }
    throw error;
  }

  static void showErrorDialog(dynamic error) {
    showDialog(
      context: RM.context!,
      builder: (context) {
        return AlertDialog(
          title: Text(errorMessage(error).title!),
          content: Text(errorMessage(error).message!),
        );
      },
    );
  }
}

class ErrorMessage {
  final String? title;
  final String? message;

  ErrorMessage({this.title, this.message});
}
