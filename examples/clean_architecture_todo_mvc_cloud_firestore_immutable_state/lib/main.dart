// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'app.dart';
import 'data_source/auth_repository.dart';
import 'service/auth_state.dart';

void main() async {
  runApp(
    Injector(
      inject: [
        Inject<AuthState>(
          () => InitAuthState(
            AuthRepository(),
          ),
        )
      ],
      builder: (context) => StatesRebuilderApp(),
    ),
  );
}
