// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'app.dart';
import 'data_source/todo_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    Injector(
        inject: [
          Inject<SharedPreferences>.future(
            () => SharedPreferences.getInstance(),
          ),
        ],
        builder: (context) {
          return StatesRebuilderApp();
        }),
  );
}
