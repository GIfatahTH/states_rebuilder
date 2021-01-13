import 'package:states_rebuilder/states_rebuilder.dart';

import 'data_source/counter_fake_repository.dart';
import 'data_source/counter_firebase_repository.dart';
import 'service/counters_service.dart';
import 'ui/common/config.dart';

enum Flavor { Prod, Dev }
//Register Two implementation of IConfig interface
//Depending on the value of Injector.env one of them is instantiated.
final config = RM.injectFlavor({
  Flavor.Prod: () => ProdConfig(),
  Flavor.Dev: () => DevConfig(),
});

//Register Two implementation of ICounterRepository interface
//The generic type is inferred by dart

final counterRepository = RM.injectFlavor({
  Flavor.Prod: () => CounterFirebaseRepository(),
  Flavor.Dev: () => CounterFakeRepository(),
});

final counterService = RM.inject(
  () => CountersService(counterRepository.state),
);
