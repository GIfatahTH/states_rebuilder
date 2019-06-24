import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:states_rebuilder_demo/tutorial_1/logic/services/counter_service_the_same_view.dart';

class Counter2ShareModelSameView extends StatesRebuilder {
  final counterService = Injector.get<CounterServiceSameView>();

  int get counter => counterService.counter;
  increment() {
    counterService.increment();
  }
}
