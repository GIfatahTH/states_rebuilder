import 'package:flutter/material.dart';
import 'package:key_value_store_flutter/key_value_store_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:todo_mvc_the_flutter_bloc_way/injected.dart';
import 'package:todos_repository_local_storage/todos_repository_local_storage.dart';

import 'run_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = await SharedPreferences.getInstance();
  todosRepository = RM.inject(
    () => LocalStorageRepository(
      localStorage: KeyValueStorage(
        'bloc_library',
        FlutterKeyValueStore(pref),
      ),
    ),
  );
  runApp(TodosApp());
}
