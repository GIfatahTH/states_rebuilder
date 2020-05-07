// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';

import 'app.dart';
import 'data_source/todo_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    StatesRebuilderApp(
      repository: StatesRebuilderTodosRepository(),
    ),
  );
}
