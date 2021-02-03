import 'dart:html';

import 'package:flutter/material.dart';
import 'package:key_value_store_web/key_value_store_web.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todos_repository_local_storage/todos_repository_local_storage.dart';
import 'run_app.dart';
import 'package:todo_mvc_the_flutter_bloc_way/injected.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  todosRepository = RM.inject(
    () => LocalStorageRepository(
      localStorage: KeyValueStorage(
        'bloc_library',
        WebKeyValueStore(window.localStorage),
      ),
    ),
  );
  runApp(TodosApp());
}
