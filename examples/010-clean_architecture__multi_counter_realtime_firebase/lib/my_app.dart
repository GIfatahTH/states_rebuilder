import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/counter_fake_repository.dart';
import 'data_source/counter_firebase_repository.dart';
import 'service/counters_service.dart';
import 'ui/common/config.dart';
import 'ui/pages/home_page/home_page.dart';

enum Flavor { Prod, Dev }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        //Register Two implementation of IConfig interface
        //Depending on the value of Injector.env one of them is instantiated.
        Inject<IConfig>.interface({
          Flavor.Prod: () => ProdConfig(),
          Flavor.Dev: () => DevConfig(),
        }),
        //Register Two implementation of ICounterRepository interface
        //The generic type is inferred by dart
        Inject.interface({
          Flavor.Prod: () => CounterFirebaseRepository(),
          Flavor.Dev: () => CounterFakeRepository(),
        }),
        //Inject the CountersService class with Its dependency
        Inject(() => CountersService(Injector.get())),
        //Inject the countersStream.
        Inject.stream(() => Injector.get<CountersService>().countersStream())
      ],
      builder: (context) {
        return MaterialApp(
          title: 'Multiple counters',
          theme: ThemeData(
            //get the primarySwatch color from the Config file
            primarySwatch: Injector.get<IConfig>().primarySwatch,
          ),
          home: HomePage(),
        );
      },
    );
  }
}
