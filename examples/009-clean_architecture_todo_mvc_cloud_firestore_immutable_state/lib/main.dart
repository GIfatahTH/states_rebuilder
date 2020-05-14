// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:clean_architecture_todo_mvc_cloud_firestore_immutable_state/service/interfaces/i_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'app.dart';
import 'data_source/auth_repository.dart';
import 'service/auth_state.dart';

void main() async {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //Inject the AuthRepository implementation and register is via its IAuthRepository interface.
        //This is important for testing (see bellow).
        Inject<IAuthRepository>(
          () => AuthRepository(),
        ),
        Inject<AuthState>(
          () => InitAuthState(
            IN.get<IAuthRepository>(),
          ),
        )
      ],
      builder: (context) => App(),
    );
  }
}

/*
In test you do not need any external mocking libraries. To test you have :

1- Create your fake implementation of IAuthRepository interface.
2- set the Injector.enableTestMode = true,
3- Inject the fake implementation above the MyApp via the IAuthRepository interface
tester.pumpWidgets(
  Injector(
    inject: [Inject<IAuthRepository>(()=>FakeRepositoryImplementation())],
    builder: (context)=>MyApp(),
  )
)

Now the testing app will use the fake implementation rather then the real implementation.
*/
