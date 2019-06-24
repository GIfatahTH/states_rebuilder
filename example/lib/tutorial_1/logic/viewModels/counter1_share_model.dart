import 'package:states_rebuilder/states_rebuilder.dart';
import '../services/counter_service.dart';

class Counter1ShareModel extends StatesRebuilder {
  final counterService = Injector.get<CounterService>();

  //Alternatively
  //Counter1ShareModel(this.counterService);
  //final CounterService counterService;

  int get counter => counterService.counter;
  increment() {
    counterService.increment();
    rebuildStates();
  }
}
