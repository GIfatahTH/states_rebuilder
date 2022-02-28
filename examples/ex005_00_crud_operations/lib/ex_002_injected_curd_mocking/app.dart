import 'package:flutter/material.dart';

import '../ex_001_crud_app_using_injected_crud/app.dart';
import '../ex_001_crud_app_using_injected_crud/blocs/todos_bloc.dart';
import '../ex_001_crud_app_using_injected_crud/models/todo.dart';

void main() {
  // This is useful if you want to test the UI
  todosViewModel().injectMock(
    () => List.generate(
      10,
      (i) => Todo(
        id: '$i',
        description: 'Description $i',
        completed: i % 3 == 0,
      ),
    ),
  );
  // //** */
  // // You can mock it using injectedFuture
  // todosViewModel().injectFutureMock(
  //   () async {
  //     await Future.delayed(const Duration(seconds: 3));
  //     return List.generate(
  //       10,
  //       (i) => Todo(
  //         id: '$i',
  //         description: 'Description $i',
  //         completed: i % 3 == 0,
  //       ),
  //     );
  //   },
  // );
  //
  // //** */
  // // You can fake the ICRUD repository
  // todosViewModel().injectCRUDMock(
  //   () =>  TodosFakeRepository(),
  // );
  runApp(const MyApp());
}
