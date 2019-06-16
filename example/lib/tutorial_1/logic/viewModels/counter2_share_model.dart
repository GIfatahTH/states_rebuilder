import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder_demo/tutorial_1/logic/services/counter_service.dart';

class Counter2ShareModel extends StatesRebuilder {
  Counter2ShareModel(this.counterService);

  final CounterService counterService;
  int get counter => counterService.counter;

  //Alternatively :
  //final counterService = Injector.get<CounterService>();

  increment() {
    counterService.increment();
    rebuildStates();
  }
}
